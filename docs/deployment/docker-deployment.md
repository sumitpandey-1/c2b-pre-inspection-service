# Docker Deployment Guide

This guide covers containerizing and deploying the C2B Pre-Inspection Service using Docker.

## Prerequisites

- Docker 20.10 or higher
- Docker Compose 2.0 or higher
- 2GB+ available memory
- 10GB+ available disk space

## Docker Setup

### 1. Create Dockerfile

Create a `Dockerfile` in the project root:

```dockerfile
# Multi-stage build for optimized image size
FROM gradle:8.14.2-jdk17 AS builder

# Set working directory
WORKDIR /app

# Copy build files
COPY build.gradle settings.gradle ./
COPY gradle/ gradle/
COPY gradlew ./

# Copy source code
COPY api/ api/
COPY assignment/ assignment/
COPY pipeline/ pipeline/
COPY attendance/ attendance/
COPY location/ location/
COPY appointment/ appointment/
COPY core/ core/
COPY shared-entity/ shared-entity/

# Build the application
RUN ./gradlew :api:bootJar --no-daemon

# Runtime stage
FROM openjdk:17-jre-slim

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy JAR from builder stage
COPY --from=builder /app/api/build/libs/*.jar app.jar

# Change ownership to non-root user
RUN chown appuser:appuser app.jar

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 2. Create .dockerignore

```dockerignore
# Build artifacts
build/
.gradle/
*.jar
*.war

# IDE files
.idea/
.vscode/
*.iml
*.ipr
*.iws

# OS files
.DS_Store
Thumbs.db

# Git
.git/
.gitignore

# Documentation
docs/
README.md
*.md

# Logs
logs/
*.log

# Temporary files
tmp/
temp/
```

### 3. Build Docker Image

```bash
# Build the image
docker build -t c2b-pre-inspection-service:latest .

# Build with specific tag
docker build -t c2b-pre-inspection-service:1.0.0 .

# Build with build arguments
docker build \
  --build-arg JAVA_OPTS="-Xmx512m" \
  -t c2b-pre-inspection-service:latest .
```

## Docker Compose Setup

### 1. Create docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build: .
    container_name: c2b-pre-inspection-service
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
      - SPRING_DATASOURCE_URL=jdbc:postgresql://db:5432/c2b_inspection
      - SPRING_DATASOURCE_USERNAME=c2b_user
      - SPRING_DATASOURCE_PASSWORD=c2b_password
      - JAVA_OPTS=-Xmx1g -Xms512m
    depends_on:
      db:
        condition: service_healthy
    networks:
      - c2b-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  db:
    image: postgres:15-alpine
    container_name: c2b-postgres
    environment:
      - POSTGRES_DB=c2b_inspection
      - POSTGRES_USER=c2b_user
      - POSTGRES_PASSWORD=c2b_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - c2b-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U c2b_user -d c2b_inspection"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: c2b-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - c2b-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3

volumes:
  postgres_data:
  redis_data:

networks:
  c2b-network:
    driver: bridge
```

### 2. Create docker-compose.override.yml (Development)

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      target: builder
    volumes:
      - .:/app
      - gradle_cache:/home/gradle/.gradle
    environment:
      - SPRING_PROFILES_ACTIVE=dev
      - SPRING_DEVTOOLS_RESTART_ENABLED=true
    command: ./gradlew :api:bootRun

  db:
    ports:
      - "5433:5432"  # Different port for dev

volumes:
  gradle_cache:
```

### 3. Create Production docker-compose.prod.yml

```yaml
version: '3.8'

services:
  app:
    image: c2b-pre-inspection-service:1.0.0
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - JAVA_OPTS=-Xmx2g -Xms1g -XX:+UseG1GC
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "3"

  db:
    deploy:
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "3"
```

## Running with Docker Compose

### Development Environment

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up --build -d
```

### Production Environment

```bash
# Start production services
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Scale application instances
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --scale app=3

# Update application
docker-compose -f docker-compose.yml -f docker-compose.prod.yml pull app
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d app
```

## Environment Configuration

### 1. Create .env file

```env
# Application
APP_VERSION=1.0.0
SPRING_PROFILES_ACTIVE=docker

# Database
POSTGRES_DB=c2b_inspection
POSTGRES_USER=c2b_user
POSTGRES_PASSWORD=your_secure_password_here

# JVM Options
JAVA_OPTS=-Xmx1g -Xms512m

# Ports
APP_PORT=8080
DB_PORT=5432
REDIS_PORT=6379
```

### 2. Application Properties for Docker

Create `application-docker.properties`:

```properties
# Database Configuration
spring.datasource.url=jdbc:postgresql://db:5432/${POSTGRES_DB}
spring.datasource.username=${POSTGRES_USER}
spring.datasource.password=${POSTGRES_PASSWORD}

# JPA Configuration
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.format_sql=false

# Redis Configuration
spring.data.redis.host=redis
spring.data.redis.port=6379

# Actuator Configuration
management.endpoints.web.exposure.include=health,info,metrics,prometheus
management.endpoint.health.show-details=when-authorized

# Logging Configuration
logging.level.com.cars24.c2b_pre_inspection_service=INFO
logging.level.org.springframework.security=WARN
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n
```

## Database Initialization

### 1. Create init-db.sql

```sql
-- Create database schema
CREATE SCHEMA IF NOT EXISTS c2b_inspection;

-- Create tables
CREATE TABLE IF NOT EXISTS assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    inspector_id VARCHAR(255) NOT NULL,
    appointment_id VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL,
    scheduled_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pipelines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_assignments_inspector ON assignments(inspector_id);
CREATE INDEX IF NOT EXISTS idx_assignments_status ON assignments(status);
CREATE INDEX IF NOT EXISTS idx_pipelines_status ON pipelines(status);

-- Insert sample data
INSERT INTO assignments (inspector_id, appointment_id, status, scheduled_date) 
VALUES 
    ('inspector-1', 'appointment-1', 'ASSIGNED', '2024-01-20 09:00:00'),
    ('inspector-2', 'appointment-2', 'IN_PROGRESS', '2024-01-20 10:00:00')
ON CONFLICT DO NOTHING;
```

## Health Checks and Monitoring

### 1. Application Health Check

```bash
# Check application health
curl http://localhost:8080/actuator/health

# Check specific component health
curl http://localhost:8080/actuator/health/db
curl http://localhost:8080/actuator/health/redis
```

### 2. Container Health Monitoring

```bash
# Check container status
docker-compose ps

# View container logs
docker-compose logs app
docker-compose logs db

# Monitor resource usage
docker stats c2b-pre-inspection-service
```

## Backup and Restore

### 1. Database Backup

```bash
# Create backup
docker-compose exec db pg_dump -U c2b_user c2b_inspection > backup.sql

# Restore backup
docker-compose exec -T db psql -U c2b_user c2b_inspection < backup.sql
```

### 2. Volume Backup

```bash
# Backup volumes
docker run --rm -v c2b-pre-inspection-service_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz /data

# Restore volumes
docker run --rm -v c2b-pre-inspection-service_postgres_data:/data -v $(pwd):/backup alpine tar xzf /backup/postgres_backup.tar.gz
```

## Security Considerations

### 1. Image Security

```dockerfile
# Use specific versions
FROM openjdk:17.0.2-jre-slim

# Run as non-root user
RUN addgroup --system appuser && adduser --system --group appuser
USER appuser

# Remove unnecessary packages
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
```

### 2. Network Security

```yaml
# Use custom networks
networks:
  c2b-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

# Limit port exposure
ports:
  - "127.0.0.1:8080:8080"  # Bind to localhost only
```

### 3. Secrets Management

```yaml
# Use Docker secrets
secrets:
  db_password:
    file: ./secrets/db_password.txt

services:
  app:
    secrets:
      - db_password
    environment:
      - SPRING_DATASOURCE_PASSWORD_FILE=/run/secrets/db_password
```

## Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Find process using port
   lsof -i :8080
   
   # Use different port
   docker-compose up -d --scale app=0
   docker-compose up -d -p 8081:8080
   ```

2. **Database Connection Failed**
   ```bash
   # Check database logs
   docker-compose logs db
   
   # Test connection
   docker-compose exec app curl -f http://localhost:8080/actuator/health/db
   ```

3. **Out of Memory**
   ```bash
   # Increase memory limits
   docker-compose up -d --scale app=0
   docker-compose run -e JAVA_OPTS="-Xmx2g" app
   ```

### Performance Tuning

```yaml
# Optimize for production
services:
  app:
    environment:
      - JAVA_OPTS=-Xmx2g -Xms1g -XX:+UseG1GC -XX:MaxGCPauseMillis=200
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
```

---

*This guide provides comprehensive Docker deployment instructions for development and production environments.*
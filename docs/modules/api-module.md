# API Module

The API module serves as the main Spring Boot application and orchestration layer for the C2B Pre-Inspection Service. It provides the web interface, security configuration, and coordinates interactions between domain modules.

## Overview

- **Module Name**: `api`
- **Type**: Spring Boot Application
- **Purpose**: HTTP API layer and application orchestration
- **Dependencies**: All domain modules (assignment, pipeline, attendance, location, appointment), core, shared-entity

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        API Module                           │
├─────────────────────────────────────────────────────────────┤
│  Controllers  │  Security  │  Configuration  │  Filters     │
├─────────────────────────────────────────────────────────────┤
│                    Service Layer                            │
├─────────────────────────────────────────────────────────────┤
│  Assignment   │  Pipeline  │  Attendance  │  Location  │    │
│  Client       │  Client    │  Client      │  Client    │... │
└─────────────────────────────────────────────────────────────┘
```

## Package Structure

```
api/
├── src/main/java/com/cars24/c2b_pre_inspection_service/api/
│   ├── C2bPreInspectionServiceApplication.java  # Main application class
│   ├── client/                                  # Public API interfaces
│   └── internal/                               # Internal implementation
│       ├── config/                             # Configuration classes
│       ├── controller/                         # REST controllers
│       ├── security/                           # Security configuration
│       ├── service/                            # Business services
│       └── dto/                                # Data transfer objects
└── src/main/resources/
    ├── application.properties                   # Application configuration
    └── static/                                 # Static resources
```

## Key Components

### Main Application Class

```java
@SpringBootApplication
@EnableJpaRepositories
@EnableScheduling
public class C2bPreInspectionServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(C2bPreInspectionServiceApplication.class, args);
    }
}
```

### Controllers

#### Assignment Controller
- **Path**: `/api/assignments`
- **Responsibilities**:
  - CRUD operations for assignments
  - Assignment status management
  - Inspector assignment logic

#### Pipeline Controller
- **Path**: `/api/pipelines`
- **Responsibilities**:
  - Pipeline workflow management
  - Stage progression tracking
  - Process orchestration

#### Attendance Controller
- **Path**: `/api/attendance`
- **Responsibilities**:
  - Clock in/out operations
  - Attendance record management
  - Time tracking

#### Location Controller
- **Path**: `/api/locations`
- **Responsibilities**:
  - Location search and management
  - Distance calculations
  - Geographic operations

#### Appointment Controller
- **Path**: `/api/appointments`
- **Responsibilities**:
  - Appointment scheduling
  - Customer interaction
  - Appointment lifecycle management

### Security Configuration

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/actuator/health").permitAll()
                .requestMatchers("/api/auth/**").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(withDefaults()))
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .build();
    }
}
```

### Configuration Classes

#### Database Configuration
```java
@Configuration
@EnableJpaRepositories(basePackages = "com.cars24.c2b_pre_inspection_service")
public class DatabaseConfig {
    
    @Bean
    @Primary
    public DataSource dataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl("jdbc:h2:mem:testdb");
        config.setUsername("sa");
        config.setPassword("");
        return new HikariDataSource(config);
    }
}
```

#### Web Configuration
```java
@Configuration
@EnableWebMvc
public class WebConfig implements WebMvcConfigurer {
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
            .allowedOrigins("*")
            .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH")
            .allowedHeaders("*");
    }
}
```

## Service Layer

The API module contains service classes that orchestrate calls to domain modules:

### Assignment Service
```java
@Service
@Transactional
public class AssignmentService {
    
    private final AssignmentClient assignmentClient;
    private final LocationClient locationClient;
    private final AttendanceClient attendanceClient;
    
    public AssignmentDto createAssignment(CreateAssignmentRequest request) {
        // Validate inspector availability
        // Check location accessibility
        // Create assignment through domain module
        // Return result
    }
}
```

## Error Handling

### Global Exception Handler
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<ErrorResponse> handleValidation(ValidationException ex) {
        return ResponseEntity.badRequest()
            .body(ErrorResponse.builder()
                .code("VALIDATION_ERROR")
                .message(ex.getMessage())
                .build());
    }
    
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        return ResponseEntity.notFound().build();
    }
}
```

## Configuration Properties

### Application Properties
```properties
# Server Configuration
server.port=8080
server.servlet.context-path=/

# Database Configuration
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.username=sa
spring.datasource.password=
spring.h2.console.enabled=true

# JPA Configuration
spring.jpa.hibernate.ddl-auto=create-drop
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true

# Actuator Configuration
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=always

# Logging Configuration
logging.level.com.cars24.c2b_pre_inspection_service=DEBUG
logging.level.org.springframework.security=DEBUG
```

## API Documentation

### OpenAPI Configuration
```java
@Configuration
public class OpenApiConfig {
    
    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("C2B Pre-Inspection Service API")
                .version("1.0.0")
                .description("API for managing vehicle pre-inspection services"))
            .addSecurityItem(new SecurityRequirement().addList("bearerAuth"))
            .components(new Components()
                .addSecuritySchemes("bearerAuth", 
                    new SecurityScheme()
                        .type(SecurityScheme.Type.HTTP)
                        .scheme("bearer")
                        .bearerFormat("JWT")));
    }
}
```

## Testing

### Controller Tests
```java
@WebMvcTest(AssignmentController.class)
class AssignmentControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private AssignmentService assignmentService;
    
    @Test
    void createAssignment_ShouldReturnCreated() throws Exception {
        // Test implementation
    }
}
```

### Integration Tests
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@TestPropertySource(properties = "spring.datasource.url=jdbc:h2:mem:testdb")
class AssignmentIntegrationTest {
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void assignmentLifecycle_ShouldWork() {
        // Integration test implementation
    }
}
```

## Monitoring and Observability

### Health Checks
- **Database connectivity**: Checks H2/PostgreSQL connection
- **Disk space**: Monitors available disk space
- **Custom health indicators**: Domain-specific health checks

### Metrics
- **Request metrics**: Response times, error rates
- **Business metrics**: Assignment counts, pipeline completion rates
- **JVM metrics**: Memory usage, garbage collection

### Logging
- **Structured logging**: JSON format for log aggregation
- **Correlation IDs**: Request tracing across modules
- **Security events**: Authentication and authorization logs

## Security Features

### Authentication
- **JWT tokens**: Stateless authentication
- **Token validation**: Signature and expiration checks
- **User context**: Security context propagation

### Authorization
- **Role-based access**: Fine-grained permissions
- **Method-level security**: `@PreAuthorize` annotations
- **Resource-level security**: Owner-based access control

### Security Headers
- **CORS**: Cross-origin resource sharing configuration
- **CSRF**: Cross-site request forgery protection
- **Security headers**: XSS protection, content type options

## Performance Considerations

### Database Optimization
- **Connection pooling**: HikariCP configuration
- **Query optimization**: Efficient JPA queries
- **Caching**: Redis integration for frequently accessed data

### API Performance
- **Pagination**: Limit large result sets
- **Compression**: Gzip response compression
- **Rate limiting**: Prevent API abuse

## Deployment

### JAR Packaging
```bash
./gradlew :api:bootJar
java -jar api/build/libs/api-1.0.0.jar
```

### Docker Deployment
```dockerfile
FROM openjdk:17-jre-slim
COPY api/build/libs/api-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

### Environment Configuration
- **Development**: H2 database, debug logging
- **Staging**: PostgreSQL, info logging
- **Production**: PostgreSQL, warn logging, security hardening

## Future Enhancements

### Planned Features
- **GraphQL API**: Alternative query interface
- **WebSocket support**: Real-time updates
- **File upload**: Document and image handling
- **Batch operations**: Bulk data processing

### Scalability Improvements
- **Caching layer**: Redis for performance
- **Message queues**: Async processing
- **Load balancing**: Multiple instance support
- **Database sharding**: Horizontal scaling

---

*This module serves as the entry point and orchestration layer for the entire application.* 
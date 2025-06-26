# Getting Started

This guide will help you set up the C2B Pre-Inspection Service development environment and get the application running locally.

## Prerequisites

### Required Software
- **Java 17 or higher** - [Download OpenJDK](https://adoptium.net/)
- **Git** - [Download Git](https://git-scm.com/downloads)
- **IDE** - IntelliJ IDEA (recommended) or Eclipse

### Optional Tools
- **Docker** - For containerized deployment
- **Postman** - For API testing
- **DBeaver** - For database management

## Environment Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd c2b-pre-inspection-service
```

### 2. Verify Java Installation
```bash
java -version
# Should show Java 17 or higher
```

### 3. Make Gradle Wrapper Executable
```bash
chmod +x gradlew
```

### 4. Quick Setup (Automated)
```bash
make dev-setup
```

This command will:
- Clean any previous builds
- Download dependencies
- Compile all modules
- Run initial tests
- Set up the development environment

## Manual Setup (Alternative)

If you prefer manual setup or the Makefile isn't available:

### 1. Clean and Build
```bash
./gradlew clean build
```

### 2. Run Tests
```bash
./gradlew test
```

### 3. Start the Application
```bash
./gradlew :api:bootRun
```

## Running the Application

### Using Makefile (Recommended)
```bash
# Start the application
make run

# Start in development mode (with hot reload)
make run-dev

# Run in background
make run-background

# Check application status
make status

# Stop background application
make stop
```

### Using Gradle Directly
```bash
# Run the main application
./gradlew :api:bootRun

# Run with specific profile
./gradlew :api:bootRun --args='--spring.profiles.active=dev'

# Run with debug mode
./gradlew :api:bootRun --debug-jvm
```

### Using JAR File
```bash
# Build JAR
make bootjar

# Run JAR
make run-jar
```

## Verification

### 1. Check Application Health
```bash
curl http://localhost:8080/actuator/health
```

Expected response:
```json
{
  "status": "UP"
}
```

### 2. Access H2 Database Console
- URL: http://localhost:8080/h2-console
- JDBC URL: `jdbc:h2:mem:testdb`
- Username: `sa`
- Password: (leave empty)

### 3. View Application Info
```bash
curl http://localhost:8080/actuator/info
```

## Development Workflow

### 1. Daily Development Commands
```bash
# Start development session
make dev-setup
make run-dev

# Run tests frequently
make test

# Check build status
make build

# View logs
make logs
```

### 2. Module-Specific Development
```bash
# Test specific module
./gradlew :assignment:test
./gradlew :pipeline:test

# Build specific module
./gradlew :api:build
```

### 3. Database Operations
```bash
# Access H2 console
make db-console

# Reset database (restart application)
make restart
```

## IDE Setup

### IntelliJ IDEA (Recommended)

1. **Import Project**
   - File → Open → Select project root directory
   - Choose "Import Gradle project"
   - Use Gradle wrapper

2. **Configure Java SDK**
   - File → Project Structure → Project
   - Set Project SDK to Java 17
   - Set Project language level to 17

3. **Enable Annotation Processing**
   - File → Settings → Build → Compiler → Annotation Processors
   - Check "Enable annotation processing"

4. **Install Recommended Plugins**
   - Spring Boot
   - Gradle
   - Database Tools and SQL
   - Git Integration

### Eclipse Setup

1. **Import Project**
   - File → Import → Existing Gradle Project
   - Select project root directory

2. **Configure Java Build Path**
   - Right-click project → Properties → Java Build Path
   - Set JRE to Java 17

## Project Structure Overview

```
c2b-pre-inspection-service/
├── api/                    # Main Spring Boot application
├── assignment/             # Assignment domain module
├── pipeline/              # Pipeline domain module
├── attendance/            # Attendance domain module
├── location/              # Location domain module
├── appointment/           # Appointment domain module
├── core/                  # Shared utilities
├── shared-entity/         # Common entities and DTOs
├── docs/                  # Documentation
├── build.gradle           # Root build configuration
├── settings.gradle        # Gradle settings
├── Makefile              # Development commands
└── README.md             # Project overview
```

## Common Issues and Solutions

### Issue: Gradle Build Fails
```bash
# Solution: Clean and rebuild
make clean
make build
```

### Issue: Port 8080 Already in Use
```bash
# Solution: Kill process using port 8080
lsof -ti:8080 | xargs kill -9

# Or change port in application.properties
server.port=8081
```

### Issue: Java Version Mismatch
```bash
# Check current Java version
java -version

# Set JAVA_HOME (macOS/Linux)
export JAVA_HOME=/path/to/java17

# Set JAVA_HOME (Windows)
set JAVA_HOME=C:\path\to\java17
```

### Issue: Tests Failing
```bash
# Run tests with detailed output
./gradlew test --info

# Run specific test class
./gradlew test --tests "com.cars24.c2b_pre_inspection_service.api.*"
```

## Development Best Practices

### 1. Code Style
- Follow Java naming conventions
- Use meaningful variable and method names
- Add appropriate comments and documentation
- Keep methods small and focused

### 2. Testing
- Write unit tests for all business logic
- Use integration tests for API endpoints
- Maintain test coverage above 80%
- Run tests before committing code

### 3. Git Workflow
- Create feature branches for new work
- Write descriptive commit messages
- Keep commits small and focused
- Rebase before merging to main

### 4. Module Boundaries
- Keep domain logic within respective modules
- Use client interfaces for inter-module communication
- Avoid circular dependencies between modules
- Follow the established package structure

## Next Steps

1. **Explore the Codebase**
   - Review module structure in [Module Architecture](../architecture/module-architecture.md)
   - Understand the API endpoints in [REST API Reference](../api/rest-api.md)

2. **Development Guidelines**
   - Read [Development Guidelines](development-guidelines.md)
   - Understand [Testing Strategy](testing-strategy.md)

3. **Start Contributing**
   - Pick up a task from the backlog
   - Create a feature branch
   - Follow the development workflow
   - Submit a pull request

## Getting Help

- **Documentation**: Check the `docs/` folder for detailed guides
- **Code Examples**: Look at existing module implementations
- **Team Support**: Reach out to team members for guidance
- **Issues**: Create GitHub issues for bugs or feature requests

---

*Happy coding! 🚀* 
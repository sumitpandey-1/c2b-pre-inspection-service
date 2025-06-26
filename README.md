# C2B Pre-Inspection Service - Multimodule Project

## Overview
This project has been converted from a single module Spring Boot application into a multimodule project following Domain-Driven Design (DDD) principles.

## Module Structure

The project consists of the following modules:

### 1. **api** (Main Application Module)
- **Purpose**: Entry point for the application and API layer
- **Location**: `api/`
- **Main Class**: `C2bPreInspectionServiceApplication`
- **Dependencies**: All other modules
- **Packages**:
  - `client/`: Interfaces for external communication
  - `internal/`: Internal API business logic

### 2. **assignment** (Domain Module)
- **Purpose**: Handles assignment-related functionality
- **Location**: `assignment/`
- **Packages**:
  - `client/`: `AssignmentClient` - External interface for assignment operations
  - `internal/`: `AssignmentService` - Internal assignment business logic

### 3. **pipeline** (Domain Module)
- **Purpose**: Handles pipeline-related functionality
- **Location**: `pipeline/`
- **Packages**:
  - `client/`: `PipelineClient` - External interface for pipeline operations
  - `internal/`: `PipelineService` - Internal pipeline business logic

### 4. **attendance** (Domain Module)
- **Purpose**: Handles attendance-related functionality
- **Location**: `attendance/`
- **Packages**:
  - `client/`: `AttendanceClient` - External interface for attendance operations
  - `internal/`: `AttendanceService` - Internal attendance business logic

### 5. **location** (Domain Module)
- **Purpose**: Handles location-related functionality
- **Location**: `location/`
- **Packages**:
  - `client/`: `LocationClient` - External interface for location operations
  - `internal/`: `LocationService` - Internal location business logic

### 6. **appointment** (Domain Module)
- **Purpose**: Handles appointment-related functionality
- **Location**: `appointment/`
- **Packages**:
  - `client/`: `AppointmentClient` - External interface for appointment operations
  - `internal/`: `AppointmentService` - Internal appointment business logic

### 7. **core** (Core Module)
- **Purpose**: Contains core utilities, constants, and configurations
- **Location**: `core/`
- **Key Classes**:
  - `Constants`: Application-wide constants
  - `BaseException`: Base exception class

### 8. **shared-entity** (Shared Entity Module)
- **Purpose**: Contains shared entities and DTOs
- **Location**: `shared-entity/`
- **Key Classes**:
  - `BaseEntity`: Common entity base class
  - `ResponseDto`: Standardized response wrapper
- **Access Rule**: Can only access `client` packages of other modules

## Architecture Principles

### Domain-Driven Design (DDD)
- Each module represents a bounded context
- Clear boundaries between domains
- Shared kernel in `coreshared-entity`

### Module Communication Rules
1. **Client Package**: Public interfaces for inter-module communication
2. **Internal Package**: Private implementation details, not accessible by other modules
3. **Shared Entity Access**: Only accesses `client` packages of other modules

### Dependency Flow
```
api (depends on all modules)
├── assignment
├── pipeline  
├── attendance
├── location
├── appointment
├── core (shared utilities)
└── shared-entity (shared entities, depends on core)
```

## Building the Project

### Prerequisites
- Java 21
- Gradle 8.x

### Build Commands
```bash
# Clean and build all modules
./gradlew clean build

# Build specific module
./gradlew :api:build
./gradlew :assignment:build

# Run the application (API module)
./gradlew :api:bootRun
```

## Module Dependencies

### API Module
```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation project(':assignment')
    implementation project(':pipeline')
    implementation project(':attendance')
    implementation project(':location')
    implementation project(':appointment')
    implementation project(':core')
    implementation project(':shared-entity')
}
```

### Domain Modules (assignment, pipeline, etc.)
```gradle
dependencies {
    implementation project(':core')
    implementation project(':shared-entity')
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
}
```

### Core Module
```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
}
```

### Shared Entity Module
```gradle
dependencies {
    implementation project(':core')
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
}
```

## Development Guidelines

### Adding New Features
1. Place domain-specific logic in the appropriate module's `internal` package
2. Expose functionality through `client` interfaces
3. Use `core` for utilities, constants, and configurations
4. Use `shared-entity` for common entities and DTOs

### Inter-Module Communication
```java
// ✅ Correct: Using client interface
@Autowired
private AssignmentClient assignmentClient;

// ❌ Incorrect: Direct access to internal classes
@Autowired
private AssignmentService assignmentService; // Should not be accessible
```

### Package Structure Convention
```
com.cars24.c2b_pre_inspection_service.{module}
├── client/           # Public interfaces
│   └── {Module}Client.java
└── internal/         # Private implementation
    └── {Module}Service.java
```

## Running the Application

The main application class is located in the `api` module:
```
api/src/main/java/com/cars24/c2b_pre_inspection_service/api/C2bPreInspectionServiceApplication.java
```

The application is configured to scan all packages under `com.cars24.c2b_pre_inspection_service` to discover beans from all modules.

## Next Steps

1. **Implement Client Interfaces**: Add actual methods to client interfaces based on your business requirements
2. **Add Service Implementations**: Implement the business logic in internal service classes
3. **Configure Databases**: Add database configurations for each module if needed
4. **Add Security**: Implement security configurations appropriate for each module
5. **Add Tests**: Create unit and integration tests for each module

## Troubleshooting

If you encounter build issues:
1. Ensure Java 21 is installed and JAVA_HOME is set correctly
2. Try cleaning the project: `./gradlew clean`
3. Check for circular dependencies between modules
4. Verify network connectivity for downloading dependencies 
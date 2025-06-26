# System Architecture

## Overview

The C2B Pre-Inspection Service is designed using a **multimodule monolith** architecture with **Domain-Driven Design (DDD)** principles. This approach provides clear module boundaries while maintaining deployment simplicity.

## Architecture Principles

### 1. Domain-Driven Design (DDD)
- **Bounded Contexts**: Each module represents a distinct business domain
- **Ubiquitous Language**: Consistent terminology across business and technical teams
- **Domain Models**: Rich domain objects with business logic encapsulation

### 2. Hexagonal Architecture (Ports & Adapters)
- **Client/Internal Package Structure**: Clear separation of public APIs and internal implementation
- **Dependency Inversion**: Dependencies point inward toward the domain
- **Testability**: Easy to mock external dependencies

### 3. Modular Monolith Benefits
- **Independent Development**: Teams can work on different modules simultaneously
- **Gradual Migration**: Modules can be extracted to microservices if needed
- **Simplified Deployment**: Single deployable unit reduces operational complexity

## System Components

```
┌─────────────────────────────────────────────────────────────┐
│                    C2B Pre-Inspection Service               │
├─────────────────────────────────────────────────────────────┤
│                        API Module                           │
│              (Spring Boot Application)                      │
├─────────────┬─────────────┬─────────────┬─────────────────┤
│ Assignment  │  Pipeline   │ Attendance  │   Location      │
│   Module    │   Module    │   Module    │    Module       │
├─────────────┼─────────────┼─────────────┼─────────────────┤
│ Appointment │    Core     │ Shared-Entity                 │
│   Module    │   Module    │    Module                     │
└─────────────┴─────────────┴─────────────────────────────────┘
```

## Module Responsibilities

### API Module
- **Purpose**: Main Spring Boot application and orchestration layer
- **Responsibilities**:
  - HTTP request/response handling
  - Security configuration
  - Cross-cutting concerns (logging, monitoring)
  - Module composition and dependency injection

### Domain Modules
Each domain module follows the same structure:

#### Assignment Module
- **Domain**: Inspector assignment and scheduling
- **Key Entities**: Assignment, Inspector, Schedule
- **Business Logic**: Assignment algorithms, availability checking

#### Pipeline Module
- **Domain**: Inspection workflow and process management
- **Key Entities**: Pipeline, Stage, Workflow
- **Business Logic**: Process orchestration, state transitions

#### Attendance Module
- **Domain**: Inspector attendance tracking
- **Key Entities**: Attendance, TimeSlot, CheckIn/CheckOut
- **Business Logic**: Time tracking, attendance validation

#### Location Module
- **Domain**: Geographic location management
- **Key Entities**: Location, Address, GeoCoordinate
- **Business Logic**: Location validation, distance calculations

#### Appointment Module
- **Domain**: Customer appointment scheduling
- **Key Entities**: Appointment, TimeSlot, Customer
- **Business Logic**: Scheduling algorithms, conflict resolution

### Infrastructure Modules

#### Core Module
- **Purpose**: Shared utilities and cross-cutting concerns
- **Contains**:
  - Common exceptions
  - Utility classes
  - Constants and enums
  - Validation helpers

#### Shared-Entity Module
- **Purpose**: Common domain entities and DTOs
- **Contains**:
  - Base entities
  - Common DTOs
  - Shared value objects
  - Database configurations

## Technology Stack

### Core Technologies
- **Spring Boot 3.5.0**: Application framework
- **Spring Data JPA**: Data persistence
- **Spring Security**: Authentication and authorization
- **Spring Web**: REST API development

### Database
- **Development**: H2 in-memory database
- **Production**: PostgreSQL (recommended)
- **Migration**: Flyway/Liquibase for schema management

### Build & Deployment
- **Build Tool**: Gradle 8.14.2
- **Java Version**: 17 (LTS)
- **Packaging**: Executable JAR
- **Container**: Docker (optional)

## Communication Patterns

### Inter-Module Communication
- **Direct Method Calls**: Modules communicate through client interfaces
- **Event-Driven**: Domain events for loose coupling (future enhancement)
- **Shared Data**: Common entities through shared-entity module

### External Communication
- **REST APIs**: Standard HTTP/JSON for external clients
- **Database**: JPA/Hibernate for data persistence
- **Messaging**: Future support for async communication

## Security Architecture

### Authentication
- **JWT Tokens**: Stateless authentication
- **Spring Security**: Framework-level security
- **Role-Based Access**: Fine-grained permissions

### Authorization
- **Method-Level Security**: `@PreAuthorize` annotations
- **URL-Based Security**: Path-specific access rules
- **Domain-Level Security**: Business rule enforcement

## Scalability Considerations

### Current Architecture
- **Vertical Scaling**: Increase instance resources
- **Load Balancing**: Multiple application instances
- **Database Optimization**: Connection pooling, query optimization

### Future Migration Path
- **Microservices**: Extract modules to independent services
- **Event Sourcing**: Implement for audit and replay capabilities
- **CQRS**: Separate read/write models for performance

## Quality Attributes

### Maintainability
- **Clear Module Boundaries**: Reduced coupling between domains
- **Consistent Patterns**: Standardized structure across modules
- **Comprehensive Testing**: Unit, integration, and contract tests

### Performance
- **Database Optimization**: Efficient queries and indexing
- **Caching Strategy**: Redis for frequently accessed data
- **Connection Pooling**: HikariCP for database connections

### Reliability
- **Error Handling**: Comprehensive exception management
- **Health Checks**: Application and dependency monitoring
- **Graceful Degradation**: Fallback mechanisms

## Deployment Architecture

```
┌─────────────────────────────────────────────────┐
│                Load Balancer                    │
└─────────────────┬───────────────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
┌───▼───┐    ┌───▼───┐    ┌───▼───┐
│App    │    │App    │    │App    │
│Instance│    │Instance│    │Instance│
│  1    │    │  2    │    │  3    │
└───────┘    └───────┘    └───────┘
    │             │             │
    └─────────────┼─────────────┘
                  │
            ┌─────▼─────┐
            │ Database  │
            │Cluster    │
            └───────────┘
```

## Monitoring & Observability

### Application Metrics
- **Spring Boot Actuator**: Health checks and metrics
- **Micrometer**: Application performance monitoring
- **Custom Metrics**: Business-specific measurements

### Logging
- **Structured Logging**: JSON format for log aggregation
- **Correlation IDs**: Request tracing across modules
- **Log Levels**: Configurable logging per module

### Distributed Tracing
- **Future Enhancement**: OpenTelemetry integration
- **Request Flow**: Track requests across module boundaries
- **Performance Analysis**: Identify bottlenecks

---

*This document describes the current system architecture and future evolution plans.* 
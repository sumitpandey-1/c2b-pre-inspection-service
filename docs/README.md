# C2B Pre-Inspection Service Documentation

Welcome to the C2B Pre-Inspection Service documentation. This service is built using Spring Boot 3.5.0 with a multimodule architecture following Domain-Driven Design principles.

## 📚 Documentation Index

### 🏗️ Architecture
- [System Architecture](architecture/system-architecture.md) - High-level system design and components
- [Module Architecture](architecture/module-architecture.md) - Detailed module structure and interactions
- [Database Design](architecture/database-design.md) - Database schema and relationships
- [Security Architecture](architecture/security-architecture.md) - Authentication and authorization design

### 🔧 Development
- [Getting Started](development/getting-started.md) - Quick setup guide for developers
- [Development Guidelines](development/development-guidelines.md) - Coding standards and best practices
- [Testing Strategy](development/testing-strategy.md) - Testing approach and guidelines
- [Build & Deployment](development/build-deployment.md) - Build process and deployment procedures

### 📦 Modules
- [API Module](modules/api-module.md) - Main Spring Boot application module
- [Assignment Module](modules/assignment-module.md) - Assignment domain logic
- [Pipeline Module](modules/pipeline-module.md) - Pipeline management functionality
- [Attendance Module](modules/attendance-module.md) - Attendance tracking features
- [Location Module](modules/location-module.md) - Location management services
- [Appointment Module](modules/appointment-module.md) - Appointment scheduling system
- [Core Module](modules/core-module.md) - Shared utilities and constants
- [Shared Entity Module](modules/shared-entity-module.md) - Common entities and DTOs

### 🚀 API Documentation
- [REST API Reference](api/rest-api.md) - Complete API endpoint documentation
- [API Authentication](api/authentication.md) - API security and authentication
- [Error Handling](api/error-handling.md) - Error codes and response formats
- [Rate Limiting](api/rate-limiting.md) - API rate limiting policies

### 🌐 Deployment
- [Environment Setup](deployment/environment-setup.md) - Environment configuration
- [Docker Deployment](deployment/docker-deployment.md) - Containerization guide
- [Production Deployment](deployment/production-deployment.md) - Production deployment checklist
- [Monitoring & Logging](deployment/monitoring-logging.md) - Observability setup

### 📊 Diagrams
- [System Overview](diagrams/system-overview.md) - High-level system diagrams
- [Database ERD](diagrams/database-erd.md) - Entity relationship diagrams
- [Sequence Diagrams](diagrams/sequence-diagrams.md) - Process flow diagrams

## 🚀 Quick Start

1. **Setup Development Environment**
   ```bash
   make dev-setup
   ```

2. **Run the Application**
   ```bash
   make run
   ```

3. **Run Tests**
   ```bash
   make test
   ```

4. **View All Available Commands**
   ```bash
   make help
   ```

## 📋 Project Information

- **Spring Boot Version**: 3.5.0
- **Java Version**: 17
- **Build Tool**: Gradle 8.14.2
- **Architecture**: Multimodule with Domain-Driven Design
- **Database**: H2 (Development), PostgreSQL (Production)

## 🤝 Contributing

Please read our [Development Guidelines](development/development-guidelines.md) before contributing to this project.

## 📞 Support

For questions or support, please contact the development team or create an issue in the project repository.

---

*Last updated: $(date)* 
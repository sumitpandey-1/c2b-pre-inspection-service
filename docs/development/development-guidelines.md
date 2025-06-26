# Development Guidelines

This document outlines the coding standards, best practices, and development workflows for the C2B Pre-Inspection Service project.

## Code Style and Standards

### Java Coding Standards

#### Naming Conventions
- **Classes**: PascalCase (e.g., `AssignmentService`, `LocationController`)
- **Methods**: camelCase (e.g., `createAssignment`, `findByInspectorId`)
- **Variables**: camelCase (e.g., `inspectorId`, `scheduledDate`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_ATTEMPTS`, `DEFAULT_TIMEOUT`)
- **Packages**: lowercase with dots (e.g., `com.cars24.c2b_pre_inspection_service`)

#### Class Structure
```java
// 1. Package declaration
package com.cars24.c2b_pre_inspection_service.assignment.internal;

// 2. Imports (grouped and sorted)
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.cars24.c2b_pre_inspection_service.core.exception.BusinessException;
import com.cars24.c2b_pre_inspection_service.shared.BaseEntity;

// 3. Class documentation
/**
 * Service class for managing assignment operations.
 * 
 * @author Development Team
 * @since 1.0.0
 */
// 4. Annotations
@Service
@Transactional
// 5. Class declaration
public class AssignmentService {
    
    // 6. Constants
    private static final int MAX_ASSIGNMENTS_PER_DAY = 10;
    
    // 7. Fields
    private final AssignmentRepository repository;
    private final LocationClient locationClient;
    
    // 8. Constructor
    public AssignmentService(AssignmentRepository repository, 
                           LocationClient locationClient) {
        this.repository = repository;
        this.locationClient = locationClient;
    }
    
    // 9. Public methods
    public AssignmentDto createAssignment(CreateAssignmentRequest request) {
        // Implementation
    }
    
    // 10. Private methods
    private void validateAssignment(CreateAssignmentRequest request) {
        // Implementation
    }
}
```

#### Method Guidelines
- **Single Responsibility**: Each method should have one clear purpose
- **Method Length**: Keep methods under 20-30 lines when possible
- **Parameter Count**: Limit to 3-4 parameters; use objects for more
- **Return Types**: Use specific types, avoid returning null when possible

```java
// Good
public Optional<Assignment> findAssignmentById(String id) {
    return repository.findById(id);
}

// Good
public List<Assignment> findAssignmentsByStatus(AssignmentStatus status) {
    return repository.findByStatus(status);
}

// Avoid
public Assignment getAssignment(String id) {
    return repository.findById(id).orElse(null); // Avoid returning null
}
```

### Documentation Standards

#### JavaDoc Requirements
- **All public classes and interfaces**: Must have class-level JavaDoc
- **All public methods**: Must have method-level JavaDoc
- **Complex private methods**: Should have documentation
- **Parameters and return values**: Document all parameters and return types

```java
/**
 * Creates a new assignment for an inspector.
 * 
 * @param request the assignment creation request containing inspector and appointment details
 * @return the created assignment with generated ID and timestamps
 * @throws ValidationException if the request data is invalid
 * @throws BusinessException if business rules are violated
 */
public AssignmentDto createAssignment(CreateAssignmentRequest request) {
    // Implementation
}
```

## Module Architecture Guidelines

### Package Structure
Each module should follow the client/internal pattern:

```
module-name/
├── src/main/java/com/cars24/c2b_pre_inspection_service/module/
│   ├── client/              # Public interfaces (exported)
│   │   ├── ModuleClient.java
│   │   └── dto/
│   └── internal/            # Private implementation
│       ├── service/
│       ├── repository/
│       ├── entity/
│       └── config/
```

### Client Interface Design
```java
/**
 * Public interface for assignment module operations.
 * This interface defines the contract for other modules to interact with assignments.
 */
public interface AssignmentClient {
    
    /**
     * Creates a new assignment.
     */
    AssignmentDto createAssignment(CreateAssignmentRequest request);
    
    /**
     * Finds assignments by inspector ID.
     */
    List<AssignmentDto> findAssignmentsByInspector(String inspectorId);
    
    /**
     * Updates assignment status.
     */
    void updateAssignmentStatus(String assignmentId, AssignmentStatus status);
}
```

### Dependency Rules
1. **Client packages** can depend on other module's client packages
2. **Internal packages** can depend on client packages but not other internal packages
3. **No circular dependencies** between modules
4. **Core module** can be used by all modules
5. **Shared-entity module** can be used by all modules

## Testing Guidelines

### Test Structure
Follow the AAA pattern (Arrange, Act, Assert):

```java
@Test
void createAssignment_WithValidData_ShouldReturnCreatedAssignment() {
    // Arrange
    CreateAssignmentRequest request = CreateAssignmentRequest.builder()
        .inspectorId("inspector-123")
        .appointmentId("appointment-456")
        .scheduledDate(LocalDateTime.now().plusDays(1))
        .build();
    
    // Act
    AssignmentDto result = assignmentService.createAssignment(request);
    
    // Assert
    assertThat(result).isNotNull();
    assertThat(result.getInspectorId()).isEqualTo("inspector-123");
    assertThat(result.getStatus()).isEqualTo(AssignmentStatus.ASSIGNED);
}
```

### Test Categories

#### Unit Tests
- **Scope**: Individual classes/methods
- **Dependencies**: Mock all external dependencies
- **Location**: Same package as tested class
- **Naming**: `ClassNameTest.java`

```java
@ExtendWith(MockitoExtension.class)
class AssignmentServiceTest {
    
    @Mock
    private AssignmentRepository repository;
    
    @Mock
    private LocationClient locationClient;
    
    @InjectMocks
    private AssignmentService assignmentService;
    
    @Test
    void testMethod() {
        // Test implementation
    }
}
```

#### Integration Tests
- **Scope**: Module interactions
- **Dependencies**: Use real implementations where possible
- **Location**: `src/test/java` with `IntegrationTest` suffix
- **Spring Context**: Use `@SpringBootTest` for full context

```java
@SpringBootTest
@TestPropertySource(properties = "spring.datasource.url=jdbc:h2:mem:testdb")
class AssignmentIntegrationTest {
    
    @Autowired
    private AssignmentService assignmentService;
    
    @Test
    void integrationTest() {
        // Test implementation
    }
}
```

### Test Coverage
- **Minimum Coverage**: 80% line coverage
- **Critical Paths**: 100% coverage for business logic
- **Generated Code**: Exclude from coverage requirements
- **Configuration Classes**: Basic smoke tests sufficient

## Error Handling

### Exception Hierarchy
```java
// Base exception for all business exceptions
public abstract class BusinessException extends RuntimeException {
    private final String errorCode;
    
    protected BusinessException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }
}

// Specific business exceptions
public class ValidationException extends BusinessException {
    public ValidationException(String message) {
        super("VALIDATION_ERROR", message);
    }
}

public class ResourceNotFoundException extends BusinessException {
    public ResourceNotFoundException(String resource, String id) {
        super("RESOURCE_NOT_FOUND", String.format("%s with id %s not found", resource, id));
    }
}
```

### Error Handling Best Practices
1. **Use specific exceptions** for different error scenarios
2. **Include context** in error messages
3. **Log errors** at appropriate levels
4. **Don't expose internal details** to clients
5. **Provide actionable error messages**

```java
public AssignmentDto createAssignment(CreateAssignmentRequest request) {
    try {
        validateRequest(request);
        
        Assignment assignment = mapToEntity(request);
        Assignment saved = repository.save(assignment);
        
        return mapToDto(saved);
        
    } catch (ValidationException e) {
        log.warn("Assignment creation failed due to validation: {}", e.getMessage());
        throw e;
    } catch (Exception e) {
        log.error("Unexpected error creating assignment", e);
        throw new BusinessException("ASSIGNMENT_CREATION_FAILED", 
            "Failed to create assignment due to internal error");
    }
}
```

## Database Guidelines

### Entity Design
```java
@Entity
@Table(name = "assignments")
public class Assignment extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    @Column(name = "inspector_id", nullable = false)
    private String inspectorId;
    
    @Column(name = "appointment_id", nullable = false)
    private String appointmentId;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private AssignmentStatus status;
    
    @Column(name = "scheduled_date", nullable = false)
    private LocalDateTime scheduledDate;
    
    // Constructors, getters, setters
}
```

### Repository Guidelines
```java
@Repository
public interface AssignmentRepository extends JpaRepository<Assignment, String> {
    
    List<Assignment> findByInspectorId(String inspectorId);
    
    List<Assignment> findByStatus(AssignmentStatus status);
    
    @Query("SELECT a FROM Assignment a WHERE a.scheduledDate BETWEEN :start AND :end")
    List<Assignment> findByScheduledDateBetween(
        @Param("start") LocalDateTime start, 
        @Param("end") LocalDateTime end);
}
```

## Security Guidelines

### Input Validation
```java
@Valid
public AssignmentDto createAssignment(@Valid @RequestBody CreateAssignmentRequest request) {
    // Spring will automatically validate the request
    return assignmentService.createAssignment(request);
}

// Request DTO with validation annotations
public class CreateAssignmentRequest {
    
    @NotBlank(message = "Inspector ID is required")
    private String inspectorId;
    
    @NotBlank(message = "Appointment ID is required")
    private String appointmentId;
    
    @Future(message = "Scheduled date must be in the future")
    private LocalDateTime scheduledDate;
}
```

### Authorization
```java
@PreAuthorize("hasRole('ADMIN') or hasRole('SUPERVISOR')")
public AssignmentDto createAssignment(CreateAssignmentRequest request) {
    // Only admins and supervisors can create assignments
}

@PreAuthorize("hasRole('INSPECTOR') and #inspectorId == authentication.name")
public List<AssignmentDto> getMyAssignments(String inspectorId) {
    // Inspectors can only view their own assignments
}
```

## Performance Guidelines

### Database Performance
1. **Use appropriate indexes** for frequently queried fields
2. **Avoid N+1 queries** with proper fetch strategies
3. **Use pagination** for large result sets
4. **Optimize queries** with @Query when needed

```java
// Good - uses pagination
public Page<Assignment> findAssignments(Pageable pageable) {
    return repository.findAll(pageable);
}

// Good - single query with join fetch
@Query("SELECT a FROM Assignment a JOIN FETCH a.inspector WHERE a.status = :status")
List<Assignment> findByStatusWithInspector(@Param("status") AssignmentStatus status);
```

### Caching Strategy
```java
@Service
public class AssignmentService {
    
    @Cacheable(value = "assignments", key = "#id")
    public AssignmentDto findById(String id) {
        return repository.findById(id)
            .map(this::mapToDto)
            .orElseThrow(() -> new ResourceNotFoundException("Assignment", id));
    }
    
    @CacheEvict(value = "assignments", key = "#result.id")
    public AssignmentDto updateAssignment(String id, UpdateAssignmentRequest request) {
        // Update logic
    }
}
```

## Git Workflow

### Branch Naming
- **Feature branches**: `feature/assignment-creation`
- **Bug fixes**: `bugfix/fix-assignment-validation`
- **Hotfixes**: `hotfix/security-patch`
- **Release branches**: `release/1.1.0`

### Commit Messages
Follow conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Examples:
```
feat(assignment): add assignment creation API
fix(pipeline): resolve stage progression issue
docs(api): update REST API documentation
test(assignment): add integration tests for assignment service
```

### Pull Request Guidelines
1. **Clear title** describing the change
2. **Detailed description** with context and reasoning
3. **Link to related issues** or tickets
4. **Include screenshots** for UI changes
5. **Ensure tests pass** before requesting review
6. **Keep PRs small** and focused on single feature/fix

## Code Review Process

### Review Checklist
- [ ] Code follows established patterns and conventions
- [ ] All tests pass and coverage is adequate
- [ ] Documentation is updated where necessary
- [ ] No security vulnerabilities introduced
- [ ] Performance impact is acceptable
- [ ] Error handling is appropriate
- [ ] Logging is adequate but not excessive

### Review Guidelines
1. **Be constructive** in feedback
2. **Explain the why** behind suggestions
3. **Suggest alternatives** when pointing out issues
4. **Approve when ready** - don't hold up for minor style issues
5. **Learn from reviews** - both giving and receiving

## Deployment Guidelines

### Environment Promotion
1. **Development**: Feature branches, frequent deployments
2. **Staging**: Release candidates, full integration testing
3. **Production**: Stable releases, careful rollout

### Configuration Management
- **Environment-specific properties** in separate files
- **Secrets management** through environment variables
- **Feature flags** for gradual rollouts
- **Database migrations** versioned and tested

## Monitoring and Logging

### Logging Standards
```java
@Slf4j
public class AssignmentService {
    
    public AssignmentDto createAssignment(CreateAssignmentRequest request) {
        log.info("Creating assignment for inspector: {}", request.getInspectorId());
        
        try {
            // Business logic
            log.debug("Assignment created successfully with ID: {}", result.getId());
            return result;
            
        } catch (Exception e) {
            log.error("Failed to create assignment for inspector: {}", 
                request.getInspectorId(), e);
            throw e;
        }
    }
}
```

### Metrics Collection
```java
@Component
public class AssignmentMetrics {
    
    private final Counter assignmentCreatedCounter;
    private final Timer assignmentCreationTimer;
    
    public AssignmentMetrics(MeterRegistry meterRegistry) {
        this.assignmentCreatedCounter = Counter.builder("assignments.created")
            .description("Number of assignments created")
            .register(meterRegistry);
            
        this.assignmentCreationTimer = Timer.builder("assignments.creation.time")
            .description("Time taken to create assignments")
            .register(meterRegistry);
    }
    
    public void recordAssignmentCreated() {
        assignmentCreatedCounter.increment();
    }
    
    public Timer.Sample startCreationTimer() {
        return Timer.start(assignmentCreationTimer);
    }
}
```

---

*These guidelines ensure consistent, maintainable, and high-quality code across the entire project.* 
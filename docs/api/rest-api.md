# REST API Reference

This document provides comprehensive documentation for the C2B Pre-Inspection Service REST API endpoints.

## Base URL

```
Development: http://localhost:8080
Production: https://api.c2b-pre-inspection.cars24.com
```

## Authentication

All API endpoints require authentication using JWT tokens.

### Authentication Header
```http
Authorization: Bearer <jwt-token>
```

### Getting Authentication Token
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
```

## Common Response Format

All API responses follow a consistent format:

### Success Response
```json
{
  "success": true,
  "data": {
    // Response data
  },
  "message": "Operation completed successfully",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Email format is invalid"
      }
    ]
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## Assignment API

### Get All Assignments
```http
GET /api/assignments
```

Query Parameters:
- `page` (optional): Page number (default: 0)
- `size` (optional): Page size (default: 20)
- `status` (optional): Filter by status
- `inspectorId` (optional): Filter by inspector ID

Response:
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "inspectorId": "inspector-123",
        "appointmentId": "appointment-456",
        "status": "ASSIGNED",
        "scheduledDate": "2024-01-20T09:00:00Z",
        "location": {
          "address": "123 Main St, City",
          "latitude": 12.9716,
          "longitude": 77.5946
        },
        "createdAt": "2024-01-15T10:30:00Z",
        "updatedAt": "2024-01-15T10:30:00Z"
      }
    ],
    "totalElements": 50,
    "totalPages": 3,
    "size": 20,
    "number": 0
  }
}
```

### Create Assignment
```http
POST /api/assignments
Content-Type: application/json

{
  "inspectorId": "inspector-123",
  "appointmentId": "appointment-456",
  "scheduledDate": "2024-01-20T09:00:00Z",
  "notes": "Special instructions for this assignment"
}
```

### Get Assignment by ID
```http
GET /api/assignments/{assignmentId}
```

### Update Assignment
```http
PUT /api/assignments/{assignmentId}
Content-Type: application/json

{
  "status": "IN_PROGRESS",
  "notes": "Updated notes"
}
```

### Delete Assignment
```http
DELETE /api/assignments/{assignmentId}
```

## Pipeline API

### Get All Pipelines
```http
GET /api/pipelines
```

Query Parameters:
- `page` (optional): Page number
- `size` (optional): Page size
- `status` (optional): Filter by status

### Create Pipeline
```http
POST /api/pipelines
Content-Type: application/json

{
  "name": "Standard Inspection Pipeline",
  "description": "Standard vehicle inspection workflow",
  "stages": [
    {
      "name": "Initial Assessment",
      "order": 1,
      "estimatedDuration": 30
    },
    {
      "name": "Detailed Inspection",
      "order": 2,
      "estimatedDuration": 60
    }
  ]
}
```

### Get Pipeline by ID
```http
GET /api/pipelines/{pipelineId}
```

### Update Pipeline Stage
```http
PUT /api/pipelines/{pipelineId}/stages/{stageId}
Content-Type: application/json

{
  "status": "COMPLETED",
  "notes": "Stage completed successfully",
  "completedAt": "2024-01-15T11:00:00Z"
}
```

## Attendance API

### Clock In
```http
POST /api/attendance/clock-in
Content-Type: application/json

{
  "inspectorId": "inspector-123",
  "location": {
    "latitude": 12.9716,
    "longitude": 77.5946
  },
  "notes": "Starting work day"
}
```

### Clock Out
```http
POST /api/attendance/clock-out
Content-Type: application/json

{
  "inspectorId": "inspector-123",
  "location": {
    "latitude": 12.9716,
    "longitude": 77.5946
  },
  "notes": "Ending work day"
}
```

### Get Attendance Records
```http
GET /api/attendance
```

Query Parameters:
- `inspectorId` (optional): Filter by inspector
- `date` (optional): Filter by date (YYYY-MM-DD)
- `startDate` (optional): Start date range
- `endDate` (optional): End date range

## Location API

### Search Locations
```http
GET /api/locations/search
```

Query Parameters:
- `query`: Search query
- `latitude` (optional): Current latitude
- `longitude` (optional): Current longitude
- `radius` (optional): Search radius in km

### Get Location by ID
```http
GET /api/locations/{locationId}
```

### Create Location
```http
POST /api/locations
Content-Type: application/json

{
  "name": "Service Center - Downtown",
  "address": "123 Main St, City, State 12345",
  "latitude": 12.9716,
  "longitude": 77.5946,
  "type": "SERVICE_CENTER",
  "contactInfo": {
    "phone": "+1-234-567-8900",
    "email": "downtown@example.com"
  }
}
```

### Calculate Distance
```http
POST /api/locations/distance
Content-Type: application/json

{
  "from": {
    "latitude": 12.9716,
    "longitude": 77.5946
  },
  "to": {
    "latitude": 12.9750,
    "longitude": 77.6000
  }
}
```

Response:
```json
{
  "success": true,
  "data": {
    "distance": 2.5,
    "unit": "km",
    "estimatedTime": 15,
    "timeUnit": "minutes"
  }
}
```

## Appointment API

### Get All Appointments
```http
GET /api/appointments
```

Query Parameters:
- `page` (optional): Page number
- `size` (optional): Page size
- `status` (optional): Filter by status
- `date` (optional): Filter by date
- `customerId` (optional): Filter by customer

### Create Appointment
```http
POST /api/appointments
Content-Type: application/json

{
  "customerId": "customer-123",
  "vehicleId": "vehicle-456",
  "appointmentType": "INSPECTION",
  "scheduledDate": "2024-01-20T10:00:00Z",
  "location": {
    "address": "Customer Address",
    "latitude": 12.9716,
    "longitude": 77.5946
  },
  "notes": "Special requirements"
}
```

### Get Appointment by ID
```http
GET /api/appointments/{appointmentId}
```

### Update Appointment Status
```http
PATCH /api/appointments/{appointmentId}/status
Content-Type: application/json

{
  "status": "CONFIRMED",
  "notes": "Appointment confirmed with customer"
}
```

### Cancel Appointment
```http
DELETE /api/appointments/{appointmentId}
```

### Reschedule Appointment
```http
PUT /api/appointments/{appointmentId}/reschedule
Content-Type: application/json

{
  "newScheduledDate": "2024-01-21T10:00:00Z",
  "reason": "Customer requested reschedule"
}
```

## Health Check API

### Application Health
```http
GET /actuator/health
```

Response:
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "H2",
        "validationQuery": "isValid()"
      }
    },
    "diskSpace": {
      "status": "UP",
      "details": {
        "total": 499963174912,
        "free": 91943821312,
        "threshold": 10485760,
        "exists": true
      }
    }
  }
}
```

### Application Info
```http
GET /actuator/info
```

### Application Metrics
```http
GET /actuator/metrics
```

## Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Request validation failed |
| `UNAUTHORIZED` | 401 | Authentication required |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource conflict |
| `INTERNAL_ERROR` | 500 | Internal server error |
| `SERVICE_UNAVAILABLE` | 503 | Service temporarily unavailable |

## Rate Limiting

API endpoints are rate limited to prevent abuse:

- **Standard endpoints**: 100 requests per minute per IP
- **Authentication endpoints**: 10 requests per minute per IP
- **Bulk operations**: 20 requests per minute per user

Rate limit headers are included in responses:
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642248000
```

## Pagination

List endpoints support pagination using query parameters:

- `page`: Page number (0-based, default: 0)
- `size`: Page size (default: 20, max: 100)
- `sort`: Sort criteria (e.g., `createdAt,desc`)

Example:
```http
GET /api/assignments?page=1&size=10&sort=createdAt,desc
```

## Filtering and Sorting

### Common Filter Parameters
- `status`: Filter by status
- `createdAt`: Filter by creation date
- `updatedAt`: Filter by update date

### Date Filtering
Use ISO 8601 format for date parameters:
- `startDate=2024-01-01T00:00:00Z`
- `endDate=2024-01-31T23:59:59Z`

### Sorting
Use the `sort` parameter with field name and direction:
- `sort=createdAt,desc`
- `sort=name,asc`
- `sort=status,asc&sort=createdAt,desc` (multiple sort criteria)

## API Versioning

The API uses URL path versioning:
- Current version: `/api/v1/`
- Future versions: `/api/v2/`, `/api/v3/`, etc.

## Content Types

### Supported Request Content Types
- `application/json`
- `multipart/form-data` (for file uploads)

### Supported Response Content Types
- `application/json`
- `application/xml` (on request with `Accept: application/xml`)

## CORS Policy

The API supports Cross-Origin Resource Sharing (CORS) for web applications:

- **Allowed Origins**: Configurable per environment
- **Allowed Methods**: GET, POST, PUT, PATCH, DELETE, OPTIONS
- **Allowed Headers**: Authorization, Content-Type, Accept
- **Max Age**: 3600 seconds

## WebSocket Endpoints (Future)

Real-time updates will be available via WebSocket:

```javascript
// Connect to WebSocket
const ws = new WebSocket('ws://localhost:8080/ws/updates');

// Subscribe to assignment updates
ws.send(JSON.stringify({
  type: 'SUBSCRIBE',
  topic: 'assignments',
  filters: { inspectorId: 'inspector-123' }
}));
```

---

*For more detailed API documentation, including request/response schemas, see the OpenAPI specification at `/api-docs`.* 
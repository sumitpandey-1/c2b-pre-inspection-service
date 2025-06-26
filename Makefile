# C2B Pre-Inspection Service Makefile
# Spring Boot 3.5.0 Multimodule Project

# Variables
PROJECT_NAME := c2b-pre-inspection-service
GRADLE_WRAPPER := ./gradlew
API_MODULE := api
MAIN_CLASS := com.cars24.c2b_pre_inspection_service.api.C2bPreInspectionServiceApplication
DEFAULT_PORT := 8080
H2_CONSOLE_PORT := 8080
JAVA_VERSION := 17

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[0;37m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# Help target
.PHONY: help
help: ## Show this help message
	@echo "$(CYAN)C2B Pre-Inspection Service - Spring Boot 3.5.0 Multimodule Project$(NC)"
	@echo "$(YELLOW)Available targets:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Setup and Installation
.PHONY: setup
setup: ## Initial project setup - check requirements and permissions
	@echo "$(BLUE)Setting up $(PROJECT_NAME)...$(NC)"
	@echo "$(YELLOW)Checking Java version...$(NC)"
	@java -version 2>&1 | head -1
	@echo "$(YELLOW)Checking Gradle wrapper permissions...$(NC)"
	@chmod +x $(GRADLE_WRAPPER)
	@echo "$(GREEN)✓ Setup complete!$(NC)"

.PHONY: install
install: setup clean build ## Full installation - setup, clean, and build
	@echo "$(GREEN)✓ Installation complete!$(NC)"

# Build targets
.PHONY: clean
clean: ## Clean all build artifacts
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@$(GRADLE_WRAPPER) clean
	@echo "$(GREEN)✓ Clean complete!$(NC)"

.PHONY: build
build: ## Build all modules
	@echo "$(YELLOW)Building all modules...$(NC)"
	@$(GRADLE_WRAPPER) build
	@echo "$(GREEN)✓ Build complete!$(NC)"

.PHONY: build-fast
build-fast: ## Fast build without tests
	@echo "$(YELLOW)Fast building (skipping tests)...$(NC)"
	@$(GRADLE_WRAPPER) build -x test
	@echo "$(GREEN)✓ Fast build complete!$(NC)"

.PHONY: compile
compile: ## Compile all modules without running tests
	@echo "$(YELLOW)Compiling all modules...$(NC)"
	@$(GRADLE_WRAPPER) compileJava
	@echo "$(GREEN)✓ Compilation complete!$(NC)"

# Test targets
.PHONY: test
test: ## Run all tests
	@echo "$(YELLOW)Running all tests...$(NC)"
	@$(GRADLE_WRAPPER) test
	@echo "$(GREEN)✓ All tests passed!$(NC)"

.PHONY: test-api
test-api: ## Run tests for API module only
	@echo "$(YELLOW)Running API module tests...$(NC)"
	@$(GRADLE_WRAPPER) :$(API_MODULE):test
	@echo "$(GREEN)✓ API tests passed!$(NC)"

.PHONY: test-report
test-report: test ## Generate test reports
	@echo "$(YELLOW)Test reports generated in:$(NC)"
	@find . -name "index.html" -path "*/test*" -exec echo "  {}" \;

# Run targets
.PHONY: run
run: ## Run the main application
	@echo "$(BLUE)Starting $(PROJECT_NAME) on port $(DEFAULT_PORT)...$(NC)"
	@echo "$(CYAN)Application will be available at: http://localhost:$(DEFAULT_PORT)$(NC)"
	@echo "$(CYAN)H2 Console available at: http://localhost:$(H2_CONSOLE_PORT)/h2-console$(NC)"
	@echo "$(YELLOW)Press Ctrl+C to stop the application$(NC)"
	@$(GRADLE_WRAPPER) :$(API_MODULE):bootRun

.PHONY: run-dev
run-dev: ## Run in development mode with debug logging
	@echo "$(BLUE)Starting $(PROJECT_NAME) in development mode...$(NC)"
	@SPRING_PROFILES_ACTIVE=dev $(GRADLE_WRAPPER) :$(API_MODULE):bootRun --args='--logging.level.com.cars24=DEBUG'

.PHONY: run-background
run-background: ## Run the application in background
	@echo "$(BLUE)Starting $(PROJECT_NAME) in background...$(NC)"
	@nohup $(GRADLE_WRAPPER) :$(API_MODULE):bootRun > application.log 2>&1 &
	@echo "$(GREEN)✓ Application started in background. Check application.log for logs.$(NC)"
	@echo "$(CYAN)Application available at: http://localhost:$(DEFAULT_PORT)$(NC)"

.PHONY: stop
stop: ## Stop the background application
	@echo "$(YELLOW)Stopping background application...$(NC)"
	@pkill -f "$(MAIN_CLASS)" || echo "$(RED)No running application found$(NC)"
	@echo "$(GREEN)✓ Application stopped$(NC)"

.PHONY: restart
restart: stop run ## Restart the application
	@echo "$(GREEN)✓ Application restarted$(NC)"

# Status and monitoring
.PHONY: status
status: ## Check application status
	@echo "$(YELLOW)Checking application status...$(NC)"
	@if pgrep -f "$(MAIN_CLASS)" > /dev/null; then \
		echo "$(GREEN)✓ Application is running$(NC)"; \
		echo "$(CYAN)  PID: $$(pgrep -f "$(MAIN_CLASS)")$(NC)"; \
		echo "$(CYAN)  URL: http://localhost:$(DEFAULT_PORT)$(NC)"; \
	else \
		echo "$(RED)✗ Application is not running$(NC)"; \
	fi

.PHONY: logs
logs: ## Show application logs (if running in background)
	@if [ -f application.log ]; then \
		echo "$(YELLOW)Showing application logs (last 50 lines):$(NC)"; \
		tail -50 application.log; \
	else \
		echo "$(RED)No log file found. Application might not be running in background.$(NC)"; \
	fi

.PHONY: logs-follow
logs-follow: ## Follow application logs in real-time
	@if [ -f application.log ]; then \
		echo "$(YELLOW)Following application logs (Press Ctrl+C to stop):$(NC)"; \
		tail -f application.log; \
	else \
		echo "$(RED)No log file found. Application might not be running in background.$(NC)"; \
	fi

# Development targets
.PHONY: deps
deps: ## Show dependency tree
	@echo "$(YELLOW)Showing dependency tree...$(NC)"
	@$(GRADLE_WRAPPER) dependencies

.PHONY: deps-api
deps-api: ## Show API module dependency tree
	@echo "$(YELLOW)Showing API module dependency tree...$(NC)"
	@$(GRADLE_WRAPPER) :$(API_MODULE):dependencies

.PHONY: modules
modules: ## List all project modules
	@echo "$(YELLOW)Project modules:$(NC)"
	@$(GRADLE_WRAPPER) projects

.PHONY: tasks
tasks: ## List all available Gradle tasks
	@echo "$(YELLOW)Available Gradle tasks:$(NC)"
	@$(GRADLE_WRAPPER) tasks

# Quality and analysis
.PHONY: check
check: ## Run all checks (build, test, quality)
	@echo "$(YELLOW)Running all checks...$(NC)"
	@$(GRADLE_WRAPPER) check
	@echo "$(GREEN)✓ All checks passed!$(NC)"

.PHONY: bootjar
bootjar: ## Create executable JAR file
	@echo "$(YELLOW)Creating executable JAR...$(NC)"
	@$(GRADLE_WRAPPER) :$(API_MODULE):bootJar
	@echo "$(GREEN)✓ Executable JAR created: $(API_MODULE)/build/libs/$(API_MODULE)-*.jar$(NC)"

.PHONY: run-jar
run-jar: bootjar ## Run the application from JAR file
	@echo "$(BLUE)Running application from JAR...$(NC)"
	@java -jar $(API_MODULE)/build/libs/$(API_MODULE)-*-SNAPSHOT.jar

# Database targets
.PHONY: db-console
db-console: ## Open H2 database console in browser
	@echo "$(CYAN)Opening H2 Console...$(NC)"
	@echo "$(YELLOW)URL: http://localhost:$(H2_CONSOLE_PORT)/h2-console$(NC)"
	@echo "$(YELLOW)JDBC URL: jdbc:h2:mem:testdb$(NC)"
	@echo "$(YELLOW)Username: sa$(NC)"
	@echo "$(YELLOW)Password: password$(NC)"
	@open http://localhost:$(H2_CONSOLE_PORT)/h2-console 2>/dev/null || echo "$(RED)Could not open browser automatically$(NC)"

# Utility targets
.PHONY: clean-logs
clean-logs: ## Clean log files
	@echo "$(YELLOW)Cleaning log files...$(NC)"
	@rm -f application.log
	@rm -f *.log
	@echo "$(GREEN)✓ Log files cleaned$(NC)"

.PHONY: clean-all
clean-all: clean clean-logs stop ## Clean everything (build artifacts, logs, stop app)
	@echo "$(GREEN)✓ Everything cleaned!$(NC)"

.PHONY: health
health: ## Check application health endpoint
	@echo "$(YELLOW)Checking application health...$(NC)"
	@curl -s http://localhost:$(DEFAULT_PORT)/actuator/health 2>/dev/null | jq . || \
	curl -s http://localhost:$(DEFAULT_PORT)/actuator/health 2>/dev/null || \
	echo "$(RED)Health endpoint not available. Is the application running?$(NC)"

.PHONY: info
info: ## Show project information
	@echo "$(CYAN)Project Information:$(NC)"
	@echo "  $(YELLOW)Name:$(NC) $(PROJECT_NAME)"
	@echo "  $(YELLOW)Spring Boot Version:$(NC) 3.5.0"
	@echo "  $(YELLOW)Java Version:$(NC) $(JAVA_VERSION)"
	@echo "  $(YELLOW)Main Class:$(NC) $(MAIN_CLASS)"
	@echo "  $(YELLOW)Default Port:$(NC) $(DEFAULT_PORT)"
	@echo "  $(YELLOW)Modules:$(NC)"
	@echo "    - api (Main Spring Boot Application)"
	@echo "    - assignment (Domain Module)"
	@echo "    - pipeline (Domain Module)"
	@echo "    - attendance (Domain Module)"
	@echo "    - location (Domain Module)"
	@echo "    - appointment (Domain Module)"
	@echo "    - core (Shared Utilities)"
	@echo "    - shared-entity (Common Entities)"

# Development workflow targets
.PHONY: dev-setup
dev-setup: setup build ## Complete development environment setup
	@echo "$(GREEN)✓ Development environment ready!$(NC)"
	@echo "$(CYAN)Quick start commands:$(NC)"
	@echo "  $(YELLOW)make run$(NC)        - Start the application"
	@echo "  $(YELLOW)make test$(NC)       - Run tests"
	@echo "  $(YELLOW)make status$(NC)     - Check if app is running"
	@echo "  $(YELLOW)make help$(NC)       - Show all available commands"

.PHONY: quick-start
quick-start: dev-setup run ## Quick start for new developers
	@echo "$(GREEN)✓ Application started! Welcome to $(PROJECT_NAME)$(NC)" 
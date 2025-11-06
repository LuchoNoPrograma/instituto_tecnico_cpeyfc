# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sistema de gestión académica del Instituto Técnico CPEyFC (Centro Psicopedagógico de Educación y Formación Continua). This Spring Boot application manages academic processes including study plans, enrollments, payments, and certificate issuance.

**Key Technologies:**
- **Backend:** Spring Boot 3.5.0 with Java 17
- **Frontend:** Vue 3 + Vuetify 3 + Vite (in `src/webapp/`)
- **Database:** PostgreSQL with JPA/Hibernate
- **Migrations:** Flyway for database schema management
- **Authentication:** JWT (Auth0 java-jwt) with Spring Security
- **Testing:** Testcontainers for integration tests
- **UI (Legacy):** Thymeleaf templates (minimal use, mostly for email templates)

## Development Commands

### Running the Application

**Backend (Spring Boot):**
```bash
# Run with dev profile (recommended for development)
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev

# Or run main class: uap.edu.bo.cpeyfc.CpeyfcApplication from IDE
```

Backend will be available at `http://localhost:8080` after Flyway migrations execute.

**Frontend (Vue 3):**
```bash
cd src/webapp

# Install dependencies (first time only)
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint
```

Frontend will be available at `http://localhost:3000`. The Vite dev server proxies `/api/*` requests to the backend at `http://localhost:8080`, so both servers must run simultaneously.

### Building

**Backend:**
```bash
# Clean and compile
./mvnw clean compile

# Package as JAR
./mvnw clean package

# Run packaged JAR with specific profile
java -Dspring.profiles.active=dev -jar ./target/cpeyfc-0.0.1-SNAPSHOT.jar

# Build Docker image
./mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=uap.edu.bo/cpeyfc
```

**Frontend:** See commands in "Running the Application" section above.

### Testing

```bash
# Run all tests (requires Docker for Testcontainers)
./mvnw test

# Run specific test class
./mvnw test -Dtest=RegistrationApiTest

# Run specific test method
./mvnw test -Dtest=RegistrationApiTest#testMethod
```

Integration tests extend `BaseIT` which provides a PostgreSQL container via Testcontainers with pre-configured test JWT tokens for different roles.

### Database

Database migrations are in `src/main/resources/db/migration/`. Flyway runs automatically on startup.

**Backup files** are stored in `src/main/resources/backups/` with naming pattern `dump-cpeyfc-YYYYMMDD_HHMMSS.backup`.

**Connection configuration:**
- Default URL: `jdbc:postgresql://localhost:5432/cpeyfc`
- Username: `postgres` in base config, `jheff` in dev profile (override with `JDBC_DATABASE_USERNAME`)
- Password: `admin123` in base config, `admin` in dev profile (override with `JDBC_DATABASE_PASSWORD`)
- Full URL override: `JDBC_DATABASE_URL`
- Backup path: Configurable via `config.ruta.backups` (default: `backups` in dev profile)

## Architecture

### Domain-Driven Structure

The codebase follows a **domain package structure** where each business entity lives in its own package under `src/main/java/uap/edu/bo/cpeyfc/domain/`. There are 36+ domain modules organized by functional area:

**Academic (aca_*):**
- `aca_area` - Academic areas
- `aca_nivel` - Academic levels
- `aca_modalidad` - Study modalities
- `aca_modulo` - Course modules
- `aca_plan_estudio` - Study plans
- `aca_programa` - Academic programs
- `aca_version` - Plan versions
- `aca_parametro_programa` - Program parameters
- `aca_programa_aprobado` - Approved programs

**Enrollment (ins_*):**
- `ins_preinscripcion` - Pre-enrollments
- `ins_matricula` - Student enrollments (matriculation)
- `ins_grupo` - Study groups

**Execution (eje_*):**
- `eje_docente` - Teaching staff
- `eje_programacion` - Course scheduling
- `eje_cronograma_modulo` - Module schedules
- `eje_calificacion` - Grades
- `eje_criterio_eval` - Evaluation criteria
- `eje_administrativo` - Administrative staff

**Finance (fin_*):**
- `fin_transaccion` - Financial transactions
- `fin_obligacion_pago` - Payment obligations
- `fin_detalle_pago` - Payment details
- `fin_concepto_pago` - Payment concepts

**Certificates (cer_*):**
- `cer_certificado` - Certificates
- `cer_titulacion` - Degree titles
- `cer_impresion` - Certificate printing

**Thesis (tgr_*):**
- `tgr_monografia` - Thesis documents
- `tgr_observacion_monografia` - Thesis observations
- `tgr_revision_monografia` - Thesis reviews

**Security (seg_*):**
- `seg_usuario` - Users
- `seg_rol` - Roles
- `seg_tarea` - Tasks/Permissions
- `seg_ocupa` - Role assignments
- `seg_designa` - Permission assignments

**Person (prs_*):**
- `prs_persona` - Person records

### Domain Module Pattern

Each domain module typically contains:
- **Entity** (`{Module}.java`) - JPA entity with `@FieldNameConstants` for type-safe field references
- **Repository** (`{Module}Repository.java`) - Spring Data JPA repository, may include custom query methods or stored procedure calls
- **Service** (`{Module}Service.java`) - Business logic
- **API** (`{Module}Api.java`) - REST controller (optional, for modules with API endpoints)

**Example:** The `aca_area` module contains:
- `AcaArea.java` - Entity
- `AcaAreaRepository.java` - Repository
- `AcaAreaService.java` - Service
- `AcaAreaApi.java` - REST controller

### Key Components

**RepositorioGenericoCrud** (`src/main/java/uap/edu/bo/cpeyfc/crud/RepositorioGenericoCrud.java`):
- Generic CRUD repository with type-safe field validation using `@FieldNameConstants`
- Provides pagination, filtering, and custom JPQL execution
- Use this for CRUD operations when custom repository methods aren't needed
- Example: `repositorio.buscarPorCampo(Usuario.class, Usuario.Fields.email, "test@email.com")`

**Auditoria** (`src/main/java/uap/edu/bo/cpeyfc/config/Auditoria.java`):
- Base class for entities with audit fields (userReg, fechaReg, userMod, fechaMod)
- All domain entities extend this class

**Database Functions:**
- Many complex operations use PostgreSQL functions defined in Flyway migrations
- Example: `InsMatriculaService.matricularPreinscrito()` calls `matricularPreinscritoCompleto()` stored procedure
- Function migrations are in files like `V12__crear_funciones_matriculas.sql`

**Authentication:**
- JWT-based with Spring Security
- `JwtRequestFilter` validates Bearer tokens from `Authorization` header
- JWT secret configured in `application.properties` as `securityConfig.secret`
- Roles: MATRICULADO, DOCENTE, ADMINISTRATIVO, DESARROLLO

### Configuration Files

**Application Profiles:**
- `application.properties` - Base configuration with minimal settings
- `application-dev.properties` - Development profile (recommended, includes detailed logging and debugging)
- `application-local.properties` - Local development overrides (not in repo, optional)
- Tests use `@ActiveProfiles("it")` with Testcontainers (no separate properties file needed)

**Entity Management:**
- `DomainConfig.java` - Enables JPA repositories and entity scanning for `uap.edu.bo.cpeyfc` package
- `@EnableJpaRepositories` and `@EntityScan` configured here

**Lombok:**
- Used extensively with `@Getter`, `@Setter`, `@RequiredArgsConstructor`, `@FieldNameConstants`
- IDE must have Lombok plugin installed and annotation processing enabled

### Frontend Architecture (Vue 3)

The frontend is a separate Vue 3 application located in `src/webapp/` with the following structure:

**Key Libraries:**
- **Vue 3** - Progressive JavaScript framework
- **Vuetify 3** - Material Design component framework (Google standard)
- **Vue Router** - Client-side routing
- **Pinia** - State management
- **Vuelidate** - Form validation
- **Axios** - HTTP client for API requests
- **AG Grid** - Advanced data tables
- **Chart.js** - Charts and visualizations
- **SweetAlert2** - Alerts and modals
- **ExcelJS** - Excel file export
- **jsPDF** - PDF generation

**Directory Structure:**
- `src/assets/` - Static resources (images, icons)
- `src/components/` - Reusable Vue components
- `src/layouts/` - Page layouts
- `src/pages/` - Application views/pages
- `src/plugins/` - Vue plugins (Vuetify, Router configuration)
- `src/router/` - Route definitions
- `src/stores/` - Pinia stores for global state
- `src/styles/` - Global SCSS styles
- `src/utils/` - Helper utilities and functions
- `vite.config.mjs` - Vite configuration with proxy to backend

**API Communication:**
- Frontend makes requests to `/api/*` endpoints
- Vite dev server proxies these to `http://localhost:8080` automatically
- No CORS configuration needed during development
- Backend must be running on port 8080 for frontend to function

## Important Patterns

### Enrollment Process (Matriculation)

The enrollment workflow is complex:
1. Pre-enrollment created (`ins_preinscripcion`)
2. User assigned to group (`ins_grupo`)
3. Matriculation executed via `InsMatriculaService.matricularPreinscrito()`
   - Calls database function `matricularPreinscritoCompleto()`
   - Creates or reuses user account (`seg_usuario`)
   - Generates temporary password if new user
   - Returns enrollment confirmation message

### Database Functions Over ORM

Many operations use PostgreSQL functions instead of JPA for:
- Complex multi-table transactions
- Business logic validation in database
- Performance optimization
- Data consistency guarantees

When modifying enrollment, grades, or payment logic, check the corresponding Flyway migration for database functions.

### Stored Procedure Return Values

Custom repository methods often return `Map<String, Object>` from database functions. Example pattern from `InsMatriculaRepository`:

```java
Map<String, Object> resultado = repository.matricularPreinscritoCompleto(...);
Boolean flag = (Boolean) resultado.get("campo_boolean");
String mensaje = (String) resultado.get("mensaje");
```

### Testing Strategy

Integration tests use:
- `@SpringBootTest` with `WebEnvironment.RANDOM_PORT`
- `@ActiveProfiles("it")` for test configuration
- `@Sql` annotations to load test data from `src/test/resources/data/`
- `BaseIT` abstract class provides:
  - Reusable PostgreSQL 17.5 container via Testcontainers
  - `@ServiceConnection` for automatic datasource configuration
  - Pre-injected repositories for all domain modules
  - `readResource()` helper method for loading test JSON files
  - Pre-configured test data via `clearAll.sql` and `segUsuarioData.sql`
- RestAssured for API testing
- Tests run against real PostgreSQL database in Docker container

## Notes

- When adding new entities, extend `Auditoria` for audit fields
- Add `@FieldNameConstants` to entities for type-safe field references with `RepositorioGenericoCrud`
- New database schema changes must go through Flyway migrations (versioned SQL files)
- API endpoints follow pattern `/api/{domain}/{action}` (e.g., `/api/area/vista/areas-activas`)
- Thymeleaf templates in `src/main/resources/templates/` are legacy; primary UI is Vue 3 frontend
- Both backend (port 8080) and frontend (port 3000) servers must run simultaneously during development
- Frontend development requires Node.js 18+ and npm

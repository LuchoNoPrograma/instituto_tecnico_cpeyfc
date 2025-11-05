# Instituto Técnico CPEyFP

## Descripción

Sistema web de gestión académica del Instituto Técnico CPEyFP (Centro de Proyectos Especiales y Formación Permanente). Esta aplicación gestiona integralmente los procesos administrativos y académicos de la institución, incluyendo:

- Gestión de planes de estudio y programas académicos
- Inscripciones y matriculación de estudiantes
- Administración de grupos y horarios
- Registro de calificaciones y evaluaciones
- Gestión financiera (pagos, obligaciones, transacciones)
- Emisión de certificados y títulos
- Seguimiento de trabajos de grado (monografías)
- Control de acceso basado en roles (estudiantes, docentes, administrativos)

## Tecnología

**Lenguaje Backend:** Java 17
**Framework Backend:** Spring Boot 3.5.0
**Framework Frontend:** Vue 3 + Vuetify 3
**Build Tool Frontend:** Vite
**Base de datos:** PostgreSQL

## Dependencias Principales

### Backend
- **Spring Boot Starter Web** - API REST y controladores MVC
- **Spring Boot Starter Data JPA** - Persistencia con Hibernate
- **Spring Boot Starter Security** - Seguridad y autenticación
- **Spring Boot Starter Thymeleaf** - Motor de plantillas HTML (solo para correos)
- **PostgreSQL Driver** - Conexión a base de datos
- **Flyway** - Migraciones automáticas de esquema SQL
- **Auth0 Java JWT** - Tokens de autenticación JWT
- **Lombok** - Reducción de código boilerplate

### Frontend (webapp/)
- **Vue 3** - Framework JavaScript progresivo
- **Vuetify 3** - Framework de componentes UI Material Design (Estandar de Google)
- **Vue Router** - Enrutamiento de aplicación
- **Vuelidate** - Validación de formularios
- **Pinia** - Estado global de aplicación
- **Axios** - Cliente HTTP para peticiones al backend
- **AG Grid** - Tablas de datos avanzadas
- **Chart.js** - Gráficos y visualizaciones
- **SweetAlert2** - Alertas y modales personalizados
- **ExcelJS** - Exportación de archivos Excel
- **jsPDF** - Generación de documentos PDF

### Base de Datos
- **PostgreSQL** - Sistema de gestión de base de datos relacional
- **Flyway** - Sistema de migración de base de datos que ejecuta scripts SQL ubicados en `src/main/resources/db/migration/`

## Requisitos Previos

### 1. Java Development Kit (JDK) 17 o superior

Verifica la instalación:
```bash
java -version
```

Instalación:
- **Ubuntu/Debian:**
  ```bash
  sudo apt update
  sudo apt install openjdk-17-jdk
  ```
- **Windows/macOS:** Descarga desde [Adoptium](https://adoptium.net/) o [Oracle](https://www.oracle.com/java/technologies/downloads/)

### 2. PostgreSQL 12 o superior

Verifica la instalación:
```bash
psql --version
```

Instalación:
- **Ubuntu/Debian:**
  ```bash
  sudo apt update
  sudo apt install postgresql postgresql-contrib
  sudo systemctl start postgresql
  sudo systemctl enable postgresql
  ```
- **Windows:** Descarga desde [postgresql.org](https://www.postgresql.org/download/windows/)
- **macOS:**
  ```bash
  brew install postgresql
  brew services start postgresql
  ```

### 3. Node.js y npm (versión 18 o superior)

El frontend (webapp) requiere Node.js y npm para ejecutarse.

Verifica la instalación:
```bash
node -v
npm -v
```

Instalación:
- **Ubuntu/Debian:**
  ```bash
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt install nodejs
  ```
- **Windows/macOS:** Descarga desde [nodejs.org](https://nodejs.org/)

### 4. Maven (incluido con Maven Wrapper)

El proyecto incluye Maven Wrapper (`mvnw`), no es necesario instalar Maven globalmente.

## Configuración para Desarrollo

### 1. Clonar el repositorio

```bash
git clone https://github.com/LuchoNoPrograma/instituto_tecnico_cpeyfc.git
cd instituto_tecnico_cpeyfc
```

### 2. Configurar la base de datos PostgreSQL

#### a) Crear la base de datos

Conéctate a PostgreSQL:
```bash
sudo -u postgres psql
```

Crea una base de datos y configura la application-dev.properties/application.properties con ruta a la base de datos

#### b) Verificar configuración

El proyecto está configurado con el perfil `dev` que usa las siguientes credenciales por defecto:
- **URL:** `jdbc:postgresql://localhost:5432/cpeyfc`
- **Usuario:** `postgres`
- **Contraseña:** `admin123`

Estas credenciales se encuentran en `src/main/resources/application-dev.properties`.

Si deseas usar diferentes credenciales, puedes modificar el archivo `application-dev.properties` o usar variables de entorno:

### 3. Configurar IDE (recomendado: IntelliJ IDEA)

Este proyecto usa **Lombok** para reducir código boilerplate. Debes configurar tu IDE correspondiente


### 4. Iniciar el Backend

El proyecto usa el perfil **`dev`** por defecto para desarrollo.

El perfil `dev` se carga automáticamente desde `application-dev.properties`.

#### Desde la IDE:

Ejecuta la clase principal: `uap.edu.bo.cpeyfc.CpeyfcApplication`

**Importante:** Al iniciar por primera vez, **Flyway ejecutará automáticamente las migraciones SQL** desde `src/main/resources/db/migration/` para crear el esquema de la base de datos.

#### Verificación:

Una vez iniciada la aplicación, verás en consola:
```
Started CpeyfcApplication in X.XXX seconds
```

El backend estará disponible en: **http://localhost:8080**

### 5. Iniciar el Frontend

El frontend es una aplicación Vue 3 separada ubicada en `src/webapp/`.

#### Instalar dependencias:

```bash
cd src/webapp
npm install
```

#### Iniciar servidor de desarrollo desde src/webapp:

```bash
npm run dev
```

El frontend estará disponible en: **http://localhost:3000**

#### Proxy de API:

El frontend está configurado con un proxy para redirigir las peticiones `/api/*` al backend en `http://localhost:8080`. No necesitas configurar CORS manualmente.

Cuando el frontend hace una petición a `/api/usuarios`, automáticamente se redirige a `http://localhost:8080/api/usuarios`.

## Acceso a la Aplicación

Una vez iniciados ambos servidores:

- **Frontend (interfaz de usuario):** http://localhost:3000
- **Backend (API REST):** http://localhost:8080

**Nota:** El frontend en el puerto 3000 se comunica automáticamente con el backend en el puerto 8080 mediante proxy configurado en `vite.config.mjs`.

No hay port forwarding adicional necesario. Ambos servidores deben estar ejecutándose simultáneamente.

## Comandos de Desarrollo

### Backend

```bash
# Limpiar y compilar
./mvnw clean compile

# Ejecutar aplicación
./mvnw spring-boot:run

# Limpiar build
./mvnw clean
```

### Frontend

```bash
cd src/webapp

# Instalar dependencias
npm install

# Iniciar desarrollo
npm run dev

# Build para producción
npm run build

# Vista previa del build
npm run preview

# Lint del código
npm run lint
```

## Estructura del Proyecto

```
instituto_tecnico_cpeyfc/
├── src/
│   ├── main/
│   │   ├── java/uap/edu/bo/cpeyfc/
│   │   │   ├── config/              # Configuraciones (Security, JPA, JWT, Lombok)
│   │   │   ├── domain/              # Módulos de dominio (36+ módulos)
│   │   │   │   ├── aca_*/          # Académico (áreas, niveles, programas, planes)
│   │   │   │   ├── ins_*/          # Inscripciones (matrículas, grupos, preinscripciones)
│   │   │   │   ├── eje_*/          # Ejecución (docentes, programaciones, calificaciones)
│   │   │   │   ├── fin_*/          # Finanzas (transacciones, pagos, obligaciones)
│   │   │   │   ├── cer_*/          # Certificados (títulos, impresiones)
│   │   │   │   ├── tgr_*/          # Trabajos de grado (monografías, revisiones)
│   │   │   │   ├── seg_*/          # Seguridad (usuarios, roles, tareas)
│   │   │   │   └── prs_*/          # Personas
│   │   │   ├── crud/               # Repositorio genérico CRUD
│   │   │   └── security/           # Servicios de autenticación JWT
│   │   └── resources/
│   │       ├── db/migration/       # Scripts Flyway (migraciones SQL)
│   │       ├── templates/          # Plantillas Thymeleaf (solo para correos)
│   │       ├── static/             # Recursos estáticos del backend
│   │       ├── application.properties         # Configuración base
│   │       └── application-dev.properties     # Configuración de desarrollo (perfil activo)
│   └── webapp/                      # FRONTEND - Aplicación Vue 3
│       ├── src/
│       │   ├── assets/             # Recursos estáticos (imágenes, iconos)
│       │   ├── components/         # Componentes Vue reutilizables
│       │   ├── layouts/            # Layouts de página
│       │   ├── pages/              # Vistas/páginas de la aplicación
│       │   ├── plugins/            # Plugins de Vue (Vuetify, Router, etc.)
│       │   ├── router/             # Configuración de rutas
│       │   ├── stores/             # Estado global con Pinia
│       │   ├── styles/             # Estilos globales SCSS
│       │   ├── utils/              # Utilidades y helpers
│       │   ├── App.vue             # Componente raíz
│       │   └── main.js             # Punto de entrada de la aplicación
│       ├── public/                 # Archivos públicos estáticos
│       ├── package.json            # Dependencias y scripts de npm
│       ├── vite.config.mjs         # Configuración de Vite (incluye proxy a backend)
│       └── index.html              # HTML base
├── pom.xml                          # Configuración de Maven
└── mvnw                             # Maven Wrapper
```

### Patrón de Módulos de Dominio (Backend)

Cada módulo de dominio sigue el patrón:
- **Entity** (`{Module}.java`) - Entidad JPA con anotaciones Lombok
- **Repository** (`{Module}Repository.java`) - Interfaz de persistencia Spring Data JPA
- **Service** (`{Module}Service.java`) - Lógica de negocio
- **Api** (`{Module}Api.java`) - Controlador REST (opcional)

**Ejemplo:** El módulo `aca_area` contiene:
- `AcaArea.java` - Entidad
- `AcaAreaRepository.java` - Repository
- `AcaAreaService.java` - Service
- `AcaAreaApi.java` - REST Controller

### Estructura del Frontend (webapp)

El frontend sigue la arquitectura estándar de Vue 3:
- **pages/** - Sistema de routing automático basado en archivos
- **components/** - Componentes reutilizables
- **stores/** - Manejo de estado con Pinia
- **layouts/** - Layouts compartidos entre páginas

## Perfiles de Aplicación

El proyecto utiliza el perfil **`dev`** por defecto para desarrollo:

- **dev** (`application-dev.properties`) - Perfil de desarrollo activo
  - Base de datos: PostgreSQL local
  - Logging: Nivel DEBUG para desarrollo
  - Flyway: Habilitado con migraciones automáticas
  - JWT Secret: Clave de desarrollo
  - Actuator: Todos los endpoints expuestos
  - Puerto: 8080

## Migraciones de Base de Datos

El proyecto usa **Flyway** para gestionar migraciones de base de datos. Al iniciar la aplicación por primera vez:

1. Flyway busca scripts SQL en `src/main/resources/db/migration/`
2. Ejecuta automáticamente las migraciones en orden (V1, V2, V3, etc.)
3. Crea el esquema completo de la base de datos
4. Registra las migraciones ejecutadas en la tabla `flyway_schema_history`

**Importante:** No modifiques los scripts de migración existentes. Para cambios en la base de datos, crea nuevos scripts con versión incremental.

## Notas Adicionales

- **Thymeleaf** está deprecado como motor principal de vistas y solo se usa para plantillas de correos electrónicos
- El frontend principal es una aplicación **Vue 3** en `src/webapp/`
- La comunicación entre frontend y backend se realiza mediante API REST
- El proxy de Vite redirige `/api/*` a `http://localhost:8080` automáticamente
- Ambos servidores (backend puerto 8080, frontend puerto 3000) deben estar ejecutándose

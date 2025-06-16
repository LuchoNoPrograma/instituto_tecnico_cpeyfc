# Instituto Técnico CPEyFC

Este repositorio aloja la aplicación web del Instituto Técnico CPEyFC, institución orientada a la formación profesional y a la educación continua. La solución gestiona diversos procesos internos como planes de estudio, inscripciones, pagos y emisión de certificados. Las entidades del dominio se ubican en `src/main/java/uap/edu/bo/cpeyfc/domain` donde pueden encontrarse módulos como **AcaArea**, **InsMatricula**, **FinTransaccion**, **SegUsuario** o **TgrMonografia**, entre otros.

## Tecnologías y dependencias principales

- **Spring Boot** con Java 17 como base de la aplicación.
- **Spring Web** y **Validation** para el manejo de peticiones HTTP y validación de datos.
- **Spring Security** junto con **JWT** (`com.auth0:java-jwt`) para autenticación.
- **Spring Data JPA** (Hibernate) con **PostgreSQL** como base de datos.
- **Flyway** para versionado y migración automática del esquema.
- **Thymeleaf** y su layout dialect para la capa de vistas.
- **Bootstrap** y **Htmx** (vía WebJars) para la interfaz de usuario.
- **Jakarta WebSocket API** para funcionalidades en tiempo real.
- **Lombok** para reducir código repetitivo.
- **Spring Boot Actuator** y **error-handling-spring-boot-starter** para monitorización y manejo de errores.
- **Dependencias de prueba**: `spring-boot-starter-test`, **Rest Assured** y **Testcontainers** con PostgreSQL.

## Guía de desarrollo

1. Clonar este repositorio.
2. Crear una base de datos PostgreSQL local y ajustar la conexión en `application.properties` o definir un `application-local.properties` con tus valores.
3. Asegurarse de que la IDE soporte Lombok (por ejemplo instalando el plugin en IntelliJ y habilitando *annotation processing*).
4. Ejecutar el proyecto con el perfil `local`:

   ```bash
   ./mvnw spring-boot:run -Dspring-boot.run.profiles=local
   ```

   Al iniciar se ejecutarán las migraciones de Flyway y la aplicación quedará disponible en `http://localhost:8080`.

## Ejecución de pruebas

- Se requiere Docker en el sistema para los tests de integración con Testcontainers.
- Ejecutar:

  ```bash
  ./mvnw test
  ```

  Las pruebas levantarán un contenedor PostgreSQL temporal para validar los repositorios y servicios.

## Build de la aplicación

1. Empaquetar el proyecto con Maven:

   ```bash
   ./mvnw clean package
   ```

2. Ejecutar el JAR generado (perfil `production` a modo de ejemplo):

   ```bash
   java -Dspring.profiles.active=production -jar ./target/cpeyfc-0.0.1-SNAPSHOT.jar
   ```

3. Opcionalmente es posible construir una imagen Docker utilizando el plugin de Spring Boot:

   ```bash
   ./mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=uap.edu.bo/cpeyfc
   ```

## Enlaces útiles

- [Documentación de Maven](https://maven.apache.org/guides/index.html)
- [Referencia de Spring Boot](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
- [Referencia de Spring Data JPA](https://docs.spring.io/spring-data/jpa/reference/jpa.html)
- [Documentación de Thymeleaf](https://www.thymeleaf.org/documentation.html)
- [Guía de Bootstrap](https://getbootstrap.com/docs/5.3/getting-started/introduction/)
- [Introducción a Htmx](https://htmx.org/docs/)
- [Libro "Taming Thymeleaf"](https://www.wimdeblauwe.com/books/taming-thymeleaf/)

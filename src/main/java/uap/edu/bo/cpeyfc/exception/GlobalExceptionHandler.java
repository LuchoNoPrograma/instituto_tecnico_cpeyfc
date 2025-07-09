// src/main/java/uap/edu/bo/cpeyfc/exception/GlobalExceptionHandler.java
package uap.edu.bo.cpeyfc.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.orm.jpa.JpaSystemException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

  /**
   * Maneja errores de tus funciones PostgreSQL (native queries)
   */
  @ExceptionHandler(JpaSystemException.class)
  public ResponseEntity<ErrorResponse> handleJpaSystemException(JpaSystemException ex) {

    String mensaje = extraerMensajePostgreSQL(ex.getMessage());

    log.error("Error de función PostgreSQL: {}", mensaje, ex);

    ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.CONFLICT.value())
            .error("Error de Base de Datos")
            .message(mensaje)
            .build();

    return new ResponseEntity<>(errorResponse, HttpStatus.CONFLICT);
  }

  /**
   * Maneja cualquier otra excepción
   */
  @ExceptionHandler(Exception.class)
  public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {

    log.error("Error interno del servidor", ex);
    ex.printStackTrace();

    ErrorResponse errorResponse = ErrorResponse.builder()
            .timestamp(LocalDateTime.now())
            .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
            .error("Error Interno")
            .message("Ha ocurrido un error interno. Contacta al administrador.")
            .build();

    return new ResponseEntity<>(errorResponse, HttpStatus.INTERNAL_SERVER_ERROR);
  }

  /**
   * Extrae el mensaje limpio de la función PostgreSQL
   */
  private String extraerMensajePostgreSQL(String mensajeCompleto) {
    if (mensajeCompleto == null) return "Error de base de datos";

    // Buscar el patrón: [ERROR: Error! MENSAJE]
    int inicioError = mensajeCompleto.indexOf("[ERROR: Error! ");
    if (inicioError != -1) {
      int inicioMensaje = inicioError + 15; // Después de "[ERROR: Error! "
      int finMensaje = mensajeCompleto.indexOf('\n', inicioMensaje);
      if (finMensaje == -1) {
        finMensaje = mensajeCompleto.indexOf(" Where:", inicioMensaje);
      }
      if (finMensaje == -1) {
        finMensaje = mensajeCompleto.indexOf(']', inicioMensaje);
      }

      if (finMensaje > inicioMensaje) {
        return mensajeCompleto.substring(inicioMensaje, finMensaje).trim();
      }
    }

    // Si no encuentra el patrón, buscar solo "ERROR: "
    int inicioErrorSimple = mensajeCompleto.indexOf("ERROR: ");
    if (inicioErrorSimple != -1) {
      int inicioMensaje = inicioErrorSimple + 7; // Después de "ERROR: "
      int finMensaje = mensajeCompleto.indexOf('\n', inicioMensaje);
      if (finMensaje == -1) {
        finMensaje = mensajeCompleto.indexOf(" Where:", inicioMensaje);
      }

      if (finMensaje > inicioMensaje) {
        return mensajeCompleto.substring(inicioMensaje, finMensaje).trim();
      }
    }

    return "Error en la operación de base de datos";
  }
}
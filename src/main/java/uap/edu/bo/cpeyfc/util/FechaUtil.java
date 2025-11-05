package uap.edu.bo.cpeyfc.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

public class FechaUtil {

  // Formatos que puede recibir del frontend
  private static final DateTimeFormatter[] DATE_FORMATTERS = {
    DateTimeFormatter.ISO_DATE_TIME,           // 2024-01-01T04:00:00.000Z
    DateTimeFormatter.ISO_ZONED_DATE_TIME,     // 2024-01-01T04:00:00.000-04:00
    DateTimeFormatter.ISO_LOCAL_DATE_TIME,     // 2024-01-01T04:00:00
    DateTimeFormatter.ISO_LOCAL_DATE,          // 2024-01-01
    DateTimeFormatter.ofPattern("yyyy-MM-dd")  // 2024-01-01
  };

  /**
   * Parsea una fecha flexible que puede venir en varios formatos
   */
  public static LocalDate toLocalDate(Object fecha) {
    if (fecha == null) {
      return null;
    }

    String fechaStr = fecha.toString().trim();

    if (fechaStr.isEmpty()) {
      return null;
    }

    // Intentar con cada formatter
    for (DateTimeFormatter formatter : DATE_FORMATTERS) {
      try {
        // Si viene con timestamp completo, extraer solo la fecha
        if (fechaStr.contains("T")) {
          ZonedDateTime zdt = ZonedDateTime.parse(fechaStr, DateTimeFormatter.ISO_DATE_TIME);
          return zdt.toLocalDate();
        }
        return LocalDate.parse(fechaStr, formatter);
      } catch (DateTimeParseException e) {
        // Intentar con el siguiente formato
        continue;
      }
    }

    throw new IllegalArgumentException("No se pudo parsear la fecha: " + fechaStr);
  }

  /**
   * Parsea LocalDateTime flexible
   */
  public static LocalDateTime toLocalDateTime(Object fecha) {
    if (fecha == null) {
      return null;
    }

    String fechaStr = fecha.toString().trim();

    if (fechaStr.isEmpty()) {
      return null;
    }

    try {
      if (fechaStr.endsWith("Z") || fechaStr.contains("+") || fechaStr.contains("-04:00")) {
        return ZonedDateTime.parse(fechaStr).toLocalDateTime();
      }
      return LocalDateTime.parse(fechaStr);
    } catch (DateTimeParseException e) {
      throw new IllegalArgumentException("No se pudo parsear la fecha/hora: " + fechaStr);
    }
  }
}
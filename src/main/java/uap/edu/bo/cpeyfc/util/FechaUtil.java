package uap.edu.bo.cpeyfc.util;

import java.sql.Date;
import java.time.LocalDate;
import java.time.OffsetDateTime;

public class FechaUtil {

  public static LocalDate toLocalDate(Object fecha) {
    if (fecha == null) return null;

    String fechaStr = fecha.toString();

    // ISO format con timezone (2025-06-01T04:00:00.000Z)
    if (fechaStr.contains("T")) {
      return OffsetDateTime.parse(fechaStr).toLocalDate();
    }

    // Simple date format (2025-06-01)
    if (fechaStr.length() >= 10) {
      return LocalDate.parse(fechaStr.substring(0, 10));
    }

    return LocalDate.parse(fechaStr);
  }

  public static Date toSqlDate(Object fecha) {
    LocalDate localDate = toLocalDate(fecha);
    return localDate != null ? Date.valueOf(localDate) : null;
  }
}
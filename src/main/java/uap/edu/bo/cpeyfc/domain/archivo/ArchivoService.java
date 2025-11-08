package uap.edu.bo.cpeyfc.domain.archivo;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Service
public class ArchivoService {

  private static final Path RUTA_BASE = Paths.get("src/main/resources/static");

  public String guardarArchivo(MultipartFile archivo, String carpeta) throws IOException {
    if (archivo == null || archivo.isEmpty()) {
      return null;
    }

    validarArchivo(archivo);

    Path directorioDestino = RUTA_BASE.resolve(carpeta);
    Files.createDirectories(directorioDestino);

    String nombreArchivo = generarNombreUnico(archivo.getOriginalFilename());
    Path archivoDestino = directorioDestino.resolve(nombreArchivo);

    Files.copy(archivo.getInputStream(), archivoDestino, StandardCopyOption.REPLACE_EXISTING);

    return "/" + carpeta + "/" + nombreArchivo;
  }

  public void eliminarArchivo(String rutaArchivo) {
    if (rutaArchivo == null || rutaArchivo.isEmpty()) return;

    try {
      Path archivo = RUTA_BASE.resolve(rutaArchivo.substring(1));
      Files.deleteIfExists(archivo);
    } catch (IOException e) {
      System.err.println("No se pudo eliminar el archivo: " + rutaArchivo);
    }
  }

  private void validarArchivo(MultipartFile archivo) {
    String contentType = archivo.getContentType();
    if (contentType == null || !contentType.startsWith("image/")) {
      throw new IllegalArgumentException("El archivo debe ser una imagen");
    }

    long tamañoMaximo = 10 * 1024 * 1024;
    if (archivo.getSize() > tamañoMaximo) {
      throw new IllegalArgumentException(
        String.format("Archivo demasiado grande (%.2f MB). Máximo: 10MB",
          archivo.getSize() / (1024.0 * 1024.0))
      );
    }
  }

  private String generarNombreUnico(String nombreOriginal) {
    String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
    String uuid = UUID.randomUUID().toString().substring(0, 8);
    String extension = obtenerExtension(nombreOriginal);
    return String.format("%s_%s%s", timestamp, uuid, extension);
  }

  private String obtenerExtension(String nombreArchivo) {
    if (nombreArchivo == null || !nombreArchivo.contains(".")) {
      return ".jpg";
    }
    return nombreArchivo.substring(nombreArchivo.lastIndexOf("."));
  }
}
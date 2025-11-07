package uap.edu.bo.cpeyfc.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

/**
 * Servicio para manejo de archivos subidos
 * Guarda archivos en el sistema de archivos local
 */
@Service
@Slf4j
public class FileStorageService {

  // Directorio base donde se almacenan todos los archivos
  private static final String BASE_UPLOAD_DIR = "src/main/resources/static";

  // Directorio específico para imágenes de noticias
  private static final String NEWS_IMAGES_DIR = "noticias";

  // Extensiones de imagen permitidas
  private static final List<String> ALLOWED_IMAGE_EXTENSIONS = Arrays.asList(
      "jpg", "jpeg", "png", "gif", "webp", "svg", "bmp"
  );

  // Tamaño máximo de archivo: 5MB
  private static final long MAX_FILE_SIZE = 5 * 1024 * 1024;

  /**
   * Guarda una imagen de noticia en el servidor
   *
   * @param file Archivo subido
   * @return Ruta relativa del archivo guardado (ej: /noticias/imagen_20250107_123456_abc123.jpg)
   * @throws IOException Si ocurre un error al guardar
   * @throws IllegalArgumentException Si el archivo no es válido
   */
  public String guardarImagenNoticia(MultipartFile file) throws IOException {
    // Validaciones
    validarArchivo(file);

    // Crear directorio si no existe
    Path uploadPath = crearDirectorioSiNoExiste(NEWS_IMAGES_DIR);

    // Generar nombre único para el archivo
    String nombreUnico = generarNombreUnico(file.getOriginalFilename());

    // Guardar archivo
    Path destinoArchivo = uploadPath.resolve(nombreUnico);
    Files.copy(file.getInputStream(), destinoArchivo, StandardCopyOption.REPLACE_EXISTING);

    log.info("Archivo guardado exitosamente: {}", destinoArchivo);

    // Retornar ruta relativa (accesible desde /noticias/nombre.jpg)
    return "/" + NEWS_IMAGES_DIR + "/" + nombreUnico;
  }

  /**
   * Elimina una imagen de noticia del servidor
   *
   * @param rutaRelativa Ruta relativa del archivo (ej: /noticias/imagen.jpg)
   * @return true si se eliminó, false si no existía
   */
  public boolean eliminarImagenNoticia(String rutaRelativa) {
    try {
      if (rutaRelativa == null || rutaRelativa.isEmpty()) {
        return false;
      }

      // Extraer nombre del archivo de la ruta relativa
      String nombreArchivo = rutaRelativa.substring(rutaRelativa.lastIndexOf("/") + 1);
      Path archivoPath = Paths.get(BASE_UPLOAD_DIR, NEWS_IMAGES_DIR, nombreArchivo);

      boolean eliminado = Files.deleteIfExists(archivoPath);

      if (eliminado) {
        log.info("Archivo eliminado exitosamente: {}", archivoPath);
      } else {
        log.warn("Archivo no encontrado para eliminar: {}", archivoPath);
      }

      return eliminado;

    } catch (IOException e) {
      log.error("Error al eliminar archivo: {}", rutaRelativa, e);
      return false;
    }
  }

  /**
   * Valida que el archivo sea una imagen válida
   */
  private void validarArchivo(MultipartFile file) {
    // Verificar que no esté vacío
    if (file == null || file.isEmpty()) {
      throw new IllegalArgumentException("El archivo está vacío");
    }

    // Verificar tamaño
    if (file.getSize() > MAX_FILE_SIZE) {
      throw new IllegalArgumentException(
          String.format("El archivo excede el tamaño máximo permitido de %d MB",
              MAX_FILE_SIZE / (1024 * 1024))
      );
    }

    // Verificar extensión
    String nombreOriginal = file.getOriginalFilename();
    if (nombreOriginal == null || !tieneExtensionValida(nombreOriginal)) {
      throw new IllegalArgumentException(
          "Formato de archivo no permitido. Permitidos: " + String.join(", ", ALLOWED_IMAGE_EXTENSIONS)
      );
    }

    // Verificar content type
    String contentType = file.getContentType();
    if (contentType == null || !contentType.startsWith("image/")) {
      throw new IllegalArgumentException("El archivo debe ser una imagen");
    }
  }

  /**
   * Verifica si el archivo tiene una extensión válida
   */
  private boolean tieneExtensionValida(String nombreArchivo) {
    String extension = obtenerExtension(nombreArchivo).toLowerCase();
    return ALLOWED_IMAGE_EXTENSIONS.contains(extension);
  }

  /**
   * Obtiene la extensión del archivo
   */
  private String obtenerExtension(String nombreArchivo) {
    int ultimoPunto = nombreArchivo.lastIndexOf('.');
    if (ultimoPunto == -1) {
      return "";
    }
    return nombreArchivo.substring(ultimoPunto + 1);
  }

  /**
   * Genera un nombre único para el archivo usando timestamp y UUID
   */
  private String generarNombreUnico(String nombreOriginal) {
    String extension = obtenerExtension(nombreOriginal);
    String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
    String uuid = UUID.randomUUID().toString().substring(0, 8);

    return String.format("noticia_%s_%s.%s", timestamp, uuid, extension);
  }

  /**
   * Crea el directorio de destino si no existe
   */
  private Path crearDirectorioSiNoExiste(String subdirectorio) throws IOException {
    Path uploadPath = Paths.get(BASE_UPLOAD_DIR, subdirectorio);

    if (!Files.exists(uploadPath)) {
      Files.createDirectories(uploadPath);
      log.info("Directorio creado: {}", uploadPath);
    }

    return uploadPath;
  }
}

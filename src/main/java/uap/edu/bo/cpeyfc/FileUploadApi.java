package uap.edu.bo.cpeyfc;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import uap.edu.bo.cpeyfc.util.FileStorageService;

import java.util.HashMap;
import java.util.Map;

/**
 * API: FileUploadApi
 * Descripción: Endpoints REST para subir archivos (imágenes, documentos, etc.)
 */
@RestController
@RequiredArgsConstructor
@Slf4j
public class FileUploadApi {

  private final FileStorageService fileStorageService;

  /**
   * POST /api/archivo/noticia/imagen
   * Sube una imagen para una noticia
   *
   * Request: multipart/form-data con campo 'file'
   *
   * Response:
   * {
   *   "success": true,
   *   "message": "Imagen subida exitosamente",
   *   "url": "/noticias/noticia_20250107_123456_abc123.jpg"
   * }
   *
   * @param file Archivo de imagen a subir
   * @return Respuesta con la URL del archivo guardado
   */
  @PostMapping("/api/archivo/noticia/imagen")
  public ResponseEntity<Map<String, Object>> subirImagenNoticia(
      @RequestParam("file") MultipartFile file) {

    try {
      log.info("Recibiendo archivo: {} - Tamaño: {} bytes - Tipo: {}",
          file.getOriginalFilename(), file.getSize(), file.getContentType());

      String rutaRelativa = fileStorageService.guardarImagenNoticia(file);

      Map<String, Object> response = new HashMap<>();
      response.put("success", true);
      response.put("message", "Imagen subida exitosamente");
      response.put("url", rutaRelativa);

      log.info("Imagen guardada exitosamente en: {}", rutaRelativa);

      return ResponseEntity.ok(response);

    } catch (IllegalArgumentException e) {
      log.warn("Validación de archivo fallida: {}", e.getMessage());

      Map<String, Object> errorResponse = new HashMap<>();
      errorResponse.put("success", false);
      errorResponse.put("message", e.getMessage());

      return ResponseEntity.badRequest().body(errorResponse);

    } catch (Exception e) {
      log.error("Error al subir archivo", e);

      Map<String, Object> errorResponse = new HashMap<>();
      errorResponse.put("success", false);
      errorResponse.put("message", "Error al guardar el archivo: " + e.getMessage());

      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
    }
  }

  /**
   * DELETE /api/archivo/noticia/imagen
   * Elimina una imagen de noticia del servidor
   *
   * Request body:
   * {
   *   "url": "/noticias/imagen.jpg"
   * }
   *
   * @param datos Datos con la URL de la imagen a eliminar
   * @return Respuesta con el resultado de la eliminación
   */
  @DeleteMapping("/api/archivo/noticia/imagen")
  public ResponseEntity<Map<String, Object>> eliminarImagenNoticia(
      @RequestBody Map<String, String> datos) {

    try {
      String url = datos.get("url");

      if (url == null || url.isEmpty()) {
        Map<String, Object> errorResponse = new HashMap<>();
        errorResponse.put("success", false);
        errorResponse.put("message", "La URL de la imagen es requerida");
        return ResponseEntity.badRequest().body(errorResponse);
      }

      boolean eliminado = fileStorageService.eliminarImagenNoticia(url);

      Map<String, Object> response = new HashMap<>();
      response.put("success", eliminado);
      response.put("message", eliminado
          ? "Imagen eliminada exitosamente"
          : "La imagen no existe o ya fue eliminada");

      return ResponseEntity.ok(response);

    } catch (Exception e) {
      log.error("Error al eliminar archivo", e);

      Map<String, Object> errorResponse = new HashMap<>();
      errorResponse.put("success", false);
      errorResponse.put("message", "Error al eliminar el archivo: " + e.getMessage());

      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
    }
  }
}

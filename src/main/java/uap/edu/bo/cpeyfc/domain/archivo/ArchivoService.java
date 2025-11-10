package uap.edu.bo.cpeyfc.domain.archivo;

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
import java.util.Base64;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class ArchivoService {

  @Value("${app.uploads.path}")
  private String uploadsPath;

  /**
   * Guarda un archivo en la carpeta especificada
   */
  public String guardarArchivo(MultipartFile archivo, String carpeta) throws IOException {
    if (archivo == null || archivo.isEmpty()) {
      return null;
    }

    validarArchivo(archivo);

    Path proyectoPath = Paths.get("").toAbsolutePath();
    Path directorioDestino = proyectoPath.resolve(uploadsPath).resolve(carpeta);

    Files.createDirectories(directorioDestino);

    String nombreArchivo = generarNombreUnico(archivo.getOriginalFilename());
    Path archivoDestino = directorioDestino.resolve(nombreArchivo);

    Files.copy(archivo.getInputStream(), archivoDestino, StandardCopyOption.REPLACE_EXISTING);

    return "/uploads/" + carpeta + "/" + nombreArchivo;
  }

  /**
   * Procesa imágenes base64 en HTML del editor WYSIWYG
   * Extrae las imágenes, las persiste y reemplaza con URLs permanentes
   *
   * @param contenidoHTML HTML con imágenes base64
   * @param carpetaDestino Carpeta donde guardar las imágenes
   * @return HTML con URLs permanentes
   */
  public String procesarImagenesBase64EnHTML(String contenidoHTML, String carpetaDestino) throws IOException {
    if (contenidoHTML == null || contenidoHTML.isEmpty()) {
      return contenidoHTML;
    }

    // Patrón para encontrar imágenes base64 en src="data:image/..."
    Pattern pattern = Pattern.compile(
      "<img[^>]+src=\"data:image/([^;]+);base64,([^\"]+)\"[^>]*>",
      Pattern.CASE_INSENSITIVE
    );

    Matcher matcher = pattern.matcher(contenidoHTML);
    StringBuffer resultado = new StringBuffer();

    int contador = 0;
    while (matcher.find()) {
      String formatoImagen = matcher.group(1); // jpeg, png, etc.
      String datosBase64 = matcher.group(2);

      try {
        // Decodificar base64
        byte[] imagenBytes = Base64.getDecoder().decode(datosBase64);

        // Generar nombre único
        String nombreArchivo = generarNombreUnicoEditor(formatoImagen, contador++);

        // Guardar imagen
        Path proyectoPath = Paths.get("").toAbsolutePath();
        Path directorioDestino = proyectoPath.resolve(uploadsPath).resolve(carpetaDestino);
        Files.createDirectories(directorioDestino);

        Path archivoDestino = directorioDestino.resolve(nombreArchivo);
        Files.write(archivoDestino, imagenBytes);

        // Construir URL permanente
        String urlPermanente = "/api/uploads/" + carpetaDestino + "/" + nombreArchivo;

        // Reemplazar en el HTML manteniendo atributos del img original
        String imgTagOriginal = matcher.group(0);
        String imgTagNuevo = imgTagOriginal.replaceFirst(
          "src=\"data:image/[^;]+;base64,[^\"]+\"",
          "src=\"" + urlPermanente + "\""
        );

        matcher.appendReplacement(resultado, Matcher.quoteReplacement(imgTagNuevo));

      } catch (Exception e) {
        System.err.println("Error procesando imagen base64: " + e.getMessage());
        // Dejar la imagen base64 original si hay error
        matcher.appendReplacement(resultado, Matcher.quoteReplacement(matcher.group(0)));
      }
    }

    matcher.appendTail(resultado);
    return resultado.toString();
  }

  public void eliminarArchivo(String rutaArchivo) {
    if (rutaArchivo == null || rutaArchivo.isEmpty()) return;

    try {
      // Remover el prefijo /uploads/
      String pathRelativo = rutaArchivo.startsWith("/uploads/")
        ? rutaArchivo.substring(9)
        : rutaArchivo;

      Path archivo = Paths.get(uploadsPath, pathRelativo);
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

  /**
   * Genera un nombre único con timestamp + UUID
   */
  private String generarNombreUnico(String nombreOriginal) {
    String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
    String uuid = UUID.randomUUID().toString().substring(0, 8);
    String extension = obtenerExtension(nombreOriginal);
    return String.format("%s_%s%s", timestamp, uuid, extension);
  }

  /**
   * Genera nombre único para imágenes del editor
   */
  private String generarNombreUnicoEditor(String formatoImagen, int contador) {
    String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
    String uuid = UUID.randomUUID().toString().substring(0, 6);
    String extension = "." + formatoImagen.toLowerCase();

    // Normalizar extensiones
    if (extension.equals(".jpeg")) extension = ".jpg";

    return String.format("editor_%s_%s_%03d%s", timestamp, uuid, contador, extension);
  }

  private String obtenerExtension(String nombreArchivo) {
    if (nombreArchivo == null || !nombreArchivo.contains(".")) {
      return ".jpg";
    }
    return nombreArchivo.substring(nombreArchivo.lastIndexOf("."));
  }
}
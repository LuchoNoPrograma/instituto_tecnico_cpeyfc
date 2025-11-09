package uap.edu.bo.cpeyfc.domain.pub_noticia;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;
import uap.edu.bo.cpeyfc.util.FechaUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class PubNoticiaApi {

  private final PubNoticiaService pubNoticiaService;
  private final ObjectMapper objectMapper;

  @GetMapping("/api/noticia/vista/noticias-activas")
  public ResponseEntity<List<Map<String, Object>>> vistaNoticiasActivas() {
    return ResponseEntity.ok(pubNoticiaService.vistaNoticiasActivas());
  }

  @GetMapping("/api/publico/noticia/carrusel")
  public ResponseEntity<List<Map<String, Object>>> vistaNoticiasCarrusel() {
    return ResponseEntity.ok(pubNoticiaService.vistaNoticiasCarrusel());
  }

  @GetMapping("/api/noticia")
  public ResponseEntity<Map<String, Object>> obtenerNoticiasPaginadas(
    @RequestParam(defaultValue = "1") Integer page,
    @RequestParam(defaultValue = "10") Integer size,
    @RequestParam(required = false) String busqueda,
    @RequestParam(required = false) String estado,
    @RequestParam(required = false) Integer id_unidad) {

    Map<String, Object> respuesta = pubNoticiaService.obtenerNoticiasPaginadas(
      page, size, busqueda, estado, id_unidad
    );

    return ResponseEntity.ok(respuesta);
  }


  @PostMapping("/api/noticia")
  public ResponseEntity<?> registrarNoticia(
    @RequestParam(value = "file", required = false) MultipartFile file,
    @RequestParam("datos") String datosJson,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    try {
      Map<String, Object> datos = objectMapper.readValue(datosJson, Map.class);

      Integer idNoticia = pubNoticiaService.registrarNoticia(
        file,
        (Integer) datos.get("id_aca_unidad"),
        (String) datos.get("titulo"),
        (String) datos.get("resumen"),
        (String) datos.get("enlace_externo"),
        FechaUtil.toLocalDate(datos.get("fecha_noticia")),
        (Boolean) datos.getOrDefault("es_destacada", false),
        (Integer) datos.getOrDefault("orden_prioridad", 0),
        userDetails.getIdSegUsuario()
      );

      return ResponseEntity.ok(Map.of(
        "success", true,
        "message", "Noticia registrada exitosamente",
        "id_pub_noticia", idNoticia
      ));
    } catch (Exception e) {
      return ResponseEntity.badRequest().body(Map.of(
        "success", false,
        "message", "Error al registrar noticia: " + e.getMessage()
      ));
    }
  }

  @PutMapping("/api/noticia/{id_pub_noticia}")
  public ResponseEntity<?> actualizarNoticia(
    @PathVariable Integer id_pub_noticia,
    @RequestParam(value = "file", required = false) MultipartFile file,
    @RequestParam("datos") String datosJson,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    try {
      Map<String, Object> datos = objectMapper.readValue(datosJson, Map.class);

      String resultado = pubNoticiaService.actualizarNoticia(
        file,
        id_pub_noticia,
        (Integer) datos.get("id_aca_unidad"),
        (String) datos.get("titulo"),
        (String) datos.get("resumen"),
        (String) datos.get("imagen_uri_antigua"),
        (String) datos.get("enlace_externo"),
        FechaUtil.toLocalDate(datos.get("fecha_noticia")),
        (Boolean) datos.getOrDefault("es_destacada", false),
        (Integer) datos.getOrDefault("orden_prioridad", 0),
        userDetails.getIdSegUsuario()
      );

      return ResponseEntity.ok(Map.of(
        "success", true,
        "message", resultado
      ));
    } catch (Exception e) {
      return ResponseEntity.badRequest().body(Map.of(
        "success", false,
        "message", "Error al actualizar noticia: " + e.getMessage()
      ));
    }
  }

  @PatchMapping("/api/noticia/{id_pub_noticia}/estado")
  public ResponseEntity<?> cambiarEstadoNoticia(
    @PathVariable Integer id_pub_noticia,
    @RequestBody Map<String, Object> datos,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    String resultado = pubNoticiaService.cambiarEstadoNoticia(
      id_pub_noticia,
      (String) datos.get("estado"),
      userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
      "success", true,
      "message", resultado
    ));
  }
}
package uap.edu.bo.cpeyfc.domain.pub_noticia;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;
import uap.edu.bo.cpeyfc.util.FechaUtil;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * API: PubNoticiaApi
 * Descripción: Endpoints REST para gestión de noticias institucionales del carrusel web
 */
@RestController
@RequiredArgsConstructor
public class PubNoticiaApi {

  private final PubNoticiaService pubNoticiaService;

  /**
   * GET /api/noticia/vista/noticias-activas
   * Obtiene listado completo de noticias activas para administración
   * Ordenadas por prioridad y fecha
   *
   * @return Lista de noticias activas con información completa
   */
  @GetMapping("/api/noticia/vista/noticias-activas")
  public ResponseEntity<List<Map<String, Object>>> vistaNoticiasActivas() {
    return ResponseEntity.ok(pubNoticiaService.vistaNoticiasActivas());
  }

  /**
   * GET /api/publico/noticia/carrusel
   * Obtiene las últimas 10 noticias para el carrusel web público
   * Endpoint público (sin autenticación requerida)
   *
   * @return Top 10 noticias destacadas para carrusel
   */
  @GetMapping("/api/publico/noticia/carrusel")
  public ResponseEntity<List<Map<String, Object>>> vistaNoticiasCarrusel() {
    return ResponseEntity.ok(pubNoticiaService.vistaNoticiasCarrusel());
  }

  /**
   * POST /api/noticia
   * Registra una nueva noticia institucional
   *
   * Request body:
   * {
   *   "id_aca_unidad": 1,
   *   "titulo": "Nueva noticia",
   *   "resumen": "Resumen de la noticia con al menos 20 caracteres",
   *   "imagen_uri": "/images/noticia.jpg",
   *   "enlace_externo": "https://example.com",
   *   "fecha_noticia": "2025-11-06",
   *   "es_destacada": true,
   *   "orden_prioridad": 10
   * }
   *
   * @param datos       Datos de la noticia
   * @param userDetails Usuario autenticado
   * @return ID de la noticia creada
   */
  @PostMapping("/api/noticia")
  public ResponseEntity<Map<String, Object>> registrarNoticia(
      @RequestBody HashMap<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    Integer idNoticia = pubNoticiaService.registrarNoticia(
        (Integer) datos.get("id_aca_unidad"),
        (String) datos.get("titulo"),
        (String) datos.get("resumen"),
        (String) datos.get("imagen_uri"),
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
  }

  /**
   * PUT /api/noticia/{id_pub_noticia}
   * Actualiza los datos de una noticia existente
   *
   * Request body:
   * {
   *   "id_aca_unidad": 1,
   *   "titulo": "Noticia actualizada",
   *   "resumen": "Resumen actualizado con al menos 20 caracteres",
   *   "imagen_uri": "/images/noticia-nueva.jpg",
   *   "enlace_externo": "https://example.com/actualizado",
   *   "fecha_noticia": "2025-11-07",
   *   "es_destacada": false,
   *   "orden_prioridad": 5
   * }
   *
   * @param idPubNoticia ID de la noticia a actualizar
   * @param datos        Datos actualizados
   * @param userDetails  Usuario autenticado
   * @return Mensaje de confirmación
   */
  @PutMapping("/api/noticia/{id_pub_noticia}")
  public ResponseEntity<String> actualizarNoticia(
      @PathVariable Integer id_pub_noticia,
      @RequestBody HashMap<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    String resultado = pubNoticiaService.actualizarNoticia(
        id_pub_noticia,
        (Integer) datos.get("id_aca_unidad"),
        (String) datos.get("titulo"),
        (String) datos.get("resumen"),
        (String) datos.get("imagen_uri"),
        (String) datos.get("enlace_externo"),
        FechaUtil.toLocalDate(datos.get("fecha_noticia")),
        (Boolean) datos.getOrDefault("es_destacada", false),
        (Integer) datos.getOrDefault("orden_prioridad", 0),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(resultado);
  }

  /**
   * PATCH /api/noticia/{id_pub_noticia}/estado
   * Cambia el estado de una noticia (ACTIVO/INACTIVO/ELIMINADO)
   *
   * Request body:
   * {
   *   "estado": "ACTIVO" | "INACTIVO" | "ELIMINADO"
   * }
   *
   * @param idPubNoticia ID de la noticia
   * @param datos        Nuevo estado
   * @param userDetails  Usuario autenticado
   * @return Mensaje de confirmación
   */
  @PatchMapping("/api/noticia/{id_pub_noticia}/estado")
  public ResponseEntity<String> cambiarEstadoNoticia(
      @PathVariable Integer id_pub_noticia,
      @RequestBody HashMap<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    String resultado = pubNoticiaService.cambiarEstadoNoticia(
        id_pub_noticia,
        (String) datos.get("estado"),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(resultado);
  }
}

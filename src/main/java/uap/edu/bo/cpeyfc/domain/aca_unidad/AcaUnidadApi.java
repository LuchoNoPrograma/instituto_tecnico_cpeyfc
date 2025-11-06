package uap.edu.bo.cpeyfc.domain.aca_unidad;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * API: AcaUnidadApi
 * Descripción: Endpoints REST para gestión de unidades académicas y administrativas
 */
@RestController
@RequiredArgsConstructor
public class AcaUnidadApi {

  private final AcaUnidadService acaUnidadService;

  /**
   * GET /api/unidad/vista/unidades-activas
   * Obtiene listado de unidades académicas activas con conteo de noticias
   *
   * @return Lista de unidades activas con estadísticas
   */
  @GetMapping("/api/unidad/vista/unidades-activas")
  public ResponseEntity<List<Map<String, Object>>> vistaUnidadesActivas() {
    return ResponseEntity.ok(acaUnidadService.vistaUnidadesActivas());
  }

  /**
   * POST /api/unidad
   * Registra una nueva unidad académica/administrativa
   *
   * Request body:
   * {
   *   "nombre_unidad": "Escuela Técnica",
   *   "descripcion": "Descripción opcional"
   * }
   *
   * @param datos       Datos de la unidad
   * @param userDetails Usuario autenticado
   * @return Mensaje de confirmación con ID generado
   */
  @PostMapping("/api/unidad")
  public ResponseEntity<String> registrarUnidad(
      @RequestBody HashMap<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    String resultado = acaUnidadService.registrarUnidad(
        (String) datos.get("nombre_unidad"),
        (String) datos.get("descripcion"),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(resultado);
  }
}

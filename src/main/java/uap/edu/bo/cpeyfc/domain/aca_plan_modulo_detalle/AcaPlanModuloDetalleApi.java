package uap.edu.bo.cpeyfc.domain.aca_plan_modulo_detalle;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AcaPlanModuloDetalleApi {
  private final AcaPlanModuloDetalleService acaPlanModuloDetalleService;
  private final AcaPlanModuloDetalleRepository acaPlanModuloDetalleRepository;

  @PostMapping("/api/plan-modulo-detalle")
  public ResponseEntity<?> registrarPlanModuloDetalle(@RequestBody Map<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = acaPlanModuloDetalleRepository.registrarPlanModuloDetalle(
      (Integer) datos.get("id_aca_plan_estudio"),
      (Integer) datos.get("id_aca_modulo"),
      (Integer) datos.get("id_aca_nivel"),
      (Integer) datos.get("carga_horaria"),
      new BigDecimal(datos.get("creditos").toString()),
      (Integer) datos.get("orden"),
      (String) datos.get("competencia"),
      userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(resultado);
  }

  @PutMapping("/api/plan-modulo-detalle")
  public ResponseEntity<?> modificarPlanModuloDetalle(@RequestBody Map<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = acaPlanModuloDetalleRepository.modificarPlanModuloDetalle(
      (Integer) datos.get("id_aca_plan_modulo_detalle"),
      (Integer) datos.get("id_aca_plan_estudio"),
      (Integer) datos.get("id_aca_modulo"),
      (Integer) datos.get("id_aca_nivel"),
      (Integer) datos.get("carga_horaria"),
      new BigDecimal(datos.get("creditos").toString()),
      (Integer) datos.get("orden"),
      (String) datos.get("competencia"),
      (String) datos.get("estado_plan_modulo_detalle"),
      userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(resultado);
  }

  @GetMapping("/api/plan-modulo-detalle/{id_aca_plan_estudio}/modulos")
  public ResponseEntity<?> consultarModulosPorPlan(@PathVariable Integer id_aca_plan_estudio) {
    return ResponseEntity.ok(acaPlanModuloDetalleRepository.consultarModulosPorPlan(id_aca_plan_estudio));
  }
}
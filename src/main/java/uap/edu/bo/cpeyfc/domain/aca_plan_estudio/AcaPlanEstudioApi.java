package uap.edu.bo.cpeyfc.domain.aca_plan_estudio;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.HashMap;

@RestController
@RequiredArgsConstructor
public class AcaPlanEstudioApi {
  private final AcaPlanEstudioService acaPlanEstudioService;
  private final AcaPlanEstudioRepository acaPlanEstudioRepository;

  @GetMapping("/api/plan-estudio/vista/planes_con_contexto")
  public ResponseEntity<?> vistaPlanesConContexto() {
    return ResponseEntity.ok(acaPlanEstudioRepository.vistaPlanEstudioConContexto());
  }

  @PostMapping("/api/plan-estudio")
  public ResponseEntity<String> registrarPlanEstudio(@RequestBody HashMap<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = acaPlanEstudioRepository.registrarPlanEstudio(
      (Integer) datos.get("anho"),
      (Boolean) datos.get("vigente"),
      userDetails.getIdSegUsuario()
    );
    return ResponseEntity.status(HttpStatus.CREATED).body(resultado);
  }

  @GetMapping("/api/plan-estudio/{id}")
  public ResponseEntity<?> vistaPlanEstudioDetalle(@PathVariable Integer id) {
    return ResponseEntity.ok(acaPlanEstudioRepository.vistaPlanEstudioDetalle(id));
  }

  @GetMapping("/api/plan-estudio/{id}/programas-asociados")
  public ResponseEntity<?> vistaProgramasAsociadosPlan(@PathVariable Integer id) {
    return ResponseEntity.ok(acaPlanEstudioRepository.vistaProgramasAsociadosPlan(id));
  }

  @GetMapping("/api/plan-estudio/{id}/modulos-detalle")
  public ResponseEntity<?> vistaModulosPlanDetalle(@PathVariable Integer id) {
    return ResponseEntity.ok(acaPlanEstudioRepository.vistaModulosPlanDetalle(id));
  }

  @GetMapping("/api/plan-estudio/{id}/estadisticas")
  public ResponseEntity<?> vistaPlanEstudioEstadisticas(@PathVariable Integer id) {
    return ResponseEntity.ok(acaPlanEstudioRepository.vistaPlanEstudioEstadisticas(id));
  }

  @GetMapping("/api/plan-estudio/vista/modulos-disponibles-nivel")
  public ResponseEntity<?> vistaModulosDisponiblesNivel() {
    return ResponseEntity.ok(acaPlanEstudioRepository.vistaModulosDisponiblesNivel());
  }
}
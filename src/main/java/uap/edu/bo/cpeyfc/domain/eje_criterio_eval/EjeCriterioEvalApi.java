package uap.edu.bo.cpeyfc.domain.eje_criterio_eval;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class EjeCriterioEvalApi {

  private final EjeCriterioEvalRepository ejeCriterioEvalRepository;

  @PostMapping("/api/criterio-evaluacion")
  public ResponseEntity<?> registrarCriterioEvaluacion(@RequestBody Map<String, Object> request, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    Integer resultado = ejeCriterioEvalRepository.registrarCriterioEvaluacion(
            (Integer) request.get("id_cronograma"),
            (String) request.get("nombre_crit"),
            (String) request.get("descripcion"),
            (Integer) request.get("ponderacion"),
            (Integer) request.get("orden"),
            userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(Map.of("id_criterio", resultado));
  }

  @PutMapping("/api/criterio-evaluacion/{idCriterio}")
  public ResponseEntity<?> modificarCriterioEvaluacion(@PathVariable Integer idCriterio,
                                                       @RequestBody Map<String, Object> request,
                                                       @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
                                                       ) {
    String resultado = ejeCriterioEvalRepository.modificarCriterioEvaluacion(
            idCriterio,
            (String) request.get("nombre_crit"),
            (String) request.get("descripcion"),
            (Integer) request.get("ponderacion"),
            (Integer) request.get("orden"),
            userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(Map.of("mensaje", resultado));
  }

  @DeleteMapping("/api/criterio-evaluacion/{idCriterio}")
  public ResponseEntity<?> eliminarCriterioEvaluacion(@PathVariable Integer idCriterio, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = ejeCriterioEvalRepository.eliminarCriterioEvaluacion(idCriterio, userDetails.getIdSegUsuario());
    return ResponseEntity.ok(Map.of("mensaje", resultado));
  }

  @GetMapping("/api/criterios/cronograma/{idCronograma}")
  public ResponseEntity<?> criteriosPorCronograma(@PathVariable Integer idCronograma) {
    return ResponseEntity.ok(ejeCriterioEvalRepository.criteriosPorCronograma(idCronograma));
  }
}
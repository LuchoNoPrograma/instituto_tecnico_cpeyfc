package uap.edu.bo.cpeyfc.domain.eje_calificacion;


import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class EjeCalificacionApi {
  private final EjeCalificacionRepository ejeCalificacionRepository;

  @PostMapping("/api/calificacion/registrar")
  public ResponseEntity<?> registrarCalificacion(@RequestBody Map<String, Object> datos,
                                                 @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    try {
      Integer idProgramacion = (Integer) datos.get("id_eje_programacion");
      Integer idCriterio = (Integer) datos.get("id_eje_criterio_eval");

      // Convertimos la nota correctamente a BigDecimal
      BigDecimal nota = new BigDecimal(datos.get("nota").toString());

      Integer resultado = ejeCalificacionRepository.registrarCalificacion(
              idProgramacion, idCriterio, nota, userDetails.getIdSegUsuario()
      );

      return ResponseEntity.ok(Map.of(
              "success", true,
              "message", "Calificación registrada exitosamente",
              "id_calificacion", resultado
      ));
    } catch (Exception e) {
      return ResponseEntity.badRequest().body(Map.of(
              "success", false,
              "message", e.getMessage()
      ));
    }
  }

  @GetMapping("/api/cronograma/{idCronograma}/calificaciones")
  public ResponseEntity<?> obtenerCalificacionesCronograma(@PathVariable Integer idCronograma) {
    return ResponseEntity.ok(ejeCalificacionRepository.obtenerCalificacionesCronograma(idCronograma));
  }

  @GetMapping("/api/cronograma/{idCronograma}/criterios")
  public ResponseEntity<?> obtenerCriteriosCronograma(@PathVariable Integer idCronograma) {
    return ResponseEntity.ok(ejeCalificacionRepository.obtenerCriteriosCronograma(idCronograma));
  }

  @GetMapping("/api/estudiante/{codMatricula}/programaciones")
  public ResponseEntity<?> obtenerProgramacionesEstudiante(@PathVariable Integer codMatricula) {
    return ResponseEntity.ok(ejeCalificacionRepository.obtenerProgramacionesEstudiante(codMatricula));
  }
}
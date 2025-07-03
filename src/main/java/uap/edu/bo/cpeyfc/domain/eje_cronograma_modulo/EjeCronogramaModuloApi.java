package uap.edu.bo.cpeyfc.domain.eje_cronograma_modulo;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;
import uap.edu.bo.cpeyfc.util.FechaUtil;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class EjeCronogramaModuloApi {
  private final EjeCronogramaModuloRepository ejeCronogramaModuloRepository;
  private final EjeCronogramaModuloService ejeCronogramaModuloService;

  @PutMapping("/api/cronograma-modulo")
  public ResponseEntity<?> modificarCronogramaModulo(@RequestBody Map<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = ejeCronogramaModuloService.modificarCronogramaModulo(
            (Integer) datos.get("id_eje_cronograma_modulo"),
            (Integer) datos.get("id_prs_persona"),
            FechaUtil.toLocalDate(datos.get("fecha_inicio")),
            FechaUtil.toLocalDate(datos.get("fecha_fin")),
            userDetails.getIdSegUsuario());
    return ResponseEntity.ok(resultado);
  }

  @GetMapping("/api/docente/cronogramas/{idUsuario}")
  public ResponseEntity<?> cronogramasPorUsuarioDocente(@PathVariable Integer idUsuario) {
    return ResponseEntity.ok(ejeCronogramaModuloRepository.vistaCronogramasPorIdUsuarioDocente(idUsuario));
  }

  @GetMapping("/api/cronograma/{idCronograma}/estudiantes")
  public ResponseEntity<?> estudiantesPorCronograma(@PathVariable Integer idCronograma) {
    return ResponseEntity.ok(ejeCronogramaModuloRepository.vistaEstudiantesPorIdCronograma(idCronograma));
  }
}

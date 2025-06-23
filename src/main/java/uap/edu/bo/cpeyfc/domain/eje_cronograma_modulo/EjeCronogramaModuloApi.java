package uap.edu.bo.cpeyfc.domain.eje_cronograma_modulo;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;
import uap.edu.bo.cpeyfc.util.FechaUtil;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class EjeCronogramaModuloApi {
  private final EjeCronogramaModuloRepository ejeCronogramaModuloRepository;

  @PutMapping("/api/cronograma-modulo")
  public ResponseEntity<?> modificarCronogramaModulo(@RequestBody Map<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = ejeCronogramaModuloRepository.modificarCronogramaModulo(
      (Integer) datos.get("id_eje_cronograma_modulo"),
      (Integer) datos.get("id_prs_persona"),
      FechaUtil.toLocalDate(datos.get("fecha_inicio")),
      FechaUtil.toLocalDate(datos.get("fecha_fin")),
      userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(resultado);
  }
}

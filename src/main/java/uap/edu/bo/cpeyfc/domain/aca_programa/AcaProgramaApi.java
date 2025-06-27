package uap.edu.bo.cpeyfc.domain.aca_programa;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AcaProgramaApi {
  private final AcaProgramaService acaProgramaService;
  private final AcaProgramaRepository acaProgramaRepository;

  @GetMapping("/api/programa/vista/programas-activos")
  public ResponseEntity<?> vistaProgramasActivos() {
    return ResponseEntity.ok(acaProgramaService.vistaProgramasActivos());
  }

  @PostMapping("/api/programa")
  public ResponseEntity<?> registrarPrograma(@RequestBody Map<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = acaProgramaRepository.registrarPrograma(
      (Integer) datos.get("id_aca_area"),
      (String) datos.get("nombre_programa"),
      (String) datos.get("sigla"),
      userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(resultado);
  }
}

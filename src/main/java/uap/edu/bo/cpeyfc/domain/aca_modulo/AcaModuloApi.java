package uap.edu.bo.cpeyfc.domain.aca_modulo;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AcaModuloApi {
  private final AcaModuloService acaModuloService;
  private final AcaModuloRepository acaModuloRepository;

  @GetMapping("/api/modulo/vista/modulos-activos")
  public ResponseEntity<?> vistaModulosActivos() {
    return ResponseEntity.ok(acaModuloRepository.vistaModulosActivos());
  }

  @PostMapping("/api/modulo")
  public ResponseEntity<?> registrarModulo(@RequestBody Map<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = acaModuloRepository.registrarModulo(
      (String) datos.get("nombre_modulo"),
      userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(resultado);
  }
}
package uap.edu.bo.cpeyfc.domain.prs_persona;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;
import uap.edu.bo.cpeyfc.util.FechaUtil;

import java.util.HashMap;

@RequiredArgsConstructor
@RestController
public class PrsPersonaApi {
  private final PrsPersonaService prsPersonaService;

  @GetMapping("/api/persona/vista/personas-activas")
  public ResponseEntity<?> vistaPersonasActivas(){
    return ResponseEntity.ok(prsPersonaService.vistaPersonasActivas());
  }

  @PostMapping("/api/persona")
  public ResponseEntity<String> registrarPersona(@RequestBody HashMap<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = prsPersonaService.registrarPersona(
      (String) datos.get("nombre"),
      (String) datos.get("ap_paterno"),
      (String) datos.get("ap_materno"),
      (String) datos.get("ci"),
      (String) datos.get("nro_celular"),
      (String) datos.get("correo"),
      FechaUtil.toLocalDate(datos.get("fecha_nacimiento")),
      userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(resultado);
  }

  @PutMapping("/api/persona/{id_prs_persona}")
  public ResponseEntity<String> modificarPersona(@PathVariable Integer id_prs_persona, @RequestBody HashMap<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = prsPersonaService.modificarPersona(
      id_prs_persona,
      (String) datos.get("nombre"),
      (String) datos.get("ap_paterno"),
      (String) datos.get("ap_materno"),
      (String) datos.get("ci"),
      (String) datos.get("nro_celular"),
      (String) datos.get("correo"),
      FechaUtil.toLocalDate(datos.get("fecha_nacimiento")),
      userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(resultado);
  }
}

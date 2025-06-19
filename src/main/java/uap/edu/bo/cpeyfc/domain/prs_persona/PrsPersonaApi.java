package uap.edu.bo.cpeyfc.domain.prs_persona;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RequiredArgsConstructor
@RestController
public class PrsPersonaApi {
  private final PrsPersonaService personaService;

  @GetMapping("/api/persona/vista/personas-activas")
  public ResponseEntity<?> vistaPersonasActivas(){
    return ResponseEntity.ok(personaService.vistaPersonasActivas());
  }
}

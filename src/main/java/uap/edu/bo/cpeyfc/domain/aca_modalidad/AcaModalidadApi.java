package uap.edu.bo.cpeyfc.domain.aca_modalidad;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AcaModalidadApi {
  private final AcaModalidadService acaModalidadService;

  @GetMapping("/api/modalidad/vista/modalidades-activas")
  public ResponseEntity<?> vistaModalidadesActivas() {
    return ResponseEntity.ok(acaModalidadService.vistaModalidadesActivas());
  }
}

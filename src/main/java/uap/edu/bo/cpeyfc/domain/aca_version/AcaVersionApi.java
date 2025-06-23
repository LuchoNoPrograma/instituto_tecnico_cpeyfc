package uap.edu.bo.cpeyfc.domain.aca_version;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AcaVersionApi {
  private final AcaVersionService acaVersionService;

  @GetMapping("/api/version/vista/versiones-activas")
  public ResponseEntity<?> vistaVersionesActivas() {
    return ResponseEntity.ok(acaVersionService.vistaVersionesActivas());
  }
}
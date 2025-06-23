package uap.edu.bo.cpeyfc.domain.aca_area;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AcaAreaApi {
  private final AcaAreaService acaAreaService;

  @GetMapping("/api/area/vista/areas-activas")
  public ResponseEntity<?> vistaAreasActivas() {
    return ResponseEntity.ok(acaAreaService.vistaAreasActivas());
  }
}

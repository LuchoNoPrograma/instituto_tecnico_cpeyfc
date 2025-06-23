package uap.edu.bo.cpeyfc.domain.aca_nivel;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AcaNivelApi {
  private final AcaNivelService acaNivelService;
  private final AcaNivelRepository acaNivelRepository;

  @GetMapping("/api/nivel/vista/niveles-activos")
  public ResponseEntity<?> vistaNivelesActivos() {
    return ResponseEntity.ok(acaNivelRepository.vistaNivelesActivos());
  }
}

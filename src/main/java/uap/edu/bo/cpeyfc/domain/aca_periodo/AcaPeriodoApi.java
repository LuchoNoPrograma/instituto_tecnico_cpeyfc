package uap.edu.bo.cpeyfc.domain.aca_periodo;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import uap.edu.bo.cpeyfc.service.VistasAcademicasService;

@RestController
@RequiredArgsConstructor
public class AcaPeriodoApi {

    private final AcaPeriodoService acaPeriodoService;
    private final AcaPeriodoRepository acaPeriodoRepository;
    private final VistasAcademicasService vistasAcademicasService;

    @GetMapping("/api/periodo/vista/periodo-actual")
    public ResponseEntity<?> obtenerPeriodoActual() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerPeriodoActual());
    }

}

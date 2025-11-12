package uap.edu.bo.cpeyfc.domain.aca_gestion;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import uap.edu.bo.cpeyfc.domain.aca_periodo.AcaPeriodoService;

@RestController
@RequiredArgsConstructor
public class AcaGestionApi {

    private final AcaGestionService acaGestionService;
    private final AcaGestionRepository acaGestionRepository;
    private final AcaPeriodoService acaPeriodoService;

    @GetMapping("/api/gestion/vista/gestiones-periodos")
    public ResponseEntity<?> obtenerGestionesPeriodos() {
        return ResponseEntity.ok(acaPeriodoService.obtenerGestionesPeriodos());
    }

}

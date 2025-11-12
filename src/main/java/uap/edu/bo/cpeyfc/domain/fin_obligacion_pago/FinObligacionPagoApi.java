package uap.edu.bo.cpeyfc.domain.fin_obligacion_pago;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import uap.edu.bo.cpeyfc.service.VistasAcademicasService;

@RestController
@RequiredArgsConstructor
public class FinObligacionPagoApi {

    private final FinObligacionPagoService finObligacionPagoService;
    private final FinObligacionPagoRepository finObligacionPagoRepository;
    private final VistasAcademicasService vistasAcademicasService;

    @GetMapping("/api/obligacion-pago/vista/estado-cuenta/ci/{ci}")
    public ResponseEntity<?> obtenerEstadoCuentaPorCi(@PathVariable String ci) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerEstadoCuentaPorCi(ci));
    }

}

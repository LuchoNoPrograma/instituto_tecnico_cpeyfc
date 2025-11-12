package uap.edu.bo.cpeyfc.domain.fin_convenio;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class FinConvenioApi {

    private final FinConvenioService finConvenioService;

    @GetMapping("/api/convenio/vista/convenios-colegios")
    public ResponseEntity<?> obtenerConveniosColegios() {
        return ResponseEntity.ok(finConvenioService.obtenerConveniosColegios());
    }

    @GetMapping("/api/convenio/vista/convenios-vigentes")
    public ResponseEntity<?> obtenerConveniosVigentes() {
        return ResponseEntity.ok(finConvenioService.obtenerConveniosVigentes());
    }

}

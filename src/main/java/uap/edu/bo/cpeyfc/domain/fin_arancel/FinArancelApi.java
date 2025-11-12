package uap.edu.bo.cpeyfc.domain.fin_arancel;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import uap.edu.bo.cpeyfc.service.FuncionesAcademicasService;
import uap.edu.bo.cpeyfc.service.VistasAcademicasService;

@RestController
@RequiredArgsConstructor
public class FinArancelApi {

    private final FinArancelService finArancelService;
    private final FinArancelRepository finArancelRepository;
    private final VistasAcademicasService vistasAcademicasService;
    private final FuncionesAcademicasService funcionesAcademicasService;

    @GetMapping("/api/arancel/vista/aranceles-vigentes")
    public ResponseEntity<?> obtenerArancelesVigentes() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerArancelesVigentes());
    }

    @GetMapping("/api/arancel/vista/aranceles-programa/{nombrePrograma}")
    public ResponseEntity<?> obtenerArancelesPorPrograma(@PathVariable String nombrePrograma) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerArancelesPorPrograma(nombrePrograma));
    }

    @GetMapping("/api/arancel/calcular-monto-matricula")
    public ResponseEntity<?> calcularMontoMatricula(
        @RequestParam Integer idProgramaAprobado,
        @RequestParam Integer idTipoEstudiante,
        @RequestParam Integer numeroPeriodo,
        @RequestParam(required = false) Integer idConvenio
    ) {
        return ResponseEntity.ok(funcionesAcademicasService.calcularMontoMatricula(
            idProgramaAprobado,
            idTipoEstudiante,
            numeroPeriodo,
            idConvenio
        ));
    }

}

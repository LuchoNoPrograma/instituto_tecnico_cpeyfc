package uap.edu.bo.cpeyfc.domain.fin_arancel;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.service.FuncionesAcademicasService;
import uap.edu.bo.cpeyfc.service.VistasAcademicasService;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class FinArancelApi {

    private final FinArancelService finArancelService;
    private final FinArancelRepository finArancelRepository;
    private final VistasAcademicasService vistasAcademicasService;
    private final FuncionesAcademicasService funcionesAcademicasService;

    // === VISTAS DE ARANCELES ===

    @GetMapping("/api/arancel/vista/aranceles-vigentes")
    public ResponseEntity<?> obtenerArancelesVigentes() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerArancelesVigentes());
    }

    @GetMapping("/api/arancel/vista/aranceles-programa/{nombrePrograma}")
    public ResponseEntity<?> obtenerArancelesPorPrograma(@PathVariable String nombrePrograma) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerArancelesPorPrograma(nombrePrograma));
    }

    @GetMapping("/api/arancel/vista/aranceles-detalle")
    public ResponseEntity<?> obtenerArancelesPrograma() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerArancelesPrograma());
    }

    @GetMapping("/api/arancel/vista/aranceles-detalle/{idProgramaAprobado}")
    public ResponseEntity<?> obtenerArancelesDetallePorPrograma(@PathVariable Integer idProgramaAprobado) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerArancelesDetallePorPrograma(idProgramaAprobado));
    }

    // === FUNCIONES DE ARANCELES ===

    @PostMapping("/api/arancel/registrar")
    public ResponseEntity<?> registrarArancel(@RequestBody Map<String, Object> request) {
        return ResponseEntity.ok(funcionesAcademicasService.registrarArancel(
            (Integer) request.get("idProgramaAprobado"),
            (Integer) request.get("idGestion"),
            (Integer) request.get("idTipoEstudiante"),
            (String) request.get("nombreArancel"),
            (String) request.get("descripcion"),
            (String) request.get("fechaInicioVigencia"),
            (String) request.get("fechaFinVigencia"),
            (String) request.get("detalles"), // JSON string
            (String) request.get("userReg")
        ));
    }

    @GetMapping("/api/arancel/conceptos")
    public ResponseEntity<?> obtenerConceptosArancel(
        @RequestParam Integer idProgramaAprobado,
        @RequestParam Integer idTipoEstudiante,
        @RequestParam Integer numeroPeriodo,
        @RequestParam(required = false) Integer idConvenio
    ) {
        return ResponseEntity.ok(funcionesAcademicasService.obtenerConceptosArancel(
            idProgramaAprobado,
            idTipoEstudiante,
            numeroPeriodo,
            idConvenio
        ));
    }

    /**
     * @deprecated Usar /api/arancel/conceptos en su lugar. Este endpoint usa el sistema legacy de precios directos.
     */
    @Deprecated
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

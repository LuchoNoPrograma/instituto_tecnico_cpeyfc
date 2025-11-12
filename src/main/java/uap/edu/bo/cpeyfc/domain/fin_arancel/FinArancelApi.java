package uap.edu.bo.cpeyfc.domain.fin_arancel;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class FinArancelApi {

    private final FinArancelService finArancelService;

    // === VISTAS DE ARANCELES ===

    @GetMapping("/api/arancel/vista/aranceles-vigentes")
    public ResponseEntity<?> obtenerArancelesVigentes() {
        return ResponseEntity.ok(finArancelService.obtenerArancelesVigentes());
    }

    @GetMapping("/api/arancel/vista/aranceles-programa/{nombrePrograma}")
    public ResponseEntity<?> obtenerArancelesPorPrograma(@PathVariable String nombrePrograma) {
        return ResponseEntity.ok(finArancelService.obtenerArancelesPorPrograma(nombrePrograma));
    }

    @GetMapping("/api/arancel/vista/aranceles-detalle")
    public ResponseEntity<?> obtenerArancelesDetalle() {
        return ResponseEntity.ok(finArancelService.obtenerArancelesDetalle());
    }

    @GetMapping("/api/arancel/vista/aranceles-detalle/{idProgramaAprobado}")
    public ResponseEntity<?> obtenerArancelesDetallePorPrograma(@PathVariable Integer idProgramaAprobado) {
        return ResponseEntity.ok(finArancelService.obtenerArancelesDetallePorPrograma(idProgramaAprobado));
    }

    // === FUNCIONES DE ARANCELES ===

    @PostMapping("/api/arancel/registrar")
    public ResponseEntity<?> registrarArancel(@RequestBody Map<String, Object> request) {
        return ResponseEntity.ok(finArancelService.registrarArancel(
            (Integer) request.get("idProgramaAprobado"),
            (Integer) request.get("idPeriodo"),
            (Integer) request.get("idTipoEstudiante"),
            (String) request.get("nombreArancel"),
            (String) request.get("nroResolucion"),
            (String) request.get("fechaAprobacion"),
            (String) request.get("fechaInicioVigencia"),
            (String) request.get("fechaFinVigencia"),
            (String) request.get("detalles"), // JSON string [{id_fin_concepto_arancel, monto_concepto, orden_aplicacion}]
            (Integer) request.get("userReg")
        ));
    }

    @GetMapping("/api/arancel/conceptos")
    public ResponseEntity<?> obtenerConceptosArancel(
        @RequestParam Integer idProgramaAprobado,
        @RequestParam Integer idTipoEstudiante,
        @RequestParam Integer numeroPeriodo,
        @RequestParam(required = false) Integer idConvenio
    ) {
        return ResponseEntity.ok(finArancelService.obtenerConceptosArancel(
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
        return ResponseEntity.ok(finArancelService.calcularMontoMatricula(
            idProgramaAprobado,
            idTipoEstudiante,
            numeroPeriodo,
            idConvenio
        ));
    }

}

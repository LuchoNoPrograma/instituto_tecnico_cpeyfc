package uap.edu.bo.cpeyfc.api;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import uap.edu.bo.cpeyfc.service.FuncionesAcademicasService;

@RestController
@RequiredArgsConstructor
public class FuncionesAcademicasApi {

    private final FuncionesAcademicasService funcionesAcademicasService;

    @GetMapping("/api/funcion/calcular-monto-matricula")
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

    @GetMapping("/api/funcion/validar-emision-certificado")
    public ResponseEntity<?> validarEmisionCertificado(
        @RequestParam Integer idPersona,
        @RequestParam Integer idCertificacionPrograma
    ) {
        return ResponseEntity.ok(funcionesAcademicasService.validarEmisionCertificado(
            idPersona,
            idCertificacionPrograma
        ));
    }

}

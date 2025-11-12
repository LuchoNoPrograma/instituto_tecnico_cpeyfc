package uap.edu.bo.cpeyfc.domain.aca_certificado_emitido;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import uap.edu.bo.cpeyfc.domain.aca_certificacion_programa.AcaCertificacionProgramaService;

@RestController
@RequiredArgsConstructor
public class AcaCertificadoEmitidoApi {

    private final AcaCertificadoEmitidoService acaCertificadoEmitidoService;
    private final AcaCertificadoEmitidoRepository acaCertificadoEmitidoRepository;
    private final AcaCertificacionProgramaService acaCertificacionProgramaService;

    @GetMapping("/api/certificado-emitido/validar-emision")
    public ResponseEntity<?> validarEmisionCertificado(
        @RequestParam Integer idPersona,
        @RequestParam Integer idCertificacionPrograma
    ) {
        return ResponseEntity.ok(acaCertificacionProgramaService.validarEmisionCertificado(
            idPersona,
            idCertificacionPrograma
        ));
    }

}

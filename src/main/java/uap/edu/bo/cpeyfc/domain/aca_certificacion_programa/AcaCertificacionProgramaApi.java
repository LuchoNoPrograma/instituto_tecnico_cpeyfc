package uap.edu.bo.cpeyfc.domain.aca_certificacion_programa;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class AcaCertificacionProgramaApi {

    private final AcaCertificacionProgramaService acaCertificacionProgramaService;

    @GetMapping("/api/certificacion-programa/vista/certificaciones-programa")
    public ResponseEntity<?> obtenerCertificacionesPrograma() {
        return ResponseEntity.ok(acaCertificacionProgramaService.obtenerCertificacionesPrograma());
    }

    @GetMapping("/api/certificacion-programa/vista/certificaciones-programa/{nombrePrograma}")
    public ResponseEntity<?> obtenerCertificacionesPorPrograma(@PathVariable String nombrePrograma) {
        return ResponseEntity.ok(acaCertificacionProgramaService.obtenerCertificacionesPorPrograma(nombrePrograma));
    }

    @GetMapping("/api/certificacion-programa/vista/estudiantes-aptos-certificacion")
    public ResponseEntity<?> obtenerEstudiantesAptosCertificacion() {
        return ResponseEntity.ok(acaCertificacionProgramaService.obtenerEstudiantesAptosCertificacion());
    }

    @GetMapping("/api/certificacion-programa/vista/estudiantes-aptos")
    public ResponseEntity<?> obtenerEstudiantesAptos() {
        return ResponseEntity.ok(acaCertificacionProgramaService.obtenerEstudiantesAptos());
    }

}

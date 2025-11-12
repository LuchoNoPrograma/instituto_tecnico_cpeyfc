package uap.edu.bo.cpeyfc.domain.aca_certificacion_programa;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import uap.edu.bo.cpeyfc.service.VistasAcademicasService;

@RestController
@RequiredArgsConstructor
public class AcaCertificacionProgramaApi {

    private final AcaCertificacionProgramaService acaCertificacionProgramaService;
    private final AcaCertificacionProgramaRepository acaCertificacionProgramaRepository;
    private final VistasAcademicasService vistasAcademicasService;

    @GetMapping("/api/certificacion-programa/vista/certificaciones-programa")
    public ResponseEntity<?> obtenerCertificacionesPrograma() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerCertificacionesPrograma());
    }

    @GetMapping("/api/certificacion-programa/vista/certificaciones-programa/{nombrePrograma}")
    public ResponseEntity<?> obtenerCertificacionesPorPrograma(@PathVariable String nombrePrograma) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerCertificacionesPorPrograma(nombrePrograma));
    }

    @GetMapping("/api/certificacion-programa/vista/estudiantes-aptos-certificacion")
    public ResponseEntity<?> obtenerEstudiantesAptosCertificacion() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerEstudiantesAptosCertificacion());
    }

    @GetMapping("/api/certificacion-programa/vista/estudiantes-aptos")
    public ResponseEntity<?> obtenerEstudiantesAptos() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerEstudiantesAptos());
    }

}

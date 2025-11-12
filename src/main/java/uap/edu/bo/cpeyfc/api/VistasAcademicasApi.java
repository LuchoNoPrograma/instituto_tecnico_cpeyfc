package uap.edu.bo.cpeyfc.api;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import uap.edu.bo.cpeyfc.service.VistasAcademicasService;

@RestController
@RequiredArgsConstructor
public class VistasAcademicasApi {

    private final VistasAcademicasService vistasAcademicasService;

    @GetMapping("/api/vista/gestiones-periodos")
    public ResponseEntity<?> obtenerGestionesPeriodos() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerGestionesPeriodos());
    }

    @GetMapping("/api/vista/periodo-actual")
    public ResponseEntity<?> obtenerPeriodoActual() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerPeriodoActual());
    }

    @GetMapping("/api/vista/cursos-disponibles")
    public ResponseEntity<?> obtenerCursosDisponibles() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerCursosDisponibles());
    }

    @GetMapping("/api/vista/cronogramas-docente")
    public ResponseEntity<?> obtenerCronogramasDocente() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerCronogramasDocente());
    }

    @GetMapping("/api/vista/cronogramas-docente/{idUsuarioDocente}")
    public ResponseEntity<?> obtenerCronogramasPorDocente(@PathVariable Integer idUsuarioDocente) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerCronogramasPorDocente(idUsuarioDocente));
    }

    @GetMapping("/api/vista/estudiantes-grupo")
    public ResponseEntity<?> obtenerEstudiantesGrupo() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerEstudiantesGrupo());
    }

    @GetMapping("/api/vista/estudiantes-grupo/{idGrupo}")
    public ResponseEntity<?> obtenerEstudiantesPorGrupo(@PathVariable Integer idGrupo) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerEstudiantesPorGrupo(idGrupo));
    }

    @GetMapping("/api/vista/estudiante/ci/{ci}")
    public ResponseEntity<?> obtenerEstudiantePorCi(@PathVariable String ci) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerEstudiantePorCi(ci));
    }

    @GetMapping("/api/vista/aranceles-vigentes")
    public ResponseEntity<?> obtenerArancelesVigentes() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerArancelesVigentes());
    }

    @GetMapping("/api/vista/aranceles-programa/{nombrePrograma}")
    public ResponseEntity<?> obtenerArancelesPorPrograma(@PathVariable String nombrePrograma) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerArancelesPorPrograma(nombrePrograma));
    }

    @GetMapping("/api/vista/convenios-colegios")
    public ResponseEntity<?> obtenerConveniosColegios() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerConveniosColegios());
    }

    @GetMapping("/api/vista/convenios-vigentes")
    public ResponseEntity<?> obtenerConveniosVigentes() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerConveniosVigentes());
    }

    @GetMapping("/api/vista/estado-cuenta/ci/{ci}")
    public ResponseEntity<?> obtenerEstadoCuentaPorCi(@PathVariable String ci) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerEstadoCuentaPorCi(ci));
    }

    @GetMapping("/api/vista/certificaciones-programa")
    public ResponseEntity<?> obtenerCertificacionesPrograma() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerCertificacionesPrograma());
    }

    @GetMapping("/api/vista/certificaciones-programa/{nombrePrograma}")
    public ResponseEntity<?> obtenerCertificacionesPorPrograma(@PathVariable String nombrePrograma) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerCertificacionesPorPrograma(nombrePrograma));
    }

    @GetMapping("/api/vista/estudiantes-aptos-certificacion")
    public ResponseEntity<?> obtenerEstudiantesAptosCertificacion() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerEstudiantesAptosCertificacion());
    }

    @GetMapping("/api/vista/estudiantes-aptos")
    public ResponseEntity<?> obtenerEstudiantesAptos() {
        return ResponseEntity.ok(vistasAcademicasService.obtenerEstudiantesAptos());
    }

    @GetMapping("/api/vista/calificaciones/matricula/{codMatricula}")
    public ResponseEntity<?> obtenerCalificacionesPorMatricula(@PathVariable Integer codMatricula) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerCalificacionesPorMatricula(codMatricula));
    }

    @GetMapping("/api/vista/calificaciones/ci/{ci}")
    public ResponseEntity<?> obtenerCalificacionesPorCi(@PathVariable String ci) {
        return ResponseEntity.ok(vistasAcademicasService.obtenerCalificacionesPorCi(ci));
    }

}

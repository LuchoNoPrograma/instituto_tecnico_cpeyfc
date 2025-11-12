package uap.edu.bo.cpeyfc.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.repository.VistasAcademicasRepository;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class VistasAcademicasService {

    private final VistasAcademicasRepository vistasAcademicasRepository;

    public List<Map<String, Object>> obtenerGestionesPeriodos() {
        return vistasAcademicasRepository.vistaGestionesPeriodos();
    }

    public List<Map<String, Object>> obtenerPeriodoActual() {
        return vistasAcademicasRepository.vistaPeriodoActual();
    }

    public List<Map<String, Object>> obtenerCursosDisponibles() {
        return vistasAcademicasRepository.vistaCursosDisponiblesInscripcion();
    }

    public List<Map<String, Object>> obtenerCronogramasDocente() {
        return vistasAcademicasRepository.vistaCronogramasDocente();
    }

    public List<Map<String, Object>> obtenerCronogramasPorDocente(Integer idUsuarioDocente) {
        return vistasAcademicasRepository.vistaCronogramasPorDocente(idUsuarioDocente);
    }

    public List<Map<String, Object>> obtenerEstudiantesGrupo() {
        return vistasAcademicasRepository.vistaEstudiantesGrupo();
    }

    public List<Map<String, Object>> obtenerEstudiantesPorGrupo(Integer idGrupo) {
        return vistasAcademicasRepository.vistaEstudiantesPorGrupo(idGrupo);
    }

    public List<Map<String, Object>> obtenerEstudiantePorCi(String ci) {
        return vistasAcademicasRepository.vistaEstudiantePorCi(ci);
    }

    public List<Map<String, Object>> obtenerArancelesVigentes() {
        return vistasAcademicasRepository.vistaArancelesVigentes();
    }

    public List<Map<String, Object>> obtenerArancelesPorPrograma(String nombrePrograma) {
        return vistasAcademicasRepository.vistaArancelesPorPrograma(nombrePrograma);
    }

    public List<Map<String, Object>> obtenerArancelesPrograma() {
        return vistasAcademicasRepository.vistaArancelesPrograma();
    }

    public List<Map<String, Object>> obtenerArancelesDetallePorPrograma(Integer idProgramaAprobado) {
        return vistasAcademicasRepository.vistaArancelesDetallePorPrograma(idProgramaAprobado);
    }

    public List<Map<String, Object>> obtenerConveniosColegios() {
        return vistasAcademicasRepository.vistaConveniosColegios();
    }

    public List<Map<String, Object>> obtenerConveniosVigentes() {
        return vistasAcademicasRepository.vistaConveniosVigentes();
    }

    public List<Map<String, Object>> obtenerEstadoCuentaPorCi(String ci) {
        return vistasAcademicasRepository.vistaEstadoCuentaPorCi(ci);
    }

    public List<Map<String, Object>> obtenerCertificacionesPrograma() {
        return vistasAcademicasRepository.vistaCertificacionesPrograma();
    }

    public List<Map<String, Object>> obtenerCertificacionesPorPrograma(String nombrePrograma) {
        return vistasAcademicasRepository.vistaCertificacionesPorPrograma(nombrePrograma);
    }

    public List<Map<String, Object>> obtenerEstudiantesAptosCertificacion() {
        return vistasAcademicasRepository.vistaEstudiantesAptosCertificacion();
    }

    public List<Map<String, Object>> obtenerEstudiantesAptos() {
        return vistasAcademicasRepository.vistaEstudiantesAptos();
    }

    public List<Map<String, Object>> obtenerCalificacionesPorMatricula(Integer codMatricula) {
        return vistasAcademicasRepository.vistaCalificacionesPorMatricula(codMatricula);
    }

    public List<Map<String, Object>> obtenerCalificacionesPorCi(String ci) {
        return vistasAcademicasRepository.vistaCalificacionesPorCi(ci);
    }

}

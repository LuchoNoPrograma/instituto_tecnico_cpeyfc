package uap.edu.bo.cpeyfc.domain.aca_certificacion_programa;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AcaCertificacionProgramaService {

    private final RepositorioGenericoCrud repositorio;
    private final AcaCertificacionProgramaRepository acaCertificacionProgramaRepository;

    // === FUNCIONES DE CERTIFICACIÓN ===

    public Map<String, Object> validarEmisionCertificado(Integer idPersona, Integer idCertificacionPrograma) {
        return acaCertificacionProgramaRepository.validarEmisionCertificado(idPersona, idCertificacionPrograma);
    }

    // === VISTAS DE CERTIFICACIÓN ===

    public List<Map<String, Object>> obtenerCertificacionesPrograma() {
        return acaCertificacionProgramaRepository.vistaCertificacionesPrograma();
    }

    public List<Map<String, Object>> obtenerCertificacionesPorPrograma(String nombrePrograma) {
        return acaCertificacionProgramaRepository.vistaCertificacionesPorPrograma(nombrePrograma);
    }

    public List<Map<String, Object>> obtenerEstudiantesAptosCertificacion() {
        return acaCertificacionProgramaRepository.vistaEstudiantesAptosCertificacion();
    }

    public List<Map<String, Object>> obtenerEstudiantesAptos() {
        return acaCertificacionProgramaRepository.vistaEstudiantesAptos();
    }

}

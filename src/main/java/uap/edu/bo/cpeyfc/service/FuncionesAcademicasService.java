package uap.edu.bo.cpeyfc.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.repository.FuncionesAcademicasRepository;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class FuncionesAcademicasService {

    private final FuncionesAcademicasRepository funcionesAcademicasRepository;

    public Map<String, Object> calcularMontoMatricula(Integer idProgramaAprobado,
                                                     Integer idTipoEstudiante,
                                                     Integer numeroPeriodo,
                                                     Integer idConvenio) {
        return funcionesAcademicasRepository.calcularMontoMatricula(
            idProgramaAprobado,
            idTipoEstudiante,
            numeroPeriodo,
            idConvenio
        );
    }

    public Map<String, Object> validarEmisionCertificado(Integer idPersona,
                                                         Integer idCertificacionPrograma) {
        return funcionesAcademicasRepository.validarEmisionCertificado(
            idPersona,
            idCertificacionPrograma
        );
    }

}

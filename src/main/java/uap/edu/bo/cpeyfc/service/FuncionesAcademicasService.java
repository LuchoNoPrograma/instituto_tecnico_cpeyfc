package uap.edu.bo.cpeyfc.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.repository.FuncionesAcademicasRepository;

import java.util.List;
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

    public Map<String, Object> registrarArancel(Integer idProgramaAprobado,
                                               Integer idPeriodo,
                                               Integer idTipoEstudiante,
                                               String nombreArancel,
                                               String nroResolucion,
                                               String fechaAprobacion,
                                               String fechaInicioVigencia,
                                               String fechaFinVigencia,
                                               String detalles,
                                               Integer userReg) {
        return funcionesAcademicasRepository.registrarArancel(
            idProgramaAprobado,
            idPeriodo,
            idTipoEstudiante,
            nombreArancel,
            nroResolucion,
            fechaAprobacion,
            fechaInicioVigencia,
            fechaFinVigencia,
            detalles,
            userReg
        );
    }

    public List<Map<String, Object>> obtenerConceptosArancel(Integer idProgramaAprobado,
                                                              Integer idTipoEstudiante,
                                                              Integer numeroPeriodo,
                                                              Integer idConvenio) {
        return funcionesAcademicasRepository.obtenerConceptosArancel(
            idProgramaAprobado,
            idTipoEstudiante,
            numeroPeriodo,
            idConvenio
        );
    }

}

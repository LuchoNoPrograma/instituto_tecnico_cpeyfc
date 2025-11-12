package uap.edu.bo.cpeyfc.domain.fin_arancel;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class FinArancelService {

    private final RepositorioGenericoCrud repositorio;
    private final FinArancelRepository finArancelRepository;

    // === FUNCIONES DE ARANCELES ===

    /**
     * Registra un arancel completo con sus detalles
     */
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
        return finArancelRepository.registrarArancel(
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

    /**
     * Obtiene los conceptos de pago con montos y descuentos aplicados según arancel
     */
    public List<Map<String, Object>> obtenerConceptosArancel(Integer idProgramaAprobado,
                                                              Integer idTipoEstudiante,
                                                              Integer numeroPeriodo,
                                                              Integer idConvenio) {
        return finArancelRepository.obtenerConceptosArancel(
            idProgramaAprobado,
            idTipoEstudiante,
            numeroPeriodo,
            idConvenio
        );
    }

    /**
     * @deprecated Usar obtenerConceptosArancel en su lugar
     */
    @Deprecated
    public Map<String, Object> calcularMontoMatricula(Integer idProgramaAprobado,
                                                      Integer idTipoEstudiante,
                                                      Integer numeroPeriodo,
                                                      Integer idConvenio) {
        return finArancelRepository.calcularMontoMatricula(
            idProgramaAprobado,
            idTipoEstudiante,
            numeroPeriodo,
            idConvenio
        );
    }

    // === VISTAS DE ARANCELES ===

    /**
     * Obtiene todos los aranceles vigentes
     */
    public List<Map<String, Object>> obtenerArancelesVigentes() {
        return finArancelRepository.vistaArancelesVigentes();
    }

    /**
     * Obtiene aranceles vigentes por programa
     */
    public List<Map<String, Object>> obtenerArancelesPorPrograma(String nombrePrograma) {
        return finArancelRepository.vistaArancelesPorPrograma(nombrePrograma);
    }

    /**
     * Obtiene todos los aranceles con detalle de conceptos
     */
    public List<Map<String, Object>> obtenerArancelesDetalle() {
        return finArancelRepository.vistaArancelesDetalle();
    }

    /**
     * Obtiene aranceles con detalle por programa
     */
    public List<Map<String, Object>> obtenerArancelesDetallePorPrograma(Integer idProgramaAprobado) {
        return finArancelRepository.vistaArancelesDetallePorPrograma(idProgramaAprobado);
    }

}

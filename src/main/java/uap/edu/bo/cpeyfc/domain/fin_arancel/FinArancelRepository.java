package uap.edu.bo.cpeyfc.domain.fin_arancel;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface FinArancelRepository extends JpaRepository<FinArancel, Integer> {

    // === FUNCIONES DE ARANCELES ===

    /**
     * Registra un arancel completo con sus detalles (conceptos)
     * @param idProgramaAprobado ID del programa aprobado
     * @param idPeriodo ID del periodo académico (puede ser null)
     * @param idTipoEstudiante ID del tipo de estudiante
     * @param nombreArancel Nombre descriptivo del arancel
     * @param nroResolucion Número de resolución (puede ser null)
     * @param fechaAprobacion Fecha de aprobación (puede ser null)
     * @param fechaInicioVigencia Fecha de inicio de vigencia
     * @param fechaFinVigencia Fecha de fin de vigencia (puede ser null)
     * @param detalles JSON array con conceptos [{id_fin_concepto_arancel, monto_concepto, orden_aplicacion}]
     * @param userReg Usuario que registra
     * @return Map con flag, mensaje, id_arancel
     */
    @Query(value = "SELECT * FROM fn_registrar_arancel(?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, CAST(?9 AS jsonb), ?10)", nativeQuery = true)
    Map<String, Object> registrarArancel(Integer idProgramaAprobado,
                                         Integer idPeriodo,
                                         Integer idTipoEstudiante,
                                         String nombreArancel,
                                         String nroResolucion,
                                         String fechaAprobacion,
                                         String fechaInicioVigencia,
                                         String fechaFinVigencia,
                                         String detalles,
                                         Integer userReg);

    /**
     * Obtiene los conceptos de pago con montos y descuentos aplicados según arancel
     * @param idProgramaAprobado ID del programa aprobado
     * @param idTipoEstudiante ID del tipo de estudiante
     * @param numeroPeriodo Número del periodo
     * @param idConvenio ID del convenio (puede ser null)
     * @return List de Maps con id_fin_concepto_arancel, nombre_concepto, descripcion, monto_base, descuento_aplicado, monto_final, origen_descuento
     */
    @Query(value = "SELECT * FROM fn_obtener_conceptos_arancel(?1, ?2, ?3, ?4)", nativeQuery = true)
    List<Map<String, Object>> obtenerConceptosArancel(Integer idProgramaAprobado,
                                                       Integer idTipoEstudiante,
                                                       Integer numeroPeriodo,
                                                       Integer idConvenio);

    /**
     * Calcula el monto de matrícula con descuentos aplicables
     * @deprecated Usar obtenerConceptosArancel en su lugar
     */
    @Deprecated
    @Query(value = "SELECT * FROM fn_calcular_monto_matricula(?1, ?2, ?3, ?4)", nativeQuery = true)
    Map<String, Object> calcularMontoMatricula(Integer idProgramaAprobado,
                                               Integer idTipoEstudiante,
                                               Integer numeroPeriodo,
                                               Integer idConvenio);

    // === VISTAS DE ARANCELES ===

    /**
     * Obtiene todos los aranceles vigentes
     */
    @Query(value = "SELECT * FROM vista_aranceles_vigentes", nativeQuery = true)
    List<Map<String, Object>> vistaArancelesVigentes();

    /**
     * Obtiene aranceles vigentes filtrados por programa
     */
    @Query(value = "SELECT * FROM vista_aranceles_vigentes WHERE nombre_programa = ?1", nativeQuery = true)
    List<Map<String, Object>> vistaArancelesPorPrograma(String nombrePrograma);

    /**
     * Obtiene todos los aranceles con su detalle de conceptos
     */
    @Query(value = "SELECT * FROM vista_aranceles_detalle", nativeQuery = true)
    List<Map<String, Object>> vistaArancelesDetalle();

    /**
     * Obtiene aranceles con detalle filtrados por programa
     */
    @Query(value = "SELECT * FROM vista_aranceles_detalle WHERE id_aca_programa_aprobado = ?1", nativeQuery = true)
    List<Map<String, Object>> vistaArancelesDetallePorPrograma(Integer idProgramaAprobado);

}

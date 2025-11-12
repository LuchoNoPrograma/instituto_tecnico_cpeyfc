package uap.edu.bo.cpeyfc.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import uap.edu.bo.cpeyfc.domain.aca_gestion.AcaGestion;

import java.util.Map;

/**
 * Repository para ejecutar funciones académicas creadas en migración V21
 */
public interface FuncionesAcademicasRepository extends JpaRepository<AcaGestion, Integer> {

  /**
   * Calcula el monto de matrícula con descuentos aplicables
   * @param idProgramaAprobado ID del programa aprobado
   * @param idTipoEstudiante ID del tipo de estudiante (Nacional, UAP, Extranjero)
   * @param numeroPeriodo Número del periodo cursando (1, 2, 3...)
   * @param idConvenio ID del convenio (puede ser null)
   * @return Map con monto_base, descuento_arancel, descuento_convenio, monto_final, conceptos (JSON)
   */
  @Query(value = "SELECT * FROM fn_calcular_monto_matricula(?1, ?2, ?3, ?4)", nativeQuery = true)
  Map<String, Object> calcularMontoMatricula(Integer idProgramaAprobado,
                                             Integer idTipoEstudiante,
                                             Integer numeroPeriodo,
                                             Integer idConvenio);

  /**
   * Valida si un estudiante cumple los requisitos para emitir un certificado
   * @param idPersona ID de la persona
   * @param idCertificacionPrograma ID de la certificación del programa
   * @return Map con puede_certificar, mensaje, periodos_requeridos, periodos_aprobados, deuda_pendiente
   */
  @Query(value = "SELECT * FROM fn_validar_emision_certificado(?1, ?2)", nativeQuery = true)
  Map<String, Object> validarEmisionCertificado(Integer idPersona,
                                                Integer idCertificacionPrograma);

  /**
   * Registra un arancel completo con sus detalles (conceptos)
   * @param idProgramaAprobado ID del programa aprobado
   * @param idGestion ID de la gestión académica
   * @param idTipoEstudiante ID del tipo de estudiante
   * @param nombreArancel Nombre descriptivo del arancel
   * @param descripcion Descripción del arancel
   * @param fechaInicioVigencia Fecha de inicio de vigencia
   * @param fechaFinVigencia Fecha de fin de vigencia (puede ser null)
   * @param detalles JSON array con conceptos [{id_fin_concepto_arancel, monto, orden}]
   * @param userReg Usuario que registra
   * @return Map con flag, mensaje, id_arancel
   */
  @Query(value = "SELECT * FROM fn_registrar_arancel(?1, ?2, ?3, ?4, ?5, ?6, ?7, CAST(?8 AS jsonb), ?9)", nativeQuery = true)
  Map<String, Object> registrarArancel(Integer idProgramaAprobado,
                                       Integer idGestion,
                                       Integer idTipoEstudiante,
                                       String nombreArancel,
                                       String descripcion,
                                       String fechaInicioVigencia,
                                       String fechaFinVigencia,
                                       String detalles,
                                       String userReg);

  /**
   * Obtiene los conceptos de pago con montos y descuentos aplicados según arancel
   * @param idProgramaAprobado ID del programa aprobado
   * @param idTipoEstudiante ID del tipo de estudiante
   * @param numeroPeriodo Número del periodo
   * @param idConvenio ID del convenio (puede ser null)
   * @return List de Maps con id_fin_concepto_arancel, nombre_concepto, descripcion, monto_base, descuento_aplicado, monto_final, origen_descuento
   */
  @Query(value = "SELECT * FROM fn_obtener_conceptos_arancel(?1, ?2, ?3, ?4)", nativeQuery = true)
  java.util.List<Map<String, Object>> obtenerConceptosArancel(Integer idProgramaAprobado,
                                                                Integer idTipoEstudiante,
                                                                Integer numeroPeriodo,
                                                                Integer idConvenio);

}

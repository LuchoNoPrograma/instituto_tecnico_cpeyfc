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

}

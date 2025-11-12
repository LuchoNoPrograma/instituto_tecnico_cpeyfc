package uap.edu.bo.cpeyfc.domain.aca_programa_aprobado;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface AcaProgramaAprobadoRepository extends JpaRepository<AcaProgramaAprobado, Integer> {
  @Query(value = "SELECT * FROM vista_programas_aprobados", nativeQuery = true)
  List<Map<String, Object>> vistaProgramasAprobados();

  @Query(value = "SELECT * FROM vista_programas_aprobados where id_aca_programa_aprobado = ?1", nativeQuery = true)
  Map<String, Object> vistaProgramasAprobadosPorIdProgramaAprobado(Long idProgramaAprobado);

  @Query(value = "SELECT * FROM fn_obtener_plan_estudio_programa_aprobado(?1)", nativeQuery = true)
  List<Map<String, Object>> obtenerPlanEstudioProgramaAprobado(Integer idAcaProgramaAprobado);

  /**
   * Registra un programa aprobado SIN precios. Los aranceles deben configurarse por separado.
   * @deprecated Los parámetros de precio ya no se usan. Usar sistema de aranceles (fin_arancel).
   */
  @Deprecated
  @Query(value = """
        SELECT fn_registrar_programa_aprobado(
            :id_aca_programa, :id_aca_modalidad, :gestion, :id_aca_plan_estudio,
            :id_aca_version, :estado_programa_aprobado, :cod_certificado_ceub,
            :precio_matricula, :precio_colegiatura, :precio_titulacion,
            :fecha_inicio_vigencia, :fecha_fin_vigencia, :user_reg)
        """, nativeQuery = true)
  String registrarProgramaAprobado(Integer id_aca_programa,
                                   Integer id_aca_modalidad,
                                   Integer gestion,
                                   Integer id_aca_plan_estudio,
                                   Integer id_aca_version,
                                   String estado_programa_aprobado,
                                   String cod_certificado_ceub,
                                   BigDecimal precio_matricula,
                                   BigDecimal precio_colegiatura,
                                   BigDecimal precio_titulacion,
                                   LocalDate fecha_inicio_vigencia,
                                   LocalDate fecha_fin_vigencia,
                                   Integer user_reg);

  /**
   * Registra un programa aprobado usando el nuevo sistema sin precios directos.
   */
  @Query(value = """
        SELECT * FROM fn_registrar_programa_aprobado(
            ?1, ?2, ?3, ?4, ?5, ?6,
            ?7, ?8, ?9, ?10, ?11, ?12)
        """, nativeQuery = true)
  Map<String, Object> registrarProgramaAprobadoV2(Integer idPrograma,
                                                   Integer idNivel,
                                                   Integer idModalidad,
                                                   Integer idPlanEstudio,
                                                   Integer idVersion,
                                                   String gestion,
                                                   String codCertificadoCeub,
                                                   String fechaInicioVigencia,
                                                   String fechaFinVigencia,
                                                   String sistemaPrograma,
                                                   String imagenProgramaUrl,
                                                   String userReg);

  /**
   * @deprecated Los parámetros de precio ya no se usan. Usar modificarProgramaAprobadoV2.
   */
  @Deprecated
  @Query(value = """
        SELECT fn_modificar_programa_aprobado(
            :id, :id_aca_programa, :id_aca_modalidad, :gestion, :id_aca_plan_estudio,
            :id_aca_version, :estado_programa_aprobado, :precio_matricula, :precio_colegiatura,
            :precio_titulacion, :fecha_inicio_vigencia, :fecha_fin_vigencia,
            :cod_certificado_ceub, :cod_sigla_version, :user_mod)
        """, nativeQuery = true)
  String modificarProgramaAprobado(Integer id,
                                   Integer id_aca_programa,
                                   Integer id_aca_modalidad,
                                   Integer gestion,
                                   Integer id_aca_plan_estudio,
                                   Integer id_aca_version,
                                   String estado_programa_aprobado,
                                   BigDecimal precio_matricula,
                                   BigDecimal precio_colegiatura,
                                   BigDecimal precio_titulacion,
                                   LocalDate fecha_inicio_vigencia,
                                   LocalDate fecha_fin_vigencia,
                                   String cod_certificado_ceub,
                                   String cod_sigla_version,
                                   Integer user_mod);

  /**
   * Modifica un programa aprobado usando el nuevo sistema sin precios directos.
   */
  @Query(value = """
        SELECT * FROM fn_modificar_programa_aprobado(
            ?1, ?2, ?3, ?4, ?5, ?6, ?7,
            ?8, ?9, ?10, ?11)
        """, nativeQuery = true)
  Map<String, Object> modificarProgramaAprobadoV2(Integer idProgramaAprobado,
                                                   Integer idPlanEstudio,
                                                   Integer idVersion,
                                                   String gestion,
                                                   String codCertificadoCeub,
                                                   String fechaInicioVigencia,
                                                   String fechaFinVigencia,
                                                   String sistemaPrograma,
                                                   String imagenProgramaUrl,
                                                   String estadoProgramaAprobado,
                                                   String userMod);
}
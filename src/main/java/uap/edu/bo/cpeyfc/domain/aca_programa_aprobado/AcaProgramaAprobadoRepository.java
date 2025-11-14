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

  @Query(value = """
    SELECT fn_registrar_programa_aprobado(
      :id_aca_programa, :id_aca_modalidad, :gestion,
      :id_aca_plan_estudio, :id_aca_version,
      :estado_programa_aprobado, :cod_certificado_ceub,
      :imagen_programa_url, :fecha_inicio_vigencia,
      :fecha_fin_vigencia, :user_reg)
    """, nativeQuery = true)
  Integer registrarProgramaAprobado(Integer id_aca_programa,
                                    Integer id_aca_modalidad,
                                    Integer gestion,
                                    Integer id_aca_plan_estudio,
                                    Integer id_aca_version,
                                    String estado_programa_aprobado,
                                    String cod_certificado_ceub,
                                    String imagen_programa_url,
                                    LocalDate fecha_inicio_vigencia,
                                    LocalDate fecha_fin_vigencia,
                                    Integer user_reg);

  @Query(value = """
  SELECT fn_modificar_programa_aprobado(
    :id_aca_programa_aprobado, :id_aca_programa, :id_aca_modalidad,
    :gestion, :id_aca_plan_estudio, :id_aca_version,
    :estado_programa_aprobado, :imagen_programa_url,
    :fecha_inicio_vigencia, :fecha_fin_vigencia, :user_mod)
  """, nativeQuery = true)
  String modificarProgramaAprobado(Integer id_aca_programa_aprobado,
                                   Integer id_aca_programa,
                                   Integer id_aca_modalidad,
                                   Integer gestion,
                                   Integer id_aca_plan_estudio,
                                   Integer id_aca_version,
                                   String estado_programa_aprobado,
                                   String imagen_programa_url,
                                   LocalDate fecha_inicio_vigencia,
                                   LocalDate fecha_fin_vigencia,
                                   Integer user_mod);
}
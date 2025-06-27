package uap.edu.bo.cpeyfc.domain.aca_parametro_programa;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface AcaParametroProgramaRepository extends JpaRepository<AcaParametroPrograma, Integer> {
  @Query(value = """
        SELECT fn_registrar_parametro_programa(
            :id_programa_aprobado, :nombre_param, :valor, :tipo_dato_param,
            :fecha_inicio_vigencia, :fecha_fin_vigencia, :orden, :user_reg)
        """, nativeQuery = true)
  Integer registrarParametro(Integer id_programa_aprobado,
                             String nombre_param,
                             String valor,
                             String tipo_dato_param,
                             LocalDate fecha_inicio_vigencia,
                             LocalDate fecha_fin_vigencia,
                             Integer orden,
                             Integer user_reg);

  @Query(value = """
        SELECT fn_modificar_parametro_programa(
            :id_parametro, :nombre_param, :valor, :tipo_dato_param,
            :fecha_inicio_vigencia, :fecha_fin_vigencia, :orden, :estado, :user_mod)
        """, nativeQuery = true)
  Boolean modificarParametro(Integer id_parametro,
                             String nombre_param,
                             String valor,
                             String tipo_dato_param,
                             LocalDate fecha_inicio_vigencia,
                             LocalDate fecha_fin_vigencia,
                             Integer orden,
                             String estado,
                             Integer user_mod);

  @Query(value = """
        SELECT * FROM fn_obtener_parametros_programa(:id_programa_aprobado, :tipo_dato_param, :solo_vigentes)
        """, nativeQuery = true)
  List<Map<String, Object>> obtenerParametrosPorPrograma(Integer id_programa_aprobado,
                                                         String tipo_dato_param,
                                                         Boolean solo_vigentes);
}
package uap.edu.bo.cpeyfc.domain.eje_criterio_eval;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface EjeCriterioEvalRepository extends JpaRepository<EjeCriterioEval, Integer> {
  @Query(value = """
        SELECT fn_registrar_criterio_evaluacion(
            :id_cronograma, :nombre_crit, :descripcion, :ponderacion, :orden, :user_reg)
        """, nativeQuery = true)
  Integer registrarCriterioEvaluacion(Integer id_cronograma,
                                      String nombre_crit,
                                      String descripcion,
                                      Integer ponderacion,
                                      Integer orden,
                                      Integer user_reg);

  @Query(value = """
        SELECT fn_modificar_criterio_evaluacion(
            :id_eje_criterio_eval, :nombre_crit, :descripcion, :ponderacion, :orden, :user_mod)
        """, nativeQuery = true)
  String modificarCriterioEvaluacion(Integer id_eje_criterio_eval,
                                     String nombre_crit,
                                     String descripcion,
                                     Integer ponderacion,
                                     Integer orden,
                                     Integer user_mod);

  @Query(value = "SELECT fn_eliminar_criterio_evaluacion(:id_eje_criterio_eval, :user_mod)", nativeQuery = true)
  String eliminarCriterioEvaluacion(Integer id_eje_criterio_eval, Integer user_mod);

  @Query(value = "SELECT * FROM fn_criterios_por_cronograma(:id_cronograma)", nativeQuery = true)
  List<Map<String, Object>> criteriosPorCronograma(Integer id_cronograma);
}
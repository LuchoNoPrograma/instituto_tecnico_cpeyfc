package uap.edu.bo.cpeyfc.domain.eje_calificacion;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public interface EjeCalificacionRepository extends JpaRepository<EjeCalificacion, Integer> {

  @Query(value = """
        SELECT fn_registrar_calificacion_cronograma(
            :id_eje_programacion, :id_eje_criterio_eval, :nota, :user_reg)
        """, nativeQuery = true)
  Integer registrarCalificacion(Integer id_eje_programacion,
                                Integer id_eje_criterio_eval,
                                BigDecimal nota,
                                Integer user_reg);

  @Query(value = """
        SELECT * FROM vista_calificaciones_detalle
        WHERE id_eje_cronograma_modulo = :id_cronograma
        ORDER BY nombre_estudiante, orden
        """, nativeQuery = true)
  List<Map<String, Object>> obtenerCalificacionesCronograma(Integer id_cronograma);

  @Query(value = """
        SELECT * FROM fn_obtener_programaciones_estudiante(:cod_matricula)
        """, nativeQuery = true)
  List<Map<String, Object>> obtenerProgramacionesEstudiante(Integer cod_matricula);

  @Query(value = """
        SELECT ce.*, cm.fecha_inicio, cm.fecha_fin, pmd.sigla, mod.nombre_modulo
        FROM eje_criterio_eval ce
        JOIN eje_cronograma_modulo cm ON ce.id_eje_cronograma_modulo = cm.id_eje_cronograma_modulo
        JOIN aca_plan_modulo_detalle pmd ON cm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle
        JOIN aca_modulo mod ON pmd.id_aca_modulo = mod.id_aca_modulo
        WHERE ce.id_eje_cronograma_modulo = :id_cronograma
          AND ce.estado_criterio_eval != 'ELIMINADO'
        ORDER BY ce.orden
        """, nativeQuery = true)
  List<Map<String, Object>> obtenerCriteriosCronograma(Integer id_cronograma);

  @Query(value = """
        SELECT 
            prog.id_eje_programacion,
            prog.cod_ins_matricula,
            p.ci,
            p.nombre || ' ' || p.ap_paterno || COALESCE(' ' || p.ap_materno, '') as nombre_estudiante,
            prog.nota_final,
            prog.estado_programacion
        FROM eje_programacion prog
        JOIN ins_matricula m ON prog.cod_ins_matricula = m.cod_ins_matricula
        JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
        WHERE prog.id_eje_cronograma_modulo = :id_cronograma
          AND prog.estado_programacion != 'ELIMINADO'
        ORDER BY p.ap_paterno, p.nombre
        """, nativeQuery = true)
  List<Map<String, Object>> obtenerEstudiantesCronograma(Integer id_cronograma);
}

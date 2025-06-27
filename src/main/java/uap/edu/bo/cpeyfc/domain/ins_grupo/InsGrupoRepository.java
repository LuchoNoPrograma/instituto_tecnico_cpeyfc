package uap.edu.bo.cpeyfc.domain.ins_grupo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface InsGrupoRepository extends JpaRepository<InsGrupo, Integer> {

  @Query(value = "SELECT * FROM vista_grupos_completos ORDER BY gestion_inicio DESC, nombre_grupo", nativeQuery = true)
  List<Map<String, Object>> vistaGruposCompletos();

  @Query(value = "SELECT * FROM vista_grupos_completos WHERE id_aca_programa_aprobado = :id_programa_aprobado ORDER BY gestion_inicio DESC, nombre_grupo", nativeQuery = true)
  List<Map<String, Object>> vistaGruposCompletosPorIdProgramaAprobado(Integer id_programa_aprobado);

  @Query(value = "SELECT * FROM vista_grupos_con_cronogramas", nativeQuery = true)
  List<Map<String, Object>> vistaGruposConCronogramas();

  @Query(value = "SELECT * FROM vista_grupos_con_cronogramas where id_aca_programa_aprobado = :id_programa", nativeQuery = true)
  List<Map<String, Object>> vistaGruposConCronogramasPorIdPrograma(Integer id_programa);

  @Query(value = "SELECT * FROM vista_grupos_matriculacion where id_aca_programa_aprobado = ?1", nativeQuery = true)
  List<Map<String, Object>> vistaGruposActivosPorProgramaAprobado(Long idProgramaAprobado);

  @Query(value = """
        SELECT 
            COUNT(*) as total,
            COUNT(CASE WHEN estado_grupo = 'PROGRAMADO' THEN 1 END) as programados,
            COUNT(CASE WHEN estado_grupo = 'EN OFERTA' THEN 1 END) as en_oferta,
            COUNT(CASE WHEN estado_grupo = 'EN EJECUCION' THEN 1 END) as en_ejecucion,
            COUNT(CASE WHEN estado_grupo = 'FINALIZADO' THEN 1 END) as finalizados
        FROM vista_grupos_completos
        """, nativeQuery = true)
  Map<String, Object> obtenerEstadisticasGrupos();

  @Query(value = "SELECT * FROM vista_estudiantes_por_grupo WHERE id_ins_grupo = :id_grupo ORDER BY ap_paterno, ap_materno, nombre", nativeQuery = true)
  List<Map<String, Object>> obtenerEstudiantesPorGrupo(Integer id_grupo);

  @Query(value = "SELECT * FROM vista_programas_publicos", nativeQuery = true)
  List<Map<String, Object>> vistaProgramasOfertadosAPublico();

  @Query(value = """
        SELECT fn_registrar_grupo(
            :id_aca_programa_aprobado, :nombre_grupo, :fecha_inicio_inscripcion,
            :fecha_fin_inscripcion, :gestion_inicio, :user_reg)
        """, nativeQuery = true)
  String registrarGrupo(Integer id_aca_programa_aprobado,
                        String nombre_grupo,
                        LocalDate fecha_inicio_inscripcion,
                        LocalDate fecha_fin_inscripcion,
                        Integer gestion_inicio,
                        Integer user_reg);

  @Query(value = """
        SELECT fn_modificar_grupo(
            :id_ins_grupo, :nombre_grupo, :fecha_inicio_inscripcion,
            :fecha_fin_inscripcion, :estado_grupo, :user_mod)
        """, nativeQuery = true)
  String modificarGrupo(Integer id_ins_grupo,
                        String nombre_grupo,
                        LocalDate fecha_inicio_inscripcion,
                        LocalDate fecha_fin_inscripcion,
                        String estado_grupo,
                        Integer user_mod);
}
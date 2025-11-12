package uap.edu.bo.cpeyfc.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import uap.edu.bo.cpeyfc.domain.aca_gestion.AcaGestion;

import java.util.List;
import java.util.Map;

/**
 * Repository para consultar vistas académicas creadas en migración V21
 */
public interface VistasAcademicasRepository extends JpaRepository<AcaGestion, Integer> {

  // VISTAS DE PERIODOS Y GESTIONES
  @Query(value = "SELECT * FROM vista_gestiones_periodos", nativeQuery = true)
  List<Map<String, Object>> vistaGestionesPeriodos();

  @Query(value = "SELECT * FROM vista_periodo_actual", nativeQuery = true)
  List<Map<String, Object>> vistaPeriodoActual();

  // VISTAS DE CRONOGRAMAS Y OFERTAS
  @Query(value = "SELECT * FROM vista_cursos_disponibles_inscripcion", nativeQuery = true)
  List<Map<String, Object>> vistaCursosDisponiblesInscripcion();

  @Query(value = "SELECT * FROM vista_cronogramas_docente", nativeQuery = true)
  List<Map<String, Object>> vistaCronogramasDocente();

  @Query(value = "SELECT * FROM vista_cronogramas_docente WHERE id_usuario_docente = ?1", nativeQuery = true)
  List<Map<String, Object>> vistaCronogramasPorDocente(Integer idUsuarioDocente);

  // VISTAS DE ESTUDIANTES Y MATRÍCULAS
  @Query(value = "SELECT * FROM vista_estudiantes_grupo", nativeQuery = true)
  List<Map<String, Object>> vistaEstudiantesGrupo();

  @Query(value = "SELECT * FROM vista_estudiantes_grupo WHERE id_ins_grupo = ?1", nativeQuery = true)
  List<Map<String, Object>> vistaEstudiantesPorGrupo(Integer idGrupo);

  @Query(value = "SELECT * FROM vista_estudiantes_grupo WHERE ci = ?1", nativeQuery = true)
  List<Map<String, Object>> vistaEstudiantePorCi(String ci);

  // VISTAS FINANCIERAS
  @Query(value = "SELECT * FROM vista_aranceles_vigentes", nativeQuery = true)
  List<Map<String, Object>> vistaArancelesVigentes();

  @Query(value = "SELECT * FROM vista_aranceles_vigentes WHERE nombre_programa = ?1", nativeQuery = true)
  List<Map<String, Object>> vistaArancelesPorPrograma(String nombrePrograma);

  @Query(value = "SELECT * FROM vista_aranceles_programa", nativeQuery = true)
  List<Map<String, Object>> vistaArancelesPrograma();

  @Query(value = "SELECT * FROM vista_aranceles_programa WHERE id_aca_programa_aprobado = ?1", nativeQuery = true)
  List<Map<String, Object>> vistaArancelesDetallePorPrograma(Integer idProgramaAprobado);

  @Query(value = "SELECT * FROM vista_convenios_colegios", nativeQuery = true)
  List<Map<String, Object>> vistaConveniosColegios();

  @Query(value = "SELECT * FROM vista_convenios_colegios WHERE estado_vigencia = 'VIGENTE'", nativeQuery = true)
  List<Map<String, Object>> vistaConveniosVigentes();

  @Query(value = "SELECT * FROM vista_estado_cuenta_estudiante WHERE ci = ?1", nativeQuery = true)
  List<Map<String, Object>> vistaEstadoCuentaPorCi(String ci);

  // VISTAS DE CERTIFICACIONES
  @Query(value = "SELECT * FROM vista_certificaciones_programa", nativeQuery = true)
  List<Map<String, Object>> vistaCertificacionesPrograma();

  @Query(value = "SELECT * FROM vista_certificaciones_programa WHERE nombre_programa = ?1", nativeQuery = true)
  List<Map<String, Object>> vistaCertificacionesPorPrograma(String nombrePrograma);

  @Query(value = "SELECT * FROM vista_estudiantes_aptos_certificacion", nativeQuery = true)
  List<Map<String, Object>> vistaEstudiantesAptosCertificacion();

  @Query(value = "SELECT * FROM vista_estudiantes_aptos_certificacion WHERE apto_para_certificar = true", nativeQuery = true)
  List<Map<String, Object>> vistaEstudiantesAptos();

  // VISTAS DE CALIFICACIONES
  @Query(value = "SELECT * FROM vista_calificaciones_competencia WHERE cod_ins_matricula = ?1", nativeQuery = true)
  List<Map<String, Object>> vistaCalificacionesPorMatricula(Integer codMatricula);

  @Query(value = "SELECT * FROM vista_calificaciones_competencia WHERE ci = ?1", nativeQuery = true)
  List<Map<String, Object>> vistaCalificacionesPorCi(String ci);

}

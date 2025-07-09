package uap.edu.bo.cpeyfc.domain.eje_cronograma_modulo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface EjeCronogramaModuloRepository extends JpaRepository<EjeCronogramaModulo, Integer> {

  @Query(value = "SELECT * FROM fn_modificar_cronograma_modulo(:id_eje_cronograma_modulo, :id_prs_persona, :fecha_inicio, :fecha_fin, :user_mod)", nativeQuery = true)
  Map<String, Object> modificarCronogramaModulo(Integer id_eje_cronograma_modulo,
                                                Integer id_prs_persona,
                                                LocalDate fecha_inicio,
                                                LocalDate fecha_fin,
                                                Integer user_mod);

  @Query(value = "SELECT * FROM fn_activar_usuario_docente(:id_usuario, :password_hash)", nativeQuery = true)
  String activarUsuarioDocente(Integer id_usuario, String password_hash);

  @Query(nativeQuery = true, value = "SELECT * FROM vista_cronogramas_por_usuario_docente WHERE id_usuario_docente = :id_usuario")
  List<Map<String, Object>> vistaCronogramasPorIdUsuarioDocente(Integer id_usuario);

  @Query(nativeQuery = true, value = "SELECT * FROM vista_estudiantes_por_cronograma WHERE id_eje_cronograma_modulo = :id_cronograma")
  List<Map<String, Object>> vistaEstudiantesPorIdCronograma(Integer id_cronograma);

  @Query(value = "SELECT * FROM fn_reporte_acta_regular(?1)", nativeQuery = true)
  List<Map<String,Object>> reporte_acta_regular(Integer id_cronograma_modulo);
}
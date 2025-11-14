package uap.edu.bo.cpeyfc.domain.aca_perfil_estudiante;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaPerfilEstudianteRepository extends JpaRepository<AcaPerfilEstudiante, Integer> {

  // Vistas para chatbot
  @Query(nativeQuery = true, value = "SELECT * FROM vista_chatbot_requisitos_por_perfil")
  List<Map<String, Object>> vistaRequisitosPerfiles();

  @Query(nativeQuery = true, value = "SELECT * FROM vista_chatbot_perfiles_programa WHERE id_aca_programa = :idPrograma")
  List<Map<String, Object>> vistaPerfilesPrograma(Integer idPrograma);

  @Query(value = "SELECT * FROM fn_obtener_requisitos_programa_chatbot(:idPrograma)", nativeQuery = true)
  List<Map<String, Object>> obtenerRequisitosPrograma(Integer idPrograma);

  // Vistas para administración
  @Query(nativeQuery = true, value = "SELECT * FROM vista_perfiles_estudiante_activos")
  List<Map<String, Object>> vistaPerfilesActivos();

  @Query(nativeQuery = true, value = "SELECT * FROM vista_requisitos_por_perfil WHERE id_aca_perfil_estudiante = :idPerfil")
  List<Map<String, Object>> vistaRequisitosPorPerfil(Integer idPerfil);

  // CRUD
  @Query(value = "SELECT fn_registrar_perfil_estudiante(:nombrePerfil, :descripcion, :userReg)", nativeQuery = true)
  Integer registrarPerfil(String nombrePerfil, String descripcion, Integer userReg);

  @Query(value = "SELECT fn_modificar_perfil_estudiante(:idPerfil, :nombrePerfil, :descripcion, :userMod)", nativeQuery = true)
  Boolean modificarPerfil(Integer idPerfil, String nombrePerfil, String descripcion, Integer userMod);

  @Query(value = "SELECT fn_eliminar_perfil_estudiante(:idPerfil, :userMod)", nativeQuery = true)
  Boolean eliminarPerfil(Integer idPerfil, Integer userMod);

}

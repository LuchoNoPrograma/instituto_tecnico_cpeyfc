package uap.edu.bo.cpeyfc.domain.aca_perfil_estudiante;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaPerfilEstudianteRepository extends JpaRepository<AcaPerfilEstudiante, Integer> {

  @Query(nativeQuery = true, value = "SELECT * FROM vista_chatbot_requisitos_por_perfil")
  List<Map<String, Object>> vistaRequisitosPerfiles();

  @Query(nativeQuery = true, value = "SELECT * FROM vista_chatbot_perfiles_programa WHERE id_aca_programa = :idPrograma")
  List<Map<String, Object>> vistaPerfilesPrograma(Integer idPrograma);

  @Query(value = "SELECT * FROM fn_obtener_requisitos_programa_chatbot(:idPrograma)", nativeQuery = true)
  List<Map<String, Object>> obtenerRequisitosPrograma(Integer idPrograma);

}

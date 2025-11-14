package uap.edu.bo.cpeyfc.domain.aca_programa_perfil;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaProgramaPerfilRepository extends JpaRepository<AcaProgramaPerfil, Integer> {

  @Query(value = "SELECT * FROM fn_asignar_perfiles_programa(:idPrograma, :perfiles, :userReg)", nativeQuery = true)
  List<Map<String, Object>> asignarPerfiles(Integer idPrograma, Integer[] perfiles, Integer userReg);

  @Query(nativeQuery = true, value = "SELECT * FROM vista_perfiles_por_programa WHERE id_aca_programa = :idPrograma")
  List<Map<String, Object>> vistaPerfilesPorPrograma(Integer idPrograma);

}

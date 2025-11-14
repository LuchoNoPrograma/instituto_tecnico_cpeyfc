package uap.edu.bo.cpeyfc.domain.aca_requisito_perfil;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaRequisitoPerfilRepository extends JpaRepository<AcaRequisitoPerfil, Integer> {

  @Query(value = "SELECT * FROM fn_asignar_requisitos_perfil(:idPerfil, :requisitos, :userReg)", nativeQuery = true)
  List<Map<String, Object>> asignarRequisitos(Integer idPerfil, Integer[] requisitos, Integer userReg);

}

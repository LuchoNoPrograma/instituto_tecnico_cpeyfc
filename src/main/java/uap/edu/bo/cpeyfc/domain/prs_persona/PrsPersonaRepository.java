package uap.edu.bo.cpeyfc.domain.prs_persona;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface PrsPersonaRepository extends JpaRepository<PrsPersona, Integer> {
  @Query(nativeQuery = true, value = "select * from vista_personas_activas")
  List<Map<String, Object>> vistaPersonasActivas();
}
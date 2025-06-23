package uap.edu.bo.cpeyfc.domain.aca_modalidad;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaModalidadRepository extends JpaRepository<AcaModalidad, Integer> {
  @Query(nativeQuery = true, value = "select * from vista_modalidades_activas")
  List<Map<String, Object>> vistaModalidadesActivas();
}
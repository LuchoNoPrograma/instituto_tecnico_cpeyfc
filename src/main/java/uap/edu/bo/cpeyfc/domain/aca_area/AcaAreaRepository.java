package uap.edu.bo.cpeyfc.domain.aca_area;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaAreaRepository extends JpaRepository<AcaArea, Integer> {
  @Query(nativeQuery = true, value = "select * from vista_areas_activas")
  List<Map<String, Object>> vistaAreasActivas();
}
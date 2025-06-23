package uap.edu.bo.cpeyfc.domain.aca_version;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaVersionRepository extends JpaRepository<AcaVersion, Integer> {
  @Query(nativeQuery = true, value = "select * from vista_aca_version_activas")
  List<Map<String, Object>> vistaVersionesActivas();
}
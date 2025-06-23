package uap.edu.bo.cpeyfc.domain.aca_nivel;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaNivelRepository extends JpaRepository<AcaNivel, Integer> {
  @Query(nativeQuery = true, value = "SELECT * FROM vista_niveles_activos")
  List<Map<String, Object>> vistaNivelesActivos();
}
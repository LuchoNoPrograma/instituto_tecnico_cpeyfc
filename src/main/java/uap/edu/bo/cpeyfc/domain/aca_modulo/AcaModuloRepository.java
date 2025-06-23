package uap.edu.bo.cpeyfc.domain.aca_modulo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaModuloRepository extends JpaRepository<AcaModulo, Integer> {
  @Query(nativeQuery = true, value = "SELECT * FROM vista_modulos_activos")
  List<Map<String, Object>> vistaModulosActivos();

  @Query(value = "SELECT fn_registrar_aca_modulo(:nombre_modulo, :user_reg)", nativeQuery = true)
  String registrarModulo(String nombre_modulo, Integer user_reg);
}
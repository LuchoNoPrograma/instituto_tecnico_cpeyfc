package uap.edu.bo.cpeyfc.domain.aca_programa;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaProgramaRepository extends JpaRepository<AcaPrograma, Integer> {
  @Query(nativeQuery = true, value = "select * from vista_aca_programas_activos")
  List<Map<String, Object>> vistaProgramasActivos();

  @Query(value = "SELECT fn_registrar_aca_programa(:id_aca_area, :nombre_programa, :sigla, :user_reg)", nativeQuery = true)
  String registrarPrograma(Integer id_aca_area, String nombre_programa, String sigla, Integer user_reg);
}
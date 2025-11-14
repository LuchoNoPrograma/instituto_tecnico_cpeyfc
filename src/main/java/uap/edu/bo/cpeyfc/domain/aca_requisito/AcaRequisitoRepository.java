package uap.edu.bo.cpeyfc.domain.aca_requisito;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaRequisitoRepository extends JpaRepository<AcaRequisito, Integer> {

  @Query(nativeQuery = true, value = "SELECT * FROM vista_requisitos_activos")
  List<Map<String, Object>> vistaRequisitosActivos();

  @Query(value = "SELECT fn_registrar_requisito(:nombreRequisito, :descripcion, :ordenPresentacion, :userReg)", nativeQuery = true)
  Integer registrarRequisito(String nombreRequisito, String descripcion, Integer ordenPresentacion, Integer userReg);

  @Query(value = "SELECT fn_modificar_requisito(:idRequisito, :nombreRequisito, :descripcion, :ordenPresentacion, :userMod)", nativeQuery = true)
  Boolean modificarRequisito(Integer idRequisito, String nombreRequisito, String descripcion, Integer ordenPresentacion, Integer userMod);

  @Query(value = "SELECT fn_eliminar_requisito(:idRequisito, :userMod)", nativeQuery = true)
  Boolean eliminarRequisito(Integer idRequisito, Integer userMod);

}

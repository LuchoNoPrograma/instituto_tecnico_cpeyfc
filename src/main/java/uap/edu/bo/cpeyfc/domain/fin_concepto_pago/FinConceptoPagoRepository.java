package uap.edu.bo.cpeyfc.domain.fin_concepto_pago;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface FinConceptoPagoRepository extends JpaRepository<FinConceptoPago, Integer> {
  @Query(nativeQuery = true, value = "SELECT * FROM vista_fin_conceptos_pago_activos")
  List<Map<String, Object>> vistaConceptosPagosActivos();

  @Query(value = "SELECT * FROM fn_obtener_conceptos_pago_programa_aprobado(:id_programa_aprobado)", nativeQuery = true)
  List<Map<String, Object>> obtenerConceptosPagoProgramaAprobado(Integer id_programa_aprobado);
}
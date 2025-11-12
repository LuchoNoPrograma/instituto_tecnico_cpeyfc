package uap.edu.bo.cpeyfc.domain.fin_obligacion_pago;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface FinObligacionPagoRepository extends JpaRepository<FinObligacionPago, Integer> {

    // === VISTAS DE ESTADO DE CUENTA ===

    /**
     * Obtiene el estado de cuenta de un estudiante por CI
     */
    @Query(value = "SELECT * FROM vista_estado_cuenta_estudiante WHERE ci = ?1", nativeQuery = true)
    List<Map<String, Object>> vistaEstadoCuentaPorCi(String ci);

}
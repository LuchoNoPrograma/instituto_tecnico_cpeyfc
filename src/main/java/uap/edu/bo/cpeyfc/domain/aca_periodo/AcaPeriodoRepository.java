package uap.edu.bo.cpeyfc.domain.aca_periodo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaPeriodoRepository extends JpaRepository<AcaPeriodo, Integer> {

    // === VISTAS DE PERIODOS ===

    /**
     * Obtiene todas las gestiones con sus periodos
     */
    @Query(value = "SELECT * FROM vista_gestiones_periodos", nativeQuery = true)
    List<Map<String, Object>> vistaGestionesPeriodos();

    /**
     * Obtiene el periodo actual activo
     */
    @Query(value = "SELECT * FROM vista_periodo_actual", nativeQuery = true)
    List<Map<String, Object>> vistaPeriodoActual();

}

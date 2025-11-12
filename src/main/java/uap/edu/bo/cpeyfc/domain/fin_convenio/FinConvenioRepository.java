package uap.edu.bo.cpeyfc.domain.fin_convenio;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface FinConvenioRepository extends JpaRepository<FinConvenio, Integer> {

    // === VISTAS DE CONVENIOS ===

    /**
     * Obtiene todos los convenios con colegios
     */
    @Query(value = "SELECT * FROM vista_convenios_colegios", nativeQuery = true)
    List<Map<String, Object>> vistaConveniosColegios();

    /**
     * Obtiene solo los convenios vigentes
     */
    @Query(value = "SELECT * FROM vista_convenios_colegios WHERE estado_vigencia = 'VIGENTE'", nativeQuery = true)
    List<Map<String, Object>> vistaConveniosVigentes();

}

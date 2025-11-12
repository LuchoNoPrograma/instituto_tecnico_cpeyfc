package uap.edu.bo.cpeyfc.domain.aca_certificacion_programa;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface AcaCertificacionProgramaRepository extends JpaRepository<AcaCertificacionPrograma, Integer> {

    // === FUNCIONES DE CERTIFICACIÓN ===

    /**
     * Valida si un estudiante cumple los requisitos para emitir un certificado
     */
    @Query(value = "SELECT * FROM fn_validar_emision_certificado(?1, ?2)", nativeQuery = true)
    Map<String, Object> validarEmisionCertificado(Integer idPersona, Integer idCertificacionPrograma);

    // === VISTAS DE CERTIFICACIÓN ===

    /**
     * Obtiene todas las certificaciones de programas
     */
    @Query(value = "SELECT * FROM vista_certificaciones_programa", nativeQuery = true)
    List<Map<String, Object>> vistaCertificacionesPrograma();

    /**
     * Obtiene certificaciones filtradas por programa
     */
    @Query(value = "SELECT * FROM vista_certificaciones_programa WHERE nombre_programa = ?1", nativeQuery = true)
    List<Map<String, Object>> vistaCertificacionesPorPrograma(String nombrePrograma);

    /**
     * Obtiene estudiantes aptos para certificación
     */
    @Query(value = "SELECT * FROM vista_estudiantes_aptos_certificacion", nativeQuery = true)
    List<Map<String, Object>> vistaEstudiantesAptosCertificacion();

    /**
     * Obtiene solo estudiantes aptos (filtrados)
     */
    @Query(value = "SELECT * FROM vista_estudiantes_aptos_certificacion WHERE apto_para_certificar = true", nativeQuery = true)
    List<Map<String, Object>> vistaEstudiantesAptos();

}

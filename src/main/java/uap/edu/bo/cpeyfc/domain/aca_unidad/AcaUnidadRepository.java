package uap.edu.bo.cpeyfc.domain.aca_unidad;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

/**
 * Repositorio: AcaUnidadRepository
 * Descripción: Gestión de unidades académicas y administrativas
 */
public interface AcaUnidadRepository extends JpaRepository<AcaUnidad, Integer> {

  /**
   * Vista: Listado de unidades académicas activas con conteo de noticias
   *
   * @return Lista de unidades activas con estadísticas de noticias
   */
  @Query(nativeQuery = true, value = "SELECT * FROM vista_unidades_activas")
  List<Map<String, Object>> vistaUnidadesActivas();

  /**
   * Función: fn_registrar_unidad
   * Registra una nueva unidad académica/administrativa
   *
   * @param p_nombre_unidad Nombre de la unidad
   * @param p_descripcion   Descripción opcional
   * @param p_user_reg      ID del usuario que registra
   * @return Mensaje de confirmación con el ID generado
   */
  @Query(value = """
        SELECT fn_registrar_unidad(
            :p_nombre_unidad,
            :p_descripcion,
            :p_user_reg)
        """, nativeQuery = true)
  String registrarUnidad(String p_nombre_unidad,
                         String p_descripcion,
                         Integer p_user_reg);
}

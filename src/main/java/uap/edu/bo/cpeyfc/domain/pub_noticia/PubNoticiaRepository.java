package uap.edu.bo.cpeyfc.domain.pub_noticia;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * Repositorio: PubNoticiaRepository
 * Descripción: Gestión de noticias institucionales para carrusel web
 */
public interface PubNoticiaRepository extends JpaRepository<PubNoticia, Integer> {

  /**
   * Vista: Listado completo de noticias activas para administración
   * Noticias ordenadas por prioridad y fecha
   *
   * @return Lista de noticias activas con información completa
   */
  @Query(nativeQuery = true, value = "SELECT * FROM vista_noticias_activas")
  List<Map<String, Object>> vistaNoticiasActivas();

  /**
   * Vista: Top 10 noticias optimizadas para carrusel web público
   * Noticias destacadas primero, luego por prioridad y fecha
   *
   * @return Lista de las últimas 10 noticias para mostrar en carrusel
   */
  @Query(nativeQuery = true, value = "SELECT * FROM vista_noticias_carrusel")
  List<Map<String, Object>> vistaNoticiasCarrusel();

  /**
   * Obtiene una noticia específica por su ID para vista pública
   *
   * @param p_id_pub_noticia ID de la noticia a consultar
   * @return Map con los datos de la noticia
   */
  @Query(nativeQuery = true, value = "SELECT * FROM vista_noticias_activas WHERE id_pub_noticia = ?1")
  Map<String, Object> obtenerNoticiaPorId(Integer p_id_pub_noticia);

  /**
   * Función: fn_registrar_noticia
   * Registra una nueva noticia institucional
   *
   * @param p_id_aca_unidad     ID de la unidad que publica
   * @param p_titulo            Título de la noticia
   * @param p_contenido         Contenido HTML de la noticia
   * @param p_imagen_uri        URI de la imagen de portada (opcional)
   * @param p_enlace_externo    URL externa (opcional)
   * @param p_fecha_noticia     Fecha de publicación
   * @param p_es_destacada      Si debe destacarse en el carrusel
   * @param p_orden_prioridad   Orden de prioridad (mayor = más prioritario)
   * @param p_user_reg          ID del usuario que registra
   * @return ID de la noticia creada
   */
  @Query(value = """
        SELECT fn_registrar_noticia(
            :p_id_aca_unidad,
            :p_titulo,
            :p_contenido,
            :p_imagen_uri,
            :p_enlace_externo,
            :p_fecha_noticia,
            :p_es_destacada,
            :p_orden_prioridad,
            :p_user_reg)
        """, nativeQuery = true)
  Integer registrarNoticia(Integer p_id_aca_unidad,
                           String p_titulo,
                           String p_contenido,
                           String p_imagen_uri,
                           String p_enlace_externo,
                           LocalDate p_fecha_noticia,
                           Boolean p_es_destacada,
                           Integer p_orden_prioridad,
                           Integer p_user_reg);

  @Query(nativeQuery = true, value = """
      SELECT * FROM fn_obtener_noticias_paginadas(:page, :size, :busqueda, :estado, :id_unidad)
      """)
  List<Map<String, Object>> obtenerNoticiasPaginadas(
    Integer page,
    Integer size,
    String busqueda,
    String estado,
    Integer id_unidad
  );

  /**
   * Función: fn_actualizar_noticia
   * Actualiza los datos de una noticia existente
   *
   * @param p_id_pub_noticia    ID de la noticia a actualizar
   * @param p_id_aca_unidad     ID de la unidad que publica
   * @param p_titulo            Título de la noticia
   * @param p_contenido         Contenido HTML de la noticia
   * @param p_imagen_uri        URI de la imagen de portada (opcional)
   * @param p_enlace_externo    URL externa (opcional)
   * @param p_fecha_noticia     Fecha de publicación
   * @param p_es_destacada      Si debe destacarse en el carrusel
   * @param p_orden_prioridad   Orden de prioridad (mayor = más prioritario)
   * @param p_user_mod          ID del usuario que modifica
   * @return Mensaje de confirmación
   */
  @Query(value = """
        SELECT fn_actualizar_noticia(
            :p_id_pub_noticia,
            :p_id_aca_unidad,
            :p_titulo,
            :p_contenido,
            :p_imagen_uri,
            :p_enlace_externo,
            :p_fecha_noticia,
            :p_es_destacada,
            :p_orden_prioridad,
            :p_user_mod)
        """, nativeQuery = true)
  String actualizarNoticia(Integer p_id_pub_noticia,
                           Integer p_id_aca_unidad,
                           String p_titulo,
                           String p_contenido,
                           String p_imagen_uri,
                           String p_enlace_externo,
                           LocalDate p_fecha_noticia,
                           Boolean p_es_destacada,
                           Integer p_orden_prioridad,
                           Integer p_user_mod);

  /**
   * Función: fn_cambiar_estado_noticia
   * Cambia el estado de una noticia (ACTIVO/INACTIVO/ELIMINADO)
   *
   * @param p_id_pub_noticia ID de la noticia
   * @param p_nuevo_estado   Nuevo estado (ACTIVO, INACTIVO, ELIMINADO)
   * @param p_user_mod       ID del usuario que modifica
   * @return Mensaje de confirmación
   */
  @Query(value = """
        SELECT fn_cambiar_estado_noticia(
            :p_id_pub_noticia,
            :p_nuevo_estado,
            :p_user_mod)
        """, nativeQuery = true)
  String cambiarEstadoNoticia(Integer p_id_pub_noticia,
                              String p_nuevo_estado,
                              Integer p_user_mod);
}

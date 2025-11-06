package uap.edu.bo.cpeyfc.domain.pub_noticia;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * Service: PubNoticiaService
 * Descripción: Servicio para gestión de noticias institucionales del carrusel web
 */
@Service
@RequiredArgsConstructor
public class PubNoticiaService {

  private final RepositorioGenericoCrud repositorio;
  private final PubNoticiaRepository pubNoticiaRepository;

  /**
   * Obtiene listado completo de noticias activas para administración
   *
   * @return Lista de noticias activas ordenadas por prioridad y fecha
   */
  public List<Map<String, Object>> vistaNoticiasActivas() {
    return pubNoticiaRepository.vistaNoticiasActivas();
  }

  /**
   * Obtiene las últimas 10 noticias para el carrusel web público
   *
   * @return Top 10 noticias destacadas para carrusel
   */
  public List<Map<String, Object>> vistaNoticiasCarrusel() {
    return pubNoticiaRepository.vistaNoticiasCarrusel();
  }

  /**
   * Registra una nueva noticia institucional
   *
   * @param idAcaUnidad     ID de la unidad que publica
   * @param titulo          Título de la noticia
   * @param resumen         Resumen o descripción breve
   * @param imagenUri       URI de la imagen de portada (opcional)
   * @param enlaceExterno   URL externa (opcional)
   * @param fechaNoticia    Fecha de publicación
   * @param esDestacada     Si debe destacarse en el carrusel
   * @param ordenPrioridad  Orden de prioridad
   * @param userReg         ID del usuario que registra
   * @return ID de la noticia creada
   */
  public Integer registrarNoticia(Integer idAcaUnidad,
                                  String titulo,
                                  String resumen,
                                  String imagenUri,
                                  String enlaceExterno,
                                  LocalDate fechaNoticia,
                                  Boolean esDestacada,
                                  Integer ordenPrioridad,
                                  Integer userReg) {
    return pubNoticiaRepository.registrarNoticia(
        idAcaUnidad,
        titulo,
        resumen,
        imagenUri,
        enlaceExterno,
        fechaNoticia,
        esDestacada,
        ordenPrioridad,
        userReg
    );
  }

  /**
   * Actualiza los datos de una noticia existente
   *
   * @param idPubNoticia    ID de la noticia a actualizar
   * @param idAcaUnidad     ID de la unidad que publica
   * @param titulo          Título de la noticia
   * @param resumen         Resumen o descripción breve
   * @param imagenUri       URI de la imagen de portada (opcional)
   * @param enlaceExterno   URL externa (opcional)
   * @param fechaNoticia    Fecha de publicación
   * @param esDestacada     Si debe destacarse en el carrusel
   * @param ordenPrioridad  Orden de prioridad
   * @param userMod         ID del usuario que modifica
   * @return Mensaje de confirmación
   */
  public String actualizarNoticia(Integer idPubNoticia,
                                  Integer idAcaUnidad,
                                  String titulo,
                                  String resumen,
                                  String imagenUri,
                                  String enlaceExterno,
                                  LocalDate fechaNoticia,
                                  Boolean esDestacada,
                                  Integer ordenPrioridad,
                                  Integer userMod) {
    return pubNoticiaRepository.actualizarNoticia(
        idPubNoticia,
        idAcaUnidad,
        titulo,
        resumen,
        imagenUri,
        enlaceExterno,
        fechaNoticia,
        esDestacada,
        ordenPrioridad,
        userMod
    );
  }

  /**
   * Cambia el estado de una noticia (ACTIVO/INACTIVO/ELIMINADO)
   *
   * @param idPubNoticia ID de la noticia
   * @param nuevoEstado  Nuevo estado (ACTIVO, INACTIVO, ELIMINADO)
   * @param userMod      ID del usuario que modifica
   * @return Mensaje de confirmación
   */
  public String cambiarEstadoNoticia(Integer idPubNoticia,
                                     String nuevoEstado,
                                     Integer userMod) {
    return pubNoticiaRepository.cambiarEstadoNoticia(
        idPubNoticia,
        nuevoEstado,
        userMod
    );
  }
}

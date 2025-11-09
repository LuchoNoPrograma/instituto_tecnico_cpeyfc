package uap.edu.bo.cpeyfc.domain.pub_noticia;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import uap.edu.bo.cpeyfc.domain.archivo.ArchivoService;


import java.io.IOException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PubNoticiaService {
  private final PubNoticiaRepository pubNoticiaRepository;
  private final ArchivoService archivoService;

  public List<Map<String, Object>> vistaNoticiasActivas() {
    return pubNoticiaRepository.vistaNoticiasActivas();
  }

  public List<Map<String, Object>> vistaNoticiasCarrusel() {
    List<Map<String, Object>> resultados = pubNoticiaRepository.vistaNoticiasCarrusel();

    return resultados.stream()
      .map(noticia -> {
        Map<String, Object> noticiaConUrl = new HashMap<>(noticia);
        String imagenUri = (String) noticia.get("imagen_uri");
        if (imagenUri != null && !imagenUri.isEmpty()) {
          noticiaConUrl.put("imagen_url", "/api" + imagenUri);
        }
        return noticiaConUrl;
      })
      .toList();
  }

  public Map<String, Object> obtenerNoticiasPaginadas(Integer page,
                                                      Integer size,
                                                      String busqueda,
                                                      String estado,
                                                      Integer idUnidad) {
    List<Map<String, Object>> resultados = pubNoticiaRepository.obtenerNoticiasPaginadas(
      page, size, busqueda, estado, idUnidad
    );

    // Convertir a Maps mutables y agregar imagen_url
    List<Map<String, Object>> noticiasConUrl = resultados.stream()
      .map(noticia -> {
        Map<String, Object> noticiaConUrl = new HashMap<>(noticia);
        String imagenUri = (String) noticia.get("imagen_uri");
        if (imagenUri != null && !imagenUri.isEmpty()) {
          noticiaConUrl.put("imagen_url", "/api" + imagenUri);
        }
        return noticiaConUrl;
      })
      .toList();

    Long totalRegistros = noticiasConUrl.isEmpty() ? 0L :
      ((Number) noticiasConUrl.get(0).get("total_registros")).longValue();

    int totalPages = (int) Math.ceil((double) totalRegistros / size);

    Map<String, Object> respuesta = new HashMap<>();
    respuesta.put("data", noticiasConUrl);
    respuesta.put("pagination", Map.of(
      "page", page,
      "size", size,
      "total", totalRegistros,
      "total_pages", totalPages,
      "has_next", page < totalPages,
      "has_previous", page > 1
    ));

    return respuesta;
  }


  public Integer registrarNoticia(MultipartFile imagen,
                                  Integer idAcaUnidad,
                                  String titulo,
                                  String resumen,
                                  String enlaceExterno,
                                  LocalDate fechaNoticia,
                                  Boolean esDestacada,
                                  Integer ordenPrioridad,
                                  Integer userReg) throws IOException {

    String imagenUri = archivoService.guardarArchivo(imagen, "images/noticias");

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

  public String actualizarNoticia(MultipartFile imagenNueva,
                                  Integer idPubNoticia,
                                  Integer idAcaUnidad,
                                  String titulo,
                                  String resumen,
                                  String imagenUriAntigua,
                                  String enlaceExterno,
                                  LocalDate fechaNoticia,
                                  Boolean esDestacada,
                                  Integer ordenPrioridad,
                                  Integer userMod) throws IOException {

    String imagenUri = imagenUriAntigua;

    if (imagenNueva != null && !imagenNueva.isEmpty()) {
      imagenUri = archivoService.guardarArchivo(imagenNueva, "images/noticias");
      archivoService.eliminarArchivo(imagenUriAntigua);
    }

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
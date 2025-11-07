package uap.edu.bo.cpeyfc.domain.aca_unidad;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import uap.edu.bo.cpeyfc.crud.RepositorioGenericoCrud;

import java.util.List;
import java.util.Map;

/**
 * Service: AcaUnidadService
 * Descripción: Servicio para gestión de unidades académicas y administrativas
 */
@Service
@RequiredArgsConstructor
public class AcaUnidadService {

  private final RepositorioGenericoCrud repositorio;
  private final AcaUnidadRepository acaUnidadRepository;

  /**
   * Obtiene listado de unidades académicas activas con conteo de noticias
   *
   * @return Lista de unidades activas con estadísticas
   */
  public List<Map<String, Object>> vistaUnidadesActivas() {
    return acaUnidadRepository.vistaUnidadesActivas();
  }

  /**
   * Registra una nueva unidad académica/administrativa
   *
   * @param nombreUnidad Nombre de la unidad
   * @param descripcion  Descripción opcional
   * @param userReg      ID del usuario que registra
   * @return Mensaje de confirmación con ID generado
   */
  public String registrarUnidad(String nombreUnidad, String descripcion, Integer userReg) {
    return acaUnidadRepository.registrarUnidad(nombreUnidad, descripcion, userReg);
  }
}

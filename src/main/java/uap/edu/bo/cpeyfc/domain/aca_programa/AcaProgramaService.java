package uap.edu.bo.cpeyfc.domain.aca_programa;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import uap.edu.bo.cpeyfc.domain.aca_programa_habilidad.AcaProgramaHabilidadRepository;
import uap.edu.bo.cpeyfc.domain.aca_programa_perfil.AcaProgramaPerfilRepository;
import uap.edu.bo.cpeyfc.domain.archivo.ArchivoService;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AcaProgramaService {
  private final AcaProgramaRepository acaProgramaRepository;
  private final AcaProgramaHabilidadRepository acaProgramaHabilidadRepository;
  private final AcaProgramaPerfilRepository acaProgramaPerfilRepository;
  private final ArchivoService archivoService;

  // ========== MÉTODO ANTIGUO (mantener compatibilidad) ==========
  public List<Map<String, Object>> vistaProgramasActivos() {
    return acaProgramaRepository.vistaProgramasActivos();
  }

  // ========== MÉTODOS NUEVOS ==========
  public List<Map<String, Object>> vistaProgramasConHabilidades() {
    return acaProgramaRepository.vistaProgramasConHabilidades();
  }

  @Transactional(rollbackFor = Exception.class)
  public Integer registrarPrograma(
    MultipartFile file,
    Integer id_aca_area,
    String nombre_programa,
    String sigla,
    String objetivo,
    String[] habilidades,
    Integer[] perfiles,
    Integer user_reg) throws IOException {

    String imagenUrl = null;
    if (file != null && !file.isEmpty()) {
      imagenUrl = archivoService.guardarArchivo(file, "images/programas");
    }

    Integer idPrograma = acaProgramaRepository.registrarPrograma(
      id_aca_area,
      nombre_programa,
      sigla,
      objetivo,
      imagenUrl,
      user_reg
    );

    // Asignar habilidades si existen
    if (habilidades != null && habilidades.length > 0) {
      acaProgramaHabilidadRepository.asignarHabilidadesPrograma(
        idPrograma,
        habilidades,
        user_reg
      );
    }

    // Asignar perfiles elegibles si existen
    if (perfiles != null && perfiles.length > 0) {
      acaProgramaPerfilRepository.asignarPerfiles(
        idPrograma,
        perfiles,
        user_reg
      );
    }

    return idPrograma;
  }

  @Transactional(rollbackFor = Exception.class)
  public String modificarPrograma(
    MultipartFile file,
    Integer id_aca_programa,
    Integer id_aca_area,
    String nombre_programa,
    String sigla,
    String objetivo,
    String imagen_url_antigua,
    String[] habilidades,
    Integer[] perfiles,
    Integer user_mod) throws IOException {

    String imagenUrl = imagen_url_antigua;

    if (file != null && !file.isEmpty()) {
      // Borrar imagen anterior si existe
      if (imagen_url_antigua != null && !imagen_url_antigua.isEmpty()) {
        archivoService.eliminarArchivo(imagen_url_antigua);
      }
      imagenUrl = archivoService.guardarArchivo(file, "images/programas");
    }

    String resultado = acaProgramaRepository.modificarPrograma(
      id_aca_programa,
      id_aca_area,
      nombre_programa,
      sigla,
      objetivo,
      imagenUrl,
      user_mod
    );

    // Actualizar habilidades: asignar nuevas (la función maneja duplicados)
    if (habilidades != null && habilidades.length > 0) {
      acaProgramaHabilidadRepository.asignarHabilidadesPrograma(
        id_aca_programa,
        habilidades,
        user_mod
      );
    }

    // Actualizar perfiles elegibles
    if (perfiles != null && perfiles.length > 0) {
      acaProgramaPerfilRepository.asignarPerfiles(
        id_aca_programa,
        perfiles,
        user_mod
      );
    }

    return resultado;
  }
}
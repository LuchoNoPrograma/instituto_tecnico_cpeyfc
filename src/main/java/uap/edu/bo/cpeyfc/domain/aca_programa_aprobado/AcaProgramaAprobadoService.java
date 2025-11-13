package uap.edu.bo.cpeyfc.domain.aca_programa_aprobado;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import uap.edu.bo.cpeyfc.domain.archivo.ArchivoService;

import java.io.IOException;
import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class AcaProgramaAprobadoService {
  private final AcaProgramaAprobadoRepository acaProgramaAprobadoRepository;
  private final ArchivoService archivoService;

  public Integer registrarProgramaAprobado(
    MultipartFile file,
    Integer id_aca_programa,
    Integer id_aca_modalidad,
    Integer gestion,
    Integer id_aca_plan_estudio,
    Integer id_aca_version,
    String estado_programa_aprobado,
    String cod_certificado_ceub,
    LocalDate fecha_inicio_vigencia,
    LocalDate fecha_fin_vigencia,
    Integer user_reg) throws IOException {

    String imagenUrl = null;
    if (file != null && !file.isEmpty()) {
      imagenUrl = archivoService.guardarArchivo(file, "images/programas");
    }

    return acaProgramaAprobadoRepository.registrarProgramaAprobado(
      id_aca_programa,
      id_aca_modalidad,
      gestion,
      id_aca_plan_estudio,
      id_aca_version,
      estado_programa_aprobado,
      cod_certificado_ceub,
      imagenUrl,
      fecha_inicio_vigencia,
      fecha_fin_vigencia,
      user_reg
    );
  }

  public String modificarProgramaAprobado(
    MultipartFile file,
    Integer id_aca_programa_aprobado,
    Integer id_aca_plan_estudio,
    Integer id_aca_version,
    String estado_programa_aprobado,
    String cod_certificado_ceub,
    String imagen_uri_antigua,
    LocalDate fecha_inicio_vigencia,
    LocalDate fecha_fin_vigencia,
    Integer user_mod) throws IOException {

    String imagenUrl = imagen_uri_antigua;

    if (file != null && !file.isEmpty()) {
      // Borrar imagen anterior si existe
      if (imagen_uri_antigua != null && !imagen_uri_antigua.isEmpty()) {
        archivoService.eliminarArchivo(imagen_uri_antigua);
      }
      imagenUrl = archivoService.guardarArchivo(file, "images/programas");
    }

    return acaProgramaAprobadoRepository.modificarProgramaAprobado(
      id_aca_programa_aprobado,
      id_aca_plan_estudio,
      id_aca_version,
      estado_programa_aprobado,
      cod_certificado_ceub,
      imagenUrl,
      fecha_inicio_vigencia,
      fecha_fin_vigencia,
      user_mod
    );
  }
}
package uap.edu.bo.cpeyfc.domain.ins_grupo;

import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;
import uap.edu.bo.cpeyfc.service.VistasAcademicasService;
import uap.edu.bo.cpeyfc.util.FechaUtil;

import java.io.IOException;
import java.nio.file.Files;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class InsGrupoApi {
  private final InsGrupoRepository insGrupoRepository;
  private final VistasAcademicasService vistasAcademicasService;

  @GetMapping("/api/grupos/vista/grupos-completos")
  public ResponseEntity<List<Map<String, Object>>> obtenerGruposCompletos(
          @RequestParam(required = false) Integer idProgramaAprobado,
          @RequestParam(required = false) Integer idGrupo) {

    List<Map<String, Object>> grupos;

    if (idGrupo != null) {
      grupos = insGrupoRepository.vistaGruposCompletosPorIdGrupo(idGrupo);
    } else if (idProgramaAprobado != null) {
      grupos = insGrupoRepository.vistaGruposCompletosPorIdProgramaAprobado(idProgramaAprobado);
    } else {
      grupos = insGrupoRepository.vistaGruposCompletos();
    }

    return ResponseEntity.ok(grupos);
  }

  @GetMapping("/api/grupos/vista/grupos-cronogramas")
  public ResponseEntity<?> vistaGruposCronogramas(@RequestParam(required = false) Integer programa) {
    if (programa != null) {
      return ResponseEntity.ok(insGrupoRepository.vistaGruposConCronogramasPorIdPrograma(programa));
    } else {
      return ResponseEntity.ok(insGrupoRepository.vistaGruposConCronogramas());
    }
  }

  @GetMapping("/api/grupos/estadisticas")
  public ResponseEntity<Map<String, Object>> obtenerEstadisticasGrupos() {
    Map<String, Object> estadisticas = insGrupoRepository.obtenerEstadisticasGrupos();
    return ResponseEntity.ok(estadisticas);
  }

  @GetMapping("/api/grupos/{id}/estudiantes")
  public ResponseEntity<List<Map<String, Object>>> obtenerEstudiantesPorGrupo(@PathVariable Integer id) {
    List<Map<String, Object>> estudiantes = insGrupoRepository.obtenerEstudiantesPorGrupo(id);
    return ResponseEntity.ok(estudiantes);
  }

  @GetMapping("/api/grupo/activo-por-programa/{idProgramaAprobado}")
  public ResponseEntity<?> obtenerGruposActivosPorProgramaAprobado(@PathVariable Long idProgramaAprobado){
    return ResponseEntity.ok(insGrupoRepository.vistaGruposActivosPorProgramaAprobado(idProgramaAprobado));
  }

  @PostMapping("/api/grupos")
  public ResponseEntity<String> registrarGrupo(
    @RequestBody Map<String, Object> datos,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = insGrupoRepository.registrarGrupo(
      (Integer) datos.get("id_aca_programa_aprobado"),
      (String) datos.get("nombre_grupo"),
      FechaUtil.toLocalDate(datos.get("fecha_inicio_inscripcion")),
      FechaUtil.toLocalDate(datos.get("fecha_fin_inscripcion")),
      (Integer) datos.get("gestion_inicio"),
      userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(resultado);
  }

  @PutMapping("/api/grupos")
  public ResponseEntity<String> modificarGrupo(
    @RequestBody Map<String, Object> datos,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    String resultado = insGrupoRepository.modificarGrupo(
      (Integer) datos.get("id_ins_grupo"),
      (String) datos.get("nombre_grupo"),
      FechaUtil.toLocalDate(datos.get("fecha_inicio_inscripcion")),
      FechaUtil.toLocalDate(datos.get("fecha_fin_inscripcion")),
      (String) datos.get("estado_grupo"),
      userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(resultado);
  }

  @GetMapping("/api/publico/programas-ofertados")
  public ResponseEntity<?> vistaProgramasPublicos(){
    return ResponseEntity.ok(insGrupoRepository.vistaProgramasOfertadosAPublico());
  }

  @GetMapping("/api/publico/programas/{nombreImagen}/imagen")
  public ResponseEntity<byte[]> obtenerImagenPrograma(@PathVariable String nombreImagen) {
    try {
      // Buscar la imagen en el directorio de recursos
      Resource resource = new ClassPathResource("static/images/ofertas/" + nombreImagen);

      if (!resource.exists()) {
        return ResponseEntity.notFound().build();
      }

      // Leer los bytes de la imagen
      byte[] imageBytes = Files.readAllBytes(resource.getFile().toPath());

      // Determinar el tipo de contenido basado en la extensión del archivo
      String contentType = Files.probeContentType(resource.getFile().toPath());
      if (contentType == null) {
        contentType = MediaType.APPLICATION_OCTET_STREAM_VALUE;
      }

      // Configurar headers
      HttpHeaders headers = new HttpHeaders();
      headers.setContentType(MediaType.parseMediaType(contentType));
      headers.setContentLength(imageBytes.length);

      return new ResponseEntity<>(imageBytes, headers, HttpStatus.OK);
    } catch (IOException e) {
      return ResponseEntity.notFound().build();
    }
  }

  @GetMapping("/api/grupo/vista/estudiantes-grupo")
  public ResponseEntity<?> obtenerVistaEstudiantesGrupo() {
    return ResponseEntity.ok(vistasAcademicasService.obtenerEstudiantesGrupo());
  }

  @GetMapping("/api/grupo/vista/estudiantes-grupo/{idGrupo}")
  public ResponseEntity<?> obtenerVistaEstudiantesPorGrupo(@PathVariable Integer idGrupo) {
    return ResponseEntity.ok(vistasAcademicasService.obtenerEstudiantesPorGrupo(idGrupo));
  }
}
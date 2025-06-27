package uap.edu.bo.cpeyfc.domain.ins_grupo;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;
import uap.edu.bo.cpeyfc.util.FechaUtil;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class InsGrupoApi {
  private final InsGrupoRepository insGrupoRepository;

  @GetMapping("/api/grupos/vista/grupos-completos")
  public ResponseEntity<List<Map<String, Object>>> obtenerGruposCompletos(
    @RequestParam(required = false) Integer idProgramaAprobado) {

    List<Map<String, Object>> grupos;

    if (idProgramaAprobado != null) {
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
}
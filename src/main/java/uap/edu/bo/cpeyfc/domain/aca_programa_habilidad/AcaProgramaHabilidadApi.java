package uap.edu.bo.cpeyfc.domain.aca_programa_habilidad;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AcaProgramaHabilidadApi {
  private final AcaProgramaHabilidadService acaProgramaHabilidadService;

  @GetMapping("/api/programa-habilidad/programa/{idPrograma}")
  public ResponseEntity<?> listarHabilidadesPorPrograma(@PathVariable Integer idPrograma) {
    return ResponseEntity.ok(acaProgramaHabilidadService.listarHabilidadesPorPrograma(idPrograma));
  }

  @GetMapping("/api/programa-habilidad/programa/{idPrograma}")
  public ResponseEntity<?> listarHabilidadesPorProgramaPublico(@PathVariable Integer idPrograma) {
    return ResponseEntity.ok(acaProgramaHabilidadService.listarHabilidadesPorPrograma(idPrograma));
  }

  @PostMapping("/api/programa-habilidad")
  public ResponseEntity<?> registrarHabilidad(
      @RequestBody Map<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    Integer idHabilidad = acaProgramaHabilidadService.registrarHabilidadPrograma(
        (Integer) datos.get("id_aca_programa"),
        (String) datos.get("nombre_habilidad"),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
        "success", true,
        "message", "Habilidad registrada exitosamente",
        "id_programa_habilidad", idHabilidad
    ));
  }

  @PutMapping("/api/programa-habilidad/{id}")
  public ResponseEntity<?> modificarHabilidad(
      @PathVariable Integer id,
      @RequestBody Map<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    String resultado = acaProgramaHabilidadService.modificarHabilidadPrograma(
        id,
        (String) datos.get("nombre_habilidad"),
        (String) datos.get("estado_programa_habilidad"),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
        "success", true,
        "message", resultado
    ));
  }

  @DeleteMapping("/api/programa-habilidad/{id}")
  public ResponseEntity<?> eliminarHabilidad(
      @PathVariable Integer id,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    String resultado = acaProgramaHabilidadService.eliminarHabilidadPrograma(
        id,
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
        "success", true,
        "message", resultado
    ));
  }

  @PostMapping("/api/programa-habilidad/asignar-multiple")
  public ResponseEntity<?> asignarHabilidadesMultiples(
      @RequestBody Map<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    // Convertir lista a array
    java.util.List<String> habilidadesList = (java.util.List<String>) datos.get("habilidades");
    String[] habilidades = habilidadesList.toArray(new String[0]);

    acaProgramaHabilidadService.asignarHabilidadesPrograma(
        (Integer) datos.get("id_aca_programa"),
        habilidades,
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
        "success", true,
        "message", "Habilidades asignadas exitosamente"
    ));
  }
}
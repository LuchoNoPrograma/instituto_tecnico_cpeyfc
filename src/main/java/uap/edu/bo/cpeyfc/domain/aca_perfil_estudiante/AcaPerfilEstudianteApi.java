package uap.edu.bo.cpeyfc.domain.aca_perfil_estudiante;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AcaPerfilEstudianteApi {

  private final AcaPerfilEstudianteService acaPerfilService;

  @GetMapping("/api/perfiles-estudiante")
  public ResponseEntity<?> listarPerfiles() {
    List<Map<String, Object>> perfiles = acaPerfilService.listarPerfilesActivos();
    return ResponseEntity.ok(perfiles);
  }

  @PostMapping("/api/perfil-estudiante")
  public ResponseEntity<?> registrarPerfil(
    @RequestBody Map<String, Object> datos,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    Integer idPerfil = acaPerfilService.registrarPerfil(
      (String) datos.get("nombre_perfil"),
      (String) datos.get("descripcion"),
      userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
      "success", true,
      "message", "Perfil registrado exitosamente",
      "id_perfil", idPerfil
    ));
  }

  @PutMapping("/api/perfil-estudiante/{id}")
  public ResponseEntity<?> modificarPerfil(
    @PathVariable Integer id,
    @RequestBody Map<String, Object> datos,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    Boolean resultado = acaPerfilService.modificarPerfil(
      id,
      (String) datos.get("nombre_perfil"),
      (String) datos.get("descripcion"),
      userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
      "success", resultado,
      "message", resultado ? "Perfil modificado exitosamente" : "No se pudo modificar el perfil"
    ));
  }

  @DeleteMapping("/api/perfil-estudiante/{id}")
  public ResponseEntity<?> eliminarPerfil(
    @PathVariable Integer id,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    Boolean resultado = acaPerfilService.eliminarPerfil(id, userDetails.getIdSegUsuario());

    return ResponseEntity.ok(Map.of(
      "success", resultado,
      "message", resultado ? "Perfil eliminado exitosamente" : "No se pudo eliminar el perfil"
    ));
  }

  @PostMapping("/api/perfil-estudiante/{id}/requisitos")
  public ResponseEntity<?> asignarRequisitos(
    @PathVariable Integer id,
    @RequestBody Map<String, Object> datos,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    List<Integer> requisitosList = (List<Integer>) datos.get("requisitos");
    Integer[] requisitos = requisitosList.toArray(new Integer[0]);

    List<Map<String, Object>> resultado = acaPerfilService.asignarRequisitos(
      id,
      requisitos,
      userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
      "success", true,
      "message", "Requisitos asignados exitosamente",
      "asignaciones", resultado
    ));
  }

  @GetMapping("/api/perfil-estudiante/{id}/requisitos")
  public ResponseEntity<?> obtenerRequisitosAsignados(@PathVariable Integer id) {
    List<Map<String, Object>> requisitos = acaPerfilService.obtenerRequisitosAsignados(id);
    return ResponseEntity.ok(requisitos);
  }
}

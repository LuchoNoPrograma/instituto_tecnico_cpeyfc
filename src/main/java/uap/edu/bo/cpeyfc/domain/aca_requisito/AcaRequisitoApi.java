package uap.edu.bo.cpeyfc.domain.aca_requisito;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AcaRequisitoApi {

  private final AcaRequisitoService acaRequisitoService;

  @GetMapping("/api/requisitos")
  public ResponseEntity<?> listarRequisitos() {
    List<Map<String, Object>> requisitos = acaRequisitoService.listarRequisitosActivos();
    return ResponseEntity.ok(requisitos);
  }

  @PostMapping("/api/requisito")
  public ResponseEntity<?> registrarRequisito(
    @RequestBody Map<String, Object> datos,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    Integer idRequisito = acaRequisitoService.registrarRequisito(
      (String) datos.get("nombre_requisito"),
      (String) datos.get("descripcion"),
      (Integer) datos.get("orden_presentacion"),
      userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
      "success", true,
      "message", "Requisito registrado exitosamente",
      "id_requisito", idRequisito
    ));
  }

  @PutMapping("/api/requisito/{id}")
  public ResponseEntity<?> modificarRequisito(
    @PathVariable Integer id,
    @RequestBody Map<String, Object> datos,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    Boolean resultado = acaRequisitoService.modificarRequisito(
      id,
      (String) datos.get("nombre_requisito"),
      (String) datos.get("descripcion"),
      (Integer) datos.get("orden_presentacion"),
      userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
      "success", resultado,
      "message", resultado ? "Requisito modificado exitosamente" : "No se pudo modificar el requisito"
    ));
  }

  @DeleteMapping("/api/requisito/{id}")
  public ResponseEntity<?> eliminarRequisito(
    @PathVariable Integer id,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    Boolean resultado = acaRequisitoService.eliminarRequisito(id, userDetails.getIdSegUsuario());

    return ResponseEntity.ok(Map.of(
      "success", resultado,
      "message", resultado ? "Requisito eliminado exitosamente" : "No se pudo eliminar el requisito"
    ));
  }
}

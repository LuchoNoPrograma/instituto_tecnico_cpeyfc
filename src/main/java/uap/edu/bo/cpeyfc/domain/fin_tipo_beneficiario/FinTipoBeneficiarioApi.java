package uap.edu.bo.cpeyfc.domain.fin_tipo_beneficiario;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.Map;

@RestController
@RequiredArgsConstructor
public class FinTipoBeneficiarioApi {

  private final FinTipoBeneficiarioRepository finTipoBeneficiarioRepository;

  @GetMapping("/api/tipos-beneficiario/activos")
  public ResponseEntity<?> obtenerTiposBeneficiarioActivos() {
    return ResponseEntity.ok(finTipoBeneficiarioRepository.obtenerTiposBeneficiarioActivos());
  }

  @PostMapping("/api/tipo-beneficiario")
  public ResponseEntity<?> registrarTipoBeneficiario(
      @RequestBody Map<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    Integer idTipoBeneficiario = finTipoBeneficiarioRepository.registrarTipoBeneficiario(
        (String) datos.get("nombre_tipo"),
        (String) datos.get("descripcion"),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
        "id_tipo_beneficiario", idTipoBeneficiario,
        "mensaje", "Tipo de beneficiario registrado exitosamente"
    ));
  }

  @PutMapping("/api/tipo-beneficiario/{idTipoBeneficiario}")
  public ResponseEntity<?> modificarTipoBeneficiario(
      @PathVariable Integer idTipoBeneficiario,
      @RequestBody Map<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    String mensaje = finTipoBeneficiarioRepository.modificarTipoBeneficiario(
        idTipoBeneficiario,
        (String) datos.get("nombre_tipo"),
        (String) datos.get("descripcion"),
        (String) datos.get("estado_tipo_beneficiario"),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of("mensaje", mensaje));
  }

  @DeleteMapping("/api/tipo-beneficiario/{idTipoBeneficiario}")
  public ResponseEntity<?> eliminarTipoBeneficiario(
      @PathVariable Integer idTipoBeneficiario,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    String mensaje = finTipoBeneficiarioRepository.eliminarTipoBeneficiario(
        idTipoBeneficiario,
        userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(Map.of("mensaje", mensaje));
  }
}
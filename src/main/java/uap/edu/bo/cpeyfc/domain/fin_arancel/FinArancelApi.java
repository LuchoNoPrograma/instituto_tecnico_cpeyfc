package uap.edu.bo.cpeyfc.domain.fin_arancel;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;
import uap.edu.bo.cpeyfc.util.FechaUtil;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class FinArancelApi {

  private final FinArancelService finArancelService;

  @GetMapping("/api/aranceles/vigentes")
  public ResponseEntity<?> obtenerArancelesVigentes() {
    return ResponseEntity.ok(finArancelService.obtenerArancelesVigentes());
  }

  @GetMapping("/api/aranceles/programa/{idPrograma}")
  public ResponseEntity<?> obtenerArancelesPrograma(@PathVariable Integer idPrograma) {
    return ResponseEntity.ok(finArancelService.obtenerArancelesPrograma(idPrograma));
  }

  @GetMapping("/api/tipos-beneficiario")
  public ResponseEntity<?> obtenerTiposBeneficiario() {
    return ResponseEntity.ok(finArancelService.obtenerTiposBeneficiario());
  }

  @PostMapping("/api/arancel")
  public ResponseEntity<?> registrarArancel(
      @RequestBody Map<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    Integer idArancel = finArancelService.registrarArancel(
        (Integer) datos.get("id_fin_concepto_pago"),
        (Integer) datos.get("id_programa_aprobado"),
        (Integer) datos.get("id_tipo_beneficiario"),
        new BigDecimal(datos.get("monto_base").toString()),
        FechaUtil.toLocalDate(datos.get("fecha_inicio_vigencia")),
        FechaUtil.toLocalDate(datos.get("fecha_fin_vigencia")),
        (String) datos.get("descripcion"),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
        "id_arancel", idArancel,
        "mensaje", "Arancel registrado exitosamente"
    ));
  }

  @PutMapping("/api/arancel/{idArancel}")
  public ResponseEntity<?> modificarArancel(
      @PathVariable Integer idArancel,
      @RequestBody Map<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    String mensaje = finArancelService.modificarArancel(
        idArancel,
        new BigDecimal(datos.get("monto_base").toString()),
        FechaUtil.toLocalDate(datos.get("fecha_inicio_vigencia")),
        FechaUtil.toLocalDate(datos.get("fecha_fin_vigencia")),
        (String) datos.get("descripcion"),
        (String) datos.get("estado_arancel"),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of("mensaje", mensaje));
  }

  @DeleteMapping("/api/arancel/{idArancel}")
  public ResponseEntity<?> eliminarArancel(
      @PathVariable Integer idArancel,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    String mensaje = finArancelService.eliminarArancel(idArancel, userDetails.getIdSegUsuario());
    return ResponseEntity.ok(Map.of("mensaje", mensaje));
  }

  @PostMapping("/api/arancel/calcular")
  public ResponseEntity<?> calcularArancelConDescuento(@RequestBody Map<String, Object> datos) {
    Map<String, Object> resultado = finArancelService.calcularArancelConDescuento(
        (Integer) datos.get("id_fin_concepto_pago"),
        (Integer) datos.get("id_programa_aprobado"),
        (Integer) datos.get("id_tipo_beneficiario"),
        (Integer) datos.get("id_convenio")
    );
    return ResponseEntity.ok(resultado);
  }
}

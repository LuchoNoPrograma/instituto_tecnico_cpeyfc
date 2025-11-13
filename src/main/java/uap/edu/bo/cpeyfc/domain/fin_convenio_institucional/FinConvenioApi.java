package uap.edu.bo.cpeyfc.domain.fin_convenio_institucional;

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
public class FinConvenioApi {

  private final FinConvenioService finConvenioService;

  @GetMapping("/api/convenios/vigentes")
  public ResponseEntity<?> obtenerConveniosVigentes() {
    return ResponseEntity.ok(finConvenioService.obtenerConveniosVigentes());
  }

  @GetMapping("/api/convenios/activos")
  public ResponseEntity<?> obtenerConveniosActivos() {
    return ResponseEntity.ok(finConvenioService.obtenerConveniosActivos());
  }

  @GetMapping("/api/convenio/{idConvenio}/descuentos")
  public ResponseEntity<?> obtenerDescuentosPorConvenio(@PathVariable Integer idConvenio) {
    return ResponseEntity.ok(finConvenioService.obtenerDescuentosPorConvenio(idConvenio));
  }

  @PostMapping("/api/convenio")
  public ResponseEntity<?> registrarConvenio(
      @RequestBody Map<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    Integer idConvenio = finConvenioService.registrarConvenio(
        (String) datos.get("nombre_institucion"),
        (String) datos.get("tipo_institucion"),
        (String) datos.get("nit"),
        (String) datos.get("contacto_nombre"),
        (String) datos.get("contacto_telefono"),
        (String) datos.get("contacto_email"),
        FechaUtil.toLocalDate(datos.get("fecha_inicio_convenio")),
        FechaUtil.toLocalDate(datos.get("fecha_fin_convenio")),
        (String) datos.get("observaciones"),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
        "id_convenio", idConvenio,
        "mensaje", "Convenio registrado exitosamente"
    ));
  }

  @PutMapping("/api/convenio/{idConvenio}")
  public ResponseEntity<?> modificarConvenio(
      @PathVariable Integer idConvenio,
      @RequestBody Map<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    String mensaje = finConvenioService.modificarConvenio(
        idConvenio,
        (String) datos.get("nombre_institucion"),
        (String) datos.get("tipo_institucion"),
        (String) datos.get("nit"),
        (String) datos.get("contacto_nombre"),
        (String) datos.get("contacto_telefono"),
        (String) datos.get("contacto_email"),
        FechaUtil.toLocalDate(datos.get("fecha_inicio_convenio")),
        FechaUtil.toLocalDate(datos.get("fecha_fin_convenio")),
        (String) datos.get("observaciones"),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of("mensaje", mensaje));
  }

  @DeleteMapping("/api/convenio/{idConvenio}")
  public ResponseEntity<?> eliminarConvenio(
      @PathVariable Integer idConvenio,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    String mensaje = finConvenioService.eliminarConvenio(idConvenio, userDetails.getIdSegUsuario());
    return ResponseEntity.ok(Map.of("mensaje", mensaje));
  }

  @PostMapping("/api/convenio/descuento")
  public ResponseEntity<?> registrarDescuento(
      @RequestBody Map<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    Integer idDescuento = finConvenioService.registrarDescuento(
        (Integer) datos.get("id_convenio"),
        (Integer) datos.get("id_aca_programa_aprobado"),
        (Integer) datos.get("id_fin_concepto_pago"),
        (String) datos.get("tipo_descuento"),
        new BigDecimal(datos.get("valor_descuento").toString()),
        FechaUtil.toLocalDate(datos.get("fecha_inicio_vigencia")),
        FechaUtil.toLocalDate(datos.get("fecha_fin_vigencia")),
        (String) datos.get("descripcion"),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
        "id_descuento", idDescuento,
        "mensaje", "Descuento registrado exitosamente"
    ));
  }

  @PutMapping("/api/convenio/descuento/{idDescuento}")
  public ResponseEntity<?> modificarDescuento(
      @PathVariable Integer idDescuento,
      @RequestBody Map<String, Object> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    String mensaje = finConvenioService.modificarDescuento(
        idDescuento,
        (String) datos.get("tipo_descuento"),
        new BigDecimal(datos.get("valor_descuento").toString()),
        FechaUtil.toLocalDate(datos.get("fecha_inicio_vigencia")),
        FechaUtil.toLocalDate(datos.get("fecha_fin_vigencia")),
        (String) datos.get("descripcion"),
        (String) datos.get("estado_descuento_convenio"),
        userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of("mensaje", mensaje));
  }

  @DeleteMapping("/api/convenio/descuento/{idDescuento}")
  public ResponseEntity<?> eliminarDescuento(
      @PathVariable Integer idDescuento,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    String mensaje = finConvenioService.eliminarDescuento(idDescuento, userDetails.getIdSegUsuario());
    return ResponseEntity.ok(Map.of("mensaje", mensaje));
  }
}

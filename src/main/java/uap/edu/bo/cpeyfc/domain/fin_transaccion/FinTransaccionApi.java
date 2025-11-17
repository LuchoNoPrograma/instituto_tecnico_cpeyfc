package uap.edu.bo.cpeyfc.domain.fin_transaccion;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class FinTransaccionApi {

    private final FinTransaccionService finTransaccionService;
    private final ObjectMapper objectMapper;

    /**
     * Registra un pago individual para una obligación de pago
     * POST /api/transaccion/registrar-pago
     */
    @PostMapping("/api/transaccion/registrar-pago")
    public ResponseEntity<?> registrarPago(
      @RequestParam(value = "voucher", required = false) MultipartFile voucher,
      @RequestParam("datos") String datosJson,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
    ) {
        try {
            Map<String, Object> datos = objectMapper.readValue(datosJson, Map.class);

            // Parsear fecha_pago desde String a LocalDate
            String fechaPagoStr = (String) datos.get("fecha_pago");
            LocalDate fechaPago = LocalDate.parse(fechaPagoStr);

            // Parsear monto_pagado desde Number a BigDecimal
            Number montoPagadoNum = (Number) datos.get("monto_pagado");
            BigDecimal montoPagado = new BigDecimal(montoPagadoNum.toString());

            Map<String, Object> resultado = finTransaccionService.registrarPagoIndividual(
              voucher,
              (Integer) datos.get("cod_matricula"),
              (Integer) datos.get("id_fin_obligacion_pago"),
              montoPagado,
              fechaPago,
              (String) datos.get("tipo_comprobante"),
              (String) datos.get("observacion"),
              userDetails.getIdSegUsuario()
            );

            return ResponseEntity.ok(Map.of(
              "success", true,
              "mensaje", resultado.get("mensaje"),
              "data", resultado
            ));

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
              "success", false,
              "message", "Error al registrar pago: " + e.getMessage()
            ));
        }
    }

    /**
     * Anula una transacción de pago
     * POST /api/transaccion/anular-pago/:id
     */
    @PostMapping("/api/transaccion/anular-pago/{id}")
    public ResponseEntity<?> anularPago(
      @PathVariable Integer id,
      @RequestBody Map<String, String> datos,
      @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
    ) {
        try {
            String resultado = finTransaccionService.anularPago(
              id,
              datos.get("motivo_anulacion"),
              userDetails.getIdSegUsuario()
            );

            return ResponseEntity.ok(Map.of(
              "success", true,
              "message", resultado
            ));

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
              "success", false,
              "message", "Error al anular pago: " + e.getMessage()
            ));
        }
    }

    /**
     * Obtiene el historial de pagos de una matrícula
     * GET /api/transaccion/historial/:codMatricula
     */
    @GetMapping("/api/transaccion/historial/{codMatricula}")
    public ResponseEntity<?> historialPagosPorMatricula(@PathVariable Integer codMatricula) {
        try {
            return ResponseEntity.ok(
              finTransaccionService.historialPagosPorMatricula(codMatricula)
            );
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
              "success", false,
              "message", "Error al obtener historial: " + e.getMessage()
            ));
        }
    }

    /**
     * Obtiene el historial de todos los pagos
     * GET /api/transaccion/historial
     */
    @GetMapping("/api/transaccion/historial")
    public ResponseEntity<?> historialPagosTodos() {
        try {
            return ResponseEntity.ok(
              finTransaccionService.historialPagosTodos()
            );
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
              "success", false,
              "message", "Error al obtener historial: " + e.getMessage()
            ));
        }
    }
}

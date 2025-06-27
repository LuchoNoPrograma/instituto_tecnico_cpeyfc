package uap.edu.bo.cpeyfc.domain.aca_parametro_programa;

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
public class AcaParametroProgramaApi {
  private final AcaParametroProgramaRepository acaParametroProgramaRepository;

  @PostMapping("/api/parametro-programa")
  public ResponseEntity<?> registrarParametro(@RequestBody Map<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String valor = datos.get("valor").toString();
    String tipoDato = inferirTipoDato(valor);

    Integer resultado = acaParametroProgramaRepository.registrarParametro(
            (Integer) datos.get("id_programa_aprobado"),
            (String) datos.get("nombre_param"),
            valor,
            tipoDato,
            FechaUtil.toLocalDate(datos.get("fecha_inicio_vigencia")),
            FechaUtil.toLocalDate(datos.get("fecha_fin_vigencia")),
            datos.get("orden") != null ? (Integer) datos.get("orden") : 1,
            userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
            "id_parametro", resultado,
            "tipo_dato_inferido", tipoDato,
            "mensaje", "Parámetro registrado exitosamente"
    ));
  }

  @PutMapping("/api/parametro-programa/{idParametro}")
  public ResponseEntity<?> modificarParametro(
          @PathVariable Integer idParametro,
          @RequestBody Map<String, Object> datos,
          @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    String tipoDato = null;
    if (datos.containsKey("valor") && datos.get("valor") != null) {
      tipoDato = inferirTipoDato(datos.get("valor").toString());
    }

    Boolean resultado = acaParametroProgramaRepository.modificarParametro(
            idParametro,
            (String) datos.get("nombre_param"),
            datos.get("valor") != null ? datos.get("valor").toString() : null,
            tipoDato,
            FechaUtil.toLocalDate(datos.get("fecha_inicio_vigencia")),
            FechaUtil.toLocalDate(datos.get("fecha_fin_vigencia")),
            datos.get("orden") != null ? (Integer) datos.get("orden") : null,
            (String) datos.get("estado"),
            userDetails.getIdSegUsuario()
    );

    return ResponseEntity.ok(Map.of(
            "exito", resultado,
            "mensaje", "Parámetro modificado exitosamente"
    ));
  }

  @GetMapping("/api/parametro-programa/programa/{idProgramaAprobado}")
  public ResponseEntity<?> obtenerParametrosPorPrograma(
          @PathVariable Integer idProgramaAprobado,
          @RequestParam(required = false) String tipoDato,
          @RequestParam(defaultValue = "true") Boolean soloVigentes) {

    List<Map<String, Object>> parametros = acaParametroProgramaRepository.obtenerParametrosPorPrograma(
            idProgramaAprobado, tipoDato, soloVigentes
    );

    return ResponseEntity.ok(parametros);
  }

  private String inferirTipoDato(String valor) {
    if (valor == null || valor.trim().isEmpty()) {
      return "VARCHAR";
    }

    if ("true".equalsIgnoreCase(valor) || "false".equalsIgnoreCase(valor)) {
      return "BOOLEAN";
    }

    try {
      String valorLimpio = valor.replace("%", "").replace(",", "").trim();
      Double.parseDouble(valorLimpio);
      return "DECIMAL";
    } catch (NumberFormatException e) {
      // Continue
    }

    try {
      Integer.parseInt(valor);
      return "INTEGER";
    } catch (NumberFormatException e) {
      // Continue
    }

    if (valor.matches("\\d{4}-\\d{2}-\\d{2}")) {
      return "DATE";
    }

    return "VARCHAR";
  }
}
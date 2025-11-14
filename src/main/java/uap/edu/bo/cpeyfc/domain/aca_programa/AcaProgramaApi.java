package uap.edu.bo.cpeyfc.domain.aca_programa;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AcaProgramaApi {
  private final AcaProgramaService acaProgramaService;
  private final ObjectMapper objectMapper;

  // ========== ENDPOINT ANTIGUO (mantener compatibilidad) ==========
  @GetMapping("/api/programa/vista/programas-activos")
  public ResponseEntity<?> vistaProgramasActivos() {
    return ResponseEntity.ok(acaProgramaService.vistaProgramasActivos());
  }

  // ========== ENDPOINTS NUEVOS ==========
  @GetMapping("/api/programa/vista/programas-con-habilidades")
  public ResponseEntity<?> vistaProgramasConHabilidades() {
    return ResponseEntity.ok(acaProgramaService.vistaProgramasConHabilidades());
  }

  @PostMapping("/api/programa")
  public ResponseEntity<?> registrarPrograma(
    @RequestParam(value = "file", required = false) MultipartFile file,
    @RequestParam("datos") String datosJson,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    try {
      Map<String, Object> datos = objectMapper.readValue(datosJson, Map.class);

      // Obtener habilidades del JSON
      List<String> habilidadesList = (List<String>) datos.get("habilidades");
      String[] habilidades = habilidadesList != null
        ? habilidadesList.toArray(new String[0])
        : new String[0];

      Integer idPrograma = acaProgramaService.registrarPrograma(
        file,
        (Integer) datos.get("id_aca_area"),
        (String) datos.get("nombre_programa"),
        (String) datos.get("sigla"),
        (String) datos.get("objetivo"),
        habilidades,
        userDetails.getIdSegUsuario()
      );

      return ResponseEntity.ok(Map.of(
        "success", true,
        "message", "Programa registrado exitosamente",
        "id_aca_programa", idPrograma
      ));
    } catch (Exception e) {
      return ResponseEntity.badRequest().body(Map.of(
        "success", false,
        "message", "Error al registrar programa: " + e.getMessage()
      ));
    }
  }

  @PutMapping("/api/programa/{id}")
  public ResponseEntity<?> modificarPrograma(
    @PathVariable Integer id,
    @RequestParam(value = "file", required = false) MultipartFile file,
    @RequestParam("datos") String datosJson,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    try {
      Map<String, Object> datos = objectMapper.readValue(datosJson, Map.class);

      // Obtener habilidades del JSON
      List<String> habilidadesList = (List<String>) datos.get("habilidades");
      String[] habilidades = habilidadesList != null
        ? habilidadesList.toArray(new String[0])
        : new String[0];

      String resultado = acaProgramaService.modificarPrograma(
        file,
        id,
        (Integer) datos.get("id_aca_area"),
        (String) datos.get("nombre_programa"),
        (String) datos.get("sigla"),
        (String) datos.get("objetivo"),
        (String) datos.get("imagen_url_antigua"),
        habilidades,
        userDetails.getIdSegUsuario()
      );

      return ResponseEntity.ok(Map.of(
        "success", true,
        "message", resultado
      ));
    } catch (Exception e) {
      return ResponseEntity.badRequest().body(Map.of(
        "success", false,
        "message", "Error al modificar programa: " + e.getMessage()
      ));
    }
  }
}
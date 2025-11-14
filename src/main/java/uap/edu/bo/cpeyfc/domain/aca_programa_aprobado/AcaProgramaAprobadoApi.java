package uap.edu.bo.cpeyfc.domain.aca_programa_aprobado;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import uap.edu.bo.cpeyfc.domain.archivo.ArchivoService;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;
import uap.edu.bo.cpeyfc.util.FechaUtil;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class AcaProgramaAprobadoApi {
  private final AcaProgramaAprobadoService acaProgramaAprobadoService;
  private final AcaProgramaAprobadoRepository acaProgramaAprobadoRepository;
  private final ArchivoService archivoService;
  private final ObjectMapper objectMapper;

  @GetMapping("/api/programa-aprobado/vista/programas-aprobados")
  public ResponseEntity<?> vistaProgramasAprobados() {
    return ResponseEntity.ok(acaProgramaAprobadoRepository.vistaProgramasAprobados());
  }

  @GetMapping("/api/programa-aprobado/vista/programas-aprobados/{idProgramaAprobado}")
  public ResponseEntity<Map<String, Object>> vistaProgramasAprobados(@PathVariable Long idProgramaAprobado) {
    return ResponseEntity.ok(acaProgramaAprobadoRepository.vistaProgramasAprobadosPorIdProgramaAprobado(idProgramaAprobado));
  }

  @GetMapping("/api/programa-aprobado/plan-estudio/{idAcaProgramaAprobado}")
  public ResponseEntity<?> obtenerPlanEstudioProgramaAprobado(@PathVariable Integer idAcaProgramaAprobado) {
    return ResponseEntity.ok(acaProgramaAprobadoRepository.obtenerPlanEstudioProgramaAprobado(idAcaProgramaAprobado));
  }

  @PostMapping("/api/programa-aprobado")
  public ResponseEntity<?> registrarProgramaAprobado(
    @RequestParam(value = "file", required = false) MultipartFile file,
    @RequestParam("datos") String datosJson,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    try {
      Map<String, Object> datos = objectMapper.readValue(datosJson, Map.class);

      Integer idProgramaAprobado = acaProgramaAprobadoService.registrarProgramaAprobado(
        file,
        (Integer) datos.get("id_aca_programa"),
        (Integer) datos.get("id_aca_modalidad"),
        (Integer) datos.get("gestion"),
        (Integer) datos.get("id_aca_plan_estudio"),
        (Integer) datos.get("id_aca_version"),
        (String) datos.get("estado_programa_aprobado"),
        (String) datos.get("cod_certificado_ceub"),
        FechaUtil.toLocalDate(datos.get("fecha_inicio_vigencia")),
        FechaUtil.toLocalDate(datos.get("fecha_fin_vigencia")),
        userDetails.getIdSegUsuario()
      );

      return ResponseEntity.ok(Map.of(
        "success", true,
        "message", "Programa aprobado registrado exitosamente",
        "id_aca_programa_aprobado", idProgramaAprobado
      ));
    } catch (Exception e) {
      return ResponseEntity.badRequest().body(Map.of(
        "success", false,
        "message", "Error al registrar programa aprobado: " + e.getMessage()
      ));
    }
  }


  @PostMapping("/api/programa-aprobado/{id}")
  public ResponseEntity<?> modificarProgramaAprobado(
    @PathVariable Integer id,
    @RequestParam(value = "file", required = false) MultipartFile file,
    @RequestParam("datos") String datosJson,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {

    try {
      Map<String, Object> datos = objectMapper.readValue(datosJson, Map.class);

      String resultado = acaProgramaAprobadoService.modificarProgramaAprobado(
        file,
        id,
        (Integer) datos.get("id_aca_programa"),
        (Integer) datos.get("id_aca_modalidad"),
        (Integer) datos.get("gestion"),
        (Integer) datos.get("id_aca_plan_estudio"),
        (Integer) datos.get("id_aca_version"),
        (String) datos.get("estado_programa_aprobado"),
        (String) datos.get("imagen_programa_url"),
        FechaUtil.toLocalDate(datos.get("fecha_inicio_vigencia")),
        FechaUtil.toLocalDate(datos.get("fecha_fin_vigencia")),
        userDetails.getIdSegUsuario()
      );

      return ResponseEntity.ok(Map.of(
        "success", true,
        "message", resultado
      ));
    } catch (Exception e) {
      return ResponseEntity.badRequest().body(Map.of(
        "success", false,
        "message", "Error al modificar programa aprobado: " + e.getMessage()
      ));
    }
  }
}
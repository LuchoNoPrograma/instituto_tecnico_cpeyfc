package uap.edu.bo.cpeyfc.domain.aca_programa_aprobado;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
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

  @GetMapping("/api/programa-aprobado/vista/programas-aprobados")
  public ResponseEntity<?> vistaProgramasAprobados() {
    return ResponseEntity.ok(acaProgramaAprobadoRepository.vistaProgramasAprobados());
  }

  @GetMapping("/api/programa-aprobado/vista/programas-aprobados/{idProgramaAprobado}")
  public ResponseEntity<?> vistaProgramasAprobados(@PathVariable Long idProgramaAprobado) {
    return ResponseEntity.ok(acaProgramaAprobadoRepository.vistaProgramasAprobadosPorIdProgramaAprobado(idProgramaAprobado));
  }

  @GetMapping("/api/programa-aprobado/plan-estudio/{idAcaProgramaAprobado}")
  public ResponseEntity<?> obtenerPlanEstudioProgramaAprobado(@PathVariable Integer idAcaProgramaAprobado) {
    return ResponseEntity.ok(acaProgramaAprobadoRepository.obtenerPlanEstudioProgramaAprobado(idAcaProgramaAprobado));
  }

  @PostMapping("/api/programa-aprobado")
  public ResponseEntity<?> registrarProgramaAprobado(@RequestBody Map<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = acaProgramaAprobadoRepository.registrarProgramaAprobado(
      (Integer) datos.get("id_aca_programa"),
      (Integer) datos.get("id_aca_modalidad"),
      (Integer) datos.get("gestion"),
      (Integer) datos.get("id_aca_plan_estudio"),
      (Integer) datos.get("id_aca_version"),
      (String) datos.get("estado_programa_aprobado"),
      (String) datos.get("cod_certificado_ceub"),
      new BigDecimal(datos.get("precio_matricula").toString()),
      new BigDecimal(datos.get("precio_colegiatura").toString()),
      datos.get("precio_titulacion") != null ? new BigDecimal(datos.get("precio_titulacion").toString()) : null,
      FechaUtil.toLocalDate(datos.get("fecha_inicio_vigencia")),
      FechaUtil.toLocalDate(datos.get("fecha_fin_vigencia")),
      userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(resultado);
  }

  @PutMapping("/api/programa-aprobado/{id}")
  public ResponseEntity<String> modificarProgramaAprobado(@PathVariable Integer id, @RequestBody HashMap<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = acaProgramaAprobadoRepository.modificarProgramaAprobado(
      id,
      (Integer) datos.get("id_aca_programa"),
      (Integer) datos.get("id_aca_modalidad"),
      (Integer) datos.get("gestion"),
      (Integer) datos.get("id_aca_plan_estudio"),
      (Integer) datos.get("id_aca_version"),
      (String) datos.get("estado_programa_aprobado"),
      new BigDecimal(datos.get("precio_matricula").toString()),
      new BigDecimal(datos.get("precio_colegiatura").toString()),
      datos.get("precio_titulacion") != null ? new BigDecimal(datos.get("precio_titulacion").toString()) : null,
      datos.get("fecha_inicio_vigencia") != null ? LocalDate.parse((String) datos.get("fecha_inicio_vigencia")) : null,
      datos.get("fecha_fin_vigencia") != null ? LocalDate.parse((String) datos.get("fecha_fin_vigencia")) : null,
      (String) datos.get("cod_certificado_ceub"),
      (String) datos.get("cod_sigla_version"),
      userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(resultado);
  }
}
package uap.edu.bo.cpeyfc.domain.ins_matricula;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.domain.fin_obligacion_pago.FinObligacionPagoRepository;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class InsMatriculaApi {
  private final InsMatriculaRepository insMatriculaRepository;
  private final InsMatriculaService insMatriculaService;
  private final FinObligacionPagoRepository finObligacionPagoRepository;

  // DEPRECADO - Mantener para compatibilidad con código existente
  @Deprecated
  @PostMapping("/api/matricula/matricular-preinscrito")
  public ResponseEntity<String> matricularPreinscrito(
    @RequestBody HashMap<String, Object> datos,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    String resultado = insMatriculaService.matricularPreinscrito(
      (Integer) datos.get("id_ins_preinscripcion"),
      (Integer) datos.get("id_ins_grupo"),
      userDetails.getIdSegUsuario(),
      (Integer) datos.get("id_parametro_descuento")
    );
    return ResponseEntity.ok(resultado);
  }

  // NUEVO - Sistema de aranceles con tipos de beneficiario
  @PostMapping("/api/matricula/matricular-preinscrito-v2")
  public ResponseEntity<?> matricularPreinscritoV2(
    @RequestBody HashMap<String, Object> datos,
    @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails
  ) {
    String resultado = insMatriculaService.matricularPreinscritoV2(
      (Integer) datos.get("id_ins_preinscripcion"),
      (Integer) datos.get("id_ins_grupo"),
      (Integer) datos.get("id_tipo_beneficiario"),  // NUEVO - obligatorio
      userDetails.getIdSegUsuario(),
      (Integer) datos.get("id_convenio")             // NUEVO - opcional
    );

    return ResponseEntity.ok(Map.of(
      "mensaje", resultado,
      "tipo", "success"
    ));
  }

  @GetMapping("/api/matricula/vista/estudiantes-grupo")
  public ResponseEntity<List<Map<String, Object>>> vistaEstudiantesGrupo(
          @RequestParam(required = false) Integer idGrupo) {

    if (idGrupo != null) {
      return ResponseEntity.ok(insMatriculaRepository.vistaEstudiantesGrupoPorIdGrupo(idGrupo));
    } else {
      return ResponseEntity.ok(insMatriculaRepository.vistaEstudiantesGrupo());
    }
  }

  @GetMapping("/api/matricula/vista/obligaciones-pago")
  public ResponseEntity<?> vistaObligacionesPago(){
    return ResponseEntity.ok(insMatriculaRepository.vistaObligacionesPago());
  }

  @GetMapping("/api/matricula/{codMatricula}/obligaciones")
  public ResponseEntity<?> obligacionesPorMatricula(@PathVariable Integer codMatricula) {
    return ResponseEntity.ok(finObligacionPagoRepository.obtenerObligacionesPorMatricula(codMatricula));
  }
}
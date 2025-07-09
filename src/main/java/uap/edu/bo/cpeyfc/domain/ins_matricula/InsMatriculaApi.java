package uap.edu.bo.cpeyfc.domain.ins_matricula;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class InsMatriculaApi {
  private final InsMatriculaRepository insMatriculaRepository;
  private final InsMatriculaService insMatriculaService;

  @PostMapping("/api/matricula/matricular-preinscrito")
  public ResponseEntity<String> matricularPreinscrito(@RequestBody HashMap<String, Object> datos, @AuthenticationPrincipal JwtSecurityConfigUserDetails userDetails) {
    String resultado = insMatriculaService.matricularPreinscrito(
            (Integer) datos.get("id_ins_preinscripcion"),
            (Integer) datos.get("id_ins_grupo"),
            userDetails.getIdSegUsuario(),
            (Integer) datos.get("id_parametro_descuento")
    );
    return ResponseEntity.ok(resultado);
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
}
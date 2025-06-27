package uap.edu.bo.cpeyfc.domain.ins_matricula;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import uap.edu.bo.cpeyfc.security.JwtSecurityConfigUserDetails;

import java.util.HashMap;

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
            (String) datos.get("ci"),
            (String) datos.get("tipo_matricula"),
            userDetails.getIdSegUsuario()
    );
    return ResponseEntity.ok(resultado);
  }
}
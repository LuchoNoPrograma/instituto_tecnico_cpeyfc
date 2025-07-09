package uap.edu.bo.cpeyfc.domain.ins_preinscripcion;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.util.FechaUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class InsPreinscripcionApi {
  private final InsPreinscripcionService insPreinscripcionService;
  private final InsPreinscripcionRepository insPreinscripcionRepository;

  @PostMapping("/api/publico/preinscripcion")
  public ResponseEntity<String> registrarPreinscripcion(@RequestBody HashMap<String, Object> datos) {
    String resultado = insPreinscripcionRepository.registrarPreinscripcion(
            (String) datos.get("nombre"),
            (String) datos.get("ap_paterno"),
            (String) datos.get("ap_materno"),
            (String) datos.get("ci"),
            (String) datos.get("celular"),
            (String) datos.get("correo"),
            FechaUtil.toLocalDate(datos.get("fecha_nacimiento")),
            Integer.parseInt(datos.get("id_aca_programa_aprobado").toString()), // <- CORREGIR ESTA LÍNEA
            1 // user_reg fijo para público
    );
    return ResponseEntity.ok(resultado);
  }

  @GetMapping("/api/preinscripcion/pendiente/{idProgramaAprobado}")
  public ResponseEntity<List<Map<String, Object>>> obtenerPreinscritosPorProgramaAprobado(
          @PathVariable Integer idProgramaAprobado) {
    return ResponseEntity.ok(insPreinscripcionRepository.obtenerPreinscripcionPorProgramaAprobado(idProgramaAprobado));
  }
}
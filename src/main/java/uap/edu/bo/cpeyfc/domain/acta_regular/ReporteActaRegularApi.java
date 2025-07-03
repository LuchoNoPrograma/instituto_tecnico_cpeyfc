package uap.edu.bo.cpeyfc.domain.acta_regular;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import uap.edu.bo.cpeyfc.domain.eje_cronograma_modulo.EjeCronogramaModuloRepository;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class ReporteActaRegularApi {
  private final EjeCronogramaModuloRepository ejeCronogramaModuloRepository;

  @GetMapping("/api/acta-regular/{id_cronograma_modulo}")
  public ResponseEntity<List<Map<String, Object>>> obtenerActaRegular(
          @PathVariable("id_cronograma_modulo") Integer idCronogramaModulo
  ) {
    List<Map<String, Object>> reporte = ejeCronogramaModuloRepository.reporte_acta_regular(idCronogramaModulo);
    return ResponseEntity.ok(reporte);
  }
}

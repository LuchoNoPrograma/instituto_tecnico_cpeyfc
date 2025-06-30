package uap.edu.bo.cpeyfc.domain.fin_concepto_pago;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class FinConceptoPagoApi {
  private final FinConceptoPagoRepository finConceptoPagoRepository;

  @GetMapping("/api/concepto-pago/activo")
  public ResponseEntity<?> vistaConceptosPagosActivos(){
    return ResponseEntity.ok(finConceptoPagoRepository.vistaConceptosPagosActivos());
  }

  @GetMapping("/api/concepto-pago/programa-aprobado/{idProgramaAprobado}")
  public ResponseEntity<?> obtenerConceptosPrograma(@PathVariable Integer idProgramaAprobado) {
    return ResponseEntity.ok(finConceptoPagoRepository.obtenerConceptosPagoProgramaAprobado(idProgramaAprobado));
  }
}
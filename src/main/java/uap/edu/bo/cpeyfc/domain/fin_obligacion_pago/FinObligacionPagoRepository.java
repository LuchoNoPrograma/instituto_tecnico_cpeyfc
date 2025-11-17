package uap.edu.bo.cpeyfc.domain.fin_obligacion_pago;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Map;

public interface FinObligacionPagoRepository extends JpaRepository<FinObligacionPago, Integer> {

  @Query(value = """
    SELECT
      op.id_fin_obligacion_pago,
      op.cod_ins_matricula,
      cp.nombre_concepto,
      cp.descripcion,
      op.deuda_sin_descuento,
      op.deuda_con_descuento,
      op.saldo_pendiente,
      op.observacion,
      op.estado_obligacion_pago
    FROM fin_obligacion_pago op
    INNER JOIN fin_concepto_pago cp ON op.id_fin_concepto_pago = cp.id_fin_concepto_pago
    WHERE op.cod_ins_matricula = :codMatricula
      AND op.estado_obligacion_pago != 'ELIMINADO'
    ORDER BY cp.nombre_concepto
    """, nativeQuery = true)
  List<Map<String, Object>> obtenerObligacionesPorMatricula(Integer codMatricula);
}
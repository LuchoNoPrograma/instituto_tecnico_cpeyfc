package uap.edu.bo.cpeyfc.domain.fin_transaccion;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface FinTransaccionRepository extends JpaRepository<FinTransaccion, Integer> {

  @Query(value = """
    SELECT * FROM fn_registrar_pago_individual(
      :cod_matricula,
      :id_fin_obligacion_pago,
      :monto_pagado,
      :fecha_pago,
      :tipo_comprobante,
      :observacion,
      :voucher_url,
      :user_reg
    )
    """, nativeQuery = true)
  Map<String, Object> registrarPagoIndividual(
    Integer cod_matricula,
    Integer id_fin_obligacion_pago,
    BigDecimal monto_pagado,
    LocalDate fecha_pago,
    String tipo_comprobante,
    String observacion,
    String voucher_url,
    Integer user_reg
  );

  @Query(value = """
    SELECT * FROM fn_anular_pago(
      :id_transaccion,
      :motivo_anulacion,
      :user_mod
    )
    """, nativeQuery = true)
  String anularPago(
    Integer id_transaccion,
    String motivo_anulacion,
    Integer user_mod
  );

  @Query(value = "SELECT * FROM vista_historial_pagos_matricula WHERE cod_ins_matricula = :cod_matricula ORDER BY fecha_pago DESC", nativeQuery = true)
  List<Map<String, Object>> historialPagosPorMatricula(Integer cod_matricula);

  @Query(value = "SELECT * FROM vista_historial_pagos_matricula ORDER BY fecha_pago DESC", nativeQuery = true)
  List<Map<String, Object>> historialPagosTodos();
}
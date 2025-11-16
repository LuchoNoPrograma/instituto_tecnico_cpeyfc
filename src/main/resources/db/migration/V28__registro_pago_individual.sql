-- ============================================
-- MIGRACIÓN V28: REGISTRO DE PAGOS INDIVIDUAL
-- ============================================
-- Fecha: 2025-01-16
-- Descripción: Funciones para registro de transacciones de pago individual
--              Un pago cubre una obligación de pago por concepto
-- ============================================

-- ============================================
-- 1. AGREGAR COLUMNA saldo_pendiente SI NO EXISTE
-- ============================================
-- Esta columna rastrea cuánto queda por pagar de la obligación

ALTER TABLE fin_obligacion_pago
  ADD COLUMN IF NOT EXISTS saldo_pendiente NUMERIC(10,2);

-- Actualizar saldo_pendiente para obligaciones existentes que no lo tengan
UPDATE fin_obligacion_pago
SET saldo_pendiente = deuda_con_descuento
WHERE saldo_pendiente IS NULL;

-- Hacer la columna NOT NULL después de establecer valores
ALTER TABLE fin_obligacion_pago
  ALTER COLUMN saldo_pendiente SET NOT NULL;

COMMENT ON COLUMN fin_obligacion_pago.saldo_pendiente IS 'Saldo pendiente de pago de la obligación. Se reduce con cada pago aplicado';

-- ============================================
-- 2. AGREGAR COLUMNA voucher_url EN fin_transaccion
-- ============================================
-- Para almacenar la URL del comprobante de pago subido

ALTER TABLE fin_transaccion
  ADD COLUMN IF NOT EXISTS voucher_url VARCHAR(500);

COMMENT ON COLUMN fin_transaccion.voucher_url IS 'URL del voucher/comprobante de pago escaneado';

-- ============================================
-- 3. FUNCIÓN: Registrar pago individual
-- ============================================
-- Registra una transacción de pago que cubre una obligación de pago
-- Actualiza el saldo pendiente de la obligación

CREATE OR REPLACE FUNCTION fn_registrar_pago_individual(
  p_cod_matricula INTEGER,
  p_id_fin_obligacion_pago INTEGER,
  p_monto_pagado NUMERIC(10,2),
  p_fecha_pago DATE,
  p_tipo_comprobante VARCHAR(35),
  p_observacion VARCHAR(500),
  p_voucher_url VARCHAR(500),
  p_user_reg INTEGER
)
  RETURNS TABLE(
                 id_transaccion INTEGER,
                 id_detalle_pago INTEGER,
                 cod_comprobante VARCHAR,
                 saldo_restante NUMERIC,
                 estado_obligacion VARCHAR,
                 mensaje TEXT
               )
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_transaccion INTEGER;
  v_id_detalle_pago INTEGER;
  v_cod_comprobante VARCHAR(35);
  v_saldo_actual NUMERIC(10,2);
  v_nuevo_saldo NUMERIC(10,2);
  v_deuda_total NUMERIC(10,2);
  v_estado_obligacion VARCHAR(35);
  v_nombre_concepto VARCHAR(100);
  v_nombre_estudiante TEXT;
  v_existe_obligacion INTEGER;
BEGIN
  -- ===== VALIDACIONES =====

  IF p_cod_matricula IS NULL OR p_id_fin_obligacion_pago IS NULL OR
     p_monto_pagado IS NULL OR p_fecha_pago IS NULL OR
     p_tipo_comprobante IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los parámetros obligatorios deben ser proporcionados';
  END IF;

  IF p_monto_pagado <= 0 THEN
    RAISE EXCEPTION 'Error! El monto pagado debe ser mayor a cero';
  END IF;

  -- Verificar que existe la obligación de pago
  SELECT COUNT(*), MAX(op.saldo_pendiente), MAX(op.deuda_con_descuento), MAX(cp.nombre_concepto)
  INTO v_existe_obligacion, v_saldo_actual, v_deuda_total, v_nombre_concepto
  FROM fin_obligacion_pago op
         INNER JOIN fin_concepto_pago cp ON op.id_fin_concepto_pago = cp.id_fin_concepto_pago
  WHERE op.id_fin_obligacion_pago = p_id_fin_obligacion_pago
    AND op.cod_ins_matricula = p_cod_matricula
    AND op.estado_obligacion_pago != 'ELIMINADO';

  IF v_existe_obligacion = 0 THEN
    RAISE EXCEPTION 'Error! Obligación de pago no encontrada para esta matrícula';
  END IF;

  -- Verificar que la obligación no esté ya pagada
  IF v_saldo_actual <= 0 THEN
    RAISE EXCEPTION 'Error! Esta obligación ya está completamente pagada';
  END IF;

  -- Verificar que el monto no exceda el saldo pendiente
  IF p_monto_pagado > v_saldo_actual THEN
    RAISE EXCEPTION 'Error! El monto pagado (Bs. %) excede el saldo pendiente (Bs. %)',
      p_monto_pagado, v_saldo_actual;
  END IF;

  -- Obtener nombre del estudiante para el mensaje
  SELECT CONCAT(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, ''))
  INTO v_nombre_estudiante
  FROM ins_matricula m
         INNER JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
  WHERE m.cod_ins_matricula = p_cod_matricula;

  -- ===== GENERAR CÓDIGO DE COMPROBANTE =====
  -- Formato: PAY-YYYYMMDD-XXXXX (ejemplo: PAY-20250116-00001)

  SELECT CONCAT(
           'PAY-',
           TO_CHAR(p_fecha_pago, 'YYYYMMDD'),
           '-',
           LPAD(NEXTVAL('fin_transaccion_id_fin_transaccion_seq')::TEXT, 5, '0')
         )
  INTO v_cod_comprobante;

  -- ===== REGISTRAR TRANSACCIÓN =====

  INSERT INTO fin_transaccion(
    cod_comprobante,
    total_pago,
    fecha_pago,
    tipo_comprobante,
    observacion,
    voucher_url,
    estado_transaccion,
    fecha_reg,
    user_reg
  ) VALUES (
             v_cod_comprobante,
             p_monto_pagado,
             p_fecha_pago,
             p_tipo_comprobante,
             p_observacion,
             p_voucher_url,
             'CONFIRMADO',
             CURRENT_TIMESTAMP,
             p_user_reg
           )
  RETURNING id_fin_transaccion INTO v_id_transaccion;

  -- ===== REGISTRAR DETALLE DE PAGO =====

  INSERT INTO fin_detalle_pago(
    id_fin_transaccion,
    id_fin_obligacion_pago,
    monto_pagado,
    estado_detalle_pago,
    fecha_reg,
    user_reg
  ) VALUES (
             v_id_transaccion,
             p_id_fin_obligacion_pago,
             p_monto_pagado,
             'APLICADO',
             CURRENT_TIMESTAMP,
             p_user_reg
           )
  RETURNING id_fin_detalle_pago INTO v_id_detalle_pago;

  -- ===== ACTUALIZAR SALDO DE OBLIGACIÓN =====

  v_nuevo_saldo := v_saldo_actual - p_monto_pagado;

  -- Determinar nuevo estado de la obligación
  IF v_nuevo_saldo <= 0 THEN
    v_estado_obligacion := 'PAGADO';
  ELSIF v_nuevo_saldo < v_deuda_total THEN
    v_estado_obligacion := 'PAGO_PARCIAL';
  ELSE
    v_estado_obligacion := 'PENDIENTE';
  END IF;

  UPDATE fin_obligacion_pago
  SET saldo_pendiente = v_nuevo_saldo,
      estado_obligacion_pago = v_estado_obligacion,
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_reg
  WHERE id_fin_obligacion_pago = p_id_fin_obligacion_pago;

  -- ===== RETORNAR RESULTADO =====

  RETURN QUERY SELECT
                 v_id_transaccion,
                 v_id_detalle_pago,
                 v_cod_comprobante,
                 v_nuevo_saldo,
                 v_estado_obligacion,
                 CONCAT(
                   'Pago registrado exitosamente. ',
                   'Comprobante: ', v_cod_comprobante, '. ',
                   'Concepto: ', v_nombre_concepto, '. ',
                   'Estudiante: ', v_nombre_estudiante, '. ',
                   'Monto: Bs. ', p_monto_pagado, '. ',
                   CASE
                     WHEN v_nuevo_saldo > 0
                       THEN CONCAT('Saldo restante: Bs. ', v_nuevo_saldo)
                     ELSE 'Obligación completamente pagada'
                   END
                 )::TEXT;
END;
$$;

COMMENT ON FUNCTION fn_registrar_pago_individual IS
  'Registra un pago individual que cubre una obligación de pago. Actualiza el saldo pendiente y el estado de la obligación';

-- ============================================
-- 4. FUNCIÓN: Anular transacción de pago
-- ============================================
-- Permite anular una transacción y revertir el saldo

CREATE OR REPLACE FUNCTION fn_anular_pago(
  p_id_transaccion INTEGER,
  p_motivo_anulacion VARCHAR(500),
  p_user_mod INTEGER
)
  RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_estado_actual VARCHAR(35);
  v_total_pago NUMERIC(10,2);
  rec_detalle RECORD;
BEGIN
  -- Verificar que existe la transacción
  SELECT estado_transaccion, total_pago
  INTO v_estado_actual, v_total_pago
  FROM fin_transaccion
  WHERE id_fin_transaccion = p_id_transaccion;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Error! Transacción no encontrada';
  END IF;

  -- Verificar que no esté ya anulada
  IF v_estado_actual = 'ANULADO' THEN
    RAISE EXCEPTION 'Error! La transacción ya está anulada';
  END IF;

  -- Revertir saldos de todas las obligaciones afectadas
  FOR rec_detalle IN
    SELECT id_fin_obligacion_pago, monto_pagado
    FROM fin_detalle_pago
    WHERE id_fin_transaccion = p_id_transaccion
      AND estado_detalle_pago != 'ANULADO'
    LOOP
      -- Incrementar el saldo pendiente
      UPDATE fin_obligacion_pago
      SET saldo_pendiente = saldo_pendiente + rec_detalle.monto_pagado,
          estado_obligacion_pago = CASE
                                     WHEN (saldo_pendiente + rec_detalle.monto_pagado) >= deuda_con_descuento
                                       THEN 'PENDIENTE'
                                     ELSE 'PAGO_PARCIAL'
            END,
          fecha_mod = CURRENT_TIMESTAMP,
          user_mod = p_user_mod
      WHERE id_fin_obligacion_pago = rec_detalle.id_fin_obligacion_pago;

      -- Marcar el detalle de pago como anulado
      UPDATE fin_detalle_pago
      SET estado_detalle_pago = 'ANULADO',
          fecha_mod = CURRENT_TIMESTAMP,
          user_mod = p_user_mod
      WHERE id_fin_transaccion = p_id_transaccion
        AND id_fin_obligacion_pago = rec_detalle.id_fin_obligacion_pago;
    END LOOP;

  -- Anular la transacción
  UPDATE fin_transaccion
  SET estado_transaccion = 'ANULADO',
      observacion = CONCAT(
        COALESCE(observacion, ''),
        ' | ANULADO: ',
        p_motivo_anulacion
      ),
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_fin_transaccion = p_id_transaccion;

  RETURN 'Pago anulado exitosamente. Saldos revertidos.';
END;
$$;

COMMENT ON FUNCTION fn_anular_pago IS
  'Anula una transacción de pago y revierte los saldos de las obligaciones afectadas';

-- ============================================
-- 5. VISTA: Historial de pagos por matrícula
-- ============================================

CREATE OR REPLACE VIEW vista_historial_pagos_matricula AS
SELECT
  m.cod_ins_matricula,
  p.id_prs_persona,
  p.nombre,
  p.ap_paterno,
  p.ap_materno,
  p.ci,

  t.id_fin_transaccion,
  t.cod_comprobante,
  t.total_pago,
  t.fecha_pago,
  t.tipo_comprobante,
  t.voucher_url,
  t.observacion AS observacion_transaccion,
  t.estado_transaccion,

  dp.id_fin_detalle_pago,
  dp.monto_pagado,
  dp.estado_detalle_pago,

  op.id_fin_obligacion_pago,
  cp.nombre_concepto,
  op.deuda_sin_descuento,
  op.deuda_con_descuento,
  op.saldo_pendiente,
  op.estado_obligacion_pago,

  -- Usuario que registró el pago
  u_reg.nombre_usuario AS usuario_registro,
  t.fecha_reg AS fecha_registro

FROM fin_transaccion t
       INNER JOIN fin_detalle_pago dp ON t.id_fin_transaccion = dp.id_fin_transaccion
       INNER JOIN fin_obligacion_pago op ON dp.id_fin_obligacion_pago = op.id_fin_obligacion_pago
       INNER JOIN ins_matricula m ON op.cod_ins_matricula = m.cod_ins_matricula
       INNER JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
       INNER JOIN fin_concepto_pago cp ON op.id_fin_concepto_pago = cp.id_fin_concepto_pago
       LEFT JOIN seg_usuario u_reg ON t.user_reg = u_reg.id_seg_usuario

WHERE t.estado_transaccion != 'ELIMINADO'
  AND dp.estado_detalle_pago != 'ELIMINADO'
  AND op.estado_obligacion_pago != 'ELIMINADO'
  AND m.estado_matricula != 'ELIMINADO'

ORDER BY t.fecha_pago DESC, t.fecha_reg DESC;

COMMENT ON VIEW vista_historial_pagos_matricula IS
  'Vista completa del historial de pagos por matrícula con detalles de transacciones y obligaciones';

-- ============================================
-- 6. ÍNDICES PARA OPTIMIZACIÓN
-- ============================================

CREATE INDEX IF NOT EXISTS idx_transaccion_fecha_pago
  ON fin_transaccion(fecha_pago DESC)
  WHERE estado_transaccion != 'ELIMINADO';

CREATE INDEX IF NOT EXISTS idx_transaccion_estado
  ON fin_transaccion(estado_transaccion)
  WHERE estado_transaccion != 'ELIMINADO';

CREATE INDEX IF NOT EXISTS idx_obligacion_saldo_pendiente
  ON fin_obligacion_pago(saldo_pendiente)
  WHERE estado_obligacion_pago != 'ELIMINADO';

-- ============================================
-- FIN DE MIGRACIÓN V28
-- ============================================

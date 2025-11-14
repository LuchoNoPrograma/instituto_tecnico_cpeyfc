-- ============================================
-- V20: MIGRACIÓN SISTEMA ARANCELES
-- ============================================
-- Fecha: 2025-01-14
-- Descripción: Migración completa del sistema de descuentos basado en parámetros
--              a un sistema de aranceles con tipos de beneficiario y convenios
-- ============================================

-- NOTA: Las tablas ya existen en V1__baseline.sql:
-- - fin_arancel
-- - fin_tipo_beneficiario
-- - fin_convenio_institucional
-- - fin_descuento_convenio
-- Este script crea las FUNCIONES necesarias para el sistema

-- ============================================
-- 1. FUNCIÓN: Calcular arancel con descuento
-- ============================================

CREATE OR REPLACE FUNCTION fn_calcular_arancel_con_descuento(
  p_id_concepto_pago INTEGER,
  p_id_programa_aprobado INTEGER,
  p_id_tipo_beneficiario INTEGER,
  p_id_convenio INTEGER DEFAULT NULL
)
  RETURNS TABLE(
                 monto_base NUMERIC,
                 descuento_aplicado NUMERIC,
                 monto_final NUMERIC,
                 detalle_descuento TEXT,
                 id_arancel_aplicado INTEGER,
                 id_descuento_aplicado INTEGER
               )
  LANGUAGE plpgsql
AS $$
DECLARE
  v_arancel RECORD;
  v_descuento RECORD;
  v_monto_descuento NUMERIC := 0;
  v_monto_final NUMERIC;
  v_detalle TEXT := NULL;
BEGIN
  -- Buscar arancel vigente (específico del programa o genérico)
  SELECT a.id_arancel, a.monto_base
  INTO v_arancel
  FROM fin_arancel a
  WHERE a.id_fin_concepto_pago = p_id_concepto_pago
    AND a.id_tipo_beneficiario = p_id_tipo_beneficiario
    AND a.estado_arancel = 'ACTIVO'
    AND a.fecha_inicio_vigencia <= CURRENT_DATE
    AND (a.fecha_fin_vigencia IS NULL OR a.fecha_fin_vigencia >= CURRENT_DATE)
    AND (
      a.id_aca_programa_aprobado = p_id_programa_aprobado OR
      a.id_aca_programa_aprobado IS NULL
    )
  ORDER BY
    CASE WHEN a.id_aca_programa_aprobado IS NULL THEN 1 ELSE 0 END,
    a.fecha_inicio_vigencia DESC
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No hay arancel vigente para concepto %, tipo beneficiario %',
      p_id_concepto_pago, p_id_tipo_beneficiario;
  END IF;

  v_monto_final := v_arancel.monto_base;

  -- Si hay convenio, buscar descuento aplicable
  IF p_id_convenio IS NOT NULL THEN
    SELECT dc.id_descuento_convenio, dc.tipo_descuento, dc.valor_descuento, ci.nombre_institucion
    INTO v_descuento
    FROM fin_descuento_convenio dc
           INNER JOIN fin_convenio_institucional ci ON dc.id_convenio = ci.id_convenio
    WHERE dc.id_convenio = p_id_convenio
      AND dc.id_fin_concepto_pago = p_id_concepto_pago
      AND dc.estado_descuento_convenio = 'ACTIVO'
      AND dc.fecha_inicio_vigencia <= CURRENT_DATE
      AND (dc.fecha_fin_vigencia IS NULL OR dc.fecha_fin_vigencia >= CURRENT_DATE)
      AND (
        dc.id_aca_programa_aprobado = p_id_programa_aprobado OR
        dc.id_aca_programa_aprobado IS NULL
      )
    ORDER BY
      CASE WHEN dc.id_aca_programa_aprobado IS NULL THEN 1 ELSE 0 END,
      dc.fecha_inicio_vigencia DESC
    LIMIT 1;

    IF FOUND THEN
      -- Calcular descuento según tipo
      IF v_descuento.tipo_descuento = 'PORCENTAJE' THEN
        v_monto_descuento := ROUND(v_arancel.monto_base * v_descuento.valor_descuento / 100, 2);
        v_detalle := CONCAT(v_descuento.nombre_institucion, ' - ', v_descuento.valor_descuento, '%');
      ELSIF v_descuento.tipo_descuento = 'MONTO_FIJO' THEN
        v_monto_descuento := v_descuento.valor_descuento;
        v_detalle := CONCAT(v_descuento.nombre_institucion, ' - Bs.', v_descuento.valor_descuento);
      END IF;

      v_monto_final := GREATEST(v_arancel.monto_base - v_monto_descuento, 0);
    END IF;
  END IF;

  RETURN QUERY SELECT
                 v_arancel.monto_base,
                 v_monto_descuento,
                 v_monto_final,
                 v_detalle,
                 v_arancel.id_arancel,
                 v_descuento.id_descuento_convenio;
END;
$$;

COMMENT ON FUNCTION fn_calcular_arancel_con_descuento IS
  'Calcula el arancel final aplicando descuentos de convenio si corresponde';

-- ============================================
-- 2. FUNCIÓN: Obtener conceptos con aranceles
-- ============================================

CREATE OR REPLACE FUNCTION fn_obtener_conceptos_pago_con_aranceles(
  p_id_programa_aprobado INTEGER,
  p_id_tipo_beneficiario INTEGER,
  p_id_convenio INTEGER DEFAULT NULL
)
  RETURNS TABLE(
                 id_fin_concepto_pago INTEGER,
                 nombre_concepto VARCHAR,
                 descripcion TEXT,
                 monto_base NUMERIC,
                 descuento_aplicado NUMERIC,
                 monto_final NUMERIC,
                 detalle_descuento TEXT,
                 id_arancel_aplicado INTEGER,
                 id_descuento_aplicado INTEGER
               )
  LANGUAGE plpgsql
AS $$
DECLARE
  rec_concepto RECORD;
BEGIN
  -- Validar programa
  IF NOT EXISTS(
    SELECT 1 FROM aca_programa_aprobado
    WHERE id_aca_programa_aprobado = p_id_programa_aprobado
      AND estado_programa_aprobado != 'ELIMINADO'
  ) THEN
    RAISE EXCEPTION 'Programa aprobado con ID % no encontrado', p_id_programa_aprobado;
  END IF;

  -- Validar tipo de beneficiario
  IF NOT EXISTS(
    SELECT 1 FROM fin_tipo_beneficiario
    WHERE id_tipo_beneficiario = p_id_tipo_beneficiario
      AND estado_tipo_beneficiario != 'ELIMINADO'
  ) THEN
    RAISE EXCEPTION 'Tipo de beneficiario con ID % no encontrado', p_id_tipo_beneficiario;
  END IF;

  -- Obtener conceptos activos y calcular aranceles
  FOR rec_concepto IN
    SELECT
      cp.id_fin_concepto_pago,
      cp.nombre_concepto,
      cp.descripcion
    FROM fin_concepto_pago cp
    WHERE cp.estado_concepto_pago != 'ELIMINADO'
    ORDER BY cp.id_fin_concepto_pago
    LOOP
      BEGIN
        RETURN QUERY
          SELECT
            rec_concepto.id_fin_concepto_pago,
            rec_concepto.nombre_concepto,
            rec_concepto.descripcion,
            calc.*
          FROM fn_calcular_arancel_con_descuento(
                   rec_concepto.id_fin_concepto_pago,
                   p_id_programa_aprobado,
                   p_id_tipo_beneficiario,
                   p_id_convenio
               ) calc;
      EXCEPTION WHEN OTHERS THEN
        -- Si no hay arancel configurado, saltarlo
        CONTINUE;
      END;
    END LOOP;
END;
$$;

COMMENT ON FUNCTION fn_obtener_conceptos_pago_con_aranceles IS
  'Obtiene conceptos de pago con aranceles y descuentos según tipo de beneficiario y convenio';

-- ============================================
-- 3. FUNCIÓN: Generar obligaciones con aranceles
-- ============================================

CREATE OR REPLACE FUNCTION fn_generar_obligaciones_pago_matricula_regular_v2(
  p_cod_matricula INTEGER,
  p_id_grupo INTEGER,
  p_id_tipo_beneficiario INTEGER,
  p_user_reg INTEGER,
  p_id_convenio INTEGER DEFAULT NULL
)
  RETURNS VOID
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_programa_aprobado INTEGER;
  rec_concepto RECORD;
BEGIN
  -- Obtener programa aprobado del grupo
  SELECT id_aca_programa_aprobado
  INTO v_id_programa_aprobado
  FROM ins_grupo
  WHERE id_ins_grupo = p_id_grupo;

  IF v_id_programa_aprobado IS NULL THEN
    RAISE EXCEPTION 'Grupo con ID % no encontrado', p_id_grupo;
  END IF;

  -- Generar obligaciones usando aranceles
  FOR rec_concepto IN
    SELECT *
    FROM fn_obtener_conceptos_pago_con_aranceles(
        v_id_programa_aprobado,
        p_id_tipo_beneficiario,
        p_id_convenio
         )
    LOOP
      -- Lógica especial: Primera impresión de certificado gratuita
      IF rec_concepto.id_fin_concepto_pago = 3 THEN
        INSERT INTO fin_obligacion_pago(
          cod_ins_matricula,
          id_fin_concepto_pago,
          id_fin_arancel,
          id_descuento_convenio,
          deuda_sin_descuento,
          deuda_con_descuento,
          saldo_pendiente,
          estado_obligacion_pago,
          observacion,
          fecha_reg,
          user_reg
        ) VALUES (
                   p_cod_matricula,
                   3,
                   rec_concepto.id_arancel_aplicado,
                   rec_concepto.id_descuento_aplicado,
                   rec_concepto.monto_base,
                   0.00,
                   0.00,
                   'PAGADO',
                   'Primera impresión gratuita - Estudiante Regular',
                   CURRENT_TIMESTAMP,
                   p_user_reg
                 );
        CONTINUE;
      END IF;

      -- Resto de conceptos
      INSERT INTO fin_obligacion_pago(
        cod_ins_matricula,
        id_fin_concepto_pago,
        id_fin_arancel,
        id_descuento_convenio,
        deuda_sin_descuento,
        deuda_con_descuento,
        saldo_pendiente,
        estado_obligacion_pago,
        observacion,
        fecha_reg,
        user_reg
      ) VALUES (
                 p_cod_matricula,
                 rec_concepto.id_fin_concepto_pago,
                 rec_concepto.id_arancel_aplicado,
                 rec_concepto.id_descuento_aplicado,
                 rec_concepto.monto_base,
                 rec_concepto.monto_final,
                 rec_concepto.monto_final,
                 'PENDIENTE',
                 rec_concepto.detalle_descuento,
                 CURRENT_TIMESTAMP,
                 p_user_reg
               );
    END LOOP;
END;
$$;

COMMENT ON FUNCTION fn_generar_obligaciones_pago_matricula_regular_v2 IS
  'V2: Genera obligaciones de pago usando sistema de aranceles con tipos de beneficiario';

-- ============================================
-- 4. ÍNDICES PARA OPTIMIZACIÓN
-- ============================================

CREATE INDEX IF NOT EXISTS idx_arancel_concepto_tipo
  ON fin_arancel(id_fin_concepto_pago, id_tipo_beneficiario, id_aca_programa_aprobado)
  WHERE estado_arancel = 'ACTIVO';

CREATE INDEX IF NOT EXISTS idx_descuento_convenio_concepto
  ON fin_descuento_convenio(id_convenio, id_fin_concepto_pago, id_aca_programa_aprobado)
  WHERE estado_descuento_convenio = 'ACTIVO';

CREATE INDEX IF NOT EXISTS idx_obligacion_arancel
  ON fin_obligacion_pago(id_fin_arancel)
  WHERE id_fin_arancel IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_obligacion_descuento
  ON fin_obligacion_pago(id_descuento_convenio)
  WHERE id_descuento_convenio IS NOT NULL;

-- ============================================
-- 5. DATOS INICIALES: Tipos de Beneficiario
-- ============================================

INSERT INTO fin_tipo_beneficiario (nombre_tipo, descripcion, estado_tipo_beneficiario, fecha_reg, user_reg)
VALUES
  ('ESTUDIANTE REGULAR', 'Estudiante matriculado regularmente en programa académico', 'ACTIVO', CURRENT_TIMESTAMP, 1),
  ('NACIONAL', 'Ciudadano boliviano', 'ACTIVO', CURRENT_TIMESTAMP, 1),
  ('EXTRANJERO', 'Ciudadano extranjero', 'ACTIVO', CURRENT_TIMESTAMP, 1)
ON CONFLICT DO NOTHING;

-- ============================================
-- 6. COMENTARIOS EN CAMPOS DEPRECADOS
-- ============================================

COMMENT ON COLUMN fin_obligacion_pago.id_aca_parametro IS
  'DEPRECADO - Usar id_fin_arancel. Se mantiene para datos históricos';

COMMENT ON COLUMN aca_programa_aprobado.precio_matricula IS
  'DEPRECADO - Usar fin_arancel. Se mantiene para datos históricos';

COMMENT ON COLUMN aca_programa_aprobado.precio_colegiatura IS
  'DEPRECADO - Usar fin_arancel. Se mantiene para datos históricos';

COMMENT ON COLUMN aca_programa_aprobado.precio_titulacion IS
  'DEPRECADO - Usar fin_arancel. Se mantiene para datos históricos';

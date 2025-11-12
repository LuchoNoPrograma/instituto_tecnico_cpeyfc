-- =====================================================================================================================
-- Migration V22: Refactorización del Sistema de Aranceles
-- =====================================================================================================================
-- Propósito: Deprecar campos de precio directo en aca_programa_aprobado y migrar a sistema de aranceles (fin_arancel)
--            Los aranceles permiten pricing diferenciado por tipo de estudiante, periodo, y convenios.
--
-- IMPORTANTE: Este archivo usa SOLO las columnas que EXISTEN en tablas.sql
--
-- Cambios principales:
-- 1. Hacer nullable los campos precio_* en aca_programa_aprobado (actualmente NOT NULL)
-- 2. Actualizar funciones legacy de registro/modificación de programa
-- 3. Crear nuevas funciones para gestión de aranceles
-- 4. Actualizar vistas para marcar campos de precio como deprecated
-- =====================================================================================================================

-- =====================================================================================================================
-- PARTE 1: MODIFICACIÓN DE TABLA aca_programa_aprobado
-- =====================================================================================================================

-- Hacer nullable los campos de precio (actualmente son NOT NULL)
ALTER TABLE aca_programa_aprobado
  ALTER COLUMN precio_matricula DROP NOT NULL,
  ALTER COLUMN precio_colegiatura DROP NOT NULL;

-- Comentar que los campos están deprecated
COMMENT ON COLUMN aca_programa_aprobado.precio_matricula IS
'[DEPRECATED] Usar fin_arancel en su lugar. Campo mantenido para datos históricos.';

COMMENT ON COLUMN aca_programa_aprobado.precio_colegiatura IS
'[DEPRECATED] Usar fin_arancel en su lugar. Campo mantenido para datos históricos.';

COMMENT ON COLUMN aca_programa_aprobado.precio_titulacion IS
'[DEPRECATED] Usar fin_arancel en su lugar. Campo mantenido para datos históricos.';


-- =====================================================================================================================
-- PARTE 2: ACTUALIZACIÓN DE FUNCIONES LEGACY DE PROGRAMA
-- =====================================================================================================================

-- Mantener funciones legacy pero deprecarlas con comentarios
COMMENT ON FUNCTION fn_registrar_programa_aprobado(integer, integer, integer, integer, integer, character varying, character varying, numeric, numeric, numeric, date, date, integer) IS
'[DEPRECATED] Esta función usa precios directos. Para nuevos programas, registrar sin precios y luego configurar fin_arancel.';

COMMENT ON FUNCTION fn_modificar_programa_aprobado(integer, integer, integer, integer, integer, integer, character varying, numeric, numeric, numeric, date, date, character varying, character varying, integer) IS
'[DEPRECATED] Esta función modifica precios directos. Usar fin_arancel para gestión de precios.';

COMMENT ON FUNCTION fn_obtener_conceptos_pago_programa_aprobado(integer) IS
'[DEPRECATED] Esta función usa precios directos del programa. Usar fn_obtener_conceptos_arancel en su lugar.';


-- =====================================================================================================================
-- PARTE 3: NUEVAS FUNCIONES PARA GESTIÓN DE ARANCELES
-- =====================================================================================================================

-- Función: fn_registrar_arancel
-- Usa las columnas REALES de las tablas
-- =====================================================================================================================
CREATE OR REPLACE FUNCTION public.fn_registrar_arancel(
  p_id_aca_programa_aprobado integer,
  p_id_aca_periodo integer,
  p_id_aca_tipo_estudiante integer,
  p_nombre_arancel character varying,
  p_nro_resolucion character varying,
  p_fecha_aprobacion date,
  p_fecha_inicio_vigencia date,
  p_fecha_fin_vigencia date,
  p_detalles jsonb,  -- Array de {id_fin_concepto_arancel, monto_concepto, orden_aplicacion}
  p_user_reg integer
)
RETURNS TABLE(
  flag boolean,
  mensaje text,
  id_arancel integer
)
LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_arancel INT;
  v_detalle jsonb;
  v_total_monto NUMERIC := 0;
BEGIN
  -- Validar que el programa aprobado existe
  IF NOT EXISTS(
    SELECT 1 FROM aca_programa_aprobado
    WHERE id_aca_programa_aprobado = p_id_aca_programa_aprobado
      AND estado_programa_aprobado != 'ELIMINADO'
  ) THEN
    RETURN QUERY SELECT
      false,
      'El programa aprobado no existe o está eliminado'::text,
      NULL::integer;
    RETURN;
  END IF;

  -- Validar que el periodo existe (si se proporciona)
  IF p_id_aca_periodo IS NOT NULL AND NOT EXISTS(
    SELECT 1 FROM aca_periodo
    WHERE id_aca_periodo = p_id_aca_periodo
      AND estado_periodo != 'ELIMINADO'
  ) THEN
    RETURN QUERY SELECT
      false,
      'El periodo académico no existe o está eliminado'::text,
      NULL::integer;
    RETURN;
  END IF;

  -- Validar que el tipo de estudiante existe
  IF NOT EXISTS(
    SELECT 1 FROM aca_tipo_estudiante
    WHERE id_aca_tipo_estudiante = p_id_aca_tipo_estudiante
      AND estado_tipo_estudiante != 'ELIMINADO'
  ) THEN
    RETURN QUERY SELECT
      false,
      'El tipo de estudiante no existe o está eliminado'::text,
      NULL::integer;
    RETURN;
  END IF;

  -- Validar fechas de vigencia
  IF p_fecha_fin_vigencia IS NOT NULL AND p_fecha_inicio_vigencia > p_fecha_fin_vigencia THEN
    RETURN QUERY SELECT
      false,
      'La fecha de inicio de vigencia no puede ser posterior a la fecha de fin'::text,
      NULL::integer;
    RETURN;
  END IF;

  -- Validar que hay detalles
  IF p_detalles IS NULL OR jsonb_array_length(p_detalles) = 0 THEN
    RETURN QUERY SELECT
      false,
      'Debe proporcionar al menos un detalle de arancel'::text,
      NULL::integer;
    RETURN;
  END IF;

  -- Insertar el arancel con las columnas REALES de la tabla fin_arancel
  INSERT INTO fin_arancel(
    id_aca_programa_aprobado,
    id_aca_periodo,
    id_aca_tipo_estudiante,
    nombre_arancel,
    nro_resolucion,
    fecha_aprobacion,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    estado_arancel,
    fecha_reg,
    user_reg
  ) VALUES (
    p_id_aca_programa_aprobado,
    p_id_aca_periodo,
    p_id_aca_tipo_estudiante,
    p_nombre_arancel,
    p_nro_resolucion,
    p_fecha_aprobacion,
    p_fecha_inicio_vigencia,
    p_fecha_fin_vigencia,
    'ACTIVO',
    CURRENT_TIMESTAMP,
    p_user_reg
  )
  RETURNING id_fin_arancel INTO v_id_arancel;

  -- Insertar los detalles del arancel con las columnas REALES de fin_detalle_arancel
  FOR v_detalle IN SELECT * FROM jsonb_array_elements(p_detalles)
  LOOP
    -- Validar que el concepto existe
    IF NOT EXISTS(
      SELECT 1 FROM fin_concepto_arancel
      WHERE id_fin_concepto_arancel = (v_detalle->>'id_fin_concepto_arancel')::integer
        AND estado_concepto != 'ELIMINADO'
    ) THEN
      -- Rollback implícito por excepción
      RAISE EXCEPTION 'El concepto de arancel con ID % no existe o está eliminado',
        (v_detalle->>'id_fin_concepto_arancel')::integer;
    END IF;

    -- Validar monto positivo
    IF (v_detalle->>'monto_concepto')::numeric <= 0 THEN
      RAISE EXCEPTION 'El monto debe ser mayor a 0 para el concepto %',
        (v_detalle->>'id_fin_concepto_arancel')::integer;
    END IF;

    -- Insertar detalle con las columnas REALES: monto_concepto, orden_aplicacion
    INSERT INTO fin_detalle_arancel(
      id_fin_arancel,
      id_fin_concepto_arancel,
      monto_concepto,
      orden_aplicacion,
      fecha_reg,
      user_reg
    ) VALUES (
      v_id_arancel,
      (v_detalle->>'id_fin_concepto_arancel')::integer,
      (v_detalle->>'monto_concepto')::numeric,
      COALESCE((v_detalle->>'orden_aplicacion')::integer, 1),
      CURRENT_TIMESTAMP,
      p_user_reg
    );

    v_total_monto := v_total_monto + (v_detalle->>'monto_concepto')::numeric;
  END LOOP;

  -- Retornar éxito
  RETURN QUERY SELECT
    true,
    format('Arancel registrado exitosamente con %s conceptos. Monto total: %s Bs.',
      jsonb_array_length(p_detalles), v_total_monto)::text,
    v_id_arancel;

END;
$function$;

COMMENT ON FUNCTION fn_registrar_arancel IS
'Registra un arancel completo con sus detalles (conceptos) en una transacción. Los detalles se pasan como JSONB array con las columnas reales de las tablas.';


-- Función: fn_obtener_conceptos_arancel
-- Usa las columnas REALES de las tablas
-- =====================================================================================================================
CREATE OR REPLACE FUNCTION public.fn_obtener_conceptos_arancel(
  p_id_aca_programa_aprobado integer,
  p_id_aca_tipo_estudiante integer,
  p_numero_periodo integer,
  p_id_fin_convenio integer DEFAULT NULL
)
RETURNS TABLE(
  id_fin_concepto_arancel integer,
  nombre_concepto character varying,
  descripcion text,
  monto_base numeric,
  descuento_aplicado numeric,
  monto_final numeric,
  origen_descuento character varying
)
LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_arancel INT;
  v_descuento_convenio NUMERIC := 0;
  v_tipo_descuento_convenio VARCHAR;
  v_monto_descuento_convenio NUMERIC := 0;
BEGIN
  -- Buscar arancel vigente para el programa y tipo de estudiante
  SELECT a.id_fin_arancel INTO v_id_arancel
  FROM fin_arancel a
  WHERE a.id_aca_programa_aprobado = p_id_aca_programa_aprobado
    AND a.id_aca_tipo_estudiante = p_id_aca_tipo_estudiante
    AND a.estado_arancel != 'ELIMINADO'
    AND a.fecha_inicio_vigencia <= CURRENT_DATE
    AND (a.fecha_fin_vigencia IS NULL OR a.fecha_fin_vigencia >= CURRENT_DATE)
  ORDER BY a.fecha_inicio_vigencia DESC
  LIMIT 1;

  IF v_id_arancel IS NULL THEN
    RAISE EXCEPTION 'No existe un arancel vigente para el programa y tipo de estudiante especificados';
  END IF;

  -- Si se proporciona convenio, obtener descuento usando las columnas REALES
  IF p_id_fin_convenio IS NOT NULL THEN
    SELECT
      c.tipo_descuento,
      COALESCE(c.porcentaje_descuento, 0),
      COALESCE(c.monto_descuento, 0)
    INTO v_tipo_descuento_convenio, v_descuento_convenio, v_monto_descuento_convenio
    FROM fin_convenio c
    WHERE c.id_fin_convenio = p_id_fin_convenio
      AND c.estado_convenio != 'ELIMINADO'
      AND c.fecha_inicio_vigencia <= CURRENT_DATE
      AND (c.fecha_fin_vigencia IS NULL OR c.fecha_fin_vigencia >= CURRENT_DATE);

    IF NOT FOUND THEN
      RAISE WARNING 'El convenio especificado no existe o no está vigente. No se aplicará descuento.';
      v_descuento_convenio := 0;
      v_monto_descuento_convenio := 0;
    END IF;
  END IF;

  -- Retornar conceptos con descuentos aplicados usando las columnas REALES
  RETURN QUERY
  SELECT
    ca.id_fin_concepto_arancel,
    ca.nombre_concepto,
    ca.descripcion,
    da.monto_concepto AS monto_base,
    -- Calcular descuento: primero el del arancel, luego el del convenio
    (
      COALESCE(
        CASE
          WHEN desca.tipo_descuento = 'PORCENTAJE'
          THEN (da.monto_concepto * desca.porcentaje_descuento / 100)
          WHEN desca.tipo_descuento = 'MONTO'
          THEN desca.monto_descuento
          ELSE 0
        END,
        0
      ) +
      CASE
        WHEN v_tipo_descuento_convenio = 'PORCENTAJE'
        THEN (da.monto_concepto * v_descuento_convenio / 100)
        WHEN v_tipo_descuento_convenio = 'MONTO'
        THEN v_monto_descuento_convenio
        ELSE 0
      END
    ) AS descuento_aplicado,
    -- Monto final
    (
      da.monto_concepto -
      COALESCE(
        CASE
          WHEN desca.tipo_descuento = 'PORCENTAJE'
          THEN (da.monto_concepto * desca.porcentaje_descuento / 100)
          WHEN desca.tipo_descuento = 'MONTO'
          THEN desca.monto_descuento
          ELSE 0
        END,
        0
      ) -
      CASE
        WHEN v_tipo_descuento_convenio = 'PORCENTAJE'
        THEN (da.monto_concepto * v_descuento_convenio / 100)
        WHEN v_tipo_descuento_convenio = 'MONTO'
        THEN v_monto_descuento_convenio
        ELSE 0
      END
    ) AS monto_final,
    -- Origen del descuento
    CASE
      WHEN desca.id_fin_descuento_arancel IS NOT NULL AND p_id_fin_convenio IS NOT NULL
      THEN 'ARANCEL + CONVENIO'
      WHEN desca.id_fin_descuento_arancel IS NOT NULL
      THEN 'ARANCEL'
      WHEN p_id_fin_convenio IS NOT NULL
      THEN 'CONVENIO'
      ELSE 'SIN DESCUENTO'
    END AS origen_descuento
  FROM fin_detalle_arancel da
  JOIN fin_concepto_arancel ca ON da.id_fin_concepto_arancel = ca.id_fin_concepto_arancel
  LEFT JOIN fin_descuento_arancel desca ON (
    desca.id_fin_arancel = da.id_fin_arancel
    AND desca.aplica_desde_periodo <= p_numero_periodo
    AND desca.estado_descuento != 'ELIMINADO'
  )
  WHERE da.id_fin_arancel = v_id_arancel
    AND ca.estado_concepto != 'ELIMINADO'
  ORDER BY da.orden_aplicacion;

END;
$function$;

COMMENT ON FUNCTION fn_obtener_conceptos_arancel IS
'Obtiene los conceptos de pago con montos y descuentos aplicados según arancel, tipo de estudiante, periodo y convenio opcional. Usa las columnas reales de las tablas.';


-- =====================================================================================================================
-- PARTE 4: ACTUALIZACIÓN DE VISTAS
-- =====================================================================================================================

-- Vista: vista_programas_aprobados (marcar campos deprecated)
-- =====================================================================================================================
CREATE OR REPLACE VIEW vista_programas_aprobados AS
SELECT
  pa.id_aca_programa_aprobado,
  p.id_aca_programa,
  p.nombre_programa,
  p.sigla AS programa_sigla,
  p.descripcion AS programa_descripcion,
  a.id_aca_area,
  a.nombre_area,
  m.id_aca_modalidad,
  m.nombre_modalidad,
  pe.id_aca_plan_estudio,
  pe.anho AS plan_anho,
  CASE
    WHEN pe.vigente = true
    THEN concat(pe.anho, ' (VIGENTE)')::character varying
    ELSE pe.anho::character varying
  END AS plan_descripcion,
  v.cod_version,
  pa.gestion,
  pa.estado_programa_aprobado,
  pa.cod_certificado_ceub,
  -- Campos deprecated: mantener para compatibilidad
  pa.precio_matricula AS precio_matricula_deprecated,
  pa.precio_colegiatura AS precio_colegiatura_deprecated,
  pa.precio_titulacion AS precio_titulacion_deprecated,
  pa.fecha_inicio_vigencia,
  pa.fecha_fin_vigencia,
  COALESCE(pa.imagen_programa_url, p.imagen_url) AS imagen_url,
  pa.fecha_reg,
  pa.fecha_mod,
  pa.user_reg,
  pa.user_mod
FROM aca_programa_aprobado pa
JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
JOIN aca_area a ON p.id_aca_area = a.id_aca_area
JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
LEFT JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
LEFT JOIN aca_version v ON pa.id_aca_version = v.id_aca_version
WHERE pa.estado_programa_aprobado != 'ELIMINADO'
  AND p.estado_programa != 'ELIMINADO'
  AND a.estado_area != 'ELIMINADO'
  AND m.estado_modalidad != 'ELIMINADO'
ORDER BY pa.gestion DESC, p.nombre_programa;

COMMENT ON VIEW vista_programas_aprobados IS
'Vista de programas aprobados. Los campos precio_*_deprecated mantienen compatibilidad pero deben usar aranceles (fin_arancel).';


-- =====================================================================================================================
-- PARTE 5: NUEVAS VISTAS PARA EL SISTEMA DE ARANCELES (usando columnas REALES)
-- =====================================================================================================================

-- Vista: vista_aranceles_vigentes
-- =====================================================================================================================
CREATE OR REPLACE VIEW vista_aranceles_vigentes AS
SELECT
  a.id_fin_arancel,
  a.id_aca_programa_aprobado,
  prog.nombre_programa,
  modal.nombre_modalidad,
  pa.gestion,
  per.nombre_periodo,
  per.numero_periodo,
  te.nombre_tipo AS tipo_estudiante,
  te.descripcion AS tipo_estudiante_descripcion,
  a.nombre_arancel,
  a.nro_resolucion,
  a.fecha_aprobacion,
  a.fecha_inicio_vigencia,
  a.fecha_fin_vigencia,
  (
    SELECT COUNT(*)
    FROM fin_detalle_arancel da
    WHERE da.id_fin_arancel = a.id_fin_arancel
  ) AS total_conceptos,
  (
    SELECT SUM(da.monto_concepto)
    FROM fin_detalle_arancel da
    WHERE da.id_fin_arancel = a.id_fin_arancel
  ) AS monto_total,
  a.estado_arancel,
  a.fecha_reg,
  a.user_reg,
  a.fecha_mod,
  a.user_mod
FROM fin_arancel a
JOIN aca_programa_aprobado pa ON a.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
JOIN aca_modalidad modal ON pa.id_aca_modalidad = modal.id_aca_modalidad
LEFT JOIN aca_periodo per ON a.id_aca_periodo = per.id_aca_periodo
JOIN aca_tipo_estudiante te ON a.id_aca_tipo_estudiante = te.id_aca_tipo_estudiante
WHERE a.estado_arancel != 'ELIMINADO'
  AND a.fecha_inicio_vigencia <= CURRENT_DATE
  AND (a.fecha_fin_vigencia IS NULL OR a.fecha_fin_vigencia >= CURRENT_DATE)
ORDER BY prog.nombre_programa, te.nombre_tipo, a.fecha_inicio_vigencia DESC;

COMMENT ON VIEW vista_aranceles_vigentes IS
'Vista de aranceles activos y vigentes con información completa del programa y totales calculados. Usa columnas reales de las tablas.';


-- Vista: vista_aranceles_detalle
-- =====================================================================================================================
CREATE OR REPLACE VIEW vista_aranceles_detalle AS
SELECT
  a.id_fin_arancel,
  a.id_aca_programa_aprobado,
  prog.nombre_programa,
  pa.gestion,
  te.nombre_tipo AS tipo_estudiante,
  a.nombre_arancel,
  ca.nombre_concepto,
  ca.tipo_concepto,
  da.monto_concepto,
  da.orden_aplicacion,
  CASE
    WHEN a.fecha_inicio_vigencia <= CURRENT_DATE
      AND (a.fecha_fin_vigencia IS NULL OR a.fecha_fin_vigencia >= CURRENT_DATE)
    THEN 'VIGENTE'
    WHEN a.fecha_inicio_vigencia > CURRENT_DATE
    THEN 'FUTURO'
    ELSE 'VENCIDO'
  END AS estado_vigencia
FROM fin_arancel a
JOIN fin_detalle_arancel da ON a.id_fin_arancel = da.id_fin_arancel
JOIN fin_concepto_arancel ca ON da.id_fin_concepto_arancel = ca.id_fin_concepto_arancel
JOIN aca_programa_aprobado pa ON a.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
JOIN aca_tipo_estudiante te ON a.id_aca_tipo_estudiante = te.id_aca_tipo_estudiante
WHERE a.estado_arancel != 'ELIMINADO'
  AND ca.estado_concepto != 'ELIMINADO'
ORDER BY prog.nombre_programa, te.nombre_tipo, da.orden_aplicacion;

COMMENT ON VIEW vista_aranceles_detalle IS
'Vista detallada de aranceles con todos los conceptos y montos desglosados. Usa columnas reales de las tablas.';


-- =====================================================================================================================
-- FIN DE MIGRACIÓN V22
-- =====================================================================================================================

-- =====================================================================================================================
-- Migration V23: Refactorización del Sistema de Aranceles
-- =====================================================================================================================
-- Propósito: Deprecar campos de precio directo en aca_programa_aprobado y migrar a sistema de aranceles (fin_arancel)
--            Los aranceles permiten pricing diferenciado por tipo de estudiante, periodo, y convenios.
--            Los parámetros de programa ahora solo almacenan metadata, no descuentos.
--
-- Cambios principales:
-- 1. Hacer nullable los campos precio_* en aca_programa_aprobado (datos históricos)
-- 2. Actualizar funciones de registro/modificación de programa (eliminar params de precio)
-- 3. Actualizar vistas para marcar campos de precio como deprecated
-- 4. Crear nuevas funciones para gestión de aranceles
-- 5. Deprecar fn_obtener_conceptos_pago_programa_aprobado (usar aranceles en su lugar)
-- =====================================================================================================================

-- =====================================================================================================================
-- PARTE 1: MODIFICACIÓN DE TABLA aca_programa_aprobado
-- =====================================================================================================================

-- Comentar que los campos están deprecated pero mantenerlos para datos históricos
COMMENT ON COLUMN aca_programa_aprobado.precio_matricula IS
'[DEPRECATED] Usar fin_arancel en su lugar. Campo mantenido para datos históricos.';

COMMENT ON COLUMN aca_programa_aprobado.precio_colegiatura IS
'[DEPRECATED] Usar fin_arancel en su lugar. Campo mantenido para datos históricos.';

COMMENT ON COLUMN aca_programa_aprobado.precio_titulacion IS
'[DEPRECATED] Usar fin_arancel en su lugar. Campo mantenido para datos históricos.';

-- Asegurar que los campos sean nullable (ya lo son, pero lo confirmamos)
ALTER TABLE aca_programa_aprobado
  ALTER COLUMN precio_matricula DROP NOT NULL,
  ALTER COLUMN precio_colegiatura DROP NOT NULL,
  ALTER COLUMN precio_titulacion DROP NOT NULL;


-- =====================================================================================================================
-- PARTE 2: ACTUALIZACIÓN DE FUNCIONES DE PROGRAMA
-- =====================================================================================================================

-- Función: fn_registrar_programa_aprobado (SIN parámetros de precio)
-- =====================================================================================================================
CREATE OR REPLACE FUNCTION public.fn_registrar_programa_aprobado(
  p_id_aca_programa integer,
  p_id_aca_nivel integer,
  p_id_aca_modalidad integer,
  p_id_aca_plan_estudio integer,
  p_id_aca_version integer,
  p_gestion character varying,
  p_cod_certificado_ceub character varying,
  p_fecha_inicio_vigencia date,
  p_fecha_fin_vigencia date,
  p_sistema_programa character varying,
  p_imagen_programa_url character varying,
  p_user_reg character varying
)
RETURNS TABLE(
  flag boolean,
  mensaje text,
  id_programa_aprobado integer
)
LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_programa_aprobado INT;
  v_programa_existente INT;
  v_nombre_programa VARCHAR;
  v_sigla_modalidad VARCHAR;
  v_nombre_nivel VARCHAR;
BEGIN
  -- Validar que el programa existe
  IF NOT EXISTS(
    SELECT 1 FROM aca_programa
    WHERE id_aca_programa = p_id_aca_programa
      AND estado_programa != 'ELIMINADO'
  ) THEN
    RETURN QUERY SELECT
      false,
      'El programa especificado no existe o está eliminado'::text,
      NULL::integer;
    RETURN;
  END IF;

  -- Validar que el nivel existe
  IF NOT EXISTS(
    SELECT 1 FROM aca_nivel
    WHERE id_aca_nivel = p_id_aca_nivel
      AND estado_nivel != 'ELIMINADO'
  ) THEN
    RETURN QUERY SELECT
      false,
      'El nivel especificado no existe o está eliminado'::text,
      NULL::integer;
    RETURN;
  END IF;

  -- Validar que la modalidad existe
  IF NOT EXISTS(
    SELECT 1 FROM aca_modalidad
    WHERE id_aca_modalidad = p_id_aca_modalidad
      AND estado_modalidad != 'ELIMINADO'
  ) THEN
    RETURN QUERY SELECT
      false,
      'La modalidad especificada no existe o está eliminada'::text,
      NULL::integer;
    RETURN;
  END IF;

  -- Validar sistema de programa
  IF p_sistema_programa NOT IN ('REGULAR', 'ACELERADO', 'MODULAR') THEN
    RETURN QUERY SELECT
      false,
      'El sistema de programa debe ser REGULAR, ACELERADO o MODULAR'::text,
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

  -- Validar que no existe otro programa aprobado activo con la misma combinación
  SELECT COUNT(*), prog.nombre_programa, mod.sigla, niv.nombre_nivel
  INTO v_programa_existente, v_nombre_programa, v_sigla_modalidad, v_nombre_nivel
  FROM aca_programa_aprobado pa
  JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
  JOIN aca_modalidad mod ON pa.id_aca_modalidad = mod.id_aca_modalidad
  JOIN aca_nivel niv ON pa.id_aca_nivel = niv.id_aca_nivel
  WHERE pa.id_aca_programa = p_id_aca_programa
    AND pa.id_aca_nivel = p_id_aca_nivel
    AND pa.id_aca_modalidad = p_id_aca_modalidad
    AND pa.gestion = p_gestion
    AND pa.estado_programa_aprobado != 'ELIMINADO'
  GROUP BY prog.nombre_programa, mod.sigla, niv.nombre_nivel;

  IF v_programa_existente > 0 THEN
    RETURN QUERY SELECT
      false,
      format('Ya existe un programa aprobado: %s - %s (%s) para la gestión %s',
        v_nombre_programa, v_sigla_modalidad, v_nombre_nivel, p_gestion)::text,
      NULL::integer;
    RETURN;
  END IF;

  -- Insertar el programa aprobado (SIN campos de precio)
  INSERT INTO aca_programa_aprobado(
    id_aca_programa,
    id_aca_nivel,
    id_aca_modalidad,
    id_aca_plan_estudio,
    id_aca_version,
    gestion,
    sistema_programa,
    cod_certificado_ceub,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    imagen_programa_url,
    estado_programa_aprobado,
    fecha_reg,
    user_reg
  ) VALUES (
    p_id_aca_programa,
    p_id_aca_nivel,
    p_id_aca_modalidad,
    p_id_aca_plan_estudio,
    p_id_aca_version,
    p_gestion,
    p_sistema_programa,
    p_cod_certificado_ceub,
    p_fecha_inicio_vigencia,
    p_fecha_fin_vigencia,
    p_imagen_programa_url,
    'ACTIVO',
    CURRENT_TIMESTAMP,
    p_user_reg
  )
  RETURNING id_aca_programa_aprobado INTO v_id_programa_aprobado;

  -- Retornar éxito
  RETURN QUERY SELECT
    true,
    format('Programa aprobado registrado exitosamente. Ahora debe configurar los aranceles correspondientes.')::text,
    v_id_programa_aprobado;

END;
$function$;

COMMENT ON FUNCTION fn_registrar_programa_aprobado IS
'Registra un programa aprobado SIN precios directos. Los aranceles deben configurarse por separado usando fin_arancel.';


-- Función: fn_modificar_programa_aprobado (SIN parámetros de precio)
-- =====================================================================================================================
CREATE OR REPLACE FUNCTION public.fn_modificar_programa_aprobado(
  p_id_programa_aprobado integer,
  p_id_aca_plan_estudio integer,
  p_id_aca_version integer,
  p_gestion character varying,
  p_cod_certificado_ceub character varying,
  p_fecha_inicio_vigencia date,
  p_fecha_fin_vigencia date,
  p_sistema_programa character varying,
  p_imagen_programa_url character varying,
  p_estado_programa_aprobado character varying,
  p_user_mod character varying
)
RETURNS TABLE(
  flag boolean,
  mensaje text
)
LANGUAGE plpgsql
AS $function$
DECLARE
  v_programa_existente INT;
BEGIN
  -- Validar que el programa aprobado existe
  IF NOT EXISTS(
    SELECT 1 FROM aca_programa_aprobado
    WHERE id_aca_programa_aprobado = p_id_programa_aprobado
      AND estado_programa_aprobado != 'ELIMINADO'
  ) THEN
    RETURN QUERY SELECT
      false,
      'El programa aprobado especificado no existe o está eliminado'::text;
    RETURN;
  END IF;

  -- Validar sistema de programa
  IF p_sistema_programa NOT IN ('REGULAR', 'ACELERADO', 'MODULAR') THEN
    RETURN QUERY SELECT
      false,
      'El sistema de programa debe ser REGULAR, ACELERADO o MODULAR'::text;
    RETURN;
  END IF;

  -- Validar estado
  IF p_estado_programa_aprobado NOT IN ('ACTIVO', 'INACTIVO', 'ELIMINADO') THEN
    RETURN QUERY SELECT
      false,
      'El estado debe ser ACTIVO, INACTIVO o ELIMINADO'::text;
    RETURN;
  END IF;

  -- Validar fechas de vigencia
  IF p_fecha_fin_vigencia IS NOT NULL AND p_fecha_inicio_vigencia > p_fecha_fin_vigencia THEN
    RETURN QUERY SELECT
      false,
      'La fecha de inicio de vigencia no puede ser posterior a la fecha de fin'::text;
    RETURN;
  END IF;

  -- Actualizar el programa aprobado (SIN campos de precio)
  UPDATE aca_programa_aprobado
  SET
    id_aca_plan_estudio = p_id_aca_plan_estudio,
    id_aca_version = p_id_aca_version,
    gestion = p_gestion,
    sistema_programa = p_sistema_programa,
    cod_certificado_ceub = p_cod_certificado_ceub,
    fecha_inicio_vigencia = p_fecha_inicio_vigencia,
    fecha_fin_vigencia = p_fecha_fin_vigencia,
    imagen_programa_url = p_imagen_programa_url,
    estado_programa_aprobado = p_estado_programa_aprobado,
    fecha_mod = CURRENT_TIMESTAMP,
    user_mod = p_user_mod
  WHERE id_aca_programa_aprobado = p_id_programa_aprobado;

  -- Retornar éxito
  RETURN QUERY SELECT
    true,
    'Programa aprobado actualizado exitosamente. Recuerde actualizar los aranceles si es necesario.'::text;

END;
$function$;

COMMENT ON FUNCTION fn_modificar_programa_aprobado IS
'Modifica un programa aprobado SIN afectar precios. Los aranceles deben gestionarse por separado usando fin_arancel.';


-- Función: fn_obtener_conceptos_pago_programa_aprobado [DEPRECATED]
-- =====================================================================================================================
COMMENT ON FUNCTION fn_obtener_conceptos_pago_programa_aprobado IS
'[DEPRECATED] Esta función usa precios directos del programa. Usar fn_obtener_conceptos_arancel en su lugar.';


-- =====================================================================================================================
-- PARTE 3: NUEVAS FUNCIONES PARA GESTIÓN DE ARANCELES
-- =====================================================================================================================

-- Función: fn_registrar_arancel
-- =====================================================================================================================
CREATE OR REPLACE FUNCTION public.fn_registrar_arancel(
  p_id_aca_programa_aprobado integer,
  p_id_aca_gestion integer,
  p_id_aca_tipo_estudiante integer,
  p_nombre_arancel character varying,
  p_descripcion text,
  p_fecha_inicio_vigencia date,
  p_fecha_fin_vigencia date,
  p_detalles jsonb,  -- Array de {id_fin_concepto_arancel, monto, orden}
  p_user_reg character varying
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
  v_orden INT;
BEGIN
  -- Validar que el programa aprobado existe
  IF NOT EXISTS(
    SELECT 1 FROM aca_programa_aprobado
    WHERE id_aca_programa_aprobado = p_id_aca_programa_aprobado
      AND estado_programa_aprobado = 'ACTIVO'
  ) THEN
    RETURN QUERY SELECT
      false,
      'El programa aprobado no existe o no está activo'::text,
      NULL::integer;
    RETURN;
  END IF;

  -- Validar que la gestión existe
  IF NOT EXISTS(
    SELECT 1 FROM aca_gestion
    WHERE id_aca_gestion = p_id_aca_gestion
      AND estado_gestion = 'ACTIVO'
  ) THEN
    RETURN QUERY SELECT
      false,
      'La gestión académica no existe o no está activa'::text,
      NULL::integer;
    RETURN;
  END IF;

  -- Validar que el tipo de estudiante existe
  IF NOT EXISTS(
    SELECT 1 FROM aca_tipo_estudiante
    WHERE id_aca_tipo_estudiante = p_id_aca_tipo_estudiante
      AND estado_tipo_estudiante = 'ACTIVO'
  ) THEN
    RETURN QUERY SELECT
      false,
      'El tipo de estudiante no existe o no está activo'::text,
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

  -- Insertar el arancel
  INSERT INTO fin_arancel(
    id_aca_programa_aprobado,
    id_aca_gestion,
    id_aca_tipo_estudiante,
    nombre_arancel,
    descripcion,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    estado_arancel,
    fecha_reg,
    user_reg
  ) VALUES (
    p_id_aca_programa_aprobado,
    p_id_aca_gestion,
    p_id_aca_tipo_estudiante,
    p_nombre_arancel,
    p_descripcion,
    p_fecha_inicio_vigencia,
    p_fecha_fin_vigencia,
    'ACTIVO',
    CURRENT_TIMESTAMP,
    p_user_reg
  )
  RETURNING id_fin_arancel INTO v_id_arancel;

  -- Insertar los detalles del arancel
  FOR v_detalle IN SELECT * FROM jsonb_array_elements(p_detalles)
  LOOP
    -- Validar que el concepto existe
    IF NOT EXISTS(
      SELECT 1 FROM fin_concepto_arancel
      WHERE id_fin_concepto_arancel = (v_detalle->>'id_fin_concepto_arancel')::integer
        AND estado_concepto_arancel = 'ACTIVO'
    ) THEN
      -- Rollback implícito por excepción
      RAISE EXCEPTION 'El concepto de arancel con ID % no existe o no está activo',
        (v_detalle->>'id_fin_concepto_arancel')::integer;
    END IF;

    -- Validar monto positivo
    IF (v_detalle->>'monto')::numeric <= 0 THEN
      RAISE EXCEPTION 'El monto debe ser mayor a 0 para el concepto %',
        (v_detalle->>'id_fin_concepto_arancel')::integer;
    END IF;

    -- Insertar detalle
    INSERT INTO fin_detalle_arancel(
      id_fin_arancel,
      id_fin_concepto_arancel,
      monto,
      orden,
      estado_detalle_arancel,
      fecha_reg,
      user_reg
    ) VALUES (
      v_id_arancel,
      (v_detalle->>'id_fin_concepto_arancel')::integer,
      (v_detalle->>'monto')::numeric,
      COALESCE((v_detalle->>'orden')::integer, 1),
      'ACTIVO',
      CURRENT_TIMESTAMP,
      p_user_reg
    );

    v_total_monto := v_total_monto + (v_detalle->>'monto')::numeric;
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
'Registra un arancel completo con sus detalles (conceptos) en una transacción. Los detalles se pasan como JSONB array.';


-- Función: fn_obtener_conceptos_arancel
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
  v_id_gestion INT;
  v_descuento_convenio NUMERIC := 0;
  v_tipo_descuento_convenio VARCHAR;
BEGIN
  -- Obtener gestión académica activa
  SELECT id_aca_gestion INTO v_id_gestion
  FROM aca_gestion
  WHERE estado_gestion = 'ACTIVO'
    AND fecha_inicio <= CURRENT_DATE
    AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
  ORDER BY fecha_inicio DESC
  LIMIT 1;

  IF v_id_gestion IS NULL THEN
    RAISE EXCEPTION 'No existe una gestión académica activa';
  END IF;

  -- Buscar arancel vigente para el programa, tipo de estudiante y gestión
  SELECT a.id_fin_arancel INTO v_id_arancel
  FROM fin_arancel a
  WHERE a.id_aca_programa_aprobado = p_id_aca_programa_aprobado
    AND a.id_aca_tipo_estudiante = p_id_aca_tipo_estudiante
    AND a.id_aca_gestion = v_id_gestion
    AND a.estado_arancel = 'ACTIVO'
    AND a.fecha_inicio_vigencia <= CURRENT_DATE
    AND (a.fecha_fin_vigencia IS NULL OR a.fecha_fin_vigencia >= CURRENT_DATE)
  ORDER BY a.fecha_inicio_vigencia DESC
  LIMIT 1;

  IF v_id_arancel IS NULL THEN
    RAISE EXCEPTION 'No existe un arancel vigente para el programa, tipo de estudiante y gestión especificados';
  END IF;

  -- Si se proporciona convenio, obtener descuento
  IF p_id_fin_convenio IS NOT NULL THEN
    SELECT
      COALESCE(c.descuento_porcentaje, 0),
      c.tipo_descuento
    INTO v_descuento_convenio, v_tipo_descuento_convenio
    FROM fin_convenio c
    WHERE c.id_fin_convenio = p_id_fin_convenio
      AND c.estado_convenio = 'ACTIVO'
      AND c.fecha_inicio_vigencia <= CURRENT_DATE
      AND (c.fecha_fin_vigencia IS NULL OR c.fecha_fin_vigencia >= CURRENT_DATE);

    IF NOT FOUND THEN
      RAISE WARNING 'El convenio especificado no existe o no está vigente. No se aplicará descuento.';
      v_descuento_convenio := 0;
    END IF;
  END IF;

  -- Retornar conceptos con descuentos aplicados
  RETURN QUERY
  SELECT
    ca.id_fin_concepto_arancel,
    ca.nombre_concepto,
    ca.descripcion,
    da.monto AS monto_base,
    -- Calcular descuento: primero el del arancel, luego el del convenio
    COALESCE(
      CASE
        WHEN desca.tipo_descuento = 'PORCENTAJE'
        THEN (da.monto * desca.descuento / 100)
        ELSE desca.descuento
      END,
      0
    ) +
    CASE
      WHEN v_tipo_descuento_convenio = 'PORCENTAJE'
      THEN (da.monto * v_descuento_convenio / 100)
      ELSE v_descuento_convenio
    END AS descuento_aplicado,
    -- Monto final
    da.monto -
    COALESCE(
      CASE
        WHEN desca.tipo_descuento = 'PORCENTAJE'
        THEN (da.monto * desca.descuento / 100)
        ELSE desca.descuento
      END,
      0
    ) -
    CASE
      WHEN v_tipo_descuento_convenio = 'PORCENTAJE'
      THEN (da.monto * v_descuento_convenio / 100)
      ELSE v_descuento_convenio
    END AS monto_final,
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
    AND desca.numero_periodo = p_numero_periodo
    AND desca.estado_descuento_arancel = 'ACTIVO'
  )
  WHERE da.id_fin_arancel = v_id_arancel
    AND da.estado_detalle_arancel = 'ACTIVO'
    AND ca.estado_concepto_arancel = 'ACTIVO'
  ORDER BY da.orden;

END;
$function$;

COMMENT ON FUNCTION fn_obtener_conceptos_arancel IS
'Obtiene los conceptos de pago con montos y descuentos aplicados según arancel, tipo de estudiante, periodo y convenio opcional.';


-- =====================================================================================================================
-- PARTE 4: ACTUALIZACIÓN DE VISTAS
-- =====================================================================================================================

-- Vista: vista_chatbot_programas_info (marcar campos deprecated)
-- =====================================================================================================================
CREATE OR REPLACE VIEW vista_chatbot_programas_info AS
SELECT
  pa.id_aca_programa_aprobado,
  prog.id_aca_programa,
  prog.nombre_programa,
  prog.sigla AS programa_sigla,
  area.nombre_area,
  modal.nombre_modalidad,
  pa.gestion,
  pe.anho AS plan_anho,
  v.cod_version,
  g.id_ins_grupo,
  g.nombre_grupo,
  g.gestion_inicio,
  g.fecha_inicio_inscripcion,
  g.fecha_fin_inscripcion,
  g.estado_grupo,
  CASE
    WHEN ((g.fecha_fin_inscripcion >= CURRENT_DATE) AND (g.fecha_inicio_inscripcion <= CURRENT_DATE))
    THEN 'INSCRIPCIONES ABIERTAS'::text
    WHEN (g.fecha_inicio_inscripcion > CURRENT_DATE)
    THEN 'PROXIMAMENTE'::text
    ELSE 'INSCRIPCIONES CERRADAS'::text
  END AS estado_inscripcion,
  CASE
    WHEN (g.fecha_fin_inscripcion >= CURRENT_DATE)
    THEN (g.fecha_fin_inscripcion - CURRENT_DATE)
    ELSE 0
  END AS dias_restantes,
  -- Campos deprecated: mantener para compatibilidad pero usar NULL para programas nuevos
  COALESCE(pa.precio_matricula, 0) AS precio_matricula_deprecated,
  COALESCE(pa.precio_colegiatura, 0) AS precio_colegiatura_deprecated,
  COALESCE(pa.precio_titulacion, 0) AS precio_titulacion_deprecated,
  (
    SELECT count(*)
    FROM ins_preinscripcion pre
    WHERE pre.id_aca_programa_aprobado = g.id_ins_grupo
      AND pre.estado_preinscripcion <> 'ELIMINADO'
  ) AS total_preinscritos,
  (
    SELECT count(DISTINCT pmd.id_aca_plan_modulo_detalle)
    FROM aca_plan_modulo_detalle pmd
    WHERE pmd.id_aca_plan_estudio = pa.id_aca_plan_estudio
      AND pmd.estado_plan_modulo_detalle <> 'ELIMINADO'
  ) AS total_modulos,
  (
    SELECT sum(pmd.carga_horaria)
    FROM aca_plan_modulo_detalle pmd
    WHERE pmd.id_aca_plan_estudio = pa.id_aca_plan_estudio
      AND pmd.estado_plan_modulo_detalle <> 'ELIMINADO'
  ) AS total_horas,
  COALESCE(pa.imagen_programa_url, prog.imagen_url) AS imagen_url,
  pa.estado_programa_aprobado
FROM ins_grupo g
JOIN aca_programa_aprobado pa ON g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
JOIN aca_area area ON prog.id_aca_area = area.id_aca_area
JOIN aca_modalidad modal ON pa.id_aca_modalidad = modal.id_aca_modalidad
LEFT JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
LEFT JOIN aca_version v ON pa.id_aca_version = v.id_aca_version
WHERE prog.estado_programa <> 'ELIMINADO'
  AND pa.estado_programa_aprobado <> 'ELIMINADO'
  AND g.estado_grupo <> 'ELIMINADO'
ORDER BY g.fecha_inicio_inscripcion DESC;

COMMENT ON VIEW vista_chatbot_programas_info IS
'Vista de programas con información para chatbot. Los campos precio_*_deprecated mantienen compatibilidad pero deben usar aranceles.';


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
  niv.id_aca_nivel,
  niv.nombre_nivel,
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
  pa.sistema_programa,
  pa.estado_programa_aprobado,
  pa.cod_certificado_ceub,
  -- Campos deprecated: mantener para compatibilidad con NULL para programas nuevos
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
JOIN aca_nivel niv ON pa.id_aca_nivel = niv.id_aca_nivel
JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
LEFT JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
LEFT JOIN aca_version v ON pa.id_aca_version = v.id_aca_version
WHERE pa.estado_programa_aprobado <> 'ELIMINADO'
  AND p.estado_programa <> 'ELIMINADO'
  AND a.estado_area <> 'ELIMINADO'
  AND niv.estado_nivel <> 'ELIMINADO'
  AND m.estado_modalidad <> 'ELIMINADO'
ORDER BY pa.gestion DESC, p.nombre_programa;

COMMENT ON VIEW vista_programas_aprobados IS
'Vista de programas aprobados. Los campos precio_*_deprecated mantienen compatibilidad pero deben usar aranceles (fin_arancel).';


-- =====================================================================================================================
-- PARTE 5: NUEVAS VISTAS PARA EL SISTEMA DE ARANCELES
-- =====================================================================================================================

-- Vista: vista_aranceles_vigentes
-- =====================================================================================================================
CREATE OR REPLACE VIEW vista_aranceles_vigentes AS
SELECT
  a.id_fin_arancel,
  a.id_aca_programa_aprobado,
  prog.nombre_programa,
  niv.nombre_nivel,
  modal.nombre_modalidad,
  pa.gestion,
  g.gestion AS gestion_academica,
  g.anio AS gestion_anio,
  te.nombre_tipo AS tipo_estudiante,
  te.descripcion AS tipo_estudiante_descripcion,
  a.nombre_arancel,
  a.descripcion,
  a.fecha_inicio_vigencia,
  a.fecha_fin_vigencia,
  (
    SELECT COUNT(*)
    FROM fin_detalle_arancel da
    WHERE da.id_fin_arancel = a.id_fin_arancel
      AND da.estado_detalle_arancel = 'ACTIVO'
  ) AS total_conceptos,
  (
    SELECT SUM(da.monto)
    FROM fin_detalle_arancel da
    WHERE da.id_fin_arancel = a.id_fin_arancel
      AND da.estado_detalle_arancel = 'ACTIVO'
  ) AS monto_total,
  a.estado_arancel,
  a.fecha_reg,
  a.user_reg,
  a.fecha_mod,
  a.user_mod
FROM fin_arancel a
JOIN aca_programa_aprobado pa ON a.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
JOIN aca_nivel niv ON pa.id_aca_nivel = niv.id_aca_nivel
JOIN aca_modalidad modal ON pa.id_aca_modalidad = modal.id_aca_modalidad
JOIN aca_gestion g ON a.id_aca_gestion = g.id_aca_gestion
JOIN aca_tipo_estudiante te ON a.id_aca_tipo_estudiante = te.id_aca_tipo_estudiante
WHERE a.estado_arancel = 'ACTIVO'
  AND a.fecha_inicio_vigencia <= CURRENT_DATE
  AND (a.fecha_fin_vigencia IS NULL OR a.fecha_fin_vigencia >= CURRENT_DATE)
ORDER BY prog.nombre_programa, te.nombre_tipo, a.fecha_inicio_vigencia DESC;

COMMENT ON VIEW vista_aranceles_vigentes IS
'Vista de aranceles activos y vigentes con información completa del programa y totales calculados.';


-- Vista: vista_aranceles_programa
-- =====================================================================================================================
CREATE OR REPLACE VIEW vista_aranceles_programa AS
SELECT
  a.id_fin_arancel,
  a.id_aca_programa_aprobado,
  prog.nombre_programa,
  pa.gestion,
  te.nombre_tipo AS tipo_estudiante,
  a.nombre_arancel,
  ca.nombre_concepto,
  da.monto,
  da.orden,
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
WHERE a.estado_arancel = 'ACTIVO'
  AND da.estado_detalle_arancel = 'ACTIVO'
  AND ca.estado_concepto_arancel = 'ACTIVO'
ORDER BY prog.nombre_programa, te.nombre_tipo, da.orden;

COMMENT ON VIEW vista_aranceles_programa IS
'Vista detallada de aranceles por programa con todos los conceptos y montos desglosados.';


-- =====================================================================================================================
-- FIN DE MIGRACIÓN V23
-- =====================================================================================================================

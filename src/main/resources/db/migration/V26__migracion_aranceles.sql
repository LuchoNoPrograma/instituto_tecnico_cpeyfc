-- ============================================
-- MIGRACIÓN: SISTEMA DE PARÁMETROS → ARANCELES
-- ============================================
-- Fecha: 2025-01-XX
-- Descripción: Migración del sistema de descuentos basado en parámetros
--              a un sistema completo de aranceles con tipos de beneficiario
-- ============================================

-- ============================================
-- 1. MODIFICAR TABLA fin_obligacion_pago
-- ============================================
-- Agregar columnas para el nuevo sistema de aranceles

ALTER TABLE fin_obligacion_pago
  ADD COLUMN IF NOT EXISTS id_arancel INTEGER,
  ADD COLUMN IF NOT EXISTS id_descuento_convenio INTEGER;

-- Agregar foreign keys
ALTER TABLE fin_obligacion_pago
  ADD CONSTRAINT fk_obligacion_arancel
    FOREIGN KEY (id_arancel)
      REFERENCES fin_arancel(id_arancel)
      ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE fin_obligacion_pago
  ADD CONSTRAINT fk_obligacion_descuento_convenio
    FOREIGN KEY (id_descuento_convenio)
      REFERENCES fin_descuento_convenio(id_descuento_convenio)
      ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Comentarios para documentar
COMMENT ON COLUMN fin_obligacion_pago.id_arancel IS 'Referencia al arancel aplicado (nuevo sistema)';
COMMENT ON COLUMN fin_obligacion_pago.id_descuento_convenio IS 'Referencia al descuento de convenio aplicado (opcional)';
COMMENT ON COLUMN fin_obligacion_pago.id_aca_parametro IS 'DEPRECADO - Usar id_arancel. Se mantiene para datos históricos';

-- ============================================
-- 2. DEPRECAR CAMPOS DE aca_programa_aprobado
-- ============================================
-- Marcar como deprecados los campos de precios (ahora se usan aranceles)

COMMENT ON COLUMN aca_programa_aprobado.precio_matricula IS 'DEPRECADO - Ahora se usa fin_arancel. Se mantiene para datos históricos';
COMMENT ON COLUMN aca_programa_aprobado.precio_colegiatura IS 'DEPRECADO - Ahora se usa fin_arancel. Se mantiene para datos históricos';
COMMENT ON COLUMN aca_programa_aprobado.precio_titulacion IS 'DEPRECADO - Ahora se usa fin_arancel. Se mantiene para datos históricos';

-- ============================================
-- 3. NUEVA FUNCIÓN: Obtener conceptos con aranceles
-- ============================================
-- Reemplaza a fn_obtener_conceptos_pago_programa_aprobado
-- Ahora recibe el tipo de beneficiario para calcular aranceles correctos

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
  -- Validar que existe el programa
  IF NOT EXISTS(
    SELECT 1 FROM aca_programa_aprobado
    WHERE id_aca_programa_aprobado = p_id_programa_aprobado
      AND estado_programa_aprobado != 'ELIMINADO'
  ) THEN
    RAISE EXCEPTION 'Programa aprobado con ID % no encontrado', p_id_programa_aprobado;
  END IF;

  -- Validar que existe el tipo de beneficiario
  IF NOT EXISTS(
    SELECT 1 FROM fin_tipo_beneficiario
    WHERE id_tipo_beneficiario = p_id_tipo_beneficiario
      AND estado_tipo_beneficiario != 'ELIMINADO'
  ) THEN
    RAISE EXCEPTION 'Tipo de beneficiario con ID % no encontrado', p_id_tipo_beneficiario;
  END IF;

  -- Obtener todos los conceptos activos y calcular sus aranceles
  FOR rec_concepto IN
    SELECT
      cp.id_fin_concepto_pago,
      cp.nombre_concepto,
      cp.descripcion
    FROM fin_concepto_pago cp
    WHERE cp.estado_concepto_pago != 'ELIMINADO'
    ORDER BY cp.id_fin_concepto_pago
    LOOP
      -- Intentar calcular el arancel con descuento
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
        -- Si no hay arancel configurado para este concepto, lo saltamos
        -- Esto permite que programas sin certificado u otros conceptos sigan funcionando
        CONTINUE;
      END;
    END LOOP;

END;
$$;

COMMENT ON FUNCTION fn_obtener_conceptos_pago_con_aranceles IS
  'Obtiene los conceptos de pago con aranceles y descuentos aplicados según tipo de beneficiario y convenio. Reemplaza a fn_obtener_conceptos_pago_programa_aprobado';

-- ============================================
-- 4. DEPRECAR FUNCIÓN ANTIGUA
-- ============================================
-- Marcar como deprecada pero mantenerla para no romper código existente

COMMENT ON FUNCTION fn_obtener_conceptos_pago_programa_aprobado IS
  'DEPRECADA - Usar fn_obtener_conceptos_pago_con_aranceles. Esta función usa precios fijos de aca_programa_aprobado que están deprecados';

-- ============================================
-- 5. NUEVA FUNCIÓN: Generar obligaciones con aranceles
-- ============================================
-- Versión actualizada de fn_generar_obligaciones_pago_matricula_regular
-- Ahora usa el sistema de aranceles y tipos de beneficiario

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

  -- Validar que el grupo existe
  IF v_id_programa_aprobado IS NULL THEN
    RAISE EXCEPTION 'Error! Grupo con ID % no encontrado', p_id_grupo;
  END IF;

  -- Generar obligaciones usando el nuevo sistema de aranceles
  FOR rec_concepto IN
    SELECT *
    FROM fn_obtener_conceptos_pago_con_aranceles(
        v_id_programa_aprobado,
        p_id_tipo_beneficiario,
        p_id_convenio
         )
    LOOP
      -- Lógica especial para certificado en estudiantes regulares
      IF rec_concepto.id_fin_concepto_pago = 3 THEN
        -- Primera impresión gratuita para estudiantes regulares
        INSERT INTO fin_obligacion_pago(
          cod_ins_matricula,
          id_fin_concepto_pago,
          id_arancel,
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

      -- Para el resto de conceptos, aplicar arancel calculado
      INSERT INTO fin_obligacion_pago(
        cod_ins_matricula,
        id_fin_concepto_pago,
        id_arancel,
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
  'Versión 2: Genera obligaciones de pago usando sistema de aranceles y tipos de beneficiario. Reemplaza a fn_generar_obligaciones_pago_matricula_regular';

-- ============================================
-- 6. DEPRECAR FUNCIÓN ANTIGUA DE MATRÍCULA
-- ============================================

COMMENT ON FUNCTION fn_generar_obligaciones_pago_matricula_regular IS
  'DEPRECADA - Usar fn_generar_obligaciones_pago_matricula_regular_v2. Esta función usa el sistema antiguo de parámetros';

-- ============================================
-- 7. ACTUALIZAR VISTA DE OBLIGACIONES
-- ============================================
-- Incluir información de aranceles en la vista

CREATE OR REPLACE VIEW vista_obligaciones_pago_detallada AS
SELECT
  p.id_prs_persona,
  p.nombre,
  p.ap_paterno,
  p.ap_materno,
  p.ci,
  p.nro_celular,
  p.correo,

  pa.id_aca_programa_aprobado,
  prog.nombre_programa,
  prog.sigla AS sigla_programa,
  area.nombre_area,
  modal.nombre_modalidad,

  g.id_ins_grupo,
  g.nombre_grupo,
  g.gestion_inicio,

  m.cod_ins_matricula,
  m.tipo_matricula,
  m.estado_matricula,

  op.id_fin_obligacion_pago,
  cp.nombre_concepto,
  cp.descripcion AS concepto_descripcion,

  op.deuda_sin_descuento,
  op.deuda_con_descuento,
  op.saldo_pendiente,
  op.observacion,
  op.estado_obligacion_pago,
  op.fecha_reg AS fecha_obligacion,

  -- Información del arancel aplicado (nuevo sistema)
  ar.id_arancel,
  tb.nombre_tipo AS tipo_beneficiario_aplicado,
  ar.monto_base AS arancel_monto_base,

  -- Información del descuento de convenio (nuevo sistema)
  dc.id_descuento_convenio,
  ci.nombre_institucion AS convenio_institucion,
  dc.tipo_descuento AS convenio_tipo_descuento,
  dc.valor_descuento AS convenio_valor_descuento,

  -- Información de parámetro (sistema antiguo - DEPRECADO)
  param.nombre_param AS parametro_descuento_deprecado,
  param.valor AS parametro_valor_deprecado,

  -- Estado calculado de pago
  CASE
    WHEN op.saldo_pendiente = 0 THEN 'PAGADO'
    WHEN op.saldo_pendiente < op.deuda_con_descuento THEN 'PAGO_PARCIAL'
    ELSE 'PENDIENTE'
    END AS estado_pago

FROM fin_obligacion_pago op
       INNER JOIN ins_matricula m ON op.cod_ins_matricula = m.cod_ins_matricula
       INNER JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
       INNER JOIN ins_grupo g ON m.id_ins_grupo = g.id_ins_grupo
       INNER JOIN aca_programa_aprobado pa ON g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       INNER JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
       INNER JOIN aca_area area ON prog.id_aca_area = area.id_aca_area
       INNER JOIN aca_modalidad modal ON pa.id_aca_modalidad = modal.id_aca_modalidad
       INNER JOIN fin_concepto_pago cp ON op.id_fin_concepto_pago = cp.id_fin_concepto_pago

-- Nuevo sistema de aranceles
       LEFT JOIN fin_arancel ar ON op.id_arancel = ar.id_arancel
       LEFT JOIN fin_tipo_beneficiario tb ON ar.id_tipo_beneficiario = tb.id_tipo_beneficiario
       LEFT JOIN fin_descuento_convenio dc ON op.id_descuento_convenio = dc.id_descuento_convenio
       LEFT JOIN fin_convenio_institucional ci ON dc.id_convenio = ci.id_convenio

-- Sistema antiguo (deprecado)
       LEFT JOIN aca_parametro_programa param ON op.id_aca_parametro = param.id_aca_parametro

WHERE op.estado_obligacion_pago != 'ELIMINADO'
  AND m.estado_matricula != 'ELIMINADO'
  AND p.estado_persona != 'ELIMINADO'
  AND g.estado_grupo != 'ELIMINADO'
  AND cp.estado_concepto_pago != 'ELIMINADO'

ORDER BY prog.nombre_programa, g.nombre_grupo, p.ap_paterno, p.ap_materno, p.nombre;

COMMENT ON VIEW vista_obligaciones_pago_detallada IS
  'Vista completa de obligaciones de pago con información de aranceles y convenios (nuevo sistema) y parámetros deprecados (sistema antiguo)';

-- ============================================
-- 8. ÍNDICES PARA OPTIMIZACIÓN
-- ============================================

CREATE INDEX IF NOT EXISTS idx_obligacion_arancel
  ON fin_obligacion_pago(id_arancel)
  WHERE id_arancel IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_obligacion_descuento_convenio
  ON fin_obligacion_pago(id_descuento_convenio)
  WHERE id_descuento_convenio IS NOT NULL;

-- ============================================
-- 9. FUNCIÓN AUXILIAR: Migrar datos históricos
-- ============================================
-- Función opcional para intentar migrar obligaciones antiguas al nuevo sistema
-- Solo para referencia, puede ejecutarse manualmente si se desea

CREATE OR REPLACE FUNCTION fn_migrar_obligaciones_historicas()
  RETURNS TABLE(
                 procesadas BIGINT,
                 migradas BIGINT,
                 sin_arancel BIGINT
               )
  LANGUAGE plpgsql
AS $$
DECLARE
  v_procesadas BIGINT := 0;
  v_migradas BIGINT := 0;
  v_sin_arancel BIGINT := 0;
  rec_obligacion RECORD;
  v_id_arancel INTEGER;
BEGIN
  -- Recorrer obligaciones que usan el sistema antiguo
  FOR rec_obligacion IN
    SELECT
      op.id_fin_obligacion_pago,
      op.id_fin_concepto_pago,
      m.id_ins_grupo,
      g.id_aca_programa_aprobado
    FROM fin_obligacion_pago op
           INNER JOIN ins_matricula m ON op.cod_ins_matricula = m.cod_ins_matricula
           INNER JOIN ins_grupo g ON m.id_ins_grupo = g.id_ins_grupo
    WHERE op.id_arancel IS NULL  -- Solo las que no tienen arancel asignado
      AND op.id_aca_parametro IS NULL  -- Y tampoco tienen parámetro (o sea, usaban precios fijos)
      AND op.estado_obligacion_pago != 'ELIMINADO'
    LOOP
      v_procesadas := v_procesadas + 1;

      -- Intentar encontrar un arancel genérico para este concepto
      -- (usamos tipo_beneficiario = 1 asumiendo que es "ESTUDIANTE REGULAR")
      BEGIN
        SELECT a.id_arancel
        INTO v_id_arancel
        FROM fin_arancel a
        WHERE a.id_fin_concepto_pago = rec_obligacion.id_fin_concepto_pago
          AND a.id_aca_programa_aprobado IS NULL  -- Arancel genérico
          AND a.id_tipo_beneficiario = 1  -- Asumiendo tipo 1 = estudiante regular
          AND a.estado_arancel != 'ELIMINADO'
          AND a.fecha_inicio_vigencia <= CURRENT_DATE
          AND (a.fecha_fin_vigencia IS NULL OR a.fecha_fin_vigencia >= CURRENT_DATE)
        ORDER BY a.fecha_inicio_vigencia DESC
        LIMIT 1;

        IF v_id_arancel IS NOT NULL THEN
          -- Actualizar la obligación con el arancel encontrado
          UPDATE fin_obligacion_pago
          SET id_arancel = v_id_arancel
          WHERE id_fin_obligacion_pago = rec_obligacion.id_fin_obligacion_pago;

          v_migradas := v_migradas + 1;
        ELSE
          v_sin_arancel := v_sin_arancel + 1;
        END IF;
      EXCEPTION WHEN OTHERS THEN
        v_sin_arancel := v_sin_arancel + 1;
      END;
    END LOOP;

  RETURN QUERY SELECT v_procesadas, v_migradas, v_sin_arancel;
END;
$$;

COMMENT ON FUNCTION fn_migrar_obligaciones_historicas IS
  'Función auxiliar para intentar migrar obligaciones históricas al nuevo sistema de aranceles. Ejecutar manualmente si se desea';

-- ============================================
-- 10. FUNCIÓN: Matricular preinscrito V2 (con aranceles)
-- ============================================
-- Versión actualizada que usa el sistema de aranceles

CREATE OR REPLACE FUNCTION fn_matricular_preinscrito_completo_v2(
  p_id_ins_preinscripcion INTEGER,
  p_id_ins_grupo INTEGER,
  p_id_tipo_beneficiario INTEGER,
  p_user_reg INTEGER,
  p_id_convenio INTEGER DEFAULT NULL
)
  RETURNS TABLE(
                 cod_matricula INTEGER,
                 ci VARCHAR,
                 password_temporal VARCHAR,
                 id_usuario INTEGER,
                 usuario_existia BOOLEAN,
                 mensaje TEXT
               )
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_persona INTEGER;
  v_id_programa_aprobado INTEGER;
  v_existe_preinscripcion INTEGER;
  v_existe_grupo INTEGER;
  v_grupo_programa_id INTEGER;
  v_ya_matriculado INTEGER;
  v_cod_matricula INTEGER;
  v_id_usuario INTEGER;
  v_nombre_completo TEXT;
  v_nombre_grupo VARCHAR(100);
  v_ci VARCHAR(20);
  v_password_temporal VARCHAR(50);
  v_usuario_existia BOOLEAN := FALSE;
BEGIN
  -- Validaciones obligatorias
  IF p_id_ins_preinscripcion IS NULL OR p_id_ins_grupo IS NULL OR
     p_id_tipo_beneficiario IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los parámetros obligatorios deben ser proporcionados';
  END IF;

  -- Verificar preinscripción y obtener datos
  SELECT COUNT(*), MAX(pre.id_prs_persona), MAX(pre.id_aca_programa_aprobado),
         MAX(p.ci), MAX(CONCAT(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, '')))
  INTO v_existe_preinscripcion, v_id_persona, v_id_programa_aprobado, v_ci, v_nombre_completo
  FROM ins_preinscripcion pre
         INNER JOIN prs_persona p ON pre.id_prs_persona = p.id_prs_persona
  WHERE pre.id_ins_preinscripcion = p_id_ins_preinscripcion
    AND pre.estado_preinscripcion != 'ELIMINADO'
    AND p.estado_persona != 'ELIMINADO';

  IF v_existe_preinscripcion = 0 THEN
    RAISE EXCEPTION 'Error! Preinscripción no encontrada o inválida';
  END IF;

  -- Verificar grupo
  SELECT COUNT(*), MAX(id_aca_programa_aprobado), MAX(nombre_grupo)
  INTO v_existe_grupo, v_grupo_programa_id, v_nombre_grupo
  FROM ins_grupo
  WHERE id_ins_grupo = p_id_ins_grupo
    AND estado_grupo != 'ELIMINADO';

  IF v_existe_grupo = 0 THEN
    RAISE EXCEPTION 'Error! Grupo no encontrado';
  END IF;

  -- Validar que programa de preinscripción coincida con programa del grupo
  IF v_id_programa_aprobado != v_grupo_programa_id THEN
    RAISE EXCEPTION 'Error! La preinscripción no corresponde al programa del grupo';
  END IF;

  -- Verificar si ya está matriculado en este grupo
  SELECT COUNT(*) INTO v_ya_matriculado
  FROM ins_matricula
  WHERE id_prs_persona = v_id_persona
    AND id_ins_grupo = p_id_ins_grupo
    AND estado_matricula != 'ELIMINADO';

  IF v_ya_matriculado > 0 THEN
    RAISE EXCEPTION 'Error! La persona ya está matriculada en este grupo';
  END IF;

  -- Buscar si ya existe usuario
  SELECT id_seg_usuario INTO v_id_usuario
  FROM seg_usuario
  WHERE nombre_usuario = v_ci
    AND estado_usuario != 'ELIMINADO';

  IF v_id_usuario IS NOT NULL THEN
    v_usuario_existia := TRUE;
    v_password_temporal := NULL;
  ELSE
    -- Crear contraseña temporal (primer nombre + CI)
    v_password_temporal := UPPER(TRIM(UNACCENT(SPLIT_PART(v_nombre_completo, ' ', 1)))) || v_ci;

    -- Crear usuario temporal (Spring Boot hasheará la contraseña)
    INSERT INTO seg_usuario(nombre_usuario, estado_usuario, fecha_reg, user_reg)
    VALUES (v_ci, 'PENDIENTE', CURRENT_TIMESTAMP, p_user_reg)
    RETURNING id_seg_usuario INTO v_id_usuario;

    -- Asignar rol ESTUDIANTE (id_seg_rol = 5)
    INSERT INTO seg_ocupa(id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg)
    VALUES (5, v_id_usuario, 'ACTIVO', CURRENT_TIMESTAMP, p_user_reg);

    -- Asignar tareas del rol estudiante
    INSERT INTO seg_designa(id_seg_tarea, id_seg_usuario, estado_designa, fecha_reg, user_reg)
    SELECT t.id_seg_tarea, v_id_usuario, 'ACTIVO', CURRENT_TIMESTAMP, p_user_reg
    FROM seg_tarea t
    WHERE t.id_seg_rol = 5
      AND t.estado_tarea != 'ELIMINADO'
    ON CONFLICT (id_seg_tarea, id_seg_usuario) DO NOTHING;
  END IF;

  -- Crear matrícula
  INSERT INTO ins_matricula(
    id_ins_grupo,
    id_prs_persona,
    id_seg_usuario,
    estado_matricula,
    tipo_matricula,
    fecha_reg,
    user_reg
  ) VALUES (
             p_id_ins_grupo,
             v_id_persona,
             v_id_usuario,
             'ACTIVO',
             'REGULAR',
             CURRENT_TIMESTAMP,
             p_user_reg
           ) RETURNING cod_ins_matricula INTO v_cod_matricula;

  -- Generar obligaciones de pago usando NUEVO sistema de aranceles
  PERFORM fn_generar_obligaciones_pago_matricula_regular_v2(
      v_cod_matricula,
      p_id_ins_grupo,
      p_id_tipo_beneficiario,
      p_user_reg,
      p_id_convenio
          );

  -- Actualizar estado de preinscripción
  UPDATE ins_preinscripcion
  SET estado_preinscripcion = 'MATRICULADO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_reg
  WHERE id_ins_preinscripcion = p_id_ins_preinscripcion;

  -- Retornar resultado
  RETURN QUERY SELECT
                 v_cod_matricula,
                 v_ci,
                 v_password_temporal,
                 v_id_usuario,
                 v_usuario_existia,
                 CONCAT('Matrícula exitosa en grupo: ', v_nombre_grupo, ' - ', v_nombre_completo)::TEXT;
END;
$$;

COMMENT ON FUNCTION fn_matricular_preinscrito_completo_v2 IS
  'Versión 2: Matricula preinscrito usando sistema de aranceles con tipos de beneficiario. Reemplaza a fn_matricular_preinscrito_completo';

-- ============================================
-- 11. DEPRECAR FUNCIÓN ANTIGUA DE MATRÍCULA
-- ============================================

COMMENT ON FUNCTION fn_matricular_preinscrito_completo IS
  'DEPRECADA - Usar fn_matricular_preinscrito_completo_v2. Esta función usa el sistema antiguo de parámetros de descuento';

-- ============================================
-- FIN DE MIGRACIÓN
-- ============================================
-- NOTAS IMPORTANTES:
-- 1. Las funciones antiguas se mantienen como DEPRECADAS pero funcionales
-- 2. Los campos precio_* en aca_programa_aprobado se mantienen para datos históricos
-- 3. El campo id_aca_parametro en fin_obligacion_pago se mantiene para compatibilidad
-- 4. Todo el código nuevo debe usar las funciones _v2 y el sistema de aranceles
-- 5. Se recomienda crear aranceles genéricos para todos los conceptos antes de usar el nuevo sistema
-- 6. El nuevo sistema requiere especificar tipo de beneficiario en cada matrícula



CREATE OR REPLACE FUNCTION fn_activar_usuario_matricula(
  p_id_usuario INTEGER,
  p_password_hash VARCHAR
)
  RETURNS TEXT
  LANGUAGE plpgsql
AS $$
BEGIN
  -- Actualizar usuario con password hash
  UPDATE seg_usuario
  SET contrasena_hash = p_password_hash,
      estado_usuario = 'ACTIVO'
  WHERE id_seg_usuario = p_id_usuario;

  -- Asignar rol matriculado SOLO si no lo tiene
  -- Usando ON CONFLICT DO NOTHING para evitar error de llave duplicada
  INSERT INTO seg_ocupa(
    id_seg_rol,
    id_seg_usuario,
    estado_ocupa,
    fecha_reg,
    user_reg
  ) VALUES (
             5,              -- Rol ESTUDIANTE
             p_id_usuario,
             'ACTIVO',
             NOW(),
             1
           )
  ON CONFLICT (id_seg_rol, id_seg_usuario) DO NOTHING;

  RETURN 'Usuario activado exitosamente';
END;
$$;

COMMENT ON FUNCTION fn_activar_usuario_matricula IS
  'Activa usuario y asigna rol ESTUDIANTE (id_seg_rol=5). Usa ON CONFLICT para evitar error si ya tiene el rol';

-- ============================================
-- FIX ADICIONAL: fn_activar_usuario_docente
-- ============================================
-- Aplicando la misma lógica por consistencia

CREATE OR REPLACE FUNCTION fn_activar_usuario_docente(
  p_id_usuario INTEGER,
  p_password_hash VARCHAR
)
  RETURNS TEXT
  LANGUAGE plpgsql
AS $$
BEGIN
  -- Actualizar usuario con password hash
  UPDATE seg_usuario
  SET contrasena_hash = p_password_hash,
      estado_usuario = 'ACTIVO'
  WHERE id_seg_usuario = p_id_usuario;

  -- Asignar rol docente SOLO si no lo tiene
  INSERT INTO seg_ocupa(
    id_seg_rol,
    id_seg_usuario,
    estado_ocupa,
    fecha_reg,
    user_reg
  ) VALUES (
             4,              -- Rol DOCENTE
             p_id_usuario,
             'ACTIVO',
             NOW(),
             1
           )
  ON CONFLICT (id_seg_rol, id_seg_usuario) DO NOTHING;

  RETURN 'Usuario docente activado exitosamente';
END;
$$;

COMMENT ON FUNCTION fn_activar_usuario_docente IS
  'Activa usuario y asigna rol DOCENTE (id_seg_rol=4). Usa ON CONFLICT para evitar error si ya tiene el rol';

select * from seg_usuario where id_seg_usuario = 5;
select prs.* from prs_persona prs
left join ins_matricula mtr on prs.id_prs_persona = mtr.id_prs_persona
left join seg_usuario usu on prs.id_prs_persona = mtr.id_seg_usuario
where usu.id_seg_usuario = 5;
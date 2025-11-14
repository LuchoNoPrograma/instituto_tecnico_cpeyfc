-- ============================================
-- V21: FIX - Usuario duplicado en matrícula
-- ============================================
-- Fecha: 2025-01-14
-- Problema: Se crean usuarios duplicados al re-matricular a una persona
-- Solución: Reutilizar usuario existente buscando por persona→matrícula
-- ============================================

-- ============================================
-- 1. FUNCIÓN CORREGIDA: fn_matricular_preinscrito_completo_v2
-- ============================================

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

  -- ============================================
  -- FIX: Buscar usuario por PERSONA (relación matrícula), NO por CI
  -- ============================================
  SELECT m.id_seg_usuario INTO v_id_usuario
  FROM ins_matricula m
         INNER JOIN seg_usuario u ON m.id_seg_usuario = u.id_seg_usuario
  WHERE m.id_prs_persona = v_id_persona
    AND m.estado_matricula != 'ELIMINADO'
    AND u.estado_usuario != 'ELIMINADO'
  LIMIT 1;

  IF v_id_usuario IS NOT NULL THEN
    -- Usuario YA EXISTE - REUTILIZAR
    v_usuario_existia := TRUE;
    v_password_temporal := NULL;

    -- Asegurar que el usuario esté activo
    UPDATE seg_usuario
    SET estado_usuario = 'ACTIVO',
        fecha_mod = CURRENT_TIMESTAMP,
        user_mod = p_user_reg
    WHERE id_seg_usuario = v_id_usuario
      AND estado_usuario != 'ACTIVO';

    -- Asegurar que tenga el rol ESTUDIANTE activo
    INSERT INTO seg_ocupa(id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg)
    VALUES (5, v_id_usuario, 'ACTIVO', CURRENT_TIMESTAMP, p_user_reg)
    ON CONFLICT (id_seg_rol, id_seg_usuario)
      DO UPDATE SET
        estado_ocupa = 'ACTIVO',
        fecha_mod = CURRENT_TIMESTAMP,
        user_mod = p_user_reg;

    -- Asegurar tareas del rol estudiante
    INSERT INTO seg_designa(id_seg_tarea, id_seg_usuario, estado_designa, fecha_reg, user_reg)
    SELECT t.id_seg_tarea, v_id_usuario, 'ACTIVO', CURRENT_TIMESTAMP, p_user_reg
    FROM seg_tarea t
    WHERE t.id_seg_rol = 5
      AND t.estado_tarea != 'ELIMINADO'
    ON CONFLICT (id_seg_tarea, id_seg_usuario)
      DO UPDATE SET
        estado_designa = 'ACTIVO',
        fecha_mod = CURRENT_TIMESTAMP,
        user_mod = p_user_reg;

  ELSE
    -- Usuario NO EXISTE - CREAR NUEVO
    v_usuario_existia := FALSE;
    v_password_temporal := UPPER(TRIM(UNACCENT(SPLIT_PART(v_nombre_completo, ' ', 1)))) || v_ci;

    INSERT INTO seg_usuario(nombre_usuario, estado_usuario, fecha_reg, user_reg)
    VALUES (v_ci, 'PENDIENTE', CURRENT_TIMESTAMP, p_user_reg)
    RETURNING id_seg_usuario INTO v_id_usuario;

    INSERT INTO seg_ocupa(id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg)
    VALUES (5, v_id_usuario, 'ACTIVO', CURRENT_TIMESTAMP, p_user_reg);

    INSERT INTO seg_designa(id_seg_tarea, id_seg_usuario, estado_designa, fecha_reg, user_reg)
    SELECT t.id_seg_tarea, v_id_usuario, 'ACTIVO', CURRENT_TIMESTAMP, p_user_reg
    FROM seg_tarea t
    WHERE t.id_seg_rol = 5
      AND t.estado_tarea != 'ELIMINADO';
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

  -- Generar obligaciones de pago
  PERFORM fn_generar_obligaciones_pago_matricula_regular_v2(
      v_cod_matricula,
      p_id_ins_grupo,
      p_id_tipo_beneficiario,
      p_user_reg,
      p_id_convenio
          );

  -- Actualizar preinscripción
  UPDATE ins_preinscripcion
  SET estado_preinscripcion = 'MATRICULADO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_reg
  WHERE id_ins_preinscripcion = p_id_ins_preinscripcion;

  RETURN QUERY SELECT
                 v_cod_matricula,
                 v_ci,
                 v_password_temporal,
                 v_id_usuario,
                 v_usuario_existia,
                 CASE
                   WHEN v_usuario_existia THEN
                     CONCAT('Matrícula exitosa (usuario reutilizado) - ', v_nombre_grupo, ' - ', v_nombre_completo)
                   ELSE
                     CONCAT('Matrícula exitosa (usuario nuevo) - ', v_nombre_grupo, ' - ', v_nombre_completo)
                   END::TEXT;
END;
$$;

-- ============================================
-- 2. FUNCIÓN AUXILIAR: fn_activar_usuario_matricula
-- ============================================

CREATE OR REPLACE FUNCTION fn_activar_usuario_matricula(
  p_id_usuario INTEGER,
  p_password_hash VARCHAR
)
  RETURNS TEXT
  LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE seg_usuario
  SET contrasena_hash = p_password_hash,
      estado_usuario = 'ACTIVO'
  WHERE id_seg_usuario = p_id_usuario;

  INSERT INTO seg_ocupa(id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg)
  VALUES (5, p_id_usuario, 'ACTIVO', CURRENT_TIMESTAMP, 1)
  ON CONFLICT (id_seg_rol, id_seg_usuario)
    DO UPDATE SET
      estado_ocupa = 'ACTIVO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = 1;

  RETURN 'Usuario activado exitosamente';
END;
$$;

-- ============================================
-- 3. FUNCIÓN AUXILIAR: fn_activar_usuario_docente
-- ============================================

CREATE OR REPLACE FUNCTION fn_activar_usuario_docente(
  p_id_usuario INTEGER,
  p_password_hash VARCHAR
)
  RETURNS TEXT
  LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE seg_usuario
  SET contrasena_hash = p_password_hash,
      estado_usuario = 'ACTIVO'
  WHERE id_seg_usuario = p_id_usuario;

  INSERT INTO seg_ocupa(id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg)
  VALUES (4, p_id_usuario, 'ACTIVO', CURRENT_TIMESTAMP, 1)
  ON CONFLICT (id_seg_rol, id_seg_usuario)
    DO UPDATE SET
      estado_ocupa = 'ACTIVO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = 1;

  RETURN 'Usuario docente activado exitosamente';
END;
$$;

-- ============================================
-- 4. ÍNDICE PARA OPTIMIZACIÓN
-- ============================================

CREATE INDEX IF NOT EXISTS idx_matricula_persona_usuario
  ON ins_matricula(id_prs_persona, id_seg_usuario)
  WHERE estado_matricula != 'ELIMINADO';

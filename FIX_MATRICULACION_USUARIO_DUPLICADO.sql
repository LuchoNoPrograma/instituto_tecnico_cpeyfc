-- ============================================
-- FIX: SOLUCIÓN DEFINITIVA - Usuario duplicado en matrícula
-- ============================================
-- Fecha: 2025-01-14
-- Problema: Se crean usuarios duplicados al re-matricular a una persona
-- Causa: La búsqueda de usuario existente usa CI en lugar de relación persona→matrícula
-- Solución: Buscar usuario por matrículas anteriores de la misma persona
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
  -- FIX CRÍTICO: Buscar usuario por PERSONA, no por CI
  -- ============================================
  -- Una persona puede tener matrículas anteriores con usuario ya creado
  -- Debemos REUTILIZAR ese usuario, no crear uno nuevo

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

    -- Asegurar que tenga el rol ESTUDIANTE activo (si no lo tiene, agregarlo)
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

  -- Generar obligaciones de pago usando sistema de aranceles
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
                 CASE
                   WHEN v_usuario_existia THEN
                     CONCAT('Matrícula exitosa (usuario reutilizado) en grupo: ', v_nombre_grupo, ' - ', v_nombre_completo)
                   ELSE
                     CONCAT('Matrícula exitosa (usuario nuevo) en grupo: ', v_nombre_grupo, ' - ', v_nombre_completo)
                 END::TEXT;
END;
$$;

COMMENT ON FUNCTION fn_matricular_preinscrito_completo_v2 IS
  'V2 CORREGIDO: Matricula preinscrito REUTILIZANDO usuario existente de matrículas anteriores. Busca por relación persona→matrícula, NO por CI';

-- ============================================
-- 2. FUNCIÓN AUXILIAR CORREGIDA: fn_activar_usuario_matricula
-- ============================================
-- Esta función ya NO debería usarse porque el rol se asigna en fn_matricular_preinscrito_completo_v2
-- PERO la dejamos con ON CONFLICT por si acaso se llama desde otro lugar

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

  -- Asignar rol ESTUDIANTE SOLO si no lo tiene
  INSERT INTO seg_ocupa(
    id_seg_rol,
    id_seg_usuario,
    estado_ocupa,
    fecha_reg,
    user_reg
  ) VALUES (
             5,
             p_id_usuario,
             'ACTIVO',
             CURRENT_TIMESTAMP,
             1
           )
  ON CONFLICT (id_seg_rol, id_seg_usuario)
  DO UPDATE SET
    estado_ocupa = 'ACTIVO',
    fecha_mod = CURRENT_TIMESTAMP,
    user_mod = 1;

  RETURN 'Usuario activado exitosamente';
END;
$$;

COMMENT ON FUNCTION fn_activar_usuario_matricula IS
  'DEPRECADA: Activa usuario y asigna rol ESTUDIANTE. Ahora el rol se asigna directamente en fn_matricular_preinscrito_completo_v2';

-- ============================================
-- 3. FUNCIÓN AUXILIAR CORREGIDA: fn_activar_usuario_docente
-- ============================================

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

  -- Asignar rol DOCENTE SOLO si no lo tiene
  INSERT INTO seg_ocupa(
    id_seg_rol,
    id_seg_usuario,
    estado_ocupa,
    fecha_reg,
    user_reg
  ) VALUES (
             4,
             p_id_usuario,
             'ACTIVO',
             CURRENT_TIMESTAMP,
             1
           )
  ON CONFLICT (id_seg_rol, id_seg_usuario)
  DO UPDATE SET
    estado_ocupa = 'ACTIVO',
    fecha_mod = CURRENT_TIMESTAMP,
    user_mod = 1;

  RETURN 'Usuario docente activado exitosamente';
END;
$$;

-- ============================================
-- 4. ÍNDICE PARA OPTIMIZAR BÚSQUEDA
-- ============================================
-- Acelera la búsqueda de usuario por persona en ins_matricula

CREATE INDEX IF NOT EXISTS idx_matricula_persona_usuario
  ON ins_matricula(id_prs_persona, id_seg_usuario)
  WHERE estado_matricula != 'ELIMINADO';

COMMENT ON INDEX idx_matricula_persona_usuario IS
  'Índice para optimizar búsqueda de usuario existente por persona al matricular';

-- ============================================
-- 5. CONSTRAINT RECOMENDADO (OPCIONAL)
-- ============================================
-- Prevenir múltiples usuarios para la misma persona
-- ADVERTENCIA: Esto puede fallar si ya hay datos duplicados

-- Descomentar solo si estás seguro de que no hay duplicados:
/*
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_persona_usuario
  ON ins_matricula(id_prs_persona)
  WHERE estado_matricula != 'ELIMINADO' AND id_seg_usuario IS NOT NULL;

COMMENT ON INDEX idx_unique_persona_usuario IS
  'Asegura que una persona solo tenga un usuario activo a través de sus matrículas';
*/

-- ============================================
-- 6. FUNCIÓN DIAGNÓSTICO: Detectar usuarios duplicados
-- ============================================

CREATE OR REPLACE FUNCTION fn_diagnostico_usuarios_duplicados()
  RETURNS TABLE(
                 id_persona INTEGER,
                 nombre_completo TEXT,
                 ci VARCHAR,
                 cantidad_usuarios BIGINT,
                 ids_usuarios TEXT
               )
  LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
    SELECT
      p.id_prs_persona,
      CONCAT(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, ''))::TEXT AS nombre_completo,
      p.ci,
      COUNT(DISTINCT m.id_seg_usuario) AS cantidad_usuarios,
      STRING_AGG(DISTINCT m.id_seg_usuario::TEXT, ', ' ORDER BY m.id_seg_usuario::TEXT) AS ids_usuarios
    FROM prs_persona p
           INNER JOIN ins_matricula m ON p.id_prs_persona = m.id_prs_persona
           INNER JOIN seg_usuario u ON m.id_seg_usuario = u.id_seg_usuario
    WHERE p.estado_persona != 'ELIMINADO'
      AND m.estado_matricula != 'ELIMINADO'
      AND u.estado_usuario != 'ELIMINADO'
    GROUP BY p.id_prs_persona, p.nombre, p.ap_paterno, p.ap_materno, p.ci
    HAVING COUNT(DISTINCT m.id_seg_usuario) > 1
    ORDER BY cantidad_usuarios DESC, p.ap_paterno;
END;
$$;

COMMENT ON FUNCTION fn_diagnostico_usuarios_duplicados IS
  'Detecta personas que tienen múltiples usuarios asignados (problema de duplicados)';

-- ============================================
-- 7. FUNCIÓN LIMPIEZA: Consolidar usuarios duplicados
-- ============================================

CREATE OR REPLACE FUNCTION fn_consolidar_usuarios_duplicados(
  p_id_persona INTEGER
)
  RETURNS TABLE(
                 usuario_mantenido INTEGER,
                 usuarios_eliminados TEXT,
                 matriculas_actualizadas INTEGER,
                 mensaje TEXT
               )
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_usuario_principal INTEGER;
  v_ids_duplicados INTEGER[];
  v_count_matriculas INTEGER;
BEGIN
  -- Obtener el usuario más antiguo (el primero creado)
  SELECT m.id_seg_usuario INTO v_id_usuario_principal
  FROM ins_matricula m
         INNER JOIN seg_usuario u ON m.id_seg_usuario = u.id_seg_usuario
  WHERE m.id_prs_persona = p_id_persona
    AND m.estado_matricula != 'ELIMINADO'
    AND u.estado_usuario != 'ELIMINADO'
  ORDER BY u.fecha_reg ASC
  LIMIT 1;

  IF v_id_usuario_principal IS NULL THEN
    RAISE EXCEPTION 'No se encontró usuario válido para persona %', p_id_persona;
  END IF;

  -- Obtener IDs de usuarios duplicados
  SELECT ARRAY_AGG(DISTINCT m.id_seg_usuario)
  INTO v_ids_duplicados
  FROM ins_matricula m
  WHERE m.id_prs_persona = p_id_persona
    AND m.id_seg_usuario != v_id_usuario_principal
    AND m.estado_matricula != 'ELIMINADO';

  -- Actualizar todas las matrículas para usar el usuario principal
  UPDATE ins_matricula
  SET id_seg_usuario = v_id_usuario_principal,
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = 1
  WHERE id_prs_persona = p_id_persona
    AND id_seg_usuario = ANY(v_ids_duplicados)
    AND estado_matricula != 'ELIMINADO';

  GET DIAGNOSTICS v_count_matriculas = ROW_COUNT;

  -- Marcar usuarios duplicados como eliminados
  UPDATE seg_usuario
  SET estado_usuario = 'ELIMINADO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = 1
  WHERE id_seg_usuario = ANY(v_ids_duplicados);

  -- Retornar resultado
  RETURN QUERY SELECT
                 v_id_usuario_principal,
                 ARRAY_TO_STRING(v_ids_duplicados, ', '),
                 v_count_matriculas,
                 CONCAT('Consolidación exitosa. Usuario principal: ', v_id_usuario_principal)::TEXT;
END;
$$;

COMMENT ON FUNCTION fn_consolidar_usuarios_duplicados IS
  'Consolida múltiples usuarios de una persona en uno solo (el más antiguo). Actualiza matrículas y elimina duplicados';

-- ============================================
-- FIN DEL FIX
-- ============================================

-- INSTRUCCIONES DE APLICACIÓN:
-- 1. Ejecutar este script completo en PostgreSQL
-- 2. Verificar funciones actualizadas: SELECT * FROM fn_diagnostico_usuarios_duplicados();
-- 3. Si hay duplicados existentes, consolidarlos: SELECT * FROM fn_consolidar_usuarios_duplicados(id_persona);
-- 4. Probar nueva matrícula con persona que ya tiene usuario
-- 5. Verificar en logs que dice "usuario reutilizado"

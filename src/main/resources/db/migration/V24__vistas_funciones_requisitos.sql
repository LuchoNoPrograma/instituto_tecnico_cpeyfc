-- ============================================
-- VISTAS Y FUNCIONES PARA CHATBOT - REQUISITOS
-- ============================================

-- Vista: Matriz de requisitos por perfil para el chatbot
CREATE VIEW vista_chatbot_requisitos_por_perfil AS
SELECT
  pe.id_aca_perfil_estudiante,
  pe.nombre_perfil,
  pe.descripcion AS descripcion_perfil,
  r.id_aca_requisito,
  r.nombre_requisito,
  r.descripcion AS descripcion_requisito,
  r.orden_presentacion
FROM aca_perfil_estudiante pe
  INNER JOIN aca_requisito_perfil rp ON pe.id_aca_perfil_estudiante = rp.id_aca_perfil_estudiante
  INNER JOIN aca_requisito r ON rp.id_aca_requisito = r.id_aca_requisito
WHERE pe.estado_perfil_estudiante != 'ELIMINADO'
  AND rp.estado_requisito_perfil != 'ELIMINADO'
  AND r.estado_requisito != 'ELIMINADO'
ORDER BY pe.nombre_perfil, r.orden_presentacion, r.nombre_requisito;

COMMENT ON VIEW vista_chatbot_requisitos_por_perfil IS 'Muestra qué requisitos debe presentar cada perfil de estudiante';

-- Vista: Perfiles elegibles por programa
CREATE VIEW vista_chatbot_perfiles_programa AS
SELECT
  prog.id_aca_programa,
  prog.nombre_programa,
  prog.sigla AS programa_sigla,
  area.nombre_area,
  pe.id_aca_perfil_estudiante,
  pe.nombre_perfil,
  pe.descripcion AS descripcion_perfil,
  pp.observaciones
FROM aca_programa prog
  INNER JOIN aca_area area ON prog.id_aca_area = area.id_aca_area
  INNER JOIN aca_programa_perfil pp ON prog.id_aca_programa = pp.id_aca_programa
  INNER JOIN aca_perfil_estudiante pe ON pp.id_aca_perfil_estudiante = pe.id_aca_perfil_estudiante
WHERE prog.estado_programa != 'ELIMINADO'
  AND area.estado_area != 'ELIMINADO'
  AND pp.estado_programa_perfil != 'ELIMINADO'
  AND pe.estado_perfil_estudiante != 'ELIMINADO'
ORDER BY prog.nombre_programa, pe.nombre_perfil;

COMMENT ON VIEW vista_chatbot_perfiles_programa IS 'Muestra qué perfiles de estudiante pueden inscribirse a cada programa';

-- Función: Obtener requisitos de un perfil específico
CREATE OR REPLACE FUNCTION fn_obtener_requisitos_perfil(p_id_perfil_estudiante INTEGER)
RETURNS TABLE(
  nombre_requisito VARCHAR,
  descripcion TEXT,
  orden_presentacion INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.nombre_requisito,
    r.descripcion,
    r.orden_presentacion
  FROM aca_requisito_perfil rp
    INNER JOIN aca_requisito r ON rp.id_aca_requisito = r.id_aca_requisito
  WHERE rp.id_aca_perfil_estudiante = p_id_perfil_estudiante
    AND rp.estado_requisito_perfil != 'ELIMINADO'
    AND r.estado_requisito != 'ELIMINADO'
  ORDER BY r.orden_presentacion, r.nombre_requisito;
END;
$$;

COMMENT ON FUNCTION fn_obtener_requisitos_perfil(INTEGER) IS 'Obtiene lista de requisitos para un perfil específico de estudiante';

-- Función: Obtener requisitos por nombre de perfil (más amigable para chatbot)
CREATE OR REPLACE FUNCTION fn_obtener_requisitos_por_nombre_perfil(p_nombre_perfil VARCHAR)
RETURNS TABLE(
  nombre_requisito VARCHAR,
  descripcion TEXT,
  orden_presentacion INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.nombre_requisito,
    r.descripcion,
    r.orden_presentacion
  FROM aca_perfil_estudiante pe
    INNER JOIN aca_requisito_perfil rp ON pe.id_aca_perfil_estudiante = rp.id_aca_perfil_estudiante
    INNER JOIN aca_requisito r ON rp.id_aca_requisito = r.id_aca_requisito
  WHERE LOWER(pe.nombre_perfil) LIKE LOWER('%' || p_nombre_perfil || '%')
    AND pe.estado_perfil_estudiante != 'ELIMINADO'
    AND rp.estado_requisito_perfil != 'ELIMINADO'
    AND r.estado_requisito != 'ELIMINADO'
  ORDER BY r.orden_presentacion, r.nombre_requisito;
END;
$$;

COMMENT ON FUNCTION fn_obtener_requisitos_por_nombre_perfil(VARCHAR) IS 'Obtiene requisitos buscando por nombre de perfil (busqueda flexible)';

-- Función: Validar si un perfil puede inscribirse a un programa
CREATE OR REPLACE FUNCTION fn_validar_perfil_programa(
  p_id_programa INTEGER,
  p_id_perfil_estudiante INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
  v_existe BOOLEAN;
BEGIN
  SELECT EXISTS(
    SELECT 1
    FROM aca_programa_perfil pp
    WHERE pp.id_aca_programa = p_id_programa
      AND pp.id_aca_perfil_estudiante = p_id_perfil_estudiante
      AND pp.estado_programa_perfil != 'ELIMINADO'
  ) INTO v_existe;

  RETURN v_existe;
END;
$$;

COMMENT ON FUNCTION fn_validar_perfil_programa(INTEGER, INTEGER) IS 'Valida si un perfil de estudiante puede inscribirse a un programa específico';

-- Función: Obtener información completa de requisitos por programa
CREATE OR REPLACE FUNCTION fn_obtener_requisitos_programa_chatbot(p_id_programa INTEGER)
RETURNS TABLE(
  nombre_perfil VARCHAR,
  descripcion_perfil TEXT,
  nombre_requisito VARCHAR,
  descripcion_requisito TEXT,
  orden_presentacion INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    pe.nombre_perfil,
    pe.descripcion,
    r.nombre_requisito,
    r.descripcion,
    r.orden_presentacion
  FROM aca_programa_perfil pp
    INNER JOIN aca_perfil_estudiante pe ON pp.id_aca_perfil_estudiante = pe.id_aca_perfil_estudiante
    INNER JOIN aca_requisito_perfil rp ON pe.id_aca_perfil_estudiante = rp.id_aca_perfil_estudiante
    INNER JOIN aca_requisito r ON rp.id_aca_requisito = r.id_aca_requisito
  WHERE pp.id_aca_programa = p_id_programa
    AND pp.estado_programa_perfil != 'ELIMINADO'
    AND pe.estado_perfil_estudiante != 'ELIMINADO'
    AND rp.estado_requisito_perfil != 'ELIMINADO'
    AND r.estado_requisito != 'ELIMINADO'
  ORDER BY pe.nombre_perfil, r.orden_presentacion, r.nombre_requisito;
END;
$$;

COMMENT ON FUNCTION fn_obtener_requisitos_programa_chatbot(INTEGER) IS 'Obtiene todos los requisitos agrupados por perfil para un programa específico (útil para chatbot)';

-- ============================================
-- VISTAS PARA DROPDOWNS Y ADMINISTRACIÓN
-- ============================================

-- Vista: Perfiles activos (para dropdowns)
CREATE VIEW vista_perfiles_estudiante_activos AS
SELECT
  id_aca_perfil_estudiante,
  nombre_perfil,
  descripcion,
  fecha_reg,
  user_reg
FROM aca_perfil_estudiante
WHERE estado_perfil_estudiante != 'ELIMINADO'
ORDER BY nombre_perfil;

COMMENT ON VIEW vista_perfiles_estudiante_activos IS 'Listado de perfiles activos para formularios';

-- Vista: Requisitos activos (para dropdowns)
CREATE VIEW vista_requisitos_activos AS
SELECT
  id_aca_requisito,
  nombre_requisito,
  descripcion,
  orden_presentacion,
  fecha_reg,
  user_reg
FROM aca_requisito
WHERE estado_requisito != 'ELIMINADO'
ORDER BY orden_presentacion, nombre_requisito;

COMMENT ON VIEW vista_requisitos_activos IS 'Listado de requisitos activos para formularios';

-- Vista: Requisitos asignados por perfil (para administración)
CREATE VIEW vista_requisitos_por_perfil AS
SELECT
  rp.id_aca_requisito_perfil,
  pe.id_aca_perfil_estudiante,
  pe.nombre_perfil,
  r.id_aca_requisito,
  r.nombre_requisito,
  r.descripcion AS descripcion_requisito,
  r.orden_presentacion,
  rp.fecha_reg,
  rp.user_reg
FROM aca_requisito_perfil rp
  INNER JOIN aca_perfil_estudiante pe ON rp.id_aca_perfil_estudiante = pe.id_aca_perfil_estudiante
  INNER JOIN aca_requisito r ON rp.id_aca_requisito = r.id_aca_requisito
WHERE rp.estado_requisito_perfil != 'ELIMINADO'
  AND pe.estado_perfil_estudiante != 'ELIMINADO'
  AND r.estado_requisito != 'ELIMINADO'
ORDER BY pe.nombre_perfil, r.orden_presentacion, r.nombre_requisito;

COMMENT ON VIEW vista_requisitos_por_perfil IS 'Muestra qué requisitos tiene asignado cada perfil de estudiante';

-- Vista: Perfiles asignados por programa (para administración)
CREATE VIEW vista_perfiles_por_programa AS
SELECT
  pp.id_aca_programa_perfil,
  prog.id_aca_programa,
  prog.nombre_programa,
  prog.sigla AS programa_sigla,
  pe.id_aca_perfil_estudiante,
  pe.nombre_perfil,
  pe.descripcion AS descripcion_perfil,
  pp.observaciones,
  pp.fecha_reg,
  pp.user_reg
FROM aca_programa_perfil pp
  INNER JOIN aca_programa prog ON pp.id_aca_programa = prog.id_aca_programa
  INNER JOIN aca_perfil_estudiante pe ON pp.id_aca_perfil_estudiante = pe.id_aca_perfil_estudiante
WHERE pp.estado_programa_perfil != 'ELIMINADO'
  AND prog.estado_programa != 'ELIMINADO'
  AND pe.estado_perfil_estudiante != 'ELIMINADO'
ORDER BY prog.nombre_programa, pe.nombre_perfil;

COMMENT ON VIEW vista_perfiles_por_programa IS 'Muestra qué perfiles pueden inscribirse a cada programa';

-- ============================================
-- FUNCIONES CRUD - PERFILES
-- ============================================

-- Registrar perfil estudiante
CREATE OR REPLACE FUNCTION fn_registrar_perfil_estudiante(
  p_nombre_perfil VARCHAR,
  p_descripcion TEXT,
  p_user_reg INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_perfil INTEGER;
BEGIN
  INSERT INTO aca_perfil_estudiante (
    nombre_perfil,
    descripcion,
    estado_perfil_estudiante,
    fecha_reg,
    user_reg
  ) VALUES (
    p_nombre_perfil,
    p_descripcion,
    'ACTIVO',
    CURRENT_TIMESTAMP,
    p_user_reg
  ) RETURNING id_aca_perfil_estudiante INTO v_id_perfil;

  RETURN v_id_perfil;
END;
$$;

COMMENT ON FUNCTION fn_registrar_perfil_estudiante IS 'Registra un nuevo perfil de estudiante';

-- Modificar perfil estudiante
CREATE OR REPLACE FUNCTION fn_modificar_perfil_estudiante(
  p_id_perfil INTEGER,
  p_nombre_perfil VARCHAR,
  p_descripcion TEXT,
  p_user_mod INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE aca_perfil_estudiante
  SET nombre_perfil = p_nombre_perfil,
      descripcion = p_descripcion,
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_aca_perfil_estudiante = p_id_perfil
    AND estado_perfil_estudiante = 'ACTIVO';

  RETURN FOUND;
END;
$$;

COMMENT ON FUNCTION fn_modificar_perfil_estudiante IS 'Modifica un perfil existente';

-- Eliminar perfil estudiante (lógico)
CREATE OR REPLACE FUNCTION fn_eliminar_perfil_estudiante(
  p_id_perfil INTEGER,
  p_user_mod INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE aca_perfil_estudiante
  SET estado_perfil_estudiante = 'ELIMINADO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_aca_perfil_estudiante = p_id_perfil
    AND estado_perfil_estudiante = 'ACTIVO';

  RETURN FOUND;
END;
$$;

COMMENT ON FUNCTION fn_eliminar_perfil_estudiante IS 'Elimina (lógicamente) un perfil de estudiante';

-- ============================================
-- FUNCIONES CRUD - REQUISITOS
-- ============================================

-- Registrar requisito
CREATE OR REPLACE FUNCTION fn_registrar_requisito(
  p_nombre_requisito VARCHAR,
  p_descripcion TEXT,
  p_orden_presentacion INTEGER,
  p_user_reg INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_id_requisito INTEGER;
BEGIN
  INSERT INTO aca_requisito (
    nombre_requisito,
    descripcion,
    orden_presentacion,
    estado_requisito,
    fecha_reg,
    user_reg
  ) VALUES (
    p_nombre_requisito,
    p_descripcion,
    COALESCE(p_orden_presentacion, 999),
    'ACTIVO',
    CURRENT_TIMESTAMP,
    p_user_reg
  ) RETURNING id_aca_requisito INTO v_id_requisito;

  RETURN v_id_requisito;
END;
$$;

COMMENT ON FUNCTION fn_registrar_requisito IS 'Registra un nuevo requisito';

-- Modificar requisito
CREATE OR REPLACE FUNCTION fn_modificar_requisito(
  p_id_requisito INTEGER,
  p_nombre_requisito VARCHAR,
  p_descripcion TEXT,
  p_orden_presentacion INTEGER,
  p_user_mod INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE aca_requisito
  SET nombre_requisito = p_nombre_requisito,
      descripcion = p_descripcion,
      orden_presentacion = p_orden_presentacion,
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_aca_requisito = p_id_requisito
    AND estado_requisito = 'ACTIVO';

  RETURN FOUND;
END;
$$;

COMMENT ON FUNCTION fn_modificar_requisito IS 'Modifica un requisito existente';

-- Eliminar requisito (lógico)
CREATE OR REPLACE FUNCTION fn_eliminar_requisito(
  p_id_requisito INTEGER,
  p_user_mod INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE aca_requisito
  SET estado_requisito = 'ELIMINADO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_aca_requisito = p_id_requisito
    AND estado_requisito = 'ACTIVO';

  RETURN FOUND;
END;
$$;

COMMENT ON FUNCTION fn_eliminar_requisito IS 'Elimina (lógicamente) un requisito';

-- ============================================
-- FUNCIONES DE ASIGNACIÓN - REQUISITOS A PERFIL
-- ============================================

-- Asignar requisitos a un perfil (array)
CREATE OR REPLACE FUNCTION fn_asignar_requisitos_perfil(
  p_id_perfil INTEGER,
  p_requisitos INTEGER[],
  p_user_reg INTEGER
)
RETURNS TABLE(
  id_aca_requisito_perfil INTEGER,
  id_aca_requisito INTEGER,
  mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_requisito INTEGER;
  v_id_asignacion INTEGER;
BEGIN
  -- Eliminar asignaciones previas
  UPDATE aca_requisito_perfil
  SET estado_requisito_perfil = 'ELIMINADO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_reg
  WHERE id_aca_perfil_estudiante = p_id_perfil
    AND estado_requisito_perfil = 'ACTIVO';

  -- Insertar nuevas asignaciones
  FOREACH v_requisito IN ARRAY p_requisitos
  LOOP
    INSERT INTO aca_requisito_perfil (
      id_aca_requisito,
      id_aca_perfil_estudiante,
      estado_requisito_perfil,
      fecha_reg,
      user_reg
    ) VALUES (
      v_requisito,
      p_id_perfil,
      'ACTIVO',
      CURRENT_TIMESTAMP,
      p_user_reg
    ) RETURNING id_aca_requisito_perfil INTO v_id_asignacion;

    RETURN QUERY SELECT v_id_asignacion, v_requisito, 'Asignado correctamente'::TEXT;
  END LOOP;
END;
$$;

COMMENT ON FUNCTION fn_asignar_requisitos_perfil IS 'Asigna un array de requisitos a un perfil (reemplaza asignaciones previas)';

-- ============================================
-- FUNCIONES DE ASIGNACIÓN - PERFILES A PROGRAMA
-- ============================================

-- Asignar perfiles a un programa (array)
CREATE OR REPLACE FUNCTION fn_asignar_perfiles_programa(
  p_id_programa INTEGER,
  p_perfiles INTEGER[],
  p_user_reg INTEGER
)
RETURNS TABLE(
  id_aca_programa_perfil INTEGER,
  id_aca_perfil_estudiante INTEGER,
  mensaje TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_perfil INTEGER;
  v_id_asignacion INTEGER;
BEGIN
  -- Eliminar asignaciones previas
  UPDATE aca_programa_perfil
  SET estado_programa_perfil = 'ELIMINADO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_reg
  WHERE id_aca_programa = p_id_programa
    AND estado_programa_perfil = 'ACTIVO';

  -- Insertar nuevas asignaciones
  FOREACH v_perfil IN ARRAY p_perfiles
  LOOP
    INSERT INTO aca_programa_perfil (
      id_aca_programa,
      id_aca_perfil_estudiante,
      estado_programa_perfil,
      fecha_reg,
      user_reg
    ) VALUES (
      p_id_programa,
      v_perfil,
      'ACTIVO',
      CURRENT_TIMESTAMP,
      p_user_reg
    ) RETURNING id_aca_programa_perfil INTO v_id_asignacion;

    RETURN QUERY SELECT v_id_asignacion, v_perfil, 'Asignado correctamente'::TEXT;
  END LOOP;
END;
$$;

COMMENT ON FUNCTION fn_asignar_perfiles_programa IS 'Asigna un array de perfiles elegibles a un programa (reemplaza asignaciones previas)';

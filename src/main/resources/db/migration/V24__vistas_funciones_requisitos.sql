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

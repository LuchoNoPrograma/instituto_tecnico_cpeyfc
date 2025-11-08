-- ====================================================================
-- MIGRACIÓN: Módulo de Publicaciones Web y Unidades Académicas
-- Descripción: Tablas, funciones y vistas para gestión de noticias
--              institucionales y catálogo de unidades académicas
-- Fecha: 2025-11-05
-- ====================================================================

-- ====================================================================
-- TABLAS
-- ====================================================================

-- Tabla: aca_unidad
-- Descripción: Catálogo de unidades académicas/administrativas institucionales
CREATE TABLE aca_unidad
(
  id_aca_unidad   SERIAL
    CONSTRAINT pk_aca_unidad PRIMARY KEY,
  nombre_unidad   VARCHAR(100) NOT NULL,
  descripcion     TEXT,
  estado_unidad   VARCHAR(35)  NOT NULL,
  fecha_reg       TIMESTAMP    NOT NULL,
  fecha_mod       TIMESTAMP,
  user_reg        INTEGER      NOT NULL,
  user_mod        INTEGER
);

COMMENT ON TABLE aca_unidad IS 'Catálogo de unidades académicas y administrativas de la institución';
COMMENT ON COLUMN aca_unidad.nombre_unidad IS 'Nombre de la unidad (Ej: Escuela Técnica, Gabinete Psicopedagógico)';
COMMENT ON COLUMN aca_unidad.descripcion IS 'Descripción opcional de la unidad';
COMMENT ON COLUMN aca_unidad.estado_unidad IS 'Estado de la unidad (ACTIVO, ELIMINADO)';
COMMENT ON COLUMN aca_unidad.fecha_reg IS 'Fecha de registro';
COMMENT ON COLUMN aca_unidad.fecha_mod IS 'Fecha de modificación';
COMMENT ON COLUMN aca_unidad.user_reg IS 'Usuario que registró';
COMMENT ON COLUMN aca_unidad.user_mod IS 'Usuario que modificó';

-- Tabla: pub_noticia
-- Descripción: Noticias institucionales para carrusel web
CREATE TABLE pub_noticia
(
  id_pub_noticia   SERIAL
    CONSTRAINT pk_pub_noticia PRIMARY KEY,
  id_aca_unidad    INTEGER      NOT NULL
    CONSTRAINT fk_pub_noticia_unidad
      REFERENCES aca_unidad(id_aca_unidad)
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  titulo           VARCHAR(255) NOT NULL,
  resumen          TEXT         NOT NULL,
  imagen_uri       VARCHAR(500),
  enlace_externo   VARCHAR(500),
  fecha_noticia    DATE         NOT NULL,
  es_destacada     BOOLEAN      DEFAULT FALSE,
  orden_prioridad  INTEGER      DEFAULT 0,
  estado_noticia   VARCHAR(35)  NOT NULL,
  fecha_reg        TIMESTAMP    NOT NULL,
  fecha_mod        TIMESTAMP,
  user_reg         INTEGER      NOT NULL,
  user_mod         INTEGER
);

COMMENT ON TABLE pub_noticia IS 'Noticias institucionales publicadas en carrusel web';
COMMENT ON COLUMN pub_noticia.id_aca_unidad IS 'Unidad académica que publica la noticia';
COMMENT ON COLUMN pub_noticia.titulo IS 'Título de la noticia';
COMMENT ON COLUMN pub_noticia.resumen IS 'Resumen o descripción breve de la noticia';
COMMENT ON COLUMN pub_noticia.imagen_uri IS 'URI/ruta de la imagen de portada';
COMMENT ON COLUMN pub_noticia.enlace_externo IS 'URL externa para más información (opcional)';
COMMENT ON COLUMN pub_noticia.fecha_noticia IS 'Fecha de publicación/vigencia de la noticia';
COMMENT ON COLUMN pub_noticia.es_destacada IS 'Marca si la noticia debe destacarse en el carrusel';
COMMENT ON COLUMN pub_noticia.orden_prioridad IS 'Orden de prioridad para ordenamiento (mayor = más prioritario)';
COMMENT ON COLUMN pub_noticia.estado_noticia IS 'Estado de la noticia (ACTIVO, INACTIVO, ELIMINADO)';
COMMENT ON COLUMN pub_noticia.fecha_reg IS 'Fecha de registro';
COMMENT ON COLUMN pub_noticia.fecha_mod IS 'Fecha de modificación';
COMMENT ON COLUMN pub_noticia.user_reg IS 'Usuario que registró';
COMMENT ON COLUMN pub_noticia.user_mod IS 'Usuario que modificó';

-- ====================================================================
-- FUNCIONES DE NEGOCIO
-- ====================================================================

-- Función: fn_registrar_aca_unidad
-- Descripción: Registra una nueva unidad académica/administrativa
CREATE OR REPLACE FUNCTION fn_registrar_unidad(
  p_nombre_unidad VARCHAR,
  p_descripcion TEXT,
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_unidad INTEGER;
  v_existe INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_nombre_unidad IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! El nombre de la unidad y el usuario son requeridos';
  END IF;

  -- Validar duplicados por nombre en registros activos
  SELECT COUNT(*)
  INTO v_existe
  FROM aca_unidad
  WHERE UPPER(TRIM(nombre_unidad)) = UPPER(TRIM(p_nombre_unidad))
    AND estado_unidad = 'ACTIVO';

  IF v_existe > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe una unidad activa con el nombre: %', p_nombre_unidad;
  END IF;

  -- Inserción con normalización de texto
  INSERT INTO aca_unidad(
    nombre_unidad, descripcion, estado_unidad, fecha_reg, user_reg
  )
  VALUES (
           UPPER(TRIM(p_nombre_unidad)),
           TRIM(p_descripcion),
           'ACTIVO',
           NOW(),
           p_user_reg
         )
  RETURNING id_aca_unidad INTO v_id_unidad;

  RETURN CONCAT('Unidad registrada exitosamente con ID: ', v_id_unidad);
END;
$$;

COMMENT ON FUNCTION fn_registrar_unidad IS 'Registra una nueva unidad académica/administrativa';

-- Función: fn_registrar_pub_noticia
-- Descripción: Registra una nueva noticia institucional
CREATE OR REPLACE FUNCTION fn_registrar_noticia(
  p_id_aca_unidad INTEGER,
  p_titulo VARCHAR,
  p_resumen TEXT,
  p_imagen_uri VARCHAR,
  p_enlace_externo VARCHAR,
  p_fecha_noticia DATE,
  p_es_destacada BOOLEAN,
  p_orden_prioridad INTEGER,
  p_user_reg INTEGER
) RETURNS INTEGER
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_noticia INTEGER;
  v_unidad_existe INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_unidad IS NULL OR p_titulo IS NULL OR p_resumen IS NULL OR
     p_fecha_noticia IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos unidad, título, resumen, fecha y usuario son requeridos';
  END IF;

  -- Validar que la unidad exista y esté activa
  SELECT COUNT(*)
  INTO v_unidad_existe
  FROM aca_unidad
  WHERE id_aca_unidad = p_id_aca_unidad
    AND estado_unidad = 'ACTIVO';

  IF v_unidad_existe = 0 THEN
    RAISE EXCEPTION 'Error! La unidad con ID % no existe o está inactiva', p_id_aca_unidad;
  END IF;

  -- Validar longitud del título
  IF LENGTH(TRIM(p_titulo)) < 5 THEN
    RAISE EXCEPTION 'Error! El título debe tener al menos 5 caracteres';
  END IF;

  -- Validar longitud del resumen
  IF LENGTH(TRIM(p_resumen)) < 20 THEN
    RAISE EXCEPTION 'Error! El resumen debe tener al menos 20 caracteres';
  END IF;

  -- Inserción con normalización
  INSERT INTO pub_noticia(
    id_aca_unidad, titulo, resumen, imagen_uri, enlace_externo,
    fecha_noticia, es_destacada, orden_prioridad, estado_noticia,
    fecha_reg, user_reg
  )
  VALUES (
           p_id_aca_unidad,
           TRIM(p_titulo),
           TRIM(p_resumen),
           TRIM(p_imagen_uri),
           TRIM(p_enlace_externo),
           p_fecha_noticia,
           COALESCE(p_es_destacada, FALSE),
           COALESCE(p_orden_prioridad, 0),
           'ACTIVO',
           NOW(),
           p_user_reg
         )
  RETURNING id_pub_noticia INTO v_id_noticia;

  RETURN v_id_noticia;
END;
$$;

COMMENT ON FUNCTION fn_registrar_noticia IS 'Registra una nueva noticia institucional para carrusel web';

-- Función: fn_actualizar_pub_noticia
-- Descripción: Actualiza una noticia existente
CREATE OR REPLACE FUNCTION fn_actualizar_noticia(
  p_id_pub_noticia INTEGER,
  p_id_aca_unidad INTEGER,
  p_titulo VARCHAR,
  p_resumen TEXT,
  p_imagen_uri VARCHAR,
  p_enlace_externo VARCHAR,
  p_fecha_noticia DATE,
  p_es_destacada BOOLEAN,
  p_orden_prioridad INTEGER,
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_noticia_existe INTEGER;
  v_unidad_existe INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_pub_noticia IS NULL OR p_id_aca_unidad IS NULL OR
     p_titulo IS NULL OR p_resumen IS NULL OR
     p_fecha_noticia IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos ID noticia, unidad, título, resumen, fecha y usuario son requeridos';
  END IF;

  -- Validar que la noticia exista y no esté eliminada
  SELECT COUNT(*)
  INTO v_noticia_existe
  FROM pub_noticia
  WHERE id_pub_noticia = p_id_pub_noticia
    AND estado_noticia <> 'ELIMINADO';

  IF v_noticia_existe = 0 THEN
    RAISE EXCEPTION 'Error! La noticia con ID % no existe o está eliminada', p_id_pub_noticia;
  END IF;

  -- Validar que la unidad exista y esté activa
  SELECT COUNT(*)
  INTO v_unidad_existe
  FROM aca_unidad
  WHERE id_aca_unidad = p_id_aca_unidad
    AND estado_unidad = 'ACTIVO';

  IF v_unidad_existe = 0 THEN
    RAISE EXCEPTION 'Error! La unidad con ID % no existe o está inactiva', p_id_aca_unidad;
  END IF;

  -- Validar longitud del título
  IF LENGTH(TRIM(p_titulo)) < 5 THEN
    RAISE EXCEPTION 'Error! El título debe tener al menos 5 caracteres';
  END IF;

  -- Validar longitud del resumen
  IF LENGTH(TRIM(p_resumen)) < 20 THEN
    RAISE EXCEPTION 'Error! El resumen debe tener al menos 20 caracteres';
  END IF;

  -- Actualización con normalización
  UPDATE pub_noticia
  SET id_aca_unidad = p_id_aca_unidad,
      titulo = TRIM(p_titulo),
      resumen = TRIM(p_resumen),
      imagen_uri = TRIM(p_imagen_uri),
      enlace_externo = TRIM(p_enlace_externo),
      fecha_noticia = p_fecha_noticia,
      es_destacada = COALESCE(p_es_destacada, FALSE),
      orden_prioridad = COALESCE(p_orden_prioridad, 0),
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_pub_noticia = p_id_pub_noticia;

  RETURN CONCAT('Noticia actualizada exitosamente con ID: ', p_id_pub_noticia);
END;
$$;

COMMENT ON FUNCTION fn_actualizar_noticia IS 'Actualiza los datos de una noticia institucional existente';

-- Función: fn_cambiar_estado_pub_noticia
-- Descripción: Cambia el estado de una noticia (ACTIVO/INACTIVO/ELIMINADO)
CREATE OR REPLACE FUNCTION fn_cambiar_estado_noticia(
  p_id_pub_noticia INTEGER,
  p_nuevo_estado VARCHAR,
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_noticia_existe INTEGER;
  v_estado_actual VARCHAR(35);
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_pub_noticia IS NULL OR p_nuevo_estado IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos ID noticia, estado y usuario son requeridos';
  END IF;

  -- Validar estados permitidos
  IF p_nuevo_estado NOT IN ('ACTIVO', 'INACTIVO', 'ELIMINADO') THEN
    RAISE EXCEPTION 'Error! Estado inválido. Use: ACTIVO, INACTIVO o ELIMINADO';
  END IF;

  -- Validar que la noticia exista
  SELECT COUNT(*), MAX(estado_noticia)
  INTO v_noticia_existe, v_estado_actual
  FROM pub_noticia
  WHERE id_pub_noticia = p_id_pub_noticia;

  IF v_noticia_existe = 0 THEN
    RAISE EXCEPTION 'Error! La noticia con ID % no existe', p_id_pub_noticia;
  END IF;

  -- Validar que no esté ya eliminada
  IF v_estado_actual = 'ELIMINADO' AND p_nuevo_estado <> 'ELIMINADO' THEN
    RAISE EXCEPTION 'Error! No se puede reactivar una noticia eliminada';
  END IF;

  -- Actualizar estado
  UPDATE pub_noticia
  SET estado_noticia = p_nuevo_estado,
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_pub_noticia = p_id_pub_noticia;

  RETURN CONCAT('Estado de noticia actualizado exitosamente a: ', p_nuevo_estado);
END;
$$;

COMMENT ON FUNCTION fn_cambiar_estado_noticia IS 'Cambia el estado de una noticia (eliminación lógica)';

-- ====================================================================
-- VISTAS
-- ====================================================================

-- Vista: vista_aca_unidades_activas
-- Descripción: Listado de unidades académicas activas
CREATE OR REPLACE VIEW vista_unidades_activas AS
SELECT
  u.id_aca_unidad,
  u.nombre_unidad,
  u.descripcion,
  u.estado_unidad,
  u.fecha_reg,
  COUNT(n.id_pub_noticia) AS total_noticias,
  COUNT(n.id_pub_noticia) FILTER (WHERE n.estado_noticia = 'ACTIVO') AS noticias_activas
FROM aca_unidad u
       LEFT JOIN pub_noticia n ON u.id_aca_unidad = n.id_aca_unidad
WHERE u.estado_unidad = 'ACTIVO'
GROUP BY u.id_aca_unidad, u.nombre_unidad, u.descripcion, u.estado_unidad, u.fecha_reg
ORDER BY u.nombre_unidad;

COMMENT ON VIEW vista_unidades_activas IS 'Listado de unidades académicas activas con conteo de noticias';

-- Vista: vista_pub_noticias_activas
-- Descripción: Listado completo de noticias activas para administración
CREATE OR REPLACE VIEW vista_noticias_activas AS
SELECT
  n.id_pub_noticia,
  n.id_aca_unidad,
  u.nombre_unidad,
  n.titulo,
  n.resumen,
  n.imagen_uri,
  n.enlace_externo,
  n.fecha_noticia,
  n.es_destacada,
  n.orden_prioridad,
  n.estado_noticia,
  n.fecha_reg,
  n.fecha_mod,
  CASE
    WHEN n.es_destacada = TRUE THEN 'DESTACADA'
    ELSE 'NORMAL'
    END AS tipo_noticia
FROM pub_noticia n
       JOIN aca_unidad u ON n.id_aca_unidad = u.id_aca_unidad
WHERE n.estado_noticia = 'ACTIVO'
  AND u.estado_unidad = 'ACTIVO'
ORDER BY n.orden_prioridad DESC, n.fecha_noticia DESC, n.fecha_reg DESC;

COMMENT ON VIEW vista_noticias_activas IS 'Noticias activas ordenadas por prioridad y fecha para administración';

-- Vista: vista_pub_noticias_carrusel
-- Descripción: Vista optimizada específicamente para el carrusel web (últimas 10 noticias)
CREATE OR REPLACE VIEW vista_noticias_carrusel AS
SELECT
  n.id_pub_noticia,
  n.titulo,
  n.resumen,
  n.imagen_uri,
  n.enlace_externo,
  n.fecha_noticia,
  u.nombre_unidad,
  n.es_destacada,
  n.orden_prioridad
FROM pub_noticia n
       JOIN aca_unidad u ON n.id_aca_unidad = u.id_aca_unidad
WHERE n.estado_noticia = 'ACTIVO'
  AND u.estado_unidad = 'ACTIVO'
  AND n.fecha_noticia <= CURRENT_DATE
ORDER BY
  n.es_destacada DESC,
  n.orden_prioridad DESC,
  n.fecha_noticia DESC
LIMIT 10;

COMMENT ON VIEW vista_noticias_carrusel IS 'Top 10 noticias optimizadas para carrusel web público';

-- Vista para listado administrativo con paginación
CREATE OR REPLACE VIEW vista_noticias_admin AS
SELECT
  pn.id_pub_noticia,
  pn.id_aca_unidad,
  au.nombre_unidad,
  pn.titulo,
  pn.resumen,
  pn.imagen_uri,
  pn.enlace_externo,
  pn.fecha_noticia,
  pn.es_destacada,
  pn.orden_prioridad,
  pn.estado_noticia,
  pn.fecha_reg,
  pn.fecha_mod,
  su.nombre_usuario as usuario_registro
FROM pub_noticia pn
       INNER JOIN aca_unidad au ON pn.id_aca_unidad = au.id_aca_unidad
       LEFT JOIN seg_usuario su ON pn.user_reg = su.id_seg_usuario
WHERE pn.estado_noticia != 'ELIMINADO'
ORDER BY
  pn.es_destacada DESC,
  pn.orden_prioridad DESC,
  pn.fecha_noticia DESC;

-- Vista para listado administrativo con paginación
CREATE OR REPLACE VIEW vista_pub_noticias_admin AS
SELECT
  pn.id_pub_noticia,
  pn.id_aca_unidad,
  au.nombre_unidad,
  pn.titulo,
  pn.resumen,
  pn.imagen_uri,
  pn.enlace_externo,
  pn.fecha_noticia,
  pn.es_destacada,
  pn.orden_prioridad,
  pn.estado_noticia,
  pn.fecha_reg,
  pn.fecha_mod,
  su.nombre_usuario as usuario_registro
FROM pub_noticia pn
       INNER JOIN aca_unidad au ON pn.id_aca_unidad = au.id_aca_unidad
       LEFT JOIN seg_usuario su ON pn.user_reg = su.id_seg_usuario
WHERE pn.estado_noticia != 'ELIMINADO'
ORDER BY
  pn.es_destacada DESC,
  pn.orden_prioridad DESC,
  pn.fecha_noticia DESC;

-- Función para obtener noticias con paginación
CREATE OR REPLACE FUNCTION fn_obtener_noticias_paginadas(
  p_page INTEGER,
  p_size INTEGER,
  p_busqueda VARCHAR DEFAULT NULL,
  p_estado VARCHAR DEFAULT NULL,
  p_id_unidad INTEGER DEFAULT NULL
)
  RETURNS TABLE(
                 id_pub_noticia INTEGER,
                 id_aca_unidad INTEGER,
                 nombre_unidad VARCHAR,
                 titulo VARCHAR,
                 resumen TEXT,
                 imagen_uri VARCHAR,
                 enlace_externo VARCHAR,
                 fecha_noticia DATE,
                 es_destacada BOOLEAN,
                 orden_prioridad INTEGER,
                 estado_noticia VARCHAR,
                 fecha_reg TIMESTAMP,
                 usuario_registro VARCHAR,
                 total_registros BIGINT
               ) AS $$
DECLARE
  v_offset INTEGER;
BEGIN
  v_offset := (p_page - 1) * p_size;

  RETURN QUERY
    WITH datos AS (
      SELECT
        vn.*,
        COUNT(*) OVER() as total
      FROM vista_pub_noticias_admin vn
      WHERE
        (p_busqueda IS NULL OR
         vn.titulo ILIKE '%' || p_busqueda || '%' OR
         vn.resumen ILIKE '%' || p_busqueda || '%')
        AND (p_estado IS NULL OR vn.estado_noticia = p_estado)
        AND (p_id_unidad IS NULL OR vn.id_aca_unidad = p_id_unidad)
    )
    SELECT
      d.id_pub_noticia,
      d.id_aca_unidad,
      d.nombre_unidad,
      d.titulo,
      d.resumen,
      d.imagen_uri,
      d.enlace_externo,
      d.fecha_noticia,
      d.es_destacada,
      d.orden_prioridad,
      d.estado_noticia,
      d.fecha_reg,
      d.usuario_registro,
      d.total
    FROM datos d
    LIMIT p_size
      OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;
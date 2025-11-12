-- ================================================
-- Migración V10: Refactorización pub_noticia
-- Renombrar 'resumen' → 'contenido' (HTML rico)
-- Crear 'resumen' (texto plano generado automáticamente)
-- ================================================

-- Paso 1: Renombrar columna resumen → contenido
ALTER TABLE pub_noticia RENAME COLUMN resumen TO contenido;

-- Paso 2: Crear nueva columna resumen (texto plano)
ALTER TABLE pub_noticia ADD COLUMN resumen TEXT;

-- Paso 3: Función para extraer texto plano de HTML
CREATE OR REPLACE FUNCTION extraer_texto_de_html(html_content TEXT)
RETURNS TEXT AS $$
DECLARE
  texto_limpio TEXT;
BEGIN
  IF html_content IS NULL OR html_content = '' THEN
    RETURN '';
  END IF;

  -- Remover todas las etiquetas HTML
  texto_limpio := regexp_replace(html_content, '<[^>]+>', '', 'g');

  -- Decodificar entidades HTML comunes
  texto_limpio := replace(texto_limpio, '&nbsp;', ' ');
  texto_limpio := replace(texto_limpio, '&amp;', '&');
  texto_limpio := replace(texto_limpio, '&lt;', '<');
  texto_limpio := replace(texto_limpio, '&gt;', '>');
  texto_limpio := replace(texto_limpio, '&quot;', '"');
  texto_limpio := replace(texto_limpio, '&#39;', '''');

  -- Normalizar espacios en blanco múltiples
  texto_limpio := regexp_replace(texto_limpio, '\s+', ' ', 'g');

  -- Trim inicial y final
  texto_limpio := trim(texto_limpio);

  RETURN texto_limpio;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION extraer_texto_de_html(TEXT) IS 'Extrae texto plano de contenido HTML para previews';

-- Paso 4: Trigger function para generar resumen automáticamente
CREATE OR REPLACE FUNCTION trigger_generar_resumen()
RETURNS TRIGGER AS $$
BEGIN
  NEW.resumen := extraer_texto_de_html(NEW.contenido);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Paso 5: Crear trigger
DROP TRIGGER IF EXISTS trigger_generar_resumen ON pub_noticia;

CREATE TRIGGER trigger_generar_resumen
  BEFORE INSERT OR UPDATE OF contenido ON pub_noticia
  FOR EACH ROW
  EXECUTE FUNCTION trigger_generar_resumen();

COMMENT ON TRIGGER trigger_generar_resumen ON pub_noticia IS 'Genera automáticamente resumen en texto plano desde el contenido HTML';

-- Paso 6: Poblar resumen de registros existentes
UPDATE pub_noticia
SET resumen = extraer_texto_de_html(contenido)
WHERE contenido IS NOT NULL;

-- Paso 7: Recrear vista_noticias_carrusel con nueva estructura
DROP VIEW IF EXISTS vista_noticias_carrusel CASCADE;

CREATE OR REPLACE VIEW vista_noticias_carrusel AS
SELECT
  n.id_pub_noticia,
  n.titulo,
  n.resumen,           -- Texto plano para preview
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
ORDER BY n.es_destacada DESC, n.orden_prioridad DESC, n.fecha_noticia DESC
LIMIT 10;

COMMENT ON VIEW vista_noticias_carrusel IS 'Top 10 noticias optimizadas para carrusel web público (con resumen texto plano)';

-- Paso 8: Recrear vista_noticias_activas
DROP VIEW IF EXISTS vista_noticias_activas CASCADE;

CREATE OR REPLACE VIEW vista_noticias_activas AS
SELECT
  n.id_pub_noticia,
  n.id_aca_unidad,
  u.nombre_unidad,
  n.titulo,
  n.resumen,           -- Texto plano
  n.contenido,         -- HTML completo
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

COMMENT ON VIEW vista_noticias_activas IS 'Noticias activas con contenido HTML y resumen texto plano';

-- Paso 9: Recrear vista_noticias_admin
DROP VIEW IF EXISTS vista_noticias_admin CASCADE;

CREATE OR REPLACE VIEW vista_noticias_admin AS
SELECT
  pn.id_pub_noticia,
  pn.id_aca_unidad,
  au.nombre_unidad,
  pn.titulo,
  pn.resumen,          -- Texto plano
  pn.contenido,        -- HTML completo
  pn.imagen_uri,
  pn.enlace_externo,
  pn.fecha_noticia,
  pn.es_destacada,
  pn.orden_prioridad,
  pn.estado_noticia,
  pn.fecha_reg,
  pn.fecha_mod,
  su.nombre_usuario AS usuario_registro
FROM pub_noticia pn
JOIN aca_unidad au ON pn.id_aca_unidad = au.id_aca_unidad
LEFT JOIN seg_usuario su ON pn.user_reg = su.id_seg_usuario
WHERE pn.estado_noticia <> 'ELIMINADO'
ORDER BY pn.es_destacada DESC, pn.orden_prioridad DESC, pn.fecha_noticia DESC;

COMMENT ON VIEW vista_noticias_admin IS 'Vista administrativa de noticias con contenido HTML y resumen';

-- Paso 10: Actualizar funciones - fn_registrar_noticia
DROP FUNCTION IF EXISTS fn_registrar_noticia(INTEGER, VARCHAR, TEXT, VARCHAR, VARCHAR, DATE, BOOLEAN, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION fn_registrar_noticia(
  p_id_aca_unidad INTEGER,
  p_titulo VARCHAR,
  p_contenido TEXT,           -- Cambiado de p_resumen
  p_imagen_uri VARCHAR,
  p_enlace_externo VARCHAR,
  p_fecha_noticia DATE,
  p_es_destacada BOOLEAN,
  p_orden_prioridad INTEGER,
  p_user_reg INTEGER
)
RETURNS INTEGER AS $$
DECLARE
  v_id_noticia INTEGER;
  v_unidad_existe INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_unidad IS NULL OR p_titulo IS NULL OR p_contenido IS NULL OR
     p_fecha_noticia IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos unidad, título, contenido, fecha y usuario son requeridos';
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

  -- Validar longitud del contenido
  IF LENGTH(TRIM(p_contenido)) < 20 THEN
    RAISE EXCEPTION 'Error! El contenido debe tener al menos 20 caracteres';
  END IF;

  -- Inserción (el trigger generará resumen automáticamente)
  INSERT INTO pub_noticia(
    id_aca_unidad, titulo, contenido, imagen_uri, enlace_externo,
    fecha_noticia, es_destacada, orden_prioridad, estado_noticia,
    fecha_reg, user_reg
  )
  VALUES (
    p_id_aca_unidad,
    TRIM(p_titulo),
    TRIM(p_contenido),
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
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_registrar_noticia(INTEGER, VARCHAR, TEXT, VARCHAR, VARCHAR, DATE, BOOLEAN, INTEGER, INTEGER)
IS 'Registra una nueva noticia con contenido HTML (trigger genera resumen automático)';

-- Paso 11: Actualizar fn_actualizar_noticia
DROP FUNCTION IF EXISTS fn_actualizar_noticia(INTEGER, INTEGER, VARCHAR, TEXT, VARCHAR, VARCHAR, DATE, BOOLEAN, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION fn_actualizar_noticia(
  p_id_pub_noticia INTEGER,
  p_id_aca_unidad INTEGER,
  p_titulo VARCHAR,
  p_contenido TEXT,           -- Cambiado de p_resumen
  p_imagen_uri VARCHAR,
  p_enlace_externo VARCHAR,
  p_fecha_noticia DATE,
  p_es_destacada BOOLEAN,
  p_orden_prioridad INTEGER,
  p_user_mod INTEGER
)
RETURNS TEXT AS $$
DECLARE
  v_noticia_existe INTEGER;
  v_unidad_existe INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_pub_noticia IS NULL OR p_id_aca_unidad IS NULL OR
     p_titulo IS NULL OR p_contenido IS NULL OR
     p_fecha_noticia IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos ID noticia, unidad, título, contenido, fecha y usuario son requeridos';
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

  -- Validar longitud del contenido
  IF LENGTH(TRIM(p_contenido)) < 20 THEN
    RAISE EXCEPTION 'Error! El contenido debe tener al menos 20 caracteres';
  END IF;

  -- Actualización (el trigger generará resumen automáticamente)
  UPDATE pub_noticia
  SET id_aca_unidad = p_id_aca_unidad,
      titulo = TRIM(p_titulo),
      contenido = TRIM(p_contenido),
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
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_actualizar_noticia(INTEGER, INTEGER, VARCHAR, TEXT, VARCHAR, VARCHAR, DATE, BOOLEAN, INTEGER, INTEGER)
IS 'Actualiza noticia con contenido HTML (trigger genera resumen automático)';

-- Paso 12: Crear índice para búsquedas en resumen
CREATE INDEX IF NOT EXISTS idx_pub_noticia_resumen_tsvector
ON pub_noticia USING gin(to_tsvector('spanish', resumen));

COMMENT ON INDEX idx_pub_noticia_resumen_tsvector IS 'Índice full-text search en resumen para búsquedas rápidas';

-- Paso 13: Verificación final
DO $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM pub_noticia WHERE resumen IS NULL AND contenido IS NOT NULL;

  IF v_count > 0 THEN
    RAISE EXCEPTION 'Error! Hay % registros con contenido pero sin resumen generado', v_count;
  END IF;

  RAISE NOTICE 'Migración V10 completada exitosamente. Todas las noticias tienen resumen generado.';
END $$;


DROP FUNCTION IF EXISTS  fn_obtener_noticias_paginadas(p_page INTEGER, p_size INTEGER, p_busqueda VARCHAR, p_estado VARCHAR, p_id_unidad INTEGER);
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
                 contenido TEXT,
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
      FROM vista_noticias_admin vn
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
      d.contenido,
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

COMMENT ON FUNCTION fn_obtener_noticias_paginadas IS 'Obtiene noticias paginadas con filtros (incluye contenido HTML y resumen texto plano)';
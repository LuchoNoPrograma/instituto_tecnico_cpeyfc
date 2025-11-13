-- =====================================================
-- Descripción: Deprecar precios, agregar imágenes/objetivos,
--              sistema de habilidades y vistas públicas
-- =====================================================

-- =====================================================
-- ALTER: aca_programa
-- Agregar objetivo e imagen base
-- =====================================================
ALTER TABLE aca_programa
  ADD COLUMN IF NOT EXISTS objetivo TEXT,
  ADD COLUMN IF NOT EXISTS imagen_url VARCHAR(500);

COMMENT ON COLUMN aca_programa.objetivo IS 'Objetivo general del programa académico';
COMMENT ON COLUMN aca_programa.imagen_url IS 'URL de imagen base/genérica del programa';

-- =====================================================
-- ALTER: aca_programa_aprobado
-- Agregar imagen promocional específica de la gestión
-- =====================================================
ALTER TABLE aca_programa_aprobado
  ADD COLUMN IF NOT EXISTS imagen_programa_url VARCHAR(500);

COMMENT ON COLUMN aca_programa_aprobado.imagen_programa_url IS 'URL de imagen promocional específica de la gestión/oferta';

-- =====================================================
-- TABLA: aca_programa_habilidad
-- Habilidades/características del programa para marketing
-- =====================================================
CREATE TABLE aca_programa_habilidad (
                                      id_programa_habilidad SERIAL PRIMARY KEY,
                                      id_aca_programa INTEGER NOT NULL REFERENCES aca_programa(id_aca_programa),
                                      nombre_habilidad VARCHAR(100) NOT NULL,
                                      estado_programa_habilidad VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
                                      fecha_reg TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      user_reg INTEGER NOT NULL,
                                      fecha_mod TIMESTAMP,
                                      user_mod INTEGER,

                                      CONSTRAINT uk_programa_habilidad UNIQUE (id_aca_programa, nombre_habilidad)
);

COMMENT ON TABLE aca_programa_habilidad IS 'Habilidades/tags del programa para visualización en frontend';
COMMENT ON COLUMN aca_programa_habilidad.nombre_habilidad IS 'Nombre corto de la habilidad (ej: Programación, Bases de Datos)';
COMMENT ON COLUMN aca_programa_habilidad.estado_programa_habilidad IS 'Estados: ACTIVO, ELIMINADO';

CREATE INDEX idx_programa_habilidad_programa ON aca_programa_habilidad(id_aca_programa);

-- =====================================================
-- VISTA: vista_aranceles_programas_publicos
-- Aranceles por programa aprobado para ofertas públicas
-- =====================================================

CREATE OR REPLACE VIEW vista_aranceles_programas_publicos AS
SELECT
  pa.id_aca_programa_aprobado,
  p.id_aca_programa,
  p.nombre_programa,
  pa.gestion,
  pe.anho AS plan_anho,
  v.cod_version,
  m.nombre_modalidad,
  g.nombre_grupo,
  ar.id_arancel,
  ar.concepto,
  ar.tipo_beneficiario,
  ar.monto AS arancel_monto,
  ar.vigencia_desde,
  ar.vigencia_hasta
FROM aca_programa_aprobado pa
       JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
       LEFT JOIN aca_version v ON pa.id_aca_version = v.id_aca_version
       LEFT JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
       JOIN ins_grupo g ON pa.id_aca_programa_aprobado = g.id_aca_programa_aprobado
       LEFT JOIN LATERAL fn_obtener_aranceles_programa(pa.id_aca_programa_aprobado) ar ON true
WHERE pa.estado_programa_aprobado IN ('SIN INICIAR', 'EN EJECUCION')
  AND g.estado_grupo != 'ELIMINADO'
  AND p.estado_programa != 'ELIMINADO'
  AND m.estado_modalidad != 'ELIMINADO'
  AND g.fecha_fin_inscripcion >= CURRENT_DATE
  AND g.fecha_inicio_inscripcion <= CURRENT_DATE + INTERVAL '30 days'
ORDER BY p.nombre_programa, pa.gestion, g.nombre_grupo, ar.concepto, ar.tipo_beneficiario;

COMMENT ON VIEW vista_aranceles_programas_publicos IS 'Aranceles detallados por programa para consulta pública';

-- =====================================================
-- VISTA: vista_programas_publicos (ACTUALIZADA)
-- Remover campos de precios deprecados
-- =====================================================
alter table public.aca_programa_aprobado
  alter column precio_matricula drop not null;

alter table public.aca_programa_aprobado
  alter column precio_colegiatura drop not null;



CREATE OR REPLACE VIEW vista_programas_publicos AS
SELECT
  pa.id_aca_programa_aprobado,
  g.id_ins_grupo,
  p.id_aca_programa,
  a.nombre_area,
  p.nombre_programa,
  p.sigla AS programa_sigla,
  p.objetivo,
  pa.gestion,
  COALESCE(pa.imagen_programa_url, p.imagen_url) AS imagen_url,
  pe.anho AS plan_anho,
  v.cod_version,
  m.nombre_modalidad,
  g.nombre_grupo,
  g.gestion_inicio,
  g.fecha_inicio_inscripcion,
  g.fecha_fin_inscripcion,
  CASE
    WHEN g.fecha_fin_inscripcion >= CURRENT_DATE AND g.fecha_inicio_inscripcion <= CURRENT_DATE
      THEN 'INSCRIPCIONES ABIERTAS'
    WHEN g.fecha_inicio_inscripcion > CURRENT_DATE THEN 'PROXIMAMENTE'
    ELSE 'INSCRIPCIONES CERRADAS'
    END AS estado_inscripcion,
  CASE
    WHEN g.fecha_fin_inscripcion >= CURRENT_DATE THEN g.fecha_fin_inscripcion - CURRENT_DATE
    ELSE 0
    END AS dias_restantes_inscripcion,
  pa.estado_programa_aprobado,
  g.estado_grupo,
  (SELECT count(*) FROM ins_preinscripcion pre
   WHERE pre.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
     AND pre.estado_preinscripcion = 'ACTIVO') AS total_preinscritos,
  (SELECT count(*) FROM ins_matricula mat
   WHERE mat.id_ins_grupo = g.id_ins_grupo
     AND mat.estado_matricula = 'ACTIVO') AS total_matriculados,
  (SELECT sum(pmd.carga_horaria) FROM aca_plan_modulo_detalle pmd
   WHERE pmd.id_aca_plan_estudio = pe.id_aca_plan_estudio) AS carga_horaria,
  g.fecha_reg AS fecha_reg_grupo,
  pa.fecha_reg AS fecha_reg_programa
FROM aca_programa_aprobado pa
       JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       JOIN aca_area a ON p.id_aca_area = a.id_aca_area
       JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
       LEFT JOIN aca_version v ON pa.id_aca_version = v.id_aca_version
       LEFT JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
       JOIN ins_grupo g ON pa.id_aca_programa_aprobado = g.id_aca_programa_aprobado
WHERE pa.estado_programa_aprobado IN ('SIN INICIAR', 'EN EJECUCION')
  AND g.estado_grupo != 'ELIMINADO'
  AND p.estado_programa != 'ELIMINADO'
  AND a.estado_area != 'ELIMINADO'
  AND m.estado_modalidad != 'ELIMINADO'
  AND g.fecha_fin_inscripcion >= CURRENT_DATE
  AND g.fecha_inicio_inscripcion <= CURRENT_DATE + INTERVAL '30 days'
ORDER BY
  CASE WHEN g.fecha_fin_inscripcion >= CURRENT_DATE AND g.fecha_inicio_inscripcion <= CURRENT_DATE
         THEN 1 ELSE 2 END,
  g.fecha_fin_inscripcion - CURRENT_DATE,
  p.nombre_programa;

COMMENT ON VIEW vista_programas_publicos IS 'Vista para oferta pública de programas - sin precios (usar vista_aranceles_programas_publicos)';

-- =====================================================
-- FUNCIÓN: fn_registrar_programa_aprobado (ACTUALIZADA)
-- Sin parámetros de precios, con imagen_programa_url
-- =====================================================
DROP FUNCTION IF EXISTS fn_registrar_programa_aprobado(p_id_aca_programa integer, p_id_aca_modalidad integer, p_gestion integer, p_id_aca_plan_estudio integer, p_id_aca_version integer, p_estado_programa_aprobado character varying, p_cod_certificado_ceub character varying, p_precio_matricula numeric, p_precio_colegiatura numeric, p_precio_titulacion numeric, p_fecha_inicio_vigencia date, p_fecha_fin_vigencia date, p_user_reg integer);
CREATE OR REPLACE FUNCTION fn_registrar_programa_aprobado(
  p_id_aca_programa INTEGER,
  p_id_aca_modalidad INTEGER,
  p_gestion INTEGER,
  p_id_aca_plan_estudio INTEGER,
  p_id_aca_version INTEGER,
  p_estado_programa_aprobado VARCHAR,
  p_cod_certificado_ceub VARCHAR,
  p_imagen_programa_url VARCHAR,
  p_fecha_inicio_vigencia DATE,
  p_fecha_fin_vigencia DATE,
  p_user_reg INTEGER
)
  RETURNS INTEGER AS $$
DECLARE
  v_id_programa_aprobado INTEGER;
  v_existe_programa INTEGER;
  v_existe_modalidad INTEGER;
  v_existe_plan INTEGER;
  v_existe_version INTEGER;
  v_duplicado INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_aca_programa IS NULL OR p_id_aca_modalidad IS NULL OR
     p_gestion IS NULL OR p_estado_programa_aprobado IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar existencia de programa
  SELECT COUNT(*) INTO v_existe_programa
  FROM aca_programa
  WHERE id_aca_programa = p_id_aca_programa
    AND estado_programa != 'ELIMINADO';

  IF v_existe_programa = 0 THEN
    RAISE EXCEPTION 'Error! El programa no existe';
  END IF;

  -- Validar existencia de modalidad
  SELECT COUNT(*) INTO v_existe_modalidad
  FROM aca_modalidad
  WHERE id_aca_modalidad = p_id_aca_modalidad
    AND estado_modalidad != 'ELIMINADO';

  IF v_existe_modalidad = 0 THEN
    RAISE EXCEPTION 'Error! La modalidad no existe';
  END IF;

  -- Validar existencia de plan (si no es NULL)
  IF p_id_aca_plan_estudio IS NOT NULL THEN
    SELECT COUNT(*) INTO v_existe_plan
    FROM aca_plan_estudio
    WHERE id_aca_plan_estudio = p_id_aca_plan_estudio
      AND estado_plan_estudio != 'ELIMINADO';

    IF v_existe_plan = 0 THEN
      RAISE EXCEPTION 'Error! El plan de estudio no existe';
    END IF;
  END IF;

  -- Validar existencia de versión (si no es NULL)
  IF p_id_aca_version IS NOT NULL THEN
    SELECT COUNT(*) INTO v_existe_version
    FROM aca_version
    WHERE id_aca_version = p_id_aca_version
      AND estado_version != 'ELIMINADO';

    IF v_existe_version = 0 THEN
      RAISE EXCEPTION 'Error! La versión no existe';
    END IF;
  END IF;

  -- Validar duplicados (programa + modalidad + gestión)
  SELECT COUNT(*) INTO v_duplicado
  FROM aca_programa_aprobado
  WHERE id_aca_programa = p_id_aca_programa
    AND id_aca_modalidad = p_id_aca_modalidad
    AND gestion = p_gestion
    AND estado_programa_aprobado != 'ELIMINADO';

  IF v_duplicado > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe un programa aprobado con esta combinación programa-modalidad-gestión';
  END IF;

  -- Validar fechas
  IF p_fecha_fin_vigencia IS NOT NULL AND p_fecha_fin_vigencia < p_fecha_inicio_vigencia THEN
    RAISE EXCEPTION 'Error! Fecha fin no puede ser anterior a fecha inicio';
  END IF;

  -- Inserción
  INSERT INTO aca_programa_aprobado(
    id_aca_programa,
    id_aca_modalidad,
    gestion,
    id_aca_plan_estudio,
    id_aca_version,
    estado_programa_aprobado,
    cod_certificado_ceub,
    imagen_programa_url,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    fecha_reg,
    user_reg
  ) VALUES (
             p_id_aca_programa,
             p_id_aca_modalidad,
             p_gestion,
             p_id_aca_plan_estudio,
             p_id_aca_version,
             UPPER(TRIM(p_estado_programa_aprobado)),
             TRIM(p_cod_certificado_ceub),
             TRIM(p_imagen_programa_url),
             p_fecha_inicio_vigencia,
             p_fecha_fin_vigencia,
             CURRENT_TIMESTAMP,
             p_user_reg
           ) RETURNING id_aca_programa_aprobado INTO v_id_programa_aprobado;

  RETURN v_id_programa_aprobado;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_registrar_programa_aprobado IS 'Registra programa aprobado sin precios (usar sistema de aranceles)';

-- =====================================================
-- FUNCIÓN: fn_modificar_programa_aprobado (ACTUALIZADA)
-- Sin parámetros de precios, con imagen_programa_url
-- =====================================================
DROP FUNCTION IF EXISTS fn_modificar_programa_aprobado(integer, integer, integer, integer, integer, integer, varchar,
                                                       numeric, numeric, numeric, date, date, varchar, varchar, integer);
CREATE OR REPLACE FUNCTION fn_modificar_programa_aprobado(
  p_id_aca_programa_aprobado INTEGER,
  p_id_aca_plan_estudio INTEGER,
  p_id_aca_version INTEGER,
  p_estado_programa_aprobado VARCHAR,
  p_cod_certificado_ceub VARCHAR,
  p_imagen_programa_url VARCHAR,
  p_fecha_inicio_vigencia DATE,
  p_fecha_fin_vigencia DATE,
  p_user_mod INTEGER
)
  RETURNS TEXT AS $$
DECLARE
  v_existe INTEGER;
  v_existe_plan INTEGER;
  v_existe_version INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_aca_programa_aprobado IS NULL OR p_estado_programa_aprobado IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar existencia
  SELECT COUNT(*) INTO v_existe
  FROM aca_programa_aprobado
  WHERE id_aca_programa_aprobado = p_id_aca_programa_aprobado
    AND estado_programa_aprobado != 'ELIMINADO';

  IF v_existe = 0 THEN
    RAISE EXCEPTION 'Error! El programa aprobado no existe';
  END IF;

  -- Validar existencia de plan (si no es NULL)
  IF p_id_aca_plan_estudio IS NOT NULL THEN
    SELECT COUNT(*) INTO v_existe_plan
    FROM aca_plan_estudio
    WHERE id_aca_plan_estudio = p_id_aca_plan_estudio
      AND estado_plan_estudio != 'ELIMINADO';

    IF v_existe_plan = 0 THEN
      RAISE EXCEPTION 'Error! El plan de estudio no existe';
    END IF;
  END IF;

  -- Validar existencia de versión (si no es NULL)
  IF p_id_aca_version IS NOT NULL THEN
    SELECT COUNT(*) INTO v_existe_version
    FROM aca_version
    WHERE id_aca_version = p_id_aca_version
      AND estado_version != 'ELIMINADO';

    IF v_existe_version = 0 THEN
      RAISE EXCEPTION 'Error! La versión no existe';
    END IF;
  END IF;

  -- Validar fechas
  IF p_fecha_fin_vigencia IS NOT NULL AND p_fecha_fin_vigencia < p_fecha_inicio_vigencia THEN
    RAISE EXCEPTION 'Error! Fecha fin no puede ser anterior a fecha inicio';
  END IF;

  -- Actualización
  UPDATE aca_programa_aprobado
  SET id_aca_plan_estudio = p_id_aca_plan_estudio,
      id_aca_version = p_id_aca_version,
      estado_programa_aprobado = UPPER(TRIM(p_estado_programa_aprobado)),
      cod_certificado_ceub = TRIM(p_cod_certificado_ceub),
      imagen_programa_url = TRIM(p_imagen_programa_url),
      fecha_inicio_vigencia = p_fecha_inicio_vigencia,
      fecha_fin_vigencia = p_fecha_fin_vigencia,
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_aca_programa_aprobado = p_id_aca_programa_aprobado;

  RETURN CONCAT('Programa aprobado modificado exitosamente con ID: ', p_id_aca_programa_aprobado);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_modificar_programa_aprobado IS 'Modifica programa aprobado sin precios (usar sistema de aranceles)';

-- =====================================================
-- FUNCIONES: aca_programa_habilidad
-- =====================================================

-- -----------------------------------------------------
-- FUNCIÓN: fn_registrar_habilidad_programa
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_registrar_habilidad_programa(
  p_id_aca_programa INTEGER,
  p_nombre_habilidad VARCHAR,
  p_user_reg INTEGER
)
  RETURNS INTEGER AS $$
DECLARE
  v_id_programa_habilidad INTEGER;
  v_existe_programa INTEGER;
  v_duplicado INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_aca_programa IS NULL OR p_nombre_habilidad IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar existencia del programa
  SELECT COUNT(*) INTO v_existe_programa
  FROM aca_programa
  WHERE id_aca_programa = p_id_aca_programa
    AND estado_programa != 'ELIMINADO';

  IF v_existe_programa = 0 THEN
    RAISE EXCEPTION 'Error! El programa no existe';
  END IF;

  -- Validar duplicados
  SELECT COUNT(*) INTO v_duplicado
  FROM aca_programa_habilidad
  WHERE id_aca_programa = p_id_aca_programa
    AND UPPER(TRIM(nombre_habilidad)) = UPPER(TRIM(p_nombre_habilidad))
    AND estado_programa_habilidad != 'ELIMINADO';

  IF v_duplicado > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe una habilidad con este nombre para el programa';
  END IF;

  -- Inserción
  INSERT INTO aca_programa_habilidad(
    id_aca_programa,
    nombre_habilidad,
    estado_programa_habilidad,
    fecha_reg,
    user_reg
  ) VALUES (
             p_id_aca_programa,
             UPPER(TRIM(p_nombre_habilidad)),
             'ACTIVO',
             CURRENT_TIMESTAMP,
             p_user_reg
           ) RETURNING id_programa_habilidad INTO v_id_programa_habilidad;

  RETURN v_id_programa_habilidad;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_registrar_habilidad_programa IS 'Registra una habilidad/tag para un programa';

-- -----------------------------------------------------
-- FUNCIÓN: fn_modificar_habilidad_programa
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_modificar_habilidad_programa(
  p_id_programa_habilidad INTEGER,
  p_nombre_habilidad VARCHAR,
  p_estado_programa_habilidad VARCHAR,
  p_user_mod INTEGER
)
  RETURNS TEXT AS $$
DECLARE
  v_existe INTEGER;
  v_duplicado INTEGER;
  v_id_programa INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_programa_habilidad IS NULL OR p_nombre_habilidad IS NULL OR
     p_estado_programa_habilidad IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar existencia y obtener id_programa
  SELECT COUNT(*), MAX(id_aca_programa) INTO v_existe, v_id_programa
  FROM aca_programa_habilidad
  WHERE id_programa_habilidad = p_id_programa_habilidad
    AND estado_programa_habilidad != 'ELIMINADO';

  IF v_existe = 0 THEN
    RAISE EXCEPTION 'Error! La habilidad no existe';
  END IF;

  -- Validar duplicados (excluyendo actual)
  SELECT COUNT(*) INTO v_duplicado
  FROM aca_programa_habilidad
  WHERE id_aca_programa = v_id_programa
    AND UPPER(TRIM(nombre_habilidad)) = UPPER(TRIM(p_nombre_habilidad))
    AND estado_programa_habilidad != 'ELIMINADO'
    AND id_programa_habilidad != p_id_programa_habilidad;

  IF v_duplicado > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe otra habilidad con este nombre para el programa';
  END IF;

  -- Actualización
  UPDATE aca_programa_habilidad
  SET nombre_habilidad = UPPER(TRIM(p_nombre_habilidad)),
      estado_programa_habilidad = UPPER(TRIM(p_estado_programa_habilidad)),
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_programa_habilidad = p_id_programa_habilidad;

  RETURN CONCAT('Habilidad modificada exitosamente con ID: ', p_id_programa_habilidad);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_modificar_habilidad_programa IS 'Modifica una habilidad de programa';

-- -----------------------------------------------------
-- FUNCIÓN: fn_eliminar_habilidad_programa
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_eliminar_habilidad_programa(
  p_id_programa_habilidad INTEGER,
  p_user_mod INTEGER
)
  RETURNS TEXT AS $$
DECLARE
  v_existe INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_programa_habilidad IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar existencia
  SELECT COUNT(*) INTO v_existe
  FROM aca_programa_habilidad
  WHERE id_programa_habilidad = p_id_programa_habilidad
    AND estado_programa_habilidad != 'ELIMINADO';

  IF v_existe = 0 THEN
    RAISE EXCEPTION 'Error! La habilidad no existe';
  END IF;

  -- Eliminación lógica
  UPDATE aca_programa_habilidad
  SET estado_programa_habilidad = 'ELIMINADO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_programa_habilidad = p_id_programa_habilidad;

  RETURN CONCAT('Habilidad eliminada exitosamente con ID: ', p_id_programa_habilidad);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_eliminar_habilidad_programa IS 'Elimina lógicamente una habilidad de programa';

-- -----------------------------------------------------
-- FUNCIÓN: fn_asignar_habilidades_programa
-- Asigna múltiples habilidades a un programa
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_asignar_habilidades_programa(
  p_id_aca_programa INTEGER,
  p_habilidades TEXT[],
  p_user_reg INTEGER
)
  RETURNS TABLE (
                  id_programa_habilidad INTEGER,
                  nombre_habilidad VARCHAR,
                  mensaje TEXT
                ) AS $$
DECLARE
  v_habilidad TEXT;
  v_id_habilidad INTEGER;
  v_existe_programa INTEGER;
  v_duplicado INTEGER;
BEGIN
  -- Validar existencia del programa
  SELECT COUNT(*) INTO v_existe_programa
  FROM aca_programa
  WHERE id_aca_programa = p_id_aca_programa
    AND estado_programa != 'ELIMINADO';

  IF v_existe_programa = 0 THEN
    RAISE EXCEPTION 'Error! El programa no existe';
  END IF;

  -- Procesar cada habilidad
  FOREACH v_habilidad IN ARRAY p_habilidades
    LOOP
      -- Verificar si ya existe
      SELECT COUNT(*) INTO v_duplicado
      FROM aca_programa_habilidad
      WHERE id_aca_programa = p_id_aca_programa
        AND UPPER(TRIM(nombre_habilidad)) = UPPER(TRIM(v_habilidad))
        AND estado_programa_habilidad != 'ELIMINADO';

      IF v_duplicado = 0 THEN
        -- Insertar nueva habilidad
        INSERT INTO aca_programa_habilidad(
          id_aca_programa,
          nombre_habilidad,
          estado_programa_habilidad,
          fecha_reg,
          user_reg
        ) VALUES (
                   p_id_aca_programa,
                   UPPER(TRIM(v_habilidad)),
                   'ACTIVO',
                   CURRENT_TIMESTAMP,
                   p_user_reg
                 ) RETURNING aca_programa_habilidad.id_programa_habilidad INTO v_id_habilidad;

        RETURN QUERY SELECT
                       v_id_habilidad,
                       UPPER(TRIM(v_habilidad))::VARCHAR,
                       'Habilidad creada'::TEXT;
      ELSE
        RETURN QUERY SELECT
                       NULL::INTEGER,
                       UPPER(TRIM(v_habilidad))::VARCHAR,
                       'Habilidad ya existe'::TEXT;
      END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_asignar_habilidades_programa IS 'Asigna múltiples habilidades a un programa en una sola operación';


-- =====================================================
-- VISTA: vista_programas_aprobados (ACTUALIZADA)
-- Remover campos de precios deprecados
-- =====================================================
DROP VIEW IF EXISTS vista_programas_aprobados CASCADE;

CREATE VIEW vista_programas_aprobados AS
SELECT
  pa.id_aca_programa_aprobado,
  pa.id_aca_programa,
  pa.id_aca_modalidad,
  pa.id_aca_plan_estudio,
  pa.id_aca_version,
  p.id_aca_area,
  p.nombre_programa AS programa_nombre,
  p.sigla AS programa_sigla,
  a.nombre_area AS area_nombre,
  m.nombre_modalidad AS modalidad_nombre,
  pe.anho AS plan_anho,
  CASE
    WHEN pe.vigente = true THEN CONCAT(pe.anho, ' (VIGENTE)')
    ELSE pe.anho::VARCHAR
    END AS plan_descripcion,
  v.cod_version,
  pa.gestion,
  pa.estado_programa_aprobado,
  pa.cod_certificado_ceub,
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

COMMENT ON VIEW vista_programas_aprobados IS 'Vista de programas aprobados sin precios (usar sistema de aranceles)';

-- =====================================================
-- FIN DE MIGRACIÓN
-- =====================================================
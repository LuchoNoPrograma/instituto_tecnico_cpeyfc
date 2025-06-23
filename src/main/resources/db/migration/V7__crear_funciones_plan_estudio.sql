-- V7__crear_funciones_plan_estudio.sql
-- Descripción: Funciones de negocio y vistas para gestión de planes de estudio
-- Autor: Luis Alberto Morales Villaca
-- Fecha: 21/06/2025
-- Estimaciones: 1 módulo, 3 funciones, 11 vistas

-- =====================================================
-- ÍNDICE DEL ARCHIVO
-- =====================================================
-- 1. MÓDULO ACADÉMICO - ACA_PLAN_ESTUDIO
--    1.1 Función registro de plan de estudio
--    1.2 Función modificación de plan de estudio
--    1.3 Función consulta programas por plan
-- 2. VISTAS PRINCIPALES PARA GESTIÓN
--    2.1 Vista planes de estudio activos
--    2.2 Vista planes con información de uso
--    2.3 Vista plan estudio con contexto
-- 3. VISTAS PARA APIs Y DETALLE
--    3.1 Vista plan estudio detalle
--    3.2 Vista programas asociados a plan
--    3.3 Vista módulos del plan con detalle
--    3.4 Vista niveles activos
--    3.5 Vista módulos activos
-- 4. VISTAS ESTADÍSTICAS Y AUXILIARES
--    4.1 Vista plan estudio estadísticas
--    4.2 Vista módulos disponibles por nivel
-- 5. VERIFICACIONES POST-EJECUCIÓN

/*==============================================================*/
/* MÓDULO ACADÉMICO - ACA_PLAN_ESTUDIO                         */
/* Funciones: gestión de planes de estudio                     */
/* Validaciones: año válido, uso en programas, campos obligatorios */
/*==============================================================*/

-- Función: Registro de plan de estudio con validaciones
-- Propósito: Centralizar creación de planes sin restricción de vigencia
-- Validaciones: año válido, campos obligatorios
CREATE OR REPLACE FUNCTION fn_registrar_aca_plan_estudio(
  p_anho INTEGER,
  p_vigente BOOLEAN,
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_plan_registrado INTEGER;
  v_anho_actual INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_anho IS NULL OR p_vigente IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos (año, vigente, usuario) son obligatorios';
  END IF;

  -- Obtener año actual para validaciones
  SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO v_anho_actual;

  -- Validar rango de año válido
  IF p_anho < 2000 OR p_anho > (v_anho_actual + 5) THEN
    RAISE EXCEPTION 'Error! El año debe estar entre 2000 y %', (v_anho_actual + 5);
  END IF;

  -- Inserción del nuevo plan de estudio
  INSERT INTO aca_plan_estudio(anho, vigente, estado_plan_estudio, fecha_reg, user_reg)
  VALUES (p_anho, p_vigente, 'ACTIVO', NOW(), p_user_reg)
  RETURNING id_aca_plan_estudio INTO v_id_plan_registrado;

  RETURN CONCAT('Plan de estudio registrado exitosamente con ID: ', v_id_plan_registrado);
END;
$$;

-- Función: Modificación de plan de estudio existente
-- Propósito: Actualizar planes con validación de uso en programas
-- Validaciones: existencia, uso en programas aprobados, estados válidos
CREATE OR REPLACE FUNCTION fn_modificar_aca_plan_estudio(
  p_id_aca_plan_estudio INTEGER,
  p_anho INTEGER,
  p_vigente BOOLEAN,
  p_estado_plan_estudio VARCHAR(35),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_plan_existe INTEGER;
  v_programas_usando INTEGER;
  v_anho_actual INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_plan_estudio IS NULL OR p_anho IS NULL OR
     p_vigente IS NULL OR p_estado_plan_estudio IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos son obligatorios';
  END IF;

  -- Validar existencia del plan
  SELECT COUNT(*)
  INTO v_plan_existe
  FROM aca_plan_estudio
  WHERE id_aca_plan_estudio = p_id_aca_plan_estudio;

  IF (v_plan_existe = 0) THEN
    RAISE EXCEPTION 'Error! El plan de estudio con ID % no existe', p_id_aca_plan_estudio;
  END IF;

  -- Obtener año actual para validaciones
  SELECT EXTRACT(YEAR FROM CURRENT_DATE) INTO v_anho_actual;

  -- Validar rango de año válido
  IF p_anho < 2000 OR p_anho > (v_anho_actual + 5) THEN
    RAISE EXCEPTION 'Error! El año debe estar entre 2000 y %', (v_anho_actual + 5);
  END IF;

  -- Validar estados permitidos
  IF p_estado_plan_estudio NOT IN ('ACTIVO', 'ELIMINADO') THEN
    RAISE EXCEPTION 'Error! El estado debe ser "ACTIVO", o "ELIMINADO"';
  END IF;

  -- Si se intenta eliminar, verificar que no esté en uso
  IF p_estado_plan_estudio = 'ELIMINADO' THEN
    SELECT COUNT(*)
    INTO v_programas_usando
    FROM aca_programa_aprobado
    WHERE id_aca_plan_estudio = p_id_aca_plan_estudio
      AND estado_programa_aprobado = 'ACTIVO';

    IF (v_programas_usando > 0) THEN
      RAISE EXCEPTION 'Error! No se puede eliminar el plan porque está siendo usado por % programa(s) aprobado(s)', v_programas_usando;
    END IF;
  END IF;

  -- Actualización del plan de estudio
  UPDATE aca_plan_estudio
  SET anho = p_anho,
      vigente = p_vigente,
      estado_plan_estudio = UPPER(TRIM(p_estado_plan_estudio)),
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_aca_plan_estudio = p_id_aca_plan_estudio;

  RETURN CONCAT('Plan de estudio con ID ', p_id_aca_plan_estudio, ' modificado exitosamente');
END;
$$;

-- Función: Consultar programas que usan un plan específico
-- Propósito: Verificar uso de planes antes de eliminar o modificar
-- Retorna: Lista de programas aprobados que usan el plan
CREATE OR REPLACE FUNCTION fn_consultar_programas_por_plan(
  p_id_aca_plan_estudio INTEGER
) RETURNS TABLE(
                 programa_nombre VARCHAR(100),
                 gestion INTEGER,
                 modalidad_nombre VARCHAR(50),
                 version_codigo VARCHAR(10),
                 estado_programa VARCHAR(35)
               ) LANGUAGE plpgsql
AS $$
BEGIN
  -- Validar que el plan existe
  IF NOT EXISTS (SELECT 1 FROM aca_plan_estudio WHERE id_aca_plan_estudio = p_id_aca_plan_estudio) THEN
    RAISE EXCEPTION 'Error! El plan de estudio con ID % no existe', p_id_aca_plan_estudio;
  END IF;

  -- Retornar programas que usan el plan
  RETURN QUERY
    SELECT
      p.nombre_programa,
      pa.gestion,
      m.nombre_modalidad,
      v.cod_version,
      pa.estado_programa_aprobado
    FROM aca_plan_estudio pe
           JOIN aca_programa_aprobado pa ON pe.id_aca_plan_estudio = pa.id_aca_plan_estudio
           JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
           JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
           JOIN aca_version v ON pa.id_aca_version = v.id_aca_version
    WHERE pe.id_aca_plan_estudio = p_id_aca_plan_estudio
      AND pa.estado_programa_aprobado != 'ELIMINADO'
    ORDER BY pa.gestion DESC, p.nombre_programa;
END;
$$;

/*==============================================================*/
/* VISTAS PRINCIPALES PARA GESTIÓN                             */
/* Uso: Formularios principales y listados administrativos     */
/*==============================================================*/

-- Vista: Planes de estudio activos para formularios de selección
-- Uso: Dropdowns en programas aprobados y gestión académica
CREATE OR REPLACE VIEW vista_aca_planes_estudio_activos AS
SELECT
  id_aca_plan_estudio,
  anho,
  vigente,
  estado_plan_estudio,
  CASE
    WHEN vigente = true THEN CONCAT(anho, ' (VIGENTE)')
    ELSE anho::VARCHAR
    END as anho_display
FROM aca_plan_estudio
WHERE estado_plan_estudio != 'ELIMINADO'
ORDER BY anho DESC, vigente DESC;

-- Vista: Planes de estudio con información de uso
-- Uso: Reportes y consultas administrativas sobre uso de planes
CREATE OR REPLACE VIEW vista_planes_estudio_con_uso AS
SELECT
  pe.id_aca_plan_estudio,
  pe.anho,
  pe.vigente,
  pe.estado_plan_estudio,
  COUNT(pa.id_aca_programa_aprobado) as programas_usando,
  COUNT(CASE WHEN pa.estado_programa_aprobado = 'ACTIVO' THEN 1 END) as programas_activos,
  STRING_AGG(
      DISTINCT p.nombre_programa,
      ', '
      ORDER BY p.nombre_programa
  ) as programas_nombres
FROM aca_plan_estudio pe
       LEFT JOIN aca_programa_aprobado pa ON pe.id_aca_plan_estudio = pa.id_aca_plan_estudio
  AND pa.estado_programa_aprobado != 'ELIMINADO'
       LEFT JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
WHERE pe.estado_plan_estudio != 'ELIMINADO'
GROUP BY pe.id_aca_plan_estudio, pe.anho, pe.vigente, pe.estado_plan_estudio
ORDER BY pe.anho DESC, pe.vigente DESC;

-- Vista: Planes de estudio con contexto de programas
-- Uso: Formulario de registro de programas aprobados con información contextual
CREATE OR REPLACE VIEW vista_plan_estudio_con_contexto AS
SELECT DISTINCT
  pe.id_aca_plan_estudio,
  pe.anho,
  pe.vigente,
  STRING_AGG(DISTINCT p.nombre_programa, ', ') as programas_usando,
  CONCAT('Plan ', pe.anho,
         CASE WHEN pe.vigente THEN ' (Vigente)' ELSE '' END,
         ' - Usado por: ', STRING_AGG(DISTINCT p.nombre_programa, ', ')
  ) as descripcion_plan
FROM aca_plan_estudio pe
       LEFT JOIN aca_programa_aprobado pa ON pe.id_aca_plan_estudio = pa.id_aca_plan_estudio
       LEFT JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
WHERE pe.estado_plan_estudio = 'ACTIVO'
GROUP BY pe.id_aca_plan_estudio, pe.anho, pe.vigente
ORDER BY pe.vigente DESC, pe.anho DESC;

/*==============================================================*/
/* VISTAS PARA APIs Y DETALLE                                  */
/* Uso: Endpoints específicos y consultas detalladas           */
/*==============================================================*/

-- Vista: Datos básicos del plan de estudio
-- API: /api/plan-estudio/{id}
CREATE OR REPLACE VIEW vista_plan_estudio_detalle AS
SELECT
  pe.id_aca_plan_estudio,
  pe.anho,
  pe.vigente,
  pe.estado_plan_estudio,
  pe.fecha_reg,
  pe.fecha_mod,
  pe.user_reg,
  pe.user_mod
FROM aca_plan_estudio pe
WHERE pe.estado_plan_estudio = 'ACTIVO';

-- Vista: Programas que usan este plan de estudio
-- API: /api/plan-estudio/{id}/programas-asociados
CREATE OR REPLACE VIEW vista_programas_asociados_plan AS
SELECT
  pa.id_aca_plan_estudio,
  pa.id_aca_programa_aprobado,
  p.id_aca_programa,
  p.nombre_programa AS programa_nombre,
  p.sigla AS programa_sigla,
  a.nombre_area AS area_nombre,
  m.nombre_modalidad AS modalidad_nombre,
  pa.gestion,
  pa.estado_programa_aprobado,
  pa.fecha_reg
FROM aca_programa_aprobado pa
       INNER JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       INNER JOIN aca_area a ON p.id_aca_area = a.id_aca_area
       INNER JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
WHERE pa.id_aca_plan_estudio IS NOT NULL
  AND pa.estado_programa_aprobado != 'ELIMINADO'
  AND p.estado_programa = 'ACTIVO'
  AND a.estado_area = 'ACTIVO'
  AND m.estado_modalidad = 'ACTIVO';

-- Vista: Módulos del plan con todos los detalles
-- API: /api/plan-estudio/{id}/modulos-detalle
CREATE OR REPLACE VIEW vista_modulos_plan_detalle AS
SELECT
  pmd.id_aca_plan_modulo_detalle,
  pmd.id_aca_plan_estudio,
  pmd.id_aca_nivel,
  pmd.id_aca_modulo,
  pmd.carga_horaria,
  pmd.creditos,
  pmd.orden,
  pmd.sigla,
  pmd.competencia,
  pmd.estado_plan_modulo_detalle,
  -- Datos del módulo
  mod.nombre_modulo,
  mod.estado_modulo,
  -- Datos del nivel
  niv.nombre_nivel,
  niv.estado_nivel,
  -- Datos del plan
  pe.anho AS plan_anho,
  pe.vigente AS plan_vigente
FROM aca_plan_modulo_detalle pmd
       INNER JOIN aca_modulo mod ON pmd.id_aca_modulo = mod.id_aca_modulo
       INNER JOIN aca_nivel niv ON pmd.id_aca_nivel = niv.id_aca_nivel
       INNER JOIN aca_plan_estudio pe ON pmd.id_aca_plan_estudio = pe.id_aca_plan_estudio
WHERE pmd.estado_plan_modulo_detalle = 'ACTIVO'
  AND mod.estado_modulo = 'ACTIVO'
  AND niv.estado_nivel = 'ACTIVO'
  AND pe.estado_plan_estudio = 'ACTIVO';

-- Vista: Niveles académicos activos
-- API: /api/nivel/vista/niveles-activos
CREATE OR REPLACE VIEW vista_niveles_activos AS
SELECT
  id_aca_nivel,
  nombre_nivel,
  estado_nivel
FROM aca_nivel
WHERE estado_nivel = 'ACTIVO'
ORDER BY nombre_nivel;

-- Vista: Módulos disponibles para agregar al plan
-- API: /api/modulo/vista/modulos-activos
CREATE OR REPLACE VIEW vista_modulos_activos AS
SELECT
  id_aca_modulo,
  nombre_modulo,
  estado_modulo
FROM aca_modulo
WHERE estado_modulo = 'ACTIVO'
ORDER BY nombre_modulo;

/*==============================================================*/
/* VISTAS ESTADÍSTICAS Y AUXILIARES                            */
/* Uso: Reportes estadísticos y formularios auxiliares         */
/*==============================================================*/

-- Vista: Resumen estadístico del plan
-- Uso: Dashboard y estadísticas rápidas de planes
CREATE OR REPLACE VIEW vista_plan_estudio_estadisticas AS
SELECT
  pe.id_aca_plan_estudio,
  pe.anho,
  pe.vigente,
  COUNT(DISTINCT pmd.id_aca_plan_modulo_detalle) AS total_modulos,
  SUM(pmd.carga_horaria) AS total_horas,
  SUM(pmd.creditos) AS total_creditos,
  COUNT(DISTINCT pmd.id_aca_nivel) AS niveles_con_modulos,
  COUNT(DISTINCT pa.id_aca_programa_aprobado) AS programas_asociados
FROM aca_plan_estudio pe
       LEFT JOIN aca_plan_modulo_detalle pmd ON pe.id_aca_plan_estudio = pmd.id_aca_plan_estudio
  AND pmd.estado_plan_modulo_detalle = 'ACTIVO'
       LEFT JOIN aca_programa_aprobado pa ON pe.id_aca_plan_estudio = pa.id_aca_plan_estudio
  AND pa.estado_programa_aprobado != 'ELIMINADO'
WHERE pe.estado_plan_estudio = 'ACTIVO'
GROUP BY pe.id_aca_plan_estudio, pe.anho, pe.vigente;

-- Vista: Módulos disponibles por nivel
-- Uso: Formulario de agregar módulos con filtro por nivel
CREATE OR REPLACE VIEW vista_modulos_disponibles_nivel AS
SELECT DISTINCT
  mod.id_aca_modulo,
  mod.nombre_modulo,
  niv.id_aca_nivel,
  niv.nombre_nivel
FROM aca_modulo mod
       CROSS JOIN aca_nivel niv
WHERE mod.estado_modulo = 'ACTIVO'
  AND niv.estado_nivel = 'ACTIVO'
ORDER BY niv.nombre_nivel, mod.nombre_modulo;

/*==============================================================*/
/* VERIFICACIONES POST-EJECUCIÓN                               */
/*==============================================================*/

-- Verificar creación exitosa de funciones para plan de estudio
-- SELECT COUNT(*) as funciones_plan_estudio FROM information_schema.routines
-- WHERE routine_name LIKE '%plan_estudio%' AND routine_schema = current_schema();

-- Verificar creación exitosa de vistas para plan de estudio
-- SELECT COUNT(*) as vistas_plan_estudio FROM information_schema.views
-- WHERE table_name LIKE '%plan%estudio%' AND table_schema = current_schema();

-- Verificar estructura de vista con uso
-- SELECT * FROM vista_planes_estudio_con_uso LIMIT 5;

-- Vista para módulos activos
CREATE VIEW vista_aca_modulos_activos
      (id_aca_modulo, nombre_modulo, estado_modulo) AS
SELECT m.id_aca_modulo,
       m.nombre_modulo,
       m.estado_modulo
FROM aca_modulo m
WHERE m.estado_modulo = 'ACTIVO'
ORDER BY m.nombre_modulo;

-- Función para registrar módulo
CREATE FUNCTION fn_registrar_aca_modulo(
  p_nombre_modulo VARCHAR(100),
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_modulo_registrado INTEGER;
  v_existen INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_nombre_modulo IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos nombre de módulo y usuario son obligatorios';
  END IF;

  -- Validar duplicados por nombre en registros activos
  SELECT COUNT(*)
  INTO v_existen
  FROM aca_modulo
  WHERE nombre_modulo = UPPER(TRIM(p_nombre_modulo))
    AND estado_modulo = 'ACTIVO';

  IF (v_existen > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe un módulo registrado con este nombre';
  END IF;

  -- Inserción con normalización de texto
  INSERT INTO aca_modulo(nombre_modulo, estado_modulo, fecha_reg, user_reg)
  VALUES (UPPER(TRIM(p_nombre_modulo)), 'ACTIVO', NOW(), p_user_reg)
  RETURNING id_aca_modulo INTO v_id_modulo_registrado;

  RETURN CONCAT('Módulo registrado exitosamente con ID: ', v_id_modulo_registrado);
END;
$$;

-- Función para modificar módulo
CREATE FUNCTION fn_modificar_aca_modulo(
  p_id_aca_modulo INTEGER,
  p_nombre_modulo VARCHAR(100),
  p_estado_modulo VARCHAR(35),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_modulo_existe INTEGER;
  v_existen_nombre INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_modulo IS NULL OR p_nombre_modulo IS NULL OR
     p_estado_modulo IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos son obligatorios';
  END IF;

  -- Validar existencia del módulo activo
  SELECT COUNT(*)
  INTO v_modulo_existe
  FROM aca_modulo
  WHERE id_aca_modulo = p_id_aca_modulo
    AND estado_modulo = 'ACTIVO';

  IF (v_modulo_existe = 0) THEN
    RAISE EXCEPTION 'Error! El módulo no existe o no está activo';
  END IF;

  -- Validar duplicados por nombre (excluyendo registro actual)
  SELECT COUNT(*)
  INTO v_existen_nombre
  FROM aca_modulo
  WHERE nombre_modulo = UPPER(TRIM(p_nombre_modulo))
    AND estado_modulo = 'ACTIVO'
    AND id_aca_modulo != p_id_aca_modulo;

  IF (v_existen_nombre > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe otro módulo registrado con este nombre';
  END IF;

  -- Actualización con normalización de texto
  UPDATE aca_modulo
  SET nombre_modulo = UPPER(TRIM(p_nombre_modulo)),
      estado_modulo = UPPER(TRIM(p_estado_modulo)),
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_aca_modulo = p_id_aca_modulo
    AND estado_modulo = 'ACTIVO';

  RETURN CONCAT('Módulo modificado exitosamente con ID: ', p_id_aca_modulo);
END;
$$;


CREATE OR REPLACE FUNCTION fn_registrar_plan_modulo_detalle(
  p_id_aca_plan_estudio INTEGER,
  p_id_aca_modulo INTEGER,
  p_id_aca_nivel INTEGER,
  p_carga_horaria INTEGER,
  p_creditos DECIMAL(6,2),
  p_orden INTEGER,
  p_competencia TEXT,
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_plan_modulo_detalle INTEGER;
  v_sigla_calculada CHAR(10);
  v_nombre_modulo VARCHAR(100);
  v_existe_plan INTEGER;
  v_existe_modulo INTEGER;
  v_existe_nivel INTEGER;
  v_existe_duplicado INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_aca_plan_estudio IS NULL OR p_id_aca_modulo IS NULL OR
     p_id_aca_nivel IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos son obligatorios';
  END IF;

  -- Validar plan de estudio activo
  SELECT COUNT(*)
  INTO v_existe_plan
  FROM aca_plan_estudio
  WHERE id_aca_plan_estudio = p_id_aca_plan_estudio
    AND estado_plan_estudio = 'ACTIVO';

  IF v_existe_plan = 0 THEN
    RAISE EXCEPTION 'Error! El plan de estudio no existe o no está activo';
  END IF;

  -- Validar módulo activo y obtener nombre
  SELECT COUNT(*), MAX(nombre_modulo)
  INTO v_existe_modulo, v_nombre_modulo
  FROM aca_modulo
  WHERE id_aca_modulo = p_id_aca_modulo
    AND estado_modulo = 'ACTIVO';

  IF v_existe_modulo = 0 THEN
    RAISE EXCEPTION 'Error! El módulo no existe o no está activo';
  END IF;

  -- Validar nivel activo
  SELECT COUNT(*)
  INTO v_existe_nivel
  FROM aca_nivel
  WHERE id_aca_nivel = p_id_aca_nivel
    AND estado_nivel = 'ACTIVO';

  IF v_existe_nivel = 0 THEN
    RAISE EXCEPTION 'Error! El nivel no existe o no está activo';
  END IF;

  -- Validar valores
  IF p_carga_horaria < 0 OR p_creditos < 0 OR p_orden < 1 THEN
    RAISE EXCEPTION 'Error! Valores inválidos: horas >= 0, créditos >= 0, orden >= 1';
  END IF;

  -- Verificar duplicado módulo+plan
  SELECT COUNT(*)
  INTO v_existe_duplicado
  FROM aca_plan_modulo_detalle
  WHERE id_aca_plan_estudio = p_id_aca_plan_estudio
    AND id_aca_modulo = p_id_aca_modulo
    AND estado_plan_modulo_detalle = 'ACTIVO';

  IF v_existe_duplicado > 0 THEN
    RAISE EXCEPTION 'Error! El módulo ya está registrado en este plan';
  END IF;

  -- Calcular sigla: primeras 3 letras del módulo + orden
  v_sigla_calculada := UPPER(LEFT(REGEXP_REPLACE(v_nombre_modulo, '[^A-Za-z]', '', 'g'), 3)) || LPAD(p_orden::TEXT, 3, '0');

  -- Insertar registro
  INSERT INTO aca_plan_modulo_detalle(
    id_aca_nivel, id_aca_plan_estudio, id_aca_modulo,
    carga_horaria, creditos, orden, sigla, competencia,
    estado_plan_modulo_detalle, fecha_reg, user_reg
  ) VALUES (
             p_id_aca_nivel, p_id_aca_plan_estudio, p_id_aca_modulo,
             p_carga_horaria, p_creditos, p_orden, v_sigla_calculada, p_competencia,
             'ACTIVO', NOW(), p_user_reg
           ) RETURNING id_aca_plan_modulo_detalle INTO v_id_plan_modulo_detalle;

  RETURN CONCAT('Módulo agregado al plan exitosamente con ID: ', v_id_plan_modulo_detalle, ', Sigla: ', v_sigla_calculada);
END;
$$;


-- Función para modificar plan módulo detalle
CREATE OR REPLACE FUNCTION fn_modificar_plan_modulo_detalle(
  p_id_aca_plan_modulo_detalle INTEGER,
  p_id_aca_plan_estudio INTEGER,
  p_id_aca_modulo INTEGER,
  p_id_aca_nivel INTEGER,
  p_carga_horaria INTEGER,
  p_creditos DECIMAL(6,2),
  p_orden INTEGER,
  p_competencia TEXT,
  p_estado_plan_modulo_detalle VARCHAR(35),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_sigla_calculada CHAR(10);
  v_nombre_modulo VARCHAR(100);
  v_existe_detalle INTEGER;
  v_existe_plan INTEGER;
  v_existe_modulo INTEGER;
  v_existe_nivel INTEGER;
  v_existe_duplicado INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_aca_plan_modulo_detalle IS NULL OR p_id_aca_plan_estudio IS NULL OR
     p_id_aca_modulo IS NULL OR p_id_aca_nivel IS NULL OR
     p_estado_plan_modulo_detalle IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos son obligatorios';
  END IF;

  -- Validar existencia del detalle
  SELECT COUNT(*)
  INTO v_existe_detalle
  FROM aca_plan_modulo_detalle
  WHERE id_aca_plan_modulo_detalle = p_id_aca_plan_modulo_detalle;

  IF v_existe_detalle = 0 THEN
    RAISE EXCEPTION 'Error! El detalle del plan módulo no existe';
  END IF;

  -- Validar plan de estudio activo
  SELECT COUNT(*)
  INTO v_existe_plan
  FROM aca_plan_estudio
  WHERE id_aca_plan_estudio = p_id_aca_plan_estudio
    AND estado_plan_estudio = 'ACTIVO';

  IF v_existe_plan = 0 THEN
    RAISE EXCEPTION 'Error! El plan de estudio no existe o no está activo';
  END IF;

  -- Validar módulo activo y obtener nombre
  SELECT COUNT(*), MAX(nombre_modulo)
  INTO v_existe_modulo, v_nombre_modulo
  FROM aca_modulo
  WHERE id_aca_modulo = p_id_aca_modulo
    AND estado_modulo = 'ACTIVO';

  IF v_existe_modulo = 0 THEN
    RAISE EXCEPTION 'Error! El módulo no existe o no está activo';
  END IF;

  -- Validar nivel activo
  SELECT COUNT(*)
  INTO v_existe_nivel
  FROM aca_nivel
  WHERE id_aca_nivel = p_id_aca_nivel
    AND estado_nivel = 'ACTIVO';

  IF v_existe_nivel = 0 THEN
    RAISE EXCEPTION 'Error! El nivel no existe o no está activo';
  END IF;

  -- Validar valores
  IF p_carga_horaria < 0 OR p_creditos < 0 OR p_orden < 1 THEN
    RAISE EXCEPTION 'Error! Valores inválidos: horas >= 0, créditos >= 0, orden >= 1';
  END IF;

  -- Validar estados permitidos
  IF p_estado_plan_modulo_detalle NOT IN ('ACTIVO', 'INACTIVO', 'ELIMINADO') THEN
    RAISE EXCEPTION 'Error! El estado debe ser "ACTIVO", "INACTIVO" o "ELIMINADO"';
  END IF;

  -- Verificar duplicado módulo+plan (excluyendo registro actual)
  SELECT COUNT(*)
  INTO v_existe_duplicado
  FROM aca_plan_modulo_detalle
  WHERE id_aca_plan_estudio = p_id_aca_plan_estudio
    AND id_aca_modulo = p_id_aca_modulo
    AND estado_plan_modulo_detalle = 'ACTIVO'
    AND id_aca_plan_modulo_detalle != p_id_aca_plan_modulo_detalle;

  IF v_existe_duplicado > 0 THEN
    RAISE EXCEPTION 'Error! El módulo ya está registrado en este plan';
  END IF;

  -- Calcular sigla: primeras 3 letras del módulo + orden
  v_sigla_calculada := UPPER(LEFT(REGEXP_REPLACE(v_nombre_modulo, '[^A-Za-z]', '', 'g'), 3)) || LPAD(p_orden::TEXT, 3, '0');

  -- Actualizar registro
  UPDATE aca_plan_modulo_detalle
  SET id_aca_plan_estudio = p_id_aca_plan_estudio,
      id_aca_modulo = p_id_aca_modulo,
      id_aca_nivel = p_id_aca_nivel,
      carga_horaria = p_carga_horaria,
      creditos = p_creditos,
      orden = p_orden,
      sigla = v_sigla_calculada,
      competencia = p_competencia,
      estado_plan_modulo_detalle = UPPER(TRIM(p_estado_plan_modulo_detalle)),
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_aca_plan_modulo_detalle = p_id_aca_plan_modulo_detalle;

  RETURN CONCAT('Detalle del plan modificado exitosamente con ID: ', p_id_aca_plan_modulo_detalle, ', Sigla: ', v_sigla_calculada);
END;
$$;


-- Función para consultar módulos de un plan específico
CREATE OR REPLACE FUNCTION fn_consultar_modulos_por_plan(
  p_id_aca_plan_estudio INTEGER
) RETURNS TABLE(
                                                                         id_aca_plan_modulo_detalle INTEGER,
                                                                         id_aca_plan_estudio INTEGER,
                                                                         id_aca_modulo INTEGER,
                                                                         id_aca_nivel INTEGER,
                 plan_anho INTEGER,
                 modulo_nombre VARCHAR(100),
                 nivel_nombre VARCHAR(100),
                 carga_horaria INTEGER,
                 creditos DECIMAL(6,2),
                 orden INTEGER,
                 sigla CHAR(10),
                 competencia TEXT,
                 estado VARCHAR(35)
               ) LANGUAGE plpgsql
AS $$
BEGIN
  -- Validar que el plan existe
  IF NOT EXISTS (SELECT 1 FROM aca_plan_estudio pe WHERE pe.id_aca_plan_estudio = p_id_aca_plan_estudio) THEN
    RAISE EXCEPTION 'Error! El plan de estudio con ID % no existe', p_id_aca_plan_estudio;
  END IF;

  -- Retornar módulos del plan
  RETURN QUERY
    SELECT
      pmd.id_aca_plan_modulo_detalle,
      pe.id_aca_plan_estudio,
      m.id_aca_modulo,
      n.id_aca_nivel,
      pe.anho,
      m.nombre_modulo,
      n.nombre_nivel,
      pmd.carga_horaria,
      pmd.creditos,
      pmd.orden,
      pmd.sigla,
      pmd.competencia,
      pmd.estado_plan_modulo_detalle
    FROM aca_plan_modulo_detalle pmd
           JOIN aca_modulo m ON pmd.id_aca_modulo = m.id_aca_modulo
           JOIN aca_nivel n ON pmd.id_aca_nivel = n.id_aca_nivel
          JOIN aca_plan_estudio pe ON pmd.id_aca_plan_estudio = pe.id_aca_plan_estudio
    WHERE pmd.id_aca_plan_estudio = p_id_aca_plan_estudio
      AND pmd.estado_plan_modulo_detalle != 'ELIMINADO'
    ORDER BY pmd.orden, m.nombre_modulo;
END;
$$;
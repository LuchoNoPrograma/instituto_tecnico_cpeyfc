-- V5__crear_funciones_preinscripcion.sql
-- Descripción: Funciones y vistas para gestión de preinscripciones
-- Autor: Luis Alberto Morales Villaca
-- Fecha: dd/MM/yyyy

/*==============================================================*/
/* ÍNDICE DEL ARCHIVO                                          */
/*==============================================================*/
-- 1. Vistas para consulta de datos
-- 2. Función para buscar persona por CI
-- 3. Función para actualizar datos de contacto
-- 4. Función para gestionar persona en preinscripción
-- 5. Función principal para registrar preinscripción

/*==============================================================*/
/* 1. VISTAS PARA CONSULTA DE DATOS                            */
/*==============================================================*/

-- Vista: Personas activas con información completa para formularios
CREATE OR REPLACE VIEW vista_personas_formulario AS
SELECT
  p.id_prs_persona,
  p.nombre,
  p.ap_paterno,
  p.ap_materno,
  p.ci,
  p.nro_celular,
  p.correo,
  p.fecha_nacimiento,
  p.estado_persona,
  CONCAT(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, '')) as nombre_completo,
  DATE_PART('year', AGE(p.fecha_nacimiento)) as edad
FROM prs_persona p
WHERE p.estado_persona = 'ACTIVO';

-- Vista: Programas disponibles para preinscripción
CREATE OR REPLACE VIEW vista_programas_preinscripcion AS
SELECT
  pa.id_aca_programa_aprobado,
  p.nombre_programa,
  a.nombre_area,
  m.nombre_modalidad,
  pa.gestion,
  pa.estado_programa_aprobado
FROM aca_programa_aprobado pa
       INNER JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       INNER JOIN aca_area a ON p.id_aca_area = a.id_aca_area
       INNER JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
WHERE pa.estado_programa_aprobado = 'ACTIVO'
  AND p.estado_programa = 'ACTIVO'
  AND a.estado_area = 'ACTIVO'
  AND m.estado_modalidad = 'ACTIVO';

/*==============================================================*/
/* 2. FUNCIÓN PARA BUSCAR PERSONA POR CI                       */
/*==============================================================*/

CREATE OR REPLACE FUNCTION fn_buscar_persona_por_ci(
  p_ci VARCHAR(20)
) RETURNS TABLE(
                 id_prs_persona INTEGER,
                 nombre VARCHAR(35),
                 ap_paterno VARCHAR(55),
                 ap_materno VARCHAR(55),
                 ci VARCHAR(20),
                 nro_celular VARCHAR(20),
                 correo VARCHAR(55),
                 fecha_nacimiento DATE,
                 nombre_completo TEXT,
                 edad NUMERIC
               )
  LANGUAGE plpgsql
AS $$
BEGIN
  IF p_ci IS NULL OR TRIM(p_ci) = '' THEN
    RAISE EXCEPTION 'Error! El CI es requerido para la búsqueda';
  END IF;

  RETURN QUERY
    SELECT *
    FROM vista_personas_formulario
    WHERE vista_personas_formulario.ci = UPPER(TRIM(p_ci))
    LIMIT 1;
END;
$$;

/*==============================================================*/
/* 3. FUNCIÓN PARA ACTUALIZAR DATOS DE CONTACTO               */
/*==============================================================*/

CREATE OR REPLACE FUNCTION fn_actualizar_contacto_persona(
  p_id_persona INTEGER,
  p_nro_celular VARCHAR(20),
  p_correo VARCHAR(55),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_existe INTEGER;
BEGIN
  IF p_id_persona IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! ID de persona y usuario son requeridos';
  END IF;

  SELECT COUNT(*)
  INTO v_existe
  FROM prs_persona
  WHERE id_prs_persona = p_id_persona
    AND estado_persona = 'ACTIVO';

  IF v_existe = 0 THEN
    RAISE EXCEPTION 'Error! No se encontró persona activa con ID: %', p_id_persona;
  END IF;

  UPDATE prs_persona
  SET
    nro_celular = COALESCE(TRIM(p_nro_celular), nro_celular),
    correo = COALESCE(TRIM(p_correo), correo),
    fecha_mod = NOW(),
    user_mod = p_user_mod
  WHERE id_prs_persona = p_id_persona;

  RETURN 'Contacto actualizado para persona ID: ' || p_id_persona;
END;
$$;

/*==============================================================*/
/* 4. FUNCIÓN PARA GESTIONAR PERSONA EN PREINSCRIPCIÓN        */
/*==============================================================*/

CREATE OR REPLACE FUNCTION fn_gestionar_persona_preinscripcion(
  p_nombre VARCHAR(35),
  p_ap_paterno VARCHAR(55),
  p_ap_materno VARCHAR(55),
  p_ci VARCHAR(20),
  p_nro_celular VARCHAR(20),
  p_correo VARCHAR(55),
  p_fecha_nacimiento DATE,
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_persona INTEGER;
  v_existe INTEGER;
  v_mensaje TEXT;
BEGIN
  -- Validaciones básicas
  IF p_nombre IS NULL OR TRIM(p_nombre) = ''
    OR p_ap_paterno IS NULL OR TRIM(p_ap_paterno) = ''
    OR p_ci IS NULL OR TRIM(p_ci) = ''
    OR p_nro_celular IS NULL OR TRIM(p_nro_celular) = ''
    OR p_correo IS NULL OR TRIM(p_correo) = ''
    OR p_fecha_nacimiento IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios incompletos';
  END IF;

  -- Verificar si existe persona con este CI
  SELECT COUNT(*), MAX(id_prs_persona)
  INTO v_existe, v_id_persona
  FROM prs_persona
  WHERE ci = UPPER(TRIM(p_ci))
    AND estado_persona = 'ACTIVO';

  IF v_existe > 0 THEN
    -- Persona existe: actualizar contacto usando la función específica
    SELECT fn_actualizar_contacto_persona(
                   v_id_persona,
                   p_nro_celular,
                   p_correo,
                   p_user_reg
           ) INTO v_mensaje;

    RETURN 'Persona encontrada ID: ' || v_id_persona || ' - ' || v_mensaje;
  ELSE
    -- Persona no existe: usar función existente fn_registrar_persona
    SELECT fn_registrar_persona(
                   p_nombre,
                   p_ap_paterno,
                   p_ap_materno,
                   p_ci,
                   p_nro_celular,
                   p_correo,
                   p_fecha_nacimiento,
                   p_user_reg
           ) INTO v_mensaje;

    -- Extraer ID de la respuesta de fn_registrar_persona
    SELECT id_prs_persona INTO v_id_persona
    FROM prs_persona
    WHERE ci = UPPER(TRIM(p_ci))
      AND estado_persona = 'ACTIVO';

    RETURN 'Persona nueva ID: ' || v_id_persona || ' - ' || v_mensaje;
  END IF;
END;
$$;

/*==============================================================*/
/* 5. FUNCIÓN PRINCIPAL PARA REGISTRAR PREINSCRIPCIÓN          */
/*==============================================================*/

CREATE OR REPLACE FUNCTION fn_registrar_preinscripcion(
  -- Datos de la persona
  p_nombre VARCHAR(35),
  p_ap_paterno VARCHAR(55),
  p_ap_materno VARCHAR(55),
  p_ci VARCHAR(20),
  p_nro_celular VARCHAR(20),
  p_correo VARCHAR(55),
  p_fecha_nacimiento DATE,
  -- Datos de la preinscripción
  p_id_aca_programa_aprobado INTEGER,
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_mensaje_persona TEXT;
  v_id_persona INTEGER;
  v_existe_programa INTEGER;
  v_existe_preinscripcion INTEGER;
  v_id_preinscripcion INTEGER;
BEGIN
  -- Validar programa activo
  SELECT COUNT(*)
  INTO v_existe_programa
  FROM vista_programas_preinscripcion
  WHERE id_aca_programa_aprobado = p_id_aca_programa_aprobado;

  IF v_existe_programa = 0 THEN
    RAISE EXCEPTION 'Error! Programa no disponible ID: %', p_id_aca_programa_aprobado;
  END IF;

  -- Gestionar persona (registrar nueva o actualizar contacto)
  SELECT fn_gestionar_persona_preinscripcion(
                 p_nombre, p_ap_paterno, p_ap_materno, p_ci,
                 p_nro_celular, p_correo, p_fecha_nacimiento, p_user_reg
         ) INTO v_mensaje_persona;

  -- Extraer ID de persona de la respuesta
  SELECT id_prs_persona INTO v_id_persona
  FROM prs_persona
  WHERE ci = UPPER(TRIM(p_ci))
    AND estado_persona = 'ACTIVO';

  -- Verificar preinscripción duplicada
  SELECT COUNT(*)
  INTO v_existe_preinscripcion
  FROM ins_preinscripcion
  WHERE id_prs_persona = v_id_persona
    AND id_aca_programa_aprobado = p_id_aca_programa_aprobado
    AND estado_preinscripcion = 'ACTIVO';

  IF v_existe_preinscripcion > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe preinscripción activa para persona ID: % en programa ID: %',
      v_id_persona, p_id_aca_programa_aprobado;
  END IF;

  -- Registrar preinscripción
  INSERT INTO ins_preinscripcion(
    id_aca_programa_aprobado,
    id_prs_persona,
    estado_preinscripcion,
    fecha_reg,
    user_reg
  )
  VALUES (
           p_id_aca_programa_aprobado,
           v_id_persona,
           'ACTIVO',
           NOW(),
           p_user_reg
         )
  RETURNING id_ins_preinscripcion INTO v_id_preinscripcion;

  RETURN 'Preinscripción registrada ID: ' || v_id_preinscripcion ||
         ' para persona ID: ' || v_id_persona ||
         ' - ' || v_mensaje_persona;

EXCEPTION
  WHEN OTHERS THEN
    RAISE LOG 'Error en fn_registrar_preinscripcion: %', SQLERRM;
    RAISE;
END;
$$;
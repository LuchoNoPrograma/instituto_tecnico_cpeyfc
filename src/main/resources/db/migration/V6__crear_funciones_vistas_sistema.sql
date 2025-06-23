-- V6__crear_funciones_vistas_sistema.sql
-- Descripción: Funciones de negocio y vistas para módulos principales del sistema
-- Autor: Luis Alberto Morales Villaca
-- Fecha: 21/06/2025
-- Estimaciones: 8 módulos, 16 funciones, 8 vistas

-- =====================================================
-- ÍNDICE DEL ARCHIVO
-- =====================================================
-- 1. MÓDULO ACADÉMICO - ACA_NIVEL
--    1.1 Función registro de nivel académico
--    1.2 Función modificación de nivel académico
--    1.3 Vista niveles activos
-- 2. MÓDULO ACADÉMICO - ACA_AREA
--    2.1 Función registro de área académica
--    2.2 Función modificación de área académica
--    2.3 Vista áreas activas
-- 3. MÓDULO ACADÉMICO - ACA_MODALIDAD
--    3.1 Función registro de modalidad
--    3.2 Función modificación de modalidad
--    3.3 Vista modalidades activas
-- 4. MÓDULO ACADÉMICO - ACA_VERSION
--    4.1 Función registro de versión CEUB
--    4.2 Función modificación de versión CEUB
--    4.3 Vista versiones activas
-- 5. MÓDULO ACADÉMICO - ACA_PROGRAMA
--    5.1 Función registro de programa académico
--    5.2 Función modificación de programa académico
--    5.3 Vista programas activos
-- 6. MÓDULO FINANCIERO - FIN_CONCEPTO_PAGO
--    6.1 Función registro de concepto de pago
--    6.2 Función modificación de concepto de pago
--    6.3 Vista conceptos de pago activos
-- 7. MÓDULO SEGURIDAD - SEG_ROL
--    7.1 Función registro de rol de seguridad
--    7.2 Función modificación de rol de seguridad
--    7.3 Vista roles activos
-- 8. MÓDULO SEGURIDAD - SEG_TAREA
--    8.1 Función registro de tarea de seguridad
--    8.2 Función modificación de tarea de seguridad
--    8.3 Vista tareas activas
-- 9. VERIFICACIONES POST-EJECUCIÓN

/*==============================================================*/
/* MÓDULO ACADÉMICO - ACA_NIVEL                                */
/* Funciones: registro y modificación                          */
/* Vista: niveles activos para formularios                     */
/*==============================================================*/

-- Función: Registro de nivel académico con validaciones
-- Propósito: Centralizar lógica de negocio para nuevos niveles
-- Validaciones: campos obligatorios, duplicados por nombre
CREATE OR REPLACE FUNCTION fn_registrar_aca_nivel(
  p_nombre_nivel VARCHAR(100),
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_nivel_registrado INTEGER;
  v_existen INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_nombre_nivel IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos deben ser completados';
  END IF;

  -- Validar duplicados por nombre en registros activos
  SELECT COUNT(*)
  INTO v_existen
  FROM aca_nivel
  WHERE nombre_nivel = UPPER(TRIM(p_nombre_nivel))
    AND estado_nivel = 'ACTIVO';

  IF (v_existen > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe un nivel registrado con este nombre';
  END IF;

  -- Inserción con normalización de texto
  INSERT INTO aca_nivel(nombre_nivel, estado_nivel, fecha_reg, user_reg)
  VALUES (UPPER(TRIM(p_nombre_nivel)), 'ACTIVO', NOW(), p_user_reg)
  RETURNING id_aca_nivel INTO v_id_nivel_registrado;

  RETURN CONCAT('Nivel académico registrado exitosamente con ID: ', v_id_nivel_registrado);
END;
$$;

-- Función: Modificación de nivel académico existente
-- Propósito: Actualizar datos con validaciones de integridad
-- Validaciones: existencia, duplicados, campos obligatorios
CREATE OR REPLACE FUNCTION fn_modificar_aca_nivel(
  p_id_aca_nivel INTEGER,
  p_nombre_nivel VARCHAR(100),
  p_estado_nivel VARCHAR(35),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_nivel_existe INTEGER;
  v_existen_nombre INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_nivel IS NULL OR p_nombre_nivel IS NULL OR
     p_estado_nivel IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos deben ser completados';
  END IF;

  -- Validar existencia del nivel activo
  SELECT COUNT(*)
  INTO v_nivel_existe
  FROM aca_nivel
  WHERE id_aca_nivel = p_id_aca_nivel
    AND estado_nivel = 'ACTIVO';

  IF (v_nivel_existe = 0) THEN
    RAISE EXCEPTION 'Error! El nivel académico no existe o no está activo';
  END IF;

  -- Validar duplicados por nombre (excluyendo registro actual)
  SELECT COUNT(*)
  INTO v_existen_nombre
  FROM aca_nivel
  WHERE nombre_nivel = UPPER(TRIM(p_nombre_nivel))
    AND estado_nivel = 'ACTIVO'
    AND id_aca_nivel != p_id_aca_nivel;

  IF (v_existen_nombre > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe otro nivel académico registrado con este nombre';
  END IF;

  -- Actualización con normalización de texto
  UPDATE aca_nivel
  SET nombre_nivel = UPPER(TRIM(p_nombre_nivel)),
      estado_nivel = UPPER(TRIM(p_estado_nivel)),
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_aca_nivel = p_id_aca_nivel
    AND estado_nivel = 'ACTIVO';

  RETURN CONCAT('Nivel académico modificado exitosamente con ID: ', p_id_aca_nivel);
END;
$$;

-- Vista: Niveles académicos activos para formularios de selección
-- Uso: Dropdowns y reportes que requieren solo datos esenciales
CREATE OR REPLACE VIEW vista_aca_niveles_activos AS
SELECT id_aca_nivel, nombre_nivel, estado_nivel
FROM aca_nivel
WHERE estado_nivel != 'ELIMINADO';

/*==============================================================*/
/* MÓDULO ACADÉMICO - ACA_AREA                                 */
/* Funciones: registro y modificación de áreas                 */
/* Vista: áreas activas para clasificación de programas        */
/*==============================================================*/

-- Función: Registro de área académica con validaciones
-- Propósito: Centralizar lógica para nuevas áreas de conocimiento
-- Validaciones: campos obligatorios, duplicados por nombre
CREATE OR REPLACE FUNCTION fn_registrar_area(
  p_nombre_area VARCHAR(100),
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_aca_area_registrada INTEGER;
  v_existe_area INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_nombre_area IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos obligatorios (nombre_area, user_reg) deben ser completados.';
  END IF;

  -- Normalización del nombre del área
  p_nombre_area := UPPER(TRIM(p_nombre_area));

  -- Validar duplicados por nombre en registros activos
  SELECT COUNT(*)
  INTO v_existe_area
  FROM aca_area
  WHERE nombre_area = p_nombre_area
    AND estado_area = 'ACTIVO';

  IF (v_existe_area > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe un área activa registrada con este nombre: %', p_nombre_area;
  END IF;

  -- Inserción de nueva área con estado inicial ACTIVO
  INSERT INTO aca_area(nombre_area, estado_area, fecha_reg, user_reg)
  VALUES (p_nombre_area, 'ACTIVO', NOW(), p_user_reg)
  RETURNING id_aca_area INTO v_id_aca_area_registrada;

  RETURN CONCAT('Área registrada exitosamente con ID: ', v_id_aca_area_registrada);
END;
$$;

-- Función: Modificación de área académica existente
-- Propósito: Actualizar datos con control de estados permitidos
-- Validaciones: existencia, duplicados, estados válidos
CREATE OR REPLACE FUNCTION fn_modificar_area(
  p_id_aca_area INTEGER,
  p_nombre_area VARCHAR(100),
  p_estado_area VARCHAR(35),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_area_existe INTEGER;
  v_existe_nombre_duplicado INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_area IS NULL OR p_nombre_area IS NULL OR
     p_estado_area IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos obligatorios deben ser completados.';
  END IF;

  -- Validar existencia del área
  SELECT COUNT(*)
  INTO v_area_existe
  FROM aca_area
  WHERE id_aca_area = p_id_aca_area;

  IF (v_area_existe = 0) THEN
    RAISE EXCEPTION 'Error! El área con ID % no existe.', p_id_aca_area;
  END IF;

  -- Normalización de datos
  p_nombre_area := UPPER(TRIM(p_nombre_area));
  p_estado_area := UPPER(TRIM(p_estado_area));

  -- Validar estados permitidos
  IF p_estado_area NOT IN ('ACTIVO', 'INACTIVO', 'ELIMINADO') THEN
    RAISE EXCEPTION 'Error! El estado del área debe ser "ACTIVO", "INACTIVO" o "ELIMINADO".';
  END IF;

  -- Validar duplicados por nombre (excluyendo registro actual)
  SELECT COUNT(*)
  INTO v_existe_nombre_duplicado
  FROM aca_area
  WHERE nombre_area = p_nombre_area
    AND estado_area = 'ACTIVO'
    AND id_aca_area != p_id_aca_area;

  IF (v_existe_nombre_duplicado > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe otra área activa con el mismo nombre: %', p_nombre_area;
  END IF;

  -- Actualización de datos del área
  UPDATE aca_area
  SET nombre_area = p_nombre_area,
      estado_area = p_estado_area,
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_aca_area = p_id_aca_area;

  RETURN CONCAT('Área con ID ', p_id_aca_area, ' modificada exitosamente.');
END;
$$;

-- Vista: Áreas activas para clasificación de programas académicos
-- Uso: Formularios de programas y reportes por área de conocimiento
CREATE OR REPLACE VIEW vista_areas_activas AS
SELECT id_aca_area, nombre_area, estado_area, user_reg, user_mod
FROM aca_area
WHERE estado_area != 'ELIMINADO';

/*==============================================================*/
/* MÓDULO ACADÉMICO - ACA_MODALIDAD                            */
/* Funciones: gestión de modalidades de estudio                */
/* Vista: modalidades para configuración de programas          */
/*==============================================================*/

-- Función: Registro de modalidad académica
-- Propósito: Centralizar creación de modalidades (presencial, virtual, etc.)
-- Validaciones: campos obligatorios, duplicados por nombre
CREATE OR REPLACE FUNCTION fn_registrar_modalidad(
  p_nombre_modalidad VARCHAR(50),
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_aca_modalidad_registrada INTEGER;
  v_existe_modalidad INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_nombre_modalidad IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos obligatorios deben ser completados.';
  END IF;

  -- Normalización del nombre de modalidad
  p_nombre_modalidad := UPPER(TRIM(p_nombre_modalidad));

  -- Validar duplicados por nombre en registros activos
  SELECT COUNT(*)
  INTO v_existe_modalidad
  FROM aca_modalidad
  WHERE nombre_modalidad = p_nombre_modalidad
    AND estado_modalidad = 'ACTIVO';

  IF (v_existe_modalidad > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe una modalidad activa registrada con este nombre: %', p_nombre_modalidad;
  END IF;

  -- Inserción de nueva modalidad con estado inicial ACTIVO
  INSERT INTO aca_modalidad(nombre_modalidad, estado_modalidad, fecha_reg, user_reg)
  VALUES (p_nombre_modalidad, 'ACTIVO', NOW(), p_user_reg)
  RETURNING id_aca_modalidad INTO v_id_aca_modalidad_registrada;

  RETURN CONCAT('Modalidad registrada exitosamente con ID: ', v_id_aca_modalidad_registrada);
END;
$$;

-- Función: Modificación de modalidad académica existente
-- Propósito: Actualizar modalidades con control de integridad
-- Validaciones: existencia, duplicados, estados válidos
CREATE OR REPLACE FUNCTION fn_modificar_modalidad(
  p_id_aca_modalidad INTEGER,
  p_nombre_modalidad VARCHAR(50),
  p_estado_modalidad VARCHAR(35),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_modalidad_existe INTEGER;
  v_existe_nombre_duplicado INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_modalidad IS NULL OR p_nombre_modalidad IS NULL OR
     p_estado_modalidad IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos obligatorios deben ser completados.';
  END IF;

  -- Validar existencia de la modalidad
  SELECT COUNT(*)
  INTO v_modalidad_existe
  FROM aca_modalidad
  WHERE id_aca_modalidad = p_id_aca_modalidad;

  IF (v_modalidad_existe = 0) THEN
    RAISE EXCEPTION 'Error! La modalidad con ID % no existe.', p_id_aca_modalidad;
  END IF;

  -- Normalización de datos
  p_nombre_modalidad := UPPER(TRIM(p_nombre_modalidad));
  p_estado_modalidad := UPPER(TRIM(p_estado_modalidad));

  -- Validar estados permitidos
  IF p_estado_modalidad NOT IN ('ACTIVO', 'INACTIVO', 'ELIMINADO') THEN
    RAISE EXCEPTION 'Error! El estado de la modalidad debe ser "ACTIVO", "INACTIVO" o "ELIMINADO".';
  END IF;

  -- Validar duplicados por nombre (excluyendo registro actual)
  SELECT COUNT(*)
  INTO v_existe_nombre_duplicado
  FROM aca_modalidad
  WHERE nombre_modalidad = p_nombre_modalidad
    AND estado_modalidad = 'ACTIVO'
    AND id_aca_modalidad != p_id_aca_modalidad;

  IF (v_existe_nombre_duplicado > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe otra modalidad activa con el mismo nombre: %', p_nombre_modalidad;
  END IF;

  -- Actualización de datos de modalidad
  UPDATE aca_modalidad
  SET nombre_modalidad = p_nombre_modalidad,
      estado_modalidad = p_estado_modalidad,
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_aca_modalidad = p_id_aca_modalidad;

  RETURN CONCAT('Modalidad con ID ', p_id_aca_modalidad, ' modificada exitosamente.');
END;
$$;

-- Vista: Modalidades activas para configuración de programas
-- Uso: Formularios de programas aprobados y reportes por modalidad
CREATE OR REPLACE VIEW vista_modalidades_activas AS
SELECT id_aca_modalidad, nombre_modalidad, estado_modalidad, user_reg, user_mod
FROM aca_modalidad
WHERE estado_modalidad != 'ELIMINADO';

/*==============================================================*/
/* MÓDULO ACADÉMICO - ACA_VERSION                              */
/* Funciones: gestión de versiones CEUB                        */
/* Vista: versiones para programas aprobados                   */
/*==============================================================*/

-- Función: Registro de versión CEUB
-- Propósito: Centralizar creación de códigos de versión para certificación
-- Validaciones: campos obligatorios, duplicados por código
CREATE OR REPLACE FUNCTION fn_registrar_aca_version(
  p_cod_version VARCHAR(10),
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_version_registrada INTEGER;
  v_existen INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_cod_version IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos deben ser completados';
  END IF;

  -- Validar duplicados por código en registros activos
  SELECT COUNT(*)
  INTO v_existen
  FROM aca_version
  WHERE cod_version = UPPER(TRIM(p_cod_version))
    AND estado_version = 'ACTIVO';

  IF (v_existen > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe una versión registrada con este código';
  END IF;

  -- Inserción con normalización de código
  INSERT INTO aca_version(cod_version, estado_version, fecha_reg, user_reg)
  VALUES (UPPER(TRIM(p_cod_version)), 'ACTIVO', NOW(), p_user_reg)
  RETURNING id_aca_version INTO v_id_version_registrada;

  RETURN CONCAT('Versión registrada exitosamente con ID: ', v_id_version_registrada);
END;
$$;

-- Función: Modificación de versión CEUB existente
-- Propósito: Actualizar códigos de versión con validaciones
-- Validaciones: existencia, duplicados por código
CREATE OR REPLACE FUNCTION fn_modificar_aca_version(
  p_id_aca_version INTEGER,
  p_cod_version VARCHAR(10),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_version_existe INTEGER;
  v_existen_cod INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_version IS NULL OR p_cod_version IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos deben ser completados';
  END IF;

  -- Validar existencia de la versión activa
  SELECT COUNT(*)
  INTO v_version_existe
  FROM aca_version
  WHERE id_aca_version = p_id_aca_version
    AND estado_version = 'ACTIVO';

  IF (v_version_existe = 0) THEN
    RAISE EXCEPTION 'Error! La versión no existe o no está activa';
  END IF;

  -- Validar duplicados por código (excluyendo registro actual)
  SELECT COUNT(*)
  INTO v_existen_cod
  FROM aca_version
  WHERE cod_version = UPPER(TRIM(p_cod_version))
    AND estado_version = 'ACTIVO'
    AND id_aca_version != p_id_aca_version;

  IF (v_existen_cod > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe otra versión registrada con este código';
  END IF;

  -- Actualización con normalización de código
  UPDATE aca_version
  SET cod_version = UPPER(TRIM(p_cod_version)),
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_aca_version = p_id_aca_version
    AND estado_version = 'ACTIVO';

  RETURN CONCAT('Versión modificada exitosamente con ID: ', p_id_aca_version);
END;
$$;

-- Vista: Versiones CEUB activas para programas aprobados
-- Uso: Formularios de programas aprobados y seguimiento de certificaciones
CREATE OR REPLACE VIEW vista_aca_version_activas AS
SELECT id_aca_version, cod_version, estado_version
FROM aca_version
WHERE estado_version != 'ELIMINADO';

/*==============================================================*/
/* MÓDULO ACADÉMICO - ACA_PROGRAMA                             */
/* Funciones: gestión de programas académicos                  */
/* Vista: programas para creación de grupos y matrículas       */
/*==============================================================*/

-- Función: Registro de programa académico
-- Propósito: Centralizar creación de programas con validación de área
-- Validaciones: campos obligatorios, área existente, duplicados
CREATE OR REPLACE FUNCTION fn_registrar_aca_programa(
  p_id_aca_area INTEGER,
  p_nombre_programa VARCHAR(100),
  p_sigla VARCHAR(15),
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_programa_registrado INTEGER;
  v_existen INTEGER;
  v_area_existe INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_area IS NULL OR p_nombre_programa IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos área, nombre de programa y usuario son obligatorios';
  END IF;

  -- Validar existencia del área activa
  SELECT COUNT(*)
  INTO v_area_existe
  FROM aca_area
  WHERE id_aca_area = p_id_aca_area
    AND estado_area = 'ACTIVO';

  IF (v_area_existe = 0) THEN
    RAISE EXCEPTION 'Error! El área especificada no existe o no está activa';
  END IF;

  -- Validar duplicados por nombre en registros activos
  SELECT COUNT(*)
  INTO v_existen
  FROM aca_programa
  WHERE nombre_programa = UPPER(TRIM(p_nombre_programa))
    AND estado_programa = 'ACTIVO';

  IF (v_existen > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe un programa registrado con este nombre';
  END IF;

  -- Inserción con normalización de texto
  INSERT INTO aca_programa(id_aca_area, nombre_programa, sigla, estado_programa, fecha_reg, user_reg)
  VALUES (p_id_aca_area, UPPER(TRIM(p_nombre_programa)), UPPER(TRIM(p_sigla)), 'ACTIVO', NOW(), p_user_reg)
  RETURNING id_aca_programa INTO v_id_programa_registrado;

  RETURN CONCAT('Programa registrado exitosamente con ID: ', v_id_programa_registrado);
END;
$$;

-- Función: Modificación de programa académico existente
-- Propósito: Actualizar programas con validación de integridad referencial
-- Validaciones: existencia, área válida, duplicados por nombre
CREATE OR REPLACE FUNCTION fn_modificar_aca_programa(
  p_id_aca_programa INTEGER,
  p_id_aca_area INTEGER,
  p_nombre_programa VARCHAR(100),
  p_sigla VARCHAR(15),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_programa_existe INTEGER;
  v_area_existe INTEGER;
  v_existen_nombre INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_programa IS NULL OR p_id_aca_area IS NULL OR
     p_nombre_programa IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos programa, área, nombre y usuario son obligatorios';
  END IF;

  -- Validar existencia del programa activo
  SELECT COUNT(*)
  INTO v_programa_existe
  FROM aca_programa
  WHERE id_aca_programa = p_id_aca_programa
    AND estado_programa = 'ACTIVO';

  IF (v_programa_existe = 0) THEN
    RAISE EXCEPTION 'Error! El programa no existe o no está activo';
  END IF;

  -- Validar existencia del área activa
  SELECT COUNT(*)
  INTO v_area_existe
  FROM aca_area
  WHERE id_aca_area = p_id_aca_area
    AND estado_area = 'ACTIVO';

  IF (v_area_existe = 0) THEN
    RAISE EXCEPTION 'Error! El área especificada no existe o no está activa';
  END IF;

  -- Validar duplicados por nombre (excluyendo registro actual)
  SELECT COUNT(*)
  INTO v_existen_nombre
  FROM aca_programa
  WHERE nombre_programa = UPPER(TRIM(p_nombre_programa))
    AND estado_programa = 'ACTIVO'
    AND id_aca_programa != p_id_aca_programa;

  IF (v_existen_nombre > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe otro programa registrado con este nombre';
  END IF;

  -- Actualización con normalización de texto
  UPDATE aca_programa
  SET id_aca_area = p_id_aca_area,
      nombre_programa = UPPER(TRIM(p_nombre_programa)),
      sigla = UPPER(TRIM(p_sigla)),
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_aca_programa = p_id_aca_programa
    AND estado_programa = 'ACTIVO';

  RETURN CONCAT('Programa modificado exitosamente con ID: ', p_id_aca_programa);
END;
$$;

-- Vista: Programas académicos activos para creación de grupos
-- Uso: Formularios de programas aprobados y gestión de grupos/cohortes
CREATE OR REPLACE VIEW vista_aca_programas_activos AS
SELECT
  p.id_aca_programa,
  p.nombre_programa,
  p.sigla,
  p.estado_programa,
  a.id_aca_area,
  a.nombre_area as area_nombre
FROM aca_programa p
       JOIN aca_area a ON p.id_aca_area = a.id_aca_area
WHERE p.estado_programa = 'ACTIVO'
  AND a.estado_area = 'ACTIVO'
ORDER BY p.nombre_programa;

/*==============================================================*/
/* MÓDULO FINANCIERO - FIN_CONCEPTO_PAGO                       */
/* Funciones: gestión de conceptos de pago                     */
/* Vista: conceptos activos para obligaciones de pago          */
/*==============================================================*/

-- Función: Registro de concepto de pago
-- Propósito: Centralizar creación de conceptos financieros (matrícula, colegiatura, etc.)
-- Validaciones: campos obligatorios, duplicados por nombre
CREATE OR REPLACE FUNCTION fn_registrar_fin_concepto_pago(
  p_nombre_concepto VARCHAR(35),
  p_descripcion TEXT,
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_concepto_registrado INTEGER;
  v_existen INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_nombre_concepto IS NULL OR p_descripcion IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos deben ser completados';
  END IF;

  -- Validar duplicados por nombre en registros activos
  SELECT COUNT(*)
  INTO v_existen
  FROM fin_concepto_pago
  WHERE nombre_concepto = UPPER(TRIM(p_nombre_concepto))
    AND estado_concepto_pago = 'ACTIVO';

  IF (v_existen > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe un concepto de pago registrado con este nombre';
  END IF;

  -- Inserción con normalización de texto
  INSERT INTO fin_concepto_pago(nombre_concepto, descripcion, estado_concepto_pago, fecha_reg, user_reg)
  VALUES (UPPER(TRIM(p_nombre_concepto)), TRIM(p_descripcion), 'ACTIVO', NOW(), p_user_reg)
  RETURNING id_fin_concepto_pago INTO v_id_concepto_registrado;

  RETURN CONCAT('Concepto de pago registrado exitosamente con ID: ', v_id_concepto_registrado);
END;
$$;

-- Función: Modificación de concepto de pago existente
-- Propósito: Actualizar conceptos financieros con control de integridad
-- Validaciones: existencia, duplicados, campos obligatorios
CREATE OR REPLACE FUNCTION fn_modificar_fin_concepto_pago(
  p_id_fin_concepto_pago INTEGER,
  p_nombre_concepto VARCHAR(35),
  p_descripcion TEXT,
  p_estado_concepto_pago VARCHAR(35),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_concepto_existe INTEGER;
  v_existen_nombre INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_fin_concepto_pago IS NULL OR p_nombre_concepto IS NULL OR
     p_descripcion IS NULL OR p_estado_concepto_pago IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos deben ser completados';
  END IF;

  -- Validar existencia del concepto activo
  SELECT COUNT(*)
  INTO v_concepto_existe
  FROM fin_concepto_pago
  WHERE id_fin_concepto_pago = p_id_fin_concepto_pago
    AND estado_concepto_pago = 'ACTIVO';

  IF (v_concepto_existe = 0) THEN
    RAISE EXCEPTION 'Error! El concepto de pago no existe o no está activo';
  END IF;

  -- Validar duplicados por nombre (excluyendo registro actual)
  SELECT COUNT(*)
  INTO v_existen_nombre
  FROM fin_concepto_pago
  WHERE nombre_concepto = UPPER(TRIM(p_nombre_concepto))
    AND estado_concepto_pago = 'ACTIVO'
    AND id_fin_concepto_pago != p_id_fin_concepto_pago;

  IF (v_existen_nombre > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe otro concepto de pago registrado con este nombre';
  END IF;

  -- Actualización con normalización de texto
  UPDATE fin_concepto_pago
  SET nombre_concepto = UPPER(TRIM(p_nombre_concepto)),
      descripcion = TRIM(p_descripcion),
      estado_concepto_pago = UPPER(TRIM(p_estado_concepto_pago)),
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_fin_concepto_pago = p_id_fin_concepto_pago
    AND estado_concepto_pago = 'ACTIVO';

  RETURN CONCAT('Concepto de pago modificado exitosamente con ID: ', p_id_fin_concepto_pago);
END;
$$;

-- Vista: Conceptos de pago activos para obligaciones financieras
-- Uso: Formularios de obligaciones de pago y reportes financieros
CREATE OR REPLACE VIEW vista_fin_conceptos_pago_activos AS
SELECT id_fin_concepto_pago, nombre_concepto, descripcion, estado_concepto_pago
FROM fin_concepto_pago
WHERE estado_concepto_pago != 'ELIMINADO';

/*==============================================================*/
/* MÓDULO SEGURIDAD - SEG_ROL                                  */
/* Funciones: gestión de roles del sistema                     */
/* Vista: roles activos para asignación de permisos            */
/*==============================================================*/

-- Función: Registro de rol de seguridad
-- Propósito: Centralizar creación de roles para control de acceso
-- Validaciones: campos obligatorios, duplicados por nombre
CREATE OR REPLACE FUNCTION fn_registrar_seg_rol(
  p_nombre_rol VARCHAR(50),
  p_descripcion TEXT,
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_rol_registrado INTEGER;
  v_existen INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_nombre_rol IS NULL OR p_descripcion IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos deben ser completados';
  END IF;

  -- Validar duplicados por nombre en registros activos
  SELECT COUNT(*)
  INTO v_existen
  FROM seg_rol
  WHERE nombre_rol = UPPER(TRIM(p_nombre_rol))
    AND estado_rol = 'ACTIVO';

  IF (v_existen > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe un rol registrado con este nombre';
  END IF;

  -- Inserción con normalización de texto
  INSERT INTO seg_rol(nombre_rol, descripcion, estado_rol, fecha_reg, user_reg)
  VALUES (UPPER(TRIM(p_nombre_rol)), TRIM(p_descripcion), 'ACTIVO', NOW(), p_user_reg)
  RETURNING id_seg_rol INTO v_id_rol_registrado;

  RETURN CONCAT('Rol de seguridad registrado exitosamente con ID: ', v_id_rol_registrado);
END;
$$;

-- Función: Modificación de rol de seguridad existente
-- Propósito: Actualizar roles con validaciones de integridad
-- Validaciones: existencia, duplicados, campos obligatorios
CREATE OR REPLACE FUNCTION fn_modificar_seg_rol(
  p_id_seg_rol INTEGER,
  p_nombre_rol VARCHAR(50),
  p_descripcion TEXT,
  p_estado_rol VARCHAR(35),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_rol_existe INTEGER;
  v_existen_nombre INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_seg_rol IS NULL OR p_nombre_rol IS NULL OR
     p_descripcion IS NULL OR p_estado_rol IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los campos deben ser completados';
  END IF;

  -- Validar existencia del rol activo
  SELECT COUNT(*)
  INTO v_rol_existe
  FROM seg_rol
  WHERE id_seg_rol = p_id_seg_rol
    AND estado_rol = 'ACTIVO';

  IF (v_rol_existe = 0) THEN
    RAISE EXCEPTION 'Error! El rol de seguridad no existe o no está activo';
  END IF;

  -- Validar duplicados por nombre (excluyendo registro actual)
  SELECT COUNT(*)
  INTO v_existen_nombre
  FROM seg_rol
  WHERE nombre_rol = UPPER(TRIM(p_nombre_rol))
    AND estado_rol = 'ACTIVO'
    AND id_seg_rol != p_id_seg_rol;

  IF (v_existen_nombre > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe otro rol de seguridad registrado con este nombre';
  END IF;

  -- Actualización con normalización de texto
  UPDATE seg_rol
  SET nombre_rol = UPPER(TRIM(p_nombre_rol)),
      descripcion = TRIM(p_descripcion),
      estado_rol = UPPER(TRIM(p_estado_rol)),
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_seg_rol = p_id_seg_rol
    AND estado_rol = 'ACTIVO';

  RETURN CONCAT('Rol de seguridad modificado exitosamente con ID: ', p_id_seg_rol);
END;
$$;

-- Vista: Roles de seguridad activos para asignación de permisos
-- Uso: Formularios de usuarios y gestión de permisos del sistema
CREATE OR REPLACE VIEW vista_seg_roles_activos AS
SELECT id_seg_rol, nombre_rol, descripcion, estado_rol
FROM seg_rol
WHERE estado_rol != 'ELIMINADO';

/*==============================================================*/
/* MÓDULO SEGURIDAD - SEG_TAREA                                */
/* Funciones: gestión de tareas por rol                        */
/* Vista: tareas activas para asignación granular              */
/*==============================================================*/

-- Función: Registro de tarea de seguridad
-- Propósito: Centralizar creación de tareas específicas por rol
-- Validaciones: campos obligatorios, rol existente, duplicados por rol+nombre
CREATE OR REPLACE FUNCTION fn_registrar_seg_tarea(
  p_id_seg_rol INTEGER,
  p_nombre_tarea VARCHAR(50),
  p_descripcion TEXT,
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_tarea_registrada INTEGER;
  v_existen INTEGER;
  v_rol_existe INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_seg_rol IS NULL OR p_nombre_tarea IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos rol, nombre de tarea y usuario son obligatorios';
  END IF;

  -- Validar existencia del rol activo
  SELECT COUNT(*)
  INTO v_rol_existe
  FROM seg_rol
  WHERE id_seg_rol = p_id_seg_rol
    AND estado_rol = 'ACTIVO';

  IF (v_rol_existe = 0) THEN
    RAISE EXCEPTION 'Error! El rol especificado no existe o no está activo';
  END IF;

  -- Validar duplicados por rol+nombre en registros activos
  SELECT COUNT(*)
  INTO v_existen
  FROM seg_tarea
  WHERE id_seg_rol = p_id_seg_rol
    AND nombre_tarea = UPPER(TRIM(p_nombre_tarea))
    AND estado_tarea = 'ACTIVO';

  IF (v_existen > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe una tarea con este nombre para el rol seleccionado';
  END IF;

  -- Inserción con normalización de texto
  INSERT INTO seg_tarea(id_seg_rol, nombre_tarea, descripcion, estado_tarea, fecha_reg, user_reg)
  VALUES (p_id_seg_rol, UPPER(TRIM(p_nombre_tarea)), TRIM(p_descripcion), 'ACTIVO', NOW(), p_user_reg)
  RETURNING id_seg_tarea INTO v_id_tarea_registrada;

  RETURN CONCAT('Tarea registrada exitosamente con ID: ', v_id_tarea_registrada);
END;
$$;

-- Función: Modificación de tarea de seguridad existente
-- Propósito: Actualizar tareas con validación de integridad referencial
-- Validaciones: existencia, rol válido, duplicados por rol+nombre
CREATE OR REPLACE FUNCTION fn_modificar_seg_tarea(
  p_id_seg_tarea INTEGER,
  p_id_seg_rol INTEGER,
  p_nombre_tarea VARCHAR(50),
  p_descripcion TEXT,
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_tarea_existe INTEGER;
  v_rol_existe INTEGER;
  v_existen_nombre INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_seg_tarea IS NULL OR p_id_seg_rol IS NULL OR
     p_nombre_tarea IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos tarea, rol, nombre y usuario son obligatorios';
  END IF;

  -- Validar existencia de la tarea activa
  SELECT COUNT(*)
  INTO v_tarea_existe
  FROM seg_tarea
  WHERE id_seg_tarea = p_id_seg_tarea
    AND estado_tarea = 'ACTIVO';

  IF (v_tarea_existe = 0) THEN
    RAISE EXCEPTION 'Error! La tarea no existe o no está activa';
  END IF;

  -- Validar existencia del rol activo
  SELECT COUNT(*)
  INTO v_rol_existe
  FROM seg_rol
  WHERE id_seg_rol = p_id_seg_rol
    AND estado_rol = 'ACTIVO';

  IF (v_rol_existe = 0) THEN
    RAISE EXCEPTION 'Error! El rol especificado no existe o no está activo';
  END IF;

  -- Validar duplicados por rol+nombre (excluyendo registro actual)
  SELECT COUNT(*)
  INTO v_existen_nombre
  FROM seg_tarea
  WHERE id_seg_rol = p_id_seg_rol
    AND nombre_tarea = UPPER(TRIM(p_nombre_tarea))
    AND estado_tarea = 'ACTIVO'
    AND id_seg_tarea != p_id_seg_tarea;

  IF (v_existen_nombre > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe otra tarea con este nombre para el rol seleccionado';
  END IF;

  -- Actualización con normalización de texto
  UPDATE seg_tarea
  SET id_seg_rol = p_id_seg_rol,
      nombre_tarea = UPPER(TRIM(p_nombre_tarea)),
      descripcion = TRIM(p_descripcion),
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_seg_tarea = p_id_seg_tarea
    AND estado_tarea = 'ACTIVO';

  RETURN CONCAT('Tarea modificada exitosamente con ID: ', p_id_seg_tarea);
END;
$$;

-- Vista: Tareas activas para asignación granular de permisos
-- Uso: Formularios de asignación de tareas y auditoría de permisos
CREATE OR REPLACE VIEW vista_seg_tarea_activas AS
SELECT id_seg_tarea, id_seg_rol, nombre_tarea, descripcion, estado_tarea
FROM seg_tarea
WHERE estado_tarea != 'ELIMINADO';

/*==============================================================*/
/* VERIFICACIONES POST-EJECUCIÓN                               */
/*==============================================================*/

-- Verificar creación exitosa de funciones
-- SELECT COUNT(*) as funciones_creadas FROM information_schema.routines
-- WHERE routine_name LIKE 'fn_%' AND routine_schema = current_schema();

-- Verificar creación exitosa de vistas
-- SELECT COUNT(*) as vistas_creadas FROM information_schema.views
-- WHERE table_name LIKE 'vista_%' AND table_schema = current_schema();
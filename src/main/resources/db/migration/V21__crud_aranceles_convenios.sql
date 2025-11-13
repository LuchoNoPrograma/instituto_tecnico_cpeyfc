-- =====================================================
-- Migración: Funciones CRUD - Sistema de Aranceles y Convenios
-- Versión: V101
-- Descripción: Operaciones registrar, modificar y eliminar
--              para aranceles y convenios institucionales
-- =====================================================

-- =====================================================
-- FUNCIONES: fin_tipo_beneficiario
-- =====================================================

-- -----------------------------------------------------
-- FUNCIÓN: fn_registrar_tipo_beneficiario
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_registrar_tipo_beneficiario(
  p_nombre_tipo VARCHAR,
  p_descripcion TEXT,
  p_user_reg INTEGER
)
  RETURNS INTEGER AS $$
DECLARE
  v_id_tipo_beneficiario INTEGER;
  v_existe INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_nombre_tipo IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar duplicados por nombre
  SELECT COUNT(*) INTO v_existe
  FROM fin_tipo_beneficiario
  WHERE UPPER(TRIM(nombre_tipo)) = UPPER(TRIM(p_nombre_tipo))
    AND estado_tipo_beneficiario != 'ELIMINADO';

  IF v_existe > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe un tipo de beneficiario con este nombre';
  END IF;

  -- Inserción
  INSERT INTO fin_tipo_beneficiario(
    nombre_tipo,
    descripcion,
    estado_tipo_beneficiario,
    fecha_reg,
    user_reg
  ) VALUES (
             UPPER(TRIM(p_nombre_tipo)),
             TRIM(p_descripcion),
             'ACTIVO',
             CURRENT_TIMESTAMP,
             p_user_reg
           ) RETURNING id_tipo_beneficiario INTO v_id_tipo_beneficiario;

  RETURN v_id_tipo_beneficiario;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_registrar_tipo_beneficiario IS 'Registra un nuevo tipo de beneficiario';

-- -----------------------------------------------------
-- FUNCIÓN: fn_modificar_tipo_beneficiario
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_modificar_tipo_beneficiario(
  p_id_tipo_beneficiario INTEGER,
  p_nombre_tipo VARCHAR,
  p_descripcion TEXT,
  p_estado_tipo_beneficiario VARCHAR,
  p_user_mod INTEGER
)
  RETURNS TEXT AS $$
DECLARE
  v_existe INTEGER;
  v_duplicado INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_tipo_beneficiario IS NULL OR p_nombre_tipo IS NULL OR
     p_estado_tipo_beneficiario IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar existencia
  SELECT COUNT(*) INTO v_existe
  FROM fin_tipo_beneficiario
  WHERE id_tipo_beneficiario = p_id_tipo_beneficiario
    AND estado_tipo_beneficiario != 'ELIMINADO';

  IF v_existe = 0 THEN
    RAISE EXCEPTION 'Error! El tipo de beneficiario no existe';
  END IF;

  -- Validar duplicados (excluyendo actual)
  SELECT COUNT(*) INTO v_duplicado
  FROM fin_tipo_beneficiario
  WHERE UPPER(TRIM(nombre_tipo)) = UPPER(TRIM(p_nombre_tipo))
    AND estado_tipo_beneficiario != 'ELIMINADO'
    AND id_tipo_beneficiario != p_id_tipo_beneficiario;

  IF v_duplicado > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe otro tipo de beneficiario con este nombre';
  END IF;

  -- Actualización
  UPDATE fin_tipo_beneficiario
  SET nombre_tipo = UPPER(TRIM(p_nombre_tipo)),
      descripcion = TRIM(p_descripcion),
      estado_tipo_beneficiario = UPPER(TRIM(p_estado_tipo_beneficiario)),
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_tipo_beneficiario = p_id_tipo_beneficiario;

  RETURN CONCAT('Tipo de beneficiario modificado exitosamente con ID: ', p_id_tipo_beneficiario);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_modificar_tipo_beneficiario IS 'Modifica un tipo de beneficiario existente';

-- -----------------------------------------------------
-- FUNCIÓN: fn_eliminar_tipo_beneficiario
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_eliminar_tipo_beneficiario(
  p_id_tipo_beneficiario INTEGER,
  p_user_mod INTEGER
)
  RETURNS TEXT AS $$
DECLARE
  v_existe INTEGER;
  v_aranceles_asociados INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_tipo_beneficiario IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar existencia
  SELECT COUNT(*) INTO v_existe
  FROM fin_tipo_beneficiario
  WHERE id_tipo_beneficiario = p_id_tipo_beneficiario
    AND estado_tipo_beneficiario != 'ELIMINADO';

  IF v_existe = 0 THEN
    RAISE EXCEPTION 'Error! El tipo de beneficiario no existe';
  END IF;

  -- Validar aranceles asociados activos
  SELECT COUNT(*) INTO v_aranceles_asociados
  FROM fin_arancel
  WHERE id_tipo_beneficiario = p_id_tipo_beneficiario
    AND estado_arancel != 'ELIMINADO';

  IF v_aranceles_asociados > 0 THEN
    RAISE EXCEPTION 'Error! No se puede eliminar el tipo de beneficiario porque tiene % aranceles asociados', v_aranceles_asociados;
  END IF;

  -- Eliminación lógica
  UPDATE fin_tipo_beneficiario
  SET estado_tipo_beneficiario = 'ELIMINADO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_tipo_beneficiario = p_id_tipo_beneficiario;

  RETURN CONCAT('Tipo de beneficiario eliminado exitosamente con ID: ', p_id_tipo_beneficiario);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_eliminar_tipo_beneficiario IS 'Elimina lógicamente un tipo de beneficiario';

-- =====================================================
-- FUNCIONES: fin_arancel
-- =====================================================

-- -----------------------------------------------------
-- FUNCIÓN: fn_registrar_arancel
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_registrar_arancel(
  p_id_fin_concepto_pago INTEGER,
  p_id_aca_programa_aprobado INTEGER,
  p_id_tipo_beneficiario INTEGER,
  p_monto_base NUMERIC,
  p_fecha_inicio_vigencia DATE,
  p_fecha_fin_vigencia DATE,
  p_descripcion TEXT,
  p_user_reg INTEGER
)
  RETURNS INTEGER AS $$
DECLARE
  v_id_arancel INTEGER;
  v_existe_concepto INTEGER;
  v_existe_programa INTEGER;
  v_existe_tipo_benef INTEGER;
  v_duplicado INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_fin_concepto_pago IS NULL OR p_id_tipo_beneficiario IS NULL OR
     p_monto_base IS NULL OR p_fecha_inicio_vigencia IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar monto positivo
  IF p_monto_base <= 0 THEN
    RAISE EXCEPTION 'Error! El monto base debe ser mayor a 0';
  END IF;

  -- Validar fechas
  IF p_fecha_fin_vigencia IS NOT NULL AND p_fecha_fin_vigencia < p_fecha_inicio_vigencia THEN
    RAISE EXCEPTION 'Error! Fecha fin no puede ser anterior a fecha inicio';
  END IF;

  -- Validar existencia de concepto de pago
  SELECT COUNT(*) INTO v_existe_concepto
  FROM fin_concepto_pago
  WHERE id_fin_concepto_pago = p_id_fin_concepto_pago
    AND estado_concepto_pago != 'ELIMINADO';

  IF v_existe_concepto = 0 THEN
    RAISE EXCEPTION 'Error! El concepto de pago no existe';
  END IF;

  -- Validar existencia de tipo de beneficiario
  SELECT COUNT(*) INTO v_existe_tipo_benef
  FROM fin_tipo_beneficiario
  WHERE id_tipo_beneficiario = p_id_tipo_beneficiario
    AND estado_tipo_beneficiario != 'ELIMINADO';

  IF v_existe_tipo_benef = 0 THEN
    RAISE EXCEPTION 'Error! El tipo de beneficiario no existe';
  END IF;

  -- Validar existencia de programa (si no es genérico)
  IF p_id_aca_programa_aprobado IS NOT NULL THEN
    SELECT COUNT(*) INTO v_existe_programa
    FROM aca_programa_aprobado
    WHERE id_aca_programa_aprobado = p_id_aca_programa_aprobado
      AND estado_programa_aprobado != 'ELIMINADO';

    IF v_existe_programa = 0 THEN
      RAISE EXCEPTION 'Error! El programa no existe';
    END IF;
  END IF;

  -- Validar duplicados (mismo concepto+programa+tipo+fecha_inicio)
  SELECT COUNT(*) INTO v_duplicado
  FROM fin_arancel
  WHERE id_fin_concepto_pago = p_id_fin_concepto_pago
    AND (id_aca_programa_aprobado = p_id_aca_programa_aprobado OR
         (id_aca_programa_aprobado IS NULL AND p_id_aca_programa_aprobado IS NULL))
    AND id_tipo_beneficiario = p_id_tipo_beneficiario
    AND fecha_inicio_vigencia = p_fecha_inicio_vigencia
    AND estado_arancel != 'ELIMINADO';

  IF v_duplicado > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe un arancel con esta combinación de concepto, programa, tipo y fecha inicio';
  END IF;

  -- Inserción
  INSERT INTO fin_arancel(
    id_fin_concepto_pago,
    id_aca_programa_aprobado,
    id_tipo_beneficiario,
    monto_base,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    descripcion,
    estado_arancel,
    fecha_reg,
    user_reg
  ) VALUES (
             p_id_fin_concepto_pago,
             p_id_aca_programa_aprobado,
             p_id_tipo_beneficiario,
             p_monto_base,
             p_fecha_inicio_vigencia,
             p_fecha_fin_vigencia,
             TRIM(p_descripcion),
             'ACTIVO',
             CURRENT_TIMESTAMP,
             p_user_reg
           ) RETURNING id_arancel INTO v_id_arancel;

  RETURN v_id_arancel;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_registrar_arancel IS 'Registra un nuevo arancel para concepto+programa+tipo de beneficiario';

-- -----------------------------------------------------
-- FUNCIÓN: fn_modificar_arancel
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_modificar_arancel(
  p_id_arancel INTEGER,
  p_monto_base NUMERIC,
  p_fecha_inicio_vigencia DATE,
  p_fecha_fin_vigencia DATE,
  p_descripcion TEXT,
  p_estado_arancel VARCHAR,
  p_user_mod INTEGER
)
  RETURNS TEXT AS $$
DECLARE
  v_existe INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_arancel IS NULL OR p_monto_base IS NULL OR
     p_fecha_inicio_vigencia IS NULL OR p_estado_arancel IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar monto positivo
  IF p_monto_base <= 0 THEN
    RAISE EXCEPTION 'Error! El monto base debe ser mayor a 0';
  END IF;

  -- Validar fechas
  IF p_fecha_fin_vigencia IS NOT NULL AND p_fecha_fin_vigencia < p_fecha_inicio_vigencia THEN
    RAISE EXCEPTION 'Error! Fecha fin no puede ser anterior a fecha inicio';
  END IF;

  -- Validar existencia
  SELECT COUNT(*) INTO v_existe
  FROM fin_arancel
  WHERE id_arancel = p_id_arancel
    AND estado_arancel != 'ELIMINADO';

  IF v_existe = 0 THEN
    RAISE EXCEPTION 'Error! El arancel no existe';
  END IF;

  -- Actualización
  UPDATE fin_arancel
  SET monto_base = p_monto_base,
      fecha_inicio_vigencia = p_fecha_inicio_vigencia,
      fecha_fin_vigencia = p_fecha_fin_vigencia,
      descripcion = TRIM(p_descripcion),
      estado_arancel = UPPER(TRIM(p_estado_arancel)),
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_arancel = p_id_arancel;

  RETURN CONCAT('Arancel modificado exitosamente con ID: ', p_id_arancel);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_modificar_arancel IS 'Modifica un arancel existente';

-- -----------------------------------------------------
-- FUNCIÓN: fn_eliminar_arancel
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_eliminar_arancel(
  p_id_arancel INTEGER,
  p_user_mod INTEGER
)
  RETURNS TEXT AS $$
DECLARE
  v_existe INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_arancel IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar existencia
  SELECT COUNT(*) INTO v_existe
  FROM fin_arancel
  WHERE id_arancel = p_id_arancel
    AND estado_arancel != 'ELIMINADO';

  IF v_existe = 0 THEN
    RAISE EXCEPTION 'Error! El arancel no existe';
  END IF;

  -- Eliminación lógica
  UPDATE fin_arancel
  SET estado_arancel = 'ELIMINADO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_arancel = p_id_arancel;

  RETURN CONCAT('Arancel eliminado exitosamente con ID: ', p_id_arancel);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_eliminar_arancel IS 'Elimina lógicamente un arancel';

-- =====================================================
-- FUNCIONES: fin_convenio_institucional
-- =====================================================

-- -----------------------------------------------------
-- FUNCIÓN: fn_registrar_convenio_institucional
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_registrar_convenio_institucional(
  p_nombre_institucion VARCHAR,
  p_tipo_institucion VARCHAR,
  p_nit VARCHAR,
  p_contacto_nombre VARCHAR,
  p_contacto_telefono VARCHAR,
  p_contacto_email VARCHAR,
  p_fecha_inicio_convenio DATE,
  p_fecha_fin_convenio DATE,
  p_observaciones TEXT,
  p_user_reg INTEGER
)
  RETURNS INTEGER AS $$
DECLARE
  v_id_convenio INTEGER;
  v_duplicado INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_nombre_institucion IS NULL OR p_tipo_institucion IS NULL OR
     p_fecha_inicio_convenio IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar fechas
  IF p_fecha_fin_convenio IS NOT NULL AND p_fecha_fin_convenio < p_fecha_inicio_convenio THEN
    RAISE EXCEPTION 'Error! Fecha fin no puede ser anterior a fecha inicio';
  END IF;

  -- Validar duplicados por nombre
  SELECT COUNT(*) INTO v_duplicado
  FROM fin_convenio_institucional
  WHERE UPPER(TRIM(nombre_institucion)) = UPPER(TRIM(p_nombre_institucion))
    AND estado_convenio != 'ELIMINADO';

  IF v_duplicado > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe un convenio con esta institución';
  END IF;

  -- Inserción
  INSERT INTO fin_convenio_institucional(
    nombre_institucion,
    tipo_institucion,
    nit,
    contacto_nombre,
    contacto_telefono,
    contacto_email,
    fecha_inicio_convenio,
    fecha_fin_convenio,
    observaciones,
    estado_convenio,
    fecha_reg,
    user_reg
  ) VALUES (
             UPPER(TRIM(p_nombre_institucion)),
             UPPER(TRIM(p_tipo_institucion)),
             TRIM(p_nit),
             TRIM(p_contacto_nombre),
             TRIM(p_contacto_telefono),
             LOWER(TRIM(p_contacto_email)),
             p_fecha_inicio_convenio,
             p_fecha_fin_convenio,
             TRIM(p_observaciones),
             'ACTIVO',
             CURRENT_TIMESTAMP,
             p_user_reg
           ) RETURNING id_convenio INTO v_id_convenio;

  RETURN v_id_convenio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_registrar_convenio_institucional IS 'Registra un nuevo convenio institucional';

-- -----------------------------------------------------
-- FUNCIÓN: fn_modificar_convenio_institucional
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_modificar_convenio_institucional(
  p_id_convenio INTEGER,
  p_nombre_institucion VARCHAR,
  p_tipo_institucion VARCHAR,
  p_nit VARCHAR,
  p_contacto_nombre VARCHAR,
  p_contacto_telefono VARCHAR,
  p_contacto_email VARCHAR,
  p_fecha_inicio_convenio DATE,
  p_fecha_fin_convenio DATE,
  p_observaciones TEXT,
  p_estado_convenio VARCHAR,
  p_user_mod INTEGER
)
  RETURNS TEXT AS $$
DECLARE
  v_existe INTEGER;
  v_duplicado INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_convenio IS NULL OR p_nombre_institucion IS NULL OR
     p_tipo_institucion IS NULL OR p_fecha_inicio_convenio IS NULL OR
     p_estado_convenio IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar fechas
  IF p_fecha_fin_convenio IS NOT NULL AND p_fecha_fin_convenio < p_fecha_inicio_convenio THEN
    RAISE EXCEPTION 'Error! Fecha fin no puede ser anterior a fecha inicio';
  END IF;

  -- Validar existencia
  SELECT COUNT(*) INTO v_existe
  FROM fin_convenio_institucional
  WHERE id_convenio = p_id_convenio
    AND estado_convenio != 'ELIMINADO';

  IF v_existe = 0 THEN
    RAISE EXCEPTION 'Error! El convenio no existe';
  END IF;

  -- Validar duplicados (excluyendo actual)
  SELECT COUNT(*) INTO v_duplicado
  FROM fin_convenio_institucional
  WHERE UPPER(TRIM(nombre_institucion)) = UPPER(TRIM(p_nombre_institucion))
    AND estado_convenio != 'ELIMINADO'
    AND id_convenio != p_id_convenio;

  IF v_duplicado > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe otro convenio con esta institución';
  END IF;

  -- Actualización
  UPDATE fin_convenio_institucional
  SET nombre_institucion = UPPER(TRIM(p_nombre_institucion)),
      tipo_institucion = UPPER(TRIM(p_tipo_institucion)),
      nit = TRIM(p_nit),
      contacto_nombre = TRIM(p_contacto_nombre),
      contacto_telefono = TRIM(p_contacto_telefono),
      contacto_email = LOWER(TRIM(p_contacto_email)),
      fecha_inicio_convenio = p_fecha_inicio_convenio,
      fecha_fin_convenio = p_fecha_fin_convenio,
      observaciones = TRIM(p_observaciones),
      estado_convenio = UPPER(TRIM(p_estado_convenio)),
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_convenio = p_id_convenio;

  RETURN CONCAT('Convenio modificado exitosamente con ID: ', p_id_convenio);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_modificar_convenio_institucional IS 'Modifica un convenio institucional existente';

-- -----------------------------------------------------
-- FUNCIÓN: fn_eliminar_convenio_institucional
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_eliminar_convenio_institucional(
  p_id_convenio INTEGER,
  p_user_mod INTEGER
)
  RETURNS TEXT AS $$
DECLARE
  v_existe INTEGER;
  v_descuentos_asociados INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_convenio IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar existencia
  SELECT COUNT(*) INTO v_existe
  FROM fin_convenio_institucional
  WHERE id_convenio = p_id_convenio
    AND estado_convenio != 'ELIMINADO';

  IF v_existe = 0 THEN
    RAISE EXCEPTION 'Error! El convenio no existe';
  END IF;

  -- Validar descuentos asociados activos
  SELECT COUNT(*) INTO v_descuentos_asociados
  FROM fin_descuento_convenio
  WHERE id_convenio = p_id_convenio
    AND estado_descuento_convenio != 'ELIMINADO';

  IF v_descuentos_asociados > 0 THEN
    RAISE EXCEPTION 'Error! No se puede eliminar el convenio porque tiene % descuentos asociados', v_descuentos_asociados;
  END IF;

  -- Eliminación lógica
  UPDATE fin_convenio_institucional
  SET estado_convenio = 'ELIMINADO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_convenio = p_id_convenio;

  RETURN CONCAT('Convenio eliminado exitosamente con ID: ', p_id_convenio);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_eliminar_convenio_institucional IS 'Elimina lógicamente un convenio institucional';

-- =====================================================
-- FUNCIONES: fin_descuento_convenio
-- =====================================================

-- -----------------------------------------------------
-- FUNCIÓN: fn_registrar_descuento_convenio
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_registrar_descuento_convenio(
  p_id_convenio INTEGER,
  p_id_aca_programa_aprobado INTEGER,
  p_id_fin_concepto_pago INTEGER,
  p_tipo_descuento VARCHAR,
  p_valor_descuento NUMERIC,
  p_fecha_inicio_vigencia DATE,
  p_fecha_fin_vigencia DATE,
  p_descripcion TEXT,
  p_user_reg INTEGER
)
  RETURNS INTEGER AS $$
DECLARE
  v_id_descuento_convenio INTEGER;
  v_existe_convenio INTEGER;
  v_existe_programa INTEGER;
  v_existe_concepto INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_convenio IS NULL OR p_tipo_descuento IS NULL OR
     p_valor_descuento IS NULL OR p_fecha_inicio_vigencia IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar tipo de descuento
  IF UPPER(TRIM(p_tipo_descuento)) NOT IN ('PORCENTUAL', 'FIJO') THEN
    RAISE EXCEPTION 'Error! Tipo de descuento debe ser PORCENTUAL o FIJO';
  END IF;

  -- Validar valor descuento
  IF p_valor_descuento <= 0 THEN
    RAISE EXCEPTION 'Error! El valor del descuento debe ser mayor a 0';
  END IF;

  -- Validar porcentaje
  IF UPPER(TRIM(p_tipo_descuento)) = 'PORCENTUAL' AND p_valor_descuento > 100 THEN
    RAISE EXCEPTION 'Error! El porcentaje de descuento no puede ser mayor a 100';
  END IF;

  -- Validar fechas
  IF p_fecha_fin_vigencia IS NOT NULL AND p_fecha_fin_vigencia < p_fecha_inicio_vigencia THEN
    RAISE EXCEPTION 'Error! Fecha fin no puede ser anterior a fecha inicio';
  END IF;

  -- Validar existencia de convenio
  SELECT COUNT(*) INTO v_existe_convenio
  FROM fin_convenio_institucional
  WHERE id_convenio = p_id_convenio
    AND estado_convenio != 'ELIMINADO';

  IF v_existe_convenio = 0 THEN
    RAISE EXCEPTION 'Error! El convenio no existe';
  END IF;

  -- Validar existencia de programa (si no es genérico)
  IF p_id_aca_programa_aprobado IS NOT NULL THEN
    SELECT COUNT(*) INTO v_existe_programa
    FROM aca_programa_aprobado
    WHERE id_aca_programa_aprobado = p_id_aca_programa_aprobado
      AND estado_programa_aprobado != 'ELIMINADO';

    IF v_existe_programa = 0 THEN
      RAISE EXCEPTION 'Error! El programa no existe';
    END IF;
  END IF;

  -- Validar existencia de concepto (si no es genérico)
  IF p_id_fin_concepto_pago IS NOT NULL THEN
    SELECT COUNT(*) INTO v_existe_concepto
    FROM fin_concepto_pago
    WHERE id_fin_concepto_pago = p_id_fin_concepto_pago
      AND estado_concepto_pago != 'ELIMINADO';

    IF v_existe_concepto = 0 THEN
      RAISE EXCEPTION 'Error! El concepto de pago no existe';
    END IF;
  END IF;

  -- Inserción
  INSERT INTO fin_descuento_convenio(
    id_convenio,
    id_aca_programa_aprobado,
    id_fin_concepto_pago,
    tipo_descuento,
    valor_descuento,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    descripcion,
    estado_descuento_convenio,
    fecha_reg,
    user_reg
  ) VALUES (
             p_id_convenio,
             p_id_aca_programa_aprobado,
             p_id_fin_concepto_pago,
             UPPER(TRIM(p_tipo_descuento)),
             p_valor_descuento,
             p_fecha_inicio_vigencia,
             p_fecha_fin_vigencia,
             TRIM(p_descripcion),
             'ACTIVO',
             CURRENT_TIMESTAMP,
             p_user_reg
           ) RETURNING id_descuento_convenio INTO v_id_descuento_convenio;

  RETURN v_id_descuento_convenio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_registrar_descuento_convenio IS 'Registra un descuento para un convenio institucional';

-- -----------------------------------------------------
-- FUNCIÓN: fn_modificar_descuento_convenio
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_modificar_descuento_convenio(
  p_id_descuento_convenio INTEGER,
  p_tipo_descuento VARCHAR,
  p_valor_descuento NUMERIC,
  p_fecha_inicio_vigencia DATE,
  p_fecha_fin_vigencia DATE,
  p_descripcion TEXT,
  p_estado_descuento_convenio VARCHAR,
  p_user_mod INTEGER
)
  RETURNS TEXT AS $$
DECLARE
  v_existe INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_descuento_convenio IS NULL OR p_tipo_descuento IS NULL OR
     p_valor_descuento IS NULL OR p_fecha_inicio_vigencia IS NULL OR
     p_estado_descuento_convenio IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar tipo de descuento
  IF UPPER(TRIM(p_tipo_descuento)) NOT IN ('PORCENTUAL', 'FIJO') THEN
    RAISE EXCEPTION 'Error! Tipo de descuento debe ser PORCENTUAL o FIJO';
  END IF;

  -- Validar valor descuento
  IF p_valor_descuento <= 0 THEN
    RAISE EXCEPTION 'Error! El valor del descuento debe ser mayor a 0';
  END IF;

  -- Validar porcentaje
  IF UPPER(TRIM(p_tipo_descuento)) = 'PORCENTUAL' AND p_valor_descuento > 100 THEN
    RAISE EXCEPTION 'Error! El porcentaje de descuento no puede ser mayor a 100';
  END IF;

  -- Validar fechas
  IF p_fecha_fin_vigencia IS NOT NULL AND p_fecha_fin_vigencia < p_fecha_inicio_vigencia THEN
    RAISE EXCEPTION 'Error! Fecha fin no puede ser anterior a fecha inicio';
  END IF;

  -- Validar existencia
  SELECT COUNT(*) INTO v_existe
  FROM fin_descuento_convenio
  WHERE id_descuento_convenio = p_id_descuento_convenio
    AND estado_descuento_convenio != 'ELIMINADO';

  IF v_existe = 0 THEN
    RAISE EXCEPTION 'Error! El descuento no existe';
  END IF;

  -- Actualización
  UPDATE fin_descuento_convenio
  SET tipo_descuento = UPPER(TRIM(p_tipo_descuento)),
      valor_descuento = p_valor_descuento,
      fecha_inicio_vigencia = p_fecha_inicio_vigencia,
      fecha_fin_vigencia = p_fecha_fin_vigencia,
      descripcion = TRIM(p_descripcion),
      estado_descuento_convenio = UPPER(TRIM(p_estado_descuento_convenio)),
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_descuento_convenio = p_id_descuento_convenio;

  RETURN CONCAT('Descuento modificado exitosamente con ID: ', p_id_descuento_convenio);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_modificar_descuento_convenio IS 'Modifica un descuento de convenio existente';

-- -----------------------------------------------------
-- FUNCIÓN: fn_eliminar_descuento_convenio
-- -----------------------------------------------------
CREATE OR REPLACE FUNCTION fn_eliminar_descuento_convenio(
  p_id_descuento_convenio INTEGER,
  p_user_mod INTEGER
)
  RETURNS TEXT AS $$
DECLARE
  v_existe INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_descuento_convenio IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar existencia
  SELECT COUNT(*) INTO v_existe
  FROM fin_descuento_convenio
  WHERE id_descuento_convenio = p_id_descuento_convenio
    AND estado_descuento_convenio != 'ELIMINADO';

  IF v_existe = 0 THEN
    RAISE EXCEPTION 'Error! El descuento no existe';
  END IF;

  -- Eliminación lógica
  UPDATE fin_descuento_convenio
  SET estado_descuento_convenio = 'ELIMINADO',
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = p_user_mod
  WHERE id_descuento_convenio = p_id_descuento_convenio;

  RETURN CONCAT('Descuento eliminado exitosamente con ID: ', p_id_descuento_convenio);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_eliminar_descuento_convenio IS 'Elimina lógicamente un descuento de convenio';

-- =====================================================
-- FIN DE MIGRACIÓN
-- =====================================================
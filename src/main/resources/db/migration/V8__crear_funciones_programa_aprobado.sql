CREATE OR REPLACE FUNCTION fn_registrar_programa_aprobado(
  p_id_aca_programa INTEGER,
  p_id_aca_modalidad INTEGER,
  p_gestion INTEGER,
  p_id_aca_plan_estudio INTEGER,
  p_id_aca_version INTEGER,
  p_estado_programa_aprobado VARCHAR(35),
  p_cod_certificado_ceub VARCHAR(55),
  p_precio_matricula DECIMAL(8,2),
  p_precio_colegiatura DECIMAL(8,2),
  p_precio_titulacion DECIMAL(8,2),
  p_fecha_inicio_vigencia DATE,
  p_fecha_fin_vigencia DATE,
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_programa_aprobado INTEGER;
  v_programa_existe INTEGER;
  v_modalidad_existe INTEGER;
  v_plan_existe INTEGER;
  v_version_existe INTEGER;
  v_combinacion_existe INTEGER;
  v_sigla_programa VARCHAR(15);
  v_cod_version VARCHAR(10);
  v_cod_sigla_version VARCHAR(15);
  v_version_numero INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_programa IS NULL OR p_id_aca_modalidad IS NULL OR
     p_gestion IS NULL OR p_user_reg IS NULL OR p_estado_programa_aprobado IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos programa, modalidad, gestión, estado y usuario son obligatorios';
  END IF;

  -- Validar estado válido
  IF p_estado_programa_aprobado NOT IN ('SIN INICIAR', 'EN EJECUCION', 'FINALIZADOS') THEN
    RAISE EXCEPTION 'Error! Estado debe ser: SIN INICIAR, EN EJECUCION o FINALIZADOS';
  END IF;

  -- Validar existencia del programa activo y obtener sigla
  SELECT COUNT(*), MAX(sigla)
  INTO v_programa_existe, v_sigla_programa
  FROM aca_programa
  WHERE id_aca_programa = p_id_aca_programa
    AND estado_programa = 'ACTIVO';

  IF (v_programa_existe = 0) THEN
    RAISE EXCEPTION 'Error! El programa especificado no existe o no está activo';
  END IF;

  -- Validar existencia de modalidad activa
  SELECT COUNT(*)
  INTO v_modalidad_existe
  FROM aca_modalidad
  WHERE id_aca_modalidad = p_id_aca_modalidad
    AND estado_modalidad = 'ACTIVO';

  IF (v_modalidad_existe = 0) THEN
    RAISE EXCEPTION 'Error! La modalidad especificada no existe o no está activa';
  END IF;

  -- Validar plan de estudio si se proporciona
  IF p_id_aca_plan_estudio IS NOT NULL THEN
    SELECT COUNT(*)
    INTO v_plan_existe
    FROM aca_plan_estudio
    WHERE id_aca_plan_estudio = p_id_aca_plan_estudio
      AND estado_plan_estudio = 'ACTIVO';

    IF (v_plan_existe = 0) THEN
      RAISE EXCEPTION 'Error! El plan de estudio especificado no existe o no está activo';
    END IF;
  END IF;

  -- Validar versión y obtener código para generar sigla
  IF p_id_aca_version IS NOT NULL THEN
    SELECT COUNT(*), MAX(cod_version)
    INTO v_version_existe, v_cod_version
    FROM aca_version
    WHERE id_aca_version = p_id_aca_version
      AND estado_version = 'ACTIVO';

    IF (v_version_existe = 0) THEN
      RAISE EXCEPTION 'Error! La versión especificada no existe o no está activa';
    END IF;

    -- Convertir versión romana a número y generar código sigla
    v_version_numero := CASE v_cod_version
                          WHEN 'I' THEN 1
                          WHEN 'II' THEN 2
                          WHEN 'III' THEN 3
                          WHEN 'IV' THEN 4
                          WHEN 'V' THEN 5
                          WHEN 'VI' THEN 6
                          WHEN 'VII' THEN 7
                          WHEN 'VIII' THEN 8
                          WHEN 'IX' THEN 9
                          WHEN 'X' THEN 10
                          ELSE 1
      END;

    v_cod_sigla_version := CONCAT(COALESCE(v_sigla_programa, ''), ' ', (v_version_numero * 100));
  END IF;

  -- Validar gestión válida
  IF p_gestion < 2000 OR p_gestion > (EXTRACT(YEAR FROM CURRENT_DATE) + 5) THEN
    RAISE EXCEPTION 'Error! La gestión debe estar entre 2000 y %', (EXTRACT(YEAR FROM CURRENT_DATE) + 5);
  END IF;

  -- Validar precios no negativos
  IF p_precio_matricula < 0 OR p_precio_colegiatura < 0 THEN
    RAISE EXCEPTION 'Error! Los precios de matrícula y colegiatura no pueden ser negativos';
  END IF;

  -- Validar precio titulación si se proporciona
  IF p_precio_titulacion IS NOT NULL AND p_precio_titulacion < 0 THEN
    RAISE EXCEPTION 'Error! El precio de titulación no pueden ser negativos';
  END IF;

  -- Validar fechas de vigencia
  IF p_fecha_inicio_vigencia IS NOT NULL AND p_fecha_fin_vigencia IS NOT NULL THEN
    IF p_fecha_inicio_vigencia >= p_fecha_fin_vigencia THEN
      RAISE EXCEPTION 'Error! La fecha de inicio debe ser anterior a la fecha de fin';
    END IF;
  END IF;

  -- Validar formato de certificado CEUB
  IF p_cod_certificado_ceub IS NOT NULL AND p_cod_certificado_ceub !~ '^\d+/\d{4}$' THEN
    RAISE EXCEPTION 'Error! El código de certificado CEUB debe tener formato número/año (ej: 123/2024)';
  END IF;

  -- Validar combinación única programa+modalidad+gestión
  SELECT COUNT(*)
  INTO v_combinacion_existe
  FROM aca_programa_aprobado
  WHERE id_aca_programa = p_id_aca_programa
    AND id_aca_modalidad = p_id_aca_modalidad
    AND gestion = p_gestion
    AND estado_programa_aprobado IN ('SIN INICIAR', 'EN EJECUCION');

  IF (v_combinacion_existe > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe un programa aprobado activo con esa modalidad para la gestión %', p_gestion;
  END IF;

  -- Inserción del programa aprobado
  INSERT INTO aca_programa_aprobado(
    id_aca_programa, id_aca_modalidad, gestion, id_aca_plan_estudio,
    id_aca_version, estado_programa_aprobado, cod_certificado_ceub,
    cod_sigla_version, precio_matricula, precio_colegiatura,
    precio_titulacion, fecha_inicio_vigencia, fecha_fin_vigencia,
    fecha_reg, user_reg
  ) VALUES (
             p_id_aca_programa, p_id_aca_modalidad, p_gestion, p_id_aca_plan_estudio,
             p_id_aca_version, p_estado_programa_aprobado, p_cod_certificado_ceub,
             v_cod_sigla_version, p_precio_matricula, p_precio_colegiatura,
             p_precio_titulacion, p_fecha_inicio_vigencia, p_fecha_fin_vigencia,
             NOW(), p_user_reg
           ) RETURNING id_aca_programa_aprobado INTO v_id_programa_aprobado;

  RETURN CONCAT('Programa aprobado registrado exitosamente con ID: ', v_id_programa_aprobado,
                CASE WHEN v_cod_sigla_version IS NOT NULL
                       THEN CONCAT(', Código: ', v_cod_sigla_version)
                     ELSE ''
                  END);
END;
$$;

CREATE OR REPLACE FUNCTION fn_modificar_programa_aprobado(
  p_id_aca_programa_aprobado INTEGER,
  p_id_aca_programa INTEGER,
  p_id_aca_modalidad INTEGER,
  p_gestion INTEGER,
  p_id_aca_plan_estudio INTEGER,
  p_id_aca_version INTEGER,
  p_estado_programa_aprobado VARCHAR(35),
  p_precio_matricula DECIMAL(8,2),
  p_precio_colegiatura DECIMAL(8,2),
  p_precio_titulacion DECIMAL(8,2),
  p_fecha_inicio_vigencia DATE,
  p_fecha_fin_vigencia DATE,
  p_cod_certificado_ceub VARCHAR(55),
  p_cod_sigla_version VARCHAR(15),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_programa_aprobado_existe INTEGER;
  v_programa_existe INTEGER;
  v_modalidad_existe INTEGER;
  v_plan_existe INTEGER;
  v_version_existe INTEGER;
  v_combinacion_existe INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_programa_aprobado IS NULL OR p_id_aca_programa IS NULL OR
     p_id_aca_modalidad IS NULL OR p_gestion IS NULL OR
     p_estado_programa_aprobado IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos ID, programa, modalidad, gestión, estado y usuario son obligatorios';
  END IF;

  -- Validar existencia del programa aprobado
  SELECT COUNT(*)
  INTO v_programa_aprobado_existe
  FROM aca_programa_aprobado
  WHERE id_aca_programa_aprobado = p_id_aca_programa_aprobado;

  IF (v_programa_aprobado_existe = 0) THEN
    RAISE EXCEPTION 'Error! El programa aprobado con ID % no existe', p_id_aca_programa_aprobado;
  END IF;

  -- Validar existencia del programa activo
  SELECT COUNT(*)
  INTO v_programa_existe
  FROM aca_programa
  WHERE id_aca_programa = p_id_aca_programa
    AND estado_programa = 'ACTIVO';

  IF (v_programa_existe = 0) THEN
    RAISE EXCEPTION 'Error! El programa especificado no existe o no está activo';
  END IF;

  -- Validar existencia de modalidad activa
  SELECT COUNT(*)
  INTO v_modalidad_existe
  FROM aca_modalidad
  WHERE id_aca_modalidad = p_id_aca_modalidad
    AND estado_modalidad = 'ACTIVO';

  IF (v_modalidad_existe = 0) THEN
    RAISE EXCEPTION 'Error! La modalidad especificada no existe o no está activa';
  END IF;

  -- Validar plan de estudio si se proporciona
  IF p_id_aca_plan_estudio IS NOT NULL THEN
    SELECT COUNT(*)
    INTO v_plan_existe
    FROM aca_plan_estudio
    WHERE id_aca_plan_estudio = p_id_aca_plan_estudio
      AND estado_plan_estudio = 'ACTIVO';

    IF (v_plan_existe = 0) THEN
      RAISE EXCEPTION 'Error! El plan de estudio especificado no existe o no está activo';
    END IF;
  END IF;

  -- Validar versión si se proporciona
  IF p_id_aca_version IS NOT NULL THEN
    SELECT COUNT(*)
    INTO v_version_existe
    FROM aca_version
    WHERE id_aca_version = p_id_aca_version
      AND estado_version = 'ACTIVO';

    IF (v_version_existe = 0) THEN
      RAISE EXCEPTION 'Error! La versión especificada no existe o no está activa';
    END IF;
  END IF;

  -- Validar gestión válida
  IF p_gestion < 2000 OR p_gestion > (EXTRACT(YEAR FROM CURRENT_DATE) + 5) THEN
    RAISE EXCEPTION 'Error! La gestión debe estar entre 2000 y %', (EXTRACT(YEAR FROM CURRENT_DATE) + 5);
  END IF;

  -- Validar precios no negativos
  IF p_precio_matricula < 0 OR p_precio_colegiatura < 0 OR
     (p_precio_titulacion IS NOT NULL AND p_precio_titulacion < 0) THEN
    RAISE EXCEPTION 'Error! Los precios no pueden ser negativos';
  END IF;

  -- Validar fechas de vigencia lógicas
  IF p_fecha_inicio_vigencia IS NOT NULL AND p_fecha_fin_vigencia IS NOT NULL THEN
    IF p_fecha_inicio_vigencia > p_fecha_fin_vigencia THEN
      RAISE EXCEPTION 'Error! La fecha de inicio no puede ser posterior a la fecha de fin';
    END IF;
  END IF;

  -- Validar estados permitidos
  IF p_estado_programa_aprobado NOT IN ('ACTIVO', 'INACTIVO', 'ELIMINADO') THEN
    RAISE EXCEPTION 'Error! El estado debe ser "ACTIVO", "INACTIVO" o "ELIMINADO"';
  END IF;

  -- Validar combinación única programa+modalidad+gestión (excluyendo registro actual)
  SELECT COUNT(*)
  INTO v_combinacion_existe
  FROM aca_programa_aprobado
  WHERE id_aca_programa = p_id_aca_programa
    AND id_aca_modalidad = p_id_aca_modalidad
    AND gestion = p_gestion
    AND estado_programa_aprobado = 'ACTIVO'
    AND id_aca_programa_aprobado != p_id_aca_programa_aprobado;

  IF (v_combinacion_existe > 0) THEN
    RAISE EXCEPTION 'Error! Ya existe otro programa aprobado con esa modalidad para la gestión %', p_gestion;
  END IF;

  -- Actualización del programa aprobado
  UPDATE aca_programa_aprobado
  SET id_aca_programa = p_id_aca_programa,
      id_aca_modalidad = p_id_aca_modalidad,
      gestion = p_gestion,
      id_aca_plan_estudio = p_id_aca_plan_estudio,
      id_aca_version = p_id_aca_version,
      estado_programa_aprobado = UPPER(TRIM(p_estado_programa_aprobado)),
      precio_matricula = p_precio_matricula,
      precio_colegiatura = p_precio_colegiatura,
      precio_titulacion = p_precio_titulacion,
      fecha_inicio_vigencia = p_fecha_inicio_vigencia,
      fecha_fin_vigencia = p_fecha_fin_vigencia,
      cod_certificado_ceub = UPPER(TRIM(p_cod_certificado_ceub)),
      cod_sigla_version = UPPER(TRIM(p_cod_sigla_version)),
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_aca_programa_aprobado = p_id_aca_programa_aprobado;

  RETURN CONCAT('Programa aprobado con ID ', p_id_aca_programa_aprobado, ' modificado exitosamente');
END;
$$;


CREATE OR REPLACE VIEW vista_programas_aprobados AS
SELECT
  pa.id_aca_programa_aprobado,
  p.nombre_programa as programa_nombre,
  p.sigla as programa_sigla,
  a.nombre_area as area_nombre,
  m.nombre_modalidad as modalidad_nombre,
  pa.gestion,
  pa.estado_programa_aprobado,
  v.cod_version,
  pe.id_aca_plan_estudio,
  pe.anho as plan_anho,
  pa.fecha_inicio_vigencia,
  pa.fecha_fin_vigencia,
  pa.precio_matricula,
  pa.precio_colegiatura,
  pa.precio_titulacion
FROM aca_programa_aprobado pa
       JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       JOIN aca_area a ON p.id_aca_area = a.id_aca_area
       JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
       JOIN aca_version v ON pa.id_aca_version = v.id_aca_version
       LEFT JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
WHERE pa.estado_programa_aprobado != 'ELIMINADO'
ORDER BY pa.gestion DESC, p.nombre_programa;
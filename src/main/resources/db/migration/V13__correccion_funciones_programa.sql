drop view if exists vista_grupos_con_cronogramas;
create or replace view vista_grupos_con_cronogramas
          (id_ins_grupo, nombre_grupo, fecha_inicio_inscripcion, fecha_fin_inscripcion, estado_grupo, gestion_inicio,
           id_aca_programa_aprobado, nombre_programa, programa_sigla, nombre_area, nombre_modalidad, gestion,
           total_estudiantes, id_eje_cronograma_modulo, nombre_modulo, nombre_nivel, modulo_orden, carga_horaria, creditos,
           sigla, fecha_inicio, fecha_fin, estado_cronograma_modulo, id_eje_docente, docente_nombre_completo, docente_ci)
as
SELECT g.id_ins_grupo,
       g.nombre_grupo,
       g.fecha_inicio_inscripcion,
       g.fecha_fin_inscripcion,
       g.estado_grupo,
       g.gestion_inicio,
       pa.id_aca_programa_aprobado,
       p.nombre_programa,
       p.sigla                                                                                    AS programa_sigla,
       a.nombre_area,
       m.nombre_modalidad,
       pa.gestion,
       count(DISTINCT mat.cod_ins_matricula)                                                      AS total_estudiantes,
       cm.id_eje_cronograma_modulo,
       mod.nombre_modulo,
       niv.nombre_nivel,
       pmd.orden                                                                                  AS modulo_orden,
       pmd.carga_horaria,
       pmd.creditos,
       CASE
         WHEN COALESCE(pa.cod_sigla_version, p.sigla) ~ '^[A-Z]+ [0-9]+$' THEN
           TRIM(SPLIT_PART(COALESCE(pa.cod_sigla_version, p.sigla), ' ', 1)) || ' ' ||
           (SPLIT_PART(COALESCE(pa.cod_sigla_version, p.sigla), ' ', 2)::INTEGER + pmd.orden)::TEXT
         ELSE
           UPPER(REGEXP_REPLACE(COALESCE(pa.cod_sigla_version, p.sigla, ''), '[^A-Za-z]', '', 'g')) || ' ' ||
           (100 + pmd.orden)::TEXT
         END                                                                                        AS sigla,
       cm.fecha_inicio,
       cm.fecha_fin,
       cm.estado_cronograma_modulo,
       d.id_eje_docente,
       concat(pd.nombre, ' ', pd.ap_paterno, ' ',
              COALESCE(pd.ap_materno, ''::character varying))                                     AS docente_nombre_completo,
       pd.ci                                                                                      AS docente_ci
FROM ins_grupo g
       JOIN aca_programa_aprobado pa ON g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       JOIN aca_area a ON p.id_aca_area = a.id_aca_area
       JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
       LEFT JOIN ins_matricula mat ON g.id_ins_grupo = mat.id_ins_grupo AND mat.estado_matricula::text = 'ACTIVO'::text
       LEFT JOIN eje_cronograma_modulo cm
                 ON g.id_ins_grupo = cm.id_ins_grupo AND cm.estado_cronograma_modulo::text <> 'ELIMINADO'::text
       LEFT JOIN aca_plan_modulo_detalle pmd ON cm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle
       LEFT JOIN aca_modulo mod ON pmd.id_aca_modulo = mod.id_aca_modulo
       LEFT JOIN aca_nivel niv ON pmd.id_aca_nivel = niv.id_aca_nivel
       LEFT JOIN eje_docente d ON cm.id_eje_docente = d.id_eje_docente
       LEFT JOIN prs_persona pd ON d.id_prs_persona = pd.id_prs_persona
WHERE g.estado_grupo::text <> 'ELIMINADO'::text
GROUP BY g.id_ins_grupo, g.nombre_grupo, g.fecha_inicio_inscripcion, g.fecha_fin_inscripcion, g.estado_grupo,
         g.gestion_inicio, pa.id_aca_programa_aprobado, p.nombre_programa, p.sigla, a.nombre_area, m.nombre_modalidad,
         pa.gestion, cm.id_eje_cronograma_modulo, mod.nombre_modulo, niv.nombre_nivel, pmd.orden, pmd.carga_horaria,
         pmd.creditos, pa.cod_sigla_version, cm.fecha_inicio, cm.fecha_fin, cm.estado_cronograma_modulo, d.id_eje_docente,
         pd.nombre, pd.ap_paterno, pd.ap_materno, pd.ci
ORDER BY g.gestion_inicio DESC, g.nombre_grupo, pmd.orden;



create or replace function fn_registrar_programa_aprobado(p_id_aca_programa integer, p_id_aca_modalidad integer, p_gestion integer, p_id_aca_plan_estudio integer, p_id_aca_version integer, p_estado_programa_aprobado character varying, p_cod_certificado_ceub character varying, p_precio_matricula numeric, p_precio_colegiatura numeric, p_precio_titulacion numeric, p_fecha_inicio_vigencia date, p_fecha_fin_vigencia date, p_user_reg integer) returns text
  language plpgsql
as
$$
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
  v_version_final INTEGER;
BEGIN
  -- Validaciones de campos obligatorios
  IF p_id_aca_programa IS NULL OR p_id_aca_modalidad IS NULL OR
     p_gestion IS NULL OR p_user_reg IS NULL OR p_estado_programa_aprobado IS NULL THEN
    RAISE EXCEPTION 'Error! Los campos programa, modalidad, gestión, estado y usuario son obligatorios';
  END IF;

  -- Validar estado válido
  IF p_estado_programa_aprobado NOT IN ('SIN INICIAR', 'EN EJECUCION', 'FINALIZADO') THEN
    RAISE EXCEPTION 'Error! Estado debe ser: SIN INICIAR, EN EJECUCION o FINALIZADO';
  END IF;

  -- Validar existencia del programa activo y obtener sigla
  SELECT COUNT(*), MAX(sigla)
  INTO v_programa_existe, v_sigla_programa
  FROM aca_programa
  WHERE id_aca_programa = p_id_aca_programa
    AND estado_programa != 'ELIMINADO';

  IF (v_programa_existe = 0) THEN
    RAISE EXCEPTION 'Error! El programa especificado no existe o no está activo';
  END IF;

  -- Validar existencia de modalidad activa
  SELECT COUNT(*)
  INTO v_modalidad_existe
  FROM aca_modalidad
  WHERE id_aca_modalidad = p_id_aca_modalidad
    AND estado_modalidad != 'ELIMINADO';

  IF (v_modalidad_existe = 0) THEN
    RAISE EXCEPTION 'Error! La modalidad especificada no existe o no está activa';
  END IF;

  -- Validar plan de estudio si se proporciona
  IF p_id_aca_plan_estudio IS NOT NULL THEN
    SELECT COUNT(*)
    INTO v_plan_existe
    FROM aca_plan_estudio
    WHERE id_aca_plan_estudio = p_id_aca_plan_estudio
      AND estado_plan_estudio != 'ELIMINADO';

    IF (v_plan_existe = 0) THEN
      RAISE EXCEPTION 'Error! El plan de estudio especificado no existe o no está activo';
    END IF;
  END IF;

  -- Asignar versión por defecto si no se proporciona
  IF p_id_aca_version IS NULL THEN
    SELECT id_aca_version
    INTO v_version_final
    FROM aca_version
    WHERE cod_version = 'I'
      AND estado_version != 'ELIMINADO'
    LIMIT 1;

    IF v_version_final IS NULL THEN
      RAISE EXCEPTION 'Error! No se encontró la versión I por defecto';
    END IF;
  ELSE
    v_version_final := p_id_aca_version;
  END IF;

  -- Validar versión y obtener código para generar sigla
  SELECT COUNT(*), MAX(cod_version)
  INTO v_version_existe, v_cod_version
  FROM aca_version
  WHERE id_aca_version = v_version_final
    AND estado_version != 'ELIMINADO';

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
             v_version_final, p_estado_programa_aprobado, p_cod_certificado_ceub,
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

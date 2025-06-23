-- Vista grupos completos con información agregada
CREATE VIEW vista_grupos_completos AS
SELECT
  g.id_ins_grupo,
  g.nombre_grupo,
  g.fecha_inicio_inscripcion,
  g.fecha_fin_inscripcion,
  g.estado_grupo,
  g.gestion_inicio,
  -- Datos del programa aprobado
  pa.gestion,
  pa.id_aca_programa_aprobado,
  p.nombre_programa,
  p.sigla AS programa_sigla,
  a.nombre_area,
  m.nombre_modalidad,
  pe.anho AS plan_anho,
  v.cod_version,
  -- Métricas
  COUNT(DISTINCT mat.cod_ins_matricula) AS total_estudiantes,
  COUNT(DISTINCT cm.id_eje_cronograma_modulo) AS total_cronogramas
FROM ins_grupo g
       JOIN aca_programa_aprobado pa ON g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       JOIN aca_area a ON p.id_aca_area = a.id_aca_area
       JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
       LEFT JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
       LEFT JOIN aca_version v ON pa.id_aca_version = v.id_aca_version
       LEFT JOIN ins_matricula mat ON g.id_ins_grupo = mat.id_ins_grupo AND mat.estado_matricula = 'ACTIVO'
       LEFT JOIN eje_cronograma_modulo cm ON g.id_ins_grupo = cm.id_ins_grupo AND cm.estado_cronograma_modulo = 'ACTIVO'
WHERE g.estado_grupo != 'ELIMINADO'
GROUP BY g.id_ins_grupo, g.nombre_grupo, g.fecha_inicio_inscripcion, g.fecha_fin_inscripcion, pa.id_aca_programa_aprobado,
         g.estado_grupo, g.gestion_inicio, pa.gestion, p.nombre_programa, p.sigla,
         a.nombre_area, m.nombre_modalidad, pe.anho, v.cod_version
ORDER BY g.gestion_inicio DESC, g.nombre_grupo;

-- Vista estudiantes por grupo
CREATE VIEW vista_estudiantes_por_grupo AS
SELECT
  g.id_ins_grupo,
  g.nombre_grupo,
  mat.cod_ins_matricula,
  p.nombre,
  p.ap_paterno,
  p.ap_materno,
  p.ci,
  p.nro_celular,
  mat.tipo_matricula,
  mat.estado_matricula,
  mat.fecha_reg AS fecha_matricula
FROM ins_grupo g
       JOIN ins_matricula mat ON g.id_ins_grupo = mat.id_ins_grupo
       JOIN prs_persona p ON mat.id_prs_persona = p.id_prs_persona
WHERE mat.estado_matricula != 'ELIMINADO'
ORDER BY g.id_ins_grupo, p.ap_paterno, p.ap_materno, p.nombre;

-- Función registrar grupo
CREATE OR REPLACE FUNCTION fn_registrar_grupo(
  p_id_aca_programa_aprobado INTEGER,
  p_nombre_grupo VARCHAR(100),
  p_fecha_inicio_inscripcion DATE,
  p_fecha_fin_inscripcion DATE,
  p_gestion_inicio INTEGER,
  p_user_reg INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_grupo INTEGER;
  v_programa_existe INTEGER;
  v_nombre_existe INTEGER;
  v_estado_calculado VARCHAR(35);
BEGIN
  -- Validaciones obligatorias
  IF p_id_aca_programa_aprobado IS NULL OR p_nombre_grupo IS NULL OR
     p_fecha_inicio_inscripcion IS NULL OR p_gestion_inicio IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
  END IF;

  -- Validar programa aprobado activo
  SELECT COUNT(*) INTO v_programa_existe
  FROM aca_programa_aprobado
  WHERE id_aca_programa_aprobado = p_id_aca_programa_aprobado
    AND estado_programa_aprobado != 'ELIMINADO';

  IF v_programa_existe = 0 THEN
    RAISE EXCEPTION 'Error! El programa aprobado no existe';
  END IF;

  -- Validar nombre único
  SELECT COUNT(*) INTO v_nombre_existe
  FROM ins_grupo
  WHERE UPPER(TRIM(nombre_grupo)) = UPPER(TRIM(p_nombre_grupo))
    AND estado_grupo != 'ELIMINADO';

  IF v_nombre_existe > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe un grupo activo con este nombre';
  END IF;

  -- Validar fechas
  IF p_fecha_fin_inscripcion IS NOT NULL AND p_fecha_inicio_inscripcion > p_fecha_fin_inscripcion THEN
    RAISE EXCEPTION 'Error! Fecha inicio no puede ser posterior a fecha fin';
  END IF;

  -- Calcular estado inicial
  IF p_fecha_inicio_inscripcion <= CURRENT_DATE AND
     (p_fecha_fin_inscripcion IS NULL OR p_fecha_fin_inscripcion >= CURRENT_DATE) THEN
    v_estado_calculado := 'EN OFERTA';
  ELSE
    v_estado_calculado := 'PROGRAMADO';
  END IF;

  -- Insertar grupo
  INSERT INTO ins_grupo(
    id_aca_programa_aprobado, nombre_grupo, fecha_inicio_inscripcion,
    fecha_fin_inscripcion, estado_grupo, gestion_inicio,
    fecha_reg, user_reg
  ) VALUES (
             p_id_aca_programa_aprobado, UPPER(TRIM(p_nombre_grupo)), p_fecha_inicio_inscripcion,
             p_fecha_fin_inscripcion, v_estado_calculado, p_gestion_inicio,
             NOW(), p_user_reg
           ) RETURNING id_ins_grupo INTO v_id_grupo;

  RETURN CONCAT('Grupo registrado exitosamente con ID: ', v_id_grupo);
END;
$$;

-- Función modificar grupo
CREATE OR REPLACE FUNCTION fn_modificar_grupo(
  p_id_ins_grupo INTEGER,
  p_nombre_grupo VARCHAR(100),
  p_fecha_inicio_inscripcion DATE,
  p_fecha_fin_inscripcion DATE,
  p_estado_grupo VARCHAR(35),
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
    v_grupo_existe INTEGER;
    v_nombre_existe INTEGER;
BEGIN
    -- Validaciones obligatorias
    IF p_id_ins_grupo IS NULL OR p_nombre_grupo IS NULL OR
       p_fecha_inicio_inscripcion IS NULL OR p_estado_grupo IS NULL OR p_user_mod IS NULL THEN
        RAISE EXCEPTION 'Error! Campos obligatorios faltantes';
    END IF;

    -- Validar existencia del grupo
    SELECT COUNT(*) INTO v_grupo_existe
    FROM ins_grupo
    WHERE id_ins_grupo = p_id_ins_grupo;

    IF v_grupo_existe = 0 THEN
        RAISE EXCEPTION 'Error! El grupo no existe';
    END IF;

    -- Validar nombre único (excluyendo actual)
    SELECT COUNT(*) INTO v_nombre_existe
    FROM ins_grupo
    WHERE UPPER(TRIM(nombre_grupo)) = UPPER(TRIM(p_nombre_grupo))
      AND estado_grupo = 'ACTIVO'
      AND id_ins_grupo != p_id_ins_grupo;

    IF v_nombre_existe > 0 THEN
        RAISE EXCEPTION 'Error! Ya existe otro grupo activo con este nombre';
    END IF;

    -- Validar fechas
    IF p_fecha_fin_inscripcion IS NOT NULL AND p_fecha_inicio_inscripcion > p_fecha_fin_inscripcion THEN
        RAISE EXCEPTION 'Error! Fecha inicio no puede ser posterior a fecha fin';
    END IF;

    -- Validar estados
    IF p_estado_grupo NOT IN ('PROGRAMADO', 'EN OFERTA', 'EN EJECUCION', 'FINALIZADO') THEN
        RAISE EXCEPTION 'Error! Estado inválido';
    END IF;

    -- Actualizar grupo
    UPDATE ins_grupo
    SET nombre_grupo = UPPER(TRIM(p_nombre_grupo)),
        fecha_inicio_inscripcion = p_fecha_inicio_inscripcion,
        fecha_fin_inscripcion = p_fecha_fin_inscripcion,
        estado_grupo = p_estado_grupo,
        fecha_mod = NOW(),
        user_mod = p_user_mod
    WHERE id_ins_grupo = p_id_ins_grupo;

    RETURN CONCAT('Grupo modificado exitosamente con ID: ', p_id_ins_grupo);
END;
$$;

CREATE OR REPLACE FUNCTION fn_trigger_crear_cronogramas_grupo()
  RETURNS TRIGGER
  LANGUAGE plpgsql
AS $$
DECLARE
  v_plan_estudio INTEGER;
  rec_modulo RECORD;
BEGIN
  SELECT pe.id_aca_plan_estudio INTO v_plan_estudio
  FROM aca_programa_aprobado pa
         JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
  WHERE pa.id_aca_programa_aprobado = NEW.id_aca_programa_aprobado
    AND pe.vigente = true
    AND pe.estado_plan_estudio = 'ACTIVO';

  IF v_plan_estudio IS NOT NULL THEN
    FOR rec_modulo IN
      SELECT id_aca_plan_modulo_detalle
      FROM aca_plan_modulo_detalle
      WHERE id_aca_plan_estudio = v_plan_estudio
        AND estado_plan_modulo_detalle = 'ACTIVO'
      ORDER BY orden
      LOOP
        INSERT INTO eje_cronograma_modulo(
          id_ins_grupo, id_aca_plan_modulo_detalle,
          estado_cronograma_modulo, fecha_reg, user_reg
        ) VALUES (
                   NEW.id_ins_grupo, rec_modulo.id_aca_plan_modulo_detalle,
                   'PROGRAMADO', NOW(), NEW.user_reg
                 );
      END LOOP;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER tr_crear_cronogramas_grupo
  AFTER INSERT ON ins_grupo
  FOR EACH ROW
EXECUTE FUNCTION fn_trigger_crear_cronogramas_grupo();

-- Función auxiliar para actualizar estado automático
CREATE OR REPLACE FUNCTION fn_actualizar_estado_grupo_automatico(p_id_grupo INTEGER)
  RETURNS VOID
  LANGUAGE plpgsql
AS $$
DECLARE
  v_nuevo_estado VARCHAR(35);
  v_estudiantes INTEGER;
  v_fecha_inicio DATE;
  v_fecha_fin DATE;
  v_estado_actual VARCHAR(35);
BEGIN
  SELECT fecha_inicio_inscripcion, fecha_fin_inscripcion, estado_grupo
  INTO v_fecha_inicio, v_fecha_fin, v_estado_actual
  FROM ins_grupo WHERE id_ins_grupo = p_id_grupo;

  IF v_estado_actual IN ('ELIMINADO') THEN
    RETURN;
  END IF;

  SELECT COUNT(*) INTO v_estudiantes
  FROM ins_matricula
  WHERE id_ins_grupo = p_id_grupo AND estado_matricula = 'ACTIVO';

  -- Lógica simplificada de estados
  IF v_estudiantes > 0 THEN
    v_nuevo_estado := 'EN EJECUCION';
  ELSIF v_fecha_inicio <= CURRENT_DATE AND
        (v_fecha_fin IS NULL OR v_fecha_fin >= CURRENT_DATE) THEN
    v_nuevo_estado := 'EN OFERTA';
  ELSE
    v_nuevo_estado := 'PROGRAMADO';
  END IF;

  IF v_nuevo_estado != v_estado_actual THEN
    UPDATE ins_grupo
    SET estado_grupo = v_nuevo_estado, fecha_mod = NOW()
    WHERE id_ins_grupo = p_id_grupo;
  END IF;
END;
$$;

-- Trigger para actualizar estado cuando cambian matrículas
CREATE OR REPLACE FUNCTION fn_trigger_matricula_actualiza_grupo()
  RETURNS TRIGGER
  LANGUAGE plpgsql
AS $$
DECLARE
  v_id_grupo INTEGER;
BEGIN
  v_id_grupo := COALESCE(NEW.id_ins_grupo, OLD.id_ins_grupo);
  PERFORM fn_actualizar_estado_grupo_automatico(v_id_grupo);
  RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER tr_matricula_actualiza_grupo
  AFTER INSERT OR UPDATE OR DELETE ON ins_matricula
  FOR EACH ROW
EXECUTE FUNCTION fn_trigger_matricula_actualiza_grupo();

-- Trigger para actualizar estado en cambios de fechas del grupo
CREATE OR REPLACE FUNCTION fn_trigger_actualizar_estado_grupo()
  RETURNS TRIGGER
  LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM fn_actualizar_estado_grupo_automatico(NEW.id_ins_grupo);
  RETURN NEW;
END;
$$;

CREATE TRIGGER tr_actualizar_estado_grupo
  AFTER UPDATE ON ins_grupo
  FOR EACH ROW
EXECUTE FUNCTION fn_trigger_actualizar_estado_grupo();


CREATE VIEW vista_grupos_con_cronogramas AS
SELECT
  -- Datos del grupo
  g.id_ins_grupo,
  g.nombre_grupo,
  g.fecha_inicio_inscripcion,
  g.fecha_fin_inscripcion,
  g.estado_grupo,
  g.gestion_inicio,

  -- Datos del programa
  pa.id_aca_programa_aprobado,
  p.nombre_programa,
  p.sigla AS programa_sigla,
  a.nombre_area,
  m.nombre_modalidad,
  pa.gestion,

  -- Conteo estudiantes
  COUNT(DISTINCT mat.cod_ins_matricula) AS total_estudiantes,

  -- Datos cronograma (NULL si no hay)
  cm.id_eje_cronograma_modulo,
  mod.nombre_modulo,
  niv.nombre_nivel,
  pmd.orden AS modulo_orden,
  pmd.carga_horaria,
  pmd.creditos,
  pmd.sigla,
  cm.fecha_inicio,
  cm.fecha_fin,
  cm.estado_cronograma_modulo,

  -- Datos docente (NULL si no asignado)
  d.id_eje_docente,
  CONCAT(pd.nombre, ' ', pd.ap_paterno, ' ', COALESCE(pd.ap_materno, '')) AS docente_nombre_completo,
  pd.ci AS docente_ci

FROM ins_grupo g
       JOIN aca_programa_aprobado pa ON g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       JOIN aca_area a ON p.id_aca_area = a.id_aca_area
       JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
       LEFT JOIN ins_matricula mat ON g.id_ins_grupo = mat.id_ins_grupo AND mat.estado_matricula = 'ACTIVO'
       LEFT JOIN eje_cronograma_modulo cm ON g.id_ins_grupo = cm.id_ins_grupo AND cm.estado_cronograma_modulo != 'ELIMINADO'
       LEFT JOIN aca_plan_modulo_detalle pmd ON cm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle
       LEFT JOIN aca_modulo mod ON pmd.id_aca_modulo = mod.id_aca_modulo
       LEFT JOIN aca_nivel niv ON pmd.id_aca_nivel = niv.id_aca_nivel
       LEFT JOIN eje_docente d ON cm.id_eje_docente = d.id_eje_docente
       LEFT JOIN prs_persona pd ON d.id_prs_persona = pd.id_prs_persona
WHERE g.estado_grupo != 'ELIMINADO'
GROUP BY g.id_ins_grupo, g.nombre_grupo, g.fecha_inicio_inscripcion, g.fecha_fin_inscripcion,
         g.estado_grupo, g.gestion_inicio, pa.id_aca_programa_aprobado, p.nombre_programa,
         p.sigla, a.nombre_area, m.nombre_modalidad, pa.gestion,
         cm.id_eje_cronograma_modulo, mod.nombre_modulo, niv.nombre_nivel, pmd.orden,
         pmd.carga_horaria, pmd.creditos, pmd.sigla, cm.fecha_inicio, cm.fecha_fin,
         cm.estado_cronograma_modulo, d.id_eje_docente, pd.nombre, pd.ap_paterno,
         pd.ap_materno, pd.ci
ORDER BY g.gestion_inicio DESC, g.nombre_grupo, pmd.orden;


-- Habilitar extensión para encriptación
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION fn_modificar_cronograma_modulo(
  p_id_eje_cronograma_modulo INTEGER,
  p_id_prs_persona INTEGER,
  p_fecha_inicio DATE,
  p_fecha_fin DATE,
  p_user_mod INTEGER
) RETURNS TEXT
  LANGUAGE plpgsql
AS $$
DECLARE
  v_cronograma_existe INTEGER;
  v_id_eje_docente INTEGER;
  v_persona_existe INTEGER;
  v_id_usuario INTEGER;
  v_usuario_existente INTEGER;
  v_rol_asignado INTEGER;
  v_ci_persona VARCHAR(20);
  v_nombre_completo VARCHAR(200);
  rec_tarea RECORD;
BEGIN
  -- Validar campos obligatorios
  IF p_id_eje_cronograma_modulo IS NULL OR p_user_mod IS NULL THEN
    RAISE EXCEPTION 'Error! ID cronograma y usuario son obligatorios';
  END IF;

  -- Validar cronograma existe y activo
  SELECT COUNT(*) INTO v_cronograma_existe
  FROM eje_cronograma_modulo
  WHERE id_eje_cronograma_modulo = p_id_eje_cronograma_modulo
    AND estado_cronograma_modulo != 'ELIMINADO';

  IF v_cronograma_existe = 0 THEN
    RAISE EXCEPTION 'Error! Cronograma no existo';
  END IF;

  -- Procesar docente si se especifica persona
  IF p_id_prs_persona IS NOT NULL THEN
    -- Verificar persona existe y obtener datos
    SELECT COUNT(*), MAX(ci), MAX(CONCAT(nombre, ' ', ap_paterno))
    INTO v_persona_existe, v_ci_persona, v_nombre_completo
    FROM prs_persona
    WHERE id_prs_persona = p_id_prs_persona
      AND estado_persona = 'ACTIVO';

    IF v_persona_existe = 0 THEN
      RAISE EXCEPTION 'Error! La persona no existe o no está activa';
    END IF;

    -- Buscar si ya es docente
    SELECT id_eje_docente, id_seg_usuario INTO v_id_eje_docente, v_id_usuario
    FROM eje_docente
    WHERE id_prs_persona = p_id_prs_persona
      AND estado_docente != 'ELIMINADO';

    -- Si no es docente, crearlo con usuario
    IF v_id_eje_docente IS NULL THEN
      -- Crear usuario con CI como username y contraseña encriptada
      INSERT INTO seg_usuario(nombre_usuario, contrasena_hash, estado_usuario, fecha_reg, user_reg)
      VALUES (v_ci_persona, crypt('123456', gen_salt('bf')), 'ACTIVO', NOW(), p_user_mod)
      RETURNING id_seg_usuario INTO v_id_usuario;

      -- Crear docente
      INSERT INTO eje_docente(id_prs_persona, id_seg_usuario, estado_docente, fecha_reg, user_reg)
      VALUES (p_id_prs_persona, v_id_usuario, 'ACTIVO', NOW(), p_user_mod)
      RETURNING id_eje_docente INTO v_id_eje_docente;
    END IF;

    -- Asignar rol DOCENTE si no lo tiene
    SELECT COUNT(*) INTO v_rol_asignado
    FROM seg_ocupa
    WHERE id_seg_usuario = v_id_usuario
      AND id_seg_rol = 4
      AND estado_ocupa = 'ACTIVO';

    IF v_rol_asignado = 0 THEN
      INSERT INTO seg_ocupa(id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg)
      VALUES (4, v_id_usuario, 'ACTIVO', NOW(), p_user_mod);
    END IF;

    -- Asignar tareas de docente
    FOR rec_tarea IN
      SELECT id_seg_tarea
      FROM seg_tarea
      WHERE id_seg_rol = 4
        AND estado_tarea = 'ACTIVO'
      LOOP
        INSERT INTO seg_designa(id_seg_tarea, id_seg_usuario, estado_designa, fecha_reg, user_reg)
        VALUES (rec_tarea.id_seg_tarea, v_id_usuario, 'ACTIVO', NOW(), p_user_mod)
        ON CONFLICT (id_seg_tarea, id_seg_usuario) DO NOTHING;
      END LOOP;
  END IF;

  -- Validar fechas
  IF p_fecha_inicio IS NOT NULL AND p_fecha_fin IS NOT NULL AND p_fecha_inicio > p_fecha_fin THEN
    RAISE EXCEPTION 'Error! Fecha inicio no puede ser posterior a fecha fin';
  END IF;

  -- Actualizar cronograma
  UPDATE eje_cronograma_modulo
  SET id_eje_docente = v_id_eje_docente,
      fecha_inicio = p_fecha_inicio,
      fecha_fin = p_fecha_fin,
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_eje_cronograma_modulo = p_id_eje_cronograma_modulo;

  RETURN CONCAT('Cronograma actualizado exitosamente con ID: ', p_id_eje_cronograma_modulo);
END;
$$;
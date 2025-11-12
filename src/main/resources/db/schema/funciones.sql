-- ============================================
-- FUNCIONES ALMACENADAS
-- ============================================

CREATE OR REPLACE FUNCTION public.extraer_texto_de_html(html_content text)
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_activar_usuario_docente(p_id_usuario integer, p_password_hash character varying)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Actualizar usuario con password hash
  UPDATE seg_usuario
  SET contrasena_hash = p_password_hash,
      estado_usuario = 'ACTIVO'
  WHERE id_seg_usuario = p_id_usuario;

  RETURN 'Usuario docente activado exitosamente';
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_activar_usuario_matricula(p_id_usuario integer, p_password_hash character varying)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Actualizar usuario con password hash
  UPDATE seg_usuario
  SET contrasena_hash = p_password_hash, estado_usuario = 'ACTIVO'
  WHERE id_seg_usuario = p_id_usuario;

  -- Asignar rol matriculado
  INSERT INTO seg_ocupa(
    id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg
  ) VALUES (
             5, p_id_usuario, 'ACTIVO', NOW(), 1
           );

  RETURN 'Usuario activado exitosamente';
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_actualizar_auditoria_mod()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.fecha_mod := NOW();
  -- user_mod se debe establecer desde la aplicación
  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_actualizar_contacto_persona(p_id_persona integer, p_nro_celular character varying, p_correo character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_actualizar_estado_grupo()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Actualizar estado basándose en fechas
  IF NEW.fecha_inicio IS NOT NULL AND NEW.fecha_fin IS NOT NULL THEN
    IF CURRENT_DATE < NEW.fecha_inicio_inscripcion THEN
      NEW.estado_grupo := 'PROGRAMADO';
    ELSIF CURRENT_DATE BETWEEN NEW.fecha_inicio_inscripcion AND NEW.fecha_fin_inscripcion THEN
      NEW.estado_grupo := 'EN OFERTA';
    ELSIF CURRENT_DATE BETWEEN NEW.fecha_inicio AND NEW.fecha_fin THEN
      NEW.estado_grupo := 'EN EJECUCION';
    ELSIF CURRENT_DATE > NEW.fecha_fin THEN
      NEW.estado_grupo := 'FINALIZADO';
    END IF;
  END IF;

  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_actualizar_estado_grupo_automatico(p_id_grupo integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_actualizar_noticia(p_id_pub_noticia integer, p_id_aca_unidad integer, p_titulo character varying, p_contenido text, p_imagen_uri character varying, p_enlace_externo character varying, p_fecha_noticia date, p_es_destacada boolean, p_orden_prioridad integer, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_actualizar_saldo_obligacion()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_nuevo_saldo DECIMAL;
  v_nuevo_estado VARCHAR(35);
BEGIN
  -- Determinar la obligación afectada
  DECLARE
    v_id_obligacion INTEGER;
  BEGIN
    IF TG_OP = 'DELETE' THEN
      v_id_obligacion := OLD.id_fin_obligacion_pago;
    ELSE
      v_id_obligacion := NEW.id_fin_obligacion_pago;
    END IF;

    -- Calcular nuevo saldo
    v_nuevo_saldo := fn_calcular_saldo_pendiente(v_id_obligacion);

    -- Determinar nuevo estado
    IF v_nuevo_saldo = 0 THEN
      v_nuevo_estado := 'PAGADO';
    ELSIF v_nuevo_saldo < (SELECT deuda_con_descuento FROM fin_obligacion_pago WHERE id_fin_obligacion_pago = v_id_obligacion) THEN
      v_nuevo_estado := 'PAGO_PARCIAL';
    ELSE
      v_nuevo_estado := 'PENDIENTE';
    END IF;

    -- Actualizar la obligación
    UPDATE fin_obligacion_pago
    SET
      saldo_pendiente = v_nuevo_saldo,
      estado_obligacion_pago = v_nuevo_estado,
      fecha_mod = CURRENT_TIMESTAMP,
      user_mod = CASE
                   WHEN TG_OP = 'DELETE' THEN OLD.user_reg
                   ELSE NEW.user_reg
        END
    WHERE id_fin_obligacion_pago = v_id_obligacion;
  END;

  RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_actualizar_saldo_pendiente()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_total_pagado NUMERIC(10,2);
BEGIN
  -- Calcular total pagado
  SELECT COALESCE(SUM(dp.monto_pago), 0)
  INTO v_total_pagado
  FROM fin_detalle_pago dp
  WHERE dp.id_fin_obligacion_pago = NEW.id_fin_obligacion_pago
    AND dp.estado_detalle_pago != 'ELIMINADO';

  -- Actualizar saldo pendiente
  UPDATE fin_obligacion_pago
  SET saldo_pendiente = GREATEST(monto_final - v_total_pagado, 0),
      estado_obligacion_pago = CASE
        WHEN GREATEST(monto_final - v_total_pagado, 0) = 0 THEN 'PAGADO'
        WHEN GREATEST(monto_final - v_total_pagado, 0) < monto_final THEN 'PAGO_PARCIAL'
        ELSE 'PENDIENTE'
      END
  WHERE id_fin_obligacion_pago = NEW.id_fin_obligacion_pago;

  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_buscar_persona_por_ci(p_ci character varying)
 RETURNS TABLE(id_prs_persona integer, nombre character varying, ap_paterno character varying, ap_materno character varying, ci character varying, nro_celular character varying, correo character varying, fecha_nacimiento date, nombre_completo text, edad double precision)
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF p_ci IS NULL OR TRIM(p_ci) = '' THEN
    RAISE EXCEPTION 'Error! El CI es requerido para la búsqueda';
  END IF;

  RETURN QUERY
    SELECT
      v.id_prs_persona,
      v.nombre,
      v.ap_paterno,
      v.ap_materno,
      v.ci,
      v.nro_celular,
      v.correo,
      v.fecha_nacimiento,
      v.nombre_completo,
      v.edad
    FROM vista_personas_formulario v
    WHERE v.ci = UPPER(TRIM(p_ci))
    LIMIT 1;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_calcular_monto_matricula(p_id_programa_aprobado integer, p_id_tipo_estudiante integer, p_numero_periodo integer, p_id_fin_convenio integer DEFAULT NULL::integer)
 RETURNS TABLE(monto_base numeric, descuento_arancel numeric, descuento_convenio numeric, monto_final numeric, conceptos json)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_arancel INTEGER;
  v_monto_base NUMERIC(10,2) := 0;
  v_desc_arancel NUMERIC(10,2) := 0;
  v_desc_convenio NUMERIC(10,2) := 0;
  v_conceptos JSON;
BEGIN
  -- Obtener arancel aplicable
  SELECT a.id_fin_arancel INTO v_id_arancel
  FROM fin_arancel a
  WHERE a.id_aca_programa_aprobado = p_id_programa_aprobado
    AND a.id_aca_tipo_estudiante = p_id_tipo_estudiante
    AND a.estado_arancel = 'ACTIVO'
    AND a.fecha_inicio_vigencia <= CURRENT_DATE
    AND (a.fecha_fin_vigencia IS NULL OR a.fecha_fin_vigencia >= CURRENT_DATE)
  LIMIT 1;

  IF v_id_arancel IS NULL THEN
    RAISE EXCEPTION 'No se encontró arancel aplicable';
  END IF;

  -- Calcular monto base
  SELECT COALESCE(SUM(da.monto_concepto), 0)
  INTO v_monto_base
  FROM fin_detalle_arancel da
  WHERE da.id_fin_arancel = v_id_arancel;

  -- Obtener conceptos
  SELECT json_agg(json_build_object(
      'concepto', ca.nombre_concepto,
      'monto', da.monto_concepto
                  ))
  INTO v_conceptos
  FROM fin_detalle_arancel da
         JOIN fin_concepto_arancel ca ON da.id_fin_concepto_arancel = ca.id_fin_concepto_arancel
  WHERE da.id_fin_arancel = v_id_arancel;

  -- Descuento por antigüedad
  SELECT
    CASE
      WHEN tipo_descuento = 'PORCENTAJE'
        THEN v_monto_base * (porcentaje_descuento / 100)
      ELSE monto_descuento
      END
  INTO v_desc_arancel
  FROM fin_descuento_arancel
  WHERE id_fin_arancel = v_id_arancel
    AND estado_descuento = 'ACTIVO'
    AND (aplica_desde_periodo IS NULL OR p_numero_periodo >= aplica_desde_periodo)
  LIMIT 1;

  v_desc_arancel := COALESCE(v_desc_arancel, 0);

  -- Descuento por convenio
  IF p_id_fin_convenio IS NOT NULL THEN
    SELECT
      CASE
        WHEN tipo_descuento = 'PORCENTAJE'
          THEN (v_monto_base - v_desc_arancel) * (porcentaje_descuento / 100)
        ELSE monto_descuento
        END
    INTO v_desc_convenio
    FROM fin_convenio
    WHERE id_fin_convenio = p_id_fin_convenio
      AND estado_convenio = 'ACTIVO'
      AND fecha_inicio_vigencia <= CURRENT_DATE
      AND (fecha_fin_vigencia IS NULL OR fecha_fin_vigencia >= CURRENT_DATE);
  END IF;

  v_desc_convenio := COALESCE(v_desc_convenio, 0);

  RETURN QUERY
    SELECT
      v_monto_base,
      v_desc_arancel,
      v_desc_convenio,
      v_monto_base - v_desc_arancel - v_desc_convenio,
      v_conceptos;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_calcular_nota_final_competencias()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_promedio NUMERIC(5,2);
  v_total_areas INTEGER;
BEGIN
  -- Calcular promedio de todas las áreas de evaluación
  SELECT
    AVG(dc.nota_final_area),
    COUNT(*)
  INTO v_promedio, v_total_areas
  FROM eje_detalle_calificacion dc
  WHERE dc.id_eje_calificacion = NEW.id_eje_calificacion
    AND dc.estado_detalle_calificacion = 'ACTIVO';

  -- Si hay detalles, actualizar nota en eje_calificacion
  IF v_total_areas > 0 THEN
    UPDATE eje_calificacion
    SET nota = v_promedio,
        nota_ponderada = v_promedio
    WHERE id_eje_calificacion = NEW.id_eje_calificacion;

    -- También actualizar en eje_programacion
    UPDATE eje_programacion ep
    SET nota_final = v_promedio
    FROM eje_calificacion ec
    WHERE ec.id_eje_programacion = ep.id_eje_programacion
      AND ec.id_eje_calificacion = NEW.id_eje_calificacion;
  END IF;

  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_calcular_nota_final_programacion(p_id_programacion integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_nota_final DECIMAL(5,2);
BEGIN
  -- Sumar todas las notas ponderadas
  SELECT COALESCE(SUM(nota_ponderada), 0) INTO v_nota_final
  FROM eje_calificacion
  WHERE id_eje_programacion = p_id_programacion
    AND estado_calificacion != 'ELIMINADO';

  -- Actualizar nota final en programación
  UPDATE eje_programacion SET
                            nota_final = ROUND(v_nota_final),
                            fecha_mod = NOW()
  WHERE id_eje_programacion = p_id_programacion;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_calcular_saldo_pendiente(p_id_obligacion integer)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_deuda_con_descuento DECIMAL;
  v_total_pagado DECIMAL;
BEGIN
  -- Obtener la deuda con descuento
  SELECT deuda_con_descuento INTO v_deuda_con_descuento
  FROM fin_obligacion_pago
  WHERE id_fin_obligacion_pago = p_id_obligacion;

  -- Calcular total pagado
  SELECT COALESCE(SUM(dp.monto_pagado), 0) INTO v_total_pagado
  FROM fin_detalle_pago dp
         INNER JOIN fin_transaccion t ON dp.id_fin_transaccion = t.id_fin_transaccion
  WHERE dp.id_fin_obligacion_pago = p_id_obligacion
    AND dp.estado_detalle_pago != 'ELIMINADO'
    AND t.estado_transaccion != 'ELIMINADO';

  RETURN v_deuda_con_descuento - v_total_pagado;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_cambiar_estado_noticia(p_id_pub_noticia integer, p_nuevo_estado character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_consultar_modulos_por_plan(p_id_aca_plan_estudio integer)
 RETURNS TABLE(id_aca_plan_modulo_detalle integer, id_aca_plan_estudio integer, id_aca_modulo integer, id_aca_nivel integer, plan_anho integer, modulo_nombre character varying, nivel_nombre character varying, carga_horaria integer, creditos numeric, orden integer, sigla character, competencia text, estado character varying)
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_consultar_programas_por_plan(p_id_aca_plan_estudio integer)
 RETURNS TABLE(programa_nombre character varying, gestion integer, modalidad_nombre character varying, version_codigo character varying, estado_programa character varying)
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_criterios_por_cronograma(p_id_cronograma integer)
 RETURNS TABLE(id_eje_criterio_eval integer, nombre_crit character varying, descripcion character varying, ponderacion integer, orden integer, tiene_calificaciones boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      ce.id_eje_criterio_eval,
      ce.nombre_crit,
      ce.descripcion,
      ce.ponderacion,
      ce.orden,
      CASE WHEN COUNT(cal.id_eje_calificacion) > 0 THEN TRUE ELSE FALSE END
    FROM eje_criterio_eval ce
           LEFT JOIN eje_calificacion cal ON ce.id_eje_criterio_eval = cal.id_eje_criterio_eval
      AND cal.estado_calificacion != 'ELIMINADO'
    WHERE ce.id_eje_cronograma_modulo = p_id_cronograma
      AND ce.estado_criterio_eval != 'ELIMINADO'
    GROUP BY ce.id_eje_criterio_eval, ce.nombre_crit, ce.descripcion, ce.ponderacion, ce.orden
    ORDER BY ce.orden;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_detalle_obligaciones_matricula(p_cod_matricula integer)
 RETURNS TABLE(nombre character varying, ap_paterno character varying, ap_materno character varying, ci character varying, nro_celular character varying, cod_ins_matricula integer, tipo_matricula character varying, fecha_matricula timestamp without time zone, id_fin_obligacion_pago integer, nombre_concepto character varying, deuda_sin_descuento numeric, deuda_con_descuento numeric, saldo_pendiente numeric, monto_pagado numeric, porcentaje_pagado numeric, descuento_aplicado numeric, estado_pago character varying, fecha_obligacion timestamp without time zone, dias_desde_obligacion integer, nombre_param character varying, valor_parametro text, total_pagos_realizados integer, ultima_fecha_pago date, ultimo_comprobante text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      -- Datos de persona
      p.nombre,
      p.ap_paterno,
      p.ap_materno,
      p.ci,
      p.nro_celular,

      -- Datos de matrícula
      m.cod_ins_matricula,
      m.tipo_matricula,
      m.fecha_reg,

      -- Datos de obligación detallados
      op.id_fin_obligacion_pago,
      cp.nombre_concepto,
      op.deuda_sin_descuento,
      op.deuda_con_descuento,
      op.saldo_pendiente,
      (op.deuda_con_descuento - op.saldo_pendiente) AS monto_pagado,
      CASE
        WHEN op.deuda_con_descuento > 0 THEN
          ROUND(((op.deuda_con_descuento - op.saldo_pendiente) * 100.0 / op.deuda_con_descuento), 2)
        ELSE 0
        END AS porcentaje_pagado,
      (op.deuda_sin_descuento - op.deuda_con_descuento) AS descuento_aplicado,
      CASE
        WHEN op.saldo_pendiente = 0 THEN 'PAGADO'
        WHEN op.saldo_pendiente < op.deuda_con_descuento THEN 'PAGO_PARCIAL'
        ELSE 'PENDIENTE'
        END::VARCHAR AS estado_pago,
      op.fecha_reg,
      (CURRENT_DATE - op.fecha_reg::date)::INTEGER AS dias_desde_obligacion,

      -- Datos de parámetro
      param.nombre_param,
      param.valor,

      -- Datos de pagos
      COALESCE(pagos.total_pagos, 0)::INTEGER,
      pagos.ultima_fecha,
      pagos.ultimo_comprobante

    FROM fin_obligacion_pago op
           INNER JOIN ins_matricula m ON op.cod_ins_matricula = m.cod_ins_matricula
           INNER JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
           INNER JOIN fin_concepto_pago cp ON op.id_fin_concepto_pago = cp.id_fin_concepto_pago
           LEFT JOIN aca_parametro_programa param ON op.id_aca_parametro = param.id_aca_parametro
           LEFT JOIN (
      SELECT
        dp.id_fin_obligacion_pago,
        COUNT(*) AS total_pagos,
        MAX(t.fecha_pago) AS ultima_fecha,
        MAX(t.cod_comprobante) AS ultimo_comprobante
      FROM fin_detalle_pago dp
             INNER JOIN fin_transaccion t ON dp.id_fin_transaccion = t.id_fin_transaccion
      WHERE dp.estado_detalle_pago != 'ELIMINADO'
        AND t.estado_transaccion != 'ELIMINADO'
      GROUP BY dp.id_fin_obligacion_pago
    ) pagos ON op.id_fin_obligacion_pago = pagos.id_fin_obligacion_pago

    WHERE m.cod_ins_matricula = p_cod_matricula
      AND op.estado_obligacion_pago != 'ELIMINADO'
      AND m.estado_matricula != 'ELIMINADO'
      AND p.estado_persona != 'ELIMINADO'
      AND cp.estado_concepto_pago != 'ELIMINADO'

    ORDER BY op.fecha_reg;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_eliminar_criterio_evaluacion(p_id_eje_criterio_eval integer, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_criterio_existe INTEGER;
  v_hay_calificaciones INTEGER;
BEGIN
  -- Validar criterio existe
  SELECT COUNT(*) INTO v_criterio_existe
  FROM eje_criterio_eval
  WHERE id_eje_criterio_eval = p_id_eje_criterio_eval
    AND estado_criterio_eval != 'ELIMINADO';

  IF v_criterio_existe = 0 THEN
    RAISE EXCEPTION 'Error! Criterio no encontrado';
  END IF;

  -- Verificar si ya hay calificaciones
  SELECT COUNT(*) INTO v_hay_calificaciones
  FROM eje_calificacion
  WHERE id_eje_criterio_eval = p_id_eje_criterio_eval
    AND estado_calificacion != 'ELIMINADO';

  IF v_hay_calificaciones > 0 THEN
    RAISE EXCEPTION 'Error! No se puede eliminar criterio con calificaciones registradas';
  END IF;

  -- Eliminar criterio
  UPDATE eje_criterio_eval
  SET estado_criterio_eval = 'ELIMINADO',
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_eje_criterio_eval = p_id_eje_criterio_eval;

  RETURN 'Criterio eliminado exitosamente';
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_estudiantes_aptos_titular(p_id_grupo integer)
 RETURNS TABLE(cod_ins_matricula integer, nombre_completo character varying, ci character varying, apto_titular boolean, promedio_general numeric, modulos_aprobados integer, modulos_requeridos integer, saldo_pendiente numeric, monografia_estado character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      m.cod_ins_matricula,
      CONCAT(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, ''))::VARCHAR,
      p.ci,
      val.apto_titular,
      val.promedio_general,
      val.modulos_aprobados,
      val.modulos_requeridos,
      val.saldo_total_pendiente,
      CASE
        WHEN val.monografia_aprobada THEN 'APROBADA'
        WHEN val.monografia_presentada THEN 'PRESENTADA'
        ELSE 'PENDIENTE'
        END::VARCHAR
    FROM ins_matricula m
           INNER JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
           CROSS JOIN LATERAL fn_validar_apto_titulacion(m.cod_ins_matricula) val
    WHERE m.id_ins_grupo = p_id_grupo
      AND m.estado_matricula != 'ELIMINADO'
    ORDER BY val.apto_titular DESC, val.promedio_general DESC;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_generar_hash_verificacion()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_datos_hash TEXT;
BEGIN
  -- Generar hash con datos del certificado
  v_datos_hash := NEW.numero_certificado ||
                  NEW.id_prs_persona::TEXT ||
                  NEW.id_aca_certificacion_programa::TEXT ||
                  NEW.fecha_emision::TEXT;

  -- Generar hash MD5
  NEW.hash_verificacion := MD5(v_datos_hash);

  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_generar_numero_certificado()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_anio VARCHAR(4);
  v_consecutivo INTEGER;
  v_numero_certificado VARCHAR(50);
BEGIN
  -- Si ya tiene número, no hacer nada
  IF NEW.numero_certificado IS NOT NULL AND NEW.numero_certificado != '' THEN
    RETURN NEW;
  END IF;

  v_anio := EXTRACT(YEAR FROM CURRENT_DATE)::VARCHAR;

  -- Obtener último consecutivo del año
  SELECT COALESCE(MAX(
    CAST(SUBSTRING(numero_certificado FROM '[0-9]+$') AS INTEGER)
  ), 0) + 1
  INTO v_consecutivo
  FROM aca_certificado_emitido
  WHERE numero_certificado LIKE 'CERT-' || v_anio || '-%';

  -- Generar número con formato: CERT-2025-00001
  v_numero_certificado := 'CERT-' || v_anio || '-' || LPAD(v_consecutivo::TEXT, 5, '0');

  NEW.numero_certificado := v_numero_certificado;

  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_generar_obligaciones_pago_matricula_regular(p_cod_matricula integer, p_id_grupo integer, p_user_reg integer, p_id_parametro_descuento integer DEFAULT NULL::integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_programa_aprobado INTEGER;
  rec_concepto RECORD;
  v_descuento_porcentaje DECIMAL := 0;
  v_monto_con_descuento DECIMAL;
BEGIN
  SELECT id_aca_programa_aprobado INTO v_id_programa_aprobado
  FROM ins_grupo WHERE id_ins_grupo = p_id_grupo;

  -- Obtener porcentaje de descuento si aplica
  IF p_id_parametro_descuento IS NOT NULL THEN
    SELECT CAST(REPLACE(valor, '%', '') AS DECIMAL) INTO v_descuento_porcentaje
    FROM aca_parametro_programa
    WHERE id_aca_parametro = p_id_parametro_descuento
      AND estado_parametro_programa != 'ELIMINADO';
  END IF;

  -- Generar obligaciones de conceptos
  FOR rec_concepto IN
    SELECT * FROM fn_obtener_conceptos_pago_programa_aprobado(v_id_programa_aprobado)
    LOOP
      -- SKIP certificado en REGULARES
      IF rec_concepto.id_fin_concepto_pago = 3 THEN
        -- Para REGULARES: certificado gratuito
        INSERT INTO fin_obligacion_pago(
          cod_ins_matricula, id_fin_concepto_pago, deuda_sin_descuento,
          deuda_con_descuento, saldo_pendiente, estado_obligacion_pago,
          observacion, fecha_reg, user_reg
        ) VALUES (
                   p_cod_matricula, 3, 0.00, 0.00, 0.00, 'PAGADO',
                   'Primera impresión gratuita - Estudiante Regular', NOW(), p_user_reg
                 );
        CONTINUE; -- Saltar al siguiente concepto
      END IF;

      -- Calcular descuento para matrícula/colegiatura
      v_monto_con_descuento := rec_concepto.monto_aplicar;
      IF v_descuento_porcentaje > 0 THEN
        v_monto_con_descuento := rec_concepto.monto_aplicar - (rec_concepto.monto_aplicar * v_descuento_porcentaje / 100);
      END IF;

      INSERT INTO fin_obligacion_pago(
        cod_ins_matricula, id_fin_concepto_pago, id_aca_parametro,
        deuda_sin_descuento, deuda_con_descuento, saldo_pendiente,
        estado_obligacion_pago, fecha_reg, user_reg
      ) VALUES (
                 p_cod_matricula, rec_concepto.id_fin_concepto_pago, p_id_parametro_descuento,
                 rec_concepto.monto_aplicar, v_monto_con_descuento, v_monto_con_descuento,
                 'PENDIENTE', NOW(), p_user_reg
               );
    END LOOP;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_generar_programaciones_matricula_regular(p_cod_matricula integer, p_id_grupo integer, p_user_reg integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  rec_cronograma RECORD;
BEGIN
  FOR rec_cronograma IN
    SELECT id_eje_cronograma_modulo
    FROM eje_cronograma_modulo
    WHERE id_ins_grupo = p_id_grupo
      AND estado_cronograma_modulo != 'ELIMINADO'
    LOOP
      INSERT INTO eje_programacion(cod_ins_matricula, id_eje_cronograma_modulo, fecha_programacion,
                                   estado_programacion, fecha_reg, user_reg)
      VALUES (p_cod_matricula, rec_cronograma.id_eje_cronograma_modulo, CURRENT_DATE,
              'PENDIENTE', NOW(), p_user_reg);
    END LOOP;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_gestionar_persona_preinscripcion(p_nombre character varying, p_ap_paterno character varying, p_ap_materno character varying, p_ci character varying, p_nro_celular character varying, p_correo character varying, p_fecha_nacimiento date, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_log_cambio_calificacion()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF TG_OP = 'UPDATE' AND OLD.nota IS DISTINCT FROM NEW.nota THEN
    INSERT INTO eje_log_calificacion (
      id_eje_calificacion,
      accion,
      nota_anterior,
      nota_nueva,
      usuario_cambio,
      observacion
    ) VALUES (
      NEW.id_eje_calificacion,
      'UPDATE',
      OLD.nota,
      NEW.nota,
      NEW.user_mod,
      'Cambio de nota'
    );
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO eje_log_calificacion (
      id_eje_calificacion,
      accion,
      nota_nueva,
      usuario_cambio,
      observacion
    ) VALUES (
      NEW.id_eje_calificacion,
      'INSERT',
      NEW.nota,
      NEW.user_reg,
      'Nota inicial'
    );
  END IF;

  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_matricular_preinscrito_completo(p_id_ins_preinscripcion integer, p_id_ins_grupo integer, p_user_reg integer, p_id_parametro_descuento integer DEFAULT NULL::integer)
 RETURNS TABLE(cod_matricula integer, ci character varying, password_temporal character varying, id_usuario integer, usuario_existia boolean, mensaje text)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_persona INTEGER;
  v_id_programa_aprobado INTEGER;
  v_existe_preinscripcion INTEGER;
  v_existe_grupo INTEGER;
  v_grupo_programa_id INTEGER;
  v_ya_matriculado INTEGER;
  v_cod_matricula INTEGER;
  v_id_usuario INTEGER;
  v_nombre_completo TEXT;
  v_nombre_grupo VARCHAR(100);
  v_ci VARCHAR(20);
  v_password_temporal VARCHAR(50);
  v_usuario_existia BOOLEAN := FALSE;
BEGIN
  -- Validaciones obligatorias
  IF p_id_ins_preinscripcion IS NULL OR p_id_ins_grupo IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Todos los parámetros son obligatorios';
  END IF;

  -- Verificar preinscripción y obtener datos
  SELECT COUNT(*), MAX(pre.id_prs_persona), MAX(pre.id_aca_programa_aprobado),
         MAX(p.ci), MAX(CONCAT(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, '')))
  INTO v_existe_preinscripcion, v_id_persona, v_id_programa_aprobado, v_ci, v_nombre_completo
  FROM ins_preinscripcion pre
         INNER JOIN prs_persona p ON pre.id_prs_persona = p.id_prs_persona
  WHERE pre.id_ins_preinscripcion = p_id_ins_preinscripcion
    AND pre.estado_preinscripcion != 'ELIMINADO'
    AND p.estado_persona != 'ELIMINADO';

  IF v_existe_preinscripcion = 0 THEN
    RAISE EXCEPTION 'Error! Preinscripción no encontrada o eliminada';
  END IF;

  -- Verificar grupo
  SELECT COUNT(*), MAX(g.id_aca_programa_aprobado), MAX(g.nombre_grupo)
  INTO v_existe_grupo, v_grupo_programa_id, v_nombre_grupo
  FROM ins_grupo g
  WHERE g.id_ins_grupo = p_id_ins_grupo
    AND g.estado_grupo != 'ELIMINADO';

  IF v_existe_grupo = 0 THEN
    RAISE EXCEPTION 'Error! Grupo no encontrado o eliminado';
  END IF;

  -- Verificar coherencia programa-grupo
  IF v_id_programa_aprobado != v_grupo_programa_id THEN
    RAISE EXCEPTION 'Error! El grupo no corresponde al programa de la preinscripción';
  END IF;

  -- Verificar no matriculado previamente
  SELECT COUNT(*)
  INTO v_ya_matriculado
  FROM ins_matricula m
         INNER JOIN ins_grupo g ON m.id_ins_grupo = g.id_ins_grupo
  WHERE m.id_prs_persona = v_id_persona
    AND g.id_aca_programa_aprobado = v_id_programa_aprobado
    AND m.estado_matricula != 'ELIMINADO';

  IF v_ya_matriculado > 0 THEN
    RAISE EXCEPTION 'Error! La persona ya está matriculada en este programa';
  END IF;

  -- Verificar si usuario ya existe
  SELECT id_seg_usuario INTO v_id_usuario
  FROM seg_usuario
  WHERE nombre_usuario = v_ci
    AND estado_usuario != 'ELIMINADO';

  IF v_id_usuario IS NOT NULL THEN
    -- Usuario ya existe
    v_usuario_existia := TRUE;
    v_password_temporal := NULL;
  ELSE
    -- Crear nuevo usuario temporal
    v_password_temporal := UPPER(TRIM(UNACCENT(SPLIT_PART(v_nombre_completo, ' ', 1)))) || v_ci;

    INSERT INTO seg_usuario(
      nombre_usuario, estado_usuario, fecha_reg, user_reg
    ) VALUES (
               v_ci, 'PENDIENTE', NOW(), p_user_reg
             ) RETURNING id_seg_usuario INTO v_id_usuario;
  END IF;

  -- Crear matrícula
  INSERT INTO ins_matricula(
    id_ins_grupo, id_prs_persona, id_seg_usuario, estado_matricula, tipo_matricula, fecha_reg, user_reg
  ) VALUES (
             p_id_ins_grupo, v_id_persona, v_id_usuario, 'EN EJECUCION', 'REGULAR', NOW(), p_user_reg
           ) RETURNING cod_ins_matricula INTO v_cod_matricula;

  -- Actualizar preinscripción
  UPDATE ins_preinscripcion
  SET estado_preinscripcion = 'MATRICULADO', fecha_mod = NOW(), user_mod = p_user_reg
  WHERE id_ins_preinscripcion = p_id_ins_preinscripcion;

  PERFORM fn_generar_obligaciones_pago_matricula_regular(v_cod_matricula, p_id_ins_grupo, p_user_reg, p_id_parametro_descuento);
  RETURN QUERY SELECT v_cod_matricula, v_ci, v_password_temporal, v_id_usuario, v_usuario_existia,
                      CONCAT('Matrícula exitosa - Código: ', v_cod_matricula)::TEXT;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_aca_modulo(p_id_aca_modulo integer, p_nombre_modulo character varying, p_estado_modulo character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_aca_nivel(p_id_aca_nivel integer, p_nombre_nivel character varying, p_estado_nivel character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_aca_plan_estudio(p_id_aca_plan_estudio integer, p_anho integer, p_vigente boolean, p_estado_plan_estudio character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_aca_programa(p_id_aca_programa integer, p_id_aca_area integer, p_nombre_programa character varying, p_sigla character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_aca_version(p_id_aca_version integer, p_cod_version character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_area(p_id_aca_area integer, p_nombre_area character varying, p_estado_area character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_criterio_evaluacion(p_id_eje_criterio_eval integer, p_nombre_crit character varying, p_descripcion character varying, p_ponderacion integer, p_orden integer, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_criterio_existe INTEGER;
  v_id_cronograma INTEGER;
  v_hay_calificaciones INTEGER;
  v_orden_existe INTEGER;
  v_total_ponderacion INTEGER;
BEGIN
  -- Validar criterio existe y obtener cronograma
  SELECT COUNT(*), MAX(id_eje_cronograma_modulo) INTO v_criterio_existe, v_id_cronograma
  FROM eje_criterio_eval
  WHERE id_eje_criterio_eval = p_id_eje_criterio_eval
    AND estado_criterio_eval != 'ELIMINADO';

  IF v_criterio_existe = 0 THEN
    RAISE EXCEPTION 'Error! Criterio no encontrado';
  END IF;

  -- Verificar calificaciones
  SELECT COUNT(*) INTO v_hay_calificaciones
  FROM eje_calificacion
  WHERE id_eje_criterio_eval = p_id_eje_criterio_eval
    AND estado_calificacion != 'ELIMINADO';

  IF v_hay_calificaciones > 0 THEN
    RAISE EXCEPTION 'Error! No se puede modificar criterio con calificaciones';
  END IF;

  -- Validar orden único (excluyendo actual)
  SELECT COUNT(*) INTO v_orden_existe
  FROM eje_criterio_eval
  WHERE id_eje_cronograma_modulo = v_id_cronograma
    AND orden = p_orden
    AND id_eje_criterio_eval != p_id_eje_criterio_eval
    AND estado_criterio_eval != 'ELIMINADO';

  IF v_orden_existe > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe un criterio con ese orden';
  END IF;

  -- Validar ponderación total
  SELECT COALESCE(SUM(ponderacion), 0) INTO v_total_ponderacion
  FROM eje_criterio_eval
  WHERE id_eje_cronograma_modulo = v_id_cronograma
    AND id_eje_criterio_eval != p_id_eje_criterio_eval
    AND estado_criterio_eval != 'ELIMINADO';

  IF v_total_ponderacion + p_ponderacion > 100 THEN
    RAISE EXCEPTION 'Error! La ponderación total excedería 100%%';
  END IF;

  -- Actualizar
  UPDATE eje_criterio_eval
  SET nombre_crit = p_nombre_crit,
      descripcion = p_descripcion,
      ponderacion = p_ponderacion,
      orden = p_orden,
      fecha_mod = NOW(),
      user_mod = p_user_mod
  WHERE id_eje_criterio_eval = p_id_eje_criterio_eval;

  RETURN 'Criterio modificado exitosamente';
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_cronograma_modulo(p_id_eje_cronograma_modulo integer, p_id_prs_persona integer, p_fecha_inicio date, p_fecha_fin date, p_user_mod integer)
 RETURNS TABLE(mensaje text, id_usuario integer, password_temporal character varying, usuario_existia boolean, ci_persona character varying)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_cronograma_existe INTEGER;
  v_id_eje_docente INTEGER;
  v_persona_existe INTEGER;
  v_id_usuario INTEGER;
  v_rol_asignado INTEGER;
  v_ci_persona VARCHAR(20);
  v_nombre_completo VARCHAR(200);
  v_password_temporal VARCHAR(50);
  v_usuario_existia BOOLEAN := FALSE;
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
    RAISE EXCEPTION 'Error! Cronograma no existe';
  END IF;

  -- Procesar docente si se especifica persona
  IF p_id_prs_persona IS NOT NULL THEN
    -- Verificar persona existe y obtener datos
    SELECT COUNT(*), MAX(ci), MAX(CONCAT(nombre, ' ', ap_paterno, ' ', COALESCE(ap_materno, '')))
    INTO v_persona_existe, v_ci_persona, v_nombre_completo
    FROM prs_persona
    WHERE id_prs_persona = p_id_prs_persona
      AND estado_persona != 'ELIMINADO';

    IF v_persona_existe = 0 THEN
      RAISE EXCEPTION 'Error! La persona no existe o está eliminada';
    END IF;

    -- Buscar si ya es docente
    SELECT id_eje_docente, id_seg_usuario INTO v_id_eje_docente, v_id_usuario
    FROM eje_docente
    WHERE id_prs_persona = p_id_prs_persona
      AND estado_docente != 'ELIMINADO';

    -- Si no es docente, crearlo con usuario temporal
    IF v_id_eje_docente IS NULL THEN
      -- Verificar si ya existe usuario con este CI
      SELECT id_seg_usuario INTO v_id_usuario
      FROM seg_usuario
      WHERE nombre_usuario = v_ci_persona
        AND estado_usuario != 'ELIMINADO';

      IF v_id_usuario IS NOT NULL THEN
        -- Usuario ya existe
        v_usuario_existia := TRUE;
        v_password_temporal := NULL;
      ELSE
        -- Crear contraseña temporal similar al patrón de matrícula
        v_password_temporal := UPPER(TRIM(UNACCENT(SPLIT_PART(v_nombre_completo, ' ', 1)))) || v_ci_persona;

        -- Crear usuario temporal (sin hash, Spring Boot lo manejará)
        INSERT INTO seg_usuario(nombre_usuario, estado_usuario, fecha_reg, user_reg)
        VALUES (v_ci_persona, 'PENDIENTE', NOW(), p_user_mod)
        RETURNING id_seg_usuario INTO v_id_usuario;
      END IF;

      -- Crear docente
      INSERT INTO eje_docente(id_prs_persona, id_seg_usuario, estado_docente, fecha_reg, user_reg)
      VALUES (p_id_prs_persona, v_id_usuario, 'ACTIVO', NOW(), p_user_mod)
      RETURNING id_eje_docente INTO v_id_eje_docente;

    ELSE
      -- Docente ya existe
      v_usuario_existia := TRUE;
      v_password_temporal := NULL;
    END IF;

    -- Asignar rol DOCENTE si no lo tiene
    IF NOT v_usuario_existia THEN
      SELECT COUNT(*) INTO v_rol_asignado
      FROM seg_ocupa
      WHERE id_seg_usuario = v_id_usuario
        AND id_seg_rol = 4
        AND estado_ocupa != 'ELIMINADO';

      IF v_rol_asignado = 0 THEN
        INSERT INTO seg_ocupa(id_seg_rol, id_seg_usuario, estado_ocupa, fecha_reg, user_reg)
        VALUES (4, v_id_usuario, 'ACTIVO', NOW(), p_user_mod);
      END IF;

      -- Asignar tareas de docente
      FOR rec_tarea IN
        SELECT id_seg_tarea
        FROM seg_tarea
        WHERE id_seg_rol = 4
          AND estado_tarea != 'ELIMINADO'
        LOOP
          INSERT INTO seg_designa(id_seg_tarea, id_seg_usuario, estado_designa, fecha_reg, user_reg)
          VALUES (rec_tarea.id_seg_tarea, v_id_usuario, 'ACTIVO', NOW(), p_user_mod)
          ON CONFLICT (id_seg_tarea, id_seg_usuario) DO NOTHING;
        END LOOP;
    END IF;
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

  -- Retornar información para Spring Boot
  RETURN QUERY SELECT
                 CONCAT('Cronograma actualizado exitosamente con ID: ', p_id_eje_cronograma_modulo)::TEXT,
                 v_id_usuario,
                 v_password_temporal,
                 v_usuario_existia,
                 v_ci_persona;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_fin_concepto_pago(p_id_fin_concepto_pago integer, p_nombre_concepto character varying, p_descripcion text, p_estado_concepto_pago character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_grupo(p_id_ins_grupo integer, p_nombre_grupo character varying, p_fecha_inicio_inscripcion date, p_fecha_fin_inscripcion date, p_estado_grupo character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_modalidad(p_id_aca_modalidad integer, p_nombre_modalidad character varying, p_estado_modalidad character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_parametro_programa(p_id_parametro integer, p_nombre_param character varying DEFAULT NULL::character varying, p_valor text DEFAULT NULL::text, p_tipo_dato_param character varying DEFAULT NULL::character varying, p_fecha_inicio_vigencia date DEFAULT NULL::date, p_fecha_fin_vigencia date DEFAULT NULL::date, p_orden integer DEFAULT NULL::integer, p_estado character varying DEFAULT NULL::character varying, p_user_mod integer DEFAULT 1)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
BEGIN
  -- Verificar que el parámetro existe
  IF NOT EXISTS(
    SELECT 1 FROM aca_parametro_programa
    WHERE id_aca_parametro = p_id_parametro
      AND estado_parametro_programa != 'ELIMINADO'
  ) THEN
    RAISE EXCEPTION 'El parámetro ID % no existe', p_id_parametro;
  END IF;

  UPDATE aca_parametro_programa
  SET
    nombre_param = COALESCE(p_nombre_param, nombre_param),
    valor = COALESCE(p_valor, valor),
    tipo_dato_param = COALESCE(p_tipo_dato_param, tipo_dato_param),
    fecha_inicio_vigencia = COALESCE(p_fecha_inicio_vigencia, fecha_inicio_vigencia),
    fecha_fin_vigencia = COALESCE(p_fecha_fin_vigencia, fecha_fin_vigencia),
    orden = COALESCE(p_orden, orden),
    estado_parametro_programa = COALESCE(p_estado, estado_parametro_programa),
    fecha_mod = NOW(),
    user_mod = p_user_mod
  WHERE id_aca_parametro = p_id_parametro;

  RETURN TRUE;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_persona(p_id_prs_persona integer, p_nombre character varying, p_ap_paterno character varying, p_ap_materno character varying, p_ci character varying, p_nro_celular character varying, p_correo character varying, p_fecha_nacimiento date, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare
  v_persona_existe integer;
  v_existen_ci integer;
  v_filas_afectadas integer;
begin
  -- Validaciones si uno es null entonces chau, nos salimos de la funchion
  if p_id_prs_persona is null or p_nombre is null or p_ap_paterno is null or p_ap_materno is null
    or p_ci is null or p_nro_celular is null or p_correo is null
    or p_fecha_nacimiento is null or p_user_mod is null then
    raise exception 'Error! Todos los campos deben ser completados';
  end if;

  -- Validar que la persona exista con el identificador
  select count(*) into v_persona_existe from prs_persona
  where id_prs_persona = p_id_prs_persona and estado_persona = 'ACTIVO';

  if (v_persona_existe = 0) then
    raise exception 'Error! La persona no existe o no está activa';
  end if;

  -- Validar qel CI no este siendo duplicado (menos de la persona actual)
  select count(*) into v_existen_ci from prs_persona
  where ci = p_ci and estado_persona = 'ACTIVO' and id_prs_persona != p_id_prs_persona;

  if (v_existen_ci > 0) then
    raise exception 'Error! Ya existe otra persona registrada con este CI';
  end if;

  -- Validación de fechas de nacimiento
  if p_fecha_nacimiento > current_date then
    raise exception 'Error! La fecha de nacimiento no puede ser posterior al día de hoy';
  end if;

  if (p_fecha_nacimiento > (current_date - interval '4 years')) then
    raise exception 'Error! La persona debe tener al menos 4 años';
  end if;


  update prs_persona
  set
    nombre = upper(trim(p_nombre)),
    ap_paterno = upper(trim(p_ap_paterno)),
    ap_materno = upper(trim(p_ap_materno)),
    ci = upper(trim(p_ci)),
    nro_celular = trim(p_nro_celular),
    correo = trim(p_correo),
    fecha_nacimiento = p_fecha_nacimiento,
    fecha_mod = now(),
    user_mod = p_user_mod
  where id_prs_persona = p_id_prs_persona
    and estado_persona = 'ACTIVO';

  return concat('Persona modificada exitosamente con ID: ' || p_id_prs_persona);
end;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_plan_modulo_detalle(p_id_aca_plan_modulo_detalle integer, p_id_aca_plan_estudio integer, p_id_aca_modulo integer, p_id_aca_nivel integer, p_carga_horaria integer, p_creditos numeric, p_orden integer, p_competencia text, p_estado_plan_modulo_detalle character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_programa_aprobado(p_id_aca_programa_aprobado integer, p_id_aca_programa integer, p_id_aca_modalidad integer, p_gestion integer, p_id_aca_plan_estudio integer, p_id_aca_version integer, p_estado_programa_aprobado character varying, p_precio_matricula numeric, p_precio_colegiatura numeric, p_precio_titulacion numeric, p_fecha_inicio_vigencia date, p_fecha_fin_vigencia date, p_cod_certificado_ceub character varying, p_cod_sigla_version character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_seg_rol(p_id_seg_rol integer, p_nombre_rol character varying, p_descripcion text, p_estado_rol character varying, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_modificar_seg_tarea(p_id_seg_tarea integer, p_id_seg_rol integer, p_nombre_tarea character varying, p_descripcion text, p_user_mod integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_obligaciones_por_matricula(p_cod_matricula integer)
 RETURNS TABLE(id_prs_persona integer, nombre character varying, ap_paterno character varying, ap_materno character varying, ci character varying, nro_celular character varying, correo character varying, cod_ins_matricula integer, tipo_matricula character varying, estado_matricula character varying, id_fin_obligacion_pago integer, nombre_concepto character varying, deuda_sin_descuento numeric, deuda_con_descuento numeric, saldo_pendiente numeric, observacion character varying, estado_obligacion_pago character varying, fecha_obligacion timestamp without time zone, nombre_param character varying, valor_parametro text, estado_pago character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      -- Datos de persona
      p.id_prs_persona,
      p.nombre,
      p.ap_paterno,
      p.ap_materno,
      p.ci,
      p.nro_celular,
      p.correo,

      -- Datos de matrícula
      m.cod_ins_matricula,
      m.tipo_matricula,
      m.estado_matricula,

      -- Datos de obligación
      op.id_fin_obligacion_pago,
      cp.nombre_concepto,
      op.deuda_sin_descuento,
      op.deuda_con_descuento,
      op.saldo_pendiente,
      op.observacion,
      op.estado_obligacion_pago,
      op.fecha_reg,

      -- Datos del parámetro si existe
      param.nombre_param,
      param.valor,

      -- Estado calculado
      CASE
        WHEN op.saldo_pendiente = 0 THEN 'PAGADO'
        WHEN op.saldo_pendiente < op.deuda_con_descuento THEN 'PAGO_PARCIAL'
        ELSE 'PENDIENTE'
        END::VARCHAR

    FROM fin_obligacion_pago op
           INNER JOIN ins_matricula m ON op.cod_ins_matricula = m.cod_ins_matricula
           INNER JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
           INNER JOIN fin_concepto_pago cp ON op.id_fin_concepto_pago = cp.id_fin_concepto_pago
           LEFT JOIN aca_parametro_programa param ON op.id_aca_parametro = param.id_aca_parametro

    WHERE m.cod_ins_matricula = p_cod_matricula
      AND op.estado_obligacion_pago != 'ELIMINADO'
      AND m.estado_matricula != 'ELIMINADO'
      AND p.estado_persona != 'ELIMINADO'
      AND cp.estado_concepto_pago != 'ELIMINADO'

    ORDER BY op.fecha_reg;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_obtener_conceptos_pago_programa_aprobado(p_id_programa_aprobado integer)
 RETURNS TABLE(id_fin_concepto_pago integer, nombre_concepto character varying, descripcion text, monto_aplicar numeric)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_precio_matricula DECIMAL;
  v_precio_colegiatura DECIMAL;
  v_precio_titulacion DECIMAL;
BEGIN
  -- Obtener precios del programa aprobado
  SELECT precio_matricula, precio_colegiatura, precio_titulacion
  INTO v_precio_matricula, v_precio_colegiatura, v_precio_titulacion
  FROM aca_programa_aprobado
  WHERE id_aca_programa_aprobado = p_id_programa_aprobado
    AND estado_programa_aprobado != 'ELIMINADO';

  -- Validar que existe el programa
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Programa aprobado con ID % no encontrado', p_id_programa_aprobado;
  END IF;

  -- Aplicar lógica de conceptos (igual que antes)
  IF v_precio_matricula > 0 AND v_precio_colegiatura > 0 THEN
    -- MATRICULA UNICA + COLEGIATURA
    RETURN QUERY
      SELECT fp.id_fin_concepto_pago, fp.nombre_concepto, fp.descripcion, v_precio_matricula
      FROM vista_fin_conceptos_pago_activos fp WHERE fp.id_fin_concepto_pago = 4;

    RETURN QUERY
      SELECT fp.id_fin_concepto_pago, fp.nombre_concepto, fp.descripcion, v_precio_colegiatura
      FROM vista_fin_conceptos_pago_activos fp WHERE fp.id_fin_concepto_pago = 2;

  ELSIF v_precio_matricula > 0 THEN
    -- MATRICULA SEMESTRAL
    RETURN QUERY
      SELECT fp.id_fin_concepto_pago, fp.nombre_concepto, fp.descripcion, v_precio_matricula
      FROM vista_fin_conceptos_pago_activos fp WHERE fp.id_fin_concepto_pago = 1;

  ELSIF v_precio_colegiatura > 0 THEN
    -- COLEGIATURA COMPLETA
    RETURN QUERY
      SELECT fp.id_fin_concepto_pago, fp.nombre_concepto, fp.descripcion, v_precio_colegiatura
      FROM vista_fin_conceptos_pago_activos fp WHERE fp.id_fin_concepto_pago = 2;
  END IF;

  -- Titulación adicional
  IF v_precio_titulacion > 0 THEN
    RETURN QUERY
      SELECT fp.id_fin_concepto_pago, fp.nombre_concepto, fp.descripcion, v_precio_titulacion
      FROM vista_fin_conceptos_pago_activos fp WHERE fp.id_fin_concepto_pago = 3;
  END IF;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_obtener_grupos_programa(p_id_aca_programa_aprobado integer)
 RETURNS TABLE(id_ins_grupo integer, nombre_grupo character varying, estado_inscripcion text, total_matriculados bigint, fecha_inicio_inscripcion date, fecha_fin_inscripcion date)
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF p_id_aca_programa_aprobado IS NULL THEN
    RAISE EXCEPTION 'Error! El ID del programa aprobado es requerido';
  END IF;

  RETURN QUERY
    SELECT
      v.id_ins_grupo,
      v.nombre_grupo,
      v.estado_inscripcion,
      v.total_matriculados,
      v.fecha_inicio_inscripcion,
      v.fecha_fin_inscripcion
    FROM vista_grupos_matriculacion v
    WHERE v.id_aca_programa_aprobado = p_id_aca_programa_aprobado
    ORDER BY v.estado_inscripcion DESC, v.nombre_grupo;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_obtener_parametros_programa(p_id_programa_aprobado integer, p_tipo_dato_param character varying DEFAULT NULL::character varying, p_solo_vigentes boolean DEFAULT true)
 RETURNS TABLE(id_parametro integer, nombre_param character varying, valor text, tipo_dato_param character varying, fecha_inicio_vigencia date, fecha_fin_vigencia date, orden integer, estado character varying, vigente boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      app.id_aca_parametro,
      app.nombre_param,
      app.valor,
      app.tipo_dato_param,
      app.fecha_inicio_vigencia,
      app.fecha_fin_vigencia,
      app.orden,
      app.estado_parametro_programa,
      CASE
        WHEN (app.fecha_inicio_vigencia IS NULL OR app.fecha_inicio_vigencia <= CURRENT_DATE)
          AND (app.fecha_fin_vigencia IS NULL OR app.fecha_fin_vigencia >= CURRENT_DATE)
          THEN TRUE
        ELSE FALSE
        END as vigente
    FROM aca_parametro_programa app
    WHERE app.id_aca_programa_aprobado = p_id_programa_aprobado
      AND app.estado_parametro_programa != 'ELIMINADO'
      AND (p_tipo_dato_param IS NULL OR app.tipo_dato_param = p_tipo_dato_param)
      AND (
      NOT p_solo_vigentes
        OR (
        (app.fecha_inicio_vigencia IS NULL OR app.fecha_inicio_vigencia <= CURRENT_DATE)
          AND (app.fecha_fin_vigencia IS NULL OR app.fecha_fin_vigencia >= CURRENT_DATE)
        )
      )
    ORDER BY app.orden, app.nombre_param;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_obtener_plan_estudio_programa_aprobado(p_id_aca_programa_aprobado integer)
 RETURNS TABLE(nivel character varying, orden integer, sigla text, nombre_modulo character varying, carga_horaria integer, creditos numeric, competencia text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      niv.nombre_nivel,
      pmd.orden,
      CASE
        WHEN COALESCE(pa.cod_sigla_version, p.sigla) ~ '^[A-Z]+ [0-9]+$' THEN
          TRIM(SPLIT_PART(COALESCE(pa.cod_sigla_version, p.sigla), ' ', 1)) || ' ' ||
          (SPLIT_PART(COALESCE(pa.cod_sigla_version, p.sigla), ' ', 2)::INTEGER + pmd.orden)::TEXT
        ELSE
          UPPER(REGEXP_REPLACE(COALESCE(pa.cod_sigla_version, p.sigla, ''), '[^A-Za-z]', '', 'g')) || ' ' ||
          (100 + pmd.orden)::TEXT
        END AS sigla,
      mod.nombre_modulo,
      pmd.carga_horaria,
      pmd.creditos,
      pmd.competencia
    FROM aca_programa_aprobado pa
           INNER JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
           INNER JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
           INNER JOIN aca_plan_modulo_detalle pmd ON pe.id_aca_plan_estudio = pmd.id_aca_plan_estudio
           INNER JOIN aca_modulo mod ON pmd.id_aca_modulo = mod.id_aca_modulo
           INNER JOIN aca_nivel niv ON pmd.id_aca_nivel = niv.id_aca_nivel
    WHERE pa.id_aca_programa_aprobado = p_id_aca_programa_aprobado
      AND pa.estado_programa_aprobado != 'ELIMINADO'
      AND pe.estado_plan_estudio != 'ELIMINADO'
      AND pmd.estado_plan_modulo_detalle != 'ELIMINADO'
      AND mod.estado_modulo != 'ELIMINADO'
      AND niv.estado_nivel != 'ELIMINADO'
    ORDER BY niv.nombre_nivel, pmd.orden;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_obtener_preinscritos_programa(p_id_aca_programa_aprobado integer)
 RETURNS TABLE(id_ins_preinscripcion integer, id_prs_persona integer, nombre_completo text, nombre character varying, ap_paterno character varying, ap_materno character varying, ci character varying, fecha_nacimiento date, nro_celular character varying, correo character varying, edad double precision, fecha_preinscripcion timestamp without time zone, estado_matriculacion text, nombre_grupo character varying, fecha_matriculacion timestamp without time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF p_id_aca_programa_aprobado IS NULL THEN
    RAISE EXCEPTION 'Error! El ID del programa aprobado es requerido';
  END IF;

  RETURN QUERY
    SELECT
      v.id_ins_preinscripcion,
      v.id_prs_persona,
      v.nombre_completo,
      v.nombre,
      v.ap_paterno,
      v.ap_materno,
      v.ci,
      v.fecha_nacimiento,
      v.nro_celular,
      v.correo,
      v.edad,
      v.fecha_preinscripcion,
      v.estado_matriculacion,
      v.nombre_grupo,
      v.fecha_matriculacion
    FROM vista_preinscritos_programa v
    WHERE v.id_aca_programa_aprobado = p_id_aca_programa_aprobado
    ORDER BY
      CASE v.estado_matriculacion
        WHEN 'NO MATRICULADO' THEN 1
        ELSE 2
        END,
      v.fecha_preinscripcion ASC;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_obtener_programaciones_estudiante(p_cod_matricula integer)
 RETURNS TABLE(id_eje_programacion integer, cod_ins_matricula integer, id_eje_cronograma_modulo integer, sigla character varying, nombre_modulo character varying, fecha_programacion date, estado_programacion character varying, nota_final integer, observacion character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      prog.id_eje_programacion,
      prog.cod_ins_matricula,
      prog.id_eje_cronograma_modulo,
      pmd.sigla,
      mod.nombre_modulo,
      prog.fecha_programacion,
      prog.estado_programacion,
      prog.nota_final,
      prog.observacion
    FROM eje_programacion prog
           JOIN eje_cronograma_modulo cm ON prog.id_eje_cronograma_modulo = cm.id_eje_cronograma_modulo
           JOIN aca_plan_modulo_detalle pmd ON cm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle
           JOIN aca_modulo mod ON pmd.id_aca_modulo = mod.id_aca_modulo
    WHERE prog.cod_ins_matricula = p_cod_matricula
      AND prog.estado_programacion != 'ELIMINADO'
    ORDER BY pmd.orden;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_prevenir_eliminacion_fisica()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  RAISE EXCEPTION 'No se permite eliminación física. Use eliminación lógica (estado = ELIMINADO)';
  RETURN NULL;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_aca_modulo(p_nombre_modulo character varying, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_aca_nivel(p_nombre_nivel character varying, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_aca_plan_estudio(p_anho integer, p_vigente boolean, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_aca_programa(p_id_aca_area integer, p_nombre_programa character varying, p_sigla character varying, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_aca_version(p_cod_version character varying, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_area(p_nombre_area character varying, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_calificacion(p_id_eje_programacion integer, p_id_eje_criterio_eval integer, p_nota numeric, p_user_reg integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_calificacion INTEGER;
  v_ponderacion INTEGER;
  v_nota_ponderada DECIMAL(5,2);
BEGIN
  -- Validar que la programación existe
  IF NOT EXISTS (SELECT 1 FROM eje_programacion WHERE id_eje_programacion = p_id_eje_programacion AND estado_programacion != 'ELIMINADO') THEN
    RAISE EXCEPTION 'La programación especificada no existe';
  END IF;

  -- Validar que el criterio existe
  SELECT ponderacion INTO v_ponderacion
  FROM eje_criterio_eval
  WHERE id_eje_criterio_eval = p_id_eje_criterio_eval AND estado_criterio_eval != 'ELIMINADO';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'El criterio de evaluación no existe';
  END IF;

  -- Validar nota (0-100)
  IF p_nota < 0 OR p_nota > 100 THEN
    RAISE EXCEPTION 'La nota debe estar entre 0 y 100';
  END IF;

  -- Calcular nota ponderada
  v_nota_ponderada := (p_nota * v_ponderacion) / 100.0;

  -- Verificar si ya existe calificación
  SELECT id_eje_calificacion INTO v_id_calificacion
  FROM eje_calificacion
  WHERE id_eje_programacion = p_id_eje_programacion
    AND id_eje_criterio_eval = p_id_eje_criterio_eval;

  IF v_id_calificacion IS NOT NULL THEN
    -- Actualizar calificación existente
    UPDATE eje_calificacion SET
                              nota = p_nota,
                              nota_ponderada = v_nota_ponderada,
                              fecha_mod = NOW(),
                              user_mod = p_user_reg
    WHERE id_eje_calificacion = v_id_calificacion;
  ELSE
    -- Insertar nueva calificación
    INSERT INTO eje_calificacion (
      id_eje_programacion, id_eje_criterio_eval, nota, nota_ponderada,
      estado_calificacion, fecha_reg, user_reg
    ) VALUES (
               p_id_eje_programacion, p_id_eje_criterio_eval, p_nota, v_nota_ponderada,
               'ACTIVO', NOW(), p_user_reg
             ) RETURNING id_eje_calificacion INTO v_id_calificacion;
  END IF;

  -- Actualizar nota final en programación
  PERFORM fn_calcular_nota_final_programacion(p_id_eje_programacion);

  RETURN v_id_calificacion;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_calificacion_cronograma(p_id_eje_programacion integer, p_id_eje_criterio_eval integer, p_nota numeric, p_user_reg integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_calificacion INTEGER;
  v_ponderacion INTEGER;
  v_nota_ponderada DECIMAL(5,2);
  v_cronograma_programacion INTEGER;
  v_cronograma_criterio INTEGER;
BEGIN
  -- Validar que la programación existe
  SELECT id_eje_cronograma_modulo INTO v_cronograma_programacion
  FROM eje_programacion
  WHERE id_eje_programacion = p_id_eje_programacion
    AND estado_programacion != 'ELIMINADO';

  IF v_cronograma_programacion IS NULL THEN
    RAISE EXCEPTION 'La programación especificada no existe';
  END IF;

  -- Validar que el criterio existe y obtener ponderación
  SELECT ponderacion, id_eje_cronograma_modulo
  INTO v_ponderacion, v_cronograma_criterio
  FROM eje_criterio_eval
  WHERE id_eje_criterio_eval = p_id_eje_criterio_eval
    AND estado_criterio_eval != 'ELIMINADO';

  IF v_ponderacion IS NULL THEN
    RAISE EXCEPTION 'El criterio de evaluación no existe';
  END IF;

  -- Validar que el criterio pertenece al mismo cronograma
  IF v_cronograma_programacion != v_cronograma_criterio THEN
    RAISE EXCEPTION 'El criterio no pertenece al cronograma de la programación';
  END IF;

  -- Validar nota (0-100)
  IF p_nota < 0 OR p_nota > 100 THEN
    RAISE EXCEPTION 'La nota debe estar entre 0 y 100';
  END IF;

  -- Calcular nota ponderada
  v_nota_ponderada := ROUND((p_nota * v_ponderacion) / 100.0, 2);

  -- Verificar si ya existe calificación
  SELECT id_eje_calificacion INTO v_id_calificacion
  FROM eje_calificacion
  WHERE id_eje_programacion = p_id_eje_programacion
    AND id_eje_criterio_eval = p_id_eje_criterio_eval
    AND estado_calificacion != 'ELIMINADO';

  IF v_id_calificacion IS NOT NULL THEN
    -- Actualizar calificación existente
    UPDATE eje_calificacion SET
                              nota = p_nota,
                              nota_ponderada = v_nota_ponderada,
                              fecha_mod = NOW(),
                              user_mod = p_user_reg
    WHERE id_eje_calificacion = v_id_calificacion;
  ELSE
    -- Insertar nueva calificación
    INSERT INTO eje_calificacion (
      id_eje_programacion, id_eje_criterio_eval, nota, nota_ponderada,
      estado_calificacion, fecha_reg, user_reg
    ) VALUES (
               p_id_eje_programacion, p_id_eje_criterio_eval, p_nota, v_nota_ponderada,
               'ACTIVO', NOW(), p_user_reg
             ) RETURNING id_eje_calificacion INTO v_id_calificacion;
  END IF;

  -- Actualizar nota final en programación (suma de ponderadas)
  UPDATE eje_programacion
  SET nota_final = (
    SELECT COALESCE(ROUND(SUM(nota_ponderada)), 0)
    FROM eje_calificacion
    WHERE id_eje_programacion = p_id_eje_programacion
      AND estado_calificacion != 'ELIMINADO'
  ),
      fecha_mod = NOW()
  WHERE id_eje_programacion = p_id_eje_programacion;

  RETURN v_id_calificacion;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_criterio_evaluacion(p_id_cronograma integer, p_nombre_crit character varying, p_descripcion character varying, p_ponderacion integer, p_orden integer, p_user_reg integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_cronograma_existe INTEGER;
  v_id_docente INTEGER;
  v_orden_existe INTEGER;
  v_total_ponderacion INTEGER;
  v_nuevo_id INTEGER;
BEGIN
  -- Validar cronograma y obtener docente
  SELECT COUNT(*), MAX(id_eje_docente) INTO v_cronograma_existe, v_id_docente
  FROM eje_cronograma_modulo
  WHERE id_eje_cronograma_modulo = p_id_cronograma
    AND estado_cronograma_modulo != 'ELIMINADO';

  IF v_cronograma_existe = 0 THEN
    RAISE EXCEPTION 'Error! Cronograma no encontrado';
  END IF;

  -- Validar orden único por cronograma
  SELECT COUNT(*) INTO v_orden_existe
  FROM eje_criterio_eval
  WHERE id_eje_cronograma_modulo = p_id_cronograma
    AND orden = p_orden
    AND estado_criterio_eval != 'ELIMINADO';

  IF v_orden_existe > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe un criterio con ese orden';
  END IF;

  -- Validar ponderación total ≤ 100
  SELECT COALESCE(SUM(ponderacion), 0) INTO v_total_ponderacion
  FROM eje_criterio_eval
  WHERE id_eje_cronograma_modulo = p_id_cronograma
    AND estado_criterio_eval != 'ELIMINADO';

  IF v_total_ponderacion + p_ponderacion > 100 THEN
    RAISE EXCEPTION 'Error! La ponderación total excedería 100%%';
  END IF;

  -- Insertar criterio
  INSERT INTO eje_criterio_eval(
    id_eje_docente, id_eje_cronograma_modulo, nombre_crit, descripcion,
    ponderacion, orden, estado_criterio_eval, fecha_reg, user_reg
  ) VALUES (
             v_id_docente, p_id_cronograma, p_nombre_crit, p_descripcion,
             p_ponderacion, p_orden, 'ACTIVO', NOW(), p_user_reg
           ) RETURNING id_eje_criterio_eval INTO v_nuevo_id;

  RETURN v_nuevo_id;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_fin_concepto_pago(p_nombre_concepto character varying, p_descripcion text, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_grupo(p_id_aca_programa_aprobado integer, p_nombre_grupo character varying, p_fecha_inicio_inscripcion date, p_fecha_fin_inscripcion date, p_gestion_inicio integer, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_grupo INTEGER;
  v_programa_existe INTEGER;
  v_nombre_existe INTEGER;
  v_estado_calculado VARCHAR(35);
  v_nombre_programa VARCHAR(100);
  --validar si tiene plan de estudio y modulos
  v_id_plan_estudio INTEGER;
  v_n_modulos_asignados INTEGER;
BEGIN
  -- Validaciones obligatorias
  IF p_id_aca_programa_aprobado IS NULL OR p_nombre_grupo IS NULL OR
     p_fecha_inicio_inscripcion IS NULL OR p_gestion_inicio IS NULL OR p_user_reg IS NULL THEN
    RAISE EXCEPTION 'Error! Campos obligatorios faltantes: programa, nombre, fecha inicio, gestión y usuario son requeridos';
  END IF;

  -- Validar programa aprobado activo y obtener nombre
  SELECT COUNT(*), MAX(p.nombre_programa) INTO v_programa_existe, v_nombre_programa
  FROM aca_programa_aprobado pa
         JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
  WHERE pa.id_aca_programa_aprobado = p_id_aca_programa_aprobado
    AND pa.estado_programa_aprobado != 'ELIMINADO'
    AND p.estado_programa != 'ELIMINADO';

  IF v_programa_existe = 0 THEN
    RAISE EXCEPTION 'Error! El programa aprobado con ID % no existe o está inactivo', p_id_aca_programa_aprobado;
  END IF;

  -- Obtener el plan de estudio del programa
  SELECT pa.id_aca_plan_estudio INTO v_id_plan_estudio
  FROM aca_programa_aprobado pa
  JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
  WHERE pa.id_aca_programa_aprobado = p_id_aca_programa_aprobado
    AND pe.vigente = true
    AND pe.estado_plan_estudio = 'ACTIVO';

  IF v_id_plan_estudio IS NULL THEN
    RAISE EXCEPTION 'Error! El programa "%" no tiene un plan de estudio vigente asignado', v_nombre_programa;
  END IF;

  -- Verificar que el plan tenga módulos definidos
  SELECT COUNT(*) INTO v_n_modulos_asignados
  FROM aca_plan_modulo_detalle
  WHERE id_aca_plan_estudio = v_id_plan_estudio
    AND estado_plan_modulo_detalle != 'ELIMINADO';

  IF v_n_modulos_asignados = 0 THEN
    RAISE EXCEPTION 'Error! El plan de estudio del programa "%" no tiene módulos definidos', v_nombre_programa;
  END IF;

  -- Validar nombre único por programa específico
  SELECT COUNT(*) INTO v_nombre_existe
  FROM ins_grupo
  WHERE UPPER(TRIM(nombre_grupo)) = UPPER(TRIM(p_nombre_grupo))
    AND id_aca_programa_aprobado = p_id_aca_programa_aprobado
    AND estado_grupo != 'ELIMINADO';

  IF v_nombre_existe > 0 THEN
    RAISE EXCEPTION 'Error! Ya existe un grupo activo con el nombre "%" para el programa "%"',
      UPPER(TRIM(p_nombre_grupo)), v_nombre_programa;
  END IF;

  -- Validar fechas
  IF p_fecha_fin_inscripcion IS NOT NULL AND p_fecha_inicio_inscripcion > p_fecha_fin_inscripcion THEN
    RAISE EXCEPTION 'Error! La fecha de inicio (%) no puede ser posterior a la fecha fin (%)',
      p_fecha_inicio_inscripcion, p_fecha_fin_inscripcion;
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_modalidad(p_nombre_modalidad character varying, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_noticia(p_id_aca_unidad integer, p_titulo character varying, p_contenido text, p_imagen_uri character varying, p_enlace_externo character varying, p_fecha_noticia date, p_es_destacada boolean, p_orden_prioridad integer, p_user_reg integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_pago_individual(p_id_obligacion integer, p_monto_pago numeric, p_cod_comprobante character varying, p_tipo_comprobante character varying, p_observacion character varying, p_user_reg integer)
 RETURNS TABLE(id_transaccion integer, id_detalle_pago integer, nuevo_saldo numeric, mensaje character varying)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_transaccion INTEGER;
  v_id_detalle_pago INTEGER;
  v_saldo_actual DECIMAL;
  v_nuevo_saldo DECIMAL;
BEGIN
  -- Validar que la obligación existe y tiene saldo
  SELECT saldo_pendiente INTO v_saldo_actual
  FROM fin_obligacion_pago
  WHERE id_fin_obligacion_pago = p_id_obligacion
    AND estado_obligacion_pago != 'ELIMINADO';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Obligación de pago % no encontrada o eliminada', p_id_obligacion;
  END IF;

  -- Validar monto
  IF p_monto_pago <= 0 THEN
    RAISE EXCEPTION 'El monto de pago debe ser mayor a 0';
  END IF;

  IF p_monto_pago > v_saldo_actual THEN
    RAISE EXCEPTION 'El monto %.2f excede el saldo pendiente %.2f', p_monto_pago, v_saldo_actual;
  END IF;

  -- Crear transacción con todos los campos requeridos
  INSERT INTO fin_transaccion (
    cod_comprobante,
    fecha_pago,
    tipo_comprobante,
    observacion,
    estado_transaccion,
    fecha_reg,
    user_reg,
    total_pago  -- Campo que faltaba
  ) VALUES (
             COALESCE(p_cod_comprobante, 'COMP-' || EXTRACT(EPOCH FROM NOW())::TEXT),
             CURRENT_DATE,
             COALESCE(p_tipo_comprobante, 'EFECTIVO'),
             COALESCE(p_observacion, ''),
             'REGISTRADO',
             CURRENT_TIMESTAMP,
             p_user_reg,
             p_monto_pago  -- Total de la transacción
           ) RETURNING id_fin_transaccion INTO v_id_transaccion;

  -- Crear detalle de pago con todos los campos requeridos
  INSERT INTO fin_detalle_pago (
    id_fin_transaccion,
    id_fin_obligacion_pago,
    monto_pagado,
    estado_detalle_pago,
    fecha_reg,
    user_reg
  ) VALUES (
             v_id_transaccion,
             p_id_obligacion,
             p_monto_pago,
             'REGISTRADO',
             CURRENT_TIMESTAMP,
             p_user_reg
           ) RETURNING id_fin_detalle_pago INTO v_id_detalle_pago;

  -- El trigger se encarga de actualizar el saldo automáticamente
  -- Obtener el nuevo saldo para retornarlo
  SELECT saldo_pendiente INTO v_nuevo_saldo
  FROM fin_obligacion_pago
  WHERE id_fin_obligacion_pago = p_id_obligacion;

  RETURN QUERY SELECT
                 v_id_transaccion,
                 v_id_detalle_pago,
                 v_nuevo_saldo,
                 CAST('Pago registrado exitosamente' AS VARCHAR);

EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Error al procesar el pago: %', SQLERRM;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_parametro_programa(p_id_programa_aprobado integer, p_nombre_param character varying, p_valor text, p_tipo_dato_param character varying, p_fecha_inicio_vigencia date DEFAULT CURRENT_DATE, p_fecha_fin_vigencia date DEFAULT NULL::date, p_orden integer DEFAULT 1, p_user_reg integer DEFAULT 1)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_parametro INT4;
BEGIN
  -- Validar que el programa existe
  IF NOT EXISTS(
    SELECT 1 FROM aca_programa_aprobado
    WHERE id_aca_programa_aprobado = p_id_programa_aprobado
      AND estado_programa_aprobado != 'ELIMINADO'
  ) THEN
    RAISE EXCEPTION 'El programa aprobado ID % no existe', p_id_programa_aprobado;
  END IF;

  -- Validar fechas
  IF p_fecha_fin_vigencia IS NOT NULL AND p_fecha_inicio_vigencia > p_fecha_fin_vigencia THEN
    RAISE EXCEPTION 'La fecha de inicio no puede ser posterior a la fecha de fin';
  END IF;

  INSERT INTO aca_parametro_programa (
    id_aca_programa_aprobado,
    nombre_param,
    valor,
    tipo_dato_param,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    orden,
    estado_parametro_programa,
    fecha_reg,
    user_reg
  ) VALUES (
             p_id_programa_aprobado,
             p_nombre_param,
             p_valor,
             p_tipo_dato_param,
             p_fecha_inicio_vigencia,
             p_fecha_fin_vigencia,
             p_orden,
             'ACTIVO',
             NOW(),
             p_user_reg
           ) RETURNING id_aca_parametro INTO v_id_parametro;

  RETURN v_id_parametro;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_persona(p_nombre character varying, p_ap_paterno character varying, p_ap_materno character varying, p_ci character varying, p_nro_celular character varying, p_correo character varying, p_fecha_nacimiento date, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare
  v_id_persona_registrada integer;
  v_existen               integer;

begin
  --validaciones si uno es null entonces chau, nos salimos de la funcion
  if p_nombre is null or p_ap_paterno is null or p_ap_materno is null
    or p_ci is null or p_nro_celular is null or p_correo is null or p_correo is null
    or p_fecha_nacimiento is null or p_user_reg is null
  then
    raise exception 'Error! Todos los campos deben ser completados';
  end if;

  --luego validar is existe esa persona en la base de datos
  select count(*)
  into v_existen
  from prs_persona
  where ci = p_ci
    and estado_persona = 'ACTIVO';

  if (v_existen > 0) then
    raise exception 'Error! Ya existe una persona registrar con este CI';
  end if;

  --validacion de fechas de nacimiento
  if p_fecha_nacimiento > current_date then
    raise exception 'Error! La fecha de nacimiento no puede ser posterior a dia de hoy';
  end if;

  if (p_fecha_nacimiento > (current_date - interval '4 years')) then
    raise exception 'Error! La persona debe tener al menos 4 años';
  end if;

  --insercion con trims y upper para normalizacion de texto
  insert into prs_persona(nombre, ap_paterno, ap_materno, ci, nro_celular, correo, fecha_nacimiento, estado_persona,
                          fecha_reg, user_reg)
  values (upper(trim(p_nombre)), upper(trim(p_ap_paterno)), upper(trim(p_ap_materno)), upper(trim(p_ci)),
          trim(p_nro_celular), trim(p_correo), p_fecha_nacimiento, 'ACTIVO', now(), p_user_reg)
  returning id_prs_persona
    into v_id_persona_registrada;

  return concat('Persona registrada exitosamente con ID: ' || v_id_persona_registrada);
end;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_plan_modulo_detalle(p_id_aca_plan_estudio integer, p_id_aca_modulo integer, p_id_aca_nivel integer, p_carga_horaria integer, p_creditos numeric, p_orden integer, p_competencia text, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_preinscripcion(p_nombre character varying, p_ap_paterno character varying, p_ap_materno character varying, p_ci character varying, p_nro_celular character varying, p_correo character varying, p_fecha_nacimiento date, p_id_aca_programa_aprobado integer, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_programa_aprobado(p_id_aca_programa integer, p_id_aca_modalidad integer, p_gestion integer, p_id_aca_plan_estudio integer, p_id_aca_version integer, p_estado_programa_aprobado character varying, p_cod_certificado_ceub character varying, p_precio_matricula numeric, p_precio_colegiatura numeric, p_precio_titulacion numeric, p_fecha_inicio_vigencia date, p_fecha_fin_vigencia date, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_seg_rol(p_nombre_rol character varying, p_descripcion text, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_seg_tarea(p_id_seg_rol integer, p_nombre_tarea character varying, p_descripcion text, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_titulacion(p_cod_matricula integer, p_cod_titulo character varying, p_uri_titulo character varying, p_user_reg integer)
 RETURNS TABLE(id_titulacion integer, mensaje character varying, validacion_exitosa boolean)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_titulacion INTEGER;
  v_apto BOOLEAN;
  v_impedimentos TEXT;
BEGIN
  -- Validar que el estudiante puede titular
  SELECT apto_titular, motivos_impedimento
  INTO v_apto, v_impedimentos
  FROM fn_validar_apto_titulacion(p_cod_matricula);

  IF NOT v_apto THEN
    RETURN QUERY SELECT
                   NULL::INTEGER,
                   ('No puede titular: ' || v_impedimentos)::VARCHAR,
                   FALSE;
    RETURN;
  END IF;

  -- Verificar que no esté ya titulado
  IF EXISTS (
    SELECT 1 FROM cer_titulacion
    WHERE cod_ins_matricula = p_cod_matricula
      AND estado_titulacion != 'ELIMINADO'
  ) THEN
    RETURN QUERY SELECT
                   NULL::INTEGER,
                   'El estudiante ya cuenta con titulación registrada'::VARCHAR,
                   FALSE;
    RETURN;
  END IF;

  -- Registrar titulación
  INSERT INTO cer_titulacion (
    cod_ins_matricula,
    cod_titulo,
    uri_titulo,
    estado_titulacion,
    fecha_reg,
    user_reg
  ) VALUES (
             p_cod_matricula,
             p_cod_titulo,
             p_uri_titulo,
             'REGISTRADO',
             CURRENT_TIMESTAMP,
             p_user_reg
           ) RETURNING id_cer_titulacion INTO v_id_titulacion;

  RETURN QUERY SELECT
                 v_id_titulacion,
                 'Titulación registrada exitosamente'::VARCHAR,
                 TRUE;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_registrar_unidad(p_nombre_unidad character varying, p_descripcion text, p_user_reg integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_reporte_acta_detalle(p_id_grupo integer, p_id_modulo integer DEFAULT NULL::integer, p_id_docente integer DEFAULT NULL::integer)
 RETURNS TABLE(cod_matricula integer, ci character varying, nombre_completo character varying, modulo character varying, docente character varying, criterio character varying, ponderacion integer, nota numeric, nota_ponderada numeric, nota_final integer, estado_nota character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      m.cod_ins_matricula,
      p.ci,
      p.nombre || ' ' || p.ap_paterno || COALESCE(' ' || p.ap_materno, '') as nombre_completo,
      mod.nombre_modulo,
      pd.nombre || ' ' || pd.ap_paterno || COALESCE(' ' || pd.ap_materno, '') as docente,
      ce.nombre_crit as criterio,
      ce.ponderacion,
      COALESCE(cal.nota, 0.00) as nota,
      COALESCE(cal.nota_ponderada, 0.00) as nota_ponderada,
      COALESCE(prog.nota_final, 0) as nota_final,
      CASE
        WHEN prog.nota_final >= 70 THEN 'APROBADO'
        WHEN prog.nota_final < 70 AND prog.nota_final > 0 THEN 'REPROBADO'
        ELSE 'SIN_CALIFICAR'
        END as estado_nota
    FROM ins_matricula m
           JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
           JOIN eje_programacion prog ON m.cod_ins_matricula = prog.cod_ins_matricula
           JOIN eje_cronograma_modulo cm ON prog.id_eje_cronograma_modulo = cm.id_eje_cronograma_modulo
           JOIN aca_plan_modulo_detalle pmd ON cm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle
           JOIN aca_modulo mod ON pmd.id_aca_modulo = mod.id_aca_modulo
           LEFT JOIN eje_docente d ON cm.id_eje_docente = d.id_eje_docente
           LEFT JOIN prs_persona pd ON d.id_prs_persona = pd.id_prs_persona
           LEFT JOIN eje_criterio_eval ce ON d.id_eje_docente = ce.id_eje_docente
           LEFT JOIN eje_calificacion cal ON prog.id_eje_programacion = cal.id_eje_programacion
      AND ce.id_eje_criterio_eval = cal.id_eje_criterio_eval
    WHERE m.id_ins_grupo = p_id_grupo
      AND m.estado_matricula != 'ELIMINADO'
      AND prog.estado_programacion != 'ELIMINADO'
      AND (p_id_modulo IS NULL OR mod.id_aca_modulo = p_id_modulo)
      AND (p_id_docente IS NULL OR d.id_eje_docente = p_id_docente)
      AND (ce.estado_criterio_eval != 'ELIMINADO' OR ce.estado_criterio_eval IS NULL)
    ORDER BY p.ap_paterno, p.nombre, mod.nombre_modulo, ce.orden;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_reporte_acta_regular(p_id_cronograma_modulo integer)
 RETURNS TABLE(cod_matricula integer, ci character varying, nombre_completo character varying, programa character varying, plan character varying, version character varying, modalidad character varying, grupo character varying, gestion_programa integer, gestion_grupo integer, docente character varying, sigla character varying, nota_final integer, estado_nota character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      m.cod_ins_matricula,
      p.ci,
      (p.nombre
         || ' '
         || p.ap_paterno
        || COALESCE(' '||p.ap_materno,'')
        )::varchar AS nombre_completo,
      progbase.nombre_programa::varchar  AS programa,
      plan.anho::varchar                  AS plan,
      ver.cod_version::varchar            AS version,
      moda.nombre_modalidad::varchar      AS modalidad,
      g.nombre_grupo::varchar             AS grupo,
      apa.gestion                         AS gestion_programa,
      g.gestion_inicio                    AS gestion_grupo,
      (pd.nombre
         || ' '
         || pd.ap_paterno
        || COALESCE(' '||pd.ap_materno,'')
        )::varchar                          AS docente,
      (
        split_part(apa.cod_sigla_version,' ',1)
          || ' '
          || (split_part(apa.cod_sigla_version,' ',2)::integer + pmd.orden)
        )::varchar                          AS sigla,
      COALESCE(prog.nota_final,0)         AS nota_final,
      (
        CASE
          WHEN prog.nota_final >= 51 THEN 'APROBADO'
          WHEN prog.nota_final > 0    THEN 'REPROBADO'
          ELSE 'ABANDONO'
          END
        )::varchar                          AS estado_nota
    FROM eje_cronograma_modulo cm
           JOIN ins_grupo g
                ON cm.id_ins_grupo = g.id_ins_grupo
           JOIN aca_programa_aprobado apa
                ON g.id_aca_programa_aprobado = apa.id_aca_programa_aprobado
           JOIN aca_programa progbase
                ON apa.id_aca_programa = progbase.id_aca_programa
           JOIN aca_plan_estudio plan
                ON apa.id_aca_plan_estudio = plan.id_aca_plan_estudio
           JOIN aca_version ver
                ON apa.id_aca_version = ver.id_aca_version
           JOIN aca_modalidad moda
                ON apa.id_aca_modalidad = moda.id_aca_modalidad
           JOIN ins_matricula m
                ON m.id_ins_grupo = g.id_ins_grupo
                  AND m.estado_matricula <> 'ELIMINADO'
           JOIN prs_persona p
                ON m.id_prs_persona = p.id_prs_persona
           JOIN eje_programacion prog
                ON prog.cod_ins_matricula = m.cod_ins_matricula
                  AND prog.id_eje_cronograma_modulo = cm.id_eje_cronograma_modulo
                  AND prog.estado_programacion <> 'ELIMINADO'
           JOIN aca_plan_modulo_detalle pmd
                ON cm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle
           LEFT JOIN eje_docente ed
                     ON cm.id_eje_docente = ed.id_eje_docente
           LEFT JOIN prs_persona pd
                     ON ed.id_prs_persona = pd.id_prs_persona
    WHERE cm.id_eje_cronograma_modulo = p_id_cronograma_modulo
      AND apa.estado_programa_aprobado <> 'ELIMINADO'
    ORDER BY p.ap_paterno, p.nombre;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_reporte_situacion_economica(p_id_grupo integer)
 RETURNS TABLE(id_ins_grupo integer, nombre_grupo character varying, nombre_programa character varying, modalidad character varying, gestion_inicio integer, total_estudiantes integer, estudiantes_al_dia integer, estudiantes_pago_parcial integer, estudiantes_sin_pagar integer, total_deuda_grupo numeric, total_pagado_grupo numeric, total_saldo_pendiente numeric, porcentaje_cobranza numeric, total_obligaciones integer, obligaciones_pagadas integer, obligaciones_pendientes integer, obligaciones_parciales integer)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
    SELECT
      g.id_ins_grupo,
      g.nombre_grupo,
      prog.nombre_programa,
      modal.nombre_modalidad,
      g.gestion_inicio,

      -- Estadísticas de estudiantes
      COUNT(DISTINCT m.cod_ins_matricula)::INTEGER AS total_estudiantes,
      COUNT(DISTINCT CASE
                       WHEN estudiante_stats.saldo_estudiante = 0 THEN m.cod_ins_matricula
        END)::INTEGER AS estudiantes_al_dia,
      COUNT(DISTINCT CASE
                       WHEN estudiante_stats.saldo_estudiante > 0 AND estudiante_stats.monto_pagado_estudiante > 0
                         THEN m.cod_ins_matricula
        END)::INTEGER AS estudiantes_pago_parcial,
      COUNT(DISTINCT CASE
                       WHEN estudiante_stats.monto_pagado_estudiante = 0 THEN m.cod_ins_matricula
        END)::INTEGER AS estudiantes_sin_pagar,

      -- Estadísticas financieras
      SUM(op.deuda_con_descuento) AS total_deuda_grupo,
      SUM(op.deuda_con_descuento - op.saldo_pendiente) AS total_pagado_grupo,
      SUM(op.saldo_pendiente) AS total_saldo_pendiente,
      CASE
        WHEN SUM(op.deuda_con_descuento) > 0 THEN
          ROUND((SUM(op.deuda_con_descuento - op.saldo_pendiente) * 100.0 / SUM(op.deuda_con_descuento)), 2)
        ELSE 0
        END AS porcentaje_cobranza,

      -- Obligaciones
      COUNT(op.id_fin_obligacion_pago)::INTEGER AS total_obligaciones,
      COUNT(CASE WHEN op.saldo_pendiente = 0 THEN 1 END)::INTEGER AS obligaciones_pagadas,
      COUNT(CASE WHEN op.saldo_pendiente = op.deuda_con_descuento THEN 1 END)::INTEGER AS obligaciones_pendientes,
      COUNT(CASE WHEN op.saldo_pendiente > 0 AND op.saldo_pendiente < op.deuda_con_descuento THEN 1 END)::INTEGER AS obligaciones_parciales

    FROM ins_grupo g
           INNER JOIN aca_programa_aprobado pa ON g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
           INNER JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
           INNER JOIN aca_modalidad modal ON pa.id_aca_modalidad = modal.id_aca_modalidad
           INNER JOIN ins_matricula m ON g.id_ins_grupo = m.id_ins_grupo
           INNER JOIN fin_obligacion_pago op ON m.cod_ins_matricula = op.cod_ins_matricula
           LEFT JOIN (
      SELECT
        m2.cod_ins_matricula,
        SUM(op2.saldo_pendiente) AS saldo_estudiante,
        SUM(op2.deuda_con_descuento - op2.saldo_pendiente) AS monto_pagado_estudiante
      FROM ins_matricula m2
             INNER JOIN fin_obligacion_pago op2 ON m2.cod_ins_matricula = op2.cod_ins_matricula
      WHERE op2.estado_obligacion_pago != 'ELIMINADO'
      GROUP BY m2.cod_ins_matricula
    ) estudiante_stats ON m.cod_ins_matricula = estudiante_stats.cod_ins_matricula

    WHERE g.id_ins_grupo = p_id_grupo
      AND g.estado_grupo != 'ELIMINADO'
      AND m.estado_matricula != 'ELIMINADO'
      AND op.estado_obligacion_pago != 'ELIMINADO'

    GROUP BY g.id_ins_grupo, g.nombre_grupo, prog.nombre_programa, modal.nombre_modalidad, g.gestion_inicio;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_trigger_actualizar_estado_grupo()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  PERFORM fn_actualizar_estado_grupo_automatico(NEW.id_ins_grupo);
  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_trigger_crear_cronogramas_grupo()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
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
$function$
;


CREATE OR REPLACE FUNCTION public.fn_trigger_matricula_actualiza_grupo()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_grupo INTEGER;
BEGIN
  v_id_grupo := COALESCE(NEW.id_ins_grupo, OLD.id_ins_grupo);
  PERFORM fn_actualizar_estado_grupo_automatico(v_id_grupo);
  RETURN COALESCE(NEW, OLD);
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_trigger_matricula_regular()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.tipo_matricula = 'REGULAR' AND NEW.estado_matricula = 'EN EJECUCION' THEN
    -- Generar programaciones
    PERFORM fn_generar_programaciones_matricula_regular(NEW.cod_ins_matricula, NEW.id_ins_grupo, NEW.user_reg);
  END IF;

  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_validar_apto_titulacion(p_cod_matricula integer)
 RETURNS TABLE(cod_ins_matricula integer, nombre_completo character varying, apto_titular boolean, motivos_impedimento text, modulos_requeridos integer, modulos_aprobados integer, modulos_pendientes integer, promedio_general numeric, obligaciones_pendientes integer, saldo_total_pendiente numeric, monografia_presentada boolean, monografia_aprobada boolean)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_impedimentos TEXT := '';
  v_apto BOOLEAN := TRUE;
  v_modulos_req INTEGER;
  v_modulos_aprob INTEGER;
  v_saldo_pend DECIMAL;
  v_oblig_pend INTEGER;
  v_mono_presentada BOOLEAN;
  v_mono_aprobada BOOLEAN;
  v_promedio DECIMAL;
BEGIN
  -- Obtener módulos requeridos vs aprobados
  SELECT
    COUNT(*) as total_modulos,
    COUNT(CASE WHEN prog.nota_final >= 51 THEN 1 END) as aprobados,
    AVG(CASE WHEN prog.nota_final IS NOT NULL THEN prog.nota_final END)
  INTO v_modulos_req, v_modulos_aprob, v_promedio
  FROM ins_matricula m
         INNER JOIN ins_grupo g ON m.id_ins_grupo = g.id_ins_grupo
         INNER JOIN aca_programa_aprobado pa ON g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
         INNER JOIN aca_plan_modulo_detalle pmd ON pa.id_aca_plan_estudio = pmd.id_aca_plan_estudio
         LEFT JOIN eje_cronograma_modulo cm ON g.id_ins_grupo = cm.id_ins_grupo AND pmd.id_aca_plan_modulo_detalle = cm.id_aca_plan_modulo_detalle
         LEFT JOIN eje_programacion prog ON m.cod_ins_matricula = prog.cod_ins_matricula AND cm.id_eje_cronograma_modulo = prog.id_eje_cronograma_modulo
  WHERE m.cod_ins_matricula = p_cod_matricula;

  -- Validar módulos completados
  IF v_modulos_aprob < v_modulos_req THEN
    v_apto := FALSE;
    v_impedimentos := v_impedimentos || 'Módulos pendientes: ' || (v_modulos_req - v_modulos_aprob) || '. ';
  END IF;

  -- Validar saldo pendiente
  SELECT
    COUNT(*) as obligaciones,
    SUM(op.saldo_pendiente) as saldo
  INTO v_oblig_pend, v_saldo_pend
  FROM fin_obligacion_pago op
  WHERE op.cod_ins_matricula = p_cod_matricula
    AND op.saldo_pendiente > 0
    AND op.estado_obligacion_pago != 'ELIMINADO';

  IF v_saldo_pend > 0 THEN
    v_apto := FALSE;
    v_impedimentos := v_impedimentos || 'Deuda pendiente: Bs.' || v_saldo_pend || '. ';
  END IF;

  -- Validar monografía
  SELECT
    COUNT(*) > 0,
    COUNT(CASE WHEN tm.estado_monografia = 'APROBADO' THEN 1 END) > 0
  INTO v_mono_presentada, v_mono_aprobada
  FROM tgr_monografia tm
  WHERE tm.cod_ins_matricula = p_cod_matricula
    AND tm.estado_monografia != 'ELIMINADO';

  IF NOT v_mono_presentada THEN
    v_apto := FALSE;
    v_impedimentos := v_impedimentos || 'Monografía no presentada. ';
  ELSIF NOT v_mono_aprobada THEN
    v_apto := FALSE;
    v_impedimentos := v_impedimentos || 'Monografía no aprobada. ';
  END IF;

  -- Preparar respuesta
  IF v_impedimentos = '' THEN
    v_impedimentos := 'Ninguno - Apto para titular';
  END IF;

  RETURN QUERY
    SELECT
      p_cod_matricula,
      CONCAT(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, ''))::VARCHAR,
      v_apto,
      v_impedimentos,
      v_modulos_req,
      v_modulos_aprob,
      (v_modulos_req - v_modulos_aprob),
      COALESCE(v_promedio, 0),
      COALESCE(v_oblig_pend, 0),
      COALESCE(v_saldo_pend, 0),
      COALESCE(v_mono_presentada, FALSE),
      COALESCE(v_mono_aprobada, FALSE)
    FROM ins_matricula m
           INNER JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
    WHERE m.cod_ins_matricula = p_cod_matricula;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_validar_arancel_vigente()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_estado_arancel VARCHAR(35);
  v_fecha_fin DATE;
BEGIN
  -- Si no tiene arancel aplicado, saltear
  IF NEW.id_fin_arancel_aplicado IS NULL THEN
    RETURN NEW;
  END IF;

  -- Validar que el arancel esté vigente
  SELECT estado_arancel, fecha_fin_vigencia
  INTO v_estado_arancel, v_fecha_fin
  FROM fin_arancel
  WHERE id_fin_arancel = NEW.id_fin_arancel_aplicado;

  IF v_estado_arancel != 'ACTIVO' THEN
    RAISE EXCEPTION 'El arancel seleccionado no está activo';
  END IF;

  IF v_fecha_fin IS NOT NULL AND v_fecha_fin < CURRENT_DATE THEN
    RAISE EXCEPTION 'El arancel seleccionado ya no está vigente';
  END IF;

  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_validar_convenio_vigente()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_estado_convenio VARCHAR(35);
  v_fecha_fin DATE;
  v_id_colegio INTEGER;
  v_existe_relacion BOOLEAN;
BEGIN
  -- Si no tiene convenio aplicado, saltear
  IF NEW.id_fin_convenio_aplicado IS NULL THEN
    RETURN NEW;
  END IF;

  -- Validar que el convenio esté vigente
  SELECT estado_convenio, fecha_fin_vigencia
  INTO v_estado_convenio, v_fecha_fin
  FROM fin_convenio
  WHERE id_fin_convenio = NEW.id_fin_convenio_aplicado;

  IF v_estado_convenio != 'ACTIVO' THEN
    RAISE EXCEPTION 'El convenio seleccionado no está activo';
  END IF;

  IF v_fecha_fin IS NOT NULL AND v_fecha_fin < CURRENT_DATE THEN
    RAISE EXCEPTION 'El convenio seleccionado ya no está vigente';
  END IF;

  -- Validar que el colegio de procedencia tenga el convenio
  SELECT p.id_aca_colegio_procedencia
  INTO v_id_colegio
  FROM prs_persona p
  WHERE p.id_prs_persona = NEW.id_prs_persona;

  IF v_id_colegio IS NOT NULL THEN
    SELECT EXISTS(
      SELECT 1
      FROM fin_colegio_convenio cc
      WHERE cc.id_aca_colegio = v_id_colegio
        AND cc.id_fin_convenio = NEW.id_fin_convenio_aplicado
        AND cc.estado_colegio_convenio = 'ACTIVO'
    ) INTO v_existe_relacion;

    IF NOT v_existe_relacion THEN
      RAISE EXCEPTION 'El colegio de procedencia no tiene convenio activo';
    END IF;
  END IF;

  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_validar_emision_certificado(p_id_prs_persona integer, p_id_certificacion_programa integer)
 RETURNS TABLE(puede_certificar boolean, mensaje text, periodos_requeridos integer, periodos_aprobados integer, deuda_pendiente numeric)
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_id_programa INTEGER;
  v_periodos_req INTEGER;
  v_periodos_aprob INTEGER;
  v_deuda NUMERIC(10,2);
  v_puede BOOLEAN := TRUE;
  v_mensaje TEXT := '';
BEGIN
  SELECT
    cp.id_aca_programa_aprobado,
    cp.periodos_requeridos
  INTO v_id_programa, v_periodos_req
  FROM aca_certificacion_programa cp
  WHERE cp.id_aca_certificacion_programa = p_id_certificacion_programa;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Certificación no encontrada';
  END IF;

  -- Periodos aprobados
  SELECT COUNT(DISTINCT ecm.id_aca_periodo)
  INTO v_periodos_aprob
  FROM ins_matricula im
         JOIN ins_grupo ig ON im.id_ins_grupo = ig.id_ins_grupo
         JOIN eje_programacion prog ON im.cod_ins_matricula = prog.cod_ins_matricula
         JOIN eje_cronograma_modulo ecm ON prog.id_eje_cronograma_modulo = ecm.id_eje_cronograma_modulo
  WHERE im.id_prs_persona = p_id_prs_persona
    AND ig.id_aca_programa_aprobado = v_id_programa
    AND prog.nota_final >= 51
    AND prog.estado_programacion != 'ELIMINADO';

  -- Deuda
  SELECT COALESCE(SUM(op.saldo_pendiente), 0)
  INTO v_deuda
  FROM ins_matricula im
         JOIN fin_obligacion_pago op ON im.cod_ins_matricula = op.cod_ins_matricula
  WHERE im.id_prs_persona = p_id_prs_persona
    AND op.estado_obligacion_pago != 'ELIMINADO';

  -- Validar
  IF v_periodos_aprob < v_periodos_req THEN
    v_puede := FALSE;
    v_mensaje := v_mensaje || 'Faltan ' || (v_periodos_req - v_periodos_aprob) || ' periodo(s). ';
  END IF;

  IF v_deuda > 0 THEN
    v_puede := FALSE;
    v_mensaje := v_mensaje || 'Deuda: Bs. ' || v_deuda || '. ';
  END IF;

  IF v_puede THEN
    v_mensaje := 'Cumple todos los requisitos';
  END IF;

  RETURN QUERY
    SELECT
      v_puede,
      v_mensaje,
      v_periodos_req,
      COALESCE(v_periodos_aprob, 0),
      COALESCE(v_deuda, 0);
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_validar_fechas_inscripcion()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_periodo_inicio DATE;
  v_periodo_fin DATE;
BEGIN
  -- Si tiene periodo asignado, validar que las fechas estén dentro del periodo
  IF NEW.id_aca_periodo IS NOT NULL THEN
    SELECT fecha_inicio, fecha_fin
    INTO v_periodo_inicio, v_periodo_fin
    FROM aca_periodo
    WHERE id_aca_periodo = NEW.id_aca_periodo;

    IF NEW.fecha_inicio_inscripciones IS NOT NULL
       AND NEW.fecha_inicio_inscripciones < v_periodo_inicio THEN
      RAISE EXCEPTION 'Fecha de inicio de inscripciones no puede ser anterior al inicio del periodo';
    END IF;

    IF NEW.fecha_fin_inscripciones IS NOT NULL
       AND NEW.fecha_fin_inscripciones > v_periodo_fin THEN
      RAISE EXCEPTION 'Fecha de fin de inscripciones no puede ser posterior al fin del periodo';
    END IF;
  END IF;

  -- Validar que fecha_fin sea posterior a fecha_inicio
  IF NEW.fecha_inicio_inscripciones IS NOT NULL
     AND NEW.fecha_fin_inscripciones IS NOT NULL
     AND NEW.fecha_fin_inscripciones < NEW.fecha_inicio_inscripciones THEN
    RAISE EXCEPTION 'Fecha de fin de inscripciones debe ser posterior a fecha de inicio';
  END IF;

  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_validar_periodo_activo()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_estado_periodo VARCHAR(35);
  v_estado_gestion VARCHAR(35);
BEGIN
  -- Validar que el periodo esté activo
  SELECT p.estado_periodo, g.estado_gestion
  INTO v_estado_periodo, v_estado_gestion
  FROM aca_periodo p
  JOIN aca_gestion g ON p.id_aca_gestion = g.id_aca_gestion
  WHERE p.id_aca_periodo = NEW.id_aca_periodo;

  IF v_estado_periodo = 'ELIMINADO' THEN
    RAISE EXCEPTION 'No se puede asignar un periodo eliminado';
  END IF;

  IF v_estado_gestion = 'CERRADO' OR v_estado_gestion = 'ELIMINADO' THEN
    RAISE EXCEPTION 'La gestión del periodo está cerrada o eliminada';
  END IF;

  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.fn_validar_progresion_estudiante()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_nota_minima INTEGER := 51; -- Nota mínima de aprobación
BEGIN
  -- Si aprobó (nota >= 51), marcar debe_repetir = false
  IF NEW.nota IS NOT NULL AND NEW.nota >= v_nota_minima THEN
    NEW.debe_repetir := false;
  ELSIF NEW.nota IS NOT NULL AND NEW.nota < v_nota_minima THEN
    NEW.debe_repetir := true;
  END IF;

  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.trigger_generar_resumen()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.resumen := extraer_texto_de_html(NEW.contenido);
  RETURN NEW;
END;
$function$
;


CREATE OR REPLACE FUNCTION public.unaccent(regdictionary, text)
 RETURNS text
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/unaccent', $function$unaccent_dict$function$
;


CREATE OR REPLACE FUNCTION public.unaccent(text)
 RETURNS text
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/unaccent', $function$unaccent_dict$function$
;


CREATE OR REPLACE FUNCTION public.unaccent_init(internal)
 RETURNS internal
 LANGUAGE c
 PARALLEL SAFE
AS '$libdir/unaccent', $function$unaccent_init$function$
;


CREATE OR REPLACE FUNCTION public.unaccent_lexize(internal, internal, internal, internal)
 RETURNS internal
 LANGUAGE c
 PARALLEL SAFE
AS '$libdir/unaccent', $function$unaccent_lexize$function$
;
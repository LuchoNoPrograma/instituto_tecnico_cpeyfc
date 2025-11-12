-- ============================================
-- VISTAS
-- ============================================

CREATE OR REPLACE VIEW vista_aca_modulos_activos AS
 SELECT m.id_aca_modulo,
    m.nombre_modulo,
    m.estado_modulo
   FROM aca_modulo m
  WHERE ((m.estado_modulo)::text = 'ACTIVO'::text)
  ORDER BY m.nombre_modulo;;


CREATE OR REPLACE VIEW vista_aca_niveles_activos AS
 SELECT aca_nivel.id_aca_nivel,
    aca_nivel.nombre_nivel,
    aca_nivel.estado_nivel
   FROM aca_nivel
  WHERE ((aca_nivel.estado_nivel)::text <> 'ELIMINADO'::text);;


CREATE OR REPLACE VIEW vista_aca_planes_estudio_activos AS
 SELECT aca_plan_estudio.id_aca_plan_estudio,
    aca_plan_estudio.anho,
    aca_plan_estudio.vigente,
    aca_plan_estudio.estado_plan_estudio,
        CASE
            WHEN (aca_plan_estudio.vigente = true) THEN (concat(aca_plan_estudio.anho, ' (VIGENTE)'))::character varying
            ELSE (aca_plan_estudio.anho)::character varying
        END AS anho_display
   FROM aca_plan_estudio
  WHERE ((aca_plan_estudio.estado_plan_estudio)::text <> 'ELIMINADO'::text)
  ORDER BY aca_plan_estudio.anho DESC, aca_plan_estudio.vigente DESC;;


CREATE OR REPLACE VIEW vista_aca_programas_activos AS
 SELECT p.id_aca_programa,
    p.nombre_programa,
    p.sigla,
    p.estado_programa,
    a.id_aca_area,
    a.nombre_area AS area_nombre
   FROM (aca_programa p
     JOIN aca_area a ON ((p.id_aca_area = a.id_aca_area)))
  WHERE (((p.estado_programa)::text = 'ACTIVO'::text) AND ((a.estado_area)::text = 'ACTIVO'::text))
  ORDER BY p.nombre_programa;;


CREATE OR REPLACE VIEW vista_aca_version_activas AS
 SELECT aca_version.id_aca_version,
    aca_version.cod_version,
    aca_version.estado_version
   FROM aca_version
  WHERE ((aca_version.estado_version)::text <> 'ELIMINADO'::text);;


CREATE OR REPLACE VIEW vista_aranceles_vigentes AS
 SELECT a.id_fin_arancel,
    a.nombre_arancel,
    a.nro_resolucion,
    a.fecha_aprobacion,
    p.nombre_programa,
    pa.sistema_programa,
    per.nombre_periodo,
    te.nombre_tipo AS tipo_estudiante,
    te.es_nacional,
    da.id_fin_detalle_arancel,
    ca.nombre_concepto,
    ca.tipo_concepto,
    da.monto_concepto,
    da.orden_aplicacion,
    ( SELECT sum(fin_detalle_arancel.monto_concepto) AS sum
           FROM fin_detalle_arancel
          WHERE (fin_detalle_arancel.id_fin_arancel = a.id_fin_arancel)) AS monto_total,
    ( SELECT count(*) AS count
           FROM fin_descuento_arancel
          WHERE ((fin_descuento_arancel.id_fin_arancel = a.id_fin_arancel) AND ((fin_descuento_arancel.estado_descuento)::text = 'ACTIVO'::text))) AS descuentos_disponibles,
    a.estado_arancel,
    a.fecha_inicio_vigencia,
    a.fecha_fin_vigencia
   FROM ((((((fin_arancel a
     JOIN aca_programa_aprobado pa ON ((a.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     JOIN aca_programa p ON ((pa.id_aca_programa = p.id_aca_programa)))
     JOIN aca_tipo_estudiante te ON ((a.id_aca_tipo_estudiante = te.id_aca_tipo_estudiante)))
     LEFT JOIN aca_periodo per ON ((a.id_aca_periodo = per.id_aca_periodo)))
     LEFT JOIN fin_detalle_arancel da ON ((a.id_fin_arancel = da.id_fin_arancel)))
     LEFT JOIN fin_concepto_arancel ca ON ((da.id_fin_concepto_arancel = ca.id_fin_concepto_arancel)))
  WHERE (((a.estado_arancel)::text = 'ACTIVO'::text) AND ((a.fecha_fin_vigencia IS NULL) OR (a.fecha_fin_vigencia >= CURRENT_DATE)))
  ORDER BY p.nombre_programa, te.nombre_tipo, da.orden_aplicacion;;


CREATE OR REPLACE VIEW vista_areas_activas AS
 SELECT aca_area.id_aca_area,
    aca_area.nombre_area,
    aca_area.estado_area,
    aca_area.user_reg,
    aca_area.user_mod
   FROM aca_area
  WHERE ((aca_area.estado_area)::text <> 'ELIMINADO'::text);;


CREATE OR REPLACE VIEW vista_calificaciones_competencia AS
 SELECT prog.id_eje_programacion,
    m.cod_ins_matricula,
    concat(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, ''::character varying)) AS nombre_estudiante,
    p.ci,
    pr.nombre_programa,
    mod.nombre_modulo,
    g.nombre_grupo,
    prog.nota_final AS nota_final_modulo,
    prog.observacion AS observacion_modulo,
    dc.id_eje_detalle_calificacion,
    ae.nombre_area,
    ae.descripcion AS area_descripcion,
    dc.nota_progress_test,
    dc.nota_class_performance,
    dc.nota_final_area,
    dc.comentario_docente,
    ae.orden AS area_orden
   FROM (((((((((((eje_programacion prog
     JOIN ins_matricula m ON ((prog.cod_ins_matricula = m.cod_ins_matricula)))
     JOIN prs_persona p ON ((m.id_prs_persona = p.id_prs_persona)))
     JOIN ins_grupo g ON ((m.id_ins_grupo = g.id_ins_grupo)))
     JOIN aca_programa_aprobado pa ON ((g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     JOIN aca_programa pr ON ((pa.id_aca_programa = pr.id_aca_programa)))
     JOIN eje_cronograma_modulo ecm ON ((prog.id_eje_cronograma_modulo = ecm.id_eje_cronograma_modulo)))
     JOIN aca_plan_modulo_detalle pmd ON ((ecm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle)))
     JOIN aca_modulo mod ON ((pmd.id_aca_modulo = mod.id_aca_modulo)))
     LEFT JOIN eje_calificacion cal ON (((prog.id_eje_programacion = cal.id_eje_programacion) AND ((cal.estado_calificacion)::text <> 'ELIMINADO'::text))))
     LEFT JOIN eje_detalle_calificacion dc ON (((cal.id_eje_calificacion = dc.id_eje_calificacion) AND ((dc.estado_detalle_calificacion)::text <> 'ELIMINADO'::text))))
     LEFT JOIN eje_area_evaluacion ae ON ((dc.id_eje_area_evaluacion = ae.id_eje_area_evaluacion)))
  WHERE ((prog.estado_programacion)::text <> 'ELIMINADO'::text)
  ORDER BY m.cod_ins_matricula, ae.orden;;


CREATE OR REPLACE VIEW vista_calificaciones_detalle AS
 SELECT prog.id_eje_programacion,
    m.cod_ins_matricula,
    cm.id_eje_cronograma_modulo,
    ce.id_eje_criterio_eval,
    ((((p.nombre)::text || ' '::text) || (p.ap_paterno)::text) || COALESCE((' '::text || (p.ap_materno)::text), ''::text)) AS nombre_estudiante,
    p.ci,
    mod.nombre_modulo,
    pmd.sigla,
    g.nombre_grupo,
    ce.nombre_crit,
    ce.ponderacion,
    ce.orden,
    cal.nota,
    cal.nota_ponderada,
    prog.nota_final,
    prog.estado_programacion
   FROM ((((((((eje_programacion prog
     JOIN ins_matricula m ON ((prog.cod_ins_matricula = m.cod_ins_matricula)))
     JOIN prs_persona p ON ((m.id_prs_persona = p.id_prs_persona)))
     JOIN eje_cronograma_modulo cm ON ((prog.id_eje_cronograma_modulo = cm.id_eje_cronograma_modulo)))
     JOIN aca_plan_modulo_detalle pmd ON ((cm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle)))
     JOIN aca_modulo mod ON ((pmd.id_aca_modulo = mod.id_aca_modulo)))
     JOIN ins_grupo g ON ((cm.id_ins_grupo = g.id_ins_grupo)))
     JOIN eje_criterio_eval ce ON ((cm.id_eje_cronograma_modulo = ce.id_eje_cronograma_modulo)))
     LEFT JOIN eje_calificacion cal ON (((prog.id_eje_programacion = cal.id_eje_programacion) AND (ce.id_eje_criterio_eval = cal.id_eje_criterio_eval) AND ((cal.estado_calificacion)::text <> 'ELIMINADO'::text))))
  WHERE (((prog.estado_programacion)::text <> 'ELIMINADO'::text) AND ((ce.estado_criterio_eval)::text <> 'ELIMINADO'::text))
  ORDER BY g.nombre_grupo, p.ap_paterno, p.nombre, ce.orden;;


CREATE OR REPLACE VIEW vista_certificaciones_programa AS
 SELECT cp.id_aca_certificacion_programa,
    prog.nombre_programa,
    pa.sistema_programa,
    cp.nombre_certificacion,
    cp.tipo_certificacion_programa,
    tc.nombre_titulo,
    tc.tipo_certificacion,
    tc.nivel_academico,
    cp.periodos_requeridos,
    cp.creditos_requeridos,
    cp.horas_academicas_requeridas,
    cp.orden_secuencial,
    ( SELECT string_agg((mg.nombre_modalidad)::text, ', '::text) AS string_agg
           FROM (aca_programa_modalidad_graduacion pmg
             JOIN aca_modalidad_graduacion mg ON ((pmg.id_aca_modalidad_graduacion = mg.id_aca_modalidad_graduacion)))
          WHERE ((pmg.id_aca_programa_aprobado = pa.id_aca_programa_aprobado) AND ((pmg.estado_programa_modalidad)::text = 'ACTIVO'::text) AND ((mg.estado_modalidad_graduacion)::text = 'ACTIVO'::text))) AS modalidades_disponibles,
    cp.estado_certificacion_programa
   FROM (((aca_certificacion_programa cp
     JOIN aca_titulo_certificado tc ON ((cp.id_aca_titulo_certificado = tc.id_aca_titulo_certificado)))
     JOIN aca_programa_aprobado pa ON ((cp.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     JOIN aca_programa prog ON ((pa.id_aca_programa = prog.id_aca_programa)))
  WHERE (((cp.estado_certificacion_programa)::text = 'ACTIVO'::text) AND ((tc.estado_titulo)::text = 'ACTIVO'::text) AND ((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text))
  ORDER BY prog.nombre_programa, cp.orden_secuencial;;


CREATE OR REPLACE VIEW vista_chatbot_estadisticas_generales AS
 SELECT ( SELECT count(*) AS count
           FROM aca_programa
          WHERE ((aca_programa.estado_programa)::text <> 'ELIMINADO'::text)) AS total_programas,
    ( SELECT count(*) AS count
           FROM aca_area
          WHERE ((aca_area.estado_area)::text <> 'ELIMINADO'::text)) AS total_areas,
    ( SELECT count(*) AS count
           FROM ins_grupo
          WHERE ((ins_grupo.estado_grupo)::text <> 'ELIMINADO'::text)) AS total_grupos,
    ( SELECT count(*) AS count
           FROM ins_grupo
          WHERE (((ins_grupo.estado_grupo)::text <> 'ELIMINADO'::text) AND (ins_grupo.fecha_fin_inscripcion >= CURRENT_DATE) AND (ins_grupo.fecha_inicio_inscripcion <= CURRENT_DATE))) AS grupos_con_inscripcion_abierta,
    ( SELECT count(*) AS count
           FROM ins_matricula
          WHERE ((ins_matricula.estado_matricula)::text <> 'ELIMINADO'::text)) AS total_estudiantes,
    ( SELECT count(*) AS count
           FROM eje_docente
          WHERE ((eje_docente.estado_docente)::text <> 'ELIMINADO'::text)) AS total_docentes;;


CREATE OR REPLACE VIEW vista_chatbot_niveles_programa AS
 SELECT DISTINCT prog.id_aca_programa,
    prog.nombre_programa,
    niv.nombre_nivel,
    count(DISTINCT pmd.id_aca_plan_modulo_detalle) AS modulos_nivel
   FROM ((((aca_programa prog
     JOIN aca_programa_aprobado pa ON ((prog.id_aca_programa = pa.id_aca_programa)))
     JOIN aca_plan_estudio pe ON ((pa.id_aca_plan_estudio = pe.id_aca_plan_estudio)))
     JOIN aca_plan_modulo_detalle pmd ON ((pe.id_aca_plan_estudio = pmd.id_aca_plan_estudio)))
     JOIN aca_nivel niv ON ((pmd.id_aca_nivel = niv.id_aca_nivel)))
  WHERE (((prog.estado_programa)::text <> 'ELIMINADO'::text) AND ((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text) AND ((pmd.estado_plan_modulo_detalle)::text <> 'ELIMINADO'::text) AND ((niv.estado_nivel)::text <> 'ELIMINADO'::text))
  GROUP BY prog.id_aca_programa, prog.nombre_programa, niv.nombre_nivel
  ORDER BY prog.nombre_programa, niv.nombre_nivel;;


CREATE OR REPLACE VIEW vista_chatbot_programas_info AS
 SELECT pa.id_aca_programa_aprobado,
    prog.id_aca_programa,
    prog.nombre_programa,
    prog.sigla AS programa_sigla,
    area.nombre_area,
    modal.nombre_modalidad,
    pa.gestion,
    pe.anho AS plan_anho,
    v.cod_version,
    g.id_ins_grupo,
    g.nombre_grupo,
    g.gestion_inicio,
    g.fecha_inicio_inscripcion,
    g.fecha_fin_inscripcion,
    g.estado_grupo,
        CASE
            WHEN ((g.fecha_fin_inscripcion >= CURRENT_DATE) AND (g.fecha_inicio_inscripcion <= CURRENT_DATE)) THEN 'INSCRIPCIONES ABIERTAS'::text
            WHEN (g.fecha_inicio_inscripcion > CURRENT_DATE) THEN 'PROXIMAMENTE'::text
            ELSE 'INSCRIPCIONES CERRADAS'::text
        END AS estado_inscripcion,
        CASE
            WHEN (g.fecha_fin_inscripcion >= CURRENT_DATE) THEN (g.fecha_fin_inscripcion - CURRENT_DATE)
            ELSE 0
        END AS dias_restantes,
    COALESCE(pa.precio_matricula, (0)::numeric) AS precio_matricula,
    COALESCE(pa.precio_colegiatura, (0)::numeric) AS precio_colegiatura,
    COALESCE(pa.precio_titulacion, (0)::numeric) AS precio_titulacion,
    ( SELECT count(*) AS count
           FROM ins_preinscripcion pre
          WHERE ((pre.id_aca_programa_aprobado = g.id_ins_grupo) AND ((pre.estado_preinscripcion)::text <> 'ELIMINADO'::text))) AS total_preinscritos,
    ( SELECT count(DISTINCT pmd.id_aca_plan_modulo_detalle) AS count
           FROM aca_plan_modulo_detalle pmd
          WHERE ((pmd.id_aca_plan_estudio = pa.id_aca_plan_estudio) AND ((pmd.estado_plan_modulo_detalle)::text <> 'ELIMINADO'::text))) AS total_modulos,
    ( SELECT sum(pmd.carga_horaria) AS sum
           FROM aca_plan_modulo_detalle pmd
          WHERE ((pmd.id_aca_plan_estudio = pa.id_aca_plan_estudio) AND ((pmd.estado_plan_modulo_detalle)::text <> 'ELIMINADO'::text))) AS total_horas,
    COALESCE(pa.imagen_programa_url, prog.imagen_url) AS imagen_url,
    pa.estado_programa_aprobado
   FROM ((((((ins_grupo g
     JOIN aca_programa_aprobado pa ON ((g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     JOIN aca_programa prog ON ((pa.id_aca_programa = prog.id_aca_programa)))
     JOIN aca_area area ON ((prog.id_aca_area = area.id_aca_area)))
     JOIN aca_modalidad modal ON ((pa.id_aca_modalidad = modal.id_aca_modalidad)))
     LEFT JOIN aca_plan_estudio pe ON ((pa.id_aca_plan_estudio = pe.id_aca_plan_estudio)))
     LEFT JOIN aca_version v ON ((pa.id_aca_version = v.id_aca_version)))
  WHERE (((g.estado_grupo)::text <> 'ELIMINADO'::text) AND ((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text) AND ((prog.estado_programa)::text <> 'ELIMINADO'::text) AND ((area.estado_area)::text <> 'ELIMINADO'::text) AND ((modal.estado_modalidad)::text <> 'ELIMINADO'::text))
  ORDER BY
        CASE
            WHEN (g.fecha_fin_inscripcion >= CURRENT_DATE) THEN 0
            WHEN (g.fecha_inicio_inscripcion > CURRENT_DATE) THEN 1
            ELSE 2
        END, g.fecha_fin_inscripcion DESC;;


CREATE OR REPLACE VIEW vista_convenios_colegios AS
 SELECT conv.id_fin_convenio,
    conv.nombre_convenio,
    conv.descripcion,
    conv.tipo_descuento,
    conv.monto_descuento,
    conv.porcentaje_descuento,
    conv.fecha_inicio_vigencia,
    conv.fecha_fin_vigencia,
    col.id_aca_colegio,
    col.nombre_colegio,
    col.tipo_colegio,
    col.director_nombre,
    col.telefono AS colegio_telefono,
    cc.fecha_inicio,
    cc.fecha_fin,
    cc.estado_colegio_convenio,
        CASE
            WHEN (CURRENT_DATE < conv.fecha_inicio_vigencia) THEN 'PROXIMO'::text
            WHEN ((conv.fecha_fin_vigencia IS NOT NULL) AND (CURRENT_DATE > conv.fecha_fin_vigencia)) THEN 'VENCIDO'::text
            WHEN ((cc.estado_colegio_convenio)::text = 'SUSPENDIDO'::text) THEN 'SUSPENDIDO'::text
            ELSE 'VIGENTE'::text
        END AS estado_vigencia,
    ( SELECT count(DISTINCT m.id_prs_persona) AS count
           FROM (ins_matricula m
             JOIN prs_persona p ON ((m.id_prs_persona = p.id_prs_persona)))
          WHERE ((p.id_aca_colegio_procedencia = col.id_aca_colegio) AND (m.id_fin_convenio_aplicado = conv.id_fin_convenio) AND ((m.estado_matricula)::text = 'ACTIVO'::text))) AS estudiantes_beneficiados
   FROM ((fin_convenio conv
     JOIN fin_colegio_convenio cc ON ((conv.id_fin_convenio = cc.id_fin_convenio)))
     JOIN aca_colegio col ON ((cc.id_aca_colegio = col.id_aca_colegio)))
  WHERE (((conv.estado_convenio)::text <> 'ELIMINADO'::text) AND ((col.estado_colegio)::text <> 'ELIMINADO'::text))
  ORDER BY conv.nombre_convenio, col.nombre_colegio;;


CREATE OR REPLACE VIEW vista_criterios_por_cronograma AS
 SELECT ce.id_eje_criterio_eval,
    ce.id_eje_cronograma_modulo,
    ce.id_eje_docente,
    ce.nombre_crit,
    ce.descripcion,
    ce.ponderacion,
    ce.orden,
    ce.estado_criterio_eval,
    cm.fecha_inicio,
    cm.fecha_fin,
    pmd.sigla,
    m.nombre_modulo
   FROM (((eje_criterio_eval ce
     JOIN eje_cronograma_modulo cm ON ((ce.id_eje_cronograma_modulo = cm.id_eje_cronograma_modulo)))
     JOIN aca_plan_modulo_detalle pmd ON ((cm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle)))
     JOIN aca_modulo m ON ((pmd.id_aca_modulo = m.id_aca_modulo)))
  WHERE (((ce.estado_criterio_eval)::text <> 'ELIMINADO'::text) AND ((cm.estado_cronograma_modulo)::text <> 'ELIMINADO'::text))
  ORDER BY ce.id_eje_cronograma_modulo, ce.orden;;


CREATE OR REPLACE VIEW vista_cronogramas_docente AS
 SELECT ecm.id_eje_cronograma_modulo,
    ecm.fecha_inicio,
    ecm.fecha_fin,
    pmd.sigla,
    m.nombre_modulo,
    p.nombre_programa,
    pa.sistema_programa,
    pe.anho AS anho_plan,
    v.cod_version,
    modal.nombre_modalidad,
    per.nombre_periodo,
    per.id_aca_periodo,
    ig.nombre_grupo,
    ig.horario,
    ig.aula,
    d.id_eje_docente,
    d.id_seg_usuario AS id_usuario_docente,
    concat(pd.nombre, ' ', pd.ap_paterno, ' ', COALESCE(pd.ap_materno, ''::character varying)) AS docente_nombre,
    pd.ci AS docente_ci,
    d.numero_contrato,
    count(DISTINCT im.cod_ins_matricula) FILTER (WHERE ((im.estado_matricula)::text = 'ACTIVO'::text)) AS total_estudiantes,
    count(DISTINCT ce.id_eje_criterio_eval) FILTER (WHERE ((ce.estado_criterio_eval)::text <> 'ELIMINADO'::text)) AS total_criterios,
    ecm.estado_cronograma_modulo
   FROM (((((((((((((eje_cronograma_modulo ecm
     JOIN ins_grupo ig ON ((ecm.id_ins_grupo = ig.id_ins_grupo)))
     JOIN aca_plan_modulo_detalle pmd ON ((ecm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle)))
     JOIN aca_modulo m ON ((pmd.id_aca_modulo = m.id_aca_modulo)))
     JOIN aca_plan_estudio pe ON ((pmd.id_aca_plan_estudio = pe.id_aca_plan_estudio)))
     JOIN aca_programa_aprobado pa ON ((ig.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     JOIN aca_programa p ON ((pa.id_aca_programa = p.id_aca_programa)))
     JOIN aca_modalidad modal ON ((pa.id_aca_modalidad = modal.id_aca_modalidad)))
     LEFT JOIN aca_version v ON ((pa.id_aca_version = v.id_aca_version)))
     LEFT JOIN aca_periodo per ON ((ecm.id_aca_periodo = per.id_aca_periodo)))
     LEFT JOIN eje_docente d ON ((ecm.id_eje_docente = d.id_eje_docente)))
     LEFT JOIN prs_persona pd ON ((d.id_prs_persona = pd.id_prs_persona)))
     LEFT JOIN ins_matricula im ON ((ig.id_ins_grupo = im.id_ins_grupo)))
     LEFT JOIN eje_criterio_eval ce ON ((ecm.id_eje_cronograma_modulo = ce.id_eje_cronograma_modulo)))
  WHERE (((ecm.estado_cronograma_modulo)::text <> 'ELIMINADO'::text) AND ((pmd.estado_plan_modulo_detalle)::text <> 'ELIMINADO'::text) AND ((ig.estado_grupo)::text <> 'ELIMINADO'::text) AND ((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text) AND ((d.id_eje_docente IS NULL) OR ((d.estado_docente)::text <> 'ELIMINADO'::text)))
  GROUP BY ecm.id_eje_cronograma_modulo, ecm.fecha_inicio, ecm.fecha_fin, pmd.sigla, m.nombre_modulo, p.nombre_programa, pa.sistema_programa, pe.anho, v.cod_version, modal.nombre_modalidad, per.nombre_periodo, per.id_aca_periodo, ig.nombre_grupo, ig.horario, ig.aula, d.id_eje_docente, d.id_seg_usuario, d.numero_contrato, pd.nombre, pd.ap_paterno, pd.ap_materno, pd.ci, ecm.estado_cronograma_modulo
  ORDER BY ecm.fecha_inicio DESC;;


CREATE OR REPLACE VIEW vista_cursos_disponibles_inscripcion AS
 SELECT pa.id_aca_programa_aprobado,
    p.nombre_programa,
    pa.sistema_programa,
    m.nombre_modulo,
    pmd.orden AS nivel_orden,
    ecm.id_eje_cronograma_modulo,
    ecm.fecha_inicio,
    ecm.fecha_fin,
    ecm.fecha_inicio_inscripciones,
    ecm.fecha_fin_inscripciones,
    ecm.permite_inscripciones,
    per.nombre_periodo,
    per.id_aca_periodo,
    concat(pd.nombre, ' ', pd.ap_paterno, ' ', COALESCE(pd.ap_materno, ''::character varying)) AS docente_nombre,
    ig.id_ins_grupo,
    ig.nombre_grupo,
    ig.horario,
    ig.aula,
    ( SELECT count(*) AS count
           FROM ins_matricula im
          WHERE ((im.id_ins_grupo = ig.id_ins_grupo) AND ((im.estado_matricula)::text = 'ACTIVO'::text))) AS estudiantes_matriculados,
        CASE
            WHEN (NOT ecm.permite_inscripciones) THEN 'CERRADO'::text
            WHEN (CURRENT_DATE < ecm.fecha_inicio_inscripciones) THEN 'PROXIMAMENTE'::text
            WHEN (CURRENT_DATE > ecm.fecha_fin_inscripciones) THEN 'FINALIZADO'::text
            ELSE 'ABIERTO'::text
        END AS estado_inscripcion
   FROM ((((((((eje_cronograma_modulo ecm
     JOIN ins_grupo ig ON ((ecm.id_ins_grupo = ig.id_ins_grupo)))
     JOIN aca_plan_modulo_detalle pmd ON ((ecm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle)))
     JOIN aca_modulo m ON ((pmd.id_aca_modulo = m.id_aca_modulo)))
     JOIN aca_programa_aprobado pa ON ((ig.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     JOIN aca_programa p ON ((pa.id_aca_programa = p.id_aca_programa)))
     LEFT JOIN aca_periodo per ON ((ecm.id_aca_periodo = per.id_aca_periodo)))
     LEFT JOIN eje_docente ed ON ((ecm.id_eje_docente = ed.id_eje_docente)))
     LEFT JOIN prs_persona pd ON ((ed.id_prs_persona = pd.id_prs_persona)))
  WHERE (((ecm.estado_cronograma_modulo)::text <> 'ELIMINADO'::text) AND ((pmd.estado_plan_modulo_detalle)::text <> 'ELIMINADO'::text) AND ((ig.estado_grupo)::text <> 'ELIMINADO'::text) AND ((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text) AND ((p.estado_programa)::text = 'ACTIVO'::text));;


CREATE OR REPLACE VIEW vista_estado_cuenta_estudiante AS
 SELECT m.cod_ins_matricula,
    p.id_prs_persona,
    concat(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, ''::character varying)) AS nombre_completo,
    p.ci,
    prog.nombre_programa,
    g.nombre_grupo,
    te.nombre_tipo AS tipo_estudiante,
    ar.nombre_arancel,
    conv.nombre_convenio,
    op.id_fin_obligacion_pago,
    cp.nombre_concepto AS concepto_pago,
    op.monto_base,
    op.monto_descuento_arancel,
    op.monto_descuento_convenio,
    op.monto_final,
    op.saldo_pendiente,
    op.estado_obligacion_pago,
    ( SELECT sum(fin_obligacion_pago.monto_final) AS sum
           FROM fin_obligacion_pago
          WHERE ((fin_obligacion_pago.cod_ins_matricula = m.cod_ins_matricula) AND ((fin_obligacion_pago.estado_obligacion_pago)::text <> 'ELIMINADO'::text))) AS total_deuda,
    ( SELECT sum(fin_obligacion_pago.saldo_pendiente) AS sum
           FROM fin_obligacion_pago
          WHERE ((fin_obligacion_pago.cod_ins_matricula = m.cod_ins_matricula) AND ((fin_obligacion_pago.estado_obligacion_pago)::text <> 'ELIMINADO'::text))) AS total_saldo,
    ( SELECT sum((fin_obligacion_pago.monto_final - fin_obligacion_pago.saldo_pendiente)) AS sum
           FROM fin_obligacion_pago
          WHERE ((fin_obligacion_pago.cod_ins_matricula = m.cod_ins_matricula) AND ((fin_obligacion_pago.estado_obligacion_pago)::text <> 'ELIMINADO'::text))) AS total_pagado,
        CASE
            WHEN (( SELECT sum(fin_obligacion_pago.saldo_pendiente) AS sum
               FROM fin_obligacion_pago
              WHERE (fin_obligacion_pago.cod_ins_matricula = m.cod_ins_matricula)) > (0)::numeric) THEN 'MOROSO'::text
            ELSE 'AL_DIA'::text
        END AS estado_financiero
   FROM (((((((((ins_matricula m
     JOIN prs_persona p ON ((m.id_prs_persona = p.id_prs_persona)))
     LEFT JOIN ins_grupo g ON ((m.id_ins_grupo = g.id_ins_grupo)))
     LEFT JOIN aca_programa_aprobado pa ON ((g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     LEFT JOIN aca_programa prog ON ((pa.id_aca_programa = prog.id_aca_programa)))
     LEFT JOIN aca_tipo_estudiante te ON ((m.id_aca_tipo_estudiante = te.id_aca_tipo_estudiante)))
     LEFT JOIN fin_arancel ar ON ((m.id_fin_arancel_aplicado = ar.id_fin_arancel)))
     LEFT JOIN fin_convenio conv ON ((m.id_fin_convenio_aplicado = conv.id_fin_convenio)))
     LEFT JOIN fin_obligacion_pago op ON ((m.cod_ins_matricula = op.cod_ins_matricula)))
     LEFT JOIN fin_concepto_pago cp ON ((op.id_fin_concepto_pago = cp.id_fin_concepto_pago)))
  WHERE (((m.estado_matricula)::text <> 'ELIMINADO'::text) AND ((op.id_fin_obligacion_pago IS NULL) OR ((op.estado_obligacion_pago)::text <> 'ELIMINADO'::text)));;


CREATE OR REPLACE VIEW vista_estudiantes_aptos_certificacion AS
 SELECT m.cod_ins_matricula,
    p.id_prs_persona,
    concat(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, ''::character varying)) AS nombre_completo,
    p.ci,
    prog.nombre_programa,
    cp.nombre_certificacion,
    cp.tipo_certificacion_programa,
    cp.periodos_requeridos,
    ( SELECT count(DISTINCT ecm.id_aca_periodo) AS count
           FROM (eje_programacion prog_est
             JOIN eje_cronograma_modulo ecm ON ((prog_est.id_eje_cronograma_modulo = ecm.id_eje_cronograma_modulo)))
          WHERE ((prog_est.cod_ins_matricula = m.cod_ins_matricula) AND (prog_est.nota_final >= 51) AND ((prog_est.estado_programacion)::text <> 'ELIMINADO'::text))) AS periodos_aprobados,
    COALESCE(( SELECT sum(fin_obligacion_pago.saldo_pendiente) AS sum
           FROM fin_obligacion_pago
          WHERE ((fin_obligacion_pago.cod_ins_matricula = m.cod_ins_matricula) AND ((fin_obligacion_pago.estado_obligacion_pago)::text <> 'ELIMINADO'::text))), (0)::numeric) AS deuda_pendiente,
        CASE
            WHEN ((( SELECT count(DISTINCT ecm.id_aca_periodo) AS count
               FROM (eje_programacion prog_est
                 JOIN eje_cronograma_modulo ecm ON ((prog_est.id_eje_cronograma_modulo = ecm.id_eje_cronograma_modulo)))
              WHERE ((prog_est.cod_ins_matricula = m.cod_ins_matricula) AND (prog_est.nota_final >= 51))) >= cp.periodos_requeridos) AND (COALESCE(( SELECT sum(fin_obligacion_pago.saldo_pendiente) AS sum
               FROM fin_obligacion_pago
              WHERE (fin_obligacion_pago.cod_ins_matricula = m.cod_ins_matricula)), (0)::numeric) = (0)::numeric)) THEN true
            ELSE false
        END AS apto_para_certificar,
    ( SELECT count(*) AS count
           FROM aca_certificado_emitido ce
          WHERE ((ce.id_prs_persona = p.id_prs_persona) AND (ce.id_aca_certificacion_programa = cp.id_aca_certificacion_programa) AND ((ce.estado_certificado)::text <> 'ANULADO'::text))) AS certificados_emitidos
   FROM (((((ins_matricula m
     JOIN prs_persona p ON ((m.id_prs_persona = p.id_prs_persona)))
     JOIN ins_grupo g ON ((m.id_ins_grupo = g.id_ins_grupo)))
     JOIN aca_programa_aprobado pa ON ((g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     JOIN aca_programa prog ON ((pa.id_aca_programa = prog.id_aca_programa)))
     CROSS JOIN aca_certificacion_programa cp)
  WHERE ((cp.id_aca_programa_aprobado = pa.id_aca_programa_aprobado) AND ((m.estado_matricula)::text <> 'ELIMINADO'::text) AND ((cp.estado_certificacion_programa)::text = 'ACTIVO'::text));;


CREATE OR REPLACE VIEW vista_estudiantes_grupo AS
 SELECT m.cod_ins_matricula,
    p.id_prs_persona,
    p.ci,
    concat(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, ''::character varying)) AS nombre_completo,
    p.nro_celular,
    p.correo,
    m.estado_matricula,
    m.tipo_matricula,
    m.fecha_reg AS fecha_matricula,
    g.id_ins_grupo,
    g.nombre_grupo,
    g.horario,
    g.aula,
    prog.nombre_programa,
    pa.sistema_programa,
    te.nombre_tipo AS tipo_estudiante,
    te.es_nacional,
    col.nombre_colegio AS colegio_procedencia,
    m.numero_periodo_cursando,
    m.es_estudiante_antiguo,
        CASE
            WHEN (p.id_prs_persona_apoderado IS NOT NULL) THEN concat(pa_apod.nombre, ' ', pa_apod.ap_paterno)
            ELSE NULL::text
        END AS apoderado_nombre,
    p.tipo_relacion_apoderado,
    p.telefono_apoderado,
    COALESCE(deudas.deuda_total, (0)::numeric) AS deuda_total,
    COALESCE(deudas.obligaciones_pendientes, (0)::bigint) AS obligaciones_pendientes,
        CASE
            WHEN (COALESCE(deudas.deuda_total, (0)::numeric) > (0)::numeric) THEN 'MOROSO'::text
            ELSE 'AL_DIA'::text
        END AS estado_financiero,
    conv.nombre_convenio,
    conv.tipo_descuento,
    conv.monto_descuento,
    conv.porcentaje_descuento
   FROM (((((((((ins_matricula m
     JOIN prs_persona p ON ((m.id_prs_persona = p.id_prs_persona)))
     LEFT JOIN prs_persona pa_apod ON ((p.id_prs_persona_apoderado = pa_apod.id_prs_persona)))
     LEFT JOIN ins_grupo g ON ((m.id_ins_grupo = g.id_ins_grupo)))
     LEFT JOIN aca_programa_aprobado pa ON ((g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     LEFT JOIN aca_programa prog ON ((pa.id_aca_programa = prog.id_aca_programa)))
     LEFT JOIN aca_tipo_estudiante te ON ((m.id_aca_tipo_estudiante = te.id_aca_tipo_estudiante)))
     LEFT JOIN aca_colegio col ON ((p.id_aca_colegio_procedencia = col.id_aca_colegio)))
     LEFT JOIN fin_convenio conv ON ((m.id_fin_convenio_aplicado = conv.id_fin_convenio)))
     LEFT JOIN LATERAL ( SELECT sum(op.saldo_pendiente) AS deuda_total,
            count(*) FILTER (WHERE (op.saldo_pendiente > (0)::numeric)) AS obligaciones_pendientes
           FROM fin_obligacion_pago op
          WHERE ((op.cod_ins_matricula = m.cod_ins_matricula) AND ((op.estado_obligacion_pago)::text <> 'ELIMINADO'::text))) deudas ON (true))
  WHERE (((m.estado_matricula)::text <> 'ELIMINADO'::text) AND ((p.estado_persona)::text <> 'ELIMINADO'::text));;


CREATE OR REPLACE VIEW vista_estudiantes_por_cronograma AS
 SELECT prog.id_eje_cronograma_modulo,
    prog.cod_ins_matricula,
    p.nombre,
    p.ap_paterno,
    p.ap_materno,
    p.ci,
    m.tipo_matricula,
    prog.fecha_programacion,
    prog.nota_final
   FROM ((eje_programacion prog
     JOIN ins_matricula m ON ((prog.cod_ins_matricula = m.cod_ins_matricula)))
     JOIN prs_persona p ON ((m.id_prs_persona = p.id_prs_persona)))
  WHERE (((prog.estado_programacion)::text <> 'ELIMINADO'::text) AND ((m.estado_matricula)::text <> 'ELIMINADO'::text) AND ((p.estado_persona)::text <> 'ELIMINADO'::text))
  ORDER BY p.ap_paterno, p.ap_materno, p.nombre;;


CREATE OR REPLACE VIEW vista_estudiantes_por_grupo AS
 SELECT g.id_ins_grupo,
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
   FROM ((ins_grupo g
     JOIN ins_matricula mat ON ((g.id_ins_grupo = mat.id_ins_grupo)))
     JOIN prs_persona p ON ((mat.id_prs_persona = p.id_prs_persona)))
  WHERE ((mat.estado_matricula)::text <> 'ELIMINADO'::text)
  ORDER BY g.id_ins_grupo, p.ap_paterno, p.ap_materno, p.nombre;;


CREATE OR REPLACE VIEW vista_fin_conceptos_pago_activos AS
 SELECT fin_concepto_pago.id_fin_concepto_pago,
    fin_concepto_pago.nombre_concepto,
    fin_concepto_pago.descripcion,
    fin_concepto_pago.estado_concepto_pago
   FROM fin_concepto_pago
  WHERE ((fin_concepto_pago.estado_concepto_pago)::text <> 'ELIMINADO'::text);;


CREATE OR REPLACE VIEW vista_gestiones_periodos AS
 SELECT g.id_aca_gestion,
    g.anio,
    g.fecha_inicio AS gestion_inicio,
    g.fecha_fin AS gestion_fin,
    g.estado_gestion,
    p.id_aca_periodo,
    p.codigo_periodo,
    p.nombre_periodo,
    p.tipo_periodo,
    p.numero_periodo,
    p.fecha_inicio AS periodo_inicio,
    p.fecha_fin AS periodo_fin,
    p.estado_periodo,
        CASE
            WHEN ((p.fecha_inicio <= CURRENT_DATE) AND (p.fecha_fin >= CURRENT_DATE)) THEN true
            ELSE false
        END AS es_periodo_actual
   FROM (aca_gestion g
     LEFT JOIN aca_periodo p ON (((g.id_aca_gestion = p.id_aca_gestion) AND ((p.estado_periodo)::text <> 'ELIMINADO'::text))))
  WHERE ((g.estado_gestion)::text <> 'ELIMINADO'::text)
  ORDER BY g.anio DESC, p.numero_periodo;;


CREATE OR REPLACE VIEW vista_grupos_completos AS
 SELECT g.id_ins_grupo,
    g.nombre_grupo,
    g.fecha_inicio_inscripcion,
    g.fecha_fin_inscripcion,
    g.estado_grupo,
    g.gestion_inicio,
    pa.gestion,
    pa.id_aca_programa_aprobado,
    p.nombre_programa,
    p.sigla AS programa_sigla,
    a.nombre_area,
    m.nombre_modalidad,
    pe.anho AS plan_anho,
    v.cod_version,
    count(DISTINCT mat.cod_ins_matricula) AS total_estudiantes,
    count(DISTINCT cm.id_eje_cronograma_modulo) AS total_cronogramas
   FROM ((((((((ins_grupo g
     JOIN aca_programa_aprobado pa ON ((g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     JOIN aca_programa p ON ((pa.id_aca_programa = p.id_aca_programa)))
     JOIN aca_area a ON ((p.id_aca_area = a.id_aca_area)))
     JOIN aca_modalidad m ON ((pa.id_aca_modalidad = m.id_aca_modalidad)))
     LEFT JOIN aca_plan_estudio pe ON ((pa.id_aca_plan_estudio = pe.id_aca_plan_estudio)))
     LEFT JOIN aca_version v ON ((pa.id_aca_version = v.id_aca_version)))
     LEFT JOIN ins_matricula mat ON (((g.id_ins_grupo = mat.id_ins_grupo) AND ((mat.estado_matricula)::text = 'ACTIVO'::text))))
     LEFT JOIN eje_cronograma_modulo cm ON (((g.id_ins_grupo = cm.id_ins_grupo) AND ((cm.estado_cronograma_modulo)::text = 'ACTIVO'::text))))
  WHERE ((g.estado_grupo)::text <> 'ELIMINADO'::text)
  GROUP BY g.id_ins_grupo, g.nombre_grupo, g.fecha_inicio_inscripcion, g.fecha_fin_inscripcion, pa.id_aca_programa_aprobado, g.estado_grupo, g.gestion_inicio, pa.gestion, p.nombre_programa, p.sigla, a.nombre_area, m.nombre_modalidad, pe.anho, v.cod_version
  ORDER BY g.gestion_inicio DESC, g.nombre_grupo;;


CREATE OR REPLACE VIEW vista_grupos_con_cronogramas AS
 SELECT g.id_ins_grupo,
    g.nombre_grupo,
    g.fecha_inicio_inscripcion,
    g.fecha_fin_inscripcion,
    g.estado_grupo,
    g.gestion_inicio,
    pa.id_aca_programa_aprobado,
    p.nombre_programa,
    p.sigla AS programa_sigla,
    a.nombre_area,
    m.nombre_modalidad,
    pa.gestion,
    count(DISTINCT mat.cod_ins_matricula) AS total_estudiantes,
    cm.id_eje_cronograma_modulo,
    mod.nombre_modulo,
    niv.nombre_nivel,
    pmd.orden AS modulo_orden,
    pmd.carga_horaria,
    pmd.creditos,
        CASE
            WHEN ((COALESCE(pa.cod_sigla_version, p.sigla))::text ~ '^[A-Z]+ [0-9]+$'::text) THEN ((TRIM(BOTH FROM split_part((COALESCE(pa.cod_sigla_version, p.sigla))::text, ' '::text, 1)) || ' '::text) || (((split_part((COALESCE(pa.cod_sigla_version, p.sigla))::text, ' '::text, 2))::integer + pmd.orden))::text)
            ELSE ((upper(regexp_replace((COALESCE(pa.cod_sigla_version, p.sigla, ''::character varying))::text, '[^A-Za-z]'::text, ''::text, 'g'::text)) || ' '::text) || ((100 + pmd.orden))::text)
        END AS sigla,
    cm.fecha_inicio,
    cm.fecha_fin,
    cm.estado_cronograma_modulo,
    d.id_eje_docente,
    concat(pd.nombre, ' ', pd.ap_paterno, ' ', COALESCE(pd.ap_materno, ''::character varying)) AS docente_nombre_completo,
    pd.ci AS docente_ci
   FROM (((((((((((ins_grupo g
     JOIN aca_programa_aprobado pa ON ((g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     JOIN aca_programa p ON ((pa.id_aca_programa = p.id_aca_programa)))
     JOIN aca_area a ON ((p.id_aca_area = a.id_aca_area)))
     JOIN aca_modalidad m ON ((pa.id_aca_modalidad = m.id_aca_modalidad)))
     LEFT JOIN ins_matricula mat ON (((g.id_ins_grupo = mat.id_ins_grupo) AND ((mat.estado_matricula)::text = 'ACTIVO'::text))))
     LEFT JOIN eje_cronograma_modulo cm ON (((g.id_ins_grupo = cm.id_ins_grupo) AND ((cm.estado_cronograma_modulo)::text <> 'ELIMINADO'::text))))
     LEFT JOIN aca_plan_modulo_detalle pmd ON ((cm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle)))
     LEFT JOIN aca_modulo mod ON ((pmd.id_aca_modulo = mod.id_aca_modulo)))
     LEFT JOIN aca_nivel niv ON ((pmd.id_aca_nivel = niv.id_aca_nivel)))
     LEFT JOIN eje_docente d ON ((cm.id_eje_docente = d.id_eje_docente)))
     LEFT JOIN prs_persona pd ON ((d.id_prs_persona = pd.id_prs_persona)))
  WHERE ((g.estado_grupo)::text <> 'ELIMINADO'::text)
  GROUP BY g.id_ins_grupo, g.nombre_grupo, g.fecha_inicio_inscripcion, g.fecha_fin_inscripcion, g.estado_grupo, g.gestion_inicio, pa.id_aca_programa_aprobado, p.nombre_programa, p.sigla, a.nombre_area, m.nombre_modalidad, pa.gestion, cm.id_eje_cronograma_modulo, mod.nombre_modulo, niv.nombre_nivel, pmd.orden, pmd.carga_horaria, pmd.creditos, pa.cod_sigla_version, cm.fecha_inicio, cm.fecha_fin, cm.estado_cronograma_modulo, d.id_eje_docente, pd.nombre, pd.ap_paterno, pd.ap_materno, pd.ci
  ORDER BY g.gestion_inicio DESC, g.nombre_grupo, pmd.orden;;


CREATE OR REPLACE VIEW vista_grupos_matriculacion AS
 SELECT g.id_ins_grupo,
    g.nombre_grupo,
    g.fecha_inicio_inscripcion,
    g.fecha_fin_inscripcion,
    g.estado_grupo,
    g.gestion_inicio,
    pa.id_aca_programa_aprobado,
    prog.nombre_programa,
    area.nombre_area,
    modal.nombre_modalidad,
    pa.gestion,
    count(mat.cod_ins_matricula) AS total_matriculados,
        CASE
            WHEN (CURRENT_DATE < g.fecha_inicio_inscripcion) THEN 'PROXIMAMENTE'::text
            WHEN ((CURRENT_DATE >= g.fecha_inicio_inscripcion) AND (CURRENT_DATE <= COALESCE(g.fecha_fin_inscripcion, CURRENT_DATE))) THEN 'INSCRIPCIONES ABIERTAS'::text
            WHEN (CURRENT_DATE > COALESCE(g.fecha_fin_inscripcion, CURRENT_DATE)) THEN 'INSCRIPCIONES CERRADAS'::text
            ELSE 'SIN DEFINIR'::text
        END AS estado_inscripcion
   FROM (((((ins_grupo g
     JOIN aca_programa_aprobado pa ON ((g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     JOIN aca_programa prog ON ((pa.id_aca_programa = prog.id_aca_programa)))
     JOIN aca_area area ON ((prog.id_aca_area = area.id_aca_area)))
     JOIN aca_modalidad modal ON ((pa.id_aca_modalidad = modal.id_aca_modalidad)))
     LEFT JOIN ins_matricula mat ON (((g.id_ins_grupo = mat.id_ins_grupo) AND ((mat.estado_matricula)::text <> 'ELIMINADO'::text))))
  WHERE (((g.estado_grupo)::text <> 'ELIMINADO'::text) AND ((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text) AND ((prog.estado_programa)::text <> 'ELIMINADO'::text) AND ((area.estado_area)::text <> 'ELIMINADO'::text) AND ((modal.estado_modalidad)::text <> 'ELIMINADO'::text))
  GROUP BY g.id_ins_grupo, g.nombre_grupo, g.fecha_inicio_inscripcion, g.fecha_fin_inscripcion, g.estado_grupo, g.gestion_inicio, pa.id_aca_programa_aprobado, prog.nombre_programa, area.nombre_area, modal.nombre_modalidad, pa.gestion
  ORDER BY g.gestion_inicio DESC, g.nombre_grupo;;


CREATE OR REPLACE VIEW vista_matriculados_grupo AS
 WITH progreso_academico AS (
         SELECT m_1.cod_ins_matricula,
            count(DISTINCT ep.id_eje_programacion) AS modulos_cursados,
            count(DISTINCT
                CASE
                    WHEN (ep.nota_final >= 60) THEN ep.id_eje_programacion
                    ELSE NULL::integer
                END) AS modulos_aprobados,
            count(DISTINCT
                CASE
                    WHEN ((ep.estado_programacion)::text = 'EN_CURSO'::text) THEN ep.id_eje_programacion
                    ELSE NULL::integer
                END) AS modulos_en_curso,
            round(avg(
                CASE
                    WHEN (ep.nota_final IS NOT NULL) THEN ep.nota_final
                    ELSE NULL::integer
                END), 2) AS promedio_notas
           FROM (ins_matricula m_1
             LEFT JOIN eje_programacion ep ON ((m_1.cod_ins_matricula = ep.cod_ins_matricula)))
          GROUP BY m_1.cod_ins_matricula
        ), estado_financiero AS (
         SELECT m_1.cod_ins_matricula,
            COALESCE(sum(fop.saldo_pendiente), (0)::numeric) AS deuda_total,
            count(
                CASE
                    WHEN ((fop.estado_obligacion_pago)::text = 'PENDIENTE'::text) THEN 1
                    ELSE NULL::integer
                END) AS obligaciones_pendientes,
            max(
                CASE
                    WHEN (fop.saldo_pendiente > (0)::numeric) THEN 'CON_DEUDA'::text
                    ELSE 'AL_DIA'::text
                END) AS estado_financiero
           FROM (ins_matricula m_1
             LEFT JOIN fin_obligacion_pago fop ON ((m_1.cod_ins_matricula = fop.cod_ins_matricula)))
          GROUP BY m_1.cod_ins_matricula
        )
 SELECT g.id_ins_grupo,
    g.nombre_grupo,
    g.gestion_inicio,
    prog.nombre_programa,
    prog.sigla AS sigla_programa,
    mod.nombre_modalidad,
    m.cod_ins_matricula,
    p.ci AS cedula_identidad,
    concat(p.nombre, ' ', p.ap_paterno,
        CASE
            WHEN (p.ap_materno IS NOT NULL) THEN concat(' ', p.ap_materno)
            ELSE ''::text
        END) AS nombre_completo,
    p.nro_celular,
    p.correo,
    m.estado_matricula,
    m.tipo_matricula,
    m.fecha_reg AS fecha_matricula,
    COALESCE(pa.modulos_cursados, (0)::bigint) AS modulos_cursados,
    COALESCE(pa.modulos_aprobados, (0)::bigint) AS modulos_aprobados,
    COALESCE(pa.modulos_en_curso, (0)::bigint) AS modulos_en_curso,
    pa.promedio_notas,
        CASE
            WHEN (count(pmd.id_aca_plan_modulo_detalle) OVER (PARTITION BY apa.id_aca_plan_estudio) > 0) THEN round((((COALESCE(pa.modulos_aprobados, (0)::bigint))::numeric * 100.0) / (count(pmd.id_aca_plan_modulo_detalle) OVER (PARTITION BY apa.id_aca_plan_estudio))::numeric), 2)
            ELSE (0)::numeric
        END AS porcentaje_avance,
    COALESCE(ef.deuda_total, (0)::numeric) AS deuda_total,
    COALESCE(ef.obligaciones_pendientes, (0)::bigint) AS obligaciones_pendientes,
    COALESCE(ef.estado_financiero, 'AL_DIA'::text) AS estado_financiero,
        CASE
            WHEN (((m.estado_matricula)::text = 'ACTIVO'::text) AND (ef.estado_financiero = 'AL_DIA'::text)) THEN 'REGULAR'::text
            WHEN (((m.estado_matricula)::text = 'ACTIVO'::text) AND (ef.estado_financiero = 'CON_DEUDA'::text)) THEN 'MOROSO'::text
            WHEN ((m.estado_matricula)::text = 'SUSPENDIDO'::text) THEN 'SUSPENDIDO'::text
            WHEN ((m.estado_matricula)::text = 'GRADUADO'::text) THEN 'GRADUADO'::text
            ELSE 'INACTIVO'::text
        END AS situacion_academica,
    g.fecha_inicio_inscripcion,
    g.fecha_fin_inscripcion,
    m.user_reg AS registrado_por,
    m.fecha_mod AS ultima_modificacion
   FROM ((((((((ins_matricula m
     JOIN ins_grupo g ON ((m.id_ins_grupo = g.id_ins_grupo)))
     JOIN prs_persona p ON ((m.id_prs_persona = p.id_prs_persona)))
     JOIN aca_programa_aprobado apa ON ((g.id_aca_programa_aprobado = apa.id_aca_programa_aprobado)))
     JOIN aca_programa prog ON ((apa.id_aca_programa = prog.id_aca_programa)))
     JOIN aca_modalidad mod ON ((apa.id_aca_modalidad = mod.id_aca_modalidad)))
     LEFT JOIN progreso_academico pa ON ((m.cod_ins_matricula = pa.cod_ins_matricula)))
     LEFT JOIN estado_financiero ef ON ((m.cod_ins_matricula = ef.cod_ins_matricula)))
     LEFT JOIN aca_plan_modulo_detalle pmd ON ((apa.id_aca_plan_estudio = pmd.id_aca_plan_estudio)));;


CREATE OR REPLACE VIEW vista_modalidades_activas AS
 SELECT aca_modalidad.id_aca_modalidad,
    aca_modalidad.nombre_modalidad,
    aca_modalidad.estado_modalidad
   FROM aca_modalidad
  WHERE ((aca_modalidad.estado_modalidad)::text <> 'ELIMINADO'::text)
  ORDER BY aca_modalidad.nombre_modalidad;;


CREATE OR REPLACE VIEW vista_modulos_activos AS
 SELECT aca_modulo.id_aca_modulo,
    aca_modulo.nombre_modulo,
    aca_modulo.estado_modulo
   FROM aca_modulo
  WHERE ((aca_modulo.estado_modulo)::text = 'ACTIVO'::text)
  ORDER BY aca_modulo.nombre_modulo;;


CREATE OR REPLACE VIEW vista_modulos_disponibles_nivel AS
 SELECT DISTINCT mod.id_aca_modulo,
    mod.nombre_modulo,
    niv.id_aca_nivel,
    niv.nombre_nivel
   FROM (aca_modulo mod
     CROSS JOIN aca_nivel niv)
  WHERE (((mod.estado_modulo)::text = 'ACTIVO'::text) AND ((niv.estado_nivel)::text = 'ACTIVO'::text))
  ORDER BY niv.nombre_nivel, mod.nombre_modulo;;


CREATE OR REPLACE VIEW vista_modulos_plan_detalle AS
 SELECT pmd.id_aca_plan_modulo_detalle,
    pmd.id_aca_plan_estudio,
    pmd.id_aca_nivel,
    pmd.id_aca_modulo,
    pmd.carga_horaria,
    pmd.creditos,
    pmd.orden,
    pmd.sigla,
    pmd.competencia,
    pmd.estado_plan_modulo_detalle,
    mod.nombre_modulo,
    mod.estado_modulo,
    niv.nombre_nivel,
    niv.estado_nivel,
    pe.anho AS plan_anho,
    pe.vigente AS plan_vigente
   FROM (((aca_plan_modulo_detalle pmd
     JOIN aca_modulo mod ON ((pmd.id_aca_modulo = mod.id_aca_modulo)))
     JOIN aca_nivel niv ON ((pmd.id_aca_nivel = niv.id_aca_nivel)))
     JOIN aca_plan_estudio pe ON ((pmd.id_aca_plan_estudio = pe.id_aca_plan_estudio)))
  WHERE (((pmd.estado_plan_modulo_detalle)::text = 'ACTIVO'::text) AND ((mod.estado_modulo)::text = 'ACTIVO'::text) AND ((niv.estado_nivel)::text = 'ACTIVO'::text) AND ((pe.estado_plan_estudio)::text = 'ACTIVO'::text));;


CREATE OR REPLACE VIEW vista_niveles_activos AS
 SELECT aca_nivel.id_aca_nivel,
    aca_nivel.nombre_nivel,
    aca_nivel.estado_nivel
   FROM aca_nivel
  WHERE ((aca_nivel.estado_nivel)::text <> 'ELIMINADO'::text);;


CREATE OR REPLACE VIEW vista_noticias_activas AS
 SELECT n.id_pub_noticia,
    n.id_aca_unidad,
    u.nombre_unidad,
    n.titulo,
    n.resumen,
    n.contenido,
    n.imagen_uri,
    n.enlace_externo,
    n.fecha_noticia,
    n.es_destacada,
    n.orden_prioridad,
    n.estado_noticia,
    n.fecha_reg,
    n.fecha_mod,
        CASE
            WHEN (n.es_destacada = true) THEN 'DESTACADA'::text
            ELSE 'NORMAL'::text
        END AS tipo_noticia
   FROM (pub_noticia n
     JOIN aca_unidad u ON ((n.id_aca_unidad = u.id_aca_unidad)))
  WHERE (((n.estado_noticia)::text = 'ACTIVO'::text) AND ((u.estado_unidad)::text = 'ACTIVO'::text))
  ORDER BY n.orden_prioridad DESC, n.fecha_noticia DESC, n.fecha_reg DESC;;


CREATE OR REPLACE VIEW vista_noticias_admin AS
 SELECT pn.id_pub_noticia,
    pn.id_aca_unidad,
    au.nombre_unidad,
    pn.titulo,
    pn.resumen,
    pn.contenido,
    pn.imagen_uri,
    pn.enlace_externo,
    pn.fecha_noticia,
    pn.es_destacada,
    pn.orden_prioridad,
    pn.estado_noticia,
    pn.fecha_reg,
    pn.fecha_mod,
    su.nombre_usuario AS usuario_registro
   FROM ((pub_noticia pn
     JOIN aca_unidad au ON ((pn.id_aca_unidad = au.id_aca_unidad)))
     LEFT JOIN seg_usuario su ON ((pn.user_reg = su.id_seg_usuario)))
  WHERE ((pn.estado_noticia)::text <> 'ELIMINADO'::text)
  ORDER BY pn.es_destacada DESC, pn.orden_prioridad DESC, pn.fecha_noticia DESC;;


CREATE OR REPLACE VIEW vista_noticias_carrusel AS
 SELECT n.id_pub_noticia,
    n.titulo,
    n.resumen,
    n.imagen_uri,
    n.enlace_externo,
    n.fecha_noticia,
    u.nombre_unidad,
    n.es_destacada,
    n.orden_prioridad
   FROM (pub_noticia n
     JOIN aca_unidad u ON ((n.id_aca_unidad = u.id_aca_unidad)))
  WHERE (((n.estado_noticia)::text = 'ACTIVO'::text) AND ((u.estado_unidad)::text = 'ACTIVO'::text) AND (n.fecha_noticia <= CURRENT_DATE))
  ORDER BY n.es_destacada DESC, n.orden_prioridad DESC, n.fecha_noticia DESC
 LIMIT 10;;


CREATE OR REPLACE VIEW vista_obligaciones_pago_programa AS
 SELECT p.id_prs_persona,
    p.nombre,
    p.ap_paterno,
    p.ap_materno,
    p.ci,
    p.nro_celular,
    p.correo,
    pa.id_aca_programa_aprobado,
    prog.nombre_programa,
    prog.sigla AS sigla_programa,
    area.nombre_area,
    modal.nombre_modalidad,
    g.id_ins_grupo,
    g.nombre_grupo,
    g.gestion_inicio,
    m.cod_ins_matricula,
    m.tipo_matricula,
    m.estado_matricula,
    op.id_fin_obligacion_pago,
    cp.nombre_concepto,
    cp.descripcion AS concepto_descripcion,
    op.deuda_sin_descuento,
    op.deuda_con_descuento,
    op.saldo_pendiente,
    op.observacion,
    op.estado_obligacion_pago,
    op.fecha_reg AS fecha_obligacion,
    param.nombre_param,
    param.valor AS valor_parametro,
        CASE
            WHEN (op.saldo_pendiente = (0)::numeric) THEN 'PAGADO'::text
            WHEN (op.saldo_pendiente < op.deuda_con_descuento) THEN 'PAGO_PARCIAL'::text
            ELSE 'PENDIENTE'::text
        END AS estado_pago
   FROM (((((((((fin_obligacion_pago op
     JOIN ins_matricula m ON ((op.cod_ins_matricula = m.cod_ins_matricula)))
     JOIN prs_persona p ON ((m.id_prs_persona = p.id_prs_persona)))
     JOIN ins_grupo g ON ((m.id_ins_grupo = g.id_ins_grupo)))
     JOIN aca_programa_aprobado pa ON ((g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     JOIN aca_programa prog ON ((pa.id_aca_programa = prog.id_aca_programa)))
     JOIN aca_area area ON ((prog.id_aca_area = area.id_aca_area)))
     JOIN aca_modalidad modal ON ((pa.id_aca_modalidad = modal.id_aca_modalidad)))
     JOIN fin_concepto_pago cp ON ((op.id_fin_concepto_pago = cp.id_fin_concepto_pago)))
     LEFT JOIN aca_parametro_programa param ON ((op.id_aca_parametro = param.id_aca_parametro)))
  WHERE (((op.estado_obligacion_pago)::text <> 'ELIMINADO'::text) AND ((m.estado_matricula)::text <> 'ELIMINADO'::text) AND ((p.estado_persona)::text <> 'ELIMINADO'::text) AND ((g.estado_grupo)::text <> 'ELIMINADO'::text) AND ((cp.estado_concepto_pago)::text <> 'ELIMINADO'::text))
  ORDER BY prog.nombre_programa, g.nombre_grupo, p.ap_paterno, p.ap_materno, p.nombre;;


CREATE OR REPLACE VIEW vista_periodo_actual AS
 SELECT p.id_aca_periodo,
    p.codigo_periodo,
    p.nombre_periodo,
    p.tipo_periodo,
    g.anio,
    p.fecha_inicio,
    p.fecha_fin,
    (p.fecha_fin - CURRENT_DATE) AS dias_restantes
   FROM (aca_periodo p
     JOIN aca_gestion g ON ((p.id_aca_gestion = g.id_aca_gestion)))
  WHERE ((p.fecha_inicio <= CURRENT_DATE) AND (p.fecha_fin >= CURRENT_DATE) AND ((p.estado_periodo)::text = 'ACTIVO'::text) AND ((g.estado_gestion)::text = 'ACTIVO'::text))
 LIMIT 1;;


CREATE OR REPLACE VIEW vista_personas_activas AS
 SELECT prs_persona.id_prs_persona,
    prs_persona.nombre,
    prs_persona.ap_paterno,
    prs_persona.ap_materno,
    prs_persona.ci,
    prs_persona.nro_celular,
    prs_persona.correo,
    prs_persona.fecha_nacimiento
   FROM prs_persona
  WHERE ((prs_persona.estado_persona)::text <> 'ELIMINADO'::text);;


CREATE OR REPLACE VIEW vista_personas_formulario AS
 SELECT p.id_prs_persona,
    p.nombre,
    p.ap_paterno,
    p.ap_materno,
    p.ci,
    p.nro_celular,
    p.correo,
    p.fecha_nacimiento,
    p.estado_persona,
    concat(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, ''::character varying)) AS nombre_completo,
    date_part('year'::text, age((p.fecha_nacimiento)::timestamp with time zone)) AS edad
   FROM prs_persona p
  WHERE ((p.estado_persona)::text <> 'ELIMINADO'::text);;


CREATE OR REPLACE VIEW vista_plan_estudio_con_contexto AS
 SELECT DISTINCT pe.id_aca_plan_estudio,
    pe.anho,
    pe.vigente,
    concat('Plan ', pe.anho,
        CASE
            WHEN pe.vigente THEN ' (Vigente)'::text
            ELSE ' (Sin vigencia)'::text
        END,
        CASE
            WHEN (count(pa.id_aca_programa_aprobado) > 0) THEN concat(' - Usado por: ', string_agg(DISTINCT concat(p.nombre_programa, ' (', m.nombre_modalidad, ' - ', v.cod_version, ' - ', pa.gestion, ')'), ', '::text))
            ELSE ' - Sin programas asignados'::text
        END) AS descripcion_plan
   FROM ((((aca_plan_estudio pe
     LEFT JOIN aca_programa_aprobado pa ON (((pe.id_aca_plan_estudio = pa.id_aca_plan_estudio) AND ((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text))))
     LEFT JOIN aca_programa p ON (((pa.id_aca_programa = p.id_aca_programa) AND ((p.estado_programa)::text <> 'ELIMINADO'::text))))
     LEFT JOIN aca_modalidad m ON (((pa.id_aca_modalidad = m.id_aca_modalidad) AND ((m.estado_modalidad)::text <> 'ELIMINADO'::text))))
     LEFT JOIN aca_version v ON (((pa.id_aca_version = v.id_aca_version) AND ((v.estado_version)::text <> 'ELIMINADO'::text))))
  WHERE ((pe.estado_plan_estudio)::text <> 'ELIMINADO'::text)
  GROUP BY pe.id_aca_plan_estudio, pe.anho, pe.vigente
  ORDER BY pe.vigente DESC, pe.anho DESC;;


CREATE OR REPLACE VIEW vista_plan_estudio_detalle AS
 SELECT pe.id_aca_plan_estudio,
    pe.anho,
    pe.vigente,
    pe.estado_plan_estudio,
    pe.fecha_reg,
    pe.fecha_mod,
    pe.user_reg,
    pe.user_mod
   FROM aca_plan_estudio pe
  WHERE ((pe.estado_plan_estudio)::text = 'ACTIVO'::text);;


CREATE OR REPLACE VIEW vista_plan_estudio_estadisticas AS
 SELECT pe.id_aca_plan_estudio,
    pe.anho,
    pe.vigente,
    count(DISTINCT pmd.id_aca_plan_modulo_detalle) AS total_modulos,
    sum(pmd.carga_horaria) AS total_horas,
    sum(pmd.creditos) AS total_creditos,
    count(DISTINCT pmd.id_aca_nivel) AS niveles_con_modulos,
    count(DISTINCT pa.id_aca_programa_aprobado) AS programas_asociados
   FROM ((aca_plan_estudio pe
     LEFT JOIN aca_plan_modulo_detalle pmd ON (((pe.id_aca_plan_estudio = pmd.id_aca_plan_estudio) AND ((pmd.estado_plan_modulo_detalle)::text = 'ACTIVO'::text))))
     LEFT JOIN aca_programa_aprobado pa ON (((pe.id_aca_plan_estudio = pa.id_aca_plan_estudio) AND ((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text))))
  WHERE ((pe.estado_plan_estudio)::text = 'ACTIVO'::text)
  GROUP BY pe.id_aca_plan_estudio, pe.anho, pe.vigente;;


CREATE OR REPLACE VIEW vista_planes_con_contexto AS
 SELECT pe.id_aca_plan_estudio,
    pe.anho,
    pe.vigente,
    pe.estado_plan_estudio,
        CASE
            WHEN (count(DISTINCT pa.id_aca_programa) = 0) THEN concat('Plan ', pe.anho, ' - Sin programas asignados')
            ELSE concat('Plan ', pe.anho, ' - Usado por: ', string_agg(DISTINCT (p.sigla)::text, ', '::text ORDER BY (p.sigla)::text))
        END AS descripcion_plan,
    count(DISTINCT pa.id_aca_programa) AS total_programas,
    pe.fecha_reg,
    pe.user_reg
   FROM ((aca_plan_estudio pe
     LEFT JOIN aca_programa_aprobado pa ON (((pe.id_aca_plan_estudio = pa.id_aca_plan_estudio) AND ((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text))))
     LEFT JOIN aca_programa p ON (((pa.id_aca_programa = p.id_aca_programa) AND ((p.estado_programa)::text <> 'ELIMINADO'::text))))
  WHERE ((pe.estado_plan_estudio)::text <> 'ELIMINADO'::text)
  GROUP BY pe.id_aca_plan_estudio, pe.anho, pe.vigente, pe.estado_plan_estudio, pe.fecha_reg, pe.user_reg
  ORDER BY pe.anho DESC, pe.vigente DESC;;


CREATE OR REPLACE VIEW vista_planes_estudio_activos AS
 SELECT pe.id_aca_plan_estudio,
    pe.anho,
    pe.vigente,
    pe.estado_plan_estudio,
        CASE
            WHEN (pe.vigente = true) THEN (concat(pe.anho, ' (VIGENTE)'))::character varying
            ELSE (pe.anho)::character varying
        END AS anho_display,
    count(DISTINCT pmd.id_aca_modulo) AS total_modulos,
    sum(pmd.carga_horaria) AS total_horas
   FROM (aca_plan_estudio pe
     LEFT JOIN aca_plan_modulo_detalle pmd ON (((pe.id_aca_plan_estudio = pmd.id_aca_plan_estudio) AND ((pmd.estado_plan_modulo_detalle)::text <> 'ELIMINADO'::text))))
  WHERE ((pe.estado_plan_estudio)::text <> 'ELIMINADO'::text)
  GROUP BY pe.id_aca_plan_estudio, pe.anho, pe.vigente, pe.estado_plan_estudio
  ORDER BY pe.anho DESC, pe.vigente DESC;;


CREATE OR REPLACE VIEW vista_planes_estudio_con_uso AS
 SELECT pe.id_aca_plan_estudio,
    pe.anho,
    pe.vigente,
    pe.estado_plan_estudio,
    count(pa.id_aca_programa_aprobado) AS programas_usando,
    count(
        CASE
            WHEN ((pa.estado_programa_aprobado)::text = 'ACTIVO'::text) THEN 1
            ELSE NULL::integer
        END) AS programas_activos,
    string_agg(DISTINCT (p.nombre_programa)::text, ', '::text ORDER BY (p.nombre_programa)::text) AS programas_nombres
   FROM ((aca_plan_estudio pe
     LEFT JOIN aca_programa_aprobado pa ON (((pe.id_aca_plan_estudio = pa.id_aca_plan_estudio) AND ((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text))))
     LEFT JOIN aca_programa p ON ((pa.id_aca_programa = p.id_aca_programa)))
  WHERE ((pe.estado_plan_estudio)::text <> 'ELIMINADO'::text)
  GROUP BY pe.id_aca_plan_estudio, pe.anho, pe.vigente, pe.estado_plan_estudio
  ORDER BY pe.anho DESC, pe.vigente DESC;;


CREATE OR REPLACE VIEW vista_preinscritos_programa AS
 SELECT pre.id_ins_preinscripcion,
    pre.id_aca_programa_aprobado,
    pre.estado_preinscripcion,
    pre.fecha_reg AS fecha_preinscripcion,
    p.id_prs_persona,
    p.nombre,
    p.ap_paterno,
    p.ap_materno,
    p.ci,
    p.nro_celular,
    p.correo,
    p.fecha_nacimiento,
    concat(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, ''::character varying)) AS nombre_completo,
    date_part('year'::text, age((p.fecha_nacimiento)::timestamp with time zone)) AS edad,
    prog.nombre_programa,
    area.nombre_area,
    modal.nombre_modalidad,
    pa.gestion,
    pa.estado_programa_aprobado,
        CASE
            WHEN (mat.cod_ins_matricula IS NOT NULL) THEN 'MATRICULADO'::text
            ELSE 'NO MATRICULADO'::text
        END AS estado_matriculacion,
    mat.cod_ins_matricula,
    mat.tipo_matricula,
    mat.fecha_reg AS fecha_matriculacion,
    g.id_ins_grupo,
    g.nombre_grupo,
    g.fecha_inicio_inscripcion,
    g.fecha_fin_inscripcion,
    g.gestion_inicio
   FROM (((((((ins_preinscripcion pre
     JOIN prs_persona p ON ((pre.id_prs_persona = p.id_prs_persona)))
     JOIN aca_programa_aprobado pa ON ((pre.id_aca_programa_aprobado = pa.id_aca_programa_aprobado)))
     JOIN aca_programa prog ON ((pa.id_aca_programa = prog.id_aca_programa)))
     JOIN aca_area area ON ((prog.id_aca_area = area.id_aca_area)))
     JOIN aca_modalidad modal ON ((pa.id_aca_modalidad = modal.id_aca_modalidad)))
     LEFT JOIN ins_matricula mat ON (((p.id_prs_persona = mat.id_prs_persona) AND ((mat.estado_matricula)::text <> 'ELIMINADO'::text))))
     LEFT JOIN ins_grupo g ON (((mat.id_ins_grupo = g.id_ins_grupo) AND (g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado) AND ((g.estado_grupo)::text <> 'ELIMINADO'::text))))
  WHERE (((pre.estado_preinscripcion)::text <> 'ELIMINADO'::text) AND ((p.estado_persona)::text <> 'ELIMINADO'::text) AND ((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text) AND ((prog.estado_programa)::text <> 'ELIMINADO'::text) AND ((area.estado_area)::text <> 'ELIMINADO'::text) AND ((modal.estado_modalidad)::text <> 'ELIMINADO'::text));;


CREATE OR REPLACE VIEW vista_programas_activos AS
 SELECT p.id_aca_programa,
    p.nombre_programa,
    p.sigla,
    p.estado_programa,
    a.id_aca_area,
    a.nombre_area
   FROM (aca_programa p
     JOIN aca_area a ON ((p.id_aca_area = a.id_aca_area)))
  WHERE (((p.estado_programa)::text = 'ACTIVO'::text) AND ((a.estado_area)::text = 'ACTIVO'::text))
  ORDER BY p.nombre_programa;;


CREATE OR REPLACE VIEW vista_programas_aprobados AS
 SELECT pa.id_aca_programa_aprobado,
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
            WHEN (pe.vigente = true) THEN (concat(pe.anho, ' (VIGENTE)'))::character varying
            ELSE (pe.anho)::character varying
        END AS plan_descripcion,
    v.cod_version,
    pa.gestion,
    pa.estado_programa_aprobado,
    pa.cod_certificado_ceub,
    pa.precio_matricula,
    pa.precio_colegiatura,
    pa.precio_titulacion,
    pa.fecha_inicio_vigencia,
    pa.fecha_fin_vigencia,
    COALESCE(pa.imagen_programa_url, p.imagen_url) AS imagen_url,
    pa.fecha_reg,
    pa.fecha_mod,
    pa.user_reg,
    pa.user_mod
   FROM (((((aca_programa_aprobado pa
     JOIN aca_programa p ON ((pa.id_aca_programa = p.id_aca_programa)))
     JOIN aca_area a ON ((p.id_aca_area = a.id_aca_area)))
     JOIN aca_modalidad m ON ((pa.id_aca_modalidad = m.id_aca_modalidad)))
     LEFT JOIN aca_plan_estudio pe ON ((pa.id_aca_plan_estudio = pe.id_aca_plan_estudio)))
     LEFT JOIN aca_version v ON ((pa.id_aca_version = v.id_aca_version)))
  WHERE (((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text) AND ((p.estado_programa)::text <> 'ELIMINADO'::text) AND ((a.estado_area)::text <> 'ELIMINADO'::text) AND ((m.estado_modalidad)::text <> 'ELIMINADO'::text))
  ORDER BY pa.gestion DESC, p.nombre_programa;;


CREATE OR REPLACE VIEW vista_programas_aprobados_detalle AS
 SELECT pa.id_aca_programa_aprobado,
    p.id_aca_programa,
    p.nombre_programa,
    p.sigla AS programa_sigla,
    pa.sistema_programa,
    a.nombre_area,
    m.nombre_modalidad,
    pa.gestion,
    pa.estado_programa_aprobado,
    pe.anho AS plan_anho,
    v.cod_version,
    ( SELECT count(*) AS count
           FROM aca_certificacion_programa cp
          WHERE ((cp.id_aca_programa_aprobado = pa.id_aca_programa_aprobado) AND ((cp.estado_certificacion_programa)::text = 'ACTIVO'::text))) AS total_certificaciones
   FROM (((((aca_programa_aprobado pa
     JOIN aca_programa p ON ((pa.id_aca_programa = p.id_aca_programa)))
     JOIN aca_area a ON ((p.id_aca_area = a.id_aca_area)))
     JOIN aca_modalidad m ON ((pa.id_aca_modalidad = m.id_aca_modalidad)))
     LEFT JOIN aca_version v ON ((pa.id_aca_version = v.id_aca_version)))
     LEFT JOIN aca_plan_estudio pe ON ((pa.id_aca_plan_estudio = pe.id_aca_plan_estudio)))
  WHERE (((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text) AND ((p.estado_programa)::text = 'ACTIVO'::text) AND ((a.estado_area)::text = 'ACTIVO'::text) AND ((m.estado_modalidad)::text = 'ACTIVO'::text));;


CREATE OR REPLACE VIEW vista_programas_asociados_plan AS
 SELECT pa.id_aca_plan_estudio,
    pa.id_aca_programa_aprobado,
    p.id_aca_programa,
    p.nombre_programa AS programa_nombre,
    p.sigla AS programa_sigla,
    a.nombre_area AS area_nombre,
    m.nombre_modalidad AS modalidad_nombre,
    pa.gestion,
    pa.estado_programa_aprobado,
    pa.fecha_reg
   FROM (((aca_programa_aprobado pa
     JOIN aca_programa p ON ((pa.id_aca_programa = p.id_aca_programa)))
     JOIN aca_area a ON ((p.id_aca_area = a.id_aca_area)))
     JOIN aca_modalidad m ON ((pa.id_aca_modalidad = m.id_aca_modalidad)))
  WHERE ((pa.id_aca_plan_estudio IS NOT NULL) AND ((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text) AND ((p.estado_programa)::text = 'ACTIVO'::text) AND ((a.estado_area)::text = 'ACTIVO'::text) AND ((m.estado_modalidad)::text = 'ACTIVO'::text));;


CREATE OR REPLACE VIEW vista_programas_preinscripcion AS
 SELECT pa.id_aca_programa_aprobado,
    p.nombre_programa,
    a.nombre_area,
    m.nombre_modalidad,
    pa.gestion,
    pa.estado_programa_aprobado
   FROM (((aca_programa_aprobado pa
     JOIN aca_programa p ON ((pa.id_aca_programa = p.id_aca_programa)))
     JOIN aca_area a ON ((p.id_aca_area = a.id_aca_area)))
     JOIN aca_modalidad m ON ((pa.id_aca_modalidad = m.id_aca_modalidad)))
  WHERE (((pa.estado_programa_aprobado)::text <> 'ELIMINADO'::text) AND ((p.estado_programa)::text <> 'ELIMINADO'::text) AND ((a.estado_area)::text <> 'ELIMINADO'::text) AND ((m.estado_modalidad)::text <> 'ELIMINADO'::text));;


CREATE OR REPLACE VIEW vista_seg_roles_activos AS
 SELECT seg_rol.id_seg_rol,
    seg_rol.nombre_rol,
    seg_rol.descripcion,
    seg_rol.estado_rol
   FROM seg_rol
  WHERE ((seg_rol.estado_rol)::text <> 'ELIMINADO'::text);;


CREATE OR REPLACE VIEW vista_seg_tarea_activas AS
 SELECT seg_tarea.id_seg_tarea,
    seg_tarea.id_seg_rol,
    seg_tarea.nombre_tarea,
    seg_tarea.descripcion,
    seg_tarea.estado_tarea
   FROM seg_tarea
  WHERE ((seg_tarea.estado_tarea)::text <> 'ELIMINADO'::text);;


CREATE OR REPLACE VIEW vista_unidades_activas AS
 SELECT u.id_aca_unidad,
    u.nombre_unidad,
    u.descripcion,
    u.estado_unidad,
    u.fecha_reg,
    count(n.id_pub_noticia) AS total_noticias,
    count(n.id_pub_noticia) FILTER (WHERE ((n.estado_noticia)::text = 'ACTIVO'::text)) AS noticias_activas
   FROM (aca_unidad u
     LEFT JOIN pub_noticia n ON ((u.id_aca_unidad = n.id_aca_unidad)))
  WHERE ((u.estado_unidad)::text = 'ACTIVO'::text)
  GROUP BY u.id_aca_unidad, u.nombre_unidad, u.descripcion, u.estado_unidad, u.fecha_reg
  ORDER BY u.nombre_unidad;;


CREATE OR REPLACE VIEW vista_usuarios_permisos_resumen AS
 SELECT u.id_seg_usuario,
    u.nombre_usuario,
    u.estado_usuario,
    COALESCE((((((p.nombre)::text || ' '::text) || (p.ap_paterno)::text) || ' '::text) || (COALESCE(p.ap_materno, ''::character varying))::text), 'Sin nombre'::text) AS nombre_completo,
    COALESCE(p.ci, 'Sin CI'::character varying) AS ci_persona,
    COALESCE(p.correo, 'Sin correo'::character varying) AS correo,
    string_agg(DISTINCT (r.nombre_rol)::text, ', '::text ORDER BY (r.nombre_rol)::text) AS roles,
    string_agg(DISTINCT (t.nombre_tarea)::text, ', '::text ORDER BY (t.nombre_tarea)::text) AS permisos,
    count(DISTINCT t.id_seg_tarea) AS total_permisos,
    count(DISTINCT r.id_seg_rol) AS total_roles
   FROM (((((((seg_usuario u
     LEFT JOIN ( SELECT ed.id_seg_usuario,
            p_1.nombre,
            p_1.ap_paterno,
            p_1.ap_materno,
            p_1.ci,
            p_1.correo
           FROM (eje_docente ed
             JOIN prs_persona p_1 ON ((ed.id_prs_persona = p_1.id_prs_persona)))
          WHERE (((ed.estado_docente)::text <> 'ELIMINADO'::text) AND ((p_1.estado_persona)::text <> 'ELIMINADO'::text))
        UNION ALL
         SELECT ea.id_seg_usuario,
            p_1.nombre,
            p_1.ap_paterno,
            p_1.ap_materno,
            p_1.ci,
            p_1.correo
           FROM (eje_administrativo ea
             JOIN prs_persona p_1 ON ((ea.id_prs_persona = p_1.id_prs_persona)))
          WHERE (((ea.estado_administrativo)::text <> 'ELIMINADO'::text) AND ((p_1.estado_persona)::text <> 'ELIMINADO'::text))
        UNION ALL
         SELECT m.id_seg_usuario,
            p_1.nombre,
            p_1.ap_paterno,
            p_1.ap_materno,
            p_1.ci,
            p_1.correo
           FROM (ins_matricula m
             JOIN prs_persona p_1 ON ((m.id_prs_persona = p_1.id_prs_persona)))
          WHERE (((m.estado_matricula)::text <> 'ELIMINADO'::text) AND ((p_1.estado_persona)::text <> 'ELIMINADO'::text))) p ON ((u.id_seg_usuario = p.id_seg_usuario)))
     LEFT JOIN seg_ocupa o ON (((u.id_seg_usuario = o.id_seg_usuario) AND ((o.estado_ocupa)::text <> 'ELIMINADO'::text))))
     LEFT JOIN seg_rol r ON (((o.id_seg_rol = r.id_seg_rol) AND ((r.estado_rol)::text <> 'ELIMINADO'::text))))
     LEFT JOIN seg_tarea t_rol ON (((r.id_seg_rol = t_rol.id_seg_rol) AND ((t_rol.estado_tarea)::text <> 'ELIMINADO'::text))))
     LEFT JOIN seg_designa d ON (((u.id_seg_usuario = d.id_seg_usuario) AND ((d.estado_designa)::text <> 'ELIMINADO'::text))))
     LEFT JOIN seg_tarea t_directo ON (((d.id_seg_tarea = t_directo.id_seg_tarea) AND ((t_directo.estado_tarea)::text <> 'ELIMINADO'::text))))
     LEFT JOIN seg_tarea t ON ((t.id_seg_tarea = COALESCE(t_rol.id_seg_tarea, t_directo.id_seg_tarea))))
  WHERE ((u.estado_usuario)::text <> 'ELIMINADO'::text)
  GROUP BY u.id_seg_usuario, u.nombre_usuario, u.estado_usuario, p.nombre, p.ap_paterno, p.ap_materno, p.ci, p.correo
  ORDER BY COALESCE((((((p.nombre)::text || ' '::text) || (p.ap_paterno)::text) || ' '::text) || (COALESCE(p.ap_materno, ''::character varying))::text), 'Sin nombre'::text);;
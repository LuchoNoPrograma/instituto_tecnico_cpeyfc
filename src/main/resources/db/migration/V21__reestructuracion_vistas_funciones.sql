-- ============================================================================
-- MIGRACIÓN: Vistas y Funciones del Sistema Académico CORREGIDA
-- Versión: V026
-- Descripción: Actualización de vistas y funciones existentes + nuevas vistas
--              para soportar las nuevas tablas de periodos, convenios, aranceles
--              y certificaciones - VERSIÓN CORREGIDA
-- Autor: CPEyFP Dev Team
-- Fecha: 2025-01-XX
-- ============================================================================

-- ============================================================================
-- SECCIÓN 1: DROP DE VISTAS ANTIGUAS QUE SERÁN REEMPLAZADAS
-- ============================================================================

DROP VIEW IF EXISTS vista_estudiantes_grupo CASCADE;
DROP VIEW IF EXISTS vista_fin_estado_cuenta_estudiante CASCADE;
DROP VIEW IF EXISTS vista_programas_publicos CASCADE;
DROP VIEW IF EXISTS vista_cronogramas_por_usuario_docente CASCADE;

-- ============================================================================
-- SECCIÓN 2: VISTAS ACADÉMICAS BÁSICAS (SIN CAMBIOS)
-- ============================================================================

CREATE OR REPLACE VIEW vista_modulos_activos AS
SELECT
  id_aca_modulo,
  nombre_modulo,
  estado_modulo
FROM aca_modulo
WHERE estado_modulo = 'ACTIVO'
ORDER BY nombre_modulo;

COMMENT ON VIEW vista_modulos_activos IS 'Módulos/asignaturas activos';

CREATE OR REPLACE VIEW vista_niveles_activos AS
SELECT
  id_aca_nivel,
  nombre_nivel,
  estado_nivel
FROM aca_nivel
WHERE estado_nivel != 'ELIMINADO';

COMMENT ON VIEW vista_niveles_activos IS 'Niveles académicos activos';

CREATE OR REPLACE VIEW vista_planes_estudio_activos AS
SELECT
  pe.id_aca_plan_estudio,
  pe.anho,
  pe.vigente,
  pe.estado_plan_estudio,
  CASE
    WHEN pe.vigente = true THEN CONCAT(pe.anho, ' (VIGENTE)')
    ELSE pe.anho::VARCHAR
    END AS anho_display,
  COUNT(DISTINCT pmd.id_aca_modulo) as total_modulos,
  SUM(pmd.carga_horaria) as total_horas
FROM aca_plan_estudio pe
       LEFT JOIN aca_plan_modulo_detalle pmd ON pe.id_aca_plan_estudio = pmd.id_aca_plan_estudio
  AND pmd.estado_plan_modulo_detalle != 'ELIMINADO'
WHERE pe.estado_plan_estudio != 'ELIMINADO'
GROUP BY pe.id_aca_plan_estudio, pe.anho, pe.vigente, pe.estado_plan_estudio
ORDER BY pe.anho DESC, pe.vigente DESC;

COMMENT ON VIEW vista_planes_estudio_activos IS 'Planes de estudio con resumen de módulos y horas';

CREATE OR REPLACE VIEW vista_programas_activos AS
SELECT
  p.id_aca_programa,
  p.nombre_programa,
  p.sigla,
  p.estado_programa,
  a.id_aca_area,
  a.nombre_area
FROM aca_programa p
       JOIN aca_area a ON p.id_aca_area = a.id_aca_area
WHERE p.estado_programa = 'ACTIVO'
  AND a.estado_area = 'ACTIVO'
ORDER BY p.nombre_programa;

COMMENT ON VIEW vista_programas_activos IS 'Programas académicos activos';

CREATE OR REPLACE VIEW vista_programas_aprobados_detalle AS
SELECT
  pa.id_aca_programa_aprobado,
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
  -- Certificaciones disponibles
  (SELECT COUNT(*)
   FROM aca_certificacion_programa cp
   WHERE cp.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
     AND cp.estado_certificacion_programa = 'ACTIVO') as total_certificaciones
FROM aca_programa_aprobado pa
       JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       JOIN aca_area a ON p.id_aca_area = a.id_aca_area
       JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
       LEFT JOIN aca_version v ON pa.id_aca_version = v.id_aca_version
       LEFT JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
WHERE pa.estado_programa_aprobado != 'ELIMINADO'
  AND p.estado_programa = 'ACTIVO'
  AND a.estado_area = 'ACTIVO'
  AND m.estado_modalidad = 'ACTIVO';

COMMENT ON VIEW vista_programas_aprobados_detalle IS 'Programas aprobados con detalles completos';

-- ============================================================================
-- SECCIÓN 3: VISTAS DE PERIODOS Y GESTIONES (NUEVAS)
-- ============================================================================

CREATE OR REPLACE VIEW vista_gestiones_periodos AS
SELECT
  g.id_aca_gestion,
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
    WHEN p.fecha_inicio <= CURRENT_DATE AND p.fecha_fin >= CURRENT_DATE
      THEN true
    ELSE false
    END AS es_periodo_actual
FROM aca_gestion g
       LEFT JOIN aca_periodo p ON g.id_aca_gestion = p.id_aca_gestion
  AND p.estado_periodo != 'ELIMINADO'
WHERE g.estado_gestion != 'ELIMINADO'
ORDER BY g.anio DESC, p.numero_periodo;

COMMENT ON VIEW vista_gestiones_periodos IS 'Gestiones académicas con sus periodos';

CREATE OR REPLACE VIEW vista_periodo_actual AS
SELECT
  p.id_aca_periodo,
  p.codigo_periodo,
  p.nombre_periodo,
  p.tipo_periodo,
  g.anio,
  p.fecha_inicio,
  p.fecha_fin,
  (p.fecha_fin - CURRENT_DATE) as dias_restantes
FROM aca_periodo p
       JOIN aca_gestion g ON p.id_aca_gestion = g.id_aca_gestion
WHERE p.fecha_inicio <= CURRENT_DATE
  AND p.fecha_fin >= CURRENT_DATE
  AND p.estado_periodo = 'ACTIVO'
  AND g.estado_gestion = 'ACTIVO'
LIMIT 1;

COMMENT ON VIEW vista_periodo_actual IS 'Periodo académico vigente actualmente';

-- ============================================================================
-- SECCIÓN 4: VISTAS DE CRONOGRAMAS Y OFERTAS (ACTUALIZADAS)
-- ============================================================================

CREATE OR REPLACE VIEW vista_cursos_disponibles_inscripcion AS
SELECT
  pa.id_aca_programa_aprobado,
  p.nombre_programa,
  pa.sistema_programa,
  m.nombre_modulo,
  pmd.orden as nivel_orden,
  ecm.id_eje_cronograma_modulo,
  ecm.fecha_inicio,
  ecm.fecha_fin,
  ecm.fecha_inicio_inscripciones,
  ecm.fecha_fin_inscripciones,
  ecm.permite_inscripciones,
  per.nombre_periodo,
  per.id_aca_periodo,
  -- Docente
  CONCAT(pd.nombre, ' ', pd.ap_paterno, ' ', COALESCE(pd.ap_materno, '')) as docente_nombre,
  -- Grupo
  ig.id_ins_grupo,
  ig.nombre_grupo,
  ig.horario,
  ig.aula,
  -- Estudiantes matriculados
  (SELECT COUNT(*)
   FROM ins_matricula im
   WHERE im.id_ins_grupo = ig.id_ins_grupo
     AND im.estado_matricula = 'ACTIVO') as estudiantes_matriculados,
  -- Estado de inscripción
  CASE
    WHEN NOT ecm.permite_inscripciones THEN 'CERRADO'
    WHEN CURRENT_DATE < ecm.fecha_inicio_inscripciones THEN 'PROXIMAMENTE'
    WHEN CURRENT_DATE > ecm.fecha_fin_inscripciones THEN 'FINALIZADO'
    ELSE 'ABIERTO'
    END as estado_inscripcion
FROM eje_cronograma_modulo ecm
       JOIN ins_grupo ig ON ecm.id_ins_grupo = ig.id_ins_grupo
       JOIN aca_plan_modulo_detalle pmd ON ecm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle
       JOIN aca_modulo m ON pmd.id_aca_modulo = m.id_aca_modulo
       JOIN aca_programa_aprobado pa ON ig.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       LEFT JOIN aca_periodo per ON ecm.id_aca_periodo = per.id_aca_periodo
       LEFT JOIN eje_docente ed ON ecm.id_eje_docente = ed.id_eje_docente
       LEFT JOIN prs_persona pd ON ed.id_prs_persona = pd.id_prs_persona
WHERE ecm.estado_cronograma_modulo != 'ELIMINADO'
  AND pmd.estado_plan_modulo_detalle != 'ELIMINADO'
  AND ig.estado_grupo != 'ELIMINADO'
  AND pa.estado_programa_aprobado != 'ELIMINADO'
  AND p.estado_programa = 'ACTIVO';

COMMENT ON VIEW vista_cursos_disponibles_inscripcion IS 'Cursos disponibles para inscripción';

CREATE OR REPLACE VIEW vista_cronogramas_docente AS
SELECT
  ecm.id_eje_cronograma_modulo,
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
  CONCAT(pd.nombre, ' ', pd.ap_paterno, ' ', COALESCE(pd.ap_materno, '')) as docente_nombre,
  pd.ci as docente_ci,
  d.numero_contrato,
  -- Estudiantes
  COUNT(DISTINCT im.cod_ins_matricula) FILTER (WHERE im.estado_matricula = 'ACTIVO') as total_estudiantes,
  -- Criterios
  COUNT(DISTINCT ce.id_eje_criterio_eval) FILTER (WHERE ce.estado_criterio_eval != 'ELIMINADO') as total_criterios,
  ecm.estado_cronograma_modulo
FROM eje_cronograma_modulo ecm
       JOIN ins_grupo ig ON ecm.id_ins_grupo = ig.id_ins_grupo
       JOIN aca_plan_modulo_detalle pmd ON ecm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle
       JOIN aca_modulo m ON pmd.id_aca_modulo = m.id_aca_modulo
       JOIN aca_plan_estudio pe ON pmd.id_aca_plan_estudio = pe.id_aca_plan_estudio
       JOIN aca_programa_aprobado pa ON ig.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       JOIN aca_modalidad modal ON pa.id_aca_modalidad = modal.id_aca_modalidad
       LEFT JOIN aca_version v ON pa.id_aca_version = v.id_aca_version
       LEFT JOIN aca_periodo per ON ecm.id_aca_periodo = per.id_aca_periodo
       LEFT JOIN eje_docente d ON ecm.id_eje_docente = d.id_eje_docente
       LEFT JOIN prs_persona pd ON d.id_prs_persona = pd.id_prs_persona
       LEFT JOIN ins_matricula im ON ig.id_ins_grupo = im.id_ins_grupo
       LEFT JOIN eje_criterio_eval ce ON ecm.id_eje_cronograma_modulo = ce.id_eje_cronograma_modulo
WHERE ecm.estado_cronograma_modulo != 'ELIMINADO'
  AND pmd.estado_plan_modulo_detalle != 'ELIMINADO'
  AND ig.estado_grupo != 'ELIMINADO'
  AND pa.estado_programa_aprobado != 'ELIMINADO'
  AND (d.id_eje_docente IS NULL OR d.estado_docente != 'ELIMINADO')
GROUP BY
  ecm.id_eje_cronograma_modulo, ecm.fecha_inicio, ecm.fecha_fin,
  pmd.sigla, m.nombre_modulo, p.nombre_programa, pa.sistema_programa,
  pe.anho, v.cod_version, modal.nombre_modalidad,
  per.nombre_periodo, per.id_aca_periodo,
  ig.nombre_grupo, ig.horario, ig.aula,
  d.id_eje_docente, d.id_seg_usuario, d.numero_contrato,
  pd.nombre, pd.ap_paterno, pd.ap_materno, pd.ci,
  ecm.estado_cronograma_modulo
ORDER BY ecm.fecha_inicio DESC;

COMMENT ON VIEW vista_cronogramas_docente IS 'Cronogramas de módulos con información del docente';

-- ============================================================================
-- SECCIÓN 5: VISTAS DE ESTUDIANTES Y MATRÍCULAS (ACTUALIZADAS)
-- ============================================================================

CREATE OR REPLACE VIEW vista_estudiantes_grupo AS
SELECT
  m.cod_ins_matricula,
  p.id_prs_persona,
  p.ci,
  CONCAT(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, '')) AS nombre_completo,
  p.nro_celular,
  p.correo,
  m.estado_matricula,
  m.tipo_matricula,
  m.fecha_reg AS fecha_matricula,
  -- Grupo
  g.id_ins_grupo,
  g.nombre_grupo,
  g.horario,
  g.aula,
  -- Programa
  prog.nombre_programa,
  pa.sistema_programa,
  -- Tipo estudiante y colegio
  te.nombre_tipo as tipo_estudiante,
  te.es_nacional,
  col.nombre_colegio as colegio_procedencia,
  m.numero_periodo_cursando,
  m.es_estudiante_antiguo,
  -- Apoderado
  CASE
    WHEN p.id_prs_persona_apoderado IS NOT NULL
      THEN CONCAT(pa_apod.nombre, ' ', pa_apod.ap_paterno)
    ELSE NULL
    END as apoderado_nombre,
  p.tipo_relacion_apoderado,
  p.telefono_apoderado,
  -- Financiero
  COALESCE(deudas.deuda_total, 0) AS deuda_total,
  COALESCE(deudas.obligaciones_pendientes, 0) AS obligaciones_pendientes,
  CASE
    WHEN COALESCE(deudas.deuda_total, 0) > 0 THEN 'MOROSO'
    ELSE 'AL_DIA'
    END AS estado_financiero,
  -- Convenio
  conv.nombre_convenio,
  conv.tipo_descuento,
  conv.monto_descuento,
  conv.porcentaje_descuento
FROM ins_matricula m
       JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
       LEFT JOIN prs_persona pa_apod ON p.id_prs_persona_apoderado = pa_apod.id_prs_persona
       LEFT JOIN ins_grupo g ON m.id_ins_grupo = g.id_ins_grupo
       LEFT JOIN aca_programa_aprobado pa ON g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       LEFT JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
       LEFT JOIN aca_tipo_estudiante te ON m.id_aca_tipo_estudiante = te.id_aca_tipo_estudiante
       LEFT JOIN aca_colegio col ON p.id_aca_colegio_procedencia = col.id_aca_colegio
       LEFT JOIN fin_convenio conv ON m.id_fin_convenio_aplicado = conv.id_fin_convenio
       LEFT JOIN LATERAL (
  SELECT
    SUM(op.saldo_pendiente) as deuda_total,
    COUNT(*) FILTER (WHERE op.saldo_pendiente > 0) as obligaciones_pendientes
  FROM fin_obligacion_pago op
  WHERE op.cod_ins_matricula = m.cod_ins_matricula
    AND op.estado_obligacion_pago != 'ELIMINADO'
  ) deudas ON true
WHERE m.estado_matricula != 'ELIMINADO'
  AND p.estado_persona != 'ELIMINADO';

COMMENT ON VIEW vista_estudiantes_grupo IS 'Estudiantes con información completa';

-- ============================================================================
-- SECCIÓN 6: VISTAS FINANCIERAS (NUEVAS)
-- ============================================================================

CREATE OR REPLACE VIEW vista_aranceles_vigentes AS
SELECT
  a.id_fin_arancel,
  a.nombre_arancel,
  a.nro_resolucion,
  a.fecha_aprobacion,
  p.nombre_programa,
  pa.sistema_programa,
  per.nombre_periodo,
  te.nombre_tipo as tipo_estudiante,
  te.es_nacional,
  -- Desglose
  da.id_fin_detalle_arancel,
  ca.nombre_concepto,
  ca.tipo_concepto,
  da.monto_concepto,
  da.orden_aplicacion,
  -- Totales
  (SELECT SUM(monto_concepto)
   FROM fin_detalle_arancel
   WHERE id_fin_arancel = a.id_fin_arancel) as monto_total,
  (SELECT COUNT(*)
   FROM fin_descuento_arancel
   WHERE id_fin_arancel = a.id_fin_arancel
     AND estado_descuento = 'ACTIVO') as descuentos_disponibles,
  a.estado_arancel,
  a.fecha_inicio_vigencia,
  a.fecha_fin_vigencia
FROM fin_arancel a
       JOIN aca_programa_aprobado pa ON a.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       JOIN aca_tipo_estudiante te ON a.id_aca_tipo_estudiante = te.id_aca_tipo_estudiante
       LEFT JOIN aca_periodo per ON a.id_aca_periodo = per.id_aca_periodo
       LEFT JOIN fin_detalle_arancel da ON a.id_fin_arancel = da.id_fin_arancel
       LEFT JOIN fin_concepto_arancel ca ON da.id_fin_concepto_arancel = ca.id_fin_concepto_arancel
WHERE a.estado_arancel = 'ACTIVO'
  AND (a.fecha_fin_vigencia IS NULL OR a.fecha_fin_vigencia >= CURRENT_DATE)
ORDER BY p.nombre_programa, te.nombre_tipo, da.orden_aplicacion;

COMMENT ON VIEW vista_aranceles_vigentes IS 'Aranceles vigentes con desglose';

CREATE OR REPLACE VIEW vista_convenios_colegios AS
SELECT
  conv.id_fin_convenio,
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
  col.telefono as colegio_telefono,
  cc.fecha_inicio,
  cc.fecha_fin,
  cc.estado_colegio_convenio,
  CASE
    WHEN CURRENT_DATE < conv.fecha_inicio_vigencia THEN 'PROXIMO'
    WHEN conv.fecha_fin_vigencia IS NOT NULL AND CURRENT_DATE > conv.fecha_fin_vigencia THEN 'VENCIDO'
    WHEN cc.estado_colegio_convenio = 'SUSPENDIDO' THEN 'SUSPENDIDO'
    ELSE 'VIGENTE'
    END as estado_vigencia,
  (SELECT COUNT(DISTINCT m.id_prs_persona)
   FROM ins_matricula m
          JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
   WHERE p.id_aca_colegio_procedencia = col.id_aca_colegio
     AND m.id_fin_convenio_aplicado = conv.id_fin_convenio
     AND m.estado_matricula = 'ACTIVO') as estudiantes_beneficiados
FROM fin_convenio conv
       JOIN fin_colegio_convenio cc ON conv.id_fin_convenio = cc.id_fin_convenio
       JOIN aca_colegio col ON cc.id_aca_colegio = col.id_aca_colegio
WHERE conv.estado_convenio != 'ELIMINADO'
  AND col.estado_colegio != 'ELIMINADO'
ORDER BY conv.nombre_convenio, col.nombre_colegio;

COMMENT ON VIEW vista_convenios_colegios IS 'Convenios con colegios y estudiantes beneficiados';

CREATE OR REPLACE VIEW vista_estado_cuenta_estudiante AS
SELECT
  m.cod_ins_matricula,
  p.id_prs_persona,
  CONCAT(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, '')) as nombre_completo,
  p.ci,
  prog.nombre_programa,
  g.nombre_grupo,
  te.nombre_tipo as tipo_estudiante,
  ar.nombre_arancel,
  conv.nombre_convenio,
  op.id_fin_obligacion_pago,
  cp.nombre_concepto as concepto_pago,
  op.monto_base,
  op.monto_descuento_arancel,
  op.monto_descuento_convenio,
  op.monto_final,
  op.saldo_pendiente,
  op.estado_obligacion_pago,
  (SELECT SUM(monto_final)
   FROM fin_obligacion_pago
   WHERE cod_ins_matricula = m.cod_ins_matricula
     AND estado_obligacion_pago != 'ELIMINADO') as total_deuda,
  (SELECT SUM(saldo_pendiente)
   FROM fin_obligacion_pago
   WHERE cod_ins_matricula = m.cod_ins_matricula
     AND estado_obligacion_pago != 'ELIMINADO') as total_saldo,
  (SELECT SUM(monto_final - saldo_pendiente)
   FROM fin_obligacion_pago
   WHERE cod_ins_matricula = m.cod_ins_matricula
     AND estado_obligacion_pago != 'ELIMINADO') as total_pagado,
  CASE
    WHEN (SELECT SUM(saldo_pendiente) FROM fin_obligacion_pago WHERE cod_ins_matricula = m.cod_ins_matricula) > 0
      THEN 'MOROSO'
    ELSE 'AL_DIA'
    END as estado_financiero
FROM ins_matricula m
       JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
       LEFT JOIN ins_grupo g ON m.id_ins_grupo = g.id_ins_grupo
       LEFT JOIN aca_programa_aprobado pa ON g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       LEFT JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
       LEFT JOIN aca_tipo_estudiante te ON m.id_aca_tipo_estudiante = te.id_aca_tipo_estudiante
       LEFT JOIN fin_arancel ar ON m.id_fin_arancel_aplicado = ar.id_fin_arancel
       LEFT JOIN fin_convenio conv ON m.id_fin_convenio_aplicado = conv.id_fin_convenio
       LEFT JOIN fin_obligacion_pago op ON m.cod_ins_matricula = op.cod_ins_matricula
       LEFT JOIN fin_concepto_pago cp ON op.id_fin_concepto_pago = cp.id_fin_concepto_pago
WHERE m.estado_matricula != 'ELIMINADO'
  AND (op.id_fin_obligacion_pago IS NULL OR op.estado_obligacion_pago != 'ELIMINADO');

COMMENT ON VIEW vista_estado_cuenta_estudiante IS 'Estado de cuenta financiero';

-- ============================================================================
-- SECCIÓN 7: VISTAS DE CERTIFICACIONES (NUEVAS)
-- ============================================================================

CREATE OR REPLACE VIEW vista_certificaciones_programa AS
SELECT
  cp.id_aca_certificacion_programa,
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
  (SELECT STRING_AGG(mg.nombre_modalidad, ', ')
   FROM aca_programa_modalidad_graduacion pmg
          JOIN aca_modalidad_graduacion mg ON pmg.id_aca_modalidad_graduacion = mg.id_aca_modalidad_graduacion
   WHERE pmg.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
     AND pmg.estado_programa_modalidad = 'ACTIVO'
     AND mg.estado_modalidad_graduacion = 'ACTIVO') as modalidades_disponibles,
  cp.estado_certificacion_programa
FROM aca_certificacion_programa cp
       JOIN aca_titulo_certificado tc ON cp.id_aca_titulo_certificado = tc.id_aca_titulo_certificado
       JOIN aca_programa_aprobado pa ON cp.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
WHERE cp.estado_certificacion_programa = 'ACTIVO'
  AND tc.estado_titulo = 'ACTIVO'
  AND pa.estado_programa_aprobado != 'ELIMINADO'
ORDER BY prog.nombre_programa, cp.orden_secuencial;

COMMENT ON VIEW vista_certificaciones_programa IS 'Certificaciones disponibles por programa';

CREATE OR REPLACE VIEW vista_estudiantes_aptos_certificacion AS
SELECT
  m.cod_ins_matricula,
  p.id_prs_persona,
  CONCAT(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, '')) as nombre_completo,
  p.ci,
  prog.nombre_programa,
  cp.nombre_certificacion,
  cp.tipo_certificacion_programa,
  cp.periodos_requeridos,
  (SELECT COUNT(DISTINCT ecm.id_aca_periodo)
   FROM eje_programacion prog_est
          JOIN eje_cronograma_modulo ecm ON prog_est.id_eje_cronograma_modulo = ecm.id_eje_cronograma_modulo
   WHERE prog_est.cod_ins_matricula = m.cod_ins_matricula
     AND prog_est.nota_final >= 51
     AND prog_est.estado_programacion != 'ELIMINADO') as periodos_aprobados,
  COALESCE((SELECT SUM(saldo_pendiente)
            FROM fin_obligacion_pago
            WHERE cod_ins_matricula = m.cod_ins_matricula
              AND estado_obligacion_pago != 'ELIMINADO'), 0) as deuda_pendiente,
  CASE
    WHEN (SELECT COUNT(DISTINCT ecm.id_aca_periodo)
          FROM eje_programacion prog_est
                 JOIN eje_cronograma_modulo ecm ON prog_est.id_eje_cronograma_modulo = ecm.id_eje_cronograma_modulo
          WHERE prog_est.cod_ins_matricula = m.cod_ins_matricula
            AND prog_est.nota_final >= 51) >= cp.periodos_requeridos
      AND COALESCE((SELECT SUM(saldo_pendiente)
                    FROM fin_obligacion_pago
                    WHERE cod_ins_matricula = m.cod_ins_matricula), 0) = 0
      THEN true
    ELSE false
    END as apto_para_certificar,
  (SELECT COUNT(*)
   FROM aca_certificado_emitido ce
   WHERE ce.id_prs_persona = p.id_prs_persona
     AND ce.id_aca_certificacion_programa = cp.id_aca_certificacion_programa
     AND ce.estado_certificado != 'ANULADO') as certificados_emitidos
FROM ins_matricula m
       JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
       JOIN ins_grupo g ON m.id_ins_grupo = g.id_ins_grupo
       JOIN aca_programa_aprobado pa ON g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
       CROSS JOIN aca_certificacion_programa cp
WHERE cp.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
  AND m.estado_matricula != 'ELIMINADO'
  AND cp.estado_certificacion_programa = 'ACTIVO';

COMMENT ON VIEW vista_estudiantes_aptos_certificacion IS 'Estudiantes que cumplen requisitos de certificación';

-- ============================================================================
-- SECCIÓN 8: VISTAS DE CALIFICACIONES (ACTUALIZADAS)
-- ============================================================================

CREATE OR REPLACE VIEW vista_calificaciones_competencia AS
SELECT
  prog.id_eje_programacion,
  m.cod_ins_matricula,
  CONCAT(p.nombre, ' ', p.ap_paterno, ' ', COALESCE(p.ap_materno, '')) as nombre_estudiante,
  p.ci,
  pr.nombre_programa,
  mod.nombre_modulo,
  g.nombre_grupo,
  prog.nota_final as nota_final_modulo,
  prog.observacion as observacion_modulo,
  -- Desglose por competencia (si existe)
  dc.id_eje_detalle_calificacion,
  ae.nombre_area,
  ae.descripcion as area_descripcion,
  dc.nota_progress_test,
  dc.nota_class_performance,
  dc.nota_final_area,
  dc.comentario_docente,
  ae.orden as area_orden
FROM eje_programacion prog
       JOIN ins_matricula m ON prog.cod_ins_matricula = m.cod_ins_matricula
       JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
       JOIN ins_grupo g ON m.id_ins_grupo = g.id_ins_grupo
       JOIN aca_programa_aprobado pa ON g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       JOIN aca_programa pr ON pa.id_aca_programa = pr.id_aca_programa
       JOIN eje_cronograma_modulo ecm ON prog.id_eje_cronograma_modulo = ecm.id_eje_cronograma_modulo
       JOIN aca_plan_modulo_detalle pmd ON ecm.id_aca_plan_modulo_detalle = pmd.id_aca_plan_modulo_detalle
       JOIN aca_modulo mod ON pmd.id_aca_modulo = mod.id_aca_modulo
       LEFT JOIN eje_calificacion cal ON prog.id_eje_programacion = cal.id_eje_programacion
  AND cal.estado_calificacion != 'ELIMINADO'
       LEFT JOIN eje_detalle_calificacion dc ON cal.id_eje_calificacion = dc.id_eje_calificacion
  AND dc.estado_detalle_calificacion != 'ELIMINADO'
       LEFT JOIN eje_area_evaluacion ae ON dc.id_eje_area_evaluacion = ae.id_eje_area_evaluacion
WHERE prog.estado_programacion != 'ELIMINADO'
ORDER BY m.cod_ins_matricula, ae.orden;

COMMENT ON VIEW vista_calificaciones_competencia IS 'Calificaciones con desglose por competencias';

-- ============================================================================
-- SECCIÓN 9: FUNCIONES NUEVAS
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_calcular_monto_matricula(
  p_id_programa_aprobado INTEGER,
  p_id_tipo_estudiante INTEGER,
  p_numero_periodo INTEGER,
  p_id_fin_convenio INTEGER DEFAULT NULL
) RETURNS TABLE(
                 monto_base NUMERIC(10,2),
                 descuento_arancel NUMERIC(10,2),
                 descuento_convenio NUMERIC(10,2),
                 monto_final NUMERIC(10,2),
                 conceptos JSON
               ) AS $$
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
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_calcular_monto_matricula IS 'Calcula monto de matrícula con descuentos';

CREATE OR REPLACE FUNCTION fn_validar_emision_certificado(
  p_id_prs_persona INTEGER,
  p_id_certificacion_programa INTEGER
) RETURNS TABLE(
                 puede_certificar BOOLEAN,
                 mensaje TEXT,
                 periodos_requeridos INTEGER,
                 periodos_aprobados INTEGER,
                 deuda_pendiente NUMERIC(10,2)
               ) AS $$
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
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_validar_emision_certificado IS 'Valida requisitos para emitir certificado';

-- ============================================================================
-- FIN DE MIGRACIÓN
-- ============================================================================

DO $$
  BEGIN
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'MIGRACIÓN V026 COMPLETADA EXITOSAMENTE - VERSIÓN CORREGIDA';
    RAISE NOTICE 'Se actualizaron/crearon las siguientes vistas:';
    RAISE NOTICE '- vista_estudiantes_grupo (actualizada)';
    RAISE NOTICE '- vista_cronogramas_docente (actualizada)';
    RAISE NOTICE '- vista_cursos_disponibles_inscripcion (nueva)';
    RAISE NOTICE '- vista_aranceles_vigentes (nueva)';
    RAISE NOTICE '- vista_convenios_colegios (nueva)';
    RAISE NOTICE '- vista_certificaciones_programa (nueva)';
    RAISE NOTICE '- vista_calificaciones_competencia (actualizada)';
    RAISE NOTICE '';
    RAISE NOTICE 'Se crearon las siguientes funciones:';
    RAISE NOTICE '- fn_calcular_monto_matricula()';
    RAISE NOTICE '- fn_validar_emision_certificado()';
    RAISE NOTICE '============================================================================';
  END $$;
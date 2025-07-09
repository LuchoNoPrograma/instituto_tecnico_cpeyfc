CREATE OR REPLACE VIEW vista_matriculados_grupo AS
WITH progreso_academico AS (
  -- Calcular progreso por estudiante
  SELECT
    m.cod_ins_matricula,
    COUNT(DISTINCT ep.id_eje_programacion) AS modulos_cursados,
    COUNT(DISTINCT CASE WHEN ep.nota_final >= 60 THEN ep.id_eje_programacion END) AS modulos_aprobados,
    COUNT(DISTINCT CASE WHEN ep.estado_programacion = 'EN_CURSO' THEN ep.id_eje_programacion END) AS modulos_en_curso,
    ROUND(
            AVG(CASE WHEN ep.nota_final IS NOT NULL THEN ep.nota_final END), 2
    ) AS promedio_notas
  FROM ins_matricula m
         LEFT JOIN eje_programacion ep ON m.cod_ins_matricula = ep.cod_ins_matricula
  GROUP BY m.cod_ins_matricula
),
     estado_financiero AS (
       -- Consolidar estado de pagos por estudiante
       SELECT
         m.cod_ins_matricula,
         COALESCE(SUM(fop.saldo_pendiente), 0) AS deuda_total,
         COUNT(CASE WHEN fop.estado_obligacion_pago = 'PENDIENTE' THEN 1 END) AS obligaciones_pendientes,
         MAX(CASE WHEN fop.saldo_pendiente > 0 THEN 'CON_DEUDA' ELSE 'AL_DIA' END) AS estado_financiero
       FROM ins_matricula m
              LEFT JOIN fin_obligacion_pago fop ON m.cod_ins_matricula = fop.cod_ins_matricula
       GROUP BY m.cod_ins_matricula
     )
SELECT
  -- Identificación del grupo
  g.id_ins_grupo,
  g.nombre_grupo,
  g.gestion_inicio,

  -- Información del programa
  prog.nombre_programa,
  prog.sigla AS sigla_programa,
  mod.nombre_modalidad,

  -- Datos del estudiante
  m.cod_ins_matricula,
  p.ci AS cedula_identidad,
  CONCAT(p.nombre, ' ', p.ap_paterno,
         CASE WHEN p.ap_materno IS NOT NULL THEN CONCAT(' ', p.ap_materno) ELSE '' END) AS nombre_completo,
  p.nro_celular,
  p.correo,

  -- Estado académico
  m.estado_matricula,
  m.tipo_matricula,
  m.fecha_reg AS fecha_matricula,

  -- Progreso académico
  COALESCE(pa.modulos_cursados, 0) AS modulos_cursados,
  COALESCE(pa.modulos_aprobados, 0) AS modulos_aprobados,
  COALESCE(pa.modulos_en_curso, 0) AS modulos_en_curso,
  pa.promedio_notas,

  -- Porcentaje de avance (basado en módulos del plan de estudio)
  CASE
    WHEN COUNT(pmd.id_aca_plan_modulo_detalle) OVER (PARTITION BY apa.id_aca_plan_estudio) > 0
      THEN ROUND(
            (COALESCE(pa.modulos_aprobados, 0) * 100.0) /
            COUNT(pmd.id_aca_plan_modulo_detalle) OVER (PARTITION BY apa.id_aca_plan_estudio), 2
           )
    ELSE 0
    END AS porcentaje_avance,

  -- Estado financiero
  COALESCE(ef.deuda_total, 0) AS deuda_total,
  COALESCE(ef.obligaciones_pendientes, 0) AS obligaciones_pendientes,
  COALESCE(ef.estado_financiero, 'AL_DIA') AS estado_financiero,

  -- Información adicional para operaciones
  CASE
    WHEN m.estado_matricula = 'ACTIVO' AND ef.estado_financiero = 'AL_DIA' THEN 'REGULAR'
    WHEN m.estado_matricula = 'ACTIVO' AND ef.estado_financiero = 'CON_DEUDA' THEN 'MOROSO'
    WHEN m.estado_matricula = 'SUSPENDIDO' THEN 'SUSPENDIDO'
    WHEN m.estado_matricula = 'GRADUADO' THEN 'GRADUADO'
    ELSE 'INACTIVO'
    END AS situacion_academica,

  -- Fechas importantes
  g.fecha_inicio_inscripcion,
  g.fecha_fin_inscripcion,

  -- Metadatos
  m.user_reg AS registrado_por,
  m.fecha_mod AS ultima_modificacion

FROM ins_matricula m
       INNER JOIN ins_grupo g ON m.id_ins_grupo = g.id_ins_grupo
       INNER JOIN prs_persona p ON m.id_prs_persona = p.id_prs_persona
       INNER JOIN aca_programa_aprobado apa ON g.id_aca_programa_aprobado = apa.id_aca_programa_aprobado
       INNER JOIN aca_programa prog ON apa.id_aca_programa = prog.id_aca_programa
       INNER JOIN aca_modalidad mod ON apa.id_aca_modalidad = mod.id_aca_modalidad
       LEFT JOIN progreso_academico pa ON m.cod_ins_matricula = pa.cod_ins_matricula
       LEFT JOIN estado_financiero ef ON m.cod_ins_matricula = ef.cod_ins_matricula
       LEFT JOIN aca_plan_modulo_detalle pmd ON apa.id_aca_plan_estudio = pmd.id_aca_plan_estudio

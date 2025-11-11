-- ============================================
-- VISTAS PARA CHATBOT ACADÉMICO
-- ============================================

-- Vista principal con toda la info de programas disponibles
CREATE OR REPLACE VIEW vista_chatbot_programas_info AS
SELECT
  pa.id_aca_programa_aprobado,
  prog.id_aca_programa,
  prog.nombre_programa,
  prog.sigla AS programa_sigla,
  area.nombre_area,
  modal.nombre_modalidad,
  pa.gestion,
  pe.anho AS plan_anho,
  v.cod_version,

  -- Info del grupo
  g.id_ins_grupo,
  g.nombre_grupo,
  g.gestion_inicio,
  g.fecha_inicio_inscripcion,
  g.fecha_fin_inscripcion,
  g.estado_grupo,

  -- Estado de inscripción calculado
  CASE
    WHEN g.fecha_fin_inscripcion >= CURRENT_DATE
      AND g.fecha_inicio_inscripcion <= CURRENT_DATE THEN 'INSCRIPCIONES ABIERTAS'
    WHEN g.fecha_inicio_inscripcion > CURRENT_DATE THEN 'PROXIMAMENTE'
    ELSE 'INSCRIPCIONES CERRADAS'
    END AS estado_inscripcion,

  -- Días restantes
  CASE
    WHEN g.fecha_fin_inscripcion >= CURRENT_DATE
      THEN (g.fecha_fin_inscripcion - CURRENT_DATE)
    ELSE 0
    END AS dias_restantes,

  -- Precios
  COALESCE(pa.precio_matricula, 0) AS precio_matricula,
  COALESCE(pa.precio_colegiatura, 0) AS precio_colegiatura,
  COALESCE(pa.precio_titulacion, 0) AS precio_titulacion,

  -- Estadísticas
  (SELECT COUNT(*)
   FROM ins_preinscripcion pre
   WHERE pre.id_aca_programa_aprobado = g.id_ins_grupo
     AND pre.estado_preinscripcion != 'ELIMINADO') AS total_preinscritos,

  -- Módulos/carga horaria
  (SELECT COUNT(DISTINCT pmd.id_aca_plan_modulo_detalle)
   FROM aca_plan_modulo_detalle pmd
   WHERE pmd.id_aca_plan_estudio = pa.id_aca_plan_estudio
     AND pmd.estado_plan_modulo_detalle != 'ELIMINADO') AS total_modulos,

  (SELECT SUM(pmd.carga_horaria)
   FROM aca_plan_modulo_detalle pmd
   WHERE pmd.id_aca_plan_estudio = pa.id_aca_plan_estudio
     AND pmd.estado_plan_modulo_detalle != 'ELIMINADO') AS total_horas,

  -- Info adicional
  COALESCE(pa.imagen_programa_url, prog.imagen_url) AS imagen_url,
  pa.estado_programa_aprobado

FROM ins_grupo g
       INNER JOIN aca_programa_aprobado pa ON g.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       INNER JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
       INNER JOIN aca_area area ON prog.id_aca_area = area.id_aca_area
       INNER JOIN aca_modalidad modal ON pa.id_aca_modalidad = modal.id_aca_modalidad
       LEFT JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
       LEFT JOIN aca_version v ON pa.id_aca_version = v.id_aca_version

WHERE g.estado_grupo != 'ELIMINADO'
  AND pa.estado_programa_aprobado != 'ELIMINADO'
  AND prog.estado_programa != 'ELIMINADO'
  AND area.estado_area != 'ELIMINADO'
  AND modal.estado_modalidad != 'ELIMINADO'

ORDER BY
  CASE
    WHEN g.fecha_fin_inscripcion >= CURRENT_DATE THEN 0
    WHEN g.fecha_inicio_inscripcion > CURRENT_DATE THEN 1
    ELSE 2
    END,
  g.fecha_fin_inscripcion DESC;

-- Vista para estadísticas generales del instituto
CREATE OR REPLACE VIEW vista_chatbot_estadisticas_generales AS
SELECT
  (SELECT COUNT(*) FROM aca_programa WHERE estado_programa != 'ELIMINADO') AS total_programas,
  (SELECT COUNT(*) FROM aca_area WHERE estado_area != 'ELIMINADO') AS total_areas,
  (SELECT COUNT(*) FROM ins_grupo WHERE estado_grupo != 'ELIMINADO') AS total_grupos,
  (SELECT COUNT(*)
   FROM ins_grupo
   WHERE estado_grupo != 'ELIMINADO'
     AND fecha_fin_inscripcion >= CURRENT_DATE
     AND fecha_inicio_inscripcion <= CURRENT_DATE) AS grupos_con_inscripcion_abierta,
  (SELECT COUNT(*) FROM ins_matricula WHERE estado_matricula != 'ELIMINADO') AS total_estudiantes,
  (SELECT COUNT(*) FROM eje_docente WHERE estado_docente != 'ELIMINADO') AS total_docentes;

-- Vista para niveles de programas (Básico, Intermedio, Avanzado, etc.)
CREATE OR REPLACE VIEW vista_chatbot_niveles_programa AS
SELECT DISTINCT
  prog.id_aca_programa,
  prog.nombre_programa,
  niv.nombre_nivel,
  COUNT(DISTINCT pmd.id_aca_plan_modulo_detalle) AS modulos_nivel
FROM aca_programa prog
       INNER JOIN aca_programa_aprobado pa ON prog.id_aca_programa = pa.id_aca_programa
       INNER JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
       INNER JOIN aca_plan_modulo_detalle pmd ON pe.id_aca_plan_estudio = pmd.id_aca_plan_estudio
       INNER JOIN aca_nivel niv ON pmd.id_aca_nivel = niv.id_aca_nivel
WHERE prog.estado_programa != 'ELIMINADO'
  AND pa.estado_programa_aprobado != 'ELIMINADO'
  AND pmd.estado_plan_modulo_detalle != 'ELIMINADO'
  AND niv.estado_nivel != 'ELIMINADO'
GROUP BY prog.id_aca_programa, prog.nombre_programa, niv.nombre_nivel
ORDER BY prog.nombre_programa, niv.nombre_nivel;
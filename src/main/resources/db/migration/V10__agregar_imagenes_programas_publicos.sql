-- V10__crear_vista_preinscripciones.sql
-- Descripción: Agregar columnas para imágenes y configuración de vista pública
-- Autor: Luis Alberto Morales Villaca
-- Fecha: 26/06/2025  0


-- Agregar imagen URL a programas aprobados
ALTER TABLE aca_programa_aprobado
  DROP COLUMN IF EXISTS imagen_programa_url;
ALTER TABLE aca_programa_aprobado
  ADD COLUMN imagen_programa_url VARCHAR(500) NULL;

-- Agregar imagen URL a programas base
ALTER TABLE aca_programa
  DROP COLUMN IF EXISTS imagen_url;
ALTER TABLE aca_programa
  ADD COLUMN imagen_url VARCHAR(500) NULL;
-- Comentarios para las nuevas columnas
COMMENT ON COLUMN aca_programa_aprobado.imagen_programa_url IS 'URL de imagen destacada del programa para vista pública';
COMMENT ON COLUMN aca_programa.imagen_url IS 'URL de imagen del programa base';

-- ====================================
-- 1. VISTA PARA PROGRAMAS PÚBLICOS
-- ====================================

-- Vista para mostrar programas disponibles para inscripción pública
CREATE OR REPLACE VIEW vista_programas_publicos AS
SELECT
  -- IDs principales
  pa.id_aca_programa_aprobado,
  g.id_ins_grupo,
  p.id_aca_programa,

  -- Información del programa
  a.nombre_area,
  p.nombre_programa,
  p.sigla AS programa_sigla,
  pa.gestion,
  COALESCE(pa.imagen_programa_url, p.imagen_url) AS imagen_url,
  -- Información del plan y version, moalidad
  pe.anho AS plan_anho,
  v.cod_version,
  m.nombre_modalidad,

  -- Información del grupo
  g.nombre_grupo,
  g.gestion_inicio,
  g.fecha_inicio_inscripcion,
  g.fecha_fin_inscripcion,
  -- Cálculos de fechas
  CASE
    WHEN g.fecha_fin_inscripcion >= CURRENT_DATE
      AND g.fecha_inicio_inscripcion <= CURRENT_DATE
      THEN 'INSCRIPCIONES ABIERTAS'
    WHEN g.fecha_inicio_inscripcion > CURRENT_DATE
      THEN 'PROXIMAMENTE'
    ELSE 'INSCRIPCIONES CERRADAS'
    END AS estado_inscripcion,

  -- Días restantes para inscripción
  CASE
    WHEN g.fecha_fin_inscripcion >= CURRENT_DATE
      THEN g.fecha_fin_inscripcion - CURRENT_DATE
    ELSE 0
    END AS dias_restantes_inscripcion,

  -- Precios
  pa.precio_matricula,
  pa.precio_colegiatura,
  pa.precio_titulacion,

  -- Estados
  pa.estado_programa_aprobado,
  g.estado_grupo,

  -- Contadores
  (
    SELECT COUNT(*)
    FROM ins_preinscripcion pre
    WHERE pre.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
      AND pre.estado_preinscripcion = 'ACTIVO'
  ) AS total_preinscritos,

  (
    SELECT COUNT(*)
    FROM ins_matricula mat
    WHERE mat.id_ins_grupo = g.id_ins_grupo
      AND mat.estado_matricula = 'ACTIVO'
  ) AS total_matriculados,

  -- Carga horaria de plan estudio
  (
    SELECT SUM(pmd.carga_horaria)
    FROM aca_plan_modulo_detalle pmd
    WHERE pmd.id_aca_plan_estudio = pe.id_aca_plan_estudio
  ) AS carga_horaria,

  -- Fechas de registro para ordenar
  g.fecha_reg AS fecha_reg_grupo,
  pa.fecha_reg AS fecha_reg_programa

FROM aca_programa_aprobado pa
       INNER JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       INNER JOIN aca_area a ON p.id_aca_area = a.id_aca_area
       INNER JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
       LEFT JOIN aca_version v ON pa.id_aca_version = v.id_aca_version
       LEFT JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
       INNER JOIN ins_grupo g ON pa.id_aca_programa_aprobado = g.id_aca_programa_aprobado

WHERE
  pa.estado_programa_aprobado IN ('SIN INICIAR', 'EN EJECUCION')
  AND g.estado_grupo != 'ELIMINADO'
  AND p.estado_programa != 'ELIMINADO'
  AND a.estado_area != 'ELIMINADO'
  AND m.estado_modalidad != 'ELIMINADO'

  -- Solo grupos con inscripciones abiertas o próximas a abrir (máximo 30 días)
  AND g.fecha_fin_inscripcion >= CURRENT_DATE
  AND g.fecha_inicio_inscripcion <= CURRENT_DATE + INTERVAL '30 days'
ORDER BY
  -- Priorizar grupos con inscripción abierta
  CASE
    WHEN g.fecha_fin_inscripcion >= CURRENT_DATE
      AND g.fecha_inicio_inscripcion <= CURRENT_DATE
      THEN 1
    ELSE 2
    END,
  -- Luego por días restantes (menos días = más urgente)
  (g.fecha_fin_inscripcion - CURRENT_DATE),
  p.nombre_programa;

-- ====================================
-- 2. DATOS DE EJEMPLO (OPCIONAL)
-- ====================================

-- Comentarios finales
COMMENT ON VIEW vista_programas_publicos IS 'Vista completa para mostrar programas disponibles para inscripción pública con toda la información necesaria al publico';
-- V15__correcciones_vista_con_ids.sql
-- Corrección de vistas para incluir IDs necesarios para edición en frontend

-- =====================================================
-- 1. CORREGIR vista_aca_programas_aprobados
-- =====================================================
DROP VIEW IF EXISTS vista_programas_aprobados CASCADE;

CREATE VIEW vista_programas_aprobados AS
SELECT
  pa.id_aca_programa_aprobado,

  -- IDs necesarios para edición (CRÍTICO)
  pa.id_aca_programa,
  pa.id_aca_modalidad,
  pa.id_aca_plan_estudio,
  pa.id_aca_version,
  p.id_aca_area,

  -- Información descriptiva (para mostrar)
  p.nombre_programa AS programa_nombre,
  p.sigla AS programa_sigla,
  a.nombre_area AS area_nombre,
  m.nombre_modalidad AS modalidad_nombre,

  -- Plan de estudio
  pe.anho AS plan_anho,
  CASE
    WHEN pe.vigente = true THEN CONCAT(pe.anho, ' (VIGENTE)')
    ELSE pe.anho::VARCHAR
    END AS plan_descripcion,

  -- Versión
  v.cod_version,

  -- Datos del programa aprobado
  pa.gestion,
  pa.estado_programa_aprobado,
  pa.cod_certificado_ceub,

  -- Precios
  pa.precio_matricula,
  pa.precio_colegiatura,
  pa.precio_titulacion,

  -- Vigencia
  pa.fecha_inicio_vigencia,
  pa.fecha_fin_vigencia,

  -- Imagen
  COALESCE(pa.imagen_programa_url, p.imagen_url) AS imagen_url,

  -- Auditoría
  pa.fecha_reg,
  pa.fecha_mod,
  pa.user_reg,
  pa.user_mod

FROM aca_programa_aprobado pa
       JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
       JOIN aca_area a ON p.id_aca_area = a.id_aca_area
       JOIN aca_modalidad m ON pa.id_aca_modalidad = m.id_aca_modalidad
       LEFT JOIN aca_plan_estudio pe ON pa.id_aca_plan_estudio = pe.id_aca_plan_estudio
       LEFT JOIN aca_version v ON pa.id_aca_version = v.id_aca_version
WHERE
  pa.estado_programa_aprobado <> 'ELIMINADO'
  AND p.estado_programa <> 'ELIMINADO'
  AND a.estado_area <> 'ELIMINADO'
  AND m.estado_modalidad <> 'ELIMINADO'
ORDER BY
  pa.gestion DESC,
  p.nombre_programa;

COMMENT ON VIEW vista_programas_aprobados IS
  'Vista completa de programas aprobados con todos los IDs necesarios para operaciones CRUD desde el frontend';


-- =====================================================
-- 2. CORREGIR vista_aca_modalidades_activas
-- =====================================================
DROP VIEW IF EXISTS vista_modalidades_activas CASCADE;

CREATE VIEW vista_modalidades_activas AS
SELECT
  id_aca_modalidad,
  nombre_modalidad,
  estado_modalidad
FROM aca_modalidad
WHERE estado_modalidad <> 'ELIMINADO'
ORDER BY nombre_modalidad;


-- =====================================================
-- 3. CORREGIR vista_aca_planes_con_contexto
-- =====================================================
DROP VIEW IF EXISTS vista_planes_con_contexto CASCADE;

CREATE VIEW vista_planes_con_contexto AS
SELECT
  pe.id_aca_plan_estudio,
  pe.anho,
  pe.vigente,
  pe.estado_plan_estudio,

  -- Descripción mejorada
  CASE
    WHEN COUNT(DISTINCT pa.id_aca_programa) = 0 THEN
      CONCAT('Plan ', pe.anho, ' - Sin programas asignados')
    ELSE
      CONCAT('Plan ', pe.anho, ' - Usado por: ', STRING_AGG(DISTINCT p.sigla, ', ' ORDER BY p.sigla))
    END AS descripcion_plan,

  COUNT(DISTINCT pa.id_aca_programa) AS total_programas,

  pe.fecha_reg,
  pe.user_reg

FROM aca_plan_estudio pe
       LEFT JOIN aca_programa_aprobado pa ON pe.id_aca_plan_estudio = pa.id_aca_plan_estudio
  AND pa.estado_programa_aprobado <> 'ELIMINADO'
       LEFT JOIN aca_programa p ON pa.id_aca_programa = p.id_aca_programa
  AND p.estado_programa <> 'ELIMINADO'

WHERE pe.estado_plan_estudio <> 'ELIMINADO'

GROUP BY
  pe.id_aca_plan_estudio,
  pe.anho,
  pe.vigente,
  pe.estado_plan_estudio,
  pe.fecha_reg,
  pe.user_reg

ORDER BY
  pe.anho DESC,
  pe.vigente DESC;

COMMENT ON VIEW vista_planes_con_contexto IS
  'Vista de planes de estudio con información de uso por programas';

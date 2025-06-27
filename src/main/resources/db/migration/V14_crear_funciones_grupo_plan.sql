CREATE OR REPLACE FUNCTION fn_obtener_plan_estudio_programa_aprobado(
  p_id_aca_programa_aprobado INTEGER
) RETURNS TABLE(
                 nivel VARCHAR(100),
                 orden INTEGER,
                 sigla TEXT,
                 nombre_modulo VARCHAR(100),
                 carga_horaria INTEGER,
                 creditos NUMERIC(6,2),
                 competencia TEXT
               )
  LANGUAGE plpgsql
AS $$
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
$$;
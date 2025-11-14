-- Vista simplificada de descuentos vigentes para el chatbot
CREATE OR REPLACE VIEW vista_chatbot_descuentos_vigentes AS
SELECT
  ci.id_convenio,
  ci.nombre_institucion,
  ci.tipo_institucion,
  dc.id_descuento_convenio,
  dc.tipo_descuento,
  dc.valor_descuento,
  dc.descripcion,

  -- Programa (NULL = aplica a todos)
  pa.id_aca_programa_aprobado,
  COALESCE(prog.nombre_programa, 'TODOS LOS PROGRAMAS') AS nombre_programa,
  COALESCE(prog.sigla, 'GENERAL') AS sigla_programa,

  -- Concepto (NULL = aplica a todos)
  cp.id_fin_concepto_pago,
  COALESCE(cp.nombre_concepto, 'TODOS LOS CONCEPTOS') AS nombre_concepto,

  -- Formato del descuento para mostrar
  CASE
    WHEN dc.tipo_descuento = 'PORCENTUAL' THEN CONCAT(dc.valor_descuento, '%')
    ELSE CONCAT('Bs. ', dc.valor_descuento)
    END AS descuento_formato,

  -- Alcance del descuento (para saber qué tan específico es)
  CASE
    WHEN dc.id_aca_programa_aprobado IS NOT NULL AND dc.id_fin_concepto_pago IS NOT NULL THEN 'PROGRAMA Y CONCEPTO ESPECÍFICO'
    WHEN dc.id_aca_programa_aprobado IS NOT NULL THEN 'PROGRAMA ESPECÍFICO'
    WHEN dc.id_fin_concepto_pago IS NOT NULL THEN 'CONCEPTO ESPECÍFICO'
    ELSE 'GENERAL'
    END AS alcance_descuento

FROM fin_convenio_institucional ci
       INNER JOIN fin_descuento_convenio dc ON ci.id_convenio = dc.id_convenio
       LEFT JOIN aca_programa_aprobado pa ON dc.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       LEFT JOIN aca_programa prog ON pa.id_aca_programa = prog.id_aca_programa
       LEFT JOIN fin_concepto_pago cp ON dc.id_fin_concepto_pago = cp.id_fin_concepto_pago

WHERE ci.estado_convenio != 'ELIMINADO'
  AND dc.estado_descuento_convenio != 'ELIMINADO'
  AND ci.fecha_inicio_convenio <= CURRENT_DATE
  AND (ci.fecha_fin_convenio IS NULL OR ci.fecha_fin_convenio >= CURRENT_DATE)
  AND dc.fecha_inicio_vigencia <= CURRENT_DATE
  AND (dc.fecha_fin_vigencia IS NULL OR dc.fecha_fin_vigencia >= CURRENT_DATE)

ORDER BY ci.nombre_institucion,
         CASE
           WHEN dc.id_aca_programa_aprobado IS NOT NULL THEN 0
           ELSE 1
           END;
-- V5__correccion_estructura_tablas.sql
-- Descripción: Correcciones estructurales críticas y mejoras al esquema base
-- Autor: Luis Alberto Morales Villaca
-- Fecha: 21/06/2025
-- Estimaciones: 1 tabla nueva, 4 columnas agregadas, 2 renombradas, 1 relación crítica corregida

-- =====================================================
-- ÍNDICE DEL ARCHIVO
-- =====================================================
-- 1. CREAR NUEVAS TABLAS
--    1.1 TGR_TRIBUNAL - Gestión de tribunales para defensa de monografías
-- 2. AGREGAR COLUMNAS FALTANTES
--    2.1 Saldo pendiente en obligaciones de pago
--    2.2 Fecha de impresión en certificados
--    2.3 Nota ponderada en calificaciones
-- 3. RENOMBRAR COLUMNAS PARA CONSISTENCIA
--    3.1 Estandarizar nomenclatura financiera
--    3.2 Unificar terminología de pagos
-- 4. CORREGIR RELACIONES CRÍTICAS
--    4.1 Criterios de evaluación vinculados a docentes
-- 5. CREAR ÍNDICES PARA OPTIMIZACIÓN
--    5.1 Índices para nueva tabla tribunal
--    5.2 Actualizar índices corregidos
-- 6. COMENTARIOS DESCRIPTIVOS EN TABLAS
-- 7. COMENTARIOS ADICIONALES EN COLUMNAS CLAVE

-- =====================================================
-- SECCIÓN 1: CREAR NUEVAS TABLAS
-- =====================================================

-- Tabla: tgr_tribunal
-- Propósito: Gestión de tribunales para defensa de monografías/trabajos de grado
-- Permite registrar los miembros del tribunal que evaluarán las monografías
CREATE TABLE public.tgr_tribunal
(
  id_tgr_tribunal   SERIAL
    CONSTRAINT pk_tgr_tribunal PRIMARY KEY,
  id_tgr_monografia INTEGER     NOT NULL
    CONSTRAINT fk_tgr_trib_monografi_tgr_mono
      REFERENCES public.tgr_monografia
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  id_prs_persona    INTEGER     NOT NULL
    CONSTRAINT fk_tgr_trib_tribunal__prs_pers
      REFERENCES public.prs_persona
      ON UPDATE RESTRICT ON DELETE RESTRICT,
  tipo_tribunal     VARCHAR(35) NOT NULL,
  estado_tribunal   VARCHAR(35) NOT NULL,
  fecha_reg         TIMESTAMP   NOT NULL,
  fecha_mod         TIMESTAMP,
  user_reg          INTEGER     NOT NULL,
  user_mod          INTEGER
);

-- Comentarios descriptivos para tgr_tribunal
COMMENT ON TABLE public.tgr_tribunal IS 'Registro de miembros del tribunal para defensa de monografías';
COMMENT ON COLUMN public.tgr_tribunal.tipo_tribunal IS 'Tipo de miembro del tribunal (PRESIDENTE, VOCAL)';
COMMENT ON COLUMN public.tgr_tribunal.estado_tribunal IS 'Estado del miembro del tribunal (ACTIVO, ELIMINADO)';
COMMENT ON COLUMN public.tgr_tribunal.fecha_reg IS 'Fecha de registro';
COMMENT ON COLUMN public.tgr_tribunal.fecha_mod IS 'Fecha de modificación';
COMMENT ON COLUMN public.tgr_tribunal.user_reg IS 'Usuario que registró';
COMMENT ON COLUMN public.tgr_tribunal.user_mod IS 'Usuario que modificó';

-- Establecer propietario
ALTER TABLE public.tgr_tribunal
  OWNER TO postgres;

-- =====================================================
-- SECCIÓN 2: AGREGAR COLUMNAS FALTANTES
-- =====================================================

-- 2.1 Módulo Financiero: Saldo pendiente en obligaciones
-- Funcionalidad: Control de saldos después de pagos parciales y descuentos
-- Impacto: Crítico para reportes financieros y seguimiento de cobranza
ALTER TABLE public.fin_obligacion_pago
  ADD COLUMN saldo_pendiente NUMERIC(10, 2) NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.fin_obligacion_pago.saldo_pendiente IS 'Saldo pendiente de pago después de aplicar descuentos y pagos parciales';

-- 2.2 Módulo Certificación: Fecha de impresión
-- Funcionalidad: Registro temporal de emisión física de certificados
-- Impacto: Auditoría y control del proceso de certificación
ALTER TABLE public.cer_impresion
  ADD COLUMN fecha_impresion DATE;

COMMENT ON COLUMN public.cer_impresion.fecha_impresion IS 'Fecha efectiva de impresión del certificado';

-- 2.3 Módulo Académico: Nota ponderada en calificaciones
-- Funcionalidad: Cálculo automático aplicando peso de criterios
-- Impacto: Precisión en calificaciones finales y reportes académicos
ALTER TABLE public.eje_calificacion
  ADD COLUMN nota_ponderada NUMERIC(5, 2);

COMMENT ON COLUMN public.eje_calificacion.nota_ponderada IS 'Nota calculada aplicando la ponderación del criterio de evaluación';

-- =====================================================
-- SECCIÓN 3: RENOMBRAR COLUMNAS PARA CONSISTENCIA
-- =====================================================

-- 3.1 Estandarizar nomenclatura en obligaciones de pago
-- Lógica: Cambiar "monto" por "deuda" para mayor claridad conceptual
-- Refleja mejor la naturaleza de las obligaciones financieras
ALTER TABLE public.fin_obligacion_pago
  RENAME COLUMN monto_sin_descuento TO deuda_sin_descuento;

ALTER TABLE public.fin_obligacion_pago
  RENAME COLUMN monto_con_descuento TO deuda_con_descuento;

-- 3.2 Estandarizar nomenclatura en detalles de pago
-- Lógica: "monto_pagado" es más descriptivo que "monto_aplicado"
-- Clarifica la acción realizada vs. la pendiente
ALTER TABLE public.fin_detalle_pago
  RENAME COLUMN monto_aplicado TO monto_pagado;

-- =====================================================
-- SECCIÓN 4: CORREGIR RELACIONES CRÍTICAS
-- =====================================================

-- 4.1 Corrección CRÍTICA: Criterios de evaluación deben estar relacionados con docentes, no cronogramas
-- Lógica de negocio: Un docente define sus criterios de evaluación que aplica en todas sus programaciones
-- Error original: criterios ligados a cronograma limitaba flexibilidad y reutilización
-- Impacto: Fundamental para el funcionamiento correcto del módulo de evaluaciones

-- Eliminar constraint incorrecta
ALTER TABLE public.eje_criterio_eval
  DROP CONSTRAINT IF EXISTS fk_eje_crit_cronogram_eje_cron;

-- Renombrar columna para reflejar la relación correcta
ALTER TABLE public.eje_criterio_eval
  RENAME COLUMN id_eje_cronograma_modulo TO id_eje_docente;

-- Agregar constraint correcta: docente define criterios
ALTER TABLE public.eje_criterio_eval
  ADD CONSTRAINT fk_eje_crit_docente_define_criterio
    FOREIGN KEY (id_eje_docente)
      REFERENCES public.eje_docente (id_eje_docente)
      ON UPDATE RESTRICT ON DELETE RESTRICT;

-- =====================================================
-- SECCIÓN 5: CREAR ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

-- 5.1 Índices para tabla tgr_tribunal
-- Justificación: Consultas frecuentes por monografía y persona en formularios de tribunal
CREATE UNIQUE INDEX tgr_tribunal_pk
  ON public.tgr_tribunal (id_tgr_tribunal);

CREATE INDEX monografia_tiene_miembro_tribun
  ON public.tgr_tribunal (id_tgr_monografia);

CREATE INDEX tribunal_es_una_persona_fk
  ON public.tgr_tribunal (id_prs_persona);

-- 5.2 Actualizar índice corregido
-- Justificación: Optimizar consultas de criterios por docente tras corrección de relación
DROP INDEX IF EXISTS cronograma_modulo_define_criter;
CREATE INDEX docente_define_criterios_evaluacion
  ON public.eje_criterio_eval (id_eje_docente);

-- =====================================================
-- SECCIÓN 6: COMENTARIOS DESCRIPTIVOS EN TABLAS IMPORTANTES
-- =====================================================

-- 6.1 Módulo Financiero - Tabla central de obligaciones
COMMENT ON TABLE public.fin_obligacion_pago IS 'Registro de deudas y obligaciones financieras de estudiantes matriculados';

-- 6.2 Módulo de Evaluación - Tabla de criterios
COMMENT ON TABLE public.eje_criterio_eval IS 'Criterios de evaluación definidos por docentes para calificar el desempeño estudiantil';

-- 6.3 Módulo de Certificación - Control de impresiones
COMMENT ON TABLE public.cer_impresion IS 'Control de impresión de certificados con hash de seguridad para prevenir falsificaciones';

-- 6.4 Módulo de Trabajo de Grado - Monografías
COMMENT ON TABLE public.tgr_monografia IS 'Registro de trabajos de grado (monografías) presentados por estudiantes para titulación';

-- =====================================================
-- SECCIÓN 7: COMENTARIOS ADICIONALES EN COLUMNAS CLAVE
-- =====================================================

-- Columnas financieras importantes
COMMENT ON COLUMN public.fin_obligacion_pago.deuda_sin_descuento IS 'Monto original de la deuda antes de aplicar descuentos';
COMMENT ON COLUMN public.fin_obligacion_pago.deuda_con_descuento IS 'Monto final de la deuda después de aplicar descuentos vigentes';

-- Columnas de seguridad en certificación
COMMENT ON COLUMN public.cer_impresion.hash_impresion IS 'Hash de seguridad único para validar autenticidad del certificado impreso';

-- Columnas académicas importantes
COMMENT ON COLUMN public.eje_criterio_eval.ponderacion IS 'Peso porcentual del criterio en la calificación final del módulo';

-- =====================================================
-- VERIFICACIONES POST-EJECUCIÓN
-- =====================================================

-- Verificar creación exitosa de tabla tgr_tribunal
-- SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'tgr_tribunal';

-- Verificar columnas agregadas correctamente
-- SELECT column_name FROM information_schema.columns WHERE table_name = 'fin_obligacion_pago' AND column_name = 'saldo_pendiente';

-- Verificar corrección de relación en criterios de evaluación
-- SELECT constraint_name FROM information_schema.table_constraints WHERE table_name = 'eje_criterio_eval' AND constraint_type = 'FOREIGN KEY';
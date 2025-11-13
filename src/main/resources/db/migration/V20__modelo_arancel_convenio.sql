-- =====================================================
-- Migración: Sistema de Aranceles y Convenios
-- Versión: V100
-- Descripción: Sistema de gestión de aranceles diferenciados
--              por tipo de beneficiario y convenios institucionales
-- =====================================================

-- =====================================================
-- TABLA: fin_tipo_beneficiario
-- Descripción: Categorías de personas para aranceles diferenciados
-- =====================================================
CREATE TABLE fin_tipo_beneficiario (
                                     id_tipo_beneficiario SERIAL PRIMARY KEY,
                                     nombre_tipo VARCHAR(100) NOT NULL,
                                     descripcion TEXT,
                                     estado_tipo_beneficiario VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
                                     fecha_reg TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                     user_reg INTEGER NOT NULL,
                                     fecha_mod TIMESTAMP,
                                     user_mod INTEGER
);

COMMENT ON TABLE fin_tipo_beneficiario IS 'Catálogo de tipos de beneficiarios para aranceles diferenciados';
COMMENT ON COLUMN fin_tipo_beneficiario.nombre_tipo IS 'Nombre del tipo (ESTUDIANTE_UAP, NACIONAL, EXTRANJERO)';
COMMENT ON COLUMN fin_tipo_beneficiario.estado_tipo_beneficiario IS 'Estados: ACTIVO, INACTIVO, ELIMINADO';

-- =====================================================
-- TABLA: fin_arancel
-- Descripción: Aranceles configurables por concepto, programa y tipo de beneficiario
-- =====================================================
CREATE TABLE fin_arancel (
                           id_arancel SERIAL PRIMARY KEY,
                           id_fin_concepto_pago INTEGER NOT NULL REFERENCES fin_concepto_pago(id_fin_concepto_pago),
                           id_aca_programa_aprobado INTEGER REFERENCES aca_programa_aprobado(id_aca_programa_aprobado),
                           id_tipo_beneficiario INTEGER NOT NULL REFERENCES fin_tipo_beneficiario(id_tipo_beneficiario),
                           monto_base NUMERIC(10,2) NOT NULL,
                           fecha_inicio_vigencia DATE NOT NULL,
                           fecha_fin_vigencia DATE,
                           descripcion TEXT,
                           estado_arancel VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
                           fecha_reg TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           user_reg INTEGER NOT NULL,
                           fecha_mod TIMESTAMP,
                           user_mod INTEGER,

                           CONSTRAINT uk_arancel_vigencia UNIQUE (
                                                                  id_fin_concepto_pago,
                                                                  id_aca_programa_aprobado,
                                                                  id_tipo_beneficiario,
                                                                  fecha_inicio_vigencia
                             ),
                           CONSTRAINT ck_arancel_monto_positivo CHECK (monto_base > 0),
                           CONSTRAINT ck_arancel_fechas CHECK (
                             fecha_fin_vigencia IS NULL OR fecha_fin_vigencia >= fecha_inicio_vigencia
                             )
);

COMMENT ON TABLE fin_arancel IS 'Aranceles por concepto de pago, programa y tipo de beneficiario';
COMMENT ON COLUMN fin_arancel.id_aca_programa_aprobado IS 'NULL para aranceles genéricos que aplican a todos los programas';
COMMENT ON COLUMN fin_arancel.monto_base IS 'Monto base sin descuentos aplicados';
COMMENT ON COLUMN fin_arancel.estado_arancel IS 'Estados: ACTIVO, INACTIVO, ELIMINADO';

-- Índices para optimización
CREATE INDEX idx_arancel_concepto ON fin_arancel(id_fin_concepto_pago);
CREATE INDEX idx_arancel_programa ON fin_arancel(id_aca_programa_aprobado);
CREATE INDEX idx_arancel_tipo_benef ON fin_arancel(id_tipo_beneficiario);
CREATE INDEX idx_arancel_vigencia ON fin_arancel(fecha_inicio_vigencia, fecha_fin_vigencia);

-- =====================================================
-- TABLA: fin_convenio_institucional
-- Descripción: Convenios con instituciones educativas y empresas
-- =====================================================
CREATE TABLE fin_convenio_institucional (
                                          id_convenio SERIAL PRIMARY KEY,
                                          nombre_institucion VARCHAR(200) NOT NULL,
                                          tipo_institucion VARCHAR(50) NOT NULL,
                                          nit VARCHAR(20),
                                          contacto_nombre VARCHAR(150),
                                          contacto_telefono VARCHAR(20),
                                          contacto_email VARCHAR(100),
                                          fecha_inicio_convenio DATE NOT NULL,
                                          fecha_fin_convenio DATE,
                                          observaciones TEXT,
                                          estado_convenio VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
                                          fecha_reg TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                          user_reg INTEGER NOT NULL,
                                          fecha_mod TIMESTAMP,
                                          user_mod INTEGER,

                                          CONSTRAINT ck_convenio_fechas CHECK (
                                            fecha_fin_convenio IS NULL OR fecha_fin_convenio >= fecha_inicio_convenio
                                            )
);

COMMENT ON TABLE fin_convenio_institucional IS 'Convenios con colegios, empresas e instituciones para descuentos';
COMMENT ON COLUMN fin_convenio_institucional.tipo_institucion IS 'Ejemplos: COLEGIO, EMPRESA, FUNDACION, ONG';
COMMENT ON COLUMN fin_convenio_institucional.estado_convenio IS 'Estados: ACTIVO, INACTIVO, ELIMINADO';

-- Índice para búsquedas
CREATE INDEX idx_convenio_institucion ON fin_convenio_institucional(nombre_institucion);
CREATE INDEX idx_convenio_vigencia ON fin_convenio_institucional(fecha_inicio_convenio, fecha_fin_convenio);

-- =====================================================
-- TABLA: fin_descuento_convenio
-- Descripción: Descuentos asociados a convenios (fijos o porcentuales)
-- =====================================================
CREATE TABLE fin_descuento_convenio (
                                      id_descuento_convenio SERIAL PRIMARY KEY,
                                      id_convenio INTEGER NOT NULL REFERENCES fin_convenio_institucional(id_convenio),
                                      id_aca_programa_aprobado INTEGER REFERENCES aca_programa_aprobado(id_aca_programa_aprobado),
                                      id_fin_concepto_pago INTEGER REFERENCES fin_concepto_pago(id_fin_concepto_pago),
                                      tipo_descuento VARCHAR(20) NOT NULL,
                                      valor_descuento NUMERIC(10,2) NOT NULL,
                                      fecha_inicio_vigencia DATE NOT NULL,
                                      fecha_fin_vigencia DATE,
                                      descripcion TEXT,
                                      estado_descuento_convenio VARCHAR(20) NOT NULL DEFAULT 'ACTIVO',
                                      fecha_reg TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      user_reg INTEGER NOT NULL,
                                      fecha_mod TIMESTAMP,
                                      user_mod INTEGER,

                                      CONSTRAINT ck_tipo_descuento CHECK (tipo_descuento IN ('PORCENTUAL', 'FIJO')),
                                      CONSTRAINT ck_valor_descuento_positivo CHECK (valor_descuento > 0),
                                      CONSTRAINT ck_descuento_fechas CHECK (
                                        fecha_fin_vigencia IS NULL OR fecha_fin_vigencia >= fecha_inicio_vigencia
                                        ),
                                      CONSTRAINT ck_porcentaje_valido CHECK (
                                        tipo_descuento != 'PORCENTUAL' OR (valor_descuento > 0 AND valor_descuento <= 100)
                                        )
);

COMMENT ON TABLE fin_descuento_convenio IS 'Descuentos aplicables por convenios institucionales';
COMMENT ON COLUMN fin_descuento_convenio.id_aca_programa_aprobado IS 'NULL para descuentos que aplican a todos los programas';
COMMENT ON COLUMN fin_descuento_convenio.id_fin_concepto_pago IS 'NULL para descuentos que aplican a todos los conceptos';
COMMENT ON COLUMN fin_descuento_convenio.tipo_descuento IS 'PORCENTUAL: valor es %, FIJO: valor en Bs';
COMMENT ON COLUMN fin_descuento_convenio.valor_descuento IS 'Valor en Bs para FIJO o % para PORCENTUAL';
COMMENT ON COLUMN fin_descuento_convenio.estado_descuento_convenio IS 'Estados: ACTIVO, INACTIVO, ELIMINADO';

-- Índices para optimización
CREATE INDEX idx_descuento_convenio ON fin_descuento_convenio(id_convenio);
CREATE INDEX idx_descuento_programa ON fin_descuento_convenio(id_aca_programa_aprobado);
CREATE INDEX idx_descuento_concepto ON fin_descuento_convenio(id_fin_concepto_pago);
CREATE INDEX idx_descuento_vigencia ON fin_descuento_convenio(fecha_inicio_vigencia, fecha_fin_vigencia);

-- =====================================================
-- VISTA: vista_aranceles_vigentes
-- Descripción: Muestra todos los aranceles activos y vigentes
-- =====================================================
CREATE OR REPLACE VIEW vista_aranceles_vigentes AS
SELECT
  a.id_arancel,
  cp.id_fin_concepto_pago,
  cp.nombre_concepto,
  cp.descripcion AS descripcion_concepto,
  tb.id_tipo_beneficiario,
  tb.nombre_tipo AS tipo_beneficiario,
  tb.descripcion AS descripcion_tipo_beneficiario,
  COALESCE(pa.id_aca_programa_aprobado, 0) AS id_aca_programa_aprobado,
  COALESCE(prg.nombre_programa, 'GENÉRICO - APLICA A TODOS') AS nombre_programa,
  a.monto_base,
  a.fecha_inicio_vigencia,
  a.fecha_fin_vigencia,
  a.descripcion AS descripcion_arancel,
  CASE
    WHEN a.fecha_fin_vigencia IS NULL THEN 'VIGENTE'
    WHEN a.fecha_fin_vigencia >= CURRENT_DATE THEN 'VIGENTE'
    ELSE 'VENCIDO'
    END AS estado_vigencia
FROM fin_arancel a
       INNER JOIN fin_concepto_pago cp ON a.id_fin_concepto_pago = cp.id_fin_concepto_pago
       INNER JOIN fin_tipo_beneficiario tb ON a.id_tipo_beneficiario = tb.id_tipo_beneficiario
       LEFT JOIN aca_programa_aprobado pa ON a.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       LEFT JOIN aca_programa prg ON pa.id_aca_programa = prg.id_aca_programa
WHERE a.estado_arancel != 'ELIMINADO'
  AND cp.estado_concepto_pago != 'ELIMINADO'
  AND tb.estado_tipo_beneficiario != 'ELIMINADO'
  AND a.fecha_inicio_vigencia <= CURRENT_DATE
  AND (a.fecha_fin_vigencia IS NULL OR a.fecha_fin_vigencia >= CURRENT_DATE)
ORDER BY cp.nombre_concepto, tb.nombre_tipo, prg.nombre_programa;

COMMENT ON VIEW vista_aranceles_vigentes IS 'Vista de aranceles activos y vigentes para consulta rápida';

-- =====================================================
-- VISTA: vista_convenios_vigentes
-- Descripción: Muestra convenios activos con sus descuentos vigentes
-- =====================================================
CREATE OR REPLACE VIEW vista_convenios_vigentes AS
SELECT
  ci.id_convenio,
  ci.nombre_institucion,
  ci.tipo_institucion,
  ci.nit,
  ci.contacto_nombre,
  ci.contacto_telefono,
  ci.contacto_email,
  ci.fecha_inicio_convenio,
  ci.fecha_fin_convenio,
  dc.id_descuento_convenio,
  COALESCE(pa.id_aca_programa_aprobado, 0)             AS id_programa_aprobado,
  COALESCE(prg.nombre_programa, 'TODOS LOS PROGRAMAS') AS nombre_programa,
  COALESCE(cp.id_fin_concepto_pago, 0)                 AS id_fin_concepto_pago,
  COALESCE(cp.nombre_concepto, 'TODOS LOS CONCEPTOS')  AS nombre_concepto,
  dc.tipo_descuento,
  dc.valor_descuento,
  dc.fecha_inicio_vigencia                             AS fecha_inicio_descuento,
  dc.fecha_fin_vigencia                                AS fecha_fin_descuento,
  dc.descripcion                                       AS descripcion_descuento,
  CASE
    WHEN dc.tipo_descuento = 'PORCENTUAL' THEN CONCAT(dc.valor_descuento::TEXT, '%')
    ELSE CONCAT(dc.valor_descuento::TEXT, ' Bs')
    END                                                AS descuento_formato,
  CASE
    WHEN ci.fecha_fin_convenio IS NULL THEN 'VIGENTE'
    WHEN ci.fecha_fin_convenio >= CURRENT_DATE THEN 'VIGENTE'
    ELSE 'VENCIDO'
    END AS estado_vigencia_convenio
FROM fin_convenio_institucional ci
       INNER JOIN fin_descuento_convenio dc ON ci.id_convenio = dc.id_convenio
       LEFT JOIN aca_programa_aprobado pa ON dc.id_aca_programa_aprobado = pa.id_aca_programa_aprobado
       LEFT JOIN aca_programa prg ON pa.id_aca_programa = prg.id_aca_programa
       LEFT JOIN fin_concepto_pago cp ON dc.id_fin_concepto_pago = cp.id_fin_concepto_pago
WHERE ci.estado_convenio != 'ELIMINADO'
  AND dc.estado_descuento_convenio != 'ELIMINADO'
  AND ci.fecha_inicio_convenio <= CURRENT_DATE
  AND (ci.fecha_fin_convenio IS NULL OR ci.fecha_fin_convenio >= CURRENT_DATE)
  AND dc.fecha_inicio_vigencia <= CURRENT_DATE
  AND (dc.fecha_fin_vigencia IS NULL OR dc.fecha_fin_vigencia >= CURRENT_DATE)
ORDER BY ci.nombre_institucion, prg.nombre_programa, cp.nombre_concepto;

COMMENT ON VIEW vista_convenios_vigentes IS 'Vista de convenios institucionales activos con sus descuentos vigentes';

-- =====================================================
-- FUNCIÓN: fn_calcular_arancel_con_descuento
-- Descripción: Calcula el monto final de un arancel aplicando descuento de convenio
-- =====================================================
CREATE OR REPLACE FUNCTION fn_calcular_arancel_con_descuento(
  p_id_fin_concepto_pago INTEGER,
  p_id_programa_aprobado INTEGER,
  p_id_tipo_beneficiario INTEGER,
  p_id_convenio INTEGER DEFAULT NULL
)
  RETURNS TABLE (
                  monto_base NUMERIC,
                  descuento_aplicado NUMERIC,
                  monto_final NUMERIC,
                  detalle_descuento TEXT,
                  id_arancel_aplicado INTEGER,
                  id_descuento_aplicado INTEGER
                ) AS $$
DECLARE
  v_monto_base NUMERIC;
  v_descuento NUMERIC := 0;
  v_tipo_descuento VARCHAR(20);
  v_valor_descuento NUMERIC;
  v_detalle TEXT := 'Sin descuento aplicado';
  v_id_arancel INTEGER;
  v_id_descuento INTEGER := NULL;
BEGIN
  -- Buscar arancel específico del programa o genérico
  -- Prioriza: programa específico > genérico
  SELECT a.monto_base, a.id_arancel
  INTO v_monto_base, v_id_arancel
  FROM fin_arancel a
  WHERE a.id_fin_concepto_pago = p_id_fin_concepto_pago
    AND a.id_tipo_beneficiario = p_id_tipo_beneficiario
    AND (a.id_aca_programa_aprobado = p_id_programa_aprobado OR a.id_aca_programa_aprobado IS NULL)
    AND a.estado_arancel != 'ELIMINADO'
    AND a.fecha_inicio_vigencia <= CURRENT_DATE
    AND (a.fecha_fin_vigencia IS NULL OR a.fecha_fin_vigencia >= CURRENT_DATE)
  ORDER BY
    CASE WHEN a.id_aca_programa_aprobado IS NULL THEN 1 ELSE 0 END,  -- Específico primero
    a.fecha_inicio_vigencia DESC  -- Más reciente primero
  LIMIT 1;

  -- Validar que se encontró arancel
  IF v_monto_base IS NULL THEN
    RAISE EXCEPTION 'No se encontró arancel vigente para el concepto %, programa % y tipo de beneficiario %',
      p_id_fin_concepto_pago,
      COALESCE(p_id_programa_aprobado::TEXT, 'GENÉRICO'),
      p_id_tipo_beneficiario;
  END IF;

  -- Si hay convenio, buscar descuento aplicable
  -- Prioriza: programa y concepto específico > solo programa > solo concepto > genérico
  IF p_id_convenio IS NOT NULL THEN
    SELECT
      dc.tipo_descuento,
      dc.valor_descuento,
      CONCAT(
          COALESCE(ci.nombre_institucion, ''),
          ' - ',
          dc.descripcion
      ),
      dc.id_descuento_convenio
    INTO v_tipo_descuento, v_valor_descuento, v_detalle, v_id_descuento
    FROM fin_descuento_convenio dc
           INNER JOIN fin_convenio_institucional ci ON dc.id_convenio = ci.id_convenio
    WHERE dc.id_convenio = p_id_convenio
      AND (dc.id_aca_programa_aprobado = p_id_programa_aprobado OR dc.id_aca_programa_aprobado IS NULL)
      AND (dc.id_fin_concepto_pago = p_id_fin_concepto_pago OR dc.id_fin_concepto_pago IS NULL)
      AND dc.estado_descuento_convenio != 'ELIMINADO'
      AND ci.estado_convenio != 'ELIMINADO'
      AND dc.fecha_inicio_vigencia <= CURRENT_DATE
      AND (dc.fecha_fin_vigencia IS NULL OR dc.fecha_fin_vigencia >= CURRENT_DATE)
      AND ci.fecha_inicio_convenio <= CURRENT_DATE
      AND (ci.fecha_fin_convenio IS NULL OR ci.fecha_fin_convenio >= CURRENT_DATE)
    ORDER BY
      -- Prioridad: programa + concepto > programa > concepto > genérico
      CASE
        WHEN dc.id_aca_programa_aprobado IS NOT NULL AND dc.id_fin_concepto_pago IS NOT NULL THEN 0
        WHEN dc.id_aca_programa_aprobado IS NOT NULL THEN 1
        WHEN dc.id_fin_concepto_pago IS NOT NULL THEN 2
        ELSE 3
        END,
      dc.fecha_inicio_vigencia DESC  -- Más reciente primero
    LIMIT 1;

    -- Calcular descuento si se encontró
    IF v_tipo_descuento IS NOT NULL THEN
      IF v_tipo_descuento = 'PORCENTUAL' THEN
        v_descuento := ROUND(v_monto_base * (v_valor_descuento / 100), 2);
      ELSE -- FIJO
        v_descuento := v_valor_descuento;
      END IF;

      -- Validar que el descuento no exceda el monto base
      IF v_descuento > v_monto_base THEN
        v_descuento := v_monto_base;
        v_detalle := v_detalle || ' (Descuento limitado al monto base)';
      END IF;
    ELSE
      v_detalle := 'Convenio sin descuento vigente para este concepto/programa';
    END IF;
  END IF;

  -- Retornar resultados
  RETURN QUERY SELECT
                 v_monto_base,
                 v_descuento,
                 v_monto_base - v_descuento,
                 v_detalle,
                 v_id_arancel,
                 v_id_descuento;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_calcular_arancel_con_descuento IS 'Calcula monto final con descuento de convenio aplicado';

-- =====================================================
-- FUNCIÓN: fn_obtener_aranceles_programa
-- Descripción: Obtiene todos los aranceles vigentes de un programa
--              (Para uso del chatbot y consultas generales)
-- =====================================================
CREATE OR REPLACE FUNCTION fn_obtener_aranceles_programa(
  p_id_programa_aprobado INTEGER
)
  RETURNS TABLE (
                  id_arancel INTEGER,
                  concepto VARCHAR,
                  tipo_beneficiario VARCHAR,
                  monto NUMERIC,
                  vigencia_desde DATE,
                  vigencia_hasta DATE,
                  es_generico BOOLEAN
                ) AS $$
BEGIN
  RETURN QUERY
    SELECT
      a.id_arancel,
      cp.nombre_concepto::VARCHAR,
      tb.nombre_tipo::VARCHAR,
      a.monto_base,
      a.fecha_inicio_vigencia,
      a.fecha_fin_vigencia,
      (a.id_aca_programa_aprobado IS NULL) AS es_generico
    FROM fin_arancel a
           INNER JOIN fin_concepto_pago cp ON a.id_fin_concepto_pago = cp.id_fin_concepto_pago
           INNER JOIN fin_tipo_beneficiario tb ON a.id_tipo_beneficiario = tb.id_tipo_beneficiario
    WHERE (a.id_aca_programa_aprobado = p_id_programa_aprobado OR a.id_aca_programa_aprobado IS NULL)
      AND a.estado_arancel != 'ELIMINADO'
      AND cp.estado_concepto_pago != 'ELIMINADO'
      AND tb.estado_tipo_beneficiario != 'ELIMINADO'
      AND a.fecha_inicio_vigencia <= CURRENT_DATE
      AND (a.fecha_fin_vigencia IS NULL OR a.fecha_fin_vigencia >= CURRENT_DATE)
    ORDER BY
      cp.nombre_concepto,
      tb.nombre_tipo,
      (a.id_aca_programa_aprobado IS NULL);  -- Específicos primero
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION fn_obtener_aranceles_programa IS 'Obtiene aranceles vigentes de un programa para consultas y chatbot';

-- =====================================================
-- DATOS INICIALES: Tipos de Beneficiario
-- =====================================================
INSERT INTO fin_tipo_beneficiario (nombre_tipo, descripcion, estado_tipo_beneficiario, user_reg) VALUES
('ESTUDIANTE UAP', 'Estudiante regular de la Universidad Amazónica de Pando', 'ACTIVO', 1),
('NACIONAL', 'Persona boliviana no estudiante de UAP', 'ACTIVO', 1),
('EXTRANJERO', 'Persona extranjera', 'ACTIVO', 1);

-- =====================================================
-- FIN DE MIGRACIÓN
-- =====================================================
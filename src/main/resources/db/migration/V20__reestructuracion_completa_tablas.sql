-- ============================================================================
-- MIGRACIÓN: Sistema Académico Completo CPEyFP
-- Versión: V025
-- Descripción: Creación de tablas para gestión académica, periodos, convenios,
--              aranceles, colegios, apoderados, certificaciones y calificaciones
-- Autor: CPEyFP Dev Team
-- Fecha: 2025-01-XX
-- ============================================================================

-- ============================================================================
-- SECCIÓN 1: GESTIÓN Y PERIODOS ACADÉMICOS
-- ============================================================================
-- Tabla: aca_gestion
-- Propósito: Registro de gestiones académicas anuales (años lectivos)
CREATE TABLE IF NOT EXISTS aca_gestion (
                                         id_aca_gestion SERIAL PRIMARY KEY,
                                         anio INTEGER NOT NULL UNIQUE,
                                         fecha_inicio DATE NOT NULL,
                                         fecha_fin DATE NOT NULL,
                                         estado_gestion VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                         fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                         fecha_mod TIMESTAMP,
                                         user_reg INTEGER NOT NULL,
                                         user_mod INTEGER,
                                         CONSTRAINT chk_gestion_anio CHECK (anio >= 2015 AND anio <= 2050),
                                         CONSTRAINT chk_gestion_fechas CHECK (fecha_fin > fecha_inicio),
                                         CONSTRAINT chk_gestion_estado CHECK (estado_gestion IN ('ACTIVO', 'CERRADO', 'ELIMINADO'))
);

COMMENT ON TABLE aca_gestion IS 'Gestiones académicas anuales de la institución';
COMMENT ON COLUMN aca_gestion.anio IS 'Año de la gestión académica (ej: 2025)';
COMMENT ON COLUMN aca_gestion.estado_gestion IS 'Estado: ACTIVO (actual), CERRADO (finalizado), ELIMINADO (soft delete)';

-- Tabla: aca_periodo
-- Propósito: Periodos académicos dentro de una gestión (semestres/trimestres/bimestres)
CREATE TABLE IF NOT EXISTS aca_periodo (
                                         id_aca_periodo SERIAL PRIMARY KEY,
                                         id_aca_gestion INTEGER NOT NULL,
                                         codigo_periodo VARCHAR(20) NOT NULL,
                                         nombre_periodo VARCHAR(100) NOT NULL,
                                         tipo_periodo VARCHAR(35) NOT NULL DEFAULT 'SEMESTRE',
                                         numero_periodo INTEGER NOT NULL,
                                         fecha_inicio DATE NOT NULL,
                                         fecha_fin DATE NOT NULL,
                                         estado_periodo VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                         fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                         fecha_mod TIMESTAMP,
                                         user_reg INTEGER NOT NULL,
                                         user_mod INTEGER,
                                         FOREIGN KEY (id_aca_gestion) REFERENCES aca_gestion(id_aca_gestion),
                                         CONSTRAINT chk_periodo_tipo CHECK (tipo_periodo IN ('SEMESTRE', 'TRIMESTRE', 'BIMESTRE', 'CUATRIMESTRE', 'ANUAL')),
                                         CONSTRAINT chk_periodo_numero CHECK (numero_periodo >= 1 AND numero_periodo <= 12),
                                         CONSTRAINT chk_periodo_fechas CHECK (fecha_fin > fecha_inicio),
                                         CONSTRAINT chk_periodo_estado CHECK (estado_periodo IN ('ACTIVO', 'FINALIZADO', 'ELIMINADO')),
                                         UNIQUE(id_aca_gestion, numero_periodo, tipo_periodo)
);

COMMENT ON TABLE aca_periodo IS 'Periodos académicos (semestres, trimestres, etc.) dentro de una gestión';
COMMENT ON COLUMN aca_periodo.codigo_periodo IS 'Código único del periodo (ej: 2025-1, 2025-2)';
COMMENT ON COLUMN aca_periodo.tipo_periodo IS 'Tipo de periodo: SEMESTRE, TRIMESTRE, BIMESTRE, CUATRIMESTRE, ANUAL';
COMMENT ON COLUMN aca_periodo.numero_periodo IS 'Número ordinal del periodo dentro de la gestión (1, 2, 3...)';

CREATE INDEX idx_periodo_gestion ON aca_periodo(id_aca_gestion);
CREATE INDEX idx_periodo_estado ON aca_periodo(estado_periodo);

-- ============================================================================
-- SECCIÓN 2: MODALIDADES Y CERTIFICACIONES
-- ============================================================================

-- Tabla: aca_modalidad_graduacion
-- Propósito: Catálogo de modalidades de graduación disponibles
CREATE TABLE IF NOT EXISTS aca_modalidad_graduacion (
                                                      id_aca_modalidad_graduacion SERIAL PRIMARY KEY,
                                                      nombre_modalidad VARCHAR(150) NOT NULL,
                                                      descripcion TEXT,
                                                      requiere_tesis BOOLEAN DEFAULT false,
                                                      requiere_examen BOOLEAN DEFAULT false,
                                                      requiere_proyecto BOOLEAN DEFAULT false,
                                                      orden INTEGER NOT NULL,
                                                      estado_modalidad_graduacion VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                                      fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                                      fecha_mod TIMESTAMP,
                                                      user_reg INTEGER NOT NULL,
                                                      user_mod INTEGER,
                                                      CONSTRAINT chk_modalidad_graduacion_estado CHECK (estado_modalidad_graduacion IN ('ACTIVO', 'INACTIVO', 'ELIMINADO')),
                                                      UNIQUE(nombre_modalidad)
);

COMMENT ON TABLE aca_modalidad_graduacion IS 'Catálogo de modalidades de graduación (examen, tesis, proyecto, etc.)';
COMMENT ON COLUMN aca_modalidad_graduacion.requiere_tesis IS 'Indica si la modalidad requiere defensa de tesis';
COMMENT ON COLUMN aca_modalidad_graduacion.requiere_examen IS 'Indica si la modalidad requiere examen de grado';
COMMENT ON COLUMN aca_modalidad_graduacion.requiere_proyecto IS 'Indica si la modalidad requiere proyecto de grado';

-- Tabla: aca_titulo_certificado
-- Propósito: Catálogo de títulos y certificados que emite la institución
CREATE TABLE IF NOT EXISTS aca_titulo_certificado (
                                                    id_aca_titulo_certificado SERIAL PRIMARY KEY,
                                                    nombre_titulo VARCHAR(200) NOT NULL,
                                                    tipo_certificacion VARCHAR(50) NOT NULL,
                                                    nivel_academico VARCHAR(50) NOT NULL,
                                                    descripcion TEXT,
                                                    requiere_creditos_minimos INTEGER,
                                                    requiere_horas_minimas INTEGER,
                                                    estado_titulo VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                                    fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                                    fecha_mod TIMESTAMP,
                                                    user_reg INTEGER NOT NULL,
                                                    user_mod INTEGER,
                                                    CONSTRAINT chk_titulo_tipo CHECK (tipo_certificacion IN ('TITULO', 'CERTIFICADO', 'DIPLOMA', 'CONSTANCIA')),
                                                    CONSTRAINT chk_titulo_nivel CHECK (nivel_academico IN ('TECNICO_MEDIO', 'TECNICO_SUPERIOR', 'LICENCIATURA', 'CURSO_CORTO', 'DIPLOMADO')),
                                                    CONSTRAINT chk_titulo_estado CHECK (estado_titulo IN ('ACTIVO', 'INACTIVO', 'ELIMINADO')),
                                                    UNIQUE(nombre_titulo)
);

COMMENT ON TABLE aca_titulo_certificado IS 'Catálogo de títulos académicos y certificados que puede emitir la institución';
COMMENT ON COLUMN aca_titulo_certificado.tipo_certificacion IS 'TITULO: grado académico, CERTIFICADO: curso completado, DIPLOMA: especialización';
COMMENT ON COLUMN aca_titulo_certificado.nivel_academico IS 'Nivel: TECNICO_MEDIO, TECNICO_SUPERIOR, LICENCIATURA, CURSO_CORTO, DIPLOMADO';

-- Tabla: aca_certificacion_programa (antes aca_salida_intermedia)
-- Propósito: Define qué títulos se emiten en cada programa y bajo qué condiciones
CREATE TABLE IF NOT EXISTS aca_certificacion_programa (
                                                        id_aca_certificacion_programa SERIAL PRIMARY KEY,
                                                        id_aca_programa_aprobado INTEGER NOT NULL,
                                                        id_aca_titulo_certificado INTEGER NOT NULL,
                                                        nombre_certificacion VARCHAR(200) NOT NULL,
                                                        tipo_certificacion_programa VARCHAR(35) NOT NULL DEFAULT 'TERMINAL',
                                                        periodos_requeridos INTEGER NOT NULL,
                                                        creditos_requeridos INTEGER,
                                                        horas_academicas_requeridas INTEGER,
                                                        orden_secuencial INTEGER NOT NULL,
                                                        estado_certificacion_programa VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                                        fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                                        fecha_mod TIMESTAMP,
                                                        user_reg INTEGER NOT NULL,
                                                        user_mod INTEGER,
                                                        FOREIGN KEY (id_aca_programa_aprobado) REFERENCES aca_programa_aprobado(id_aca_programa_aprobado),
                                                        FOREIGN KEY (id_aca_titulo_certificado) REFERENCES aca_titulo_certificado(id_aca_titulo_certificado),
                                                        CONSTRAINT chk_cert_prog_tipo CHECK (tipo_certificacion_programa IN ('INTERMEDIA', 'TERMINAL')),
                                                        CONSTRAINT chk_cert_prog_estado CHECK (estado_certificacion_programa IN ('ACTIVO', 'INACTIVO', 'ELIMINADO')),
                                                        CONSTRAINT chk_cert_prog_periodos CHECK (periodos_requeridos >= 1),
                                                        UNIQUE(id_aca_programa_aprobado, id_aca_titulo_certificado)
);

COMMENT ON TABLE aca_certificacion_programa IS 'Define qué títulos/certificados se emiten en cada programa. INTERMEDIA: antes de terminar (TUM), TERMINAL: al finalizar (TUS)';
COMMENT ON COLUMN aca_certificacion_programa.tipo_certificacion_programa IS 'INTERMEDIA: certificación antes de terminar programa, TERMINAL: certificación al completar programa';
COMMENT ON COLUMN aca_certificacion_programa.periodos_requeridos IS 'Cantidad de periodos académicos que debe completar para obtener esta certificación';

CREATE INDEX idx_cert_prog_programa ON aca_certificacion_programa(id_aca_programa_aprobado);
CREATE INDEX idx_cert_prog_titulo ON aca_certificacion_programa(id_aca_titulo_certificado);

-- Tabla: aca_programa_modalidad_graduacion
-- Propósito: Relación N:N entre programas y modalidades de graduación permitidas
CREATE TABLE IF NOT EXISTS aca_programa_modalidad_graduacion (
                                                               id_aca_programa_modalidad_graduacion SERIAL PRIMARY KEY,
                                                               id_aca_programa_aprobado INTEGER NOT NULL,
                                                               id_aca_modalidad_graduacion INTEGER NOT NULL,
                                                               es_modalidad_por_defecto BOOLEAN DEFAULT false,
                                                               orden_prioridad INTEGER,
                                                               estado_programa_modalidad VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                                               fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                                               fecha_mod TIMESTAMP,
                                                               user_reg INTEGER NOT NULL,
                                                               user_mod INTEGER,
                                                               FOREIGN KEY (id_aca_programa_aprobado) REFERENCES aca_programa_aprobado(id_aca_programa_aprobado),
                                                               FOREIGN KEY (id_aca_modalidad_graduacion) REFERENCES aca_modalidad_graduacion(id_aca_modalidad_graduacion),
                                                               CONSTRAINT chk_prog_mod_estado CHECK (estado_programa_modalidad IN ('ACTIVO', 'INACTIVO', 'ELIMINADO')),
                                                               UNIQUE(id_aca_programa_aprobado, id_aca_modalidad_graduacion)
);

COMMENT ON TABLE aca_programa_modalidad_graduacion IS 'Define qué modalidades de graduación están permitidas para cada programa';
COMMENT ON COLUMN aca_programa_modalidad_graduacion.es_modalidad_por_defecto IS 'Indica si esta es la modalidad recomendada por defecto';

-- Tabla: aca_certificado_emitido
-- Propósito: Registro de certificados/títulos emitidos a estudiantes
CREATE TABLE IF NOT EXISTS aca_certificado_emitido (
                                                     id_aca_certificado_emitido SERIAL PRIMARY KEY,
                                                     id_aca_certificacion_programa INTEGER NOT NULL,
                                                     id_prs_persona INTEGER NOT NULL,
                                                     id_aca_modalidad_graduacion INTEGER,
                                                     numero_certificado VARCHAR(50) NOT NULL UNIQUE,
                                                     fecha_emision DATE NOT NULL,
                                                     fecha_vencimiento DATE,
                                                     nota_final NUMERIC(5,2),
                                                     promedio_general NUMERIC(5,2),
                                                     archivo_pdf_uri TEXT,
                                                     hash_verificacion VARCHAR(100),
                                                     observaciones TEXT,
                                                     estado_certificado VARCHAR(35) NOT NULL DEFAULT 'EMITIDO',
                                                     fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                                     fecha_mod TIMESTAMP,
                                                     user_reg INTEGER NOT NULL,
                                                     user_mod INTEGER,
                                                     FOREIGN KEY (id_aca_certificacion_programa) REFERENCES aca_certificacion_programa(id_aca_certificacion_programa),
                                                     FOREIGN KEY (id_prs_persona) REFERENCES prs_persona(id_prs_persona),
                                                     FOREIGN KEY (id_aca_modalidad_graduacion) REFERENCES aca_modalidad_graduacion(id_aca_modalidad_graduacion),
                                                     CONSTRAINT chk_cert_emitido_estado CHECK (estado_certificado IN ('EMITIDO', 'ANULADO', 'REIMPRESO', 'ELIMINADO')),
                                                     UNIQUE(id_aca_certificacion_programa, id_prs_persona)
);

COMMENT ON TABLE aca_certificado_emitido IS 'Registro de títulos y certificados emitidos a estudiantes';
COMMENT ON COLUMN aca_certificado_emitido.numero_certificado IS 'Número único del certificado para verificación';
COMMENT ON COLUMN aca_certificado_emitido.hash_verificacion IS 'Hash para validar autenticidad del documento digital';

CREATE INDEX idx_cert_emitido_persona ON aca_certificado_emitido(id_prs_persona);
CREATE INDEX idx_cert_emitido_numero ON aca_certificado_emitido(numero_certificado);

-- ============================================================================
-- SECCIÓN 3: COLEGIOS Y CONVENIOS
-- ============================================================================

-- Tabla: aca_colegio
-- Propósito: Registro de colegios (instituciones de procedencia de estudiantes)
CREATE TABLE IF NOT EXISTS aca_colegio (
                                         id_aca_colegio SERIAL PRIMARY KEY,
                                         nombre_colegio VARCHAR(200) NOT NULL,
                                         direccion TEXT,
                                         director_nombre VARCHAR(150),
                                         director_email VARCHAR(100),
                                         telefono VARCHAR(20),
                                         tipo_colegio VARCHAR(35) NOT NULL DEFAULT 'PUBLICO',
                                         nivel_educativo VARCHAR(100),
                                         estado_colegio VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                         fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                         fecha_mod TIMESTAMP,
                                         user_reg INTEGER NOT NULL,
                                         user_mod INTEGER,
                                         CONSTRAINT chk_colegio_tipo CHECK (tipo_colegio IN ('PUBLICO', 'PRIVADO', 'CONVENIO')),
                                         CONSTRAINT chk_colegio_estado CHECK (estado_colegio IN ('ACTIVO', 'INACTIVO', 'ELIMINADO'))
);

COMMENT ON TABLE aca_colegio IS 'Colegios e instituciones de procedencia de estudiantes';
COMMENT ON COLUMN aca_colegio.tipo_colegio IS 'Tipo: PUBLICO, PRIVADO, CONVENIO (con acuerdo institucional)';
COMMENT ON COLUMN aca_colegio.nivel_educativo IS 'Niveles que atiende (ej: Inicial, Primario, Secundario)';

CREATE INDEX idx_colegio_nombre ON aca_colegio(nombre_colegio);
CREATE INDEX idx_colegio_tipo ON aca_colegio(tipo_colegio);

-- Tabla: aca_tipo_estudiante
-- Propósito: Clasificación de estudiantes para aplicar aranceles diferenciados
CREATE TABLE IF NOT EXISTS aca_tipo_estudiante (
                                                 id_aca_tipo_estudiante SERIAL PRIMARY KEY,
                                                 nombre_tipo VARCHAR(100) NOT NULL,
                                                 descripcion TEXT,
                                                 es_nacional BOOLEAN DEFAULT true,
                                                 requiere_documentacion_adicional BOOLEAN DEFAULT false,
                                                 estado_tipo_estudiante VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                                 fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                                 fecha_mod TIMESTAMP,
                                                 user_reg INTEGER NOT NULL,
                                                 user_mod INTEGER,
                                                 CONSTRAINT chk_tipo_est_estado CHECK (estado_tipo_estudiante IN ('ACTIVO', 'INACTIVO', 'ELIMINADO')),
                                                 UNIQUE(nombre_tipo)
);

COMMENT ON TABLE aca_tipo_estudiante IS 'Clasificación de estudiantes: Nacional, Estudiante UAP, Extranjero, etc.';
COMMENT ON COLUMN aca_tipo_estudiante.es_nacional IS 'Indica si es estudiante nacional o extranjero';

-- Tabla: fin_convenio
-- Propósito: Convenios institucionales que otorgan descuentos
CREATE TABLE IF NOT EXISTS fin_convenio (
                                          id_fin_convenio SERIAL PRIMARY KEY,
                                          nombre_convenio VARCHAR(150) NOT NULL,
                                          descripcion TEXT,
                                          tipo_descuento VARCHAR(35) NOT NULL,
                                          monto_descuento NUMERIC(10,2),
                                          porcentaje_descuento NUMERIC(5,2),
                                          fecha_inicio_vigencia DATE NOT NULL,
                                          fecha_fin_vigencia DATE,
                                          estado_convenio VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                          fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                          fecha_mod TIMESTAMP,
                                          user_reg INTEGER NOT NULL,
                                          user_mod INTEGER,
                                          CONSTRAINT chk_convenio_tipo CHECK (tipo_descuento IN ('MONTO_FIJO', 'PORCENTAJE')),
                                          CONSTRAINT chk_convenio_estado CHECK (estado_convenio IN ('ACTIVO', 'VENCIDO', 'SUSPENDIDO', 'ELIMINADO')),
                                          CONSTRAINT chk_convenio_vigencia CHECK (fecha_fin_vigencia IS NULL OR fecha_fin_vigencia > fecha_inicio_vigencia)
);

COMMENT ON TABLE fin_convenio IS 'Convenios institucionales que otorgan descuentos en aranceles';
COMMENT ON COLUMN fin_convenio.tipo_descuento IS 'MONTO_FIJO: descuento en bolivianos, PORCENTAJE: descuento en %';
COMMENT ON COLUMN fin_convenio.monto_descuento IS 'Monto del descuento si tipo_descuento = MONTO_FIJO';
COMMENT ON COLUMN fin_convenio.porcentaje_descuento IS 'Porcentaje de descuento si tipo_descuento = PORCENTAJE';

-- Tabla: fin_colegio_convenio
-- Propósito: Relación N:N entre colegios y convenios
CREATE TABLE IF NOT EXISTS fin_colegio_convenio (
                                                  id_fin_colegio_convenio SERIAL PRIMARY KEY,
                                                  id_aca_colegio INTEGER NOT NULL,
                                                  id_fin_convenio INTEGER NOT NULL,
                                                  fecha_inicio DATE NOT NULL,
                                                  fecha_fin DATE,
                                                  estado_colegio_convenio VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                                  fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                                  fecha_mod TIMESTAMP,
                                                  user_reg INTEGER NOT NULL,
                                                  user_mod INTEGER,
                                                  FOREIGN KEY (id_aca_colegio) REFERENCES aca_colegio(id_aca_colegio),
                                                  FOREIGN KEY (id_fin_convenio) REFERENCES fin_convenio(id_fin_convenio),
                                                  CONSTRAINT chk_colegio_conv_estado CHECK (estado_colegio_convenio IN ('ACTIVO', 'VENCIDO', 'SUSPENDIDO', 'ELIMINADO')),
                                                  CONSTRAINT chk_colegio_conv_vigencia CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio),
                                                  UNIQUE(id_aca_colegio, id_fin_convenio)
);

COMMENT ON TABLE fin_colegio_convenio IS 'Asociación entre colegios y convenios de descuento';

CREATE INDEX idx_colegio_conv_colegio ON fin_colegio_convenio(id_aca_colegio);
CREATE INDEX idx_colegio_conv_convenio ON fin_colegio_convenio(id_fin_convenio);

-- ============================================================================
-- SECCIÓN 4: ARANCELES Y DESCUENTOS
-- ============================================================================

-- Tabla: fin_concepto_arancel
-- Propósito: Catálogo de conceptos que componen un arancel
CREATE TABLE IF NOT EXISTS fin_concepto_arancel (
                                                  id_fin_concepto_arancel SERIAL PRIMARY KEY,
                                                  nombre_concepto VARCHAR(100) NOT NULL,
                                                  descripcion TEXT,
                                                  es_recurrente BOOLEAN DEFAULT false,
                                                  es_unico BOOLEAN DEFAULT false,
                                                  tipo_concepto VARCHAR(35) NOT NULL,
                                                  estado_concepto VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                                  fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                                  fecha_mod TIMESTAMP,
                                                  user_reg INTEGER NOT NULL,
                                                  user_mod INTEGER,
                                                  CONSTRAINT chk_concepto_tipo CHECK (tipo_concepto IN ('INSCRIPCION', 'COLEGIATURA', 'CERTIFICACION', 'ADMINISTRATIVO', 'OTROS')),
                                                  CONSTRAINT chk_concepto_estado CHECK (estado_concepto IN ('ACTIVO', 'INACTIVO', 'ELIMINADO')),
                                                  UNIQUE(nombre_concepto)
);

COMMENT ON TABLE fin_concepto_arancel IS 'Catálogo de conceptos de cobro (inscripción, colegiatura, etc.)';
COMMENT ON COLUMN fin_concepto_arancel.es_recurrente IS 'Se cobra cada periodo (ej: colegiatura semestral)';
COMMENT ON COLUMN fin_concepto_arancel.es_unico IS 'Se cobra una sola vez en toda la carrera (ej: inscripción inicial)';

-- Tabla: fin_arancel
-- Propósito: Aranceles oficiales por programa, periodo y tipo de estudiante
CREATE TABLE IF NOT EXISTS fin_arancel (
                                         id_fin_arancel SERIAL PRIMARY KEY,
                                         id_aca_programa_aprobado INTEGER NOT NULL,
                                         id_aca_periodo INTEGER,
                                         id_aca_tipo_estudiante INTEGER NOT NULL,
                                         nombre_arancel VARCHAR(200) NOT NULL,
                                         nro_resolucion VARCHAR(50),
                                         fecha_aprobacion DATE,
                                         fecha_inicio_vigencia DATE NOT NULL,
                                         fecha_fin_vigencia DATE,
                                         estado_arancel VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                         fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                         fecha_mod TIMESTAMP,
                                         user_reg INTEGER NOT NULL,
                                         user_mod INTEGER,
                                         FOREIGN KEY (id_aca_programa_aprobado) REFERENCES aca_programa_aprobado(id_aca_programa_aprobado),
                                         FOREIGN KEY (id_aca_periodo) REFERENCES aca_periodo(id_aca_periodo),
                                         FOREIGN KEY (id_aca_tipo_estudiante) REFERENCES aca_tipo_estudiante(id_aca_tipo_estudiante),
                                         CONSTRAINT chk_arancel_estado CHECK (estado_arancel IN ('ACTIVO', 'VENCIDO', 'ELIMINADO')),
                                         CONSTRAINT chk_arancel_vigencia CHECK (fecha_fin_vigencia IS NULL OR fecha_fin_vigencia > fecha_inicio_vigencia)
);

COMMENT ON TABLE fin_arancel IS 'Aranceles oficiales aprobados por resolución. Define precios base por programa y tipo de estudiante';
COMMENT ON COLUMN fin_arancel.id_aca_periodo IS 'NULL = aplica a todos los periodos del programa';
COMMENT ON COLUMN fin_arancel.nro_resolucion IS 'Número de resolución administrativa que aprueba el arancel';

CREATE INDEX idx_arancel_programa ON fin_arancel(id_aca_programa_aprobado);
CREATE INDEX idx_arancel_periodo ON fin_arancel(id_aca_periodo);
CREATE INDEX idx_arancel_tipo_est ON fin_arancel(id_aca_tipo_estudiante);

-- Tabla: fin_detalle_arancel
-- Propósito: Desglose de conceptos que componen un arancel
CREATE TABLE IF NOT EXISTS fin_detalle_arancel (
                                                 id_fin_detalle_arancel SERIAL PRIMARY KEY,
                                                 id_fin_arancel INTEGER NOT NULL,
                                                 id_fin_concepto_arancel INTEGER NOT NULL,
                                                 monto_concepto NUMERIC(10,2) NOT NULL,
                                                 orden_aplicacion INTEGER NOT NULL,
                                                 fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                                 fecha_mod TIMESTAMP,
                                                 user_reg INTEGER NOT NULL,
                                                 user_mod INTEGER,
                                                 FOREIGN KEY (id_fin_arancel) REFERENCES fin_arancel(id_fin_arancel),
                                                 FOREIGN KEY (id_fin_concepto_arancel) REFERENCES fin_concepto_arancel(id_fin_concepto_arancel),
                                                 CONSTRAINT chk_detalle_arancel_monto CHECK (monto_concepto >= 0),
                                                 UNIQUE(id_fin_arancel, id_fin_concepto_arancel)
);

COMMENT ON TABLE fin_detalle_arancel IS 'Desglose de conceptos que componen un arancel (inscripción + colegiatura + otros)';
COMMENT ON COLUMN fin_detalle_arancel.orden_aplicacion IS 'Orden de aplicación de los conceptos para cálculo de totales';

CREATE INDEX idx_detalle_arancel_arancel ON fin_detalle_arancel(id_fin_arancel);

-- Tabla: fin_descuento_arancel
-- Propósito: Descuentos por antigüedad u otros criterios académicos
CREATE TABLE IF NOT EXISTS fin_descuento_arancel (
                                                   id_fin_descuento_arancel SERIAL PRIMARY KEY,
                                                   id_fin_arancel INTEGER NOT NULL,
                                                   nombre_descuento VARCHAR(150) NOT NULL,
                                                   descripcion TEXT,
                                                   tipo_descuento VARCHAR(35) NOT NULL,
                                                   porcentaje_descuento NUMERIC(5,2),
                                                   monto_descuento NUMERIC(10,2),
                                                   aplica_desde_periodo INTEGER,
                                                   requiere_validacion BOOLEAN DEFAULT false,
                                                   estado_descuento VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                                   fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                                   fecha_mod TIMESTAMP,
                                                   user_reg INTEGER NOT NULL,
                                                   user_mod INTEGER,
                                                   FOREIGN KEY (id_fin_arancel) REFERENCES fin_arancel(id_fin_arancel),
                                                   CONSTRAINT chk_desc_arancel_tipo CHECK (tipo_descuento IN ('PORCENTAJE', 'MONTO_FIJO')),
                                                   CONSTRAINT chk_desc_arancel_estado CHECK (estado_descuento IN ('ACTIVO', 'INACTIVO', 'ELIMINADO'))
);

COMMENT ON TABLE fin_descuento_arancel IS 'Descuentos aplicables a aranceles por antigüedad u otros criterios';
COMMENT ON COLUMN fin_descuento_arancel.aplica_desde_periodo IS 'A partir de qué número de periodo aplica (ej: desde 2do semestre en adelante)';
COMMENT ON COLUMN fin_descuento_arancel.requiere_validacion IS 'Si requiere validación manual por personal administrativo';

-- ============================================================================
-- SECCIÓN 5: CALIFICACIONES POR COMPETENCIAS
-- ============================================================================

-- Tabla: eje_area_evaluacion
-- Propósito: Catálogo de áreas/competencias evaluables (Listening, Speaking, etc.)
CREATE TABLE IF NOT EXISTS eje_area_evaluacion (
                                                 id_eje_area_evaluacion SERIAL PRIMARY KEY,
                                                 id_aca_programa_aprobado INTEGER,
                                                 nombre_area VARCHAR(100) NOT NULL,
                                                 descripcion TEXT,
                                                 orden INTEGER NOT NULL,
                                                 estado_area_evaluacion VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                                 fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                                 fecha_mod TIMESTAMP,
                                                 user_reg INTEGER NOT NULL,
                                                 user_mod INTEGER,
                                                 FOREIGN KEY (id_aca_programa_aprobado) REFERENCES aca_programa_aprobado(id_aca_programa_aprobado),
                                                 CONSTRAINT chk_area_eval_estado CHECK (estado_area_evaluacion IN ('ACTIVO', 'INACTIVO', 'ELIMINADO'))
);

COMMENT ON TABLE eje_area_evaluacion IS 'Catálogo de áreas/competencias evaluables. NULL en programa = aplica a todos';
COMMENT ON COLUMN eje_area_evaluacion.id_aca_programa_aprobado IS 'NULL = área genérica aplicable a cualquier programa';
COMMENT ON COLUMN eje_area_evaluacion.nombre_area IS 'Nombre de la competencia (Listening, Speaking, Cálculo, etc.)';

CREATE INDEX idx_area_eval_programa ON eje_area_evaluacion(id_aca_programa_aprobado);

-- Tabla: eje_detalle_calificacion
-- Propósito: Desglose de calificaciones por área/competencia
CREATE TABLE IF NOT EXISTS eje_detalle_calificacion (
                                                      id_eje_detalle_calificacion SERIAL PRIMARY KEY,
                                                      id_eje_calificacion INTEGER NOT NULL,
                                                      id_eje_area_evaluacion INTEGER NOT NULL,
                                                      nota_progress_test NUMERIC(5,2),
                                                      nota_class_performance NUMERIC(5,2),
                                                      comentario_docente TEXT,
                                                      nota_final_area NUMERIC(5,2) NOT NULL,
                                                      estado_detalle_calificacion VARCHAR(35) NOT NULL DEFAULT 'ACTIVO',
                                                      fecha_reg TIMESTAMP NOT NULL DEFAULT NOW(),
                                                      fecha_mod TIMESTAMP,
                                                      user_reg INTEGER NOT NULL,
                                                      user_mod INTEGER,
                                                      FOREIGN KEY (id_eje_calificacion) REFERENCES eje_calificacion(id_eje_calificacion),
                                                      FOREIGN KEY (id_eje_area_evaluacion) REFERENCES eje_area_evaluacion(id_eje_area_evaluacion),
                                                      CONSTRAINT chk_detalle_calif_notas CHECK (
                                                        nota_progress_test IS NULL OR (nota_progress_test >= 0 AND nota_progress_test <= 100)
                                                        ),
                                                      CONSTRAINT chk_detalle_calif_performance CHECK (
                                                        nota_class_performance IS NULL OR (nota_class_performance >= 0 AND nota_class_performance <= 100)
                                                        ),
                                                      CONSTRAINT chk_detalle_calif_final CHECK (nota_final_area >= 0 AND nota_final_area <= 100),
                                                      CONSTRAINT chk_detalle_calif_estado CHECK (estado_detalle_calificacion IN ('ACTIVO', 'ELIMINADO')),
                                                      UNIQUE(id_eje_calificacion, id_eje_area_evaluacion)
);

COMMENT ON TABLE eje_detalle_calificacion IS 'Desglose de calificaciones por áreas/competencias específicas';
COMMENT ON COLUMN eje_detalle_calificacion.nota_progress_test IS 'Nota de examen de progreso (puede ser NULL)';
COMMENT ON COLUMN eje_detalle_calificacion.nota_class_performance IS 'Nota de desempeño en clase (puede ser NULL)';
COMMENT ON COLUMN eje_detalle_calificacion.nota_final_area IS 'Nota final consolidada del área';

CREATE INDEX idx_detalle_calif_calif ON eje_detalle_calificacion(id_eje_calificacion);
CREATE INDEX idx_detalle_calif_area ON eje_detalle_calificacion(id_eje_area_evaluacion);

-- ============================================================================
-- SECCIÓN 6: MODIFICACIONES A TABLAS EXISTENTES
-- ============================================================================

-- Modificación: aca_programa_aprobado
-- Agregar campo sistema_programa
DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'aca_programa_aprobado'
        AND column_name = 'sistema_programa'
    ) THEN
      ALTER TABLE aca_programa_aprobado
        ADD COLUMN sistema_programa VARCHAR(35) NOT NULL DEFAULT 'REGULAR';

      ALTER TABLE aca_programa_aprobado
        ADD CONSTRAINT chk_programa_sistema
          CHECK (sistema_programa IN ('REGULAR', 'ACELERADO', 'MODULAR'));

      COMMENT ON COLUMN aca_programa_aprobado.sistema_programa IS 'Sistema del programa: REGULAR, ACELERADO, MODULAR';
    END IF;
  END $$;

-- Agregar campo sistema_programa
DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'aca_programa_aprobado'
        AND column_name = 'sistema_programa'
    ) THEN
      ALTER TABLE aca_programa
        ADD COLUMN tipo_programa VARCHAR(35) NOT NULL DEFAULT 'REGULAR';
    END IF;
  END $$;

-- Modificación: prs_persona
-- Agregar relación recursiva para apoderado y colegio de procedencia
DO $$
  BEGIN
    -- Agregar colegio de procedencia
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'prs_persona'
        AND column_name = 'id_aca_colegio_procedencia'
    ) THEN
      ALTER TABLE prs_persona
        ADD COLUMN id_aca_colegio_procedencia INTEGER,
        ADD CONSTRAINT fk_persona_colegio
          FOREIGN KEY (id_aca_colegio_procedencia)
            REFERENCES aca_colegio(id_aca_colegio);

      CREATE INDEX idx_persona_colegio ON prs_persona(id_aca_colegio_procedencia);

      COMMENT ON COLUMN prs_persona.id_aca_colegio_procedencia IS 'Colegio de procedencia del estudiante';
    END IF;

    -- Agregar apoderado (relación recursiva)
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'prs_persona'
        AND column_name = 'id_prs_persona_apoderado'
    ) THEN
      ALTER TABLE prs_persona
        ADD COLUMN id_prs_persona_apoderado INTEGER,
        ADD COLUMN tipo_relacion_apoderado VARCHAR(50),
        ADD COLUMN telefono_apoderado VARCHAR(20),
        ADD COLUMN email_apoderado VARCHAR(100),
        ADD CONSTRAINT fk_persona_apoderado
          FOREIGN KEY (id_prs_persona_apoderado)
            REFERENCES prs_persona(id_prs_persona);

      ALTER TABLE prs_persona
        ADD CONSTRAINT chk_persona_tipo_relacion
          CHECK (tipo_relacion_apoderado IS NULL OR tipo_relacion_apoderado IN (
                                                                                'PADRE', 'MADRE', 'TUTOR', 'ABUELO', 'ABUELA', 'TIO', 'TIA', 'HERMANO', 'HERMANA', 'OTRO'
            ));

      CREATE INDEX idx_persona_apoderado ON prs_persona(id_prs_persona_apoderado);

      COMMENT ON COLUMN prs_persona.id_prs_persona_apoderado IS 'Relación recursiva: referencia al apoderado/tutor del estudiante';
      COMMENT ON COLUMN prs_persona.tipo_relacion_apoderado IS 'Tipo de relación: PADRE, MADRE, TUTOR, ABUELO, etc.';
    END IF;
  END $$;

-- Modificación: eje_docente
-- Agregar campos de contrato
DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'eje_docente'
        AND column_name = 'numero_contrato'
    ) THEN
      ALTER TABLE eje_docente
        ADD COLUMN numero_contrato VARCHAR(50),
        ADD COLUMN fecha_inicio_contrato DATE,
        ADD COLUMN fecha_fin_contrato DATE,
        ADD COLUMN nivel_academico VARCHAR(100),
        ADD COLUMN especialidad TEXT,
        ADD COLUMN hoja_vida_uri TEXT;

      COMMENT ON COLUMN eje_docente.numero_contrato IS 'Número de contrato del docente (ej: 002/2025)';
      COMMENT ON COLUMN eje_docente.nivel_academico IS 'Nivel académico: Licenciatura, Técnico Superior, Maestría, etc.';
      COMMENT ON COLUMN eje_docente.especialidad IS 'Especialidad o área de conocimiento';
      COMMENT ON COLUMN eje_docente.hoja_vida_uri IS 'URI del archivo de hoja de vida/CV';
    END IF;
  END $$;

-- Modificación: eje_cronograma_modulo
-- Agregar periodo, docente y fechas de inscripción
DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'eje_cronograma_modulo'
        AND column_name = 'id_aca_periodo'
    ) THEN
      ALTER TABLE eje_cronograma_modulo
        ADD COLUMN id_aca_periodo INTEGER,
        ADD COLUMN fecha_inicio_inscripciones DATE,
        ADD COLUMN fecha_fin_inscripciones DATE,
        ADD COLUMN permite_inscripciones BOOLEAN DEFAULT false,
        ADD CONSTRAINT fk_cronograma_periodo
          FOREIGN KEY (id_aca_periodo)
            REFERENCES aca_periodo(id_aca_periodo),
        ADD CONSTRAINT fk_cronograma_docente
          FOREIGN KEY (id_eje_docente)
            REFERENCES eje_docente(id_eje_docente);

      CREATE INDEX idx_cronograma_periodo ON eje_cronograma_modulo(id_aca_periodo);
      CREATE INDEX idx_cronograma_docente ON eje_cronograma_modulo(id_eje_docente);

      COMMENT ON COLUMN eje_cronograma_modulo.id_aca_periodo IS 'Periodo académico en que se ejecuta este módulo';
      COMMENT ON COLUMN eje_cronograma_modulo.id_eje_docente IS 'Docente asignado a este cronograma de módulo';
      COMMENT ON COLUMN eje_cronograma_modulo.permite_inscripciones IS 'Flag para habilitar/deshabilitar inscripciones';
    END IF;
  END $$;

-- Modificación: ins_grupo
-- Agregar campos de oferta (horario, aula, cupo)
DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'ins_grupo'
        AND column_name = 'codigo_paralelo'
    ) THEN
      ALTER TABLE ins_grupo
        ADD COLUMN codigo_paralelo VARCHAR(10),
        ADD COLUMN horario VARCHAR(50),
        ADD COLUMN aula VARCHAR(20),
        ADD COLUMN fecha_inicio DATE,
        ADD COLUMN fecha_fin DATE;

      COMMENT ON COLUMN ins_grupo.codigo_paralelo IS 'Código del paralelo (A, B, C, etc.) - puede ser NULL';
      COMMENT ON COLUMN ins_grupo.horario IS 'Horario de clases (ej: 15:00-16:30)';
      COMMENT ON COLUMN ins_grupo.aula IS 'Aula asignada (ej: C-5, D-9)';
    END IF;
  END $$;

-- Modificación: ins_matricula
-- Agregar tipo estudiante, arancel y convenio aplicado
DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'ins_matricula'
        AND column_name = 'id_aca_tipo_estudiante'
    ) THEN
      ALTER TABLE ins_matricula
        ADD COLUMN id_aca_tipo_estudiante INTEGER,
        ADD COLUMN id_fin_arancel_aplicado INTEGER,
        ADD COLUMN id_fin_convenio_aplicado INTEGER,
        ADD COLUMN numero_periodo_cursando INTEGER,
        ADD COLUMN es_estudiante_antiguo BOOLEAN DEFAULT false,
        ADD CONSTRAINT fk_matricula_tipo_estudiante
          FOREIGN KEY (id_aca_tipo_estudiante)
            REFERENCES aca_tipo_estudiante(id_aca_tipo_estudiante),
        ADD CONSTRAINT fk_matricula_arancel
          FOREIGN KEY (id_fin_arancel_aplicado)
            REFERENCES fin_arancel(id_fin_arancel),
        ADD CONSTRAINT fk_matricula_convenio
          FOREIGN KEY (id_fin_convenio_aplicado)
            REFERENCES fin_convenio(id_fin_convenio);

      CREATE INDEX idx_matricula_tipo_est ON ins_matricula(id_aca_tipo_estudiante);
      CREATE INDEX idx_matricula_arancel ON ins_matricula(id_fin_arancel_aplicado);
      CREATE INDEX idx_matricula_convenio ON ins_matricula(id_fin_convenio_aplicado);

      COMMENT ON COLUMN ins_matricula.id_aca_tipo_estudiante IS 'Tipo de estudiante para aplicar arancel correspondiente';
      COMMENT ON COLUMN ins_matricula.id_fin_arancel_aplicado IS 'Arancel que se aplicó en esta matrícula';
      COMMENT ON COLUMN ins_matricula.id_fin_convenio_aplicado IS 'Convenio de descuento aplicado (si aplica)';
      COMMENT ON COLUMN ins_matricula.numero_periodo_cursando IS 'Número de periodo que está cursando (1, 2, 3...)';
    END IF;

    -- Permitir ins_grupo NULL para preinscripciones
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'ins_matricula'
        AND column_name = 'id_ins_grupo'
        AND is_nullable = 'NO'
    ) THEN
      ALTER TABLE ins_matricula
        ALTER COLUMN id_ins_grupo DROP NOT NULL;

      COMMENT ON COLUMN ins_matricula.id_ins_grupo IS 'Grupo asignado (puede ser NULL para preinscripciones)';
    END IF;
  END $$;

-- Modificación: fin_obligacion_pago
-- Agregar detalles de pago y descuentos
DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'fin_obligacion_pago'
        AND column_name = 'metodo_pago'
    ) THEN
      ALTER TABLE fin_obligacion_pago
        ADD COLUMN metodo_pago VARCHAR(50),
        ADD COLUMN monto_base NUMERIC(10,2),
        ADD COLUMN monto_descuento_arancel NUMERIC(10,2) DEFAULT 0,
        ADD COLUMN monto_descuento_convenio NUMERIC(10,2) DEFAULT 0,
        ADD COLUMN monto_final NUMERIC(10,2),
        ADD COLUMN comprobante_pago_uri TEXT,
        ADD COLUMN observaciones_pago TEXT;

      ALTER TABLE fin_obligacion_pago
        ADD CONSTRAINT chk_pago_metodo
          CHECK (metodo_pago IS NULL OR metodo_pago IN ('EFECTIVO', 'TRANSFERENCIA', 'QR', 'TARJETA', 'CHEQUE'));

      COMMENT ON COLUMN fin_obligacion_pago.metodo_pago IS 'Método de pago: EFECTIVO, TRANSFERENCIA, QR, TARJETA, CHEQUE';
      COMMENT ON COLUMN fin_obligacion_pago.monto_base IS 'Monto original del arancel sin descuentos';
      COMMENT ON COLUMN fin_obligacion_pago.monto_descuento_arancel IS 'Descuento por antigüedad u otros del arancel';
      COMMENT ON COLUMN fin_obligacion_pago.monto_descuento_convenio IS 'Descuento por convenio institucional';
      COMMENT ON COLUMN fin_obligacion_pago.monto_final IS 'Monto final a pagar = base - desc_arancel - desc_convenio';
    END IF;
  END $$;

-- Modificación: eje_calificacion
-- Agregar campos de resumen y progresión
DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name = 'eje_calificacion'
        AND column_name = 'comentario_general'
    ) THEN
      ALTER TABLE eje_calificacion
        ADD COLUMN comentario_general TEXT,
        ADD COLUMN total_faltas INTEGER DEFAULT 0,
        ADD COLUMN debe_repetir BOOLEAN DEFAULT false,
        ADD COLUMN pasa_a_modulo INTEGER,
        ADD CONSTRAINT fk_calificacion_prox_modulo
          FOREIGN KEY (pasa_a_modulo)
            REFERENCES aca_modulo(id_aca_modulo);

      COMMENT ON COLUMN eje_calificacion.comentario_general IS 'Comentario general del docente sobre el desempeño del estudiante';
      COMMENT ON COLUMN eje_calificacion.total_faltas IS 'Total de inasistencias del estudiante';
      COMMENT ON COLUMN eje_calificacion.debe_repetir IS 'Indica si el estudiante debe repetir el módulo';
      COMMENT ON COLUMN eje_calificacion.pasa_a_modulo IS 'ID del siguiente módulo al que pasa (si aprueba)';
    END IF;
  END $$;

-- ============================================================================
-- SECCIÓN 7: DATOS INICIALES (SEEDS)
-- ============================================================================

-- Modalidades de graduación
INSERT INTO aca_modalidad_graduacion (nombre_modalidad, requiere_tesis, requiere_examen, requiere_proyecto, orden, estado_modalidad_graduacion, fecha_reg, user_reg)
VALUES
  ('Graduación Directa para Técnicos Medios', false, false, false, 1, 'ACTIVO', NOW(), 1),
  ('Examen de Grado a Nivel Técnico Superior', false, true, false, 2, 'ACTIVO', NOW(), 1),
  ('Proyecto de Grado', false, false, true, 3, 'ACTIVO', NOW(), 1),
  ('Monografía', true, false, false, 4, 'ACTIVO', NOW(), 1),
  ('Certificado por Culminación de Curso', false, false, false, 5, 'ACTIVO', NOW(), 1),
  ('Certificado de Asistencia', false, false, false, 6, 'ACTIVO', NOW(), 1)
ON CONFLICT (nombre_modalidad) DO NOTHING;

-- Tipos de estudiante
INSERT INTO aca_tipo_estudiante (nombre_tipo, descripcion, es_nacional, requiere_documentacion_adicional, estado_tipo_estudiante, fecha_reg, user_reg)
VALUES
  ('Nacional', 'Estudiante boliviano', true, false, 'ACTIVO', NOW(), 1),
  ('Estudiante UAP', 'Estudiante regular de la Universidad Amazónica de Pando', true, false, 'ACTIVO', NOW(), 1),
  ('Extranjero', 'Estudiante de nacionalidad extranjera', false, true, 'ACTIVO', NOW(), 1)
ON CONFLICT (nombre_tipo) DO NOTHING;

-- Conceptos de arancel
INSERT INTO fin_concepto_arancel (nombre_concepto, descripcion, es_recurrente, es_unico, tipo_concepto, estado_concepto, fecha_reg, user_reg)
VALUES
  ('Inscripción', 'Inscripción al programa', false, true, 'INSCRIPCION', 'ACTIVO', NOW(), 1),
  ('Cédula Universitaria', 'Emisión de cédula universitaria', false, true, 'INSCRIPCION', 'ACTIVO', NOW(), 1),
  ('Carpeta Única', 'Apertura de carpeta académica', false, true, 'INSCRIPCION', 'ACTIVO', NOW(), 1),
  ('Colegiatura Semestral', 'Colegiatura por semestre académico', true, false, 'COLEGIATURA', 'ACTIVO', NOW(), 1),
  ('Colegiatura Trimestral', 'Colegiatura por trimestre académico', true, false, 'COLEGIATURA', 'ACTIVO', NOW(), 1),
  ('Certificado de Egreso', 'Emisión de certificado de egreso', false, true, 'CERTIFICACION', 'ACTIVO', NOW(), 1),
  ('Título en Provisión Nacional', 'Emisión de título profesional', false, true, 'CERTIFICACION', 'ACTIVO', NOW(), 1)
ON CONFLICT (nombre_concepto) DO NOTHING;

-- Áreas de evaluación para programas de idiomas (genéricas)
INSERT INTO eje_area_evaluacion (id_aca_programa_aprobado, nombre_area, descripcion, orden, estado_area_evaluacion, fecha_reg, user_reg)
VALUES
  (NULL, 'Listening', 'Comprensión auditiva', 1, 'ACTIVO', NOW(), 1),
  (NULL, 'Speaking', 'Expresión oral', 2, 'ACTIVO', NOW(), 1),
  (NULL, 'Reading', 'Comprensión lectora', 3, 'ACTIVO', NOW(), 1),
  (NULL, 'Writing', 'Expresión escrita', 4, 'ACTIVO', NOW(), 1),
  (NULL, 'Vocabulary', 'Vocabulario', 5, 'ACTIVO', NOW(), 1),
  (NULL, 'Grammar', 'Gramática', 6, 'ACTIVO', NOW(), 1)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- FIN DE MIGRACIÓN
-- ============================================================================

-- Mensaje de confirmación
DO $$
  BEGIN
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'MIGRACIÓN V025 COMPLETADA EXITOSAMENTE';
    RAISE NOTICE 'Se crearon las siguientes tablas:';
    RAISE NOTICE '- aca_gestion, aca_periodo';
    RAISE NOTICE '- aca_modalidad_graduacion, aca_titulo_certificado';
    RAISE NOTICE '- aca_certificacion_programa, aca_programa_modalidad_graduacion';
    RAISE NOTICE '- aca_certificado_emitido';
    RAISE NOTICE '- aca_colegio, aca_tipo_estudiante';
    RAISE NOTICE '- fin_convenio, fin_colegio_convenio';
    RAISE NOTICE '- fin_concepto_arancel, fin_arancel, fin_detalle_arancel, fin_descuento_arancel';
    RAISE NOTICE '- eje_area_evaluacion, eje_detalle_calificacion';
    RAISE NOTICE '';
    RAISE NOTICE 'Se modificaron las siguientes tablas:';
    RAISE NOTICE '- aca_programa_aprobado (sistema_programa)';
    RAISE NOTICE '- prs_persona (apoderado, colegio)';
    RAISE NOTICE '- eje_docente (contrato)';
    RAISE NOTICE '- eje_cronograma_modulo (periodo, inscripciones)';
    RAISE NOTICE '- ins_grupo (horario, aula, cupo)';
    RAISE NOTICE '- ins_matricula (tipo estudiante, arancel, convenio)';
    RAISE NOTICE '- fin_obligacion_pago (método pago, descuentos)';
    RAISE NOTICE '- eje_calificacion (comentarios, faltas, progresión)';
    RAISE NOTICE '============================================================================';
  END $$;
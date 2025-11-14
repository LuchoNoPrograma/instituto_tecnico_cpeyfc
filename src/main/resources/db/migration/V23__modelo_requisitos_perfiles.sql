-- ============================================
-- TABLAS PARA GESTIÓN DE REQUISITOS Y PERFILES
-- ============================================

-- Catálogo de requisitos disponibles
CREATE TABLE aca_requisito (
  id_aca_requisito SERIAL PRIMARY KEY,
  nombre_requisito CHARACTER VARYING(100) NOT NULL,
  descripcion TEXT,
  orden_presentacion INTEGER,
  estado_requisito CHARACTER VARYING(35) NOT NULL,
  fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  fecha_mod TIMESTAMP WITHOUT TIME ZONE,
  user_reg INTEGER NOT NULL,
  user_mod INTEGER
);

COMMENT ON TABLE aca_requisito IS 'Catálogo maestro de requisitos documentales para inscripción';
COMMENT ON COLUMN aca_requisito.nombre_requisito IS 'Nombre del requisito (Fotocopia CI, Título bachiller, Baucher de pago, etc)';
COMMENT ON COLUMN aca_requisito.orden_presentacion IS 'Orden de presentación en formularios';
COMMENT ON COLUMN aca_requisito.estado_requisito IS 'Estados: ACTIVO, INACTIVO, ELIMINADO';

-- Perfiles/tipos de estudiante
CREATE TABLE aca_perfil_estudiante (
  id_aca_perfil_estudiante SERIAL PRIMARY KEY,
  nombre_perfil CHARACTER VARYING(50) NOT NULL,
  descripcion TEXT,
  estado_perfil_estudiante CHARACTER VARYING(35) NOT NULL,
  fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  fecha_mod TIMESTAMP WITHOUT TIME ZONE,
  user_reg INTEGER NOT NULL,
  user_mod INTEGER
);

COMMENT ON TABLE aca_perfil_estudiante IS 'Tipos/perfiles de estudiante según su situación académica';
COMMENT ON COLUMN aca_perfil_estudiante.nombre_perfil IS 'Nombre del perfil (Estudiante colegio, Docente, Niñ@s, Est.Universitario)';
COMMENT ON COLUMN aca_perfil_estudiante.estado_perfil_estudiante IS 'Estados: ACTIVO, INACTIVO, ELIMINADO';

-- Configuración: qué requisitos aplican a qué perfil
CREATE TABLE aca_requisito_perfil (
  id_aca_requisito_perfil SERIAL PRIMARY KEY,
  id_aca_requisito INTEGER NOT NULL,
  id_aca_perfil_estudiante INTEGER NOT NULL,
  estado_requisito_perfil CHARACTER VARYING(35) NOT NULL,
  fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  fecha_mod TIMESTAMP WITHOUT TIME ZONE,
  user_reg INTEGER NOT NULL,
  user_mod INTEGER
);

COMMENT ON TABLE aca_requisito_perfil IS 'Matriz de requisitos: define qué requisitos aplican a cada perfil de estudiante';
COMMENT ON COLUMN aca_requisito_perfil.estado_requisito_perfil IS 'Estados: ACTIVO, INACTIVO, ELIMINADO';

-- Cumplimiento de requisitos por estudiante
CREATE TABLE ins_estudiante_requisito (
  id_ins_estudiante_requisito SERIAL PRIMARY KEY,
  cod_ins_matricula INTEGER NOT NULL,
  id_aca_requisito INTEGER NOT NULL,
  fecha_presentacion DATE,
  esta_verificado BOOLEAN DEFAULT FALSE,
  observaciones TEXT,
  ruta_documento CHARACTER VARYING(255),
  estado_estudiante_requisito CHARACTER VARYING(35) NOT NULL,
  fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  fecha_mod TIMESTAMP WITHOUT TIME ZONE,
  user_reg INTEGER NOT NULL,
  user_mod INTEGER
);

COMMENT ON TABLE ins_estudiante_requisito IS 'Registro de cumplimiento de requisitos por estudiante matriculado';
COMMENT ON COLUMN ins_estudiante_requisito.fecha_presentacion IS 'Fecha en que el estudiante presentó el requisito';
COMMENT ON COLUMN ins_estudiante_requisito.esta_verificado IS 'Indica si el requisito fue verificado por personal administrativo';
COMMENT ON COLUMN ins_estudiante_requisito.ruta_documento IS 'Ruta del documento digitalizado (si aplica)';
COMMENT ON COLUMN ins_estudiante_requisito.estado_estudiante_requisito IS 'Estados: PENDIENTE, PRESENTADO, VERIFICADO, RECHAZADO, ELIMINADO';

-- Elegibilidad: qué perfiles pueden inscribirse a qué programas
CREATE TABLE aca_programa_perfil (
  id_aca_programa_perfil SERIAL PRIMARY KEY,
  id_aca_programa INTEGER NOT NULL,
  id_aca_perfil_estudiante INTEGER NOT NULL,
  observaciones TEXT,
  estado_programa_perfil CHARACTER VARYING(35) NOT NULL,
  fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  fecha_mod TIMESTAMP WITHOUT TIME ZONE,
  user_reg INTEGER NOT NULL,
  user_mod INTEGER
);

COMMENT ON TABLE aca_programa_perfil IS 'Define qué perfiles de estudiante son elegibles para inscribirse en cada programa (dirigido a)';
COMMENT ON COLUMN aca_programa_perfil.observaciones IS 'Información adicional de elegibilidad (ej: "Dirigido a profesionales del área")';
COMMENT ON COLUMN aca_programa_perfil.estado_programa_perfil IS 'Estados: ACTIVO, INACTIVO, ELIMINADO';

-- Foreign Keys
ALTER TABLE aca_requisito_perfil ADD CONSTRAINT fk_aca_requ_requisito_aca_requ FOREIGN KEY (id_aca_requisito) REFERENCES aca_requisito (id_aca_requisito) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE aca_requisito_perfil ADD CONSTRAINT fk_aca_requ_perfil_es_aca_perf FOREIGN KEY (id_aca_perfil_estudiante) REFERENCES aca_perfil_estudiante (id_aca_perfil_estudiante) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ins_estudiante_requisito ADD CONSTRAINT fk_ins_estu_matricula_ins_matr FOREIGN KEY (cod_ins_matricula) REFERENCES ins_matricula (cod_ins_matricula) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ins_estudiante_requisito ADD CONSTRAINT fk_ins_estu_requisito_aca_requ FOREIGN KEY (id_aca_requisito) REFERENCES aca_requisito (id_aca_requisito) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE aca_programa_perfil ADD CONSTRAINT fk_aca_prog_programa__aca_prog FOREIGN KEY (id_aca_programa) REFERENCES aca_programa (id_aca_programa) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE aca_programa_perfil ADD CONSTRAINT fk_aca_prog_perfil_es_aca_perf FOREIGN KEY (id_aca_perfil_estudiante) REFERENCES aca_perfil_estudiante (id_aca_perfil_estudiante) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Unique Constraints
ALTER TABLE aca_requisito_perfil ADD CONSTRAINT uk_requisito_perfil UNIQUE (id_aca_requisito, id_aca_perfil_estudiante);
ALTER TABLE aca_programa_perfil ADD CONSTRAINT uk_programa_perfil UNIQUE (id_aca_programa, id_aca_perfil_estudiante);

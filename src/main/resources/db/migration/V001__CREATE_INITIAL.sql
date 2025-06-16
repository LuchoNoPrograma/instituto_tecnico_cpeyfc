CREATE SEQUENCE  IF NOT EXISTS primary_sequence START WITH 10000 INCREMENT BY 1;

CREATE TABLE aca_area (
    id_aca_area INTEGER NOT NULL,
    nombre_area VARCHAR(100) NOT NULL,
    estado_area VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    CONSTRAINT aca_area_pkey PRIMARY KEY (id_aca_area)
);

CREATE TABLE aca_modalidad (
    id_aca_modalidad INTEGER NOT NULL,
    nombre_modalidad VARCHAR(50) NOT NULL,
    estado_modalidad VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    CONSTRAINT aca_modalidad_pkey PRIMARY KEY (id_aca_modalidad)
);

CREATE TABLE aca_modulo (
    id_aca_modulo INTEGER NOT NULL,
    nombre_modulo VARCHAR(100) NOT NULL,
    estado_modulo VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    CONSTRAINT aca_modulo_pkey PRIMARY KEY (id_aca_modulo)
);

CREATE TABLE aca_nivel (
    id_aca_nivel INTEGER NOT NULL,
    nombre_nivel VARCHAR(100) NOT NULL,
    estado_nivel VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    CONSTRAINT aca_nivel_pkey PRIMARY KEY (id_aca_nivel)
);

CREATE TABLE aca_parametro_programa (
    id_aca_parametro INTEGER NOT NULL,
    nombre_param VARCHAR(55) NOT NULL,
    valor TEXT NOT NULL,
    tipo_dato_param VARCHAR(35) NOT NULL,
    fecha_inicio_vigencia date,
    fecha_fin_vigencia date,
    orden INTEGER NOT NULL,
    estado_parametro_programa VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    aca_programa_aprobado_id INTEGER NOT NULL,
    CONSTRAINT aca_parametro_programa_pkey PRIMARY KEY (id_aca_parametro)
);

CREATE TABLE aca_plan_estudio (
    id_aca_plan_estudio INTEGER NOT NULL,
    anho INTEGER NOT NULL,
    vigente BOOLEAN NOT NULL,
    estado_plan_estudio VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    CONSTRAINT aca_plan_estudio_pkey PRIMARY KEY (id_aca_plan_estudio)
);

CREATE TABLE aca_plan_modulo_detalle (
    id_aca_plan_modulo_detalle INTEGER NOT NULL,
    carga_horaria INTEGER NOT NULL,
    creditos numeric(6, 2) NOT NULL,
    orden INTEGER NOT NULL,
    sigla VARCHAR(10) NOT NULL,
    competencia TEXT,
    estado_plan_modulo_detalle VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    aca_modulo_id INTEGER NOT NULL,
    aca_nivel_id INTEGER NOT NULL,
    aca_plan_estudio_id INTEGER NOT NULL,
    CONSTRAINT aca_plan_modulo_detalle_pkey PRIMARY KEY (id_aca_plan_modulo_detalle)
);

CREATE TABLE aca_programa (
    id_aca_programa INTEGER NOT NULL,
    nombre_programa VARCHAR(100) NOT NULL,
    sigla VARCHAR(15),
    estado_programa VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    aca_area_id INTEGER NOT NULL,
    CONSTRAINT aca_programa_pkey PRIMARY KEY (id_aca_programa)
);

CREATE TABLE aca_programa_aprobado (
    id_aca_programa_aprobado INTEGER NOT NULL,
    fecha_inicio_vigencia date,
    fecha_fin_vigencia date,
    estado_programa_aprobado VARCHAR(35) NOT NULL,
    gestion INTEGER NOT NULL,
    cod_certificado_ceub VARCHAR(55),
    cod_sigla_version VARCHAR(15),
    precio_matricula numeric(8, 2) NOT NULL,
    precio_colegiatura numeric(8, 2) NOT NULL,
    precio_titulacion numeric(8, 2),
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    aca_plan_estudio_id INTEGER,
    aca_programa_id INTEGER NOT NULL,
    aca_modalidad_id INTEGER NOT NULL,
    aca_version_id INTEGER NOT NULL,
    CONSTRAINT aca_programa_aprobado_pkey PRIMARY KEY (id_aca_programa_aprobado)
);

CREATE TABLE aca_version (
    id_aca_version INTEGER NOT NULL,
    cod_version VARCHAR(10) NOT NULL,
    estado_version VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    CONSTRAINT aca_version_pkey PRIMARY KEY (id_aca_version)
);

CREATE TABLE cer_certificado (
    id_cer_certificado INTEGER NOT NULL,
    tipo_certificado VARCHAR(35) NOT NULL,
    estado_certificado VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    eje_administrativo_id INTEGER NOT NULL,
    cod_ins_matricula_id INTEGER NOT NULL,
    CONSTRAINT cer_certificado_pkey PRIMARY KEY (id_cer_certificado)
);

CREATE TABLE cer_impresion (
    id_cer_impresion INTEGER NOT NULL,
    num_impresion INTEGER NOT NULL,
    hash_impresion VARCHAR(255) NOT NULL,
    estado_impresion VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    cer_certificado_id INTEGER NOT NULL,
    fin_obligacion_pago_id INTEGER NOT NULL,
    CONSTRAINT cer_impresion_pkey PRIMARY KEY (id_cer_impresion)
);

CREATE TABLE cer_titulacion (
    id_cer_titulacion INTEGER NOT NULL,
    cod_titulo VARCHAR(25) NOT NULL,
    uri_titulo TEXT NOT NULL,
    estado_titulacion VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    cod_ins_matricula_id INTEGER NOT NULL,
    CONSTRAINT cer_titulacion_pkey PRIMARY KEY (id_cer_titulacion)
);

CREATE TABLE eje_administrativo (
    id_eje_administrativo INTEGER NOT NULL,
    estado_administrativo VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    seg_usuario_id INTEGER NOT NULL,
    prs_persona_id INTEGER NOT NULL,
    CONSTRAINT eje_administrativo_pkey PRIMARY KEY (id_eje_administrativo)
);

CREATE TABLE eje_calificacion (
    id_eje_calificacion INTEGER NOT NULL,
    nota numeric(5, 2),
    estado_calificacion VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    eje_criterio_eval_id INTEGER NOT NULL,
    eje_programacion_id INTEGER NOT NULL,
    CONSTRAINT eje_calificacion_pkey PRIMARY KEY (id_eje_calificacion)
);

CREATE TABLE eje_criterio_eval (
    id_eje_criterio_eval INTEGER NOT NULL,
    nombre_crit VARCHAR(25) NOT NULL,
    descripcion VARCHAR(155),
    ponderacion INTEGER NOT NULL,
    orden INTEGER NOT NULL,
    estado_criterio_eval VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    eje_cronograma_modulo_id INTEGER NOT NULL,
    CONSTRAINT eje_criterio_eval_pkey PRIMARY KEY (id_eje_criterio_eval)
);

CREATE TABLE eje_cronograma_modulo (
    id_eje_cronograma_modulo INTEGER NOT NULL,
    fecha_inicio date,
    fecha_fin date,
    estado_cronograma_modulo VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    aca_plan_modulo_detalle_id INTEGER NOT NULL,
    eje_docente_id INTEGER,
    ins_grupo_id INTEGER NOT NULL,
    CONSTRAINT eje_cronograma_modulo_pkey PRIMARY KEY (id_eje_cronograma_modulo)
);

CREATE TABLE eje_docente (
    id_eje_docente INTEGER NOT NULL,
    nro_resolucion INTEGER,
    estado_docente VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    seg_usuario_id INTEGER NOT NULL,
    prs_persona_id INTEGER NOT NULL,
    CONSTRAINT eje_docente_pkey PRIMARY KEY (id_eje_docente)
);

CREATE TABLE eje_programacion (
    id_eje_programacion INTEGER NOT NULL,
    observacion VARCHAR(255),
    fecha_programacion TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    estado_programacion VARCHAR(35) NOT NULL,
    nota_final INTEGER,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    eje_cronograma_modulo_id INTEGER,
    cod_ins_matricula_id INTEGER NOT NULL,
    CONSTRAINT eje_programacion_pkey PRIMARY KEY (id_eje_programacion)
);

CREATE TABLE fin_concepto_pago (
    id_fin_concepto_pago INTEGER NOT NULL,
    nombre_concepto VARCHAR(35) NOT NULL,
    descripcion TEXT,
    estado_concepto_pago VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    CONSTRAINT fin_concepto_pago_pkey PRIMARY KEY (id_fin_concepto_pago)
);

CREATE TABLE fin_detalle_pago (
    id_fin_detalle_pago INTEGER NOT NULL,
    monto_aplicado numeric(8, 2) NOT NULL,
    estado_detalle_pago VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    fin_obligacion_pago_id INTEGER NOT NULL,
    fin_transaccion_id INTEGER NOT NULL,
    CONSTRAINT fin_detalle_pago_pkey PRIMARY KEY (id_fin_detalle_pago)
);

CREATE TABLE fin_obligacion_pago (
    id_fin_obligacion_pago INTEGER NOT NULL,
    monto_sin_descuento numeric(10, 2) NOT NULL,
    monto_con_descuento numeric(10, 2) NOT NULL,
    observacion VARCHAR(500),
    estado_obligacion_pago VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    cod_ins_matricula_id INTEGER NOT NULL,
    aca_parametro_id INTEGER,
    fin_concepto_pago_id INTEGER NOT NULL,
    CONSTRAINT fin_obligacion_pago_pkey PRIMARY KEY (id_fin_obligacion_pago)
);

CREATE TABLE fin_transaccion (
    id_fin_transaccion INTEGER NOT NULL,
    cod_comprobante VARCHAR(35) NOT NULL,
    total_pago numeric(10, 2) NOT NULL,
    fecha_pago date NOT NULL,
    tipo_comprobante VARCHAR(35) NOT NULL,
    observacion VARCHAR(500),
    estado_transaccion VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    CONSTRAINT fin_transaccion_pkey PRIMARY KEY (id_fin_transaccion)
);

CREATE TABLE ins_grupo (
    id_ins_grupo INTEGER NOT NULL,
    nombre_grupo VARCHAR(100) NOT NULL,
    fecha_inicio_inscripcion date NOT NULL,
    fecha_fin_inscripcion date,
    estado_grupo VARCHAR(35) NOT NULL,
    gestion_inicio INTEGER NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    aca_programa_aprobado_id INTEGER NOT NULL,
    CONSTRAINT ins_grupo_pkey PRIMARY KEY (id_ins_grupo)
);

CREATE TABLE ins_matricula (
    cod_ins_matricula INTEGER NOT NULL,
    estado_matricula VARCHAR(35) NOT NULL,
    tipo_matricula VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    ins_grupo_id INTEGER NOT NULL,
    seg_usuario_id INTEGER NOT NULL,
    prs_persona_id INTEGER NOT NULL,
    CONSTRAINT ins_matricula_pkey PRIMARY KEY (cod_ins_matricula)
);

CREATE TABLE ins_preinscripcion (
    id_ins_preinscripcion INTEGER NOT NULL,
    estado_preinscripcion VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    prs_persona_id INTEGER NOT NULL,
    aca_programa_aprobado_id INTEGER NOT NULL,
    CONSTRAINT ins_preinscripcion_pkey PRIMARY KEY (id_ins_preinscripcion)
);

CREATE TABLE prs_persona (
    id_prs_persona INTEGER NOT NULL,
    nombre VARCHAR(35) NOT NULL,
    ap_paterno VARCHAR(55) NOT NULL,
    ap_materno VARCHAR(55),
    ci VARCHAR(20) NOT NULL,
    nro_celular VARCHAR(20) NOT NULL,
    correo VARCHAR(55),
    fecha_nacimiento date NOT NULL,
    estado_persona VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    CONSTRAINT prs_persona_pkey PRIMARY KEY (id_prs_persona)
);

CREATE TABLE seg_designa (
    estado_designa VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    seg_tarea_id INTEGER NOT NULL,
    seg_usuario_id INTEGER NOT NULL,
    CONSTRAINT seg_designa_pkey PRIMARY KEY (estado_designa)
);

CREATE TABLE seg_ocupa (
    estado_ocupa VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    seg_rol_id INTEGER NOT NULL,
    seg_usuario_id INTEGER NOT NULL,
    CONSTRAINT seg_ocupa_pkey PRIMARY KEY (estado_ocupa)
);

CREATE TABLE seg_rol (
    id_seg_rol INTEGER NOT NULL,
    nombre_rol VARCHAR(50) NOT NULL,
    descripcion TEXT,
    estado_rol VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    CONSTRAINT seg_rol_pkey PRIMARY KEY (id_seg_rol)
);

CREATE TABLE seg_tarea (
    id_seg_tarea INTEGER NOT NULL,
    nombre_tarea VARCHAR(50) NOT NULL,
    descripcion TEXT,
    estado_tarea VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    seg_rol_id INTEGER NOT NULL,
    CONSTRAINT seg_tarea_pkey PRIMARY KEY (id_seg_tarea)
);

CREATE TABLE seg_usuario (
    id_seg_usuario INTEGER NOT NULL,
    nombre_usuario VARCHAR(50),
    contrasena_hash VARCHAR(255),
    estado_usuario VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    CONSTRAINT seg_usuario_pkey PRIMARY KEY (id_seg_usuario)
);

CREATE TABLE tgr_monografia (
    id_tgr_monografia INTEGER NOT NULL,
    titulo_monografia VARCHAR(255) NOT NULL,
    estado_monografia VARCHAR(35) NOT NULL,
    nota_final INTEGER NOT NULL,
    fecha_defensa date,
    archivo_uri TEXT,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    cod_ins_matricula_id INTEGER NOT NULL,
    CONSTRAINT tgr_monografia_pkey PRIMARY KEY (id_tgr_monografia)
);

CREATE TABLE tgr_observacion_monografia (
    id_tgr_observacion_monografia INTEGER NOT NULL,
    descripcion TEXT NOT NULL,
    estado_observacion_monografia VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    tgr_revision_monografia_id INTEGER NOT NULL,
    CONSTRAINT tgr_observacion_monografia_pkey PRIMARY KEY (id_tgr_observacion_monografia)
);

CREATE TABLE tgr_revision_monografia (
    id_tgr_revision_monografia INTEGER NOT NULL,
    fecha_hora_designacion TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    es_aprobador_final BOOLEAN,
    fecha_hora_revision TIMESTAMP WITHOUT TIME ZONE,
    estado_revision_monografia VARCHAR(35) NOT NULL,
    fecha_reg TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    fecha_mod TIMESTAMP WITHOUT TIME ZONE,
    user_reg INTEGER NOT NULL,
    user_mod INTEGER,
    tgr_monografia_id INTEGER NOT NULL,
    eje_administrativo_id INTEGER,
    eje_docente_id INTEGER,
    CONSTRAINT tgr_revision_monografia_pkey PRIMARY KEY (id_tgr_revision_monografia)
);

ALTER TABLE aca_parametro_programa ADD CONSTRAINT fk_aca_parametro_programa_aca_programa_aprobado_id FOREIGN KEY (aca_programa_aprobado_id) REFERENCES aca_programa_aprobado (id_aca_programa_aprobado) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE aca_plan_modulo_detalle ADD CONSTRAINT fk_aca_plan_modulo_detalle_aca_modulo_id FOREIGN KEY (aca_modulo_id) REFERENCES aca_modulo (id_aca_modulo) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE aca_plan_modulo_detalle ADD CONSTRAINT fk_aca_plan_modulo_detalle_aca_nivel_id FOREIGN KEY (aca_nivel_id) REFERENCES aca_nivel (id_aca_nivel) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE aca_plan_modulo_detalle ADD CONSTRAINT fk_aca_plan_modulo_detalle_aca_plan_estudio_id FOREIGN KEY (aca_plan_estudio_id) REFERENCES aca_plan_estudio (id_aca_plan_estudio) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE aca_programa ADD CONSTRAINT fk_aca_programa_aca_area_id FOREIGN KEY (aca_area_id) REFERENCES aca_area (id_aca_area) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE aca_programa_aprobado ADD CONSTRAINT fk_aca_programa_aprobado_aca_plan_estudio_id FOREIGN KEY (aca_plan_estudio_id) REFERENCES aca_plan_estudio (id_aca_plan_estudio) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE aca_programa_aprobado ADD CONSTRAINT fk_aca_programa_aprobado_aca_programa_id FOREIGN KEY (aca_programa_id) REFERENCES aca_programa (id_aca_programa) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE aca_programa_aprobado ADD CONSTRAINT fk_aca_programa_aprobado_aca_modalidad_id FOREIGN KEY (aca_modalidad_id) REFERENCES aca_modalidad (id_aca_modalidad) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE aca_programa_aprobado ADD CONSTRAINT fk_aca_programa_aprobado_aca_version_id FOREIGN KEY (aca_version_id) REFERENCES aca_version (id_aca_version) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE cer_certificado ADD CONSTRAINT fk_cer_certificado_eje_administrativo_id FOREIGN KEY (eje_administrativo_id) REFERENCES eje_administrativo (id_eje_administrativo) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE cer_certificado ADD CONSTRAINT fk_cer_certificado_cod_ins_matricula_id FOREIGN KEY (cod_ins_matricula_id) REFERENCES ins_matricula (cod_ins_matricula) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE cer_impresion ADD CONSTRAINT fk_cer_impresion_cer_certificado_id FOREIGN KEY (cer_certificado_id) REFERENCES cer_certificado (id_cer_certificado) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE cer_impresion ADD CONSTRAINT fk_cer_impresion_fin_obligacion_pago_id FOREIGN KEY (fin_obligacion_pago_id) REFERENCES fin_obligacion_pago (id_fin_obligacion_pago) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE cer_titulacion ADD CONSTRAINT fk_cer_titulacion_cod_ins_matricula_id FOREIGN KEY (cod_ins_matricula_id) REFERENCES ins_matricula (cod_ins_matricula) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE eje_administrativo ADD CONSTRAINT fk_eje_administrativo_seg_usuario_id FOREIGN KEY (seg_usuario_id) REFERENCES seg_usuario (id_seg_usuario) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE eje_administrativo ADD CONSTRAINT fk_eje_administrativo_prs_persona_id FOREIGN KEY (prs_persona_id) REFERENCES prs_persona (id_prs_persona) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE eje_calificacion ADD CONSTRAINT fk_eje_calificacion_eje_criterio_eval_id FOREIGN KEY (eje_criterio_eval_id) REFERENCES eje_criterio_eval (id_eje_criterio_eval) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE eje_calificacion ADD CONSTRAINT fk_eje_calificacion_eje_programacion_id FOREIGN KEY (eje_programacion_id) REFERENCES eje_programacion (id_eje_programacion) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE eje_criterio_eval ADD CONSTRAINT fk_eje_criterio_eval_eje_cronograma_modulo_id FOREIGN KEY (eje_cronograma_modulo_id) REFERENCES eje_cronograma_modulo (id_eje_cronograma_modulo) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE eje_cronograma_modulo ADD CONSTRAINT fk_eje_cronograma_modulo_aca_plan_modulo_detalle_id FOREIGN KEY (aca_plan_modulo_detalle_id) REFERENCES aca_plan_modulo_detalle (id_aca_plan_modulo_detalle) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE eje_cronograma_modulo ADD CONSTRAINT fk_eje_cronograma_modulo_eje_docente_id FOREIGN KEY (eje_docente_id) REFERENCES eje_docente (id_eje_docente) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE eje_cronograma_modulo ADD CONSTRAINT fk_eje_cronograma_modulo_ins_grupo_id FOREIGN KEY (ins_grupo_id) REFERENCES ins_grupo (id_ins_grupo) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE eje_docente ADD CONSTRAINT fk_eje_docente_seg_usuario_id FOREIGN KEY (seg_usuario_id) REFERENCES seg_usuario (id_seg_usuario) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE eje_docente ADD CONSTRAINT fk_eje_docente_prs_persona_id FOREIGN KEY (prs_persona_id) REFERENCES prs_persona (id_prs_persona) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE eje_programacion ADD CONSTRAINT fk_eje_programacion_eje_cronograma_modulo_id FOREIGN KEY (eje_cronograma_modulo_id) REFERENCES eje_cronograma_modulo (id_eje_cronograma_modulo) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE eje_programacion ADD CONSTRAINT fk_eje_programacion_cod_ins_matricula_id FOREIGN KEY (cod_ins_matricula_id) REFERENCES ins_matricula (cod_ins_matricula) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE fin_detalle_pago ADD CONSTRAINT fk_fin_detalle_pago_fin_obligacion_pago_id FOREIGN KEY (fin_obligacion_pago_id) REFERENCES fin_obligacion_pago (id_fin_obligacion_pago) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE fin_detalle_pago ADD CONSTRAINT fk_fin_detalle_pago_fin_transaccion_id FOREIGN KEY (fin_transaccion_id) REFERENCES fin_transaccion (id_fin_transaccion) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE fin_obligacion_pago ADD CONSTRAINT fk_fin_obligacion_pago_cod_ins_matricula_id FOREIGN KEY (cod_ins_matricula_id) REFERENCES ins_matricula (cod_ins_matricula) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE fin_obligacion_pago ADD CONSTRAINT fk_fin_obligacion_pago_aca_parametro_id FOREIGN KEY (aca_parametro_id) REFERENCES aca_parametro_programa (id_aca_parametro) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE fin_obligacion_pago ADD CONSTRAINT fk_fin_obligacion_pago_fin_concepto_pago_id FOREIGN KEY (fin_concepto_pago_id) REFERENCES fin_concepto_pago (id_fin_concepto_pago) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE ins_grupo ADD CONSTRAINT fk_ins_grupo_aca_programa_aprobado_id FOREIGN KEY (aca_programa_aprobado_id) REFERENCES aca_programa_aprobado (id_aca_programa_aprobado) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE ins_matricula ADD CONSTRAINT fk_ins_matricula_ins_grupo_id FOREIGN KEY (ins_grupo_id) REFERENCES ins_grupo (id_ins_grupo) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE ins_matricula ADD CONSTRAINT fk_ins_matricula_seg_usuario_id FOREIGN KEY (seg_usuario_id) REFERENCES seg_usuario (id_seg_usuario) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE ins_matricula ADD CONSTRAINT fk_ins_matricula_prs_persona_id FOREIGN KEY (prs_persona_id) REFERENCES prs_persona (id_prs_persona) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE ins_preinscripcion ADD CONSTRAINT fk_ins_preinscripcion_prs_persona_id FOREIGN KEY (prs_persona_id) REFERENCES prs_persona (id_prs_persona) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE ins_preinscripcion ADD CONSTRAINT fk_ins_preinscripcion_aca_programa_aprobado_id FOREIGN KEY (aca_programa_aprobado_id) REFERENCES aca_programa_aprobado (id_aca_programa_aprobado) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE seg_designa ADD CONSTRAINT fk_seg_designa_seg_tarea_id FOREIGN KEY (seg_tarea_id) REFERENCES seg_tarea (id_seg_tarea) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE seg_designa ADD CONSTRAINT fk_seg_designa_seg_usuario_id FOREIGN KEY (seg_usuario_id) REFERENCES seg_usuario (id_seg_usuario) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE seg_ocupa ADD CONSTRAINT fk_seg_ocupa_seg_rol_id FOREIGN KEY (seg_rol_id) REFERENCES seg_rol (id_seg_rol) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE seg_ocupa ADD CONSTRAINT fk_seg_ocupa_seg_usuario_id FOREIGN KEY (seg_usuario_id) REFERENCES seg_usuario (id_seg_usuario) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE seg_tarea ADD CONSTRAINT fk_seg_tarea_seg_rol_id FOREIGN KEY (seg_rol_id) REFERENCES seg_rol (id_seg_rol) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE tgr_monografia ADD CONSTRAINT fk_tgr_monografia_cod_ins_matricula_id FOREIGN KEY (cod_ins_matricula_id) REFERENCES ins_matricula (cod_ins_matricula) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE tgr_observacion_monografia ADD CONSTRAINT fk_tgr_observacion_monografia_tgr_revision_monografia_id FOREIGN KEY (tgr_revision_monografia_id) REFERENCES tgr_revision_monografia (id_tgr_revision_monografia) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE tgr_revision_monografia ADD CONSTRAINT fk_tgr_revision_monografia_tgr_monografia_id FOREIGN KEY (tgr_monografia_id) REFERENCES tgr_monografia (id_tgr_monografia) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE tgr_revision_monografia ADD CONSTRAINT fk_tgr_revision_monografia_eje_administrativo_id FOREIGN KEY (eje_administrativo_id) REFERENCES eje_administrativo (id_eje_administrativo) ON UPDATE NO ACTION ON DELETE NO ACTION;

ALTER TABLE tgr_revision_monografia ADD CONSTRAINT fk_tgr_revision_monografia_eje_docente_id FOREIGN KEY (eje_docente_id) REFERENCES eje_docente (id_eje_docente) ON UPDATE NO ACTION ON DELETE NO ACTION;

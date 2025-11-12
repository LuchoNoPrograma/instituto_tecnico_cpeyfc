-- ============================================
-- TABLAS DEL SCHEMA PUBLIC
-- ============================================

CREATE TABLE aca_area (
  id_aca_area integer NOT NULL DEFAULT nextval('aca_area_id_aca_area_seq'::regclass),
  nombre_area character varying(100) NOT NULL,
  estado_area character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_certificacion_programa (
  id_aca_certificacion_programa integer NOT NULL DEFAULT nextval('aca_certificacion_programa_id_aca_certificacion_programa_seq'::regclass),
  id_aca_programa_aprobado integer NOT NULL,
  id_aca_titulo_certificado integer NOT NULL,
  nombre_certificacion character varying(200) NOT NULL,
  tipo_certificacion_programa character varying(35) NOT NULL DEFAULT 'TERMINAL'::character varying,
  periodos_requeridos integer NOT NULL,
  creditos_requeridos integer,
  horas_academicas_requeridas integer,
  orden_secuencial integer NOT NULL,
  estado_certificacion_programa character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_certificado_emitido (
  id_aca_certificado_emitido integer NOT NULL DEFAULT nextval('aca_certificado_emitido_id_aca_certificado_emitido_seq'::regclass),
  id_aca_certificacion_programa integer NOT NULL,
  id_prs_persona integer NOT NULL,
  id_aca_modalidad_graduacion integer,
  numero_certificado character varying(50) NOT NULL,
  fecha_emision date NOT NULL,
  fecha_vencimiento date,
  nota_final numeric(5,2),
  promedio_general numeric(5,2),
  archivo_pdf_uri text,
  hash_verificacion character varying(100),
  observaciones text,
  estado_certificado character varying(35) NOT NULL DEFAULT 'EMITIDO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_colegio (
  id_aca_colegio integer NOT NULL DEFAULT nextval('aca_colegio_id_aca_colegio_seq'::regclass),
  nombre_colegio character varying(200) NOT NULL,
  direccion text,
  director_nombre character varying(150),
  director_email character varying(100),
  telefono character varying(20),
  tipo_colegio character varying(35) NOT NULL DEFAULT 'PUBLICO'::character varying,
  nivel_educativo character varying(100),
  estado_colegio character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_gestion (
  id_aca_gestion integer NOT NULL DEFAULT nextval('aca_gestion_id_aca_gestion_seq'::regclass),
  anio integer NOT NULL,
  fecha_inicio date NOT NULL,
  fecha_fin date NOT NULL,
  estado_gestion character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_modalidad (
  id_aca_modalidad integer NOT NULL DEFAULT nextval('aca_modalidad_id_aca_modalidad_seq'::regclass),
  nombre_modalidad character varying(50) NOT NULL,
  estado_modalidad character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_modalidad_graduacion (
  id_aca_modalidad_graduacion integer NOT NULL DEFAULT nextval('aca_modalidad_graduacion_id_aca_modalidad_graduacion_seq'::regclass),
  nombre_modalidad character varying(150) NOT NULL,
  descripcion text,
  requiere_tesis boolean DEFAULT false,
  requiere_examen boolean DEFAULT false,
  requiere_proyecto boolean DEFAULT false,
  orden integer NOT NULL,
  estado_modalidad_graduacion character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_modulo (
  id_aca_modulo integer NOT NULL DEFAULT nextval('aca_modulo_id_aca_modulo_seq'::regclass),
  nombre_modulo character varying(100) NOT NULL,
  estado_modulo character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_nivel (
  id_aca_nivel integer NOT NULL DEFAULT nextval('aca_nivel_id_aca_nivel_seq'::regclass),
  nombre_nivel character varying(100) NOT NULL,
  estado_nivel character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_parametro_programa (
  id_aca_parametro integer NOT NULL DEFAULT nextval('aca_parametro_programa_id_aca_parametro_seq'::regclass),
  id_aca_programa_aprobado integer NOT NULL,
  nombre_param character varying(55) NOT NULL,
  valor text NOT NULL,
  tipo_dato_param character varying(35) NOT NULL,
  fecha_inicio_vigencia date,
  fecha_fin_vigencia date,
  orden integer NOT NULL,
  estado_parametro_programa character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_periodo (
  id_aca_periodo integer NOT NULL DEFAULT nextval('aca_periodo_id_aca_periodo_seq'::regclass),
  id_aca_gestion integer NOT NULL,
  codigo_periodo character varying(20) NOT NULL,
  nombre_periodo character varying(100) NOT NULL,
  tipo_periodo character varying(35) NOT NULL DEFAULT 'SEMESTRE'::character varying,
  numero_periodo integer NOT NULL,
  fecha_inicio date NOT NULL,
  fecha_fin date NOT NULL,
  estado_periodo character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_plan_estudio (
  id_aca_plan_estudio integer NOT NULL DEFAULT nextval('aca_plan_estudio_id_aca_plan_estudio_seq'::regclass),
  anho integer NOT NULL,
  vigente boolean NOT NULL,
  estado_plan_estudio character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_plan_modulo_detalle (
  id_aca_plan_modulo_detalle integer NOT NULL DEFAULT nextval('aca_plan_modulo_detalle_id_aca_plan_modulo_detalle_seq'::regclass),
  id_aca_nivel integer NOT NULL,
  id_aca_plan_estudio integer NOT NULL,
  id_aca_modulo integer NOT NULL,
  carga_horaria integer NOT NULL,
  creditos numeric(6,2) NOT NULL,
  orden integer NOT NULL,
  sigla character(10) NOT NULL,
  competencia text,
  estado_plan_modulo_detalle character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_programa (
  id_aca_programa integer NOT NULL DEFAULT nextval('aca_programa_id_aca_programa_seq'::regclass),
  id_aca_area integer NOT NULL,
  nombre_programa character varying(100) NOT NULL,
  sigla character varying(15),
  estado_programa character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer,
  imagen_url character varying(500),
  tipo_programa character varying(35) NOT NULL DEFAULT 'REGULAR'::character varying
);


CREATE TABLE aca_programa_aprobado (
  id_aca_programa_aprobado integer NOT NULL DEFAULT nextval('aca_programa_aprobado_id_aca_programa_aprobado_seq'::regclass),
  id_aca_modalidad integer NOT NULL,
  id_aca_programa integer NOT NULL,
  id_aca_plan_estudio integer,
  id_aca_version integer NOT NULL,
  fecha_inicio_vigencia date,
  fecha_fin_vigencia date,
  estado_programa_aprobado character varying(35) NOT NULL,
  gestion integer NOT NULL,
  cod_certificado_ceub character varying(55),
  cod_sigla_version character varying(15),
  precio_matricula numeric(8,2) NOT NULL,
  precio_colegiatura numeric(8,2) NOT NULL,
  precio_titulacion numeric(8,2),
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer,
  imagen_programa_url character varying(500),
  sistema_programa character varying(35) NOT NULL DEFAULT 'REGULAR'::character varying
);


CREATE TABLE aca_programa_modalidad_graduacion (
  id_aca_programa_modalidad_graduacion integer NOT NULL DEFAULT nextval('aca_programa_modalidad_gradua_id_aca_programa_modalidad_gra_seq'::regclass),
  id_aca_programa_aprobado integer NOT NULL,
  id_aca_modalidad_graduacion integer NOT NULL,
  es_modalidad_por_defecto boolean DEFAULT false,
  orden_prioridad integer,
  estado_programa_modalidad character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_tipo_estudiante (
  id_aca_tipo_estudiante integer NOT NULL DEFAULT nextval('aca_tipo_estudiante_id_aca_tipo_estudiante_seq'::regclass),
  nombre_tipo character varying(100) NOT NULL,
  descripcion text,
  es_nacional boolean DEFAULT true,
  requiere_documentacion_adicional boolean DEFAULT false,
  estado_tipo_estudiante character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_titulo_certificado (
  id_aca_titulo_certificado integer NOT NULL DEFAULT nextval('aca_titulo_certificado_id_aca_titulo_certificado_seq'::regclass),
  nombre_titulo character varying(200) NOT NULL,
  tipo_certificacion character varying(50) NOT NULL,
  nivel_academico character varying(50) NOT NULL,
  descripcion text,
  requiere_creditos_minimos integer,
  requiere_horas_minimas integer,
  estado_titulo character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_unidad (
  id_aca_unidad integer NOT NULL DEFAULT nextval('aca_unidad_id_aca_unidad_seq'::regclass),
  nombre_unidad character varying(100) NOT NULL,
  descripcion text,
  estado_unidad character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE aca_version (
  id_aca_version integer NOT NULL DEFAULT nextval('aca_version_id_aca_version_seq'::regclass),
  cod_version character varying(10) NOT NULL,
  estado_version character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE cer_certificado (
  id_cer_certificado integer NOT NULL DEFAULT nextval('cer_certificado_id_cer_certificado_seq'::regclass),
  id_eje_administrativo integer NOT NULL,
  cod_ins_matricula integer NOT NULL,
  tipo_certificado character varying(35) NOT NULL,
  estado_certificado character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE cer_impresion (
  id_cer_impresion integer NOT NULL DEFAULT nextval('cer_impresion_id_cer_impresion_seq'::regclass),
  id_cer_certificado integer NOT NULL,
  id_fin_obligacion_pago integer NOT NULL,
  num_impresion integer NOT NULL,
  hash_impresion character varying(255) NOT NULL,
  estado_impresion character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer,
  fecha_impresion date
);


CREATE TABLE cer_titulacion (
  id_cer_titulacion integer NOT NULL DEFAULT nextval('cer_titulacion_id_cer_titulacion_seq'::regclass),
  cod_ins_matricula integer NOT NULL,
  cod_titulo character varying(25) NOT NULL,
  uri_titulo character varying(1) NOT NULL,
  estado_titulacion character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE eje_administrativo (
  id_eje_administrativo integer NOT NULL DEFAULT nextval('eje_administrativo_id_eje_administrativo_seq'::regclass),
  id_prs_persona integer NOT NULL,
  id_seg_usuario integer NOT NULL,
  estado_administrativo character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE eje_area_evaluacion (
  id_eje_area_evaluacion integer NOT NULL DEFAULT nextval('eje_area_evaluacion_id_eje_area_evaluacion_seq'::regclass),
  id_aca_programa_aprobado integer,
  nombre_area character varying(100) NOT NULL,
  descripcion text,
  orden integer NOT NULL,
  estado_area_evaluacion character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE eje_calificacion (
  id_eje_calificacion integer NOT NULL DEFAULT nextval('eje_calificacion_id_eje_calificacion_seq'::regclass),
  id_eje_criterio_eval integer NOT NULL,
  id_eje_programacion integer NOT NULL,
  nota numeric(5,2),
  estado_calificacion character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer,
  nota_ponderada numeric(5,2),
  comentario_general text,
  total_faltas integer DEFAULT 0,
  debe_repetir boolean DEFAULT false,
  pasa_a_modulo integer
);


CREATE TABLE eje_criterio_eval (
  id_eje_criterio_eval integer NOT NULL DEFAULT nextval('eje_criterio_eval_id_eje_criterio_eval_seq'::regclass),
  id_eje_docente integer,
  nombre_crit character varying(25) NOT NULL,
  descripcion character varying(155),
  ponderacion integer NOT NULL,
  orden integer NOT NULL,
  estado_criterio_eval character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer,
  id_eje_cronograma_modulo integer NOT NULL
);


CREATE TABLE eje_cronograma_modulo (
  id_eje_cronograma_modulo integer NOT NULL DEFAULT nextval('eje_cronograma_modulo_id_eje_cronograma_modulo_seq'::regclass),
  id_ins_grupo integer NOT NULL,
  id_aca_plan_modulo_detalle integer NOT NULL,
  id_eje_docente integer,
  fecha_inicio date,
  fecha_fin date,
  estado_cronograma_modulo character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer,
  id_aca_periodo integer,
  fecha_inicio_inscripciones date,
  fecha_fin_inscripciones date,
  permite_inscripciones boolean DEFAULT false
);


CREATE TABLE eje_detalle_calificacion (
  id_eje_detalle_calificacion integer NOT NULL DEFAULT nextval('eje_detalle_calificacion_id_eje_detalle_calificacion_seq'::regclass),
  id_eje_calificacion integer NOT NULL,
  id_eje_area_evaluacion integer NOT NULL,
  nota_progress_test numeric(5,2),
  nota_class_performance numeric(5,2),
  comentario_docente text,
  nota_final_area numeric(5,2) NOT NULL,
  estado_detalle_calificacion character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE eje_docente (
  id_eje_docente integer NOT NULL DEFAULT nextval('eje_docente_id_eje_docente_seq'::regclass),
  id_prs_persona integer NOT NULL,
  id_seg_usuario integer NOT NULL,
  nro_resolucion integer,
  estado_docente character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer,
  numero_contrato character varying(50),
  fecha_inicio_contrato date,
  fecha_fin_contrato date,
  nivel_academico character varying(100),
  especialidad text,
  hoja_vida_uri text
);


CREATE TABLE eje_log_calificacion (
  id_eje_log_calificacion integer NOT NULL DEFAULT nextval('eje_log_calificacion_id_eje_log_calificacion_seq'::regclass),
  id_eje_calificacion integer NOT NULL,
  accion character varying(20) NOT NULL,
  nota_anterior numeric(5,2),
  nota_nueva numeric(5,2),
  usuario_cambio integer,
  fecha_cambio timestamp without time zone NOT NULL DEFAULT now(),
  observacion text
);


CREATE TABLE eje_programacion (
  id_eje_programacion integer NOT NULL DEFAULT nextval('eje_programacion_id_eje_programacion_seq'::regclass),
  cod_ins_matricula integer NOT NULL,
  id_eje_cronograma_modulo integer,
  observacion character varying(255),
  fecha_programacion date NOT NULL,
  estado_programacion character varying(35) NOT NULL,
  nota_final integer,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE fin_arancel (
  id_fin_arancel integer NOT NULL DEFAULT nextval('fin_arancel_id_fin_arancel_seq'::regclass),
  id_aca_programa_aprobado integer NOT NULL,
  id_aca_periodo integer,
  id_aca_tipo_estudiante integer NOT NULL,
  nombre_arancel character varying(200) NOT NULL,
  nro_resolucion character varying(50),
  fecha_aprobacion date,
  fecha_inicio_vigencia date NOT NULL,
  fecha_fin_vigencia date,
  estado_arancel character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE fin_colegio_convenio (
  id_fin_colegio_convenio integer NOT NULL DEFAULT nextval('fin_colegio_convenio_id_fin_colegio_convenio_seq'::regclass),
  id_aca_colegio integer NOT NULL,
  id_fin_convenio integer NOT NULL,
  fecha_inicio date NOT NULL,
  fecha_fin date,
  estado_colegio_convenio character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE fin_concepto_arancel (
  id_fin_concepto_arancel integer NOT NULL DEFAULT nextval('fin_concepto_arancel_id_fin_concepto_arancel_seq'::regclass),
  nombre_concepto character varying(100) NOT NULL,
  descripcion text,
  es_recurrente boolean DEFAULT false,
  es_unico boolean DEFAULT false,
  tipo_concepto character varying(35) NOT NULL,
  estado_concepto character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE fin_concepto_pago (
  id_fin_concepto_pago integer NOT NULL DEFAULT nextval('fin_concepto_pago_id_fin_concepto_pago_seq'::regclass),
  nombre_concepto character varying(35) NOT NULL,
  descripcion text,
  estado_concepto_pago character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE fin_convenio (
  id_fin_convenio integer NOT NULL DEFAULT nextval('fin_convenio_id_fin_convenio_seq'::regclass),
  nombre_convenio character varying(150) NOT NULL,
  descripcion text,
  tipo_descuento character varying(35) NOT NULL,
  monto_descuento numeric(10,2),
  porcentaje_descuento numeric(5,2),
  fecha_inicio_vigencia date NOT NULL,
  fecha_fin_vigencia date,
  estado_convenio character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE fin_descuento_arancel (
  id_fin_descuento_arancel integer NOT NULL DEFAULT nextval('fin_descuento_arancel_id_fin_descuento_arancel_seq'::regclass),
  id_fin_arancel integer NOT NULL,
  nombre_descuento character varying(150) NOT NULL,
  descripcion text,
  tipo_descuento character varying(35) NOT NULL,
  porcentaje_descuento numeric(5,2),
  monto_descuento numeric(10,2),
  aplica_desde_periodo integer,
  requiere_validacion boolean DEFAULT false,
  estado_descuento character varying(35) NOT NULL DEFAULT 'ACTIVO'::character varying,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE fin_detalle_arancel (
  id_fin_detalle_arancel integer NOT NULL DEFAULT nextval('fin_detalle_arancel_id_fin_detalle_arancel_seq'::regclass),
  id_fin_arancel integer NOT NULL,
  id_fin_concepto_arancel integer NOT NULL,
  monto_concepto numeric(10,2) NOT NULL,
  orden_aplicacion integer NOT NULL,
  fecha_reg timestamp without time zone NOT NULL DEFAULT now(),
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE fin_detalle_pago (
  id_fin_detalle_pago integer NOT NULL DEFAULT nextval('fin_detalle_pago_id_fin_detalle_pago_seq'::regclass),
  id_fin_transaccion integer NOT NULL,
  id_fin_obligacion_pago integer NOT NULL,
  monto_pagado numeric(8,2) NOT NULL,
  estado_detalle_pago character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE fin_obligacion_pago (
  id_fin_obligacion_pago integer NOT NULL DEFAULT nextval('fin_obligacion_pago_id_fin_obligacion_pago_seq'::regclass),
  cod_ins_matricula integer NOT NULL,
  id_fin_concepto_pago integer NOT NULL,
  id_aca_parametro integer,
  deuda_sin_descuento numeric(10,2) NOT NULL,
  deuda_con_descuento numeric(10,2) NOT NULL,
  observacion character varying(500),
  estado_obligacion_pago character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer,
  saldo_pendiente numeric(10,2) NOT NULL DEFAULT 0,
  metodo_pago character varying(50),
  monto_base numeric(10,2),
  monto_descuento_arancel numeric(10,2) DEFAULT 0,
  monto_descuento_convenio numeric(10,2) DEFAULT 0,
  monto_final numeric(10,2),
  comprobante_pago_uri text,
  observaciones_pago text
);


CREATE TABLE fin_transaccion (
  id_fin_transaccion integer NOT NULL DEFAULT nextval('fin_transaccion_id_fin_transaccion_seq'::regclass),
  cod_comprobante character varying(35) NOT NULL,
  total_pago numeric(10,2) NOT NULL,
  fecha_pago date NOT NULL,
  tipo_comprobante character varying(35) NOT NULL,
  observacion character varying(500),
  estado_transaccion character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE ins_grupo (
  id_ins_grupo integer NOT NULL DEFAULT nextval('ins_grupo_id_ins_grupo_seq'::regclass),
  id_aca_programa_aprobado integer NOT NULL,
  nombre_grupo character varying(100) NOT NULL,
  fecha_inicio_inscripcion date NOT NULL,
  fecha_fin_inscripcion date,
  estado_grupo character varying(35) NOT NULL,
  gestion_inicio integer NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer,
  codigo_paralelo character varying(10),
  horario character varying(50),
  aula character varying(20),
  fecha_inicio date,
  fecha_fin date,
  cupo_maximo integer DEFAULT 30
);


CREATE TABLE ins_matricula (
  cod_ins_matricula integer NOT NULL DEFAULT nextval('ins_matricula_cod_ins_matricula_seq'::regclass),
  id_ins_grupo integer,
  id_prs_persona integer NOT NULL,
  id_seg_usuario integer NOT NULL,
  estado_matricula character varying(35) NOT NULL,
  tipo_matricula character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer,
  id_aca_tipo_estudiante integer,
  id_fin_arancel_aplicado integer,
  id_fin_convenio_aplicado integer,
  numero_periodo_cursando integer,
  es_estudiante_antiguo boolean DEFAULT false
);


CREATE TABLE ins_preinscripcion (
  id_ins_preinscripcion integer NOT NULL DEFAULT nextval('ins_preinscripcion_id_ins_preinscripcion_seq'::regclass),
  id_aca_programa_aprobado integer NOT NULL,
  id_prs_persona integer NOT NULL,
  estado_preinscripcion character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE prs_persona (
  id_prs_persona integer NOT NULL DEFAULT nextval('prs_persona_id_prs_persona_seq'::regclass),
  nombre character varying(35) NOT NULL,
  ap_paterno character varying(55) NOT NULL,
  ap_materno character varying(55),
  ci character varying(20) NOT NULL,
  nro_celular character varying(20) NOT NULL,
  correo character varying(55),
  fecha_nacimiento date NOT NULL,
  estado_persona character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer,
  id_aca_colegio_procedencia integer,
  id_prs_persona_apoderado integer,
  tipo_relacion_apoderado character varying(50),
  telefono_apoderado character varying(20),
  email_apoderado character varying(100)
);


CREATE TABLE pub_noticia (
  id_pub_noticia integer NOT NULL DEFAULT nextval('pub_noticia_id_pub_noticia_seq'::regclass),
  id_aca_unidad integer NOT NULL,
  titulo character varying(255) NOT NULL,
  contenido text NOT NULL,
  imagen_uri character varying(500),
  enlace_externo character varying(500),
  fecha_noticia date NOT NULL,
  es_destacada boolean DEFAULT false,
  orden_prioridad integer DEFAULT 0,
  estado_noticia character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer,
  resumen text
);


CREATE TABLE seg_designa (
  id_seg_tarea integer NOT NULL,
  id_seg_usuario integer NOT NULL,
  estado_designa character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE seg_ocupa (
  id_seg_rol integer NOT NULL,
  id_seg_usuario integer NOT NULL,
  estado_ocupa character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE seg_rol (
  id_seg_rol integer NOT NULL DEFAULT nextval('seg_rol_id_seg_rol_seq'::regclass),
  nombre_rol character varying(50) NOT NULL,
  descripcion text,
  estado_rol character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE seg_tarea (
  id_seg_tarea integer NOT NULL DEFAULT nextval('seg_tarea_id_seg_tarea_seq'::regclass),
  id_seg_rol integer NOT NULL,
  nombre_tarea character varying(50) NOT NULL,
  descripcion text,
  estado_tarea character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE seg_usuario (
  id_seg_usuario integer NOT NULL DEFAULT nextval('seg_usuario_id_seg_usuario_seq'::regclass),
  nombre_usuario character varying(50),
  contrasena_hash character varying(255),
  estado_usuario character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE tgr_monografia (
  id_tgr_monografia integer NOT NULL DEFAULT nextval('tgr_monografia_id_tgr_monografia_seq'::regclass),
  cod_ins_matricula integer NOT NULL,
  titulo_monografia character varying(255) NOT NULL,
  estado_monografia character varying(35) NOT NULL,
  nota_final integer NOT NULL,
  fecha_defensa date,
  archivo_uri character varying(1),
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE tgr_observacion_monografia (
  id_tgr_observacion_monografia integer NOT NULL DEFAULT nextval('tgr_observacion_monografia_id_tgr_observacion_monografia_seq'::regclass),
  id_tgr_revision_monografia integer NOT NULL,
  descripcion character varying(1) NOT NULL,
  estado_observacion_monografia character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE tgr_revision_monografia (
  id_tgr_revision_monografia integer NOT NULL DEFAULT nextval('tgr_revision_monografia_id_tgr_revision_monografia_seq'::regclass),
  id_tgr_monografia integer NOT NULL,
  id_eje_administrativo integer,
  id_eje_docente integer,
  fecha_hora_designacion date NOT NULL,
  es_aprobador_final boolean,
  fecha_hora_revision date,
  estado_revision_monografia character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);


CREATE TABLE tgr_tribunal (
  id_tgr_tribunal integer NOT NULL DEFAULT nextval('tgr_tribunal_id_tgr_tribunal_seq'::regclass),
  id_tgr_monografia integer NOT NULL,
  id_prs_persona integer NOT NULL,
  tipo_tribunal character varying(35) NOT NULL,
  estado_tribunal character varying(35) NOT NULL,
  fecha_reg timestamp without time zone NOT NULL,
  fecha_mod timestamp without time zone,
  user_reg integer NOT NULL,
  user_mod integer
);



-- Primary Keys
ALTER TABLE aca_area ADD CONSTRAINT pk_aca_area PRIMARY KEY (id_aca_area);

ALTER TABLE aca_certificacion_programa ADD CONSTRAINT aca_certificacion_programa_pkey PRIMARY KEY (id_aca_certificacion_programa);

ALTER TABLE aca_certificado_emitido ADD CONSTRAINT aca_certificado_emitido_pkey PRIMARY KEY (id_aca_certificado_emitido);

ALTER TABLE aca_colegio ADD CONSTRAINT aca_colegio_pkey PRIMARY KEY (id_aca_colegio);

ALTER TABLE aca_gestion ADD CONSTRAINT aca_gestion_pkey PRIMARY KEY (id_aca_gestion);

ALTER TABLE aca_modalidad ADD CONSTRAINT pk_aca_modalidad PRIMARY KEY (id_aca_modalidad);

ALTER TABLE aca_modalidad_graduacion ADD CONSTRAINT aca_modalidad_graduacion_pkey PRIMARY KEY (id_aca_modalidad_graduacion);

ALTER TABLE aca_modulo ADD CONSTRAINT pk_aca_modulo PRIMARY KEY (id_aca_modulo);

ALTER TABLE aca_nivel ADD CONSTRAINT pk_aca_nivel PRIMARY KEY (id_aca_nivel);

ALTER TABLE aca_parametro_programa ADD CONSTRAINT pk_aca_parametro_programa PRIMARY KEY (id_aca_parametro);

ALTER TABLE aca_periodo ADD CONSTRAINT aca_periodo_pkey PRIMARY KEY (id_aca_periodo);

ALTER TABLE aca_plan_estudio ADD CONSTRAINT pk_aca_plan_estudio PRIMARY KEY (id_aca_plan_estudio);

ALTER TABLE aca_plan_modulo_detalle ADD CONSTRAINT pk_aca_plan_modulo_detalle PRIMARY KEY (id_aca_plan_modulo_detalle);

ALTER TABLE aca_programa ADD CONSTRAINT pk_aca_programa PRIMARY KEY (id_aca_programa);

ALTER TABLE aca_programa_aprobado ADD CONSTRAINT pk_aca_programa_aprobado PRIMARY KEY (id_aca_programa_aprobado);

ALTER TABLE aca_programa_modalidad_graduacion ADD CONSTRAINT aca_programa_modalidad_graduacion_pkey PRIMARY KEY (id_aca_programa_modalidad_graduacion);

ALTER TABLE aca_tipo_estudiante ADD CONSTRAINT aca_tipo_estudiante_pkey PRIMARY KEY (id_aca_tipo_estudiante);

ALTER TABLE aca_titulo_certificado ADD CONSTRAINT aca_titulo_certificado_pkey PRIMARY KEY (id_aca_titulo_certificado);

ALTER TABLE aca_unidad ADD CONSTRAINT pk_aca_unidad PRIMARY KEY (id_aca_unidad);

ALTER TABLE aca_version ADD CONSTRAINT pk_aca_version PRIMARY KEY (id_aca_version);

ALTER TABLE cer_certificado ADD CONSTRAINT pk_cer_certificado PRIMARY KEY (id_cer_certificado);

ALTER TABLE cer_impresion ADD CONSTRAINT pk_cer_impresion PRIMARY KEY (id_cer_impresion);

ALTER TABLE cer_titulacion ADD CONSTRAINT pk_cer_titulacion PRIMARY KEY (id_cer_titulacion);

ALTER TABLE eje_administrativo ADD CONSTRAINT pk_eje_administrativo PRIMARY KEY (id_eje_administrativo);

ALTER TABLE eje_area_evaluacion ADD CONSTRAINT eje_area_evaluacion_pkey PRIMARY KEY (id_eje_area_evaluacion);

ALTER TABLE eje_calificacion ADD CONSTRAINT pk_eje_calificacion PRIMARY KEY (id_eje_calificacion);

ALTER TABLE eje_criterio_eval ADD CONSTRAINT pk_eje_criterio_eval PRIMARY KEY (id_eje_criterio_eval);

ALTER TABLE eje_cronograma_modulo ADD CONSTRAINT pk_eje_cronograma_modulo PRIMARY KEY (id_eje_cronograma_modulo);

ALTER TABLE eje_detalle_calificacion ADD CONSTRAINT eje_detalle_calificacion_pkey PRIMARY KEY (id_eje_detalle_calificacion);

ALTER TABLE eje_docente ADD CONSTRAINT pk_eje_docente PRIMARY KEY (id_eje_docente);

ALTER TABLE eje_log_calificacion ADD CONSTRAINT eje_log_calificacion_pkey PRIMARY KEY (id_eje_log_calificacion);

ALTER TABLE eje_programacion ADD CONSTRAINT pk_eje_programacion PRIMARY KEY (id_eje_programacion);

ALTER TABLE fin_arancel ADD CONSTRAINT fin_arancel_pkey PRIMARY KEY (id_fin_arancel);

ALTER TABLE fin_colegio_convenio ADD CONSTRAINT fin_colegio_convenio_pkey PRIMARY KEY (id_fin_colegio_convenio);

ALTER TABLE fin_concepto_arancel ADD CONSTRAINT fin_concepto_arancel_pkey PRIMARY KEY (id_fin_concepto_arancel);

ALTER TABLE fin_concepto_pago ADD CONSTRAINT pk_fin_concepto_pago PRIMARY KEY (id_fin_concepto_pago);

ALTER TABLE fin_convenio ADD CONSTRAINT fin_convenio_pkey PRIMARY KEY (id_fin_convenio);

ALTER TABLE fin_descuento_arancel ADD CONSTRAINT fin_descuento_arancel_pkey PRIMARY KEY (id_fin_descuento_arancel);

ALTER TABLE fin_detalle_arancel ADD CONSTRAINT fin_detalle_arancel_pkey PRIMARY KEY (id_fin_detalle_arancel);

ALTER TABLE fin_detalle_pago ADD CONSTRAINT pk_fin_detalle_pago PRIMARY KEY (id_fin_detalle_pago);

ALTER TABLE fin_obligacion_pago ADD CONSTRAINT pk_fin_obligacion_pago PRIMARY KEY (id_fin_obligacion_pago);

ALTER TABLE fin_transaccion ADD CONSTRAINT pk_fin_transaccion PRIMARY KEY (id_fin_transaccion);

ALTER TABLE ins_grupo ADD CONSTRAINT pk_ins_grupo PRIMARY KEY (id_ins_grupo);

ALTER TABLE ins_matricula ADD CONSTRAINT pk_ins_matricula PRIMARY KEY (cod_ins_matricula);

ALTER TABLE ins_preinscripcion ADD CONSTRAINT pk_ins_preinscripcion PRIMARY KEY (id_ins_preinscripcion);

ALTER TABLE prs_persona ADD CONSTRAINT pk_prs_persona PRIMARY KEY (id_prs_persona);

ALTER TABLE pub_noticia ADD CONSTRAINT pk_pub_noticia PRIMARY KEY (id_pub_noticia);

ALTER TABLE seg_designa ADD CONSTRAINT pk_seg_designa PRIMARY KEY (id_seg_tarea, id_seg_usuario);

ALTER TABLE seg_ocupa ADD CONSTRAINT pk_seg_ocupa PRIMARY KEY (id_seg_rol, id_seg_usuario);

ALTER TABLE seg_rol ADD CONSTRAINT pk_seg_rol PRIMARY KEY (id_seg_rol);

ALTER TABLE seg_tarea ADD CONSTRAINT pk_seg_tarea PRIMARY KEY (id_seg_tarea);

ALTER TABLE seg_usuario ADD CONSTRAINT pk_seg_usuario PRIMARY KEY (id_seg_usuario);

ALTER TABLE tgr_monografia ADD CONSTRAINT pk_tgr_monografia PRIMARY KEY (id_tgr_monografia);

ALTER TABLE tgr_observacion_monografia ADD CONSTRAINT pk_tgr_observacion_monografia PRIMARY KEY (id_tgr_observacion_monografia);

ALTER TABLE tgr_revision_monografia ADD CONSTRAINT pk_tgr_revision_monografia PRIMARY KEY (id_tgr_revision_monografia);

ALTER TABLE tgr_tribunal ADD CONSTRAINT pk_tgr_tribunal PRIMARY KEY (id_tgr_tribunal);


-- Foreign Keys
ALTER TABLE aca_certificacion_programa ADD CONSTRAINT aca_certificacion_programa_id_aca_programa_aprobado_fkey FOREIGN KEY (id_aca_programa_aprobado) REFERENCES aca_programa_aprobado (id_aca_programa_aprobado);

ALTER TABLE aca_certificacion_programa ADD CONSTRAINT aca_certificacion_programa_id_aca_titulo_certificado_fkey FOREIGN KEY (id_aca_titulo_certificado) REFERENCES aca_titulo_certificado (id_aca_titulo_certificado);

ALTER TABLE aca_certificado_emitido ADD CONSTRAINT aca_certificado_emitido_id_aca_certificacion_programa_fkey FOREIGN KEY (id_aca_certificacion_programa) REFERENCES aca_certificacion_programa (id_aca_certificacion_programa);

ALTER TABLE aca_certificado_emitido ADD CONSTRAINT aca_certificado_emitido_id_aca_modalidad_graduacion_fkey FOREIGN KEY (id_aca_modalidad_graduacion) REFERENCES aca_modalidad_graduacion (id_aca_modalidad_graduacion);

ALTER TABLE aca_certificado_emitido ADD CONSTRAINT aca_certificado_emitido_id_prs_persona_fkey FOREIGN KEY (id_prs_persona) REFERENCES prs_persona (id_prs_persona);

ALTER TABLE aca_parametro_programa ADD CONSTRAINT fk_aca_para_programa__aca_prog FOREIGN KEY (id_aca_programa_aprobado) REFERENCES aca_programa_aprobado (id_aca_programa_aprobado) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE aca_periodo ADD CONSTRAINT aca_periodo_id_aca_gestion_fkey FOREIGN KEY (id_aca_gestion) REFERENCES aca_gestion (id_aca_gestion);

ALTER TABLE aca_plan_modulo_detalle ADD CONSTRAINT fk_aca_plan_modulo_es_aca_modu FOREIGN KEY (id_aca_modulo) REFERENCES aca_modulo (id_aca_modulo) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE aca_plan_modulo_detalle ADD CONSTRAINT fk_aca_plan_nivel_org_aca_nive FOREIGN KEY (id_aca_nivel) REFERENCES aca_nivel (id_aca_nivel) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE aca_plan_modulo_detalle ADD CONSTRAINT fk_aca_plan_plan_estu_aca_plan FOREIGN KEY (id_aca_plan_estudio) REFERENCES aca_plan_estudio (id_aca_plan_estudio) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE aca_programa ADD CONSTRAINT fk_aca_prog_programa__aca_area FOREIGN KEY (id_aca_area) REFERENCES aca_area (id_aca_area) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE aca_programa_aprobado ADD CONSTRAINT fk_aca_prog_programa__aca_moda FOREIGN KEY (id_aca_modalidad) REFERENCES aca_modalidad (id_aca_modalidad) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE aca_programa_aprobado ADD CONSTRAINT fk_aca_prog_programa__aca_plan FOREIGN KEY (id_aca_plan_estudio) REFERENCES aca_plan_estudio (id_aca_plan_estudio) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE aca_programa_aprobado ADD CONSTRAINT fk_aca_prog_programa__aca_prog FOREIGN KEY (id_aca_programa) REFERENCES aca_programa (id_aca_programa) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE aca_programa_aprobado ADD CONSTRAINT fk_aca_prog_programa__aca_vers FOREIGN KEY (id_aca_version) REFERENCES aca_version (id_aca_version) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE aca_programa_modalidad_graduacion ADD CONSTRAINT aca_programa_modalidad_graduac_id_aca_modalidad_graduacion_fkey FOREIGN KEY (id_aca_modalidad_graduacion) REFERENCES aca_modalidad_graduacion (id_aca_modalidad_graduacion);

ALTER TABLE aca_programa_modalidad_graduacion ADD CONSTRAINT aca_programa_modalidad_graduacion_id_aca_programa_aprobado_fkey FOREIGN KEY (id_aca_programa_aprobado) REFERENCES aca_programa_aprobado (id_aca_programa_aprobado);

ALTER TABLE cer_certificado ADD CONSTRAINT fk_cer_cert_administr_eje_admi FOREIGN KEY (id_eje_administrativo) REFERENCES eje_administrativo (id_eje_administrativo) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE cer_certificado ADD CONSTRAINT fk_cer_cert_matricula_ins_matr FOREIGN KEY (cod_ins_matricula) REFERENCES ins_matricula (cod_ins_matricula) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE cer_impresion ADD CONSTRAINT fk_cer_impr_certifica_cer_cert FOREIGN KEY (id_cer_certificado) REFERENCES cer_certificado (id_cer_certificado) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE cer_impresion ADD CONSTRAINT fk_cer_impr_obligacio_fin_obli FOREIGN KEY (id_fin_obligacion_pago) REFERENCES fin_obligacion_pago (id_fin_obligacion_pago) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE cer_titulacion ADD CONSTRAINT fk_cer_titu_matricula_ins_matr FOREIGN KEY (cod_ins_matricula) REFERENCES ins_matricula (cod_ins_matricula) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_administrativo ADD CONSTRAINT fk_eje_admi_administr_seg_usua FOREIGN KEY (id_seg_usuario) REFERENCES seg_usuario (id_seg_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_administrativo ADD CONSTRAINT fk_eje_admi_persona_p_prs_pers FOREIGN KEY (id_prs_persona) REFERENCES prs_persona (id_prs_persona) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_area_evaluacion ADD CONSTRAINT eje_area_evaluacion_id_aca_programa_aprobado_fkey FOREIGN KEY (id_aca_programa_aprobado) REFERENCES aca_programa_aprobado (id_aca_programa_aprobado);

ALTER TABLE eje_calificacion ADD CONSTRAINT fk_calificacion_prox_modulo FOREIGN KEY (pasa_a_modulo) REFERENCES aca_modulo (id_aca_modulo);

ALTER TABLE eje_calificacion ADD CONSTRAINT fk_eje_cali_calificac_eje_crit FOREIGN KEY (id_eje_criterio_eval) REFERENCES eje_criterio_eval (id_eje_criterio_eval) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_calificacion ADD CONSTRAINT fk_eje_cali_programac_eje_prog FOREIGN KEY (id_eje_programacion) REFERENCES eje_programacion (id_eje_programacion) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_criterio_eval ADD CONSTRAINT fk_criterio_cronograma FOREIGN KEY (id_eje_cronograma_modulo) REFERENCES eje_cronograma_modulo (id_eje_cronograma_modulo) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_criterio_eval ADD CONSTRAINT fk_eje_crit_docente_define_criterio FOREIGN KEY (id_eje_docente) REFERENCES eje_docente (id_eje_docente) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_cronograma_modulo ADD CONSTRAINT fk_cronograma_docente FOREIGN KEY (id_eje_docente) REFERENCES eje_docente (id_eje_docente);

ALTER TABLE eje_cronograma_modulo ADD CONSTRAINT fk_cronograma_periodo FOREIGN KEY (id_aca_periodo) REFERENCES aca_periodo (id_aca_periodo);

ALTER TABLE eje_cronograma_modulo ADD CONSTRAINT fk_eje_cron_cronogram_aca_plan FOREIGN KEY (id_aca_plan_modulo_detalle) REFERENCES aca_plan_modulo_detalle (id_aca_plan_modulo_detalle) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_cronograma_modulo ADD CONSTRAINT fk_eje_cron_docente_s_eje_doce FOREIGN KEY (id_eje_docente) REFERENCES eje_docente (id_eje_docente) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_cronograma_modulo ADD CONSTRAINT fk_eje_cron_grupo_tie_ins_grup FOREIGN KEY (id_ins_grupo) REFERENCES ins_grupo (id_ins_grupo) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_detalle_calificacion ADD CONSTRAINT eje_detalle_calificacion_id_eje_area_evaluacion_fkey FOREIGN KEY (id_eje_area_evaluacion) REFERENCES eje_area_evaluacion (id_eje_area_evaluacion);

ALTER TABLE eje_detalle_calificacion ADD CONSTRAINT eje_detalle_calificacion_id_eje_calificacion_fkey FOREIGN KEY (id_eje_calificacion) REFERENCES eje_calificacion (id_eje_calificacion);

ALTER TABLE eje_docente ADD CONSTRAINT fk_eje_doce_docente_t_seg_usua FOREIGN KEY (id_seg_usuario) REFERENCES seg_usuario (id_seg_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_docente ADD CONSTRAINT fk_eje_doce_persona_p_prs_pers FOREIGN KEY (id_prs_persona) REFERENCES prs_persona (id_prs_persona) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_programacion ADD CONSTRAINT fk_eje_prog_cronogram_eje_cron FOREIGN KEY (id_eje_cronograma_modulo) REFERENCES eje_cronograma_modulo (id_eje_cronograma_modulo) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE eje_programacion ADD CONSTRAINT fk_eje_prog_matricula_ins_matr FOREIGN KEY (cod_ins_matricula) REFERENCES ins_matricula (cod_ins_matricula) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE fin_arancel ADD CONSTRAINT fin_arancel_id_aca_periodo_fkey FOREIGN KEY (id_aca_periodo) REFERENCES aca_periodo (id_aca_periodo);

ALTER TABLE fin_arancel ADD CONSTRAINT fin_arancel_id_aca_programa_aprobado_fkey FOREIGN KEY (id_aca_programa_aprobado) REFERENCES aca_programa_aprobado (id_aca_programa_aprobado);

ALTER TABLE fin_arancel ADD CONSTRAINT fin_arancel_id_aca_tipo_estudiante_fkey FOREIGN KEY (id_aca_tipo_estudiante) REFERENCES aca_tipo_estudiante (id_aca_tipo_estudiante);

ALTER TABLE fin_colegio_convenio ADD CONSTRAINT fin_colegio_convenio_id_aca_colegio_fkey FOREIGN KEY (id_aca_colegio) REFERENCES aca_colegio (id_aca_colegio);

ALTER TABLE fin_colegio_convenio ADD CONSTRAINT fin_colegio_convenio_id_fin_convenio_fkey FOREIGN KEY (id_fin_convenio) REFERENCES fin_convenio (id_fin_convenio);

ALTER TABLE fin_descuento_arancel ADD CONSTRAINT fin_descuento_arancel_id_fin_arancel_fkey FOREIGN KEY (id_fin_arancel) REFERENCES fin_arancel (id_fin_arancel);

ALTER TABLE fin_detalle_arancel ADD CONSTRAINT fin_detalle_arancel_id_fin_arancel_fkey FOREIGN KEY (id_fin_arancel) REFERENCES fin_arancel (id_fin_arancel);

ALTER TABLE fin_detalle_arancel ADD CONSTRAINT fin_detalle_arancel_id_fin_concepto_arancel_fkey FOREIGN KEY (id_fin_concepto_arancel) REFERENCES fin_concepto_arancel (id_fin_concepto_arancel);

ALTER TABLE fin_detalle_pago ADD CONSTRAINT fk_fin_deta_obligacio_fin_obli FOREIGN KEY (id_fin_obligacion_pago) REFERENCES fin_obligacion_pago (id_fin_obligacion_pago) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE fin_detalle_pago ADD CONSTRAINT fk_fin_deta_transacci_fin_tran FOREIGN KEY (id_fin_transaccion) REFERENCES fin_transaccion (id_fin_transaccion) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE fin_obligacion_pago ADD CONSTRAINT fk_fin_obli_matricula_ins_matr FOREIGN KEY (cod_ins_matricula) REFERENCES ins_matricula (cod_ins_matricula) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE fin_obligacion_pago ADD CONSTRAINT fk_fin_obli_obligacio_aca_para FOREIGN KEY (id_aca_parametro) REFERENCES aca_parametro_programa (id_aca_parametro) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE fin_obligacion_pago ADD CONSTRAINT fk_fin_obli_obligacio_fin_conc FOREIGN KEY (id_fin_concepto_pago) REFERENCES fin_concepto_pago (id_fin_concepto_pago) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE ins_grupo ADD CONSTRAINT fk_ins_grup_programa__aca_prog FOREIGN KEY (id_aca_programa_aprobado) REFERENCES aca_programa_aprobado (id_aca_programa_aprobado) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE ins_matricula ADD CONSTRAINT fk_ins_matr_grupo_ins_ins_grup FOREIGN KEY (id_ins_grupo) REFERENCES ins_grupo (id_ins_grupo) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE ins_matricula ADD CONSTRAINT fk_ins_matr_matricula_seg_usua FOREIGN KEY (id_seg_usuario) REFERENCES seg_usuario (id_seg_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE ins_matricula ADD CONSTRAINT fk_ins_matr_persona_s_prs_pers FOREIGN KEY (id_prs_persona) REFERENCES prs_persona (id_prs_persona) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE ins_matricula ADD CONSTRAINT fk_matricula_arancel FOREIGN KEY (id_fin_arancel_aplicado) REFERENCES fin_arancel (id_fin_arancel);

ALTER TABLE ins_matricula ADD CONSTRAINT fk_matricula_convenio FOREIGN KEY (id_fin_convenio_aplicado) REFERENCES fin_convenio (id_fin_convenio);

ALTER TABLE ins_matricula ADD CONSTRAINT fk_matricula_tipo_estudiante FOREIGN KEY (id_aca_tipo_estudiante) REFERENCES aca_tipo_estudiante (id_aca_tipo_estudiante);

ALTER TABLE ins_preinscripcion ADD CONSTRAINT fk_ins_prei_persona_r_prs_pers FOREIGN KEY (id_prs_persona) REFERENCES prs_persona (id_prs_persona) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE ins_preinscripcion ADD CONSTRAINT fk_ins_prei_programa__aca_prog FOREIGN KEY (id_aca_programa_aprobado) REFERENCES aca_programa_aprobado (id_aca_programa_aprobado) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE prs_persona ADD CONSTRAINT fk_persona_apoderado FOREIGN KEY (id_prs_persona_apoderado) REFERENCES prs_persona (id_prs_persona);

ALTER TABLE prs_persona ADD CONSTRAINT fk_persona_colegio FOREIGN KEY (id_aca_colegio_procedencia) REFERENCES aca_colegio (id_aca_colegio);

ALTER TABLE pub_noticia ADD CONSTRAINT fk_pub_noticia_unidad FOREIGN KEY (id_aca_unidad) REFERENCES aca_unidad (id_aca_unidad) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE seg_designa ADD CONSTRAINT fk_seg_desi_tarea_se__seg_tare FOREIGN KEY (id_seg_tarea) REFERENCES seg_tarea (id_seg_tarea) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE seg_designa ADD CONSTRAINT fk_seg_desi_usuario_r_seg_usua FOREIGN KEY (id_seg_usuario) REFERENCES seg_usuario (id_seg_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE seg_ocupa ADD CONSTRAINT fk_seg_ocup_rol_se_oc_seg_rol FOREIGN KEY (id_seg_rol) REFERENCES seg_rol (id_seg_rol) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE seg_ocupa ADD CONSTRAINT fk_seg_ocup_usuario_o_seg_usua FOREIGN KEY (id_seg_usuario) REFERENCES seg_usuario (id_seg_usuario) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE seg_tarea ADD CONSTRAINT fk_seg_tare_rol_agrup_seg_rol FOREIGN KEY (id_seg_rol) REFERENCES seg_rol (id_seg_rol) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE tgr_monografia ADD CONSTRAINT fk_tgr_mono_matricula_ins_matr FOREIGN KEY (cod_ins_matricula) REFERENCES ins_matricula (cod_ins_matricula) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE tgr_observacion_monografia ADD CONSTRAINT fk_tgr_obse_revision__tgr_revi FOREIGN KEY (id_tgr_revision_monografia) REFERENCES tgr_revision_monografia (id_tgr_revision_monografia) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE tgr_revision_monografia ADD CONSTRAINT fk_tgr_revi_monografi_tgr_mono FOREIGN KEY (id_tgr_monografia) REFERENCES tgr_monografia (id_tgr_monografia) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE tgr_revision_monografia ADD CONSTRAINT fk_tgr_revi_revisado__eje_admi FOREIGN KEY (id_eje_administrativo) REFERENCES eje_administrativo (id_eje_administrativo) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE tgr_revision_monografia ADD CONSTRAINT fk_tgr_revi_revisado__eje_doce FOREIGN KEY (id_eje_docente) REFERENCES eje_docente (id_eje_docente) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE tgr_tribunal ADD CONSTRAINT fk_tgr_trib_monografi_tgr_mono FOREIGN KEY (id_tgr_monografia) REFERENCES tgr_monografia (id_tgr_monografia) ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE tgr_tribunal ADD CONSTRAINT fk_tgr_trib_tribunal__prs_pers FOREIGN KEY (id_prs_persona) REFERENCES prs_persona (id_prs_persona) ON UPDATE RESTRICT ON DELETE RESTRICT;
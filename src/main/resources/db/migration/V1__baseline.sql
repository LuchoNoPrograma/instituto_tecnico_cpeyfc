create table aca_area
(
  id_aca_area serial
    constraint pk_aca_area
      primary key,
  nombre_area varchar(100) not null,
  estado_area varchar(35)  not null,
  fecha_reg   timestamp    not null,
  fecha_mod   timestamp,
  user_reg    integer      not null,
  user_mod    integer
);

comment on column aca_area.estado_area is 'Estado de area';

comment on column aca_area.fecha_reg is 'Fecha de registro';

comment on column aca_area.fecha_mod is 'Fecha de modificación';

comment on column aca_area.user_reg is 'Usuario que registró';

comment on column aca_area.user_mod is 'Usuario que modificó';

alter table aca_area
  owner to postgres;

create unique index aca_area_pk
  on aca_area (id_aca_area);

create table aca_modalidad
(
  id_aca_modalidad serial
    constraint pk_aca_modalidad
      primary key,
  nombre_modalidad varchar(50) not null,
  estado_modalidad varchar(35) not null,
  fecha_reg        timestamp   not null,
  fecha_mod        timestamp,
  user_reg         integer     not null,
  user_mod         integer
);

comment on column aca_modalidad.estado_modalidad is 'Estado de modalidad';

comment on column aca_modalidad.fecha_reg is 'Fecha de registro';

comment on column aca_modalidad.fecha_mod is 'Fecha de modificación';

comment on column aca_modalidad.user_reg is 'Usuario que registró';

comment on column aca_modalidad.user_mod is 'Usuario que modificó';

alter table aca_modalidad
  owner to postgres;

create unique index aca_modalidad_pk
  on aca_modalidad (id_aca_modalidad);

create table aca_modulo
(
  id_aca_modulo serial
    constraint pk_aca_modulo
      primary key,
  nombre_modulo varchar(100) not null,
  estado_modulo varchar(35)  not null,
  fecha_reg     timestamp    not null,
  fecha_mod     timestamp,
  user_reg      integer      not null,
  user_mod      integer
);

comment on column aca_modulo.estado_modulo is 'Estado de modulo';

comment on column aca_modulo.fecha_reg is 'Fecha de registro';

comment on column aca_modulo.fecha_mod is 'Fecha de modificación';

comment on column aca_modulo.user_reg is 'Usuario que registró';

comment on column aca_modulo.user_mod is 'Usuario que modificó';

alter table aca_modulo
  owner to postgres;

create unique index aca_modulo_pk
  on aca_modulo (id_aca_modulo);

create table aca_nivel
(
  id_aca_nivel serial
    constraint pk_aca_nivel
      primary key,
  nombre_nivel varchar(100) not null,
  estado_nivel varchar(35)  not null,
  fecha_reg    timestamp    not null,
  fecha_mod    timestamp,
  user_reg     integer      not null,
  user_mod     integer
);

comment on column aca_nivel.estado_nivel is 'Estado de nivel';

comment on column aca_nivel.fecha_reg is 'Fecha de registro';

comment on column aca_nivel.fecha_mod is 'Fecha de modificación';

comment on column aca_nivel.user_reg is 'Usuario que registró';

comment on column aca_nivel.user_mod is 'Usuario que modificó';

alter table aca_nivel
  owner to postgres;

create unique index aca_nivel_pk
  on aca_nivel (id_aca_nivel);

create table aca_plan_estudio
(
  id_aca_plan_estudio serial
    constraint pk_aca_plan_estudio
      primary key,
  anho                integer     not null,
  vigente             boolean     not null,
  estado_plan_estudio varchar(35) not null,
  fecha_reg           timestamp   not null,
  fecha_mod           timestamp,
  user_reg            integer     not null,
  user_mod            integer
);

comment on column aca_plan_estudio.estado_plan_estudio is 'Estado de plan_estudio';

comment on column aca_plan_estudio.fecha_reg is 'Fecha de registro';

comment on column aca_plan_estudio.fecha_mod is 'Fecha de modificación';

comment on column aca_plan_estudio.user_reg is 'Usuario que registró';

comment on column aca_plan_estudio.user_mod is 'Usuario que modificó';

alter table aca_plan_estudio
  owner to postgres;

create unique index aca_plan_estudio_pk
  on aca_plan_estudio (id_aca_plan_estudio);

create table aca_plan_modulo_detalle
(
  id_aca_plan_modulo_detalle serial
    constraint pk_aca_plan_modulo_detalle
      primary key,
  id_aca_nivel               integer       not null
    constraint fk_aca_plan_nivel_org_aca_nive
      references aca_nivel
      on update restrict on delete restrict,
  id_aca_plan_estudio        integer       not null
    constraint fk_aca_plan_plan_estu_aca_plan
      references aca_plan_estudio
      on update restrict on delete restrict,
  id_aca_modulo              integer       not null
    constraint fk_aca_plan_modulo_es_aca_modu
      references aca_modulo
      on update restrict on delete restrict,
  carga_horaria              integer       not null,
  creditos                   numeric(6, 2) not null,
  orden                      integer       not null,
  sigla                      char(10)      not null,
  competencia                text,
  estado_plan_modulo_detalle varchar(35)   not null,
  fecha_reg                  timestamp     not null,
  fecha_mod                  timestamp,
  user_reg                   integer       not null,
  user_mod                   integer
);

comment on column aca_plan_modulo_detalle.estado_plan_modulo_detalle is 'Estado de plan_modulo_detalle';

comment on column aca_plan_modulo_detalle.fecha_reg is 'Fecha de registro';

comment on column aca_plan_modulo_detalle.fecha_mod is 'Fecha de modificación';

comment on column aca_plan_modulo_detalle.user_reg is 'Usuario que registró';

comment on column aca_plan_modulo_detalle.user_mod is 'Usuario que modificó';

alter table aca_plan_modulo_detalle
  owner to postgres;

create unique index aca_plan_modulo_detalle_pk
  on aca_plan_modulo_detalle (id_aca_plan_modulo_detalle);

create index modulo_esta_en_un_plan_estudio_
  on aca_plan_modulo_detalle (id_aca_modulo);

create index plan_estudio_contiene_modulos_d
  on aca_plan_modulo_detalle (id_aca_plan_estudio);

create index nivel_organiza_plan_modulo_deta
  on aca_plan_modulo_detalle (id_aca_nivel);

create table aca_programa
(
  id_aca_programa serial
    constraint pk_aca_programa
      primary key,
  id_aca_area     integer      not null
    constraint fk_aca_prog_programa__aca_area
      references aca_area
      on update restrict on delete restrict,
  nombre_programa varchar(100) not null,
  sigla           varchar(15),
  estado_programa varchar(35)  not null,
  fecha_reg       timestamp    not null,
  fecha_mod       timestamp,
  user_reg        integer      not null,
  user_mod        integer
);

comment on column aca_programa.estado_programa is 'Estado de programa';

comment on column aca_programa.fecha_reg is 'Fecha de registro';

comment on column aca_programa.fecha_mod is 'Fecha de modificación';

comment on column aca_programa.user_reg is 'Usuario que registró';

comment on column aca_programa.user_mod is 'Usuario que modificó';

alter table aca_programa
  owner to postgres;

create unique index aca_programa_pk
  on aca_programa (id_aca_programa);

create index programa_clasificado_por_area_f
  on aca_programa (id_aca_area);

create table aca_version
(
  id_aca_version serial
    constraint pk_aca_version
      primary key,
  cod_version    varchar(10) not null,
  estado_version varchar(35) not null,
  fecha_reg      timestamp   not null,
  fecha_mod      timestamp,
  user_reg       integer     not null,
  user_mod       integer
);

comment on column aca_version.estado_version is 'Estado de version';

comment on column aca_version.fecha_reg is 'Fecha de registro';

comment on column aca_version.fecha_mod is 'Fecha de modificación';

comment on column aca_version.user_reg is 'Usuario que registró';

comment on column aca_version.user_mod is 'Usuario que modificó';

alter table aca_version
  owner to postgres;

create table aca_programa_aprobado
(
  id_aca_programa_aprobado serial
    constraint pk_aca_programa_aprobado
      primary key,
  id_aca_modalidad         integer       not null
    constraint fk_aca_prog_programa__aca_moda
      references aca_modalidad
      on update restrict on delete restrict,
  id_aca_programa          integer       not null
    constraint fk_aca_prog_programa__aca_prog
      references aca_programa
      on update restrict on delete restrict,
  id_aca_plan_estudio      integer
    constraint fk_aca_prog_programa__aca_plan
      references aca_plan_estudio
      on update restrict on delete restrict,
  id_aca_version           integer       not null
    constraint fk_aca_prog_programa__aca_vers
      references aca_version
      on update restrict on delete restrict,
  fecha_inicio_vigencia    date,
  fecha_fin_vigencia       date,
  estado_programa_aprobado varchar(35)   not null,
  gestion                  integer       not null,
  cod_certificado_ceub     varchar(55),
  cod_sigla_version        varchar(15),
  precio_matricula         numeric(8, 2) not null,
  precio_colegiatura       numeric(8, 2) not null,
  precio_titulacion        numeric(8, 2),
  fecha_reg                timestamp     not null,
  fecha_mod                timestamp,
  user_reg                 integer       not null,
  user_mod                 integer
);

comment on column aca_programa_aprobado.estado_programa_aprobado is 'Estado de programa aprobado';

comment on column aca_programa_aprobado.fecha_reg is 'Fecha de registro';

comment on column aca_programa_aprobado.fecha_mod is 'Fecha de modificación';

comment on column aca_programa_aprobado.user_reg is 'Usuario que registró';

comment on column aca_programa_aprobado.user_mod is 'Usuario que modificó';

alter table aca_programa_aprobado
  owner to postgres;

create table aca_parametro_programa
(
  id_aca_parametro          serial
    constraint pk_aca_parametro_programa
      primary key,
  id_aca_programa_aprobado  integer     not null
    constraint fk_aca_para_programa__aca_prog
      references aca_programa_aprobado
      on update restrict on delete restrict,
  nombre_param              varchar(55) not null,
  valor                     text        not null,
  tipo_dato_param           varchar(35) not null,
  fecha_inicio_vigencia     date,
  fecha_fin_vigencia        date,
  orden                     integer     not null,
  estado_parametro_programa varchar(35) not null,
  fecha_reg                 timestamp   not null,
  fecha_mod                 timestamp,
  user_reg                  integer     not null,
  user_mod                  integer
);

comment on column aca_parametro_programa.estado_parametro_programa is 'Estado de parametro_programa';

comment on column aca_parametro_programa.fecha_reg is 'Fecha de registro';

comment on column aca_parametro_programa.fecha_mod is 'Fecha de modificación';

comment on column aca_parametro_programa.user_reg is 'Usuario que registró';

comment on column aca_parametro_programa.user_mod is 'Usuario que modificó';

alter table aca_parametro_programa
  owner to postgres;

create unique index aca_parametro_programa_pk
  on aca_parametro_programa (id_aca_parametro);

create index programa_aprobado_define_parame
  on aca_parametro_programa (id_aca_programa_aprobado);

create unique index aca_programa_aprobado_pk
  on aca_programa_aprobado (id_aca_programa_aprobado);

create index programa_es_aprobado_con_plan_e
  on aca_programa_aprobado (id_aca_plan_estudio);

create index programa_tiene_modalidad_fk
  on aca_programa_aprobado (id_aca_modalidad);

create index programa_tiene_version_ceub_fk
  on aca_programa_aprobado (id_aca_version);

create index programa_puede_ser_aprobado_fk
  on aca_programa_aprobado (id_aca_programa);

create unique index aca_version_pk
  on aca_version (id_aca_version);

create table fin_concepto_pago
(
  id_fin_concepto_pago serial
    constraint pk_fin_concepto_pago
      primary key,
  nombre_concepto      varchar(35) not null,
  descripcion          text,
  estado_concepto_pago varchar(35) not null,
  fecha_reg            timestamp   not null,
  fecha_mod            timestamp,
  user_reg             integer     not null,
  user_mod             integer
);

comment on column fin_concepto_pago.estado_concepto_pago is 'Estado de concepto_pago';

comment on column fin_concepto_pago.fecha_reg is 'Fecha de registro';

comment on column fin_concepto_pago.fecha_mod is 'Fecha de modificación';

comment on column fin_concepto_pago.user_reg is 'Usuario que registró';

comment on column fin_concepto_pago.user_mod is 'Usuario que modificó';

alter table fin_concepto_pago
  owner to postgres;

create unique index fin_concepto_pago_pk
  on fin_concepto_pago (id_fin_concepto_pago);

create table fin_transaccion
(
  id_fin_transaccion serial
    constraint pk_fin_transaccion
      primary key,
  cod_comprobante    varchar(35)    not null,
  total_pago         numeric(10, 2) not null,
  fecha_pago         date           not null,
  tipo_comprobante   varchar(35)    not null,
  observacion        varchar(500),
  estado_transaccion varchar(35)    not null,
  fecha_reg          timestamp      not null,
  fecha_mod          timestamp,
  user_reg           integer        not null,
  user_mod           integer
);

comment on column fin_transaccion.estado_transaccion is 'Estado de transaccion';

comment on column fin_transaccion.fecha_reg is 'Fecha de registro';

comment on column fin_transaccion.fecha_mod is 'Fecha de modificación';

comment on column fin_transaccion.user_reg is 'Usuario que registró';

comment on column fin_transaccion.user_mod is 'Usuario que modificó';

alter table fin_transaccion
  owner to postgres;

create unique index fin_transaccion_pk
  on fin_transaccion (id_fin_transaccion);

create table ins_grupo
(
  id_ins_grupo             serial
    constraint pk_ins_grupo
      primary key,
  id_aca_programa_aprobado integer      not null
    constraint fk_ins_grup_programa__aca_prog
      references aca_programa_aprobado
      on update restrict on delete restrict,
  nombre_grupo             varchar(100) not null,
  fecha_inicio_inscripcion date         not null,
  fecha_fin_inscripcion    date,
  estado_grupo             varchar(35)  not null,
  gestion_inicio           integer      not null,
  fecha_reg                timestamp    not null,
  fecha_mod                timestamp,
  user_reg                 integer      not null,
  user_mod                 integer
);

comment on column ins_grupo.estado_grupo is 'Estado de grupo';

comment on column ins_grupo.fecha_reg is 'Fecha de registro';

comment on column ins_grupo.fecha_mod is 'Fecha de modificación';

comment on column ins_grupo.user_reg is 'Usuario que registró';

comment on column ins_grupo.user_mod is 'Usuario que modificó';

alter table ins_grupo
  owner to postgres;

create unique index ins_grupo_pk
  on ins_grupo (id_ins_grupo);

create index programa_aprobado_tiene_grupos_
  on ins_grupo (id_aca_programa_aprobado);

create table prs_persona
(
  id_prs_persona   serial
    constraint pk_prs_persona
      primary key,
  nombre           varchar(35) not null,
  ap_paterno       varchar(55) not null,
  ap_materno       varchar(55),
  ci               varchar(20) not null,
  nro_celular      varchar(20) not null,
  correo           varchar(55),
  fecha_nacimiento date        not null,
  estado_persona   varchar(35) not null,
  fecha_reg        timestamp   not null,
  fecha_mod        timestamp,
  user_reg         integer     not null,
  user_mod         integer
);

comment on column prs_persona.estado_persona is 'Estado de persona';

comment on column prs_persona.fecha_reg is 'Fecha de registro';

comment on column prs_persona.fecha_mod is 'Fecha de modificación';

comment on column prs_persona.user_reg is 'Usuario que registró';

comment on column prs_persona.user_mod is 'Usuario que modificó';

alter table prs_persona
  owner to postgres;

create table ins_preinscripcion
(
  id_ins_preinscripcion    serial
    constraint pk_ins_preinscripcion
      primary key,
  id_aca_programa_aprobado integer     not null
    constraint fk_ins_prei_programa__aca_prog
      references aca_programa_aprobado
      on update restrict on delete restrict,
  id_prs_persona           integer     not null
    constraint fk_ins_prei_persona_r_prs_pers
      references prs_persona
      on update restrict on delete restrict,
  estado_preinscripcion    varchar(35) not null,
  fecha_reg                timestamp   not null,
  fecha_mod                timestamp,
  user_reg                 integer     not null,
  user_mod                 integer
);

comment on column ins_preinscripcion.estado_preinscripcion is 'Estado de preinscripcion';

comment on column ins_preinscripcion.fecha_reg is 'Fecha de registro';

comment on column ins_preinscripcion.fecha_mod is 'Fecha de modificación';

comment on column ins_preinscripcion.user_reg is 'Usuario que registró';

comment on column ins_preinscripcion.user_mod is 'Usuario que modificó';

alter table ins_preinscripcion
  owner to postgres;

create unique index ins_preinscripcion_pk
  on ins_preinscripcion (id_ins_preinscripcion);

create index programa_recibe_preinscripcione
  on ins_preinscripcion (id_aca_programa_aprobado);

create index persona_realiza_preinscripcione
  on ins_preinscripcion (id_prs_persona);

create unique index prs_persona_pk
  on prs_persona (id_prs_persona);

create table seg_rol
(
  id_seg_rol  serial
    constraint pk_seg_rol
      primary key,
  nombre_rol  varchar(50) not null,
  descripcion text,
  estado_rol  varchar(35) not null,
  fecha_reg   timestamp   not null,
  fecha_mod   timestamp,
  user_reg    integer     not null,
  user_mod    integer
);

comment on column seg_rol.estado_rol is 'Estado de rol';

comment on column seg_rol.fecha_reg is 'Fecha de registro';

comment on column seg_rol.fecha_mod is 'Fecha de modificación';

comment on column seg_rol.user_reg is 'Usuario que registró';

comment on column seg_rol.user_mod is 'Usuario que modificó';

alter table seg_rol
  owner to postgres;

create unique index seg_rol_pk
  on seg_rol (id_seg_rol);

create table seg_tarea
(
  id_seg_tarea serial
    constraint pk_seg_tarea
      primary key,
  id_seg_rol   integer     not null
    constraint fk_seg_tare_rol_agrup_seg_rol
      references seg_rol
      on update restrict on delete restrict,
  nombre_tarea varchar(50) not null,
  descripcion  text,
  estado_tarea varchar(35) not null,
  fecha_reg    timestamp   not null,
  fecha_mod    timestamp,
  user_reg     integer     not null,
  user_mod     integer
);

comment on column seg_tarea.estado_tarea is 'Estado de tarea';

comment on column seg_tarea.fecha_reg is 'Fecha de registro';

comment on column seg_tarea.fecha_mod is 'Fecha de modificación';

comment on column seg_tarea.user_reg is 'Usuario que registró';

comment on column seg_tarea.user_mod is 'Usuario que modificó';

alter table seg_tarea
  owner to postgres;

create unique index seg_tarea_pk
  on seg_tarea (id_seg_tarea);

create index rol_agrupa_tarea_fk
  on seg_tarea (id_seg_rol);

create table seg_usuario
(
  id_seg_usuario  serial
    constraint pk_seg_usuario
      primary key,
  nombre_usuario  varchar(50),
  contrasena_hash varchar(255),
  estado_usuario  varchar(35) not null,
  fecha_reg       timestamp   not null,
  fecha_mod       timestamp,
  user_reg        integer     not null,
  user_mod        integer
);

comment on column seg_usuario.estado_usuario is 'Estado de usuario';

comment on column seg_usuario.fecha_reg is 'Fecha de registro';

comment on column seg_usuario.fecha_mod is 'Fecha de modificación';

comment on column seg_usuario.user_reg is 'Usuario que registró';

comment on column seg_usuario.user_mod is 'Usuario que modificó';

alter table seg_usuario
  owner to postgres;

create table eje_administrativo
(
  id_eje_administrativo serial
    constraint pk_eje_administrativo
      primary key,
  id_prs_persona        integer     not null
    constraint fk_eje_admi_persona_p_prs_pers
      references prs_persona
      on update restrict on delete restrict,
  id_seg_usuario        integer     not null
    constraint fk_eje_admi_administr_seg_usua
      references seg_usuario
      on update restrict on delete restrict,
  estado_administrativo varchar(35) not null,
  fecha_reg             timestamp   not null,
  fecha_mod             timestamp,
  user_reg              integer     not null,
  user_mod              integer
);

comment on column eje_administrativo.estado_administrativo is 'Estado de administrativo';

comment on column eje_administrativo.fecha_reg is 'Fecha de registro';

comment on column eje_administrativo.fecha_mod is 'Fecha de modificación';

comment on column eje_administrativo.user_reg is 'Usuario que registró';

comment on column eje_administrativo.user_mod is 'Usuario que modificó';

alter table eje_administrativo
  owner to postgres;

create unique index eje_administrativo_pk
  on eje_administrativo (id_eje_administrativo);

create index persona_puede_ser_administrativ
  on eje_administrativo (id_prs_persona);

create index administrativo_tiene_usuario_fk
  on eje_administrativo (id_seg_usuario);

create table eje_docente
(
  id_eje_docente serial
    constraint pk_eje_docente
      primary key,
  id_prs_persona integer     not null
    constraint fk_eje_doce_persona_p_prs_pers
      references prs_persona
      on update restrict on delete restrict,
  id_seg_usuario integer     not null
    constraint fk_eje_doce_docente_t_seg_usua
      references seg_usuario
      on update restrict on delete restrict,
  nro_resolucion integer,
  estado_docente varchar(35) not null,
  fecha_reg      timestamp   not null,
  fecha_mod      timestamp,
  user_reg       integer     not null,
  user_mod       integer
);

comment on column eje_docente.estado_docente is 'Estado de docente';

comment on column eje_docente.fecha_reg is 'Fecha de registro';

comment on column eje_docente.fecha_mod is 'Fecha de modificación';

comment on column eje_docente.user_reg is 'Usuario que registró';

comment on column eje_docente.user_mod is 'Usuario que modificó';

alter table eje_docente
  owner to postgres;

create table eje_cronograma_modulo
(
  id_eje_cronograma_modulo   serial
    constraint pk_eje_cronograma_modulo
      primary key,
  id_ins_grupo               integer     not null
    constraint fk_eje_cron_grupo_tie_ins_grup
      references ins_grupo
      on update restrict on delete restrict,
  id_aca_plan_modulo_detalle integer     not null
    constraint fk_eje_cron_cronogram_aca_plan
      references aca_plan_modulo_detalle
      on update restrict on delete restrict,
  id_eje_docente             integer
    constraint fk_eje_cron_docente_s_eje_doce
      references eje_docente
      on update restrict on delete restrict,
  fecha_inicio               date,
  fecha_fin                  date,
  estado_cronograma_modulo   varchar(35) not null,
  fecha_reg                  timestamp   not null,
  fecha_mod                  timestamp,
  user_reg                   integer     not null,
  user_mod                   integer
);

comment on column eje_cronograma_modulo.estado_cronograma_modulo is 'Estado de cronograma_modulo';

comment on column eje_cronograma_modulo.fecha_reg is 'Fecha de registro';

comment on column eje_cronograma_modulo.fecha_mod is 'Fecha de modificación';

comment on column eje_cronograma_modulo.user_reg is 'Usuario que registró';

comment on column eje_cronograma_modulo.user_mod is 'Usuario que modificó';

alter table eje_cronograma_modulo
  owner to postgres;

create table eje_criterio_eval
(
  id_eje_criterio_eval     serial
    constraint pk_eje_criterio_eval
      primary key,
  id_eje_cronograma_modulo integer     not null
    constraint fk_eje_crit_cronogram_eje_cron
      references eje_cronograma_modulo
      on update restrict on delete restrict,
  nombre_crit              varchar(25) not null,
  descripcion              varchar(155),
  ponderacion              integer     not null,
  orden                    integer     not null,
  estado_criterio_eval     varchar(35) not null,
  fecha_reg                timestamp   not null,
  fecha_mod                timestamp,
  user_reg                 integer     not null,
  user_mod                 integer
);

comment on column eje_criterio_eval.estado_criterio_eval is 'Estado de criterio_eval';

comment on column eje_criterio_eval.fecha_reg is 'Fecha de registro';

comment on column eje_criterio_eval.fecha_mod is 'Fecha de modificación';

comment on column eje_criterio_eval.user_reg is 'Usuario que registró';

comment on column eje_criterio_eval.user_mod is 'Usuario que modificó';

alter table eje_criterio_eval
  owner to postgres;

create unique index eje_criterio_eval_pk
  on eje_criterio_eval (id_eje_criterio_eval);

create index cronograma_modulo_define_criter
  on eje_criterio_eval (id_eje_cronograma_modulo);

create unique index eje_cronograma_modulo_pk
  on eje_cronograma_modulo (id_eje_cronograma_modulo);

create index grupo_tiene_cronogramas_modulo_
  on eje_cronograma_modulo (id_ins_grupo);

create index docente_se_le_asigna_cronograma
  on eje_cronograma_modulo (id_eje_docente);

create index cronograma_modulo_ejecuta_plan_
  on eje_cronograma_modulo (id_aca_plan_modulo_detalle);

create unique index eje_docente_pk
  on eje_docente (id_eje_docente);

create index persona_puede_ser_docente_fk
  on eje_docente (id_prs_persona);

create index docente_tiene_usuario_fk
  on eje_docente (id_seg_usuario);

create table ins_matricula
(
  cod_ins_matricula serial
    constraint pk_ins_matricula
      primary key,
  id_ins_grupo      integer     not null
    constraint fk_ins_matr_grupo_ins_ins_grup
      references ins_grupo
      on update restrict on delete restrict,
  id_prs_persona    integer     not null
    constraint fk_ins_matr_persona_s_prs_pers
      references prs_persona
      on update restrict on delete restrict,
  id_seg_usuario    integer     not null
    constraint fk_ins_matr_matricula_seg_usua
      references seg_usuario
      on update restrict on delete restrict,
  estado_matricula  varchar(35) not null,
  tipo_matricula    varchar(35) not null,
  fecha_reg         timestamp   not null,
  fecha_mod         timestamp,
  user_reg          integer     not null,
  user_mod          integer
);

comment on column ins_matricula.estado_matricula is 'Estado de matricula';

comment on column ins_matricula.fecha_reg is 'Fecha de registro';

comment on column ins_matricula.fecha_mod is 'Fecha de modificación';

comment on column ins_matricula.user_reg is 'Usuario que registró';

comment on column ins_matricula.user_mod is 'Usuario que modificó';

alter table ins_matricula
  owner to postgres;

create table cer_certificado
(
  id_cer_certificado    serial
    constraint pk_cer_certificado
      primary key,
  id_eje_administrativo integer     not null
    constraint fk_cer_cert_administr_eje_admi
      references eje_administrativo
      on update restrict on delete restrict,
  cod_ins_matricula     integer     not null
    constraint fk_cer_cert_matricula_ins_matr
      references ins_matricula
      on update restrict on delete restrict,
  tipo_certificado      varchar(35) not null,
  estado_certificado    varchar(35) not null,
  fecha_reg             timestamp   not null,
  fecha_mod             timestamp,
  user_reg              integer     not null,
  user_mod              integer
);

comment on column cer_certificado.estado_certificado is 'Estado de certificado';

comment on column cer_certificado.fecha_reg is 'Fecha de registro';

comment on column cer_certificado.fecha_mod is 'Fecha de modificación';

comment on column cer_certificado.user_reg is 'Usuario que registró';

comment on column cer_certificado.user_mod is 'Usuario que modificó';

alter table cer_certificado
  owner to postgres;

create unique index cer_certificado_pk
  on cer_certificado (id_cer_certificado);

create index administrativo_emite_certificad
  on cer_certificado (id_eje_administrativo);

create index matricula_obtiene_certificados_
  on cer_certificado (cod_ins_matricula);

create table cer_titulacion
(
  id_cer_titulacion serial
    constraint pk_cer_titulacion
      primary key,
  cod_ins_matricula integer     not null
    constraint fk_cer_titu_matricula_ins_matr
      references ins_matricula
      on update restrict on delete restrict,
  cod_titulo        varchar(25) not null,
  uri_titulo        varchar(1)  not null,
  estado_titulacion varchar(35) not null,
  fecha_reg         timestamp   not null,
  fecha_mod         timestamp,
  user_reg          integer     not null,
  user_mod          integer
);

comment on column cer_titulacion.estado_titulacion is 'Estado de titulacion';

comment on column cer_titulacion.fecha_reg is 'Fecha de registro';

comment on column cer_titulacion.fecha_mod is 'Fecha de modificación';

comment on column cer_titulacion.user_reg is 'Usuario que registró';

comment on column cer_titulacion.user_mod is 'Usuario que modificó';

alter table cer_titulacion
  owner to postgres;

create unique index cer_titulacion_pk
  on cer_titulacion (id_cer_titulacion);

create index matricula_obtiene_titulacion_fk
  on cer_titulacion (cod_ins_matricula);

create table eje_programacion
(
  id_eje_programacion      serial
    constraint pk_eje_programacion
      primary key,
  cod_ins_matricula        integer     not null
    constraint fk_eje_prog_matricula_ins_matr
      references ins_matricula
      on update restrict on delete restrict,
  id_eje_cronograma_modulo integer
    constraint fk_eje_prog_cronogram_eje_cron
      references eje_cronograma_modulo
      on update restrict on delete restrict,
  observacion              varchar(255),
  fecha_programacion       date        not null,
  estado_programacion      varchar(35) not null,
  nota_final               integer,
  fecha_reg                timestamp   not null,
  fecha_mod                timestamp,
  user_reg                 integer     not null,
  user_mod                 integer
);

comment on column eje_programacion.estado_programacion is 'Estado de programacion';

comment on column eje_programacion.fecha_reg is 'Fecha de registro';

comment on column eje_programacion.fecha_mod is 'Fecha de modificación';

comment on column eje_programacion.user_reg is 'Usuario que registró';

comment on column eje_programacion.user_mod is 'Usuario que modificó';

alter table eje_programacion
  owner to postgres;

create table eje_calificacion
(
  id_eje_calificacion  serial
    constraint pk_eje_calificacion
      primary key,
  id_eje_criterio_eval integer     not null
    constraint fk_eje_cali_calificac_eje_crit
      references eje_criterio_eval
      on update restrict on delete restrict,
  id_eje_programacion  integer     not null
    constraint fk_eje_cali_programac_eje_prog
      references eje_programacion
      on update restrict on delete restrict,
  nota                 numeric(5, 2),
  estado_calificacion  varchar(35) not null,
  fecha_reg            timestamp   not null,
  fecha_mod            timestamp,
  user_reg             integer     not null,
  user_mod             integer
);

comment on column eje_calificacion.estado_calificacion is 'Estado de calificacion';

comment on column eje_calificacion.fecha_reg is 'Fecha de registro';

comment on column eje_calificacion.fecha_mod is 'Fecha de modificación';

comment on column eje_calificacion.user_reg is 'Usuario que registró';

comment on column eje_calificacion.user_mod is 'Usuario que modificó';

alter table eje_calificacion
  owner to postgres;

create unique index eje_calificacion_pk
  on eje_calificacion (id_eje_calificacion);

create index calificacion_en_base_a_criterio
  on eje_calificacion (id_eje_criterio_eval);

create index programacion_tiene_calificacion
  on eje_calificacion (id_eje_programacion);

create unique index eje_programacion_pk
  on eje_programacion (id_eje_programacion);

create index matricula_tiene_programaciones_
  on eje_programacion (cod_ins_matricula);

create index cronograma_modulo_recibe_progra
  on eje_programacion (id_eje_cronograma_modulo);

create table fin_obligacion_pago
(
  id_fin_obligacion_pago serial
    constraint pk_fin_obligacion_pago
      primary key,
  cod_ins_matricula      integer        not null
    constraint fk_fin_obli_matricula_ins_matr
      references ins_matricula
      on update restrict on delete restrict,
  id_fin_concepto_pago   integer        not null
    constraint fk_fin_obli_obligacio_fin_conc
      references fin_concepto_pago
      on update restrict on delete restrict,
  id_aca_parametro       integer
    constraint fk_fin_obli_obligacio_aca_para
      references aca_parametro_programa
      on update restrict on delete restrict,
  monto_sin_descuento    numeric(10, 2) not null,
  monto_con_descuento    numeric(10, 2) not null,
  observacion            varchar(500),
  estado_obligacion_pago varchar(35)    not null,
  fecha_reg              timestamp      not null,
  fecha_mod              timestamp,
  user_reg               integer        not null,
  user_mod               integer
);

comment on column fin_obligacion_pago.estado_obligacion_pago is 'Estado de obligacion_pago';

comment on column fin_obligacion_pago.fecha_reg is 'Fecha de registro';

comment on column fin_obligacion_pago.fecha_mod is 'Fecha de modificación';

comment on column fin_obligacion_pago.user_reg is 'Usuario que registró';

comment on column fin_obligacion_pago.user_mod is 'Usuario que modificó';

alter table fin_obligacion_pago
  owner to postgres;

create table cer_impresion
(
  id_cer_impresion       serial
    constraint pk_cer_impresion
      primary key,
  id_cer_certificado     integer      not null
    constraint fk_cer_impr_certifica_cer_cert
      references cer_certificado
      on update restrict on delete restrict,
  id_fin_obligacion_pago integer      not null
    constraint fk_cer_impr_obligacio_fin_obli
      references fin_obligacion_pago
      on update restrict on delete restrict,
  num_impresion          integer      not null,
  hash_impresion         varchar(255) not null,
  estado_impresion       varchar(35)  not null,
  fecha_reg              timestamp    not null,
  fecha_mod              timestamp,
  user_reg               integer      not null,
  user_mod               integer
);

comment on column cer_impresion.estado_impresion is 'Estado de impresion';

comment on column cer_impresion.fecha_reg is 'Fecha de registro';

comment on column cer_impresion.fecha_mod is 'Fecha de modificación';

comment on column cer_impresion.user_reg is 'Usuario que registró';

comment on column cer_impresion.user_mod is 'Usuario que modificó';

alter table cer_impresion
  owner to postgres;

create unique index cer_impresion_pk
  on cer_impresion (id_cer_impresion);

create index certificado_registra_impresione
  on cer_impresion (id_cer_certificado);

create index obligacion_pago_financia_impres
  on cer_impresion (id_fin_obligacion_pago);

create table fin_detalle_pago
(
  id_fin_detalle_pago    serial
    constraint pk_fin_detalle_pago
      primary key,
  id_fin_transaccion     integer       not null
    constraint fk_fin_deta_transacci_fin_tran
      references fin_transaccion
      on update restrict on delete restrict,
  id_fin_obligacion_pago integer       not null
    constraint fk_fin_deta_obligacio_fin_obli
      references fin_obligacion_pago
      on update restrict on delete restrict,
  monto_aplicado         numeric(8, 2) not null,
  estado_detalle_pago    varchar(35)   not null,
  fecha_reg              timestamp     not null,
  fecha_mod              timestamp,
  user_reg               integer       not null,
  user_mod               integer
);

comment on column fin_detalle_pago.estado_detalle_pago is 'Estado de detalle_pago';

comment on column fin_detalle_pago.fecha_reg is 'Fecha de registro';

comment on column fin_detalle_pago.fecha_mod is 'Fecha de modificación';

comment on column fin_detalle_pago.user_reg is 'Usuario que registró';

comment on column fin_detalle_pago.user_mod is 'Usuario que modificó';

alter table fin_detalle_pago
  owner to postgres;

create unique index fin_detalle_pago_pk
  on fin_detalle_pago (id_fin_detalle_pago);

create index transaccion_se_aplica_mediante_
  on fin_detalle_pago (id_fin_transaccion);

create index obligacion_pago_recibe_detalles
  on fin_detalle_pago (id_fin_obligacion_pago);

create unique index fin_obligacion_pago_pk
  on fin_obligacion_pago (id_fin_obligacion_pago);

create index matricula_tiene_obligaciones_pa
  on fin_obligacion_pago (cod_ins_matricula);

create index obligacion_pago_por_concepto_fk
  on fin_obligacion_pago (id_fin_concepto_pago);

create index obligacion_pago_aplicada_con_pa
  on fin_obligacion_pago (id_aca_parametro);

create unique index ins_matricula_pk
  on ins_matricula (cod_ins_matricula);

create index grupo_inscribe_matriculas_fk
  on ins_matricula (id_ins_grupo);

create index persona_se_matricula_en_grupo_f
  on ins_matricula (id_prs_persona);

create index matricula_tiene_usuario_fk
  on ins_matricula (id_seg_usuario);

create table seg_designa
(
  id_seg_tarea   integer     not null
    constraint fk_seg_desi_tarea_se__seg_tare
      references seg_tarea
      on update restrict on delete restrict,
  id_seg_usuario integer     not null
    constraint fk_seg_desi_usuario_r_seg_usua
      references seg_usuario
      on update restrict on delete restrict,
  estado_designa varchar(35) not null,
  fecha_reg      timestamp   not null,
  fecha_mod      timestamp,
  user_reg       integer     not null,
  user_mod       integer,
  constraint pk_seg_designa
    primary key (id_seg_tarea, id_seg_usuario)
);

comment on column seg_designa.estado_designa is 'Estado de designa';

comment on column seg_designa.fecha_reg is 'Fecha de registro';

comment on column seg_designa.fecha_mod is 'Fecha de modificación';

comment on column seg_designa.user_reg is 'Usuario que registró';

comment on column seg_designa.user_mod is 'Usuario que modificó';

alter table seg_designa
  owner to postgres;

create unique index seg_designa_pk
  on seg_designa (id_seg_tarea, id_seg_usuario);

create index usuario_recibe_tareas_designada
  on seg_designa (id_seg_usuario);

create index tarea_se_designa_a_usuario_fk
  on seg_designa (id_seg_tarea);

create table seg_ocupa
(
  id_seg_rol     integer     not null
    constraint fk_seg_ocup_rol_se_oc_seg_rol
      references seg_rol
      on update restrict on delete restrict,
  id_seg_usuario integer     not null
    constraint fk_seg_ocup_usuario_o_seg_usua
      references seg_usuario
      on update restrict on delete restrict,
  estado_ocupa   varchar(35) not null,
  fecha_reg      timestamp   not null,
  fecha_mod      timestamp,
  user_reg       integer     not null,
  user_mod       integer,
  constraint pk_seg_ocupa
    primary key (id_seg_rol, id_seg_usuario)
);

comment on column seg_ocupa.estado_ocupa is 'Estado de ocupa';

comment on column seg_ocupa.fecha_reg is 'Fecha de registro';

comment on column seg_ocupa.fecha_mod is 'Fecha de modificación';

comment on column seg_ocupa.user_reg is 'Usuario que registró';

comment on column seg_ocupa.user_mod is 'Usuario que modificó';

alter table seg_ocupa
  owner to postgres;

create unique index seg_ocupa_pk
  on seg_ocupa (id_seg_rol, id_seg_usuario);

create index usuario_ocupa_fk
  on seg_ocupa (id_seg_usuario);

create index rol_se_ocupa_fk
  on seg_ocupa (id_seg_rol);

create unique index seg_usuario_pk
  on seg_usuario (id_seg_usuario);

create table tgr_monografia
(
  id_tgr_monografia serial
    constraint pk_tgr_monografia
      primary key,
  cod_ins_matricula integer      not null
    constraint fk_tgr_mono_matricula_ins_matr
      references ins_matricula
      on update restrict on delete restrict,
  titulo_monografia varchar(255) not null,
  estado_monografia varchar(35)  not null,
  nota_final        integer      not null,
  fecha_defensa     date,
  archivo_uri       varchar(1),
  fecha_reg         timestamp    not null,
  fecha_mod         timestamp,
  user_reg          integer      not null,
  user_mod          integer
);

comment on column tgr_monografia.estado_monografia is 'Estado de monografia';

comment on column tgr_monografia.fecha_reg is 'Fecha de registro';

comment on column tgr_monografia.fecha_mod is 'Fecha de modificación';

comment on column tgr_monografia.user_reg is 'Usuario que registró';

comment on column tgr_monografia.user_mod is 'Usuario que modificó';

alter table tgr_monografia
  owner to postgres;

create unique index tgr_monografia_pk
  on tgr_monografia (id_tgr_monografia);

create index matricula_presenta_monografias_
  on tgr_monografia (cod_ins_matricula);

create table tgr_revision_monografia
(
  id_tgr_revision_monografia serial
    constraint pk_tgr_revision_monografia
      primary key,
  id_tgr_monografia          integer     not null
    constraint fk_tgr_revi_monografi_tgr_mono
      references tgr_monografia
      on update restrict on delete restrict,
  id_eje_administrativo      integer
    constraint fk_tgr_revi_revisado__eje_admi
      references eje_administrativo
      on update restrict on delete restrict,
  id_eje_docente             integer
    constraint fk_tgr_revi_revisado__eje_doce
      references eje_docente
      on update restrict on delete restrict,
  fecha_hora_designacion     date        not null,
  es_aprobador_final         boolean,
  fecha_hora_revision        date,
  estado_revision_monografia varchar(35) not null,
  fecha_reg                  timestamp   not null,
  fecha_mod                  timestamp,
  user_reg                   integer     not null,
  user_mod                   integer
);

comment on column tgr_revision_monografia.estado_revision_monografia is 'Estado de revision_monografia';

comment on column tgr_revision_monografia.fecha_reg is 'Fecha de registro';

comment on column tgr_revision_monografia.fecha_mod is 'Fecha de modificación';

comment on column tgr_revision_monografia.user_reg is 'Usuario que registró';

comment on column tgr_revision_monografia.user_mod is 'Usuario que modificó';

alter table tgr_revision_monografia
  owner to postgres;

create table tgr_observacion_monografia
(
  id_tgr_observacion_monografia serial
    constraint pk_tgr_observacion_monografia
      primary key,
  id_tgr_revision_monografia    integer     not null
    constraint fk_tgr_obse_revision__tgr_revi
      references tgr_revision_monografia
      on update restrict on delete restrict,
  descripcion                   varchar(1)  not null,
  estado_observacion_monografia varchar(35) not null,
  fecha_reg                     timestamp   not null,
  fecha_mod                     timestamp,
  user_reg                      integer     not null,
  user_mod                      integer
);

comment on column tgr_observacion_monografia.estado_observacion_monografia is 'Estado de observacion_monografia';

comment on column tgr_observacion_monografia.fecha_reg is 'Fecha de registro';

comment on column tgr_observacion_monografia.fecha_mod is 'Fecha de modificación';

comment on column tgr_observacion_monografia.user_reg is 'Usuario que registró';

comment on column tgr_observacion_monografia.user_mod is 'Usuario que modificó';

alter table tgr_observacion_monografia
  owner to postgres;

create unique index tgr_observacion_monografia_pk
  on tgr_observacion_monografia (id_tgr_observacion_monografia);

create index revision_monografia_recibe_obse
  on tgr_observacion_monografia (id_tgr_revision_monografia);

create unique index tgr_revision_monografia_pk
  on tgr_revision_monografia (id_tgr_revision_monografia);

create index monografia_es_revisada_fk
  on tgr_revision_monografia (id_tgr_monografia);

create index revisado_por_administrativo_fk
  on tgr_revision_monografia (id_eje_administrativo);

create index revisado_por_un_docente_fk
  on tgr_revision_monografia (id_eje_docente);


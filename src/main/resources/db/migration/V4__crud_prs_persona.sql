create or replace function fn_registrar_persona(
  p_nombre varchar(35),
  p_ap_paterno varchar(55),
  p_ap_materno varchar(55),
  p_ci varchar(20),
  p_nro_celular varchar(20),
  p_correo varchar(55),
  p_fecha_nacimiento date,
  p_user_reg integer
) returns text
  language plpgsql
as
$$
declare
  v_id_persona_registrada integer;
  v_existen               integer;

begin
  --validaciones si uno es null entonces chau, nos salimos de la funcion
  if p_nombre is null or p_ap_paterno is null or p_ap_materno is null
    or p_ci is null or p_nro_celular is null or p_correo is null or p_correo is null
    or p_fecha_nacimiento is null or p_user_reg is null
  then
    raise exception 'Error! Todos los campos deben ser completados';
  end if;

  --luego validar is existe esa persona en la base de datos
  select count(*)
  into v_existen
  from prs_persona
  where ci = p_ci
    and estado_persona = 'ACTIVO';

  if (v_existen > 0) then
    raise exception 'Error! Ya existe una persona registrar con este CI';
  end if;

  --validacion de fechas de nacimiento
  if p_fecha_nacimiento > current_date then
    raise exception 'Error! La fecha de nacimiento no puede ser posterior a dia de hoy';
  end if;

  if (p_fecha_nacimiento > (current_date - interval '4 years')) then
    raise exception 'Error! La persona debe tener al menos 4 años';
  end if;

  --insercion con trims y upper para normalizacion de texto
  insert into prs_persona(nombre, ap_paterno, ap_materno, ci, nro_celular, correo, fecha_nacimiento, estado_persona,
                          fecha_reg, user_reg)
  values (upper(trim(p_nombre)), upper(trim(p_ap_paterno)), upper(trim(p_ap_materno)), upper(trim(p_ci)),
          trim(p_nro_celular), trim(p_correo), p_fecha_nacimiento, 'ACTIVO', now(), p_user_reg)
  returning id_prs_persona
    into v_id_persona_registrada;

  return concat('Persona registrada exitosamente con ID: ' || v_id_persona_registrada);
end;
$$;
select fn_registrar_persona('luis alberto', 'morales ', ' villaca', '13131313', 'NO TENGO XD',
                            'correodeluis@uap.edu.bo', '2002-01-01', 1);
select *
from prs_persona
where id_prs_persona = 1;


create or replace function fn_modificar_persona(
  p_id_prs_persona integer,
  p_nombre varchar(35),
  p_ap_paterno varchar(55),
  p_ap_materno varchar(55),
  p_ci varchar(20),
  p_nro_celular varchar(20),
  p_correo varchar(55),
  p_fecha_nacimiento date,
  p_user_mod integer
) returns text
  language plpgsql
as $$
declare
  v_persona_existe integer;
  v_existen_ci integer;
  v_filas_afectadas integer;
begin
  -- Validaciones si uno es null entonces chau, nos salimos de la funchion
  if p_id_prs_persona is null or p_nombre is null or p_ap_paterno is null or p_ap_materno is null
    or p_ci is null or p_nro_celular is null or p_correo is null
    or p_fecha_nacimiento is null or p_user_mod is null then
    raise exception 'Error! Todos los campos deben ser completados';
  end if;

  -- Validar que la persona exista con el identificador
  select count(*) into v_persona_existe from prs_persona
  where id_prs_persona = p_id_prs_persona and estado_persona = 'ACTIVO';

  if (v_persona_existe = 0) then
    raise exception 'Error! La persona no existe o no está activa';
  end if;

  -- Validar qel CI no este siendo duplicado (menos de la persona actual)
  select count(*) into v_existen_ci from prs_persona
  where ci = p_ci and estado_persona = 'ACTIVO' and id_prs_persona != p_id_prs_persona;

  if (v_existen_ci > 0) then
    raise exception 'Error! Ya existe otra persona registrada con este CI';
  end if;

  -- Validación de fechas de nacimiento
  if p_fecha_nacimiento > current_date then
    raise exception 'Error! La fecha de nacimiento no puede ser posterior al día de hoy';
  end if;

  if (p_fecha_nacimiento > (current_date - interval '4 years')) then
    raise exception 'Error! La persona debe tener al menos 4 años';
  end if;


  update prs_persona
  set
    nombre = upper(trim(p_nombre)),
    ap_paterno = upper(trim(p_ap_paterno)),
    ap_materno = upper(trim(p_ap_materno)),
    ci = upper(trim(p_ci)),
    nro_celular = trim(p_nro_celular),
    correo = trim(p_correo),
    fecha_nacimiento = p_fecha_nacimiento,
    fecha_mod = now(),
    user_mod = p_user_mod
  where id_prs_persona = p_id_prs_persona
    and estado_persona = 'ACTIVO';

  return concat('Persona modificada exitosamente con ID: ' || p_id_prs_persona);
end;
$$;


create or replace view vista_personas_activas as
select id_prs_persona, nombre, ap_paterno, ap_materno, ci, nro_celular, correo, fecha_nacimiento from prs_persona
where estado_persona != 'ELIMINADO';

select * from vista_personas_activas
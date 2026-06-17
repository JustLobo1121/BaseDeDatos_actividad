-- ************************************************************
-- 002-reglas-de-negocio.sql
--
-- se añaden las reglas de negocio
-- ************************************************************

SET search_path TO cine;

-- ... el cambio de esta migración ...

alter table cliente add column correo text not null;

-- funcion(helper) para validar el rut
create or replace function validador_rut(input varchar(9))
    returns boolean as $$
    declare
        rut_limpio varchar;
        rut_cuerpo int;
        dv char(1);
        suma int := 0;
        multiplo int := 2;
        resto int;
        dv_calculado varchar(1);
    begin
        rut_limpio := upper(regexp_replace(input, '[^0-9kk]', '', 'g'));
        if length(rut_limpio) < 2 then
            return false;
        end if;

        dv := substring(rut_limpio from length (rut_limpio) for 1);
        rut_cuerpo := substring(rut_limpio from 1 for length(rut_limpio) - 1);

        while rut_cuerpo > 0 loop
            suma := suma + (rut_cuerpo % 10) * multiplo;
            rut_cuerpo := rut_cuerpo / 10;
            multiplo := multiplo + 1;
            if multiplo = 8 then
                multiplo := 2;
            end if;
        end loop;

        resto := suma % 11;
        resto := 11 - resto;

        if resto = 11 then
            dv_calculado := '0';
        elseif resto = 10 then
            dv_calculado := 'K';
        else
            dv_calculado := resto::varchar;
        end if;

        return dv_calculado = dv;
    exception
        when others then
            return false;
    END;
$$ language plpgsql;

create or replace function fun_trg_validador_rut()
    returns trigger as $$
    begin
        if new.rut is not null then
            if not validador_rut(new.rut) then
                raise exception 'el rut ingresado (%) es invalido', new.rut;
            end if;
        end if;
        return new;
    end;
$$ language plpgsql;
-- trigger
create trigger trg_validar_rut
before insert or update on cliente for each row 
execute function fun_trg_validador_rut();

-- funcion para validar el correo
create or replace function validador_correo()
    returns trigger as $$
    begin
        if new.correo is not null then
            if new.correo !~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' then
                raise exception 'El formato del correo % es erroneo', new.correo;
            end if;
        end if;
        return new;
    end;
$$ language plpgsql;
-- trigger
create trigger trg_validar_correo
before insert or update on cliente for each row
execute function validador_correo();

-- funcion para asiento unico en la misma funcion
create or replace function validador_asientos()
    returns trigger as $$
    begin
        if exists(
            select 1 from entrada 
            where id_funcion = new.id_funcion 
            and id_asiento = new.id_asiento 
            and id_asiento is distinct from new.id_asiento
        ) then
            raise exception 'asiento no disponible: el asiendo de id (%) ya fue reservado', new.id_asiento;
        end if;
        return new;
    end;
$$ language plpgsql;
-- trigger
create trigger trg_validar_asientos
before insert or update on entrada for each row
execute function validador_asientos();

-- funcion para no exceder limite de sala en una funcion | sobreventa
create or replace function limitador_sala()
    returns trigger as $$
    declare
        capacidad int;
        entradas_vendidas int;
    begin
        select s.capacidad into capacidad from sala s
        join funcion f on s.id_sala = f.id_sala
        where f.id_funcion = new.id_funcion;

        select count(*) into entradas_vendidas from entrada
        where id_funcion = new.id_funcion;

        if entradas_vendidas >= capacidad then
            raise exception 'venta bloqueada: la funcion alcanzo la capacidad maxima de la sala (%)',capacidad;
        end if;
        return new;
    end;
$$ language plpgsql;
-- trigger
create trigger trg_limitador_sala
before insert or update on entrada for each row
execute function limitador_sala();

-- funcion para no solapar una sala con 2 funciones
create or replace function verificar_horario()
    returns trigger as $$
    begin
        if exists(
            select 1 from funcion
            where id_sala = new.id_sala
            and id_funcion is distinct from new.id_funcion
            and new.hora_inicio < hora_termino
            and new.hora_termino > hora_inicio
        ) then
            raise exception 'choque de horario: la sala ya esta con una funcion activa en el bloque de hora';
        end if;
    end;
$$ language plpgsql;
-- trigger
create trigger trg_verificar_horario
before insert or update on funcion for each row
execute function verificar_horario();

-- ... fin del cambio ...

INSERT INTO schema_migrations (version) VALUES ('002-reglas-de-negocio');
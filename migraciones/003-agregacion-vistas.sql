-- ************************************************************
-- 003-agregacion-vistas.sql
--
-- se agrega las vistas
-- ************************************************************

SET search_path TO cine;

-- llenado de sala
create or replace view vista_llenado_sala as 
    select
        s.nombre_sala,
        s.capacidad,
        coalesce(
            round(
                (count(e.id_entrada)::numeric / nullif(s.capacidad * count(distinct f.id_funcion), 0)) * 100, 2
            ), 0
        ) as porcentaje_llenado
    from sala s
    left join funcion f on s.id_sala = f.id_sala
    left join entrada e on f.id_funcion = e.id_funcion
    group by 
        s.id_sala,
        s.nombre_sala,
        s.capacidad;

-- ventas por funcion
create or replace view vista_venta_funcion as
    with venta_por_funcion as (
        SELECT 
            f.id_funcion,
            p.titulo AS pelicula,
            s.nombre_sala AS sala,
            f.hora_inicio AS fecha_hora,
            DATE(f.hora_inicio) AS fecha_dia,
            COUNT(e.id_entrada) * 5000 AS monto_total_vendido
        FROM Funcion f
        JOIN Pelicula p ON f.id_pelicula = p.id_pelicula
        JOIN Sala s ON f.id_sala = s.id_sala
        LEFT JOIN Entrada e ON f.id_funcion = e.id_funcion
        GROUP BY 
            f.id_funcion, 
            p.titulo, 
            s.nombre_sala, 
            f.hora_inicio
    ),
    venta_por_dia as (
        select fecha_dia,
            sum(monto_total_vendido) as profit_total_dia
        from venta_por_funcion
        group by fecha_dia
    )
    select
        v.pelicula,
        v.sala,
        v.fecha_hora,
        v.monto_total_vendido,
        coalesce(
            round(
                (v.monto_total_vendido::numeric / nullif(vd.profit_total_dia, 0)) * 100, 2
            ), 0
        ) as porcentaje_profit_dia
    from venta_por_funcion v
    join venta_por_dia vd on v.fecha_dia = vd.fecha_dia;

-- disponibilidad por funcion
create or replace view disponibilidad_por_funcion as
    SELECT 
        f.id_funcion,
        p.titulo AS pelicula,
        s.nombre_sala AS sala,
        f.hora_inicio,
        (s.capacidad - COUNT(e.id_entrada)) AS asientos_disponibles,
            (
                SELECT STRING_AGG(a.numero::text, ', ' ORDER BY a.numero)
                FROM Asiento a
                WHERE a.id_sala = f.id_sala
                AND a.id_asiento NOT IN (
                    SELECT e2.id_asiento 
                    FROM Entrada e2 
                    WHERE e2.id_funcion = f.id_funcion
                )
            ) AS identificadores_asientos_disponibles,
        COUNT(e.id_entrada) AS entradas_vendidas,
        COUNT(e.id_entrada) * 5000 AS recaudacion_total

    FROM Funcion f
    JOIN Sala s ON f.id_sala = s.id_sala
    JOIN Pelicula p ON f.id_pelicula = p.id_pelicula
    LEFT JOIN Entrada e ON f.id_funcion = e.id_funcion
    GROUP BY 
        f.id_funcion, 
        p.titulo, 
        s.nombre_sala, 
        f.hora_inicio, 
        s.capacidad, 
        f.id_sala;

INSERT INTO schema_migrations (version) VALUES ('003-agregacion-vistas');
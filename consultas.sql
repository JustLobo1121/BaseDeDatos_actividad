-- consultas
set search_path to cine;
-- top 3 mas vendidas
select 
	f.id_funcion,
	p.titulo as pelicula,
	count(e.id_entrada) * 5000 as monto_total
from sala s
join funcion f on f.id_sala = s.id_sala
join pelicula p on f.id_pelicula = p.id_pelicula 
left join entrada e on f.id_funcion = e.id_funcion
group by
	f.id_funcion,
	p.id_pelicula
order by monto_total desc;

-- mayor % de venta por capacidad de sala
select
	f.id_funcion,
	p.titulo as pelicula,
	s.id_sala,
	count(e.id_entrada) * 5000 as vendido,
	s.capacidad,
	coalesce(
		round(
		(count(e.id_entrada)::numeric / nullif(s.capacidad * count(distinct f.id_funcion ),0)) *100,2
		),0
	) as porcentaje_llenado
from sala s
join funcion f on s.id_sala = f.id_sala
join pelicula p on f.id_pelicula = p.id_pelicula 
left join entrada e on f.id_funcion = e.id_funcion
group by
	f.id_funcion,
	p.titulo,
	s.id_sala
order by vendido desc;

-- cliente con mas compras por funcion
SELECT DISTINCT ON (f.id_funcion)
    f.id_funcion,
    p.titulo AS pelicula,
    c.nombre,
    COUNT(e.id_entrada) AS cantidad_entradas
FROM cliente c
JOIN entrada e ON c.rut = e.id_cliente
JOIN funcion f ON e.id_funcion = f.id_funcion
JOIN pelicula p ON f.id_pelicula = p.id_pelicula
GROUP BY 
    f.id_funcion, 
    p.titulo, 
    c.rut, 
    c.nombre
ORDER BY 
    f.id_funcion, 
    cantidad_entradas DESC;

-- venta por sala y por dia
SELECT 
    s.nombre_sala, 
    DATE(f.hora_inicio) AS dia, 
    COUNT(e.id_entrada) AS cantidad_entradas_vendidas
FROM sala s
JOIN funcion f ON s.id_sala = f.id_sala
JOIN entrada e ON f.id_funcion = e.id_funcion
GROUP BY 
    s.nombre_sala, 
    DATE(f.hora_inicio)
ORDER BY 
    dia ASC, 
    cantidad_entradas_vendidas DESC;

-- funciones sin entrada vendida
SELECT 
    f.id_funcion, 
    p.titulo, 
    f.hora_inicio
FROM funcion f
JOIN pelicula p ON f.id_pelicula = p.id_pelicula
LEFT JOIN entrada e ON f.id_funcion = e.id_funcion
GROUP BY 
    f.id_funcion, 
    p.titulo, 
    f.hora_inicio
HAVING 
    COUNT(e.id_entrada) = 0
ORDER BY 
    f.hora_inicio ASC;

-- horario inicio con mas ventas(peak?)
SELECT 
    f.hora_inicio, 
    COUNT(e.id_entrada) AS cantidad_ventas
FROM funcion f
JOIN entrada e ON f.id_funcion = e.id_funcion
GROUP BY 
    f.hora_inicio
ORDER BY 
    cantidad_ventas DESC
LIMIT 1;
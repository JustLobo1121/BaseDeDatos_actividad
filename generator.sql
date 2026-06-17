-- generador de datos falsos
SET search_path TO cine;

INSERT INTO pelicula (id_pelicula, titulo) VALUES
(1, 'El Padrino'),
(2, 'smile'),
(3, 'it');

INSERT INTO sala (id_sala, nombre_sala, capacidad) VALUES
(1, 'Sala IMAX', 10),
(2, 'Sala 2D Premium', 15);

INSERT INTO cliente (rut, nombre, correo) VALUES
('11111111-1', 'john doe', 'john.doe@email.com'),
('22222222-2', 'jane doe', 'jane.doe@email.com'),
('33333333-3', 'jose juan', 'jose.juan@email.com'),
('44444444-4', 'a a', 'a.a@email.com'),
('55555555-5', '1 1', '1.1@email.com');

INSERT INTO asiento (id_asiento, id_sala, numero)
SELECT s, 1, s FROM generate_series(1, 10) AS s;

INSERT INTO asiento (id_asiento, id_sala, numero)
SELECT s + 10, 2, s FROM generate_series(1, 15) AS s;

INSERT INTO funcion (id_funcion, id_pelicula, hora_inicio, hora_termino, id_sala) VALUES
(1, 2, '2026-07-15 14:00:00', '2026-07-15 17:00:00', 1),
(2, 3, '2026-07-15 18:00:00', '2026-07-15 21:00:00', 1),
(3, 1, '2026-07-15 16:00:00', '2026-07-15 19:30:00', 2);

INSERT INTO entrada (id_entrada, id_funcion, id_cliente, id_asiento) VALUES
(1, 1, '11111111-1', 1),
(2, 1, '22222222-2', 2),
(3, 1, '33333333-3', 3),
(4, 2, '44444444-4', 1),
(5, 2, '55555555-5', 2),
(6, 3, '11111111-1', 11),
(7, 3, '22222222-2', 12);

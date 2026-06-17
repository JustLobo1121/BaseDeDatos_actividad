-- ************************************************************
-- 000-modelo-inicial.sql
--
-- Migración inicial: crea el schema, la tabla de control de
-- migraciones y el modelo base del cine.
-- ************************************************************

-- Crea el schema y trabaja dentro de él.
CREATE SCHEMA IF NOT EXISTS cine;
SET search_path TO cine;

-- Tabla de control de versiones del esquema.
CREATE TABLE schema_migrations (
    version TEXT PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT now()
);

-- ... aquí van las tablas de tu modelo ...

CREATE TABLE "cliente" (
  "rut" TEXT PRIMARY KEY,
  "nombre" TEXT NOT NULL,
  "correo" TEXT NOT NULL
);

CREATE TABLE "pelicula" (
  "id_pelicula" SERIAL PRIMARY KEY,
  "titulo" TEXT NOT NULL,
  "categoria" TEXT NOT NULL,
  "duracion" TEXT NOT NULL
);

CREATE TABLE "funcion" (
  "id_funcion" SERIAL PRIMARY KEY,
  "id_pelicula" INTEGER NOT NULL,
  "hora_inicio" TIMESTAMP NOT NULL,
  "hora_termino" TIMESTAMP NOT NULL
);

CREATE INDEX "idx_funcion__id_pelicula" ON "funcion" ("id_pelicula");

ALTER TABLE "funcion" ADD CONSTRAINT "fk_funcion__id_pelicula" FOREIGN KEY ("id_pelicula") REFERENCES "pelicula" ("id_pelicula") ON DELETE CASCADE;

CREATE TABLE "sala" (
  "id_sala" SERIAL PRIMARY KEY,
  "nombre_sala" TEXT NOT NULL,
  "capacidad" INTEGER NOT NULL
);

CREATE TABLE "asiento" (
  "id_asiento" SERIAL PRIMARY KEY,
  "id_sala" INTEGER NOT NULL,
  "numero" INTEGER NOT NULL,
  "fila" TEXT NOT NULL
);

CREATE INDEX "idx_asiento__id_sala" ON "asiento" ("id_sala");

ALTER TABLE "asiento" ADD CONSTRAINT "fk_asiento__id_sala" FOREIGN KEY ("id_sala") REFERENCES "sala" ("id_sala") ON DELETE CASCADE;

CREATE TABLE "entrada" (
  "id_entrada" SERIAL PRIMARY KEY,
  "id_funcion" INTEGER NOT NULL,
  "id_cliente" TEXT NOT NULL,
  "id_asiento" INTEGER NOT NULL
);

CREATE INDEX "idx_entrada__id_asiento" ON "entrada" ("id_asiento");

CREATE INDEX "idx_entrada__id_cliente" ON "entrada" ("id_cliente");

CREATE INDEX "idx_entrada__id_funcion" ON "entrada" ("id_funcion");

ALTER TABLE "entrada" ADD CONSTRAINT "fk_entrada__id_asiento" FOREIGN KEY ("id_asiento") REFERENCES "asiento" ("id_asiento") ON DELETE CASCADE;

ALTER TABLE "entrada" ADD CONSTRAINT "fk_entrada__id_cliente" FOREIGN KEY ("id_cliente") REFERENCES "cliente" ("rut") ON DELETE CASCADE;

ALTER TABLE "entrada" ADD CONSTRAINT "fk_entrada__id_funcion" FOREIGN KEY ("id_funcion") REFERENCES "funcion" ("id_funcion") ON DELETE CASCADE;

CREATE TABLE "funcion_sala" (
  "funcion" INTEGER NOT NULL,
  "sala" INTEGER NOT NULL,
  PRIMARY KEY ("funcion", "sala")
);

CREATE INDEX "idx_funcion_sala" ON "funcion_sala" ("sala");

ALTER TABLE "funcion_sala" ADD CONSTRAINT "fk_funcion_sala__funcion" FOREIGN KEY ("funcion") REFERENCES "funcion" ("id_funcion");

ALTER TABLE "funcion_sala" ADD CONSTRAINT "fk_funcion_sala__sala" FOREIGN KEY ("sala") REFERENCES "sala" ("id_sala");

-- Registro de versión si la migración corre con éxito.

INSERT INTO schema_migrations (version) VALUES ('000-modelo-inicial');

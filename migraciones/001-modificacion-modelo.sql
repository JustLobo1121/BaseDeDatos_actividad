-- ************************************************************
-- 001-modificacion-modelo.sql
--
-- Modificacion del modelo acorde al cliente
-- ************************************************************

SET search_path TO cine;

ALTER TABLE "cliente" DROP COLUMN "correo";

ALTER TABLE "pelicula" DROP COLUMN "categoria", DROP COLUMN "duracion";

ALTER TABLE "asiento" DROP COLUMN "fila";

DROP TABLE IF EXISTS "funcion_sala";

ALTER TABLE "funcion" ADD COLUMN "id_sala" INTEGER NOT NULL;
CREATE INDEX "idx_funcion__id_sala" ON "funcion" ("id_sala");
ALTER TABLE "funcion" ADD CONSTRAINT "fk_funcion__id_sala" FOREIGN KEY ("id_sala") REFERENCES "sala" ("id_sala") ON DELETE CASCADE;

-- punto de version
INSERT INTO schema_migrations (version) VALUES ('001-modificacion-modelo');
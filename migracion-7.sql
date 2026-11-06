-- Pegar en Supabase > SQL Editor > Run (después de migracion-6.sql)
-- Ubicación aproximada (municipio) para el mapa y la búsqueda por distancia
alter table profiles add column if not exists lat double precision;
alter table profiles add column if not exists lng double precision;

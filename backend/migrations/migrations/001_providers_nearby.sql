-- =============================================================================
-- Migration: providers_nearby — busca de prestadores por raio geográfico
-- Execução: Supabase SQL Editor (Dashboard) ou CLI
-- Requer: extensão PostGIS ativada no projeto Supabase
-- =============================================================================

-- 1. Ativa a extensão PostGIS (idempotente)
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Adiciona coluna de geometria na tabela providers (idempotente)
ALTER TABLE providers
  ADD COLUMN IF NOT EXISTS location geometry(Point, 4326);

-- 3. Índice espacial GIST para performance das consultas por raio
CREATE INDEX IF NOT EXISTS providers_location_gist
  ON providers USING GIST (location);

-- 4. Trigger: mantém `location` sincronizado com latitude/longitude
--    Disparado automaticamente em INSERT e UPDATE quando lat/lng mudam.
CREATE OR REPLACE FUNCTION sync_provider_location()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.location := ST_SetSRID(
      ST_MakePoint(NEW.longitude, NEW.latitude),
      4326
    );
  ELSE
    NEW.location := NULL;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_provider_location ON providers;
CREATE TRIGGER trg_sync_provider_location
  BEFORE INSERT OR UPDATE OF latitude, longitude
  ON providers
  FOR EACH ROW
  EXECUTE FUNCTION sync_provider_location();

-- 5. Sincroniza registros existentes (executa uma vez na migration)
UPDATE providers
SET location = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;


CREATE OR REPLACE FUNCTION providers_nearby(
  p_lat       FLOAT,
  p_lng       FLOAT,
  p_radius_km FLOAT DEFAULT 10,
  p_page      INT   DEFAULT 1,
  p_limit     INT   DEFAULT 10
)
RETURNS TABLE (
  id          UUID,
  distance_km FLOAT
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    p.id,
    ROUND(
      (ST_Distance(
        p.location::geography,
        ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
      ) / 1000.0)::numeric,
      2
    )::float AS distance_km
  FROM providers p
  WHERE
    p.is_active = true
    AND p.location IS NOT NULL
    AND ST_DWithin(
      p.location::geography,
      ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
      p_radius_km * 1000   -- converte km → metros (ST_DWithin usa metros com geography)
    )
  ORDER BY
    p.location::geography <-> ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
  LIMIT  p_limit
  OFFSET (p_page - 1) * p_limit;
$$;

-- Permissão para o service_role (usado pelo adminClient do Supabase)
GRANT EXECUTE ON FUNCTION providers_nearby(FLOAT, FLOAT, FLOAT, INT, INT)
  TO service_role;


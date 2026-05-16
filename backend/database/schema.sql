-- Buscaí Database Schema
-- Execute no Supabase SQL Editor

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================================
-- TABELAS PRINCIPAIS
-- ============================================================

-- Tabela de usuários (estende auth.users do Supabase)
CREATE TABLE users (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT NOT NULL,
  role          TEXT NOT NULL CHECK (role IN ('morador', 'prestador')),
  phone         TEXT,
  cpf           TEXT,
  neighborhood  TEXT,
  city          TEXT,
  state         TEXT,
  bio           TEXT,
  avatar_url    TEXT,
  is_active     BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de categorias de serviço
CREATE TABLE categories (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name       TEXT NOT NULL,
  slug       TEXT NOT NULL UNIQUE,
  icon_name  TEXT,
  color_hex  TEXT DEFAULT '#6B7280',
  is_active  BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de tags
CREATE TABLE tags (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name       TEXT NOT NULL,
  slug       TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de posts de serviço
CREATE TABLE posts (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_id  UUID REFERENCES categories(id),
  title        TEXT NOT NULL,
  description  TEXT,
  price_from   NUMERIC(10, 2),
  price_to     NUMERIC(10, 2),
  whatsapp     TEXT NOT NULL,
  neighborhood TEXT,
  city         TEXT,
  state        TEXT,
  views_count  INTEGER DEFAULT 0,
  rating_avg   FLOAT4 DEFAULT 0,
  rating_count INTEGER DEFAULT 0,
  status       TEXT NOT NULL DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo', 'pausado')),
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de fotos dos posts
CREATE TABLE post_photos (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id     UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  storage_url TEXT NOT NULL,
  caption     TEXT,
  sort_order  INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de relação post-tags (muitos-para-muitos)
CREATE TABLE post_tags (
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  tag_id  UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (post_id, tag_id)
);

-- Tabela de favoritos
CREATE TABLE favorites (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, post_id)
);

-- Tabela de avaliações de posts
CREATE TABLE reviews (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id     UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  rating      INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (reviewer_id, post_id)
);

-- Tabela de prestadores de serviço
CREATE TABLE providers (
  id           UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  description  TEXT,
  category_id  UUID REFERENCES categories(id),
  whatsapp     TEXT NOT NULL,
  neighborhood TEXT NOT NULL,
  city         TEXT,
  state        TEXT,
  schedule     TEXT,
  latitude     FLOAT8,
  longitude    FLOAT8,
  rating_avg   FLOAT4 DEFAULT 0,
  rating_count INTEGER DEFAULT 0,
  is_active    BOOLEAN DEFAULT TRUE,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de imagens do portfólio do prestador
CREATE TABLE portfolio_images (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
  url         TEXT NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de anúncios
CREATE TABLE ads (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title       TEXT NOT NULL,
  image_url   TEXT,
  link_url    TEXT,
  status      TEXT NOT NULL DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo')),
  impressions INTEGER DEFAULT 0,
  clicks      INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de assinaturas
CREATE TABLE subscriptions (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  plan       TEXT NOT NULL DEFAULT 'free' CHECK (plan IN ('free', 'premium')),
  status     TEXT NOT NULL DEFAULT 'ativo' CHECK (status IN ('ativo', 'cancelado')),
  max_posts  INTEGER NOT NULL DEFAULT 1,
  max_photos INTEGER NOT NULL DEFAULT 3,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- DADOS INICIAIS
-- ============================================================

INSERT INTO categories (name, slug, icon_name, color_hex) VALUES
  ('Manutenção',  'manutencao', 'build',                  '#F59E0B'),
  ('Estética',    'estetica',   'face',                   '#EC4899'),
  ('Automotivo',  'automotivo', 'directions_car',         '#3B82F6'),
  ('Limpeza',     'limpeza',    'cleaning_services',      '#10B981'),
  ('Elétrica',    'eletrica',   'electrical_services',    '#F97316'),
  ('Hidráulica',  'hidraulica', 'plumbing',               '#6366F1'),
  ('Informática', 'informatica','computer',               '#8B5CF6'),
  ('Outros',      'outros',     'miscellaneous_services', '#6B7280');

-- ============================================================
-- FUNÇÕES E TRIGGERS
-- ============================================================

-- Atualiza campo updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_providers_updated_at
  BEFORE UPDATE ON providers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_ads_updated_at
  BEFORE UPDATE ON ads
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

ALTER TABLE users           ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories      ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags             ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts            ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_photos      ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_tags        ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites        ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews          ENABLE ROW LEVEL SECURITY;
ALTER TABLE providers        ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE ads              ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions    ENABLE ROW LEVEL SECURITY;

-- Leitura pública
CREATE POLICY "users_select_public"     ON users           FOR SELECT USING (true);
CREATE POLICY "categories_select_public" ON categories     FOR SELECT USING (true);
CREATE POLICY "tags_select_public"      ON tags            FOR SELECT USING (true);
CREATE POLICY "posts_select_public"     ON posts           FOR SELECT USING (status = 'ativo');
CREATE POLICY "post_photos_select_public" ON post_photos   FOR SELECT USING (true);
CREATE POLICY "post_tags_select_public" ON post_tags       FOR SELECT USING (true);
CREATE POLICY "reviews_select_public"   ON reviews         FOR SELECT USING (true);
CREATE POLICY "providers_select_public" ON providers       FOR SELECT USING (is_active = true);
CREATE POLICY "portfolio_select_public" ON portfolio_images FOR SELECT USING (true);
CREATE POLICY "ads_select_public"       ON ads             FOR SELECT USING (status = 'ativo');

-- Usuários: escrita pelo próprio
CREATE POLICY "users_insert_own" ON users FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "users_update_own" ON users FOR UPDATE USING (auth.uid() = id);

-- Posts: escrita pelo dono
CREATE POLICY "posts_insert_own" ON posts
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "posts_update_own" ON posts
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "posts_delete_own" ON posts
  FOR DELETE USING (auth.uid() = user_id);

-- Fotos: escrita pelo dono do post
CREATE POLICY "post_photos_insert_own" ON post_photos
  FOR INSERT WITH CHECK (auth.uid() = (SELECT user_id FROM posts WHERE id = post_id));
CREATE POLICY "post_photos_delete_own" ON post_photos
  FOR DELETE USING (auth.uid() = (SELECT user_id FROM posts WHERE id = post_id));

-- Favoritos: acesso pelo próprio usuário
CREATE POLICY "favorites_select_own" ON favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "favorites_insert_own" ON favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "favorites_delete_own" ON favorites FOR DELETE USING (auth.uid() = user_id);

-- Avaliações: criação autenticada, deleção pelo próprio
CREATE POLICY "reviews_insert_auth" ON reviews
  FOR INSERT WITH CHECK (auth.uid() = reviewer_id);
CREATE POLICY "reviews_delete_own" ON reviews
  FOR DELETE USING (auth.uid() = reviewer_id);

-- Prestadores: escrita pelo próprio
CREATE POLICY "providers_insert_own" ON providers FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "providers_update_own" ON providers FOR UPDATE USING (auth.uid() = id);

-- Portfólio: escrita pelo prestador dono
CREATE POLICY "portfolio_insert_own" ON portfolio_images
  FOR INSERT WITH CHECK (auth.uid() = provider_id);
CREATE POLICY "portfolio_delete_own" ON portfolio_images
  FOR DELETE USING (auth.uid() = provider_id);

-- Assinaturas: leitura pelo próprio usuário
CREATE POLICY "subscriptions_select_own" ON subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- ============================================================
-- ÍNDICES DE PERFORMANCE
-- ============================================================

CREATE INDEX idx_posts_user_id     ON posts(user_id);
CREATE INDEX idx_posts_category_id ON posts(category_id);
CREATE INDEX idx_posts_status      ON posts(status);
CREATE INDEX idx_posts_created_at  ON posts(created_at DESC);
CREATE INDEX idx_posts_city        ON posts(city);

CREATE INDEX idx_post_photos_post_id ON post_photos(post_id);

CREATE INDEX idx_post_tags_post_id ON post_tags(post_id);
CREATE INDEX idx_post_tags_tag_id  ON post_tags(tag_id);

CREATE INDEX idx_favorites_user_id ON favorites(user_id);
CREATE INDEX idx_favorites_post_id ON favorites(post_id);

CREATE INDEX idx_reviews_post_id ON reviews(post_id);

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);

CREATE INDEX idx_providers_category_id   ON providers(category_id);
CREATE INDEX idx_providers_neighborhood  ON providers(neighborhood);
CREATE INDEX idx_providers_city          ON providers(city);
CREATE INDEX idx_portfolio_provider_id   ON portfolio_images(provider_id);
CREATE INDEX idx_reviews_post_id_rating  ON reviews(post_id, rating);

-- ============================================================
-- FUNÇÕES RPC
-- ============================================================

-- Busca prestadores por raio de distância (PostGIS)
CREATE OR REPLACE FUNCTION providers_nearby(
  p_lat       FLOAT8,
  p_lng       FLOAT8,
  p_radius_km FLOAT8  DEFAULT 10,
  p_page      INTEGER DEFAULT 1,
  p_limit     INTEGER DEFAULT 10
)
RETURNS TABLE (id UUID, distance_km FLOAT8) AS $$
BEGIN
  RETURN QUERY
  SELECT
    pr.id,
    ROUND(
      (ST_Distance(
        ST_SetSRID(ST_MakePoint(pr.longitude, pr.latitude), 4326)::geography,
        ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
      ) / 1000.0)::NUMERIC, 2
    )::FLOAT8 AS distance_km
  FROM providers pr
  WHERE pr.is_active = true
    AND pr.latitude  IS NOT NULL
    AND pr.longitude IS NOT NULL
    AND ST_DWithin(
      ST_SetSRID(ST_MakePoint(pr.longitude, pr.latitude), 4326)::geography,
      ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
      p_radius_km * 1000
    )
  ORDER BY distance_km
  LIMIT  p_limit
  OFFSET (p_page - 1) * p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================
-- MIGRATION (executar apenas em banco existente)
-- ============================================================
-- ALTER TABLE posts ADD COLUMN IF NOT EXISTS rating_avg   FLOAT4  DEFAULT 0;
-- ALTER TABLE posts ADD COLUMN IF NOT EXISTS rating_count INTEGER DEFAULT 0;

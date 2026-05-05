-- Buscaí Database Schema
-- Execute no Supabase SQL Editor

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis"; -- para geolocalização futura

-- Tabela de perfis (estende auth.users do Supabase)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('morador', 'prestador')),
  neighborhood TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de categorias de serviço
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Dados iniciais de categorias
INSERT INTO categories (name, slug, icon) VALUES
  ('Manutenção', 'manutencao', 'build'),
  ('Estética', 'estetica', 'face'),
  ('Automotivo', 'automotivo', 'directions_car'),
  ('Limpeza', 'limpeza', 'cleaning_services'),
  ('Elétrica', 'eletrica', 'electrical_services'),
  ('Hidráulica', 'hidraulica', 'plumbing'),
  ('Informática', 'informatica', 'computer'),
  ('Outros', 'outros', 'miscellaneous_services');

-- Tabela de prestadores de serviço
CREATE TABLE providers (
  id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  description TEXT,
  category_id UUID REFERENCES categories(id),
  whatsapp TEXT NOT NULL,
  neighborhood TEXT NOT NULL,
  schedule TEXT,                          -- ex: "Seg–Sex 08h–18h, Sáb 08h–12h"
  latitude FLOAT8,
  longitude FLOAT8,
  rating_avg FLOAT4 DEFAULT 0,
  rating_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de imagens do portfólio
CREATE TABLE portfolio_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de avaliações
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reviewer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  provider_id UUID NOT NULL REFERENCES providers(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (reviewer_id, provider_id)
);

-- Trigger para atualizar rating_avg automaticamente
CREATE OR REPLACE FUNCTION update_provider_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE providers
  SET
    rating_avg = (SELECT AVG(rating) FROM reviews WHERE provider_id = NEW.provider_id),
    rating_count = (SELECT COUNT(*) FROM reviews WHERE provider_id = NEW.provider_id)
  WHERE id = NEW.provider_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_rating
AFTER INSERT OR UPDATE OR DELETE ON reviews
FOR EACH ROW EXECUTE FUNCTION update_provider_rating();

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_profiles_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_providers_updated_at
BEFORE UPDATE ON providers
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Políticas: leitura pública
CREATE POLICY "profiles_select_public" ON profiles FOR SELECT USING (true);
CREATE POLICY "providers_select_public" ON providers FOR SELECT USING (is_active = true);
CREATE POLICY "categories_select_public" ON categories FOR SELECT USING (true);
CREATE POLICY "portfolio_select_public" ON portfolio_images FOR SELECT USING (true);
CREATE POLICY "reviews_select_public" ON reviews FOR SELECT USING (true);

-- Políticas: escrita apenas pelo próprio usuário
CREATE POLICY "profiles_insert_own" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "providers_insert_own" ON providers FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "providers_update_own" ON providers FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "portfolio_insert_own" ON portfolio_images
  FOR INSERT WITH CHECK (auth.uid() = provider_id);
CREATE POLICY "portfolio_delete_own" ON portfolio_images
  FOR DELETE USING (auth.uid() = provider_id);

CREATE POLICY "reviews_insert_auth" ON reviews
  FOR INSERT WITH CHECK (auth.uid() = reviewer_id);
CREATE POLICY "reviews_update_own" ON reviews
  FOR UPDATE USING (auth.uid() = reviewer_id);
CREATE POLICY "reviews_delete_own" ON reviews
  FOR DELETE USING (auth.uid() = reviewer_id);

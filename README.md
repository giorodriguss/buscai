# Buscaí — O vizinho que você precisava encontrar

O **Buscaí** é um aplicativo mobile que conecta moradores a prestadores de serviços locais dentro da própria comunidade, de forma rápida, simples e sem intermediários.

---

## Sobre o projeto

O Buscaí funciona como um **catálogo digital hiper-local**, permitindo que usuários encontrem profissionais próximos com base em bairro ou raio de distância, com contato direto via WhatsApp.

---

## Problema

Em situações do dia a dia (ex: emergências domésticas), moradores:

- Não sabem quem contratar
- Dependem de indicações informais
- Perdem tempo com contatos indisponíveis ou distantes

---

## Solução

- Busca por localização (bairro ou proximidade)
- Perfis com avaliações da comunidade
- Contato imediato via WhatsApp
- Sem taxas ou intermediações

---

## Público-alvo

- **Moradores:** Buscam praticidade e rapidez
- **Prestadores autônomos:** Precisam de visibilidade digital

---

## Funcionalidades

- Cadastro e autenticação (morador / prestador)
- Catálogo baseado em localização
- Filtros por categoria (manutenção, estética, automotivo, etc.)
- Perfis completos com foto, descrição e portfólio
- Sistema de avaliações
- Agendamento de serviços
- Gerenciamento de disponibilidade (dias e horários)
- Endereços salvos por usuário
- Favoritos e histórico de serviços
- Contato direto via WhatsApp
- Área exclusiva para prestadores (painel Colaborador)

---

## Tecnologias

### Frontend
| Tecnologia | Uso |
|---|---|
| Flutter (Dart) | Framework mobile (Android + iOS) |
| Riverpod | Gerenciamento de estado reativo |
| Dio | Client HTTP para consumo da API |
| Google Fonts | Tipografia |
| Shared Preferences | Persistência local (token de sessão) |

### Backend
| Tecnologia | Uso |
|---|---|
| NestJS (TypeScript) | Framework REST API |
| Supabase (PostgreSQL) | Banco de dados relacional |
| Supabase Auth | Autenticação JWT |
| Supabase Storage | Upload de imagens |
| Passport JWT | Guards de autenticação |
| Helmet | Headers de segurança |
| Class Validator | Validação de DTOs |
| Cache Manager | Cache de respostas |

### Infraestrutura
| Tecnologia | Uso |
|---|---|
| Railway | Deploy da API |
| Supabase | BaaS (banco + auth + storage) |

---

## Arquitetura

```
Flutter App
    ↓  HTTP/JWT
NestJS REST API  (Railway)
    ↓  RLS + Service Role
Supabase (PostgreSQL + Auth + Storage)
```

### Padrões adotados

**Backend**
- Arquitetura modular por domínio (`auth`, `users`, `providers`, `reviews`, `favorites`, `subscriptions`, `posts`, `upload`, `ads`, `categories`)
- Row Level Security (RLS) no Supabase — cada usuário só acessa seus próprios dados
- `@BearerToken()` decorator para extração do JWT nos controllers
- `getUserClient(token)` para operações com contexto do usuário autenticado
- DTOs com validação via `class-validator`

**Frontend**
- Biblioteca única (`figma_flow.dart`) com `part` files por tela
- Gerenciamento de estado com Riverpod (`sessionProvider`, `collaboratorProvider`)
- Repository pattern para chamadas de API (`AuthRepository`, `ProvidersRepository`, `FavoritesRepository`)
- Mixins reutilizáveis (`AsyncLoadMixin`, `DebouncedValidationMixin`)

---

## Estrutura do projeto

```
buscai/
├── backend/
│   └── src/
│       ├── ads/
│       ├── auth/
│       ├── categories/
│       ├── common/
│       ├── config/
│       ├── favorites/
│       ├── posts/
│       ├── providers/
│       ├── reviews/
│       ├── subscriptions/
│       ├── supabase/
│       ├── tags/
│       ├── upload/
│       └── users/
└── frontend/
    └── lib/
        ├── screens/
        │   └── flow_parts/   ← uma tela por arquivo (part files)
        ├── services/         ← clients HTTP (Dio)
        └── theme/            ← tema global do app
```

---

## Configuração e execução

### Pré-requisitos

- Node.js 18+
- Flutter 3.x
- Conta no Supabase

### Backend

```bash
cd backend
npm install
cp .env.example .env   # preencha as variáveis abaixo
npm run start:dev
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

---

## Variáveis de ambiente (backend)

Crie o arquivo `backend/.env` com base no `.env.example`:

| Variável | Descrição |
|---|---|
| `SUPABASE_URL` | URL do projeto Supabase |
| `SUPABASE_ANON_KEY` | Chave pública (anon) do Supabase |
| `SUPABASE_SERVICE_ROLE_KEY` | Chave de service role (acesso admin) |
| `JWT_SECRET` | Segredo para assinatura dos tokens JWT |
| `PORT` | Porta onde a API sobe (padrão: 3000) |

---

## Status do projeto

Em desenvolvimento ativo — MVP backend funcional, frontend em fase de integração e refinamento visual.

| Área | Status |
|---|---|
| Autenticação (JWT + Supabase Auth) | Concluído |
| CRUD de prestadores | Concluído |
| Reviews e avaliações | Concluído |
| Favoritos | Concluído |
| Subscriptions | Concluído |
| Upload de imagens | Concluído |
| RLS + segurança por usuário | Concluído |
| Frontend — fluxo de autenticação | Concluído |
| Frontend — home, busca, perfis | Concluído |
| Frontend — área do prestador | Concluído |
| Frontend — gerenciamento de estado (Riverpod) | Concluído |
| Integração frontend ↔ backend | Em andamento |
| Testes automatizados | Em andamento |

---

## Próximos passos

- Concluir integração das telas restantes com a API
- Implementar busca por geolocalização real
- Testes com usuários reais
- Refinamento visual e acessibilidade
- Expansão para mais categorias e regiões

---

## Equipe

- Victor Rogério Aguiar do Rosario
- Lucas Silva Oliveira
- Franklin Ferreira dos Santos
- Giovanna Salomão Rodrigues
- Samira de Jesus Santos
- Lucas de Jesus Barreto

---

## Licença

Projeto acadêmico desenvolvido para fins educacionais.

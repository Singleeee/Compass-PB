# EXECUÇÃO DO AMBIENTE — Back-end e Front-end (PT-BR)

> **Resumo:** Abaixo estão **somente** os comandos práticos para colocar o sistema no ar **e popular dados**
para que seus testes rodem sem fricção. Inclui `npm run build` e `npm run seed` onde se aplicam.

---

## 1) Back-end (Cinema API)

### Pré-requisitos
- Node.js 16+
- MongoDB (local ou Atlas) — definir `MONGODB_URI` no `.env`
- Variáveis de ambiente mínimas (`.env`):
```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/cinema-app
JWT_SECRET=sua_chave_jwt_aqui
```

### Instalar e subir
```bash
git clone https://github.com/juniorschmitz/cinema-challenge-back
cd cinema-challenge-back
npm install

# Desenvolvimento
npm run dev

# Produção
npm start
```

### Popular o banco (seed)
```bash
# Seed padrão (amostras, conforme README do back)
npm run seed

# Scripts auxiliares (quando disponíveis no repo)
node src/utils/setup-test-users.js    # cria admin e usuário padrão
node src/utils/setup-movies-db.js     # cria filmes básicos
node src/utils/seedMoreMovies.js      # adiciona mais filmes e sessões
```

**Dicas:**
- Execute a partir da raiz do projeto para evitar erros de caminho.
- Se usar Atlas, confirme a connection string e privilégios de usuário.

---

## 2) Front-end (Cinema App Front)

### Pré-requisitos
- Node.js 16+
- Variáveis (arquivo `.env.local` ou similar):
```
VITE_API_URL=/api/v1
VITE_APP_ENV=development
```

### Instalar, desenvolver e **build**
```bash
git clone https://github.com/juniorschmitz/cinema-challenge-front
cd cinema-challenge-front
npm install

# Desenvolvimento (Vite dev server)
npm start

# **Build de produção**
npm run build

# Preview do build
npm run preview
```

**Observações:**
- Em dev, o proxy tende a encaminhar `/api/v1` para `http://localhost:5000/api/v1` ou porta configurada no back.
- Se trocar a porta/host do back, ajuste o proxy do Vite e/ou o `VITE_API_URL`.

---

## 3) Contas de teste (após seed)
- **Admin:** `admin@example.com` / `admin123`
- **Usuário:** `user@example.com` / `password123`

> Se o seed não criar usuários, rode os scripts de setup ou as rotas de setup (apenas desenvolvimento).

---

## 4) Problemas comuns
- **Erro de conexão MongoDB**: verifique `MONGODB_URI` no `.env`.
- **Login não clica (Front)**: há mais de um link “Login”; use seletor por `role=name`.
- **Build do Front falha**: limpe `node_modules` e `package-lock.json`, reinstale dependências.

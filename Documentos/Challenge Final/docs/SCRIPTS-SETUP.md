# SCRIPTS DE SETUP (Consolidação)

> Scripts úteis do back-end para preparar ambiente e massa de dados (rodar na **raiz** do projeto).

```bash
node src/utils/setup-test-users.js   # cria admin e usuário padrão
node src/utils/setup-movies-db.js    # limpa e cria filmes básicos
node src/utils/seedMoreMovies.js     # adiciona ~16 filmes + sessões (7 dias, 12h/16h/20h)
```

## Sequência sugerida
1. `node src/utils/setup-test-users.js`
2. `node src/utils/setup-movies-db.js`
3. `node src/utils/seedMoreMovies.js`

## Variáveis necessárias
- `.env`: `PORT`, `MONGODB_URI`, `JWT_SECRET`

## Dicas de troubleshooting
- "Cannot find module": execute a partir da **raiz**.
- `MONGODB_URI undefined`: confira o `.env`.
- Erros de conexão: verifique credenciais/whitelist no Atlas.

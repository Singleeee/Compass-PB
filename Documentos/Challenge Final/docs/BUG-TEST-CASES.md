# Casos de Teste — Bugs Reportados (Cinema)

> **Escopo:** somente bugs realmente *reportados/observados* durante a execução do challenge.  
> **Obs.:** Campos “Evidência” e “Status” podem ser atualizados com links para `log.html`, `report.html` e prints.

---

## BUG-001 — [WEB] Link “Login” duplicado impede clique (Playwright em modo estrito)
**Componente:** Front-end (Header / Navegação)  
**Severidade:** Média (bloqueia navegação para login por seletor genérico)  
**Prioridade:** Alta

### Pré-condições
- Front executando (`npm start` ou `npm run preview`).  
- Browser Library (Playwright) em **modo estrito** (default).

### Passos
1. Acessar a Home do app.
2. Tentar clicar em **Login** usando seletor genérico (ex.: `css=a[href="/login"]` ou `text=Login`).

### Resultado Esperado
- O click deve abrir a página **Login** com `<h1>Login</h1>` visível.

### Resultado Obtido
- O Playwright não executa o clique e retorna erro de **strict mode** por encontrar **mais de um** elemento correspondente (pelo menos dois links “Login”).

### Evidências
- Log/screenshot de execução do teste que falha ao clicar.
- Captura do DOM com **dois** elementos para “Login”.

### Ambiente
- SO/Navegador: _(preencher)_  
- Versão Front: _(commit/tag)_

### Observações & Mitigação de Teste
- **Mitigação (teste):** usar `role=link[name="Login"]` ou `css=a[href="/login"] >> nth=0`.
- **Correção (produto):** tornar único via `aria-label`/id/estrutura do header.

### Status
- **Aberto** (aguardando correção no Front).

---

## BUG-002 — [API] Conflito de sessão/reserva não retorna HTTP 409 (a confirmar)
**Componente:** Back-end (Sessions/Reservations)  
**Severidade:** Alta (regra de negócio)  
**Prioridade:** Alta

### Pré-condições
- Banco populado com *sessão existente* e assentos ocupados conforme seed ou execução prévia.
- Usuário autenticado como **comum** (não admin).

### Passos
1. Efetuar **reserva** para uma sessão específica (assentos X,Y).
2. Tentar **reservar novamente** os **mesmos assentos** na mesma sessão (ou criar nova sessão em horário conflitante, se aplicável ao endpoint testado).

### Resultado Esperado
- A API deve rejeitar com **HTTP 409 (Conflict)** e payload de erro claro.

### Resultado Obtido
- Em execução manual foi observado retorno **diferente de 409** (ex.: 200/201 ou 400/404), permitindo ou respondendo inadequadamente ao conflito. *(marcado como “a confirmar” até registro de evidência no log)*

### Evidências
- Logs/screen das duas chamadas (1ª reserva e 2ª reserva conflitante).
- Trechos de `log.html`/`report.html` com o status code retornado.

### Ambiente
- URL/API: _(preencher)_  
- Seed utilizado: _(preencher)_

### Observações
- Confirmar comportamento para **sessões sobrepostas** (criação de sessão em horário e sala que conflitam).

### Status
- **A confirmar** (necessário anexar evidências do retorno).

---

## Como referenciar estes bugs nos testes (sem alterar sua suíte)
- Utilize **tags** nos casos que reproduzem os problemas, por exemplo: `bug`, `web`, `api`, `reservations`, `sessions`.
- Armazene prints em uma pasta de evidências e linke-os aqui (ex.: `results/BUG-001-<timestamp>.png`).

## Histórico de Atualizações
- v1.0 — criação do documento com os dois bugs reportados/observados.

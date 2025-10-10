# Bugs — Autenticação & Sessões (derivados da suíte Robot)

> Fontes: 
`00_authentication.robot` 
`30_sessions.robot`

---

## A. Autenticação

### BUG-A1 — Mudar senha com dados corretos retorna 500
**Arquivo/CT:** `00_authentication.robot` — `CT08:(BUG) com dados corretos retorna 500`  
**Endpoint:** `PUT /auth/change-password` (ou rota equivalente)  
**Severidade:** Alta | **Prioridade:** Alta

**Pré-condições**
- Usuário autenticado (**token válido**).
- Senha atual conhecida.

**Passos**
1. Enviar request de **troca de senha** com: `currentPassword` válida e `newPassword` válida.
2. Verificar o **status code**.

**Esperado**
- **200** (ou 204) com confirmação da troca.

**Obtido**
- **500** (erro interno).

**Evidências**
- `log.html` do Robot contendo `[CT08] Body` e `status_code=500`.

**Observações**
- Validar logs do back-end para stacktrace e regras de validação de senha.

---

### BUG-A2 — currentPassword incorreta retorna 500 (deveria 401)
**Arquivo/CT:** `00_authentication.robot` — `CT09:(BUG) currentPassword incorreta retorna 500 (era 401)`  
**Endpoint:** `PUT /auth/change-password`  
**Severidade:** Média | **Prioridade:** Alta

**Passos**
1. Enviar request com `currentPassword` **inválida** e `newPassword` qualquer.
2. Verificar status code.

**Esperado**
- **401** (credenciais inválidas).

**Obtido**
- **500**.

**Evidências**
- `log.html` do Robot contendo `[CT09] Body` e `status_code=500`.

---

### BUG-A3 — payload incompleto retorna 200 (deveria 400)
**Arquivo/CT:** `00_authentication.robot` — `CT10:(BUG) payload incompleto retorna 200 (era 400)`  
**Endpoint:** `PUT /auth/change-password`  
**Severidade:** Média | **Prioridade:** Média

**Passos**
1. Enviar request **incompleto** (ex.: sem `currentPassword` ou sem `newPassword`).
2. Verificar status code.

**Esperado**
- **400** (dados inválidos).

**Obtido**
- **200** (ou outro sucesso).

**Evidências**
- `log.html` do Robot com payload reduzido e status de sucesso.

---

## B. Sessões

### BUG-S1 — Criar sessão em horário conflitante não retorna 409
**Arquivo/CT:** `30_sessions.robot` — `CT07:Criar sessão - conflito de horários (409)`  
**Endpoint:** `POST /sessions`  
**Severidade:** Alta | **Prioridade:** Alta

**Passos**
1. **Criar** sessão com `movieId`, `theaterId` e `startAt` (horário fixo).  
2. **Tentar criar novamente** outra sessão **idêntica** no mesmo horário e sala.
3. Verificar status code.

**Esperado**
- **409** (conflito).

**Obtido**
- Código **diferente** de 409 (ex.: 200/201/400 — verificar `log.html`).

**Evidências**
- Execução com `${fixed}=2025-10-09T15:00:00Z` (ou offset equivalente) e prints das duas respostas.

---

### BUG-S2 — Atualizar sessão com dados inválidos não retorna 400
**Arquivo/CT:** `30_sessions.robot` — `CT11:Atualizar - dados inválidos (400)`  
**Endpoint:** `PUT /sessions/:id`  
**Severidade:** Média | **Prioridade:** Média

**Passos**
1. Tentar **atualizar** sessão com payload **inválido** (ex.: horário no passado, formato inválido, ids inexistentes).
2. Verificar status code.

**Esperado**
- **400**.

**Obtido**
- Código **diferente** de 400.

---

### BUG-S3 — Atualizar sessão com reservas confirmadas não retorna 409
**Arquivo/CT:** `30_sessions.robot` — `CT15:Atualizar - possui reservas (409)`  
**Endpoint:** `PUT /sessions/:id`  
**Severidade:** Alta | **Prioridade:** Alta

**Passos**
1. Garantir uma **sessão com reserva confirmada** (assentos ocupados).
2. Tentar **atualizar** a sessão (ex.: alterar horário).
3. Verificar status code.

**Esperado**
- **409** (não deve permitir atualizar sessões com reservas).

**Obtido**
- Código **diferente** de 409.

---

### BUG-S4 — Excluir sessão com reservas confirmadas não retorna 409
**Arquivo/CT:** `30_sessions.robot` — `CT20:Excluir - não pode excluir com reservas confirmadas (409)`  
**Endpoint:** `DELETE /sessions/:id`  
**Severidade:** Alta | **Prioridade:** Alta

**Passos**
1. Sessão com **reservas confirmadas**.
2. Tentar **excluir** a sessão.
3. Verificar status code.

**Esperado**
- **409** (bloqueio de exclusão).

**Obtido**
- Código **diferente** de 409.

---

### BUG-S5 — Reset seats sem token não retorna 401 (ou retorna 404 errático)
**Arquivo/CT:** `30_sessions.robot` — `CT22:Reset seats - não autorizado (401)`  
**Endpoint:** `PUT /sessions/:id/reset`  
**Severidade:** Média | **Prioridade:** Alta

**Passos**
1. Chamar **reset de cadeiras** **sem Authorization**.
2. Verificar status code.

**Esperado**
- **401**.

**Obtido**
- **Outro código** (observado às vezes **404**). Teste permite `[401,404]` para registrar o bug.

---

### BUG-S6 — Reset seats com usuário comum não retorna 403 (ou oscila 404)
**Arquivo/CT:** `30_sessions.robot` — `CT23:Reset seats - negado (usuário comum) (403)`  
**Endpoint:** `PUT /sessions/:id/reset`  
**Severidade:** Média | **Prioridade:** Média

**Passos**
1. Autenticar como **usuário comum** (não admin).
2. Chamar reset de cadeiras.
3. Verificar status code.

**Esperado**
- **403**.

**Obtido**
- **Outro código** (em algumas execuções **404**).

---

### BUG-S7 — Reset seats (sucesso) instável
**Arquivo/CT:** `30_sessions.robot` — `CT21:Reset seats - sucesso (200)`  
**Endpoint:** `PUT /sessions/:id/reset`  
**Severidade:** Baixa | **Prioridade:** Média

**Contexto/Indício**
- Teste marcado com `bug` indica **instabilidade** ou pré-condição frágil (ex.: sessão sem reservas).

**Esperado**
- **200** com cadeiras **resetadas ao estado original**.

**Obtido**
- Sucesso **intermitente** ou retorno divergente conforme massa/estado da sessão.

---

## Anexos/Evidências
- Anexar `log.html`/`report.html` das execuções e prints das respostas.
- Indicar `movieId/theaterId/sessionId` utilizados para reprodutibilidade.

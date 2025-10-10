# PLANO DE TESTES — Cinema (Escopo Funcional)

> **Nota:** O plano cobre o que foi efetivamente testado. `Setup` e `API Info` estavam no mapa mental,
> mas foram **fora de escopo** por não serem necessários para os objetivos funcionais desta entrega.

## 1. Contexto e Apresentação
- **Nome/Curso/Semestre/Cidade:** _preencher_
- **Objetivo:** validar funcionalidades principais de **Autenticação**, **Filmes**, **Sessões**, **Reservas**, **Salas** e **Usuários**.

## 2. Escopo
- **Authentication:** registro, login, perfil, atualizar perfil
- **Movies:** listar, buscar por ID, criar/atualizar/excluir (admin)
- **Sessions:** listar por filme, buscar por ID, criar/atualizar/excluir (admin), resetar cadeiras
- **Reservations:** criar, listar do usuário, listar todas (admin), buscar por ID, atualizar status (admin), excluir (admin)
- **Theaters:** listar, buscar por ID, criar/atualizar/excluir (admin)
- **Users:** listar/buscar/atualizar/excluir (admin)

## 3. Abordagem
- Testes **funcionais** manuais + automatizados (Robot).
- Padrões: **PageObjects** (Web) e **ServiceObjects** (API) — **sem** alterar a suíte existente.
- Dados: massa mínima e isolamento por caso; idempotência sempre que possível.

## 4. Critérios de Aceite do Plano
- Ambiente sobe localmente (ou remoto) com dados básicos sem erros.
- Suíte executa com estabilidade e sem falhas bloqueantes.
- Evidências disponíveis (relatórios Robot, prints).

## 5. Cobertura (exemplos)
- Códigos de retorno esperados: `200/201/400/401/403/404/409` conforme regra de negócio.
- Perfis: **usuário** e **admin**.
- Fluxo E2E de **reserva** contemplado.

## 6. Riscos & Mitigações
- **Seletores duplicados** no Front → usar `role=`, `text=` e/ou `>> nth=` quando necessário.
- **Conflitos de horário em sessões** → validar `409` e garantir limpeza de massa.
- **Dependência de seeds** → scripts e rotas de setup para estabilidade local.

## 7. Evidências
- `output.xml`, `log.html`, `report.html`, prints de tela e `mapa-mental.png`.

## 8. Justificativas
- Itens fora de escopo (`Setup`, `API Info`) não agregavam risco ao objetivo funcional desta sprint.

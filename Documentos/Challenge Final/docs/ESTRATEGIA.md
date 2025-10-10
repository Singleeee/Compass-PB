# ESTRATÉGIA E PADRÕES (Sem alterar a suíte existente)

- **Web (Playwright / Browser Library)**: PageObjects; seletores robustos (`role=`, `text=`, `css >> nth=`).
- **API (RequestsLibrary)**: Keywords de serviço centralizando `GET/POST/PUT/DELETE`, headers e token.
- **Dados**: variáveis de ambiente/linha de comando; massa sintética quando possível.
- **Branches**: `main` (estável), `feature/*`, `fix/*`, `ci/*`; commits frequentes e descritivos.
- **Independência**: casos não dependem da ordem; limpeza apenas quando necessária.
- **Inovação**: prompts de GenAI para revisão de cobertura; CI opcional mantendo a suíte como está.

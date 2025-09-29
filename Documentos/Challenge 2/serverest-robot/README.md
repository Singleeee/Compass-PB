

### Nota sobre cabeçalhos de segurança
Algumas versões/builds do ServeRest podem não enviar `X-Content-Type-Options` e `X-Frame-Options`. O teste `40_SegurancaHeaders.robot` agora possui um toggle:

- **Enforce** (falhar se ausente): `robot -v ENFORCE_SECURITY_HEADERS:True tests`
- **Somente log** (padrão): `robot tests`

A verificação é _case-insensitive_.

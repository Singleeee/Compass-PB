*** Settings ***
Library           RequestsLibrary
Library           Collections
Library           String
Library           OperatingSystem

*** Variables ***
${BASE_URL}       %{BASE_URL=http://localhost:3000}
${ADMIN_PASSWORD}    1234

*** Keywords ***
Create API Session
    [Documentation]    Cria sessão HTTP para a API.
    Create Session    serverest    ${BASE_URL}    disable_warnings=1

Create Admin And Login
    [Documentation]    Cria usuário administrador e realiza login. Retorna token Bearer.
    ${suffix}=    Generate Random String    6    [LOWER]
    ${email}=     Set Variable    admin+${suffix}@example.com
    ${body}=      Create Dictionary    nome=Admin ${suffix}    email=${email}    password=${ADMIN_PASSWORD}    administrador=true
    ${resp}=      POST On Session    serverest    /usuarios    json=${body}
    Status Should Be    201    ${resp}
    ${login}=     Create Dictionary    email=${email}    password=${ADMIN_PASSWORD}
    ${resp2}=     POST On Session    serverest    /login    json=${login}
    Status Should Be    200    ${resp2}
    ${json}=      Evaluate    json.loads($resp2.text)    json
    ${token}=     Get From Dictionary    ${json}    authorization
    RETURN      ${token}

Create User (non-admin) And Login
    [Documentation]    Cria usuário comum e faz login. Retorna token Bearer.
    ${suffix}=    Generate Random String    6    [LOWER]
    ${email}=     Set Variable    user+${suffix}@example.com
    ${body}=      Create Dictionary    nome=User ${suffix}    email=${email}    password=1234    administrador=false
    ${resp}=      POST On Session    serverest    /usuarios    json=${body}
    Status Should Be    201    ${resp}
    ${login}=     Create Dictionary    email=${email}    password=1234
    ${resp2}=     POST On Session    serverest    /login    json=${login}
    Status Should Be    200    ${resp2}
    ${json}=      Evaluate    json.loads($resp2.text)    json
    ${token}=     Get From Dictionary    ${json}    authorization
    RETURN      ${token}

Auth Headers
    [Arguments]    ${token}
    ${headers}=    Create Dictionary    Authorization=${token}    Accept=application/json    Content-Type=application/json
    RETURN      ${headers}

Create Random Product
    [Arguments]    ${token}
    ${headers}=    Auth Headers    ${token}
    ${rand}=       Generate Random String    5    [NUMBERS]
    ${prod}=       Create Dictionary    nome=Produto ${rand}    preco=100    descricao=Mouse    quantidade=10
    ${resp}=       POST On Session    serverest    /produtos    headers=${headers}    json=${prod}
    RETURN       ${resp}

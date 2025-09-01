*** Settings ***
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       https://reqres.in

*** Keywords ***
Conectar na API
    Create Session    reqres    ${BASE_URL}

Verificar se a API está online
    [Documentation]    Faz uma chamada no endpoint /api/users?page=2 para checar se a API responde.
    Conectar na API
    ${response}=    GET On Session    reqres    /api/users?page=2
    Should Be Equal As Integers    ${response.status_code}    200

Listar usuários
    [Documentation]    Busca a lista de usuários na página 1 e valida se não está vazia.
    Conectar na API
    ${response}=    GET On Session   reqres    /api/users?page=1
    Should Be Equal As Integers    ${response.status_code}    200
    Should Not Be Empty    ${response.json()['data']}    A lista de usuários não deveria estar vazia.

Consultar usuário por ID
    [Documentation]    Busca os detalhes de um usuário específico usando seu ID.
    [Arguments]    ${user_id}
    Conectar na API
    ${response}=    GET On Session   reqres    /api/users/${user_id}
    Should Be Equal As Integers    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    data

Criar usuário
    [Documentation]    Cria um novo usuário com dados de exemplo.
    [Arguments]    ${nome}=Fulano    ${cargo}=QA Engineer
    Conectar na API
    ${body}=    Create Dictionary    name=${nome}    job=${cargo}
    ${response}=    POST On Session   reqres    /api/users    json=${body}
    Should Be Equal As Integers    ${response.status_code}    201
    Dictionary Should Contain Key    ${response.json()}    id
    [Return]    ${response.json()['id']}

Atualizar usuário
    [Documentation]    Atualiza os dados de um usuário existente (PUT).
    [Arguments]    ${user_id}    ${nome}=Ciclano    ${cargo}=DevOps
    Conectar na API
    ${body}=    Create Dictionary    name=${nome}    job=${cargo}
    ${response}=    PUT On Session   reqres    /api/users/${user_id}    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    updatedAt

Deletar usuário
    [Documentation]    Remove um usuário pelo ID.
    [Arguments]    ${user_id}
    Conectar na API
    ${response}=    DELETE On Session   reqres    /api/users/${user_id}
    Should Be Equal As Integers    ${response.status_code}    204
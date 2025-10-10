*** Settings ***
Resource    ../resources/env.resource
Resource    ../resources/auth.resource
Library     String
Library     Collections
Suite Setup    Create API Session

*** Variables ***
${INVALID_BEARER}    Bearer invalid.token.value

*** Test Cases ***

# --------------- POST - Registrar Usuário ---------------
CT01:Registrar um novo usuário (201)
    ${name}=        Set Variable     Test User
    ${rand}=        Generate Random String    6    [LETTERS]
    ${email}=       Set Variable     user_${rand}@example.com
    ${password}=    Set Variable     password123

    ${resp}=        Register User    ${name}    ${email}    ${password}
    Should Be Equal As Integers      ${resp.status_code}    201

    ${token}=       Get Token    ${resp}
    Set Suite Variable    ${REG_EMAIL}          ${email}
    Set Suite Variable    ${REG_PASSWORD}       ${password}
    Set Suite Variable    ${REG_TOKEN}          ${token}

CT02:Usuário já existente (400)
    ${resp}=        Register User    Test Again    ${REG_EMAIL}    ${REG_PASSWORD}
    Should Be Equal As Integers      ${resp.status_code}    400

# --------------- POST - Realizar login de um usuário ---------------
CT03:Autenticar com sucesso (200)
    ${resp}=        Login With       ${REG_EMAIL}    ${REG_PASSWORD}
    Should Be Equal As Integers      ${resp.status_code}    200
    ${token}=       Get Token        ${resp}
    Set Suite Variable    ${LOGIN_TOKEN}    ${token}

CT04:Credenciais inválidas (401)
    ${resp}=        Login With       wrong@example.com    badpass
    Should Be Equal As Integers      ${resp.status_code}    401

# --------------- GET - Buscar perfil de usuário atual ---------------
CT05:Dados do Usuário (200)
    ${resp}=        Get Me           ${LOGIN_TOKEN}
    Should Be Equal As Integers      ${resp.status_code}    200
    ${body}=        Set Variable     ${resp.json()}
    Dictionary Should Contain Key    ${body}    data

CT06:Sem token (401)
    ${resp}=        Get Me
    Should Be Equal As Integers      ${resp.status_code}    401

CT07:Token inválido (401)
    ${headers}=     Create Dictionary    Authorization=${INVALID_BEARER}    Accept=application/json
    ${resp}=        GET On Session   cinema    /auth/me    headers=${headers}    expected_status=any
    Should Be Equal As Integers      ${resp.status_code}    401

# --------------- PUT - Atualizar perfil de usuário ---------------
CT08:(BUG) com dados corretos retorna 500
    [Tags]    bug    profile
    ${nova}=        Catenate    SEPARATOR=    ${REG_PASSWORD}    _N1
    ${resp}=        Change Password    ${LOGIN_TOKEN}    ${REG_PASSWORD}    ${nova}
    Log To Console  \n[CT08] Body: ${resp.text}
    Should Be Equal As Integers      ${resp.status_code}    500

CT09:(BUG) currentPassword incorreta retorna 500 (era 401)
    [Tags]    bug    profile
    ${resp}=        Change Password    ${LOGIN_TOKEN}    wrong_password    any_new_pass_123
    Log To Console  \n[CT09] Body: ${resp.text}
    Should Be Equal As Integers      ${resp.status_code}    500

CT10:(BUG) payload incompleto retorna 200 (era 400)
    [Tags]    bug    profile
    ${headers}=     Header With Token    ${LOGIN_TOKEN}
    ${body}=        Create Dictionary    currentPassword=${EMPTY}
    ${resp}=        PUT On Session    cinema    /auth/profile    headers=${headers}    json=${body}    expected_status=any
    Log To Console  \n[CT10] Body: ${resp.text}
    Should Be Equal As Integers      ${resp.status_code}    200

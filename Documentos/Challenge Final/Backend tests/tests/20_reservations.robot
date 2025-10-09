*** Settings ***
Resource    ../resources/env.resource
Resource    ../resources/auth.resource
Resource    ../resources/payloads.resource
Resource    ../resources/reservations.resource

Library     Collections
Suite Setup     Create API Session

*** Variables ***
${TEST_SESSION_ID}       68e81126aad0b0d70a387eaf    # ID de uma sessão válida dentro do banco de dados do MongoDB
${INVALID_SESSION_ID}    999999999999999999999999    # ID inválido, garantidamente não existente

*** Test Cases ***

# --------------- GET - Buscar todas as reservas do usuário atual ---------------
CT01:Minhas reservas (200)
    ${user_token}=    Login As User
    ${resp}=          My Reservations    ${user_token}
    Should Be Equal As Integers    ${resp.status_code}    200

CT02:Minhas reservas - sem token (401)
    ${resp}=          GET On Session    cinema    /reservations/me    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

# --------------- POST - Criar uma nova reserva ---------------
CT03:Criar reserva com sucesso (201)
    ${user_token}=    Login As User
    ${seats}=         Reservation Seats (Default)
    ${payload}=  payloads.Reservation Payload    ${TEST_SESSION_ID}
    ${headers}=  Header With Token    ${USER_TOKEN}
    ${resp}=     POST On Session    cinema    /reservations    headers=${headers}    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    201
    ${body}=          Set Variable    ${resp.json()}
    Set Suite Variable    ${LAST_RES_ID}    ${body['data']['_id']}
    Set Suite Variable    ${LAST_SEATS}     ${seats}

CT04:Criar reserva - assentos já ocupados ou inválidos (400)
    ${user_token}=    Login As User
    ${payload}=  payloads.Reservation Payload    ${TEST_SESSION_ID}    ${LAST_SEATS}
    ${headers}=  Header With Token    ${USER_TOKEN}
    ${resp}=     POST On Session    cinema    /reservations    headers=${headers}    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    400

CT05:Criar reserva - não autorizado (401)
    ${seats}=         Reservation Seats (Default)
    ${payload}=       Reservation Payload    ${TEST_SESSION_ID}    ${seats}
    ${resp}=          POST On Session    cinema    /reservations    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT06:Criar reserva - sessão não encontrada (404)
    ${user_token}=    Login As User
    ${seats}=         Reservation Seats (Default)
    ${headers}=       Header With Token    ${user_token}
    ${payload}=       Reservation Payload    ${INVALID_SESSION_ID}    ${seats}
    ${resp}=          POST On Session    cinema    /reservations    headers=${headers}    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    404

# --------------- GET - Buscar todas as reservas ---------------
CT07:Listar todas as reservas (admin) 200
    ${admin_token}=   Login As Admin
    ${resp}=          List All Reservations (admin)    ${admin_token}    1    10
    Should Be Equal As Integers    ${resp.status_code}    200

CT08:Listar todas - sem token (401)
    ${resp}=          GET On Session    cinema    /reservations    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT09:Listar todas - usuário comum (403)
    ${user_token}=    Login As User
    ${headers}=       Header With Token    ${user_token}
    ${resp}=          GET On Session    cinema    /reservations    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

# --------------- GET - Buscar uma reserva por ID ---------------
CT10:Detalhes da reserva (200)
    ${user_token}=    Login As User
    # garante que temos uma reserva válida (se CT03 falhou por qualquer motivo)
    Run Keyword If    '${LAST_RES_ID}' == ''    Create Reservation For Details
    ${resp}=          Reservation Details    ${user_token}    ${LAST_RES_ID}
    Should Be Equal As Integers    ${resp.status_code}    200

CT11:Detalhes - não autorizado (401)
    ${resp}=          GET On Session    cinema    /reservations/${LAST_RES_ID}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT12:Detalhes - não encontrado (404)
    ${admin_token}=   Login As Admin
    ${resp}=          Reservation Details    ${admin_token}    ${INVALID_SESSION_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

# --------------- PUT - Atualizar status da reserva ---------------
CT13:Atualizar status (admin) 200
    ${admin_token}=   Login As Admin
    Run Keyword If    '${LAST_RES_ID}' == ''    Create Reservation For Details
    ${resp}=          Update Reservation Status (admin)    ${admin_token}    ${LAST_RES_ID}    confirmed
    Should Be Equal As Integers    ${resp.status_code}    200

CT14:Atualizar status - não autorizado (401)
    # garante um ID (reaproveita ${LAST_RES_ID} se já existir)
    ${rid}=    Set Variable If    '${LAST_RES_ID}'!=''    ${LAST_RES_ID}    ${EMPTY}
    Run Keyword If    '${rid}'==''
    ...    ${rid}=    Create Reservation For Update (user)

    # sem header Authorization
    ${body}=   Create Dictionary    status=confirmed
    ${resp}=   PUT On Session    cinema    /reservations/${rid}    json=${body}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT15:Atualizar status - usuário comum (403)
    # garante um ID (reaproveita ${LAST_RES_ID} se já existir)
    ${rid}=    Set Variable If    '${LAST_RES_ID}'!=''    ${LAST_RES_ID}    ${EMPTY}
    Run Keyword If    '${rid}'==''
    ...    ${rid}=    Create Reservation For Update (user)

    # token de USER, não admin
    ${user}=   Login As User
    ${headers}=    Header With Token    ${user}
    ${body}=   Create Dictionary    status=confirmed
    ${resp}=   PUT On Session    cinema    /reservations/${rid}    headers=${headers}    json=${body}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT16:Atualizar status - não encontrado (404)
    ${admin_token}=   Login As Admin
    ${resp}=          Update Reservation Status (admin)    ${admin_token}    ${INVALID_SESSION_ID}    confirmed
    Should Be Equal As Integers    ${resp.status_code}    404

# --------------- DELETE - Excluir reserva ---------------
CT17:Excluir reserva (admin) 200/204
    ${admin_token}=   Login As Admin
    Run Keyword If    '${LAST_RES_ID}' == ''    Create Reservation For Details
    ${resp}=          Delete Reservation (admin)    ${admin_token}    ${LAST_RES_ID}
    Should Be True    ${resp.status_code} in [200,204]
    Set Suite Variable    ${LAST_RES_ID}    ${EMPTY}

CT18:Excluir - não autorizado (401)
    # tenta excluir a própria CT03 se ainda existir; senão usa um id inválido só para checar 401
    ${target}=        Run Keyword If    '${LAST_RES_ID}' != ''    Set Variable    ${LAST_RES_ID}    ELSE    Set Variable    ${TEST_SESSION_ID}
    ${resp}=          DELETE On Session    cinema    /reservations/${target}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT19:Excluir - usuário comum (403)
    ${user_token}=    Login As User
    ${headers}=       Header With Token    ${user_token}
    ${target}=        Run Keyword If    '${LAST_RES_ID}' != ''    Set Variable    ${LAST_RES_ID}    ELSE    Set Variable    ${TEST_SESSION_ID}
    ${resp}=          DELETE On Session    cinema    /reservations/${target}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT20:Excluir - não encontrado (404)
    ${admin_token}=   Login As Admin
    ${resp}=          Delete Reservation (admin)    ${admin_token}    ${INVALID_SESSION_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

*** Keywords ***
Create Reservation For Update (user)
    # cria uma reserva mínima via usuário para obter um ID válido
    ${user}=       Login As User
    ${headers}=    Header With Token    ${user}
    # se você já tem ${TEST_SESSION_ID}, use-o; senão troque pelo seu ID válido de sessão
    ${payload}=    Reservation Payload    ${TEST_SESSION_ID}
    ${resp}=       POST On Session    cinema    /reservations    headers=${headers}    json=${payload}    expected_status=any
    Should Be True    ${resp.status_code} in [200,201]
    ${body}=       Set Variable    ${resp.json()}
    ${rid}=        Set Variable    ${body['data']['_id']}
    # opcional: guarda pra outros testes
    Set Suite Variable    ${LAST_RES_ID}    ${rid}
    [Return]      ${rid}

Create Reservation For Details
    ${user_token}=    Login As User
    ${seats}=         Reservation Seats (Default)
    ${payload}=  payloads.Reservation Payload    ${TEST_SESSION_ID}
    ${headers}=       Header With Token    ${user_token}
    ${resp}=          POST On Session    cinema    /reservations    headers=${headers}    json=${payload}    expected_status=any
    Should Be True    ${resp.status_code} in [200,201]
    ${body}=          Set Variable    ${resp.json()}
    Set Suite Variable    ${LAST_RES_ID}    ${body['data']['_id']}
    Set Suite Variable    ${LAST_SEATS}     ${seats}

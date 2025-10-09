*** Settings ***
Resource    ../resources/env.resource
Resource    ../resources/auth.resource
Resource    ../resources/reservations.resource
Resource    ../resources/payloads.resource

Library     Collections

Suite Setup    Setup Reservations Suite

*** Variables ***
${TEST_SESSION_ID}    ${EMPTY}
${NOT_FOUND_ID}       000000000000000000000000

*** Keywords ***
Setup Reservations Suite
    Create API Session
    ${sid}=    Ensure Test Session Id    ${TEST_SESSION_ID}
    Set Suite Variable    ${TEST_SESSION_ID}    ${sid}
    ${adm}=    Login As Admin
    ${usr}=    Login As User
    Set Suite Variable    ${ADMIN_TOKEN}    ${adm}
    Set Suite Variable    ${USER_TOKEN}     ${usr}

Make Taken Seats
    # Usa os mesmos assentos default para simular duplicidade
    ${seats}=    Reservation Seats (Default)
    RETURN       ${seats}

Create Reservation And Return Id
    [Arguments]    ${user_token}    ${session_id}
    ${resp}=    Create Reservation (user)    ${user_token}    ${session_id}
    Should Be True    ${resp.status_code} in [200,201]
    ${rid}=     Extract Reservation Id    ${resp}
    RETURN      ${rid}

*** Test Cases ***
CT01:Minhas reservas (200)
    ${resp}=    My Reservations    ${USER_TOKEN}
    Should Be Equal As Integers    ${resp.status_code}    200

CT02:Minhas reservas - sem token (401)
    ${resp}=    GET On Session    cinema    /reservations/me    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT03:Criar reserva com sucesso (201)
    ${resp}=    Create Reservation (user)    ${USER_TOKEN}    ${TEST_SESSION_ID}
    Should Be True    ${resp.status_code} in [200,201]
    Extract Reservation Id    ${resp}

CT04:Criar reserva - assentos já ocupados ou inválidos (400)
    # Reservar primeiro (ok) e tentar reservar os MESMOS assentos novamente (deve 400)
    ${seats}=   Make Taken Seats
    ${r1}=      Create Reservation (user)    ${USER_TOKEN}    ${TEST_SESSION_ID}    ${seats}
    Should Be True    ${r1.status_code} in [200,201]
    ${r2}=      Create Reservation (user)    ${USER_TOKEN}    ${TEST_SESSION_ID}    ${seats}
    Should Be Equal As Integers    ${r2.status_code}    400

CT05:Criar reserva - não autorizado (401)
    ${payload}=    Reservation Payload    ${TEST_SESSION_ID}
    ${resp}=       POST On Session    cinema    /reservations    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT06:Criar reserva - sessão não encontrada (404)
    ${resp}=    Create Reservation (user)    ${USER_TOKEN}    ${NOT_FOUND_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

CT07:Listar todas as reservas (admin) 200
    ${resp}=    List All Reservations (admin)    ${ADMIN_TOKEN}    1    10
    Should Be Equal As Integers    ${resp.status_code}    200

CT08:Listar todas - sem token (401)
    ${resp}=    GET On Session    cinema    /reservations    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT09:Listar todas - usuário comum (403)
    ${resp}=    List All Reservations (admin)    ${USER_TOKEN}    1    10
    Should Be Equal As Integers    ${resp.status_code}    403

CT10:Detalhes da reserva (200)
    ${rid}=    Create Reservation And Return Id    ${USER_TOKEN}    ${TEST_SESSION_ID}
    ${resp}=   Get Reservation    ${USER_TOKEN}    ${rid}
    Should Be Equal As Integers    ${resp.status_code}    200

CT11:Detalhes - não autorizado (401)
    ${rid}=    Create Reservation And Return Id    ${USER_TOKEN}    ${TEST_SESSION_ID}
    ${resp}=   GET On Session    cinema    /reservations/${rid}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT12:Detalhes - não encontrado (404)
    ${resp}=   Get Reservation    ${ADMIN_TOKEN}    ${NOT_FOUND_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

CT13:Atualizar status (admin) 200
    ${rid}=    Create Reservation And Return Id    ${USER_TOKEN}    ${TEST_SESSION_ID}
    ${resp}=   Update Reservation Status (admin)    ${ADMIN_TOKEN}    ${rid}    confirmed
    Should Be Equal As Integers    ${resp.status_code}    200

CT14:Atualizar status - não autorizado (401)
    ${rid}=    Create Reservation And Return Id    ${USER_TOKEN}    ${TEST_SESSION_ID}
    ${body}=   Create Dictionary    status=cancelled
    ${resp}=   PUT On Session    cinema    /reservations/${rid}    json=${body}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT15:Atualizar status - usuário comum (403)
    ${rid}=    Create Reservation And Return Id    ${USER_TOKEN}    ${TEST_SESSION_ID}
    ${resp}=   Update Reservation Status (admin)    ${USER_TOKEN}    ${rid}    cancelled
    Should Be Equal As Integers    ${resp.status_code}    403

CT16:Atualizar status - não encontrado (404)
    ${resp}=   Update Reservation Status (admin)    ${ADMIN_TOKEN}    ${NOT_FOUND_ID}    confirmed
    Should Be Equal As Integers    ${resp.status_code}    404

CT17:Excluir reserva (admin) 200/204
    ${rid}=    Create Reservation And Return Id    ${USER_TOKEN}    ${TEST_SESSION_ID}
    ${resp}=   Delete Reservation (admin)    ${ADMIN_TOKEN}    ${rid}
    Should Be True    ${resp.status_code} in [200,204]

CT18:Excluir - não autorizado (401)
    ${rid}=    Create Reservation And Return Id    ${USER_TOKEN}    ${TEST_SESSION_ID}
    ${resp}=   DELETE On Session    cinema    /reservations/${rid}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT19:Excluir - usuário comum (403)
    ${rid}=    Create Reservation And Return Id    ${USER_TOKEN}    ${TEST_SESSION_ID}
    ${resp}=   Delete Reservation (admin)    ${USER_TOKEN}    ${rid}
    Should Be Equal As Integers    ${resp.status_code}    403

CT20:Excluir - não encontrado (404)
    ${resp}=   Delete Reservation (admin)    ${ADMIN_TOKEN}    ${NOT_FOUND_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

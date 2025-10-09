*** Settings ***
Resource    env.resource
Resource    auth.resource
Resource    payloads.resource
Library     Collections

*** Keywords ***
# ============================================================
# GARANTIR UMA SESSION VÁLIDA PARA TESTES
# ============================================================
Ensure Test Session Id
    [Arguments]    ${maybe_id}=${EMPTY}
    # Se já vier preenchido, devolve
    IF    '${maybe_id}' != '' and '${maybe_id}' != '${EMPTY}'
        RETURN    ${maybe_id}
    END

    Create API Session
    ${params}=    Create Dictionary    limit=1
    ${resp}=      GET On Session    cinema    /sessions    params=${params}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    200

    ${data}=      Set Variable    ${resp.json()}
    # Algumas APIs retornam {"data":[...]}, outras retornam diretamente a lista
    ${items}=     Set Variable If    'data' in ${data}    ${data['data']}    ${data}
    Should Not Be Empty    ${items}    msg=Endpoint /sessions não retornou itens.
    ${sid}=       Set Variable    ${items}[0]['_id']
    Should Not Be Empty    ${sid}     msg=Não foi possível extrair _id da sessão.
    RETURN        ${sid}

# ============================================================
# ENDPOINTS DE RESERVATIONS
# ============================================================
My Reservations
    [Arguments]    ${token}
    ${headers}=    Header With Token    ${token}
    ${resp}=       GET On Session    cinema    /reservations/me    headers=${headers}    expected_status=any
    RETURN         ${resp}

Create Reservation (user)
    [Arguments]    ${token}    ${session_id}    ${seats}=${None}    ${payment_method}=credit_card
    ${headers}=    Header With Token    ${token}
    ${payload}=    Reservation Payload    ${session_id}    ${seats}    ${payment_method}
    ${resp}=       POST On Session    cinema    /reservations    headers=${headers}    json=${payload}    expected_status=any
    RETURN         ${resp}

List All Reservations (admin)
    [Arguments]    ${token}    ${page}=1    ${limit}=10
    ${headers}=    Header With Token    ${token}
    ${params}=     Create Dictionary    page=${page}    limit=${limit}
    ${resp}=       GET On Session    cinema    /reservations    headers=${headers}    params=${params}    expected_status=any
    RETURN         ${resp}

Get Reservation
    [Arguments]    ${token}    ${reservation_id}
    ${headers}=    Header With Token    ${token}
    ${resp}=       GET On Session    cinema    /reservations/${reservation_id}    headers=${headers}    expected_status=any
    RETURN         ${resp}

Update Reservation Status (admin)
    [Arguments]    ${token}    ${reservation_id}    ${status}
    ${headers}=    Header With Token    ${token}
    ${body}=       Create Dictionary    status=${status}
    ${resp}=       PUT On Session    cinema    /reservations/${reservation_id}    headers=${headers}    json=${body}    expected_status=any
    RETURN         ${resp}

Delete Reservation (admin)
    [Arguments]    ${token}    ${reservation_id}
    ${headers}=    Header With Token    ${token}
    ${resp}=       DELETE On Session    cinema    /reservations/${reservation_id}    headers=${headers}    expected_status=any
    RETURN         ${resp}

Extract Reservation Id
    [Arguments]    ${resp}
    ${body}=    Set Variable    ${resp.json()}
    ${rid}=     Run Keyword If    'data' in ${body} and '_id' in ${body['data']}    Set Variable    ${body['data']['_id']}
    ...         ELSE IF    '_id' in ${body}    Set Variable    ${body['_id']}
    ...         ELSE    Set Variable    ${EMPTY}
    Should Not Be Empty    ${rid}    msg=Resposta não contém _id da reserva.
    RETURN      ${rid}

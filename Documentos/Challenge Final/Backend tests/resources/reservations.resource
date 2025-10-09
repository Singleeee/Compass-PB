*** Settings ***
Resource    env.resource
Resource    auth.resource
Resource    payloads.resource
Library     Collections

*** Keywords ***
# ============================================================
# EXTRATORES E HELPERS
# ============================================================
Extract Id From First Item
    [Arguments]    ${items}
    ${first}=    Get From List    ${items}    0
    # Evaluate executa a expressão Python de verdade (Set Variable não executa .get)
    ${sid}=      Evaluate    $first.get('_id') or $first.get('id')
    Should Not Be Empty    ${sid}
    RETURN      ${sid}

Extract Object Id From Response
    [Arguments]    ${resp}
    ${id}=    Evaluate    $resp.json().get('data', {}).get('_id') or $resp.json().get('_id')
    Should Not Be Empty    ${id}
    RETURN      ${id}

# ============================================================
# GARANTIR UMA SESSION VÁLIDA PARA TESTES
# - Tenta pegar em /sessions; se não houver, cria movie+theater+session.
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

    # Se listou com sucesso, normaliza a lista de itens
    ${items}=     Set Variable    []
    IF    ${resp.status_code} == 200
        ${data}=    Set Variable    ${resp.json()}
        ${items}=   Set Variable    ${data.get('data') or data.get('items') or (data if isinstance(data, list) else [])}
    END

    IF    len(${items}) > 0
        ${sid}=    Extract Id From First Item    ${items}
        RETURN    ${sid}
    END

    # ----------- criar sessão completa (admin) -----------
    ${adm}=         Login As Admin
    ${headers}=     Header With Token    ${adm}

    # movie
    ${m_payload}=   Movie Payload (Docs)
    ${m_resp}=      POST On Session    cinema    /movies    headers=${headers}    json=${m_payload}    expected_status=any
    Should Be True  ${m_resp.status_code} in [200,201]
    ${movie_id}=    Extract Object Id From Response    ${m_resp}

    # theater
    ${t_payload}=   Random Theater Payload
    ${t_resp}=      POST On Session    cinema    /theaters    headers=${headers}    json=${t_payload}    expected_status=any
    Should Be True  ${t_resp.status_code} in [200,201]
    ${theater_id}=  Extract Object Id From Response    ${t_resp}

    # session
    ${s_payload}=   Random Session Payload    ${movie_id}    ${theater_id}
    ${s_resp}=      POST On Session    cinema    /sessions    headers=${headers}    json=${s_payload}    expected_status=any
    Should Be True  ${s_resp.status_code} in [200,201]
    ${session_id}=  Extract Object Id From Response    ${s_resp}
    RETURN          ${session_id}

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
    ${rid}=    Evaluate    $resp.json().get('data', {}).get('_id') or $resp.json().get('_id')
    Should Not Be Empty    ${rid}    msg=Resposta não contém _id da reserva.
    RETURN      ${rid}

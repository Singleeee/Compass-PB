*** Settings ***
Resource    env.resource
Resource    auth.resource
Resource    payloads.resource
Library     Collections

*** Keywords ***
# -----------------------------
# Endpoints base (públicos/admin)
# -----------------------------
List Sessions
    [Arguments]    ${params}=${None}
    ${resp}=    GET On Session    cinema    /sessions    params=${params}    expected_status=any
    RETURN      ${resp}

Create Session (admin)
    [Arguments]    ${token}    ${payload}
    ${headers}=    Header With Token    ${token}
    ${resp}=       POST On Session    cinema    /sessions    headers=${headers}    json=${payload}    expected_status=any
    RETURN         ${resp}

Get Session By Id
    [Arguments]    ${session_id}
    ${resp}=       GET On Session    cinema    /sessions/${session_id}    expected_status=any
    RETURN         ${resp}

Update Session (admin)
    [Arguments]    ${token}    ${session_id}    ${payload}
    ${headers}=    Header With Token    ${token}
    ${resp}=       PUT On Session    cinema    /sessions/${session_id}    headers=${headers}    json=${payload}    expected_status=any
    RETURN         ${resp}

Delete Session (admin)
    [Arguments]    ${token}    ${session_id}
    ${headers}=    Header With Token    ${token}
    ${resp}=       DELETE On Session    cinema    /sessions/${session_id}    headers=${headers}    expected_status=any
    RETURN         ${resp}

Reset Session Seats (admin)
    [Arguments]    ${token}    ${session_id}
    ${headers}=    Header With Token    ${token}
    # Se sua API usa outro path (ex.: /sessions/${id}/seats/reset), ajuste somente esta linha:
    ${resp}=       PUT On Session    cinema    /sessions/${session_id}/reset    headers=${headers}    expected_status=any
    RETURN         ${resp}

# -----------------------------
# Helpers para dependências
# -----------------------------
_Ensure Movie & Theater
    # Cria e memoriza (em nível de suíte) IDs de filme e sala para montar sessões
    ${adm}=        Login As Admin

    Run Keyword If    '${TEST_MOVIE_ID}'!='' and '${TEST_THEATER_ID}'!=''    
    RETURN

    # cria filme
    ${mp}=         Movie Payload (Docs)
    ${mresp}=      POST On Session    cinema    /movies    headers=${None}    expected_status=any
    ...            headers=${Header With Token(${adm})}    json=${mp}
    Should Be True    ${mresp.status_code} in [200,201]
    ${movie_id}=   Set Variable    ${mresp.json()['_id']}
    Set Suite Variable    ${TEST_MOVIE_ID}    ${movie_id}

    # cria sala
    ${tp}=         Random Theater Payload
    ${tresp}=      POST On Session    cinema    /theaters    headers=${Header With Token(${adm})}    json=${tp}    expected_status=any
    Should Be True    ${tresp.status_code} in [200,201]
    ${theater_id}=    Set Variable    ${tresp.json()['_id']}
    Set Suite Variable    ${TEST_THEATER_ID}    ${theater_id}

_Build Session Payload
    [Arguments]    ${minutes_a_frente}=10
    # Gera startTime daqui a X minutos para evitar conflitos com o clock do servidor
    ${adm}=        Login As Admin
    _Ensure Movie & Theater
    ${payload}=    Random Session Payload    ${TEST_MOVIE_ID}    ${TEST_THEATER_ID}
    RETURN         ${payload}

_Create Clean Session (admin)
    # Cria sessão “limpa” (sem reservas) e devolve o id
    ${adm}=        Login As Admin
    ${payload}=    _Build Session Payload
    ${resp}=       Create Session (admin)    ${adm}    ${payload}
    Should Be True    ${resp.status_code} in [200,201]
    ${id}=         Set Variable    ${resp.json()['_id']}
    RETURN         ${id}

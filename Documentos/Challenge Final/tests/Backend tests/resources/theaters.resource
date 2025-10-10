*** Settings ***
Resource    env.resource
Resource    auth.resource
Library     Collections
Library     String

*** Variables ***
${DEFAULT_THEATER_TYPE}    standard
# se quiser forçar um ID fixo existente para filtros, pode colocar aqui:
${KNOWN_THEATER_ID}        68e7f2d979e540f75211b23e

*** Keywords ***
# ---------- Helpers ----------
Header (Token)
    [Arguments]    ${token}
    ${headers}=    Create Dictionary
    ...    Authorization=Bearer ${token}
    ...    Content-Type=application/json
    ...    Accept=application/json
    RETURN    ${headers}

_Extract Id From Response
    [Arguments]    ${resp}
    ${body}=    Set Variable    ${resp.json()}
    ${id}=      Run Keyword And Return If    '_id' in ${body}                      Set Variable    ${body['_id']}
    ${id}=      Run Keyword And Return If    'data' in ${body} and '_id' in ${body['data']}    Set Variable    ${body['data']['_id']}
    Should Not Be Empty    ${id}
    RETURN    ${id}

Valid Theater Payload
    [Arguments]    ${name}=${None}    ${capacity}=120    ${type}=${DEFAULT_THEATER_TYPE}
    IF    $name is None
        ${rand}=    Generate Random String    6    [LOWER]
        ${name}=    Catenate    SEPARATOR=    Theater_    ${rand}
    END
    ${body}=    Create Dictionary    name=${name}    capacity=${capacity}    type=${type}
    RETURN      ${body}

Invalid Theater Payload
    # faltando campos obrigatórios
    ${bad}=     Create Dictionary    name=${EMPTY}
    RETURN      ${bad}

# ---------- Endpoints ----------
List Theaters
    [Arguments]    ${params}=${None}
    ${resp}=    GET On Session    cinema    /theaters    params=${params}    expected_status=any
    RETURN      ${resp}

Create Theater (admin)
    [Arguments]    ${token}    ${payload}=${None}
    ${headers}=    Header (Token)    ${token}
    Run Keyword If    $payload is None    ${payload}=    Valid Theater Payload
    ${resp}=    POST On Session    cinema    /theaters    headers=${headers}    json=${payload}    expected_status=any
    RETURN      ${resp}

Theater Details
    [Arguments]    ${id}
    ${resp}=    GET On Session    cinema    /theaters/${id}    expected_status=any
    RETURN      ${resp}

Update Theater (admin)
    [Arguments]    ${token}    ${id}    ${payload}
    ${headers}=    Header (Token)    ${token}
    ${resp}=    PUT On Session    cinema    /theaters/${id}    headers=${headers}    json=${payload}    expected_status=any
    RETURN      ${resp}

Delete Theater (admin)
    [Arguments]    ${token}    ${id}
    ${headers}=    Header (Token)    ${token}
    ${resp}=    DELETE On Session    cinema    /theaters/${id}    headers=${headers}    expected_status=any
    RETURN      ${resp}

# ---------- Atalhos para testes ----------
_Build Theater Payload
    [Arguments]    ${name}=${None}    ${capacity}=120    ${type}=${DEFAULT_THEATER_TYPE}
    ${p}=    Valid Theater Payload    ${name}    ${capacity}    ${type}
    RETURN    ${p}

_Create Clean Theater (admin)
    ${adm}=      Login As Admin
    ${payload}=  Valid Theater Payload
    ${resp}=     Create Theater (admin)    ${adm}    ${payload}
    Should Be True    ${resp.status_code} in [200,201]
    ${id}=       _Extract Id From Response    ${resp}
    RETURN       ${id}

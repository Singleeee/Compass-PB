*** Settings ***
Resource    env.resource
Resource    auth.resource
Library     Collections
Library     DateTime

*** Variables ***
# IDs estáticos (do seu banco) para estabilizar os testes
${TEST_MOVIE_ID}        68e81125aad0b0d70a387e9b
${TEST_THEATER_ID}      68e7f2d979e540f75211b23e
${DEFAULT_FULL_PRICE}   17
${DEFAULT_HALF_PRICE}   9.5

*** Keywords ***
# ========== Helpers básicos ==========
Header (Token)
    [Arguments]    ${token}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}    Content-Type=application/json
    Return From Keyword    ${headers}

Valid Session Payload
    [Arguments]    ${movie_id}=${TEST_MOVIE_ID}    ${theater_id}=${TEST_THEATER_ID}    ${datetime}=${None}    ${full_price}=${DEFAULT_FULL_PRICE}    ${half_price}=${DEFAULT_HALF_PRICE}
    IF    $datetime is None
        ${datetime}=    Get Current Date    result_format=%Y-%m-%dT%H:%M:%S.000Z    increment=2 hours
    END
    ${body}=    Create Dictionary
    ...    movie=${movie_id}
    ...    theater=${theater_id}
    ...    datetime=${datetime}
    ...    fullPrice=${full_price}
    ...    halfPrice=${half_price}
    Return From Keyword    ${body}

Build Sessions Query Params
    [Arguments]    ${page}=1    ${limit}=10    ${movie}=${None}    ${theater}=${None}    ${date}=${None}
    ${params}=    Create Dictionary    page=${page}    limit=${limit}
    Run Keyword If    $movie is not None      Set To Dictionary    ${params}    movie=${movie}
    Run Keyword If    $theater is not None    Set To Dictionary    ${params}    theater=${theater}
    Run Keyword If    $date is not None       Set To Dictionary    ${params}    date=${date}
    Return From Keyword    ${params}

_Extract Id From Response
    [Arguments]    ${resp}
    ${body}=    Set Variable    ${resp.json()}
    ${id}=      Run Keyword And Return If    '_id' in ${body}                      Set Variable    ${body['_id']}
    ${id}=      Run Keyword And Return If    'data' in ${body} and '_id' in ${body['data']}    Set Variable    ${body['data']['_id']}
    Should Not Be Empty    ${id}
    Return From Keyword    ${id}

# ========== Endpoints ==========
List Sessions
    [Arguments]    ${page}=1    ${limit}=10    ${movie}=${None}    ${theater}=${None}    ${date}=${None}
    ${params}=    Build Sessions Query Params    ${page}    ${limit}    ${movie}    ${theater}    ${date}
    ${resp}=      GET On Session    cinema    /sessions    params=${params}    expected_status=any
    Return From Keyword    ${resp}

# wrapper para quando o teste monta um dicionário de params e passa como 1º arg
List Sessions (params)
    [Arguments]    ${params}
    ${resp}=      GET On Session    cinema    /sessions    params=${params}    expected_status=any
    Return From Keyword    ${resp}

Create Session (admin)
    [Arguments]    ${token}    ${body}=${None}
    ${headers}=    Header (Token)    ${token}
    Run Keyword If    $body is None    ${body}=    Valid Session Payload
    ${resp}=       POST On Session    cinema    /sessions    headers=${headers}    json=${body}    expected_status=any
    Return From Keyword    ${resp}

Session Details
    [Arguments]    ${session_id}
    ${resp}=       GET On Session    cinema    /sessions/${session_id}    expected_status=any
    Return From Keyword    ${resp}

Update Session (admin)
    [Arguments]    ${token}    ${session_id}    ${body}
    ${headers}=    Header (Token)    ${token}
    ${resp}=       PUT On Session    cinema    /sessions/${session_id}    headers=${headers}    json=${body}    expected_status=any
    Return From Keyword    ${resp}

Delete Session (admin)
    [Arguments]    ${token}    ${session_id}
    ${headers}=    Header (Token)    ${token}
    ${resp}=       DELETE On Session    cinema    /sessions/${session_id}    headers=${headers}    expected_status=any
    Return From Keyword    ${resp}

Reset Session Seats (admin)
    [Arguments]    ${token}    ${session_id}
    ${headers}=    Header (Token)    ${token}
    ${resp}=       PUT On Session    cinema    /sessions/${session_id}/reset    headers=${headers}    expected_status=any
    Return From Keyword    ${resp}

# ========== ALIASES para bater com o teu 30_sessions.robot ==========
_Build Session Payload
    [Arguments]    ${movie_id}=${TEST_MOVIE_ID}    ${theater_id}=${TEST_THEATER_ID}    ${datetime}=${None}
    ${body}=    Valid Session Payload    ${movie_id}    ${theater_id}    ${datetime}
    Return From Keyword    ${body}

_Ensure Movie & Theater
    Should Not Be Empty    ${TEST_MOVIE_ID}
    Should Not Be Empty    ${TEST_THEATER_ID}

_Create Clean Session (admin)
    ${adm}=       Login As Admin
    ${payload}=   Valid Session Payload
    ${resp}=      Create Session (admin)    ${adm}    ${payload}
    Should Be True    ${resp.status_code} in [200,201]
    ${id}=        _Extract Id From Response    ${resp}
    Return From Keyword    ${id}

Get Session By Id
    [Arguments]    ${session_id}
    ${resp}=       Session Details    ${session_id}
    Return From Keyword    ${resp}

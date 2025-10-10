*** Settings ***
Resource    env.resource
Resource    auth.resource
Library     Collections
Library     String

*** Keywords ***
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
    RETURN      ${id}

# ---------- Endpoints (admin-only na doc) ----------
List Users (admin)
    [Arguments]    ${token}    ${page}=1    ${limit}=10
    ${headers}=    Header (Token)    ${token}
    ${params}=     Create Dictionary    page=${page}    limit=${limit}
    ${resp}=       GET On Session    cinema    /users    headers=${headers}    params=${params}    expected_status=any
    RETURN         ${resp}

User Details (admin)
    [Arguments]    ${token}    ${user_id}
    ${headers}=    Header (Token)    ${token}
    ${resp}=       GET On Session    cinema    /users/${user_id}    headers=${headers}    expected_status=any
    RETURN         ${resp}

Update User (admin)
    [Arguments]    ${token}    ${user_id}    ${payload}
    ${headers}=    Header (Token)    ${token}
    ${resp}=       PUT On Session    cinema    /users/${user_id}    headers=${headers}    json=${payload}    expected_status=any
    RETURN         ${resp}

Delete User (admin)
    [Arguments]    ${token}    ${user_id}
    ${headers}=    Header (Token)    ${token}
    ${resp}=       DELETE On Session    cinema    /users/${user_id}    headers=${headers}    expected_status=any
    RETURN         ${resp}

# ---------- Helpers de teste ----------
Valid User Update Payload
    [Arguments]    ${name}=${None}    ${email}=${None}    ${role}=user
    IF    $name is None
        ${name}=    Catenate    SEPARATOR=    Test User    
    END
    IF    $email is None
        ${suffix}=    Generate Random String    6    [LOWER]
        ${email}=     Catenate    SEPARATOR=    user_${suffix}@example.com
    END
    ${p}=    Create Dictionary    name=${name}    email=${email}    role=${role}
    RETURN  ${p}

Invalid User Update Payload
    ${bad}=    Create Dictionary    email=${EMPTY}
    RETURN     ${bad}

_Create Random User (public register)
    ${suffix}=   Generate Random String    6    [LOWER]
    ${name}=     Set Variable    Test User
    ${email}=    Catenate    SEPARATOR=    user_${suffix}@example.com
    ${pass}=     Set Variable    password123
    ${r}=        Register User    ${name}    ${email}    ${pass}
    Should Be True    ${r.status_code} in [200,201]
    # retorna id via /auth/me
    ${login}=    Login With    ${email}    ${pass}
    ${tk}=       Extract Token    ${login}
    ${me}=       Get Me         ${tk}
    ${uid}=      _Extract Id From Response    ${me}
    RETURN       ${uid}

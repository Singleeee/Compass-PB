*** Settings ***
Resource    env.resource
Library     Collections

*** Keywords ***
Register User
    [Arguments]    ${name}    ${email}    ${password}
    Create API Session
    ${body}=    Create Dictionary    name=${name}    email=${email}    password=${password}
    ${resp}=    POST On Session    cinema    /auth/register    json=${body}    expected_status=any
    RETURN      ${resp}

Login With
    [Arguments]    ${email}    ${password}
    Create API Session
    ${body}=    Create Dictionary    email=${email}    password=${password}
    ${resp}=    POST On Session    cinema    /auth/login    json=${body}    expected_status=any
    RETURN      ${resp}

Get Me
    [Arguments]    ${token}=    # opcional
    ${headers}=    Run Keyword If    '${token}'!=''    Header With Token    ${token}
    ...            ELSE    Create Dictionary    Accept=application/json
    ${resp}=       GET On Session    cinema    /auth/me    headers=${headers}    expected_status=any
    RETURN         ${resp}

Change Password
    [Arguments]    ${token}    ${current_password}    ${new_password}
    ${headers}=    Header With Token    ${token}
    ${body}=       Create Dictionary    currentPassword=${current_password}    newPassword=${new_password}
    ${resp}=       PUT On Session    cinema    /auth/profile    headers=${headers}    json=${body}    expected_status=any
    RETURN         ${resp}

Get Token
    [Arguments]    ${resp}
    ${body}=        Set Variable     ${resp.json()}
    Dictionary Should Contain Key    ${body}    data
    ${data}=        Set Variable     ${body['data']}
    Dictionary Should Contain Key    ${data}    token
    ${token}=       Set Variable     ${data['token']}
    RETURN         ${token}

# --------- Helpers (token/id em 'data' ou na raiz) ----------
_Extract From Body
    [Arguments]    ${body}    ${key}
    ${value}=    Run Keyword And Return If    '${key}' in ${body}    Set Variable    ${body['${key}']}
    ${value}=    Run Keyword And Return If    'data' in ${body} and '${key}' in ${body['data']}    Set Variable    ${body['data']['${key}']}
    RETURN       ${value}

Extract Token
    [Arguments]    ${resp}
    ${body}=      Set Variable    ${resp.json()}
    ${token}=     _Extract From Body    ${body}    token
    Should Not Be Empty    ${token}
    RETURN       ${token}

Extract User Id
    [Arguments]    ${resp}
    ${body}=      Set Variable    ${resp.json()}
    ${_id}=       _Extract From Body    ${body}    _id
    RETURN       ${_id}

Login As Admin
    Create API Session
    ${body}=    Create Dictionary    email=${ADMIN_EMAIL}    password=${ADMIN_PASS}
    ${resp}=    POST On Session    cinema    /auth/login    json=${body}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    200
    ${token}=   Extract Token    ${resp}
    RETURN      ${token}

Login As User
    Create API Session
    ${body}=    Create Dictionary    email=${USER_EMAIL}    password=${USER_PASS}
    ${resp}=    POST On Session    cinema    /auth/login    json=${body}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    200
    ${token}=   Extract Token    ${resp}
    RETURN      ${token}

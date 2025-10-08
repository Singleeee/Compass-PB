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

# Extrai token aceitando os dois formatos que vimos:
# 1) {"data":{"token":"..."}}
# 2) {"token":"..."}
Extract Token
    [Arguments]    ${resp}
    ${body}=    Set Variable    ${resp.json()}
    ${token}=   Set Variable If    'data' in ${body} and 'token' in ${body['data']}    ${body['data']['token']}    ${EMPTY}
    ${token}=   Set Variable If    '${token}'==''
    ...         ${body['token']}    ${token}
    Should Not Be Empty    ${token}    msg=Resposta não contém token válido.
    RETURN      ${token}

Get Token
    [Arguments]    ${resp}
    ${token}=    Extract Token    ${resp}
    RETURN       ${token}

Get Me
    [Arguments]    ${token}=${EMPTY}
    ${headers}=  Run Keyword If    '${token}'!=''    Header With Token    ${token}
    ...          ELSE    Create Dictionary    Accept=application/json
    ${resp}=     GET On Session    cinema    /auth/me    headers=${headers}    expected_status=any
    RETURN       ${resp}

Change Password
    [Arguments]    ${token}    ${current_password}    ${new_password}
    ${headers}=   Header With Token    ${token}
    ${body}=      Create Dictionary    currentPassword=${current_password}    newPassword=${new_password}
    ${resp}=      PUT On Session    cinema    /auth/profile    headers=${headers}    json=${body}    expected_status=any
    RETURN        ${resp}

Login As Admin
    Create API Session
    ${resp}=    POST On Session    cinema    /auth/login
    ...         json={"email":"${ADMIN_EMAIL}","password":"${ADMIN_PASS}"}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    200
    ${token}=   Extract Token    ${resp}
    RETURN      ${token}

Login As User
    Create API Session
    ${resp}=    POST On Session    cinema    /auth/login
    ...         json={"email":"${USER_EMAIL}","password":"${USER_PASS}"}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    200
    ${token}=   Extract Token    ${resp}
    RETURN      ${token}

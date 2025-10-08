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
    [Arguments]    ${token}=
    ${headers}=    Run Keyword If    '${token}'!=''    Header With Token    ${token}
    ...            ELSE    Create Dictionary    Accept=application/json
    ${resp}=       GET On Session    cinema    /auth/me    headers=${headers}    expected_status=any
    RETURN         ${resp}

Get Token
    [Arguments]    ${resp}
    ${body}=        Set Variable     ${resp.json()}
    Dictionary Should Contain Key    ${body}    data
    ${data}=        Set Variable     ${body['data']}
    Dictionary Should Contain Key    ${data}    token
    ${token}=       Set Variable     ${data['token']}
    RETURN         ${token}

Change Password
    [Arguments]    ${token}    ${current_password}    ${new_password}
    ${headers}=    Header With Token    ${token}
    ${body}=       Create Dictionary    currentPassword=${current_password}    newPassword=${new_password}
    ${resp}=       PUT On Session    cinema    /auth/profile    headers=${headers}    json=${body}    expected_status=any
    RETURN         ${resp}
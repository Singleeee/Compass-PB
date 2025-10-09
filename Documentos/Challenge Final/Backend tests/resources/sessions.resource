*** Settings ***
Resource    env.resource

*** Keywords ***
Create Session (admin)
    [Arguments]    ${token}    ${payload}
    ${headers}=    Header With Token    ${token}
    ${resp}=       POST On Session    cinema    /sessions    headers=${headers}    json=${payload}    expected_status=any
    RETURN         ${resp}

Get Session By Id
    [Arguments]    ${id}
    ${resp}=       GET On Session    cinema    /sessions/${id}    expected_status=any
    RETURN         ${resp}

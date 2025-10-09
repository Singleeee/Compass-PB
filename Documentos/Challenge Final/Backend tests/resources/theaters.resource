*** Settings ***
Resource    env.resource

*** Keywords ***
Create Theater (admin)
    [Arguments]    ${token}    ${payload}
    ${headers}=    Header With Token    ${token}
    ${resp}=       POST On Session    cinema    /theaters    headers=${headers}    json=${payload}    expected_status=any
    RETURN         ${resp}

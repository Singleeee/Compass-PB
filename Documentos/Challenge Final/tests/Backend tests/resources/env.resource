*** Settings ***
Library           RequestsLibrary

*** Variables ***
${BASE_URL}       http://localhost:3000/api/v1
${ADMIN_EMAIL}    admin@example.com
${ADMIN_PASS}     admin123
${USER_EMAIL}     test@example.com
${USER_PASS}      password123

*** Keywords ***
Create API Session
    Create Session    cinema    ${BASE_URL}    disable_warnings=1

Header With Token
    [Arguments]    ${token}
    ${headers}=    Create Dictionary
    ...    Authorization=Bearer ${token}
    ...    Content-Type=application/json
    ...    Accept=application/json
    RETURN    ${headers}

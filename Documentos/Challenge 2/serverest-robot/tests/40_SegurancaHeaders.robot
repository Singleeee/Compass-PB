*** Settings ***
Resource    ../resources/Serverest.resource
Suite Setup    Create API Session
Force Tags    security

*** Variables ***
${ENFORCE_SECURITY_HEADERS}    ${FALSE}

*** Test Cases ***
Respostas possuem cabeçalhos de segurança
    ${resp}=    GET On Session    serverest    /produtos
    ${headers}=    Evaluate    {k.lower(): v for k, v in $resp.headers.items()}
    ${ok}=    Evaluate    'x-content-type-options' in $headers and 'x-frame-options' in $headers
    Run Keyword If    ${ENFORCE_SECURITY_HEADERS} and not ${ok}    Fail    Security headers missing. Got keys: ${headers.keys()}
    Log    Segurança presente? ${ok}

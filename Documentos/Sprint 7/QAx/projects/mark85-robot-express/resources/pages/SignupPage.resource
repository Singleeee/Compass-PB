*** Settings ***
Documentation        Elementos e ações da página de cadastro

Library              Browser

Resource             ../env.resource

*** Keywords ***

Go to signup page
    # Go To        ${BASE_URL}/signup
    Click            css=a[href]
    
    ${element}       Set Variable                css=h1

    # Checkpoint
    Wait For Elements State        ${element}        visible        5s
    Get Text                       ${element}        equal          Faça seu cadastro

Submit signup form
    [Arguments]    ${user}

    Fill Text        css=input[name=name]        ${user}[name]
    Fill Text        css=input[name=email]       ${user}[email]
    Fill Text        css=input[name=password]    ${user}[password]
    Click            css=button[type] >> text=Cadastrar

Notice should be
    [Arguments]    ${expected_text}

    ${element}     Set Variable    css=.notice p

    Wait For Elements State        ${element}        visible        5s
    Get Text                       ${element}        equal          ${expected_text}
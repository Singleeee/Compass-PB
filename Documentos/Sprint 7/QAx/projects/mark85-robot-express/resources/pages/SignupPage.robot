*** Settings ***
Documentation        Elementos e ações da página de cadastro

Library              Browser

Resource             ../env.robot

*** Keywords ***

Go to signup page
    # Go To        ${BASE_URL}/signup
    Click            css=a[href]

    # Checkpoint
    Wait For Elements State        css=h1        visible        5s
    Get Text                       css=h1        equal          Faça seu cadastro

Submit signup form
    [Arguments]    ${user}

    Fill Text        css=input[name=name]        ${user}[name]
    Fill Text        css=input[name=email]       ${user}[email]
    Fill Text        css=input[name=password]    ${user}[password]
    Click            css=button[type] >> text=Cadastrar

Notice should be
    [Arguments]    ${expected_text}

    Wait For Elements State        css=.notice p        visible        5s
    Get Text                       css=.notice p        equal          ${expected_text}
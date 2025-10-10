*** Settings ***
Documentation        Elementos e ações da página de cadastro

Library              Browser

Resource             ../env.resource

*** Keywords ***

Go to signup page
    # Go To        ${BASE_URL}/signup
    Click          css=li > a[class="btn"]
    
    ${element}       Set Variable                css=div > h1

    # Checkpoint
    Wait For Elements State        ${element}        visible        5s
    Get Text                       ${element}        equal          Cadastro

Submit signup form
    [Arguments]    ${user}

    Fill Text        css=input[id="name"]        ${user}[name]
    Fill Text        css=input[id="email"]       ${user}[email]
    Fill Text        css=input[id="password"]    ${user}[password]
    Fill Text        css=input[id="confirmPassword"]    ${user}[password]
    Click            css=button[type] >> text=Cadastrar

Notice should be
    [Arguments]    ${expected_text}

    ${element}     Set Variable    css=div[class="alerts-container"]

    Wait For Elements State        ${element}        visible        5s
    Get Text                       ${element}        equal          ${expected_text}

Alert should be
    [Arguments]    ${expected_text}
    
    Wait For Elements State        css=.alert-error >> text=${expected_text}
    ...                            visible        5s
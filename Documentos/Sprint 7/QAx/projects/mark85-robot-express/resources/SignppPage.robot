*** Settings ***
Documentation        Elementos e ações da página de cadastro

Library              Browser

*** Keywords ***
Signup login from
    [Arguments]    ${name}    ${email}    ${password}

    Fill Text        css=input[name=name]        ${name}
    Fill Text        css=input[name=email]       ${email}
    Fill Text        css=input[name=password]    ${password}
    Click            css=button[type] >> text=Cadastrar
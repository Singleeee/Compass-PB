*** Settings ***
Documentation        Cenários de teste para a página de cadastro de usuários

Library              Browser
Library              FakerLibrary

*** Test Cases ***
Deve poder cadastrar um novo usuário

    ${name}         FakerLibrary.Name
    ${email}        FakerLibrary.Free Email
    ${password}     Set Variable    adm123


    New Browser     browser=chromium    headless=False
    New Page        http://localhost:3000/signup

    # Checkpoint
    Wait For Elements State        css=h1        visible        5s
    Get Text                       css=h1        equal          Faça seu cadastro

    Fill Text        css=#name        ${name}
    Fill Text        css=#email       ${email}
    Fill Text        css=#password    ${password}
    Click            css=#buttonSignup

    Wait For Elements State        css=.notice p        visible        5s
    Get Text                       css=.notice p        equal          Boas vindas ao Mark85, o seu gerenciador de tarefas.
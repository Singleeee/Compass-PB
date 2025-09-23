*** Settings ***
Documentation        Cenários de teste para a página de cadastro de usuários

Resource             ../resources/base.robot
Library    FakerLibrary

Test Setup        Start Session
Test Teardown     Take Screenshot

*** Test Cases ***
Deve poder cadastrar um novo usuário
    [Tags]    novo

    ${user}         Create Dictionary
    ...             name=Rodrigo Dendro
    ...             email=rodrid@exemplo.com
    ...             password=adm123

    Remove user from database      ${user}[email]

    Go To        ${BASE_URL}/signup

    # Checkpoint
    Wait For Elements State        css=h1        visible        5s
    Get Text                       css=h1        equal          Faça seu cadastro

    Fill Text        css=#name        ${user}[name]
    Fill Text        css=#email       ${user}[email]
    Fill Text        css=#password    ${user}[password]
    Click            css=#buttonSignup

    Wait For Elements State        css=.notice p        visible        5s
    Get Text                       css=.notice p        equal          Boas vindas ao Mark85, o seu gerenciador de tarefas.


Não deve permitir o cadastro com email duplicado
    [Tags]    dup
    
    ${user}         Create Dictionary
    ...             name=Francisco Correa    
    ...             email=francc@exemplo.com
    ...             password=adm123

    Remove user from database      ${user}[email]
    Insert user from database      ${user}

    Go To        ${BASE_URL}/signup

    # Checkpoint
    Wait For Elements State        css=h1        visible        5s
    Get Text                       css=h1        equal          Faça seu cadastro

    Fill Text        css=#name        ${user}[name]
    Fill Text        css=#email       ${user}[email]
    Fill Text        css=#password    ${user}[password]
    Click            css=#buttonSignup

    Wait For Elements State        css=.notice p        visible        5s
    Get Text                       css=.notice p        equal          Oops! Já existe uma conta com o e-mail informado.


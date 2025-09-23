*** Settings ***
Documentation        Cenários de teste para a página de cadastro de usuários

Resource             ../resources/base.robot

*** Variables ***

${name}         Rodrigo Dendro
${email}        rodrid@exemplo.com
${password}     adm123

*** Test Cases ***
Deve poder cadastrar um novo usuário

    Start Session
    Go To        http://localhost:3000/signup

    # Checkpoint
    Wait For Elements State        css=h1        visible        5s
    Get Text                       css=h1        equal          Faça seu cadastro

    Fill Text        css=#name        ${name}
    Fill Text        css=#email       ${email}
    Fill Text        css=#password    ${password}
    Click            css=#buttonSignup

    Wait For Elements State        css=.notice p        visible        5s
    Get Text                       css=.notice p        equal          Boas vindas ao Mark85, o seu gerenciador de tarefas.
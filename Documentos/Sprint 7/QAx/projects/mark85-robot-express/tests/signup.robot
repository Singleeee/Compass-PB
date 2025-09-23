*** Settings ***
Documentation        Cenários de teste para a página de cadastro de usuários

Resource             ../resources/base.resource

Test Setup        Start Session
Test Teardown     Take Screenshot

*** Test Cases ***
Deve poder cadastrar um novo usuário
    [Tags]          novo

    ${user}         Create Dictionary
    ...             name=Rodrigo Dendro
    ...             email=rodrid@exemplo.com
    ...             password=adm123

    Remove user from database      ${user}[email]

    Go to signup page
    Submit signup form        ${user}
    Notice should be          Boas vindas ao Mark85, o seu gerenciador de tarefas.


Não deve permitir o cadastro com email duplicado
    [Tags]          dup
    
    ${user}         Create Dictionary
    ...             name=Francisco Correa    
    ...             email=francc@exemplo.com
    ...             password=adm123

    Remove user from database      ${user}[email]
    Insert user from database      ${user}

    Go to signup page
    Submit signup form        ${user}
    Notice should be          Oops! Já existe uma conta com o e-mail informado.

Campos obrigatórios
    [Tags]          required
    
    ${user}         Create Dictionary
    ...             name=${EMPTY}
    ...             email=${EMPTY}
    ...             password=${EMPTY}
    
    
    Go to signup page
    Submit signup form        ${user}

    Alert should be           Informe seu nome completo
    Alert should be           Informe seu e-email
    Alert should be           Informe uma senha com pelo menos 6 digitos

Não deve cadastrar com email incorreto
    [Tags]          inv_email

    ${user}         Create Dictionary
    ...             name=Ana Maria
    ...             email=ana@invalido
    ...             password=adm123

    Go to signup page
    Submit signup form        ${user}
    Alert should be           Digite um e-mail válido

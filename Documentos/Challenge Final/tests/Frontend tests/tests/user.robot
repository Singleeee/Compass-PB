*** Settings ***
Documentation        Cenários de teste para a página de cadastro de usuários

Resource             ../resources/base.resource

Test Setup        Start Session
Test Teardown     Take Screenshot

*** Test Cases ***
CT01: Deve poder cadastrar um novo usuário
    [Tags]          novo

    ${user}         Create Dictionary
    ...             name=Rodrigo Dendro
    ...             email=rodrid@exemplo.com
    ...             password=adm123

    Go to signup page
    Submit signup form        ${user}
    Notice should be          Conta criada com sucesso!


CT02: Não deve permitir o cadastro com email duplicado
    [Tags]          dup
    
    ${user}         Create Dictionary
    ...             name=Francisco Correa    
    ...             email=rodrid@exemplo.com
    ...             password=adm123

    Go to signup page
    Submit signup form        ${user}
    Notice should be          User already exists

CT03: Não deve cadastrar com email incorreto
    [Tags]          inv_email

    ${user}         Create Dictionary
    ...             name=Ana Maria
    ...             email=ana@invalido
    ...             password=adm123

    Go to signup page
    Submit signup form        ${user}
    Notice should be          Validation failed
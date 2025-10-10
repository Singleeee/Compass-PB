*** Settings ***
Documentation         Todas as páginas da aplicação devem abrir corretamente

Resource              ../resources/base.resource

Test Setup        Start Session
Test Teardown     Take Screenshot

*** Test Cases ***
CT01: Webapp deve estar online

    Browser.Get Title       equal        Cinema App

CT02: Página de cadastro deve abrir corretamente
    [Tags]    cadastro

    Click          css=li > a[class="btn"]
    Get Text       css=div > h1       equal      Cadastro

CT03: Página de cadastro deve abrir corretamente
    [Tags]    login

    Click With Options          css=header a[href="/login"]
    Get Text       css=div > h1       equal      Login

CT04: Página de filmes em cartaz deve abrir corretamente
    [Tags]    filmes

    Click With Options          css=header a[href="/movies"]
    Get Text       css=div > h1       equal      Filmes em Cartaz

CT05: Página inicial deve abrir novamente
    [Tags]    home
    
    Click With Options          css=header a[href="/movies"]
    Wait For Elements State     css=div > h1    visible
    Click With Options          css=header a[href="/"] >> text=Início
    Get Text       css=div > h1       equal      Welcome to Cinema App
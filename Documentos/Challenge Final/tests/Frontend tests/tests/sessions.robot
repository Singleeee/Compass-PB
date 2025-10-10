*** Settings ***
Documentation        Cenários de teste para a página de cadastro de usuários

Resource             ../resources/base.resource

Test Setup        Start Session
Test Teardown     Take Screenshot

*** Test Cases ***
CT01: Deve reservar um ingresso
    [Tags]          ingresso

    Login user
    Click          css=header a[href="/movies"]
    Wait For Elements State     css=div > h1    visible
    Click          css=div:nth-child(1) > div.movie-info > a
    Wait For Elements State     css=div > h1    visible
    Click          css=div > div > div:nth-child(1) > a
    Wait For Elements State     css=div > h1    visible
    Click          css=button[title="Fileira C, Assento 3 - Status: available"]
    Click          css=button[class="btn btn-primary checkout-button"]
    Wait For Elements State     css=div > h1    visible
    Click          css=div[class="payment-method "] > span >> text=PIX
    Wait For Elements State     css=div[class="payment-method selected"]
    Click          css=button[class="btn btn-primary btn-checkout"]
    Wait For Elements State     css=div[class="confirmation-header"]    visible
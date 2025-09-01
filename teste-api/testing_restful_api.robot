*** Settings ***
Documentation     Casos de teste para a API Restful Booker.
Resource          test_restful_api.resource

*** Test Cases ***
Cenário 1: Verificar API online
    Verificar se a API está online

Cenário 2: Listar reservas
    Listar reservas existentes

Cenário 3: Criar reserva
    ${token}=    Autenticar e obter token
    ${booking_id}=    Criar uma nova reserva

Cenário 4: Consultar reserva
    ${booking_id}=    Criar uma nova reserva
    Consultar reserva por ID    ${booking_id}

Cenário 5: Atualizar reserva
    ${token}=    Autenticar e obter token
    ${booking_id}=    Criar uma nova reserva
    Atualizar reserva por ID    ${booking_id}    ${token}

Cenário 6: Deletar reserva
    ${token}=    Autenticar e obter token
    ${booking_id}=    Criar uma nova reserva
    Deletar reserva    ${booking_id}    ${token}

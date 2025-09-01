*** Settings ***
Documentation     Casos de teste para a API Restful Booker.
Resource          test_restful_api.resource

*** Test Cases ***
Cenário 1: Verificar API online
    Verificar se a API está online

Cenário 2: Listar reservas
    Listar reservas existentes

Cenário 3: Criar, consultar, atualizar e deletar reserva
    ${token}=    Autenticar e obter token
    ${booking_id}=    Criar uma nova reserva
    Consultar reserva por ID    ${booking_id}
    Atualizar reserva por ID    ${booking_id}    ${token}
    Deletar reserva    ${booking_id}    ${token}

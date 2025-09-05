*** Settings ***
Documentation     Testes de validação para os casos de teste da API Restful Booker.
Resource          test_restful_api.resource
Library           Collections

*** Test Cases ***
Teste 1: Validar funcionamento do Cenário 1
    [Documentation]    Valida se o teste de API online funciona corretamente
    Verificar se a API está online

Teste 2: Validar funcionamento do Cenário 2
    [Documentation]    Valida se a listagem de reservas retorna dados
    Listar reservas existentes

Teste 3: Validar funcionamento do Cenário 3
    [Documentation]    Valida se a criação de reserva com token funciona
    ${token}=    Autenticar e obter token
    Should Not Be Empty    ${token}
    ${booking_id}=    Criar uma nova reserva
    Should Not Be Empty    ${booking_id}

Teste 4: Validar funcionamento do Cenário 4
    [Documentation]    Valida se a consulta de reserva por ID funciona
    ${booking_id}=    Criar uma nova reserva
    Should Not Be Empty    ${booking_id}
    Consultar reserva por ID    ${booking_id}

Teste 5: Validar funcionamento do Cenário 5
    [Documentation]    Valida se a atualização de reserva funciona
    ${token}=    Autenticar e obter token
    Should Not Be Empty    ${token}
    ${booking_id}=    Criar uma nova reserva
    Should Not Be Empty    ${booking_id}
    Atualizar reserva por ID    ${booking_id}    ${token}

Teste 6: Validar funcionamento do Cenário 6
    [Documentation]    Valida se a deleção de reserva funciona
    ${token}=    Autenticar e obter token
    Should Not Be Empty    ${token}
    ${booking_id}=    Criar uma nova reserva
    Should Not Be Empty    ${booking_id}
    Deletar reserva    ${booking_id}    ${token}

Teste 7: Validar fluxo completo CRUD
    [Documentation]    Testa o fluxo completo de operações CRUD
    # Criar
    ${token}=    Autenticar e obter token
    ${booking_id}=    Criar uma nova reserva
    
    # Ler
    Consultar reserva por ID    ${booking_id}
    
    # Atualizar
    Atualizar reserva por ID    ${booking_id}    ${token}
    
    # Deletar
    Deletar reserva    ${booking_id}    ${token}
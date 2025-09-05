*** Settings ***
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       https://restful-booker.herokuapp.com
${USERNAME}       admin
${PASSWORD}       password123

*** Keywords ***
Conectar na API
    Create Session    restful    ${BASE_URL}

Verificar se a API está online
    [Documentation]    Faz uma chamada no endpoint /ping para checar a saúde da API.
    Conectar na API
    ${response}=    GET On Session    restful    /ping
    Should Be Equal As Integers    ${response.status_code}    201

Autenticar e obter token
    [Documentation]    Cria um token de autenticação e valida a resposta.
    Conectar na API
    ${body}=    Create Dictionary    username=${USERNAME}    password=${PASSWORD}
    ${response}=    POST On Session    restful    /auth    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    token
    RETURN    ${response.json()['token']}

Listar reservas existentes
    [Documentation]    Busca a lista de reservas e valida se não está vazia.
    Conectar na API
    ${response}=    GET On Session   restful    /booking
    Should Be Equal As Integers    ${response.status_code}    200
    Should Not Be Empty    ${response.json()}    A lista de reservas não deveria estar vazia.

Criar uma nova reserva
    [Documentation]    Cria uma nova reserva com dados padrão e retorna o ID.
    Conectar na API
    ${datas_reserva}=    Create Dictionary
    ...    checkin=2025-09-01
    ...    checkout=2025-09-15

    ${booking_data}=    Create Dictionary
    ...    firstname=Mario
    ...    lastname=Carvalho
    ...    totalprice=250
    ...    depositpaid=${True}
    ...    bookingdates=${datas_reserva}
    ...    additionalneeds=Almoco

    ${response}=    POST On Session   restful    /booking    json=${booking_data}
    Should Be Equal As Integers    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    bookingid
    RETURN    ${response.json()['bookingid']}

Consultar reserva por ID
    [Documentation]    Busca os detalhes de uma reserva específica usando seu ID.
    [Arguments]    ${booking_id}
    Conectar na API
    ${response}=    GET On Session   restful    /booking/${booking_id}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Not Be Empty    ${response.json()}    Os detalhes da reserva não deveriam estar vazios.

Atualizar reserva por ID
    [Documentation]    Atualiza os dados de uma reserva existente.
    [Arguments]    ${booking_id}    ${token}
    Conectar na API
    ${datas_reserva}=    Create Dictionary
    ...    checkin=2025-10-01
    ...    checkout=2025-10-15

    ${booking_data}=    Create Dictionary
    ...    firstname=Alex
    ...    lastname=Malta
    ...    totalprice=300
    ...    depositpaid=${False}
    ...    bookingdates=${datas_reserva}
    ...    additionalneeds=Almoco

    ${headers}=    Create Dictionary    Cookie=token=${token}
    ${response}=    PUT On Session   restful    /booking/${booking_id}    json=${booking_data}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    Dictionary Should Contain Key    ${response.json()}    firstname

Deletar reserva
    [Documentation]    Deleta uma reserva específica usando o ID.
    [Arguments]    ${booking_id}    ${token}
    Conectar na API
    ${headers}=    Create Dictionary    Cookie=token=${token}
    ${response}=    DELETE On Session   restful    /booking/${booking_id}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    201

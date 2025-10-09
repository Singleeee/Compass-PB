*** Settings ***
Resource    ../resources/env.resource
Resource    ../resources/auth.resource
Resource    ../resources/payloads.resource
Resource    ../resources/movies.resource
Resource    ../resources/reservations.resource
Resource    ../resources/sessions.resource

Library     Collections
Suite Setup    Create API Session

*** Variables ***
${INVALID_ID}       abc
${NOT_FOUND_ID}     000000000000000000000000

*** Keywords ***
_Create Session With Reservation
    # Cria sessão e faz 1 reserva para gerar 409 em update/delete
    ${sid}=        _Create Clean Session (admin)
    ${user}=       Login As User
    ${headers}=    Header With Token    ${user}
    ${payload}=    Reservation Payload    ${sid}
    ${r}=          POST On Session    cinema    /reservations    headers=${headers}    json=${payload}    expected_status=any
    Should Be True    ${r.status_code} in [200,201]
    RETURN       ${sid}

*** Test Cases ***

# GET /sessions (público)
CT01:Listar sessões (200)
    ${resp}=    List Sessions
    Should Be Equal As Integers    ${resp.status_code}    200

CT02:Listar com filtros (movie, theater, date, limit, page) (200)
    _Ensure Movie & Theater
    ${params}=    Create Dictionary    movie=${TEST_MOVIE_ID}    theater=${TEST_THEATER_ID}    limit=5    page=1
    ${resp}=      List Sessions    ${params}
    Should Be Equal As Integers    ${resp.status_code}    200

# POST /sessions (admin)
CT03:Criar nova sessão (201)
    ${adm}=        Login As Admin
    ${payload}=    _Build Session Payload
    ${resp}=       Create Session (admin)    ${adm}    ${payload}
    Should Be True    ${resp.status_code} in [200,201]

CT04:Criar sessão - dados inválidos (400)
    ${adm}=        Login As Admin
    ${headers}=    Header With Token    ${adm}
    ${bad}=        Create Dictionary    movie=${EMPTY}
    ${resp}=       POST On Session    cinema    /sessions    headers=${headers}    json=${bad}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    400

CT05:Criar sessão - não autorizado (401)
    ${payload}=    _Build Session Payload
    ${resp}=       POST On Session    cinema    /sessions    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT06:Criar sessão - filme ou sala não encontrados (404)
    ${adm}=        Login As Admin
    # payload com ids inexistentes (ObjectId válido)
    ${p}=          Random Session Payload    000000000000000000000000    000000000000000000000000
    ${resp}=       Create Session (admin)    ${adm}    ${p}
    Should Be Equal As Integers    ${resp.status_code}    404

CT07:Criar sessão - conflito de horários (409)
    ${adm}=        Login As Admin
    ${p1}=         _Build Session Payload
    ${r1}=         Create Session (admin)    ${adm}    ${p1}
    Should Be True    ${r1.status_code} in [200,201]
    # tenta criar outra no mesmo horário/teatro
    ${p2}=         Set Variable    ${p1}
    ${r2}=         Create Session (admin)    ${adm}    ${p2}
    Should Be Equal As Integers    ${r2.status_code}    409

# GET /sessions/{id}
CT08:Detalhes da sessão (200)
    ${sid}=        _Create Clean Session (admin)
    ${resp}=       Get Session By Id    ${sid}
    Should Be Equal As Integers    ${resp.status_code}    200

CT09:Detalhes - sessão não encontrada (404)
    ${resp}=       Get Session By Id    ${NOT_FOUND_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

# PUT /sessions/{id}
CT10:Atualizar sessão (200)
    ${sid}=        _Create Clean Session (admin)
    ${adm}=        Login As Admin
    ${upd}=        _Build Session Payload
    ${resp}=       Update Session (admin)    ${adm}    ${sid}    ${upd}
    Should Be Equal As Integers    ${resp.status_code}    200

CT11:Atualizar - dados inválidos (400)
    ${sid}=        _Create Clean Session (admin)
    ${adm}=        Login As Admin
    ${bad}=        Create Dictionary    startTime=${EMPTY}
    ${resp}=       Update Session (admin)    ${adm}    ${sid}    ${bad}
    Should Be Equal As Integers    ${resp.status_code}    400

CT12:Atualizar - não autorizado (401)
    ${sid}=        _Create Clean Session (admin)
    ${upd}=        _Build Session Payload
    ${resp}=       PUT On Session    cinema    /sessions/${sid}    json=${upd}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT13:Atualizar - negado (usuário comum) (403)
    ${sid}=        _Create Clean Session (admin)
    ${user}=       Login As User
    ${headers}=    Header With Token    ${user}
    ${upd}=        _Build Session Payload
    ${resp}=       PUT On Session    cinema    /sessions/${sid}    headers=${headers}    json=${upd}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT14:Atualizar - sessão não encontrada (404)
    ${adm}=        Login As Admin
    ${upd}=        _Build Session Payload
    ${resp}=       Update Session (admin)    ${adm}    ${NOT_FOUND_ID}    ${upd}
    Should Be Equal As Integers    ${resp.status_code}    404

CT15:Atualizar - possui reservas (409)
    ${sid}=        _Create Session With Reservation
    ${adm}=        Login As Admin
    ${upd}=        _Build Session Payload
    ${resp}=       Update Session (admin)    ${adm}    ${sid}    ${upd}
    Should Be Equal As Integers    ${resp.status_code}    409

# DELETE /sessions/{id}
CT16:Excluir sessão (200)
    ${sid}=        _Create Clean Session (admin)
    ${adm}=        Login As Admin
    ${resp}=       Delete Session (admin)    ${adm}    ${sid}
    Should Be True    ${resp.status_code} in [200,204]

CT17:Excluir - não autorizado (401)
    ${sid}=        _Create Clean Session (admin)
    ${resp}=       DELETE On Session    cinema    /sessions/${sid}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT18:Excluir - negado (usuário comum) (403)
    ${sid}=        _Create Clean Session (admin)
    ${user}=       Login As User
    ${headers}=    Header With Token    ${user}
    ${resp}=       DELETE On Session    cinema    /sessions/${sid}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT19:Excluir - sessão não encontrada (404)
    ${adm}=        Login As Admin
    ${resp}=       Delete Session (admin)    ${adm}    ${NOT_FOUND_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

CT20:Excluir - não pode excluir com reservas confirmadas (409)
    ${sid}=        _Create Session With Reservation
    ${adm}=        Login As Admin
    ${resp}=       Delete Session (admin)    ${adm}    ${sid}
    Should Be Equal As Integers    ${resp.status_code}    409

# PUT /sessions/{id}/reset  (retornar todas as cadeiras a disponíveis)
CT21:Reset seats - sucesso (200)
    ${sid}=        _Create Session With Reservation
    ${adm}=        Login As Admin
    ${resp}=       Reset Session Seats (admin)    ${adm}    ${sid}
    Should Be Equal As Integers    ${resp.status_code}    200

CT22:Reset seats - não autorizado (401)
    ${sid}=        _Create Session With Reservation
    ${resp}=       PUT On Session    cinema    /sessions/${sid}/reset    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT23:Reset seats - negado (usuário comum) (403)
    ${sid}=        _Create Session With Reservation
    ${user}=       Login As User
    ${headers}=    Header With Token    ${user}
    ${resp}=       PUT On Session    cinema    /sessions/${sid}/reset    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT24:Reset seats - sessão não encontrada (404)
    ${adm}=        Login As Admin
    ${resp}=       Reset Session Seats (admin)    ${adm}    ${NOT_FOUND_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

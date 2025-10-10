*** Settings ***
Resource    ../resources/env.resource
Resource    ../resources/auth.resource
Resource    ../resources/sessions.resource
Resource    ../resources/theaters.resource
Library     Collections
Suite Setup    Create API Session

*** Variables ***
${INVALID_ID}       abc
${NOT_FOUND_ID}     000000000000000000000000

*** Test Cases ***
CT01:Listar salas (200)
    ${resp}=    List Theaters
    Should Be Equal As Integers    ${resp.status_code}    200

CT02:Listar com filtros (type, sort, limit, page) (200)
    ${resp}=    List Theaters    standard    name    5    1
    Should Be Equal As Integers    ${resp.status_code}    200

CT03:Criar sala (201)
    ${adm}=     Login As Admin
    ${body}=    Valid Theater Payload
    ${resp}=    Create Theater (admin)    ${adm}    ${body}
    Should Be True    ${resp.status_code} in [200,201]

CT04:Criar sala - dados inválidos (400)
    ${adm}=     Login As Admin
    ${bad}=     Create Dictionary    name=${EMPTY}
    ${resp}=    Create Theater (admin)    ${adm}    ${bad}
    Should Be Equal As Integers    ${resp.status_code}    400

CT05:Criar sala - não autorizado (401)
    ${body}=    Valid Theater Payload
    ${resp}=    POST On Session    cinema    /theaters    json=${body}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT06:Criar sala - negado (usuário comum) (403)
    ${user}=    Login As User
    ${headers}= Header With Token    ${user}
    ${body}=    Valid Theater Payload
    ${resp}=    POST On Session    cinema    /theaters    headers=${headers}    json=${body}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT07:Criar sala - nome duplicado (409)
    ${adm}=     Login As Admin
    ${body}=    Valid Theater Payload
    ${r1}=      Create Theater (admin)    ${adm}    ${body}
    Should Be True    ${r1.status_code} in [200,201]
    ${r2}=      Create Theater (admin)    ${adm}    ${body}
    # Se a API não tratar duplicidade, registre bug
    Run Keyword If    ${r2.status_code} != 409    Log To Console    \n[BUG] Esperado 409 ao duplicar nome; recebido ${r2.status_code} com body: ${r2.text}
    Should Be Equal As Integers    ${r2.status_code}    409

CT08:Detalhes da sala (200)
    ${id}=      _Create Theater (admin)
    ${resp}=    Get Theater By Id    ${id}
    Should Be Equal As Integers    ${resp.status_code}    200

CT09:Detalhes - sala não encontrada (404)
    ${resp}=    Get Theater By Id    ${NOT_FOUND_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

CT10:Atualizar sala (200)
    ${id}=      _Create Theater (admin)
    ${adm}=     Login As Admin
    ${upd}=     Valid Theater Payload
    ${upd}=     Set To Dictionary    ${upd}    name=${upd['name']}_upd
    ${resp}=    Update Theater (admin)    ${adm}    ${id}    ${upd}
    Should Be Equal As Integers    ${resp.status_code}    200

CT11:Atualizar - dados inválidos (400)
    ${id}=      _Create Theater (admin)
    ${adm}=     Login As Admin
    ${bad}=     Create Dictionary    capacity=${EMPTY}
    ${resp}=    Update Theater (admin)    ${adm}    ${id}    ${bad}
    Should Be Equal As Integers    ${resp.status_code}    400

CT12:Atualizar - não autorizado (401)
    ${id}=      _Create Theater (admin)
    ${upd}=     Valid Theater Payload
    ${resp}=    PUT On Session    cinema    /theaters/${id}    json=${upd}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT13:Atualizar - negado (usuário comum) (403)
    ${id}=      _Create Theater (admin)
    ${user}=    Login As User
    ${headers}= Header With Token    ${user}
    ${upd}=     Valid Theater Payload
    ${resp}=    PUT On Session    cinema    /theaters/${id}    headers=${headers}    json=${upd}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT14:Atualizar - sala não encontrada (404)
    ${adm}=     Login As Admin
    ${upd}=     Valid Theater Payload
    ${resp}=    Update Theater (admin)    ${adm}    ${NOT_FOUND_ID}    ${upd}
    Should Be Equal As Integers    ${resp.status_code}    404

CT15:Atualizar - nome já em uso (409)
    ${adm}=     Login As Admin
    ${t1}=      Valid Theater Payload
    ${t2}=      Valid Theater Payload
    ${r1}=      Create Theater (admin)    ${adm}    ${t1}
    ${id1}=     _Extract Id    ${r1}
    ${r2}=      Create Theater (admin)    ${adm}    ${t2}
    ${id2}=     _Extract Id    ${r2}
    ${upd}=     Create Dictionary    name=${t1['name']}
    ${r}=       Update Theater (admin)    ${adm}    ${id2}    ${upd}
    Run Keyword If    ${r.status_code} != 409    Log To Console    \n[BUG] Esperado 409 ao atualizar para nome duplicado; recebido ${r.status_code} body=${r.text}
    Should Be Equal As Integers    ${r.status_code}    409

CT16:Excluir sala (200)
    ${id}=      _Create Theater (admin)
    ${adm}=     Login As Admin
    ${resp}=    Delete Theater (admin)    ${adm}    ${id}
    Should Be True    ${resp.status_code} in [200,204]

CT17:Excluir - não autorizado (401)
    ${id}=      _Create Theater (admin)
    ${resp}=    DELETE On Session    cinema    /theaters/${id}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT18:Excluir - negado (usuário comum) (403)
    ${id}=      _Create Theater (admin)
    ${user}=    Login As User
    ${headers}= Header With Token    ${user}
    ${resp}=    DELETE On Session    cinema    /theaters/${id}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT19:Excluir - sala não encontrada (404)
    ${adm}=     Login As Admin
    ${resp}=    Delete Theater (admin)    ${adm}    ${NOT_FOUND_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

CT20:Excluir - não pode com sessões ativas (409)
    [Tags]    bug
    ${theater_id}=    _Create Theater With Active Session
    ${adm}=           Login As Admin
    ${r}=             Delete Theater (admin)    ${adm}    ${theater_id}
    Run Keyword If    ${r.status_code} != 409    Log To Console    \n[BUG] Esperado 409 ao excluir sala com sessão ativa; recebido ${r.status_code} body=${r.text}
    Should Be Equal As Integers    ${r.status_code}    409

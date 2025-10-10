*** Settings ***
Resource    ../resources/env.resource
Resource    ../resources/auth.resource
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

CT02:Criar sala (201)
    ${adm}=      Login As Admin
    ${payload}=  _Build Theater Payload
    ${resp}=     Create Theater (admin)    ${adm}    ${payload}
    Should Be True    ${resp.status_code} in [200,201]

CT03:Criar sala - dados inválidos (400)
    ${adm}=      Login As Admin
    ${bad}=      Invalid Theater Payload
    ${resp}=     Create Theater (admin)    ${adm}    ${bad}
    Should Be Equal As Integers    ${resp.status_code}    400

CT04:Criar sala - sem token (401)
    ${p}=        _Build Theater Payload
    ${resp}=     POST On Session    cinema    /theaters    json=${p}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT05:Criar sala - negado (403)
    ${user}=     Login As User
    ${headers}=  Header (Token)    ${user}
    ${p}=        _Build Theater Payload
    ${resp}=     POST On Session    cinema    /theaters    headers=${headers}    json=${p}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT06:Detalhes da sala (200)
    ${id}=       _Create Clean Theater (admin)
    ${resp}=     Theater Details    ${id}
    Should Be Equal As Integers    ${resp.status_code}    200

CT07:Detalhes - não encontrada (404)
    ${resp}=     Theater Details    ${NOT_FOUND_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

CT08:Atualizar sala (200)
    ${id}=       _Create Clean Theater (admin)
    ${adm}=      Login As Admin
    ${upd}=      Valid Theater Payload    ${None}    150    VIP
    ${resp}=     Update Theater (admin)    ${adm}    ${id}    ${upd}
    Should Be Equal As Integers    ${resp.status_code}    200

CT09:Atualizar - dados inválidos (400)
    ${id}=       _Create Clean Theater (admin)
    ${adm}=      Login As Admin
    ${bad}=      Invalid Theater Payload
    ${resp}=     Update Theater (admin)    ${adm}    ${id}    ${bad}
    Should Be Equal As Integers    ${resp.status_code}    400

CT10:Atualizar - sem token (401)
    ${id}=       _Create Clean Theater (admin)
    ${upd}=      Valid Theater Payload
    ${resp}=     PUT On Session    cinema    /theaters/${id}    json=${upd}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT11:Atualizar - negado (403)
    ${id}=       _Create Clean Theater (admin)
    ${user}=     Login As User
    ${headers}=  Header (Token)    ${user}
    ${upd}=      Valid Theater Payload
    ${resp}=     PUT On Session    cinema    /theaters/${id}    headers=${headers}    json=${upd}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT12:Atualizar - sala não encontrada (404)
    ${adm}=      Login As Admin
    ${upd}=      Valid Theater Payload
    ${resp}=     Update Theater (admin)    ${adm}    ${NOT_FOUND_ID}    ${upd}
    Should Be Equal As Integers    ${resp.status_code}    404

CT13:Excluir sala (200/204)
    ${id}=       _Create Clean Theater (admin)
    ${adm}=      Login As Admin
    ${resp}=     Delete Theater (admin)    ${adm}    ${id}
    Should Be True    ${resp.status_code} in [200,204]

CT14:Excluir - sem token (401)
    ${id}=       _Create Clean Theater (admin)
    ${resp}=     DELETE On Session    cinema    /theaters/${id}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT15:Excluir - negado (403)
    ${id}=       _Create Clean Theater (admin)
    ${user}=     Login As User
    ${headers}=  Header (Token)    ${user}
    ${resp}=     DELETE On Session    cinema    /theaters/${id}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT16:Excluir - não encontrada (404)
    ${adm}=      Login As Admin
    ${resp}=     Delete Theater (admin)    ${adm}    ${NOT_FOUND_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

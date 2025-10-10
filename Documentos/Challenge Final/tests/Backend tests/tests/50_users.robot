*** Settings ***
Resource    ../resources/env.resource
Resource    ../resources/auth.resource
Resource    ../resources/users.resource
Library     Collections

Suite Setup    Create API Session

*** Variables ***
${NOT_FOUND_ID}     000000000000000000000000

*** Test Cases ***
CT01:Listar usuários (admin) 200
    ${adm}=     Login As Admin
    ${H}=       Header (Token)    ${adm}
    ${resp}=    GET On Session    cinema    /users    headers=${H}    params={'page':1,'limit':10}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    200

CT02:Listar usuários - sem token (401)
    ${resp}=    GET On Session    cinema    /users    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT03:Listar usuários - negado (403)
    ${usr}=     Login As User
    ${H}=       Header (Token)    ${usr}
    ${resp}=    GET On Session    cinema    /users    headers=${H}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT04:Detalhes do usuário (200)
    ${adm}=     Login As Admin
    ${uid}=     _Create Random User
    ${H}=       Header (Token)    ${adm}
    ${resp}=    GET On Session    cinema    /users/${uid}    headers=${H}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    200

CT05:Detalhes - não encontrado (404)
    ${adm}=     Login As Admin
    ${H}=       Header (Token)    ${adm}
    ${resp}=    GET On Session    cinema    /users/${NOT_FOUND_ID}    headers=${H}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    404

CT06:Atualizar usuário (200)
    ${adm}=     Login As Admin
    ${uid}=     _Create Random User
    ${upd}=     Valid User Update Payload
    ${H}=       Header (Token)    ${adm}
    ${resp}=    PUT On Session    cinema    /users/${uid}    headers=${H}    json=${upd}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    200

CT07:Atualizar - dados inválidos (400)
    ${adm}=     Login As Admin
    ${uid}=     _Create Random User
    ${bad}=     Invalid User Update Payload
    ${H}=       Header (Token)    ${adm}
    ${resp}=    PUT On Session    cinema    /users/${uid}    headers=${H}    json=${bad}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    400

CT08:Atualizar - sem token (401)
    ${uid}=     _Create Random User
    ${upd}=     Valid User Update Payload
    ${resp}=    PUT On Session    cinema    /users/${uid}    json=${upd}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT09:Atualizar - negado (usuário comum) (403)
    ${uid}=     _Create Random User
    ${usr}=     Login As User
    ${H}=       Header (Token)    ${usr}
    ${upd}=     Valid User Update Payload
    ${resp}=    PUT On Session    cinema    /users/${uid}    headers=${H}    json=${upd}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT10:Atualizar - não encontrado (404)
    ${adm}=     Login As Admin
    ${H}=       Header (Token)    ${adm}
    ${upd}=     Valid User Update Payload
    ${resp}=    PUT On Session    cinema    /users/${NOT_FOUND_ID}    headers=${H}    json=${upd}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    404

CT11:Excluir usuário (200/204)
    ${adm}=     Login As Admin
    ${uid}=     _Create Random User
    ${H}=       Header (Token)    ${adm}
    ${resp}=    DELETE On Session    cinema    /users/${uid}    headers=${H}    expected_status=any
    Should Be True    ${resp.status_code} in [200,204]

CT12:Excluir - sem token (401)
    ${uid}=     _Create Random User
    ${resp}=    DELETE On Session    cinema    /users/${uid}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT13:Excluir - negado (usuário comum) (403)
    ${uid}=     _Create Random User
    ${usr}=     Login As User
    ${H}=       Header (Token)    ${usr}
    ${resp}=    DELETE On Session    cinema    /users/${uid}    headers=${H}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT14:Excluir - não encontrado (404)
    ${adm}=     Login As Admin
    ${H}=       Header (Token)    ${adm}
    ${resp}=    DELETE On Session    cinema    /users/${NOT_FOUND_ID}    headers=${H}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    404

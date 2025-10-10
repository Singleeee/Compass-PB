*** Settings ***
Resource    ../resources/env.resource
Resource    ../resources/auth.resource
Resource    ../resources/reservations.resource
Resource    ../resources/sessions.resource
Resource    ../resources/users.resource
Library     Collections
Suite Setup    Create API Session

*** Variables ***
${INVALID_ID}       abc
${NOT_FOUND_ID}     000000000000000000000000

*** Test Cases ***
CT01:Listar usuários (admin) 200
    ${adm}=    Login As Admin
    ${resp}=   List Users (admin)    ${adm}
    Should Be Equal As Integers    ${resp.status_code}    200

CT02:Listar usuários - sem token (401)
    ${resp}=   GET On Session    cinema    /users    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT03:Listar usuários - usuário comum (403)
    ${user}=   Login As User
    ${headers}= Header With Token    ${user}
    ${resp}=   GET On Session    cinema    /users    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT04:Detalhes do usuário (admin) 200
    ${adm}=    Login As Admin
    # usa o próprio admin
    ${me}=     Get Me    ${adm}
    ${uid}=    Set Variable    ${me.json()}['data']['_id']
    ${resp}=   Get User By Id (admin)    ${adm}    ${uid}
    Should Be Equal As Integers    ${resp.status_code}    200

CT05:Detalhes - não autorizado (401)
    ${adm}=    Login As Admin
    ${me}=     Get Me    ${adm}
    ${uid}=    Set Variable    ${me.json()}['data']['_id']
    ${resp}=   GET On Session    cinema    /users/${uid}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT06:Detalhes - negado (403)
    ${user}=   Login As User
    ${headers}= Header With Token    ${user}
    ${adm}=    Login As Admin
    ${me}=     Get Me    ${adm}
    ${uid}=    Set Variable    ${me.json()}['data']['_id']
    ${resp}=   GET On Session    cinema    /users/${uid}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT07:Detalhes - usuário não encontrado (404)
    ${adm}=    Login As Admin
    ${resp}=   Get User By Id (admin)    ${adm}    ${NOT_FOUND_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

CT08:Atualizar usuário (admin) 200
    ${adm}=    Login As Admin
    ${tmp_id}    ${tmp_email}    ${tmp_pw}=    _Create Temp User
    ${upd}=    User Update Payload
    ${resp}=   Update User (admin)    ${adm}    ${tmp_id}    ${upd}
    Should Be Equal As Integers    ${resp.status_code}    200

CT09:Atualizar - dados inválidos (400)
    ${adm}=    Login As Admin
    ${tmp_id}    ${tmp_email}    ${tmp_pw}=    _Create Temp User
    ${bad}=    Create Dictionary    email=${EMPTY}
    ${resp}=   Update User (admin)    ${adm}    ${tmp_id}    ${bad}
    Should Be Equal As Integers    ${resp.status_code}    400

CT10:Atualizar - não autorizado (401)
    ${tmp_id}    ${tmp_email}    ${tmp_pw}=    _Create Temp User
    ${upd}=    User Update Payload
    ${resp}=   PUT On Session    cinema    /users/${tmp_id}    json=${upd}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT11:Atualizar - negado (403)
    ${user}=   Login As User
    ${headers}= Header With Token    ${user}
    ${tmp_id}    ${tmp_email}    ${tmp_pw}=    _Create Temp User
    ${upd}=    User Update Payload
    ${resp}=   PUT On Session    cinema    /users/${tmp_id}    headers=${headers}    json=${upd}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT12:Atualizar - usuário não encontrado (404)
    ${adm}=    Login As Admin
    ${upd}=    User Update Payload
    ${resp}=   Update User (admin)    ${adm}    ${NOT_FOUND_ID}    ${upd}
    Should Be Equal As Integers    ${resp.status_code}    404

CT13:Atualizar - email já em uso (409)
    ${adm}=    Login As Admin
    ${u1_id}    ${u1_email}    ${u1_pw}=    _Create Temp User
    ${u2_id}    ${u2_email}    ${u2_pw}=    _Create Temp User
    ${dup}=    Create Dictionary    email=${u1_email}
    ${r}=      Update User (admin)    ${adm}    ${u2_id}    ${dup}
    Run Keyword If    ${r.status_code} != 409    Log To Console    \n[BUG] Esperado 409 ao atualizar email duplicado; recebido ${r.status_code} body=${r.text}
    Should Be Equal As Integers    ${r.status_code}    409

CT14:Excluir usuário (admin) 200
    ${adm}=    Login As Admin
    ${uid}    ${em}    ${pw}=    _Create Temp User
    ${resp}=   Delete User (admin)    ${adm}    ${uid}
    Should Be True    ${resp.status_code} in [200,204]

CT15:Excluir - não autorizado (401)
    ${uid}    ${em}    ${pw}=    _Create Temp User
    ${resp}=   DELETE On Session    cinema    /users/${uid}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    401

CT16:Excluir - negado (403)
    ${user}=   Login As User
    ${headers}= Header With Token    ${user}
    ${uid}    ${em}    ${pw}=    _Create Temp User
    ${resp}=   DELETE On Session    cinema    /users/${uid}    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

CT17:Excluir - usuário não encontrado (404)
    ${adm}=    Login As Admin
    ${resp}=   Delete User (admin)    ${adm}    ${NOT_FOUND_ID}
    Should Be Equal As Integers    ${resp.status_code}    404

CT18:Excluir - não pode excluir usuário com reservas ativas (409)
    [Tags]    bug
    ${adm}=    Login As Admin
    ${uid}=    _Create User With Reservation
    ${r}=      Delete User (admin)    ${adm}    ${uid}
    Run Keyword If    ${r.status_code} != 409    Log To Console    \n[BUG] Esperado 409 ao excluir usuário com reservas; recebido ${r.status_code} body=${r.text}
    Should Be Equal As Integers    ${r.status_code}    409

*** Settings ***
Resource    ../resources/auth.resource
Resource    ../resources/movies.resource
Resource    ../resources/payloads.resource
Resource    ../resources/env.resource
Library     Collections

Suite Setup    Create API Session

*** Variables ***
${INVALID_ID}       abc
${NOT_FOUND_ID}     000000000000000000000000

*** Keywords ***
Verify Token Works
    [Arguments]    ${token}
    ${headers}=    Header With Token    ${token}
    ${resp}=       GET On Session    cinema    /auth/me    headers=${headers}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    200

Create Movie As Admin
    ${adm}=         Login As Admin
    Verify Token Works    ${adm}
    ${payload}=     Movie Payload (Docs)
    ${resp}=        Create Movie (admin)    ${adm}    ${payload}
    Should Be True  ${resp.status_code} in [200,201]
    ${id}=          movies.Extract Movie Id    ${resp}
    Should Not Be Empty    ${id}
    RETURN          ${id}

Update Movie As Admin
    [Arguments]     ${movie_id}
    ${adm}=         Login As Admin
    Verify Token Works    ${adm}
    ${headers}=     Header With Token    ${adm}
    ${upd}=         Movie Payload (Docs)
    ${upd}=         Set To Dictionary    ${upd}    title=${upd['title']}_updated
    ${resp}=        PUT On Session    cinema    /movies/${movie_id}    headers=${headers}    json=${upd}    expected_status=any
    RETURN          ${resp}

*** Test Cases ***

# --------------- GET - Buscar todos os filmes ---------------
CT01:Deve listar filmes (200)
    ${resp}=    Get Movies
    Should Be Equal As Integers    ${resp.status_code}    200

CT02:Deve aceitar filtros (title, genre, sort, limit, page) (200)
    ${params}=  Create Dictionary    title=Movie    genre=Drama    sort=title    limit=5    page=1
    ${resp}=    GET On Session    cinema    /movies    params=${params}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    200

# --------------- POST - Criar um novo filme ---------------
CT03:Deve criar filme com admin (201/200)
    ${adm}=         Login As Admin
    Verify Token Works    ${adm}
    ${payload}=     Movie Payload (Docs)
    ${resp}=        Create Movie (admin)    ${adm}    ${payload}
    Should Be True  ${resp.status_code} in [200,201]
    ${movie_id}=    movies.Extract Movie Id    ${resp}
    Should Not Be Empty    ${movie_id}
    Set Test Variable    ${MOVIE_ID}    ${movie_id}

CT04:Deve falhar com dados inválidos (400)
    ${adm}=         Login As Admin
    Verify Token Works    ${adm}
    ${headers}=     Header With Token    ${adm}
    ${bad}=         Invalid Movie Payload (Docs)
    ${resp}=        POST On Session    cinema    /movies    headers=${headers}    json=${bad}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    400

CT05:Deve falhar sem token (401)
    ${payload}=     Movie Payload (Docs)
    ${resp}=        POST On Session    cinema    /movies      json=${payload}    expected_status=any
    Should Be Equal As Integers        ${resp.status_code}    401

CT06:Deve falhar com usuário comum (403)
    ${user}=        Login As User
    Verify Token Works    ${user}
    ${headers}=     Header With Token    ${user}
    ${payload}=     Movie Payload (Docs)
    ${resp}=        POST On Session    cinema    /movies    headers=${headers}    json=${payload}    expected_status=any
    Should Be Equal As Integers    ${resp.status_code}    403

# --------------- GET - Buscar filme por ID ---------------
CT08:Detalhes do filme (200)
    ${ID}=          Create Movie As Admin
    ${resp}=        Get Movie By Id    ${ID}
    Should Be Equal As Integers    ${resp.status_code}    200

CT09:Formato de ID inválido (400 ou 404)
    ${resp}=        Get Movie By Id    ${INVALID_ID}
    Should Be True  ${resp.status_code} in [400,404]

CT10:Filme não encontrado (404)
    ${resp}=        Get Movie By Id    ${NOT_FOUND_ID}
    Should Be Equal As Integers       ${resp.status_code}    404

# --------------- PUT - Atualizar um filme ---------------
CT11:Atualizar com admin (200)
    ${ID}=          Create Movie As Admin
    ${resp}=        Update Movie As Admin    ${ID}
    Should Be Equal As Integers       ${resp.status_code}    200

CT12:Dados inválidos (400)
    ${adm}=         Login As Admin
    Verify Token Works    ${adm}
    ${headers}=     Header With Token    ${adm}
    ${bad}=         Invalid Movie Payload (Docs)
    ${ID}=          Create Movie As Admin
    ${resp}=        PUT On Session    cinema    /movies/${ID}    headers=${headers}    json=${bad}    expected_status=any
    Should Be Equal As Integers       ${resp.status_code}    400

CT13:Não autorizado (401)
    ${upd}=         Movie Payload (Docs)
    ${ID}=          Create Movie As Admin
    ${resp}=        PUT On Session    cinema    /movies/${ID}    json=${upd}    expected_status=any
    Should Be Equal As Integers       ${resp.status_code}    401

CT14:Negado (usuário comum) (403)
    ${user}=        Login As User
    Verify Token Works    ${user}
    ${headers}=     Header With Token    ${user}
    ${upd}=         Movie Payload (Docs)
    ${ID}=          Create Movie As Admin
    ${resp}=        PUT On Session    cinema    /movies/${ID}    headers=${headers}    json=${upd}    expected_status=any
    Should Be Equal As Integers       ${resp.status_code}    403

CT15:Filme não encontrado (404)
    ${adm}=         Login As Admin
    Verify Token Works    ${adm}
    ${headers}=     Header With Token    ${adm}
    ${upd}=         Movie Payload (Docs)
    ${resp}=        PUT On Session    cinema    /movies/${NOT_FOUND_ID}    headers=${headers}    json=${upd}    expected_status=any
    Should Be Equal As Integers       ${resp.status_code}    404

# --------------- DELETE - Excluir um filme ---------------
CT16:Excluir com admin (200 ou 204)
    ${ID}=          Create Movie As Admin
    ${adm}=         Login As Admin
    Verify Token Works    ${adm}
    ${headers}=     Header With Token    ${adm}
    ${resp}=        DELETE On Session    cinema    /movies/${ID}    headers=${headers}    expected_status=any
    Should Be True  ${resp.status_code} in [200,204]

CT17:Não autorizado (401)
    ${ID}=          Create Movie As Admin
    ${resp}=        DELETE On Session    cinema    /movies/${ID}    expected_status=any
    Should Be Equal As Integers       ${resp.status_code}    401
    # limpa com admin
    ${adm}=         Login As Admin
    Verify Token Works    ${adm}
    ${headers}=     Header With Token    ${adm}
    DELETE On Session    cinema    /movies/${ID}    headers=${headers}    expected_status=any

CT18:Negado (usuário comum) (403)
    ${ID}=          Create Movie As Admin
    ${user}=        Login As User
    Verify Token Works    ${user}
    ${headers}=     Header With Token    ${user}
    ${resp}=        DELETE On Session    cinema    /movies/${ID}    headers=${headers}    expected_status=any
    Should Be Equal As Integers       ${resp.status_code}    403
    # limpa com admin
    ${adm}=         Login As Admin
    Verify Token Works    ${adm}
    ${headers}=     Header With Token    ${adm}
    DELETE On Session    cinema    /movies/${ID}    headers=${headers}    expected_status=any

CT19:Filme não encontrado (404)
    ${adm}=         Login As Admin
    Verify Token Works    ${adm}
    ${headers}=     Header With Token    ${adm}
    ${resp}=        DELETE On Session    cinema    /movies/${NOT_FOUND_ID}    headers=${headers}    expected_status=any
    Should Be Equal As Integers       ${resp.status_code}    404

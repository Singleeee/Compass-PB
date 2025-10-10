*** Settings ***
Resource    env.resource

*** Keywords ***
Create Movie (admin)
    [Arguments]    ${token}    ${payload}
    ${headers}=    Header With Token    ${token}
    ${resp}=       POST On Session    cinema    /movies    headers=${headers}    json=${payload}    expected_status=any
    RETURN         ${resp}

Get Movies
    ${resp}=       GET On Session    cinema    /movies    expected_status=any
    RETURN         ${resp}

Get Movie By Id
    [Arguments]    ${movie_id}
    ${resp}=       GET On Session    cinema    /movies/${movie_id}    expected_status=any
    RETURN         ${resp}

Update Movie (admin)
    [Arguments]    ${token}    ${movie_id}    ${payload}
    ${headers}=    Header With Token    ${token}
    ${resp}=       PUT On Session    cinema    /movies/${movie_id}    headers=${headers}    json=${payload}    expected_status=any
    RETURN         ${resp}

Delete Movie (admin)
    [Arguments]    ${token}    ${movie_id}
    ${headers}=    Header With Token    ${token}
    ${resp}=       DELETE On Session    cinema    /movies/${movie_id}    headers=${headers}    expected_status=any
    RETURN         ${resp}

Extract Movie Id
    [Arguments]    ${resp}
    ${body}=       Set Variable    ${resp.json()}
    ${id}=         Run Keyword If    '_id' in ${body}                 Set Variable    ${body['_id']}
    ...            ELSE IF           'data' in ${body} and '_id' in ${body['data']}    Set Variable    ${body['data']['_id']}
    ...            ELSE                                               Set Variable    ${EMPTY}
    RETURN         ${id}

*** Settings ***
Resource    ../resources/Serverest.resource
Suite Setup    Create API Session

*** Test Cases ***
CRUD Usuários - cadastrar, buscar por id e excluir
    ${suffix}=    Generate Random String    6    [LOWER]
    ${email}=     Set Variable    qa+${suffix}@example.com
    ${body}=      Create Dictionary    nome=QA ${suffix}    email=${email}    password=1234    administrador=false
    ${resp}=      POST On Session    serverest    /usuarios    json=${body}
    Status Should Be    201    ${resp}
    ${resp_json}=    Evaluate    json.loads($resp.text)    json
    ${id}=        Get From Dictionary    ${resp_json}    _id

    ${get}=       GET On Session    serverest    /usuarios/${id}
    Status Should Be    200    ${get}

    ${del}=       DELETE On Session    serverest    /usuarios/${id}
    Status Should Be    200    ${del}

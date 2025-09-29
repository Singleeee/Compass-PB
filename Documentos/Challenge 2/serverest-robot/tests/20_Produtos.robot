*** Settings ***
Resource    ../resources/Serverest.resource
Suite Setup    Create API Session

*** Test Cases ***
Criar produto como admin (201)
    ${token}=    Create Admin And Login
    ${resp}=     Create Random Product    ${token}
    Status Should Be    201    ${resp}

Não permite criar produto sem ser admin (403)
    ${token}=    Create User (non-admin) And Login
    ${headers}=  Auth Headers    ${token}
    ${prod}=     Create Dictionary    nome=Proibido    preco=50    descricao=Mouse    quantidade=1
    ${resp}=     POST On Session    serverest    /produtos    headers=${headers}    json=${prod}    expected_status=any
    Status Should Be    403    ${resp}

Listar produtos retorna quantidade consistente (200)
    ${get}=      GET On Session    serverest    /produtos
    Status Should Be    200    ${get}
    ${json}=     Evaluate    json.loads($get.text)    json
    ${qtd}=      Get From Dictionary    ${json}    quantidade
    ${lista}=    Get From Dictionary    ${json}    produtos
    Length Should Be    ${lista}    ${qtd}

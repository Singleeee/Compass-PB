*** Settings ***
Resource    ../resources/Serverest.resource
Suite Setup    Create API Session

*** Test Cases ***
Criar carrinho e cancelar compra
    ${token}=    Create Admin And Login
    # cria um produto no estoque
    ${prodResp}=    Create Random Product    ${token}
    Status Should Be    201    ${prodResp}
    ${pjson}=    Evaluate    json.loads($prodResp.text)    json
    ${prodId}=   Get From Dictionary    ${pjson}    _id

    # cria carrinho
    ${headers}=  Auth Headers    ${token}
    ${carrinho}=    Create Dictionary    produtos=@{EMPTY}
    ${item}=     Create Dictionary    idProduto=${prodId}    quantidade=1
    Append To List    ${carrinho['produtos']}    ${item}
    ${criar}=    POST On Session    serverest    /carrinhos    headers=${headers}    json=${carrinho}
    Status Should Be    201    ${criar}

    # cancelar compra
    ${cancel}=   DELETE On Session    serverest    /carrinhos/cancelar-compra    headers=${headers}
    Status Should Be    200    ${cancel}

*** Settings ***
Resource    ../resources/Serverest.resource
Suite Setup    Create API Session
Force Tags     smoke

*** Test Cases ***
Login retorna token Bearer
    ${token}=    Create Admin And Login
    Should Start With    ${token}    Bearer

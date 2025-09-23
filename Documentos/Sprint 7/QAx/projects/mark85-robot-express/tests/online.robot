*** Settings ***
Documentation         Online

Resource              ../resources/base.robot

*** Test Cases ***
Webapp deve estar online

    Start Session
    Get Title       equal        Mark85 by QAx
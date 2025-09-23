*** Settings ***

Library               libs/database.py
Library               Browser

Resource              env.robot
Resource              pages/SignupPage.robot

*** Keywords ***
Start Session

    New Browser     browser=chromium    headless=False
    New Page        ${BASE_URL}
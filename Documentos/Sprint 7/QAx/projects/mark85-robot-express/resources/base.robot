*** Settings ***

Library               libs/database.py
Library               Browser

*** Variables ***
${BASE_URL}        http://localhost:3000

*** Keywords ***
Start Session

    New Browser     browser=chromium    headless=False
    New Page        ${BASE_URL}
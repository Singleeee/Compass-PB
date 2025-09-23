*** Settings ***
Documentation         Online
Library               Browser

*** Test Cases ***
Webapp deve estar online

    New Browser     browser=chromium    headless=False
    New Page        http://localhost:3000
    Get Title       equal        Mark85 by QAx
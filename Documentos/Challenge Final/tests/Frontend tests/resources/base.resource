*** Settings ***

Library               Browser
Library               Collections
Library               BuiltIn

Resource              env.resource
Resource              Pages/SingupPage.resource

*** Keywords ***
Start Session

    New Browser     browser=chromium    headless=False
    New Page        ${BASE_URL}
    
Login user
    ${user}          Create Dictionary
    ...              email=test@example.com
    ...              password=password123
    
    Click With Options          css=header a[href="/login"]
    
    Fill Text        css=input[id="email"]       ${user}[email]
    Fill Text        css=input[id="password"]    ${user}[password]
    Click            css=button[type] >> text=Entrar

    # Checkpoint
    Notice should be    Login realizado com sucesso!

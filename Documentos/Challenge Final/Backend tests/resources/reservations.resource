*** Settings ***
Resource    env.resource
Resource    auth.resource
Resource    payloads.resource
Library     Collections

*** Keywords ***
# === Helpers de header ===
Header (Token)
    [Arguments]    ${token}
    ${headers}=    Header With Token    ${token}
    RETURN    ${headers}

Seats From Response
    [Arguments]    ${resp}
    ${body}=    Set Variable    ${resp.json()}
    ${seats}=   Set Variable    ${body['data']['seats']}
    RETURN      ${seats}

# === Endpoints ===
My Reservations
    [Arguments]    ${token}
    ${headers}=    Header (Token)    ${token}
    ${resp}=       GET On Session    cinema    /reservations/me    headers=${headers}    expected_status=any
    RETURN         ${resp}

Create Reservation
    [Arguments]    ${token}    ${session_id}    ${seats}=${None}
    ${headers}=    Header (Token)    ${token}
    ${body}=       Reservation Payload    ${session_id}    ${seats}
    ${resp}=       POST On Session    cinema    /reservations    headers=${headers}    json=${body}    expected_status=any
    RETURN         ${resp}

List All Reservations (admin)
    [Arguments]    ${token}    ${page}=1    ${limit}=10
    ${headers}=    Header (Token)    ${token}
    ${params}=     Create Dictionary    page=${page}    limit=${limit}
    ${resp}=       GET On Session    cinema    /reservations    headers=${headers}    params=${params}    expected_status=any
    RETURN         ${resp}

Reservation Details
    [Arguments]    ${token}    ${reservation_id}
    ${headers}=    Header (Token)    ${token}
    ${resp}=       GET On Session    cinema    /reservations/${reservation_id}    headers=${headers}    expected_status=any
    RETURN         ${resp}

Update Reservation Status (admin)
    [Arguments]    ${token}    ${reservation_id}    ${status}
    ${headers}=    Header (Token)    ${token}
    ${body}=       Create Dictionary    status=${status}
    # <- API atualiza status em /reservations/{id}
    ${resp}=       PUT On Session    cinema    /reservations/${reservation_id}    headers=${headers}    json=${body}    expected_status=any
    RETURN         ${resp}

Delete Reservation (admin)
    [Arguments]    ${token}    ${reservation_id}
    ${headers}=    Header (Token)    ${token}
    ${resp}=       DELETE On Session    cinema    /reservations/${reservation_id}    headers=${headers}    expected_status=any
    RETURN         ${resp}

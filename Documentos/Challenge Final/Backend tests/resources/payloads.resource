*** Settings ***
Library     Collections
Library     BuiltIn

*** Keywords ***
# ----------------------------------------
# ASSENTOS (helpers)
# ----------------------------------------
Make Seat
    [Arguments]    ${row}    ${number}    ${type}=full
    ${seat}=    Create Dictionary    row=${row}    number=${number}    type=${type}
    RETURN      ${seat}

Next Seat
    ${exists}=    Run Keyword And Return Status    Variable Should Exist    ${SEAT_COUNTER}
    Run Keyword If    not ${exists}    Set Suite Variable    ${SEAT_COUNTER}    0

    ${rows}=    Create List    A    B    C    D    E
    ${idx}=     Evaluate    ${SEAT_COUNTER} % 5
    ${row}=     Get From List    ${rows}    ${idx}
    ${number}=  Evaluate    1 + (${SEAT_COUNTER} % 30)

    ${seat}=    Make Seat    ${row}    ${number}    full
    ${new}=     Evaluate    ${SEAT_COUNTER} + 1
    Set Suite Variable    ${SEAT_COUNTER}    ${new}
    RETURN      ${seat}

Append New Seat
    [Arguments]    ${list}
    ${seat}=    Next Seat
    Append To List    ${list}    ${seat}

Seats Unique
    [Arguments]    ${qty}=2
    ${seats}=    Create List
    Repeat Keyword    ${qty}    Append New Seat    ${seats}
    RETURN      ${seats}

Reservation Seats (Default)
    ${seats}=    Seats Unique    2
    RETURN       ${seats}

# ----------------------------------------
# PAYLOAD DA RESERVA
# ----------------------------------------
Reservation Payload
    [Arguments]    ${session_id}    ${seats}=${None}    ${payment_method}=credit_card
    IF    $seats is None
        ${seats}=    Reservation Seats (Default)
    END
    ${body}=    Create Dictionary
    ...         session=${session_id}
    ...         seats=${seats}
    ...         paymentMethod=${payment_method}
    Set Suite Variable    ${LAST_SEATS}    ${seats}
    RETURN      ${body}

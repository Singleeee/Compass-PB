*** Settings ***
Library     Collections

*** Keywords ***
# ------------------------------------------------------------
# ASSENTOS (helpers)
# ------------------------------------------------------------
Make Seat
    [Arguments]    ${row}    ${number}    ${type}=full
    ${seat}=    Create Dictionary    row=${row}    number=${number}    type=${type}
    RETURN      ${seat}

Reservation Seats (Default)
    ${s1}=    Make Seat    A    10    full
    ${s2}=    Make Seat    B    12    half
    ${seats}=    Create List    ${s1}    ${s2}
    RETURN      ${seats}

# ------------------------------------------------------------
# PAYLOAD DA RESERVA
# ------------------------------------------------------------
Reservation Payload
    [Arguments]    ${session_id}    ${seats}=${None}    ${payment_method}=credit_card
    IF    $seats is None
        ${seats}=    Reservation Seats (Default)
    END
    ${body}=    Create Dictionary
    ...         session=${session_id}
    ...         seats=${seats}
    ...         paymentMethod=${payment_method}
    RETURN      ${body}

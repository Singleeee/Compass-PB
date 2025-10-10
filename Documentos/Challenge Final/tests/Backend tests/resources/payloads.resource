*** Settings ***
Library     Collections
Library     BuiltIn
Library     String

*** Keywords ***

Movie Payload (Docs)
    ${rand}=            Generate Random String    8
    ${title}=           Catenate    SEPARATOR=    Movie_    ${rand}
    ${genres}=          Create List    Drama
    ${duration}=        Evaluate    120
    ${release}=         Evaluate    __import__('datetime').datetime.utcnow().date().isoformat()
    ${body}=            Create Dictionary
    ...                 title=${title}
    ...                 synopsis=The journey of a lifetime.
    ...                 director=Jane Doe
    ...                 genres=${genres}
    ...                 duration=${duration}
    ...                 classification=PG-13
    ...                 poster=poster.jpg
    ...                 releaseDate=${release}
    RETURN              ${body}

Invalid Movie Payload (Docs)
    ${body}=    Create Dictionary    title=${EMPTY}
    RETURN      ${body}

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

Random Theater Payload
    # Gera uma sala válida: name único e número de assentos.
    ${suf}=    Generate Random String    4    [LETTERS]
    ${name}=   Catenate    SEPARATOR=-    Sala    ${suf}
    ${seats}=  Set Variable    60
    ${body}=   Create Dictionary    name=${name}    seats=${seats}
    RETURN     ${body}

Random Session Payload
    [Arguments]    ${movie_id}    ${theater_id}    ${start_offset_min}=10    ${full_price}=30.0    ${half_price}=15.0
    # startTime em ~agora + offset (UTC) no formato ISO-8601 esperado pela API
    ${start}=    Evaluate    (__import__('datetime').datetime.utcnow() + __import__('datetime').timedelta(minutes=${start_offset_min})).isoformat() + 'Z'
    ${body}=     Create Dictionary
    ...          movie=${movie_id}
    ...          theater=${theater_id}
    ...          startTime=${start}
    ...          fullPrice=${full_price}
    ...          halfPrice=${half_price}
    RETURN       ${body}
*** Settings ***
Library     String
Library     Collections

*** Keywords ***
# ============================================================
# MOVIE (usado para criar sessão quando não existirem)
# ============================================================
Movie Payload (Docs)
    ${title_rand}=       Generate Random String    8
    ${title}=            Catenate    SEPARATOR=    Movie_    ${title_rand}
    ${synopsis}=         Set Variable    The journey of a lifetime.
    ${director}=         Set Variable    Jane Doe
    ${genres}=           Create List    Drama
    ${duration}=         Evaluate    120
    ${classification}=   Set Variable    PG-13
    ${poster}=           Set Variable    poster.jpg
    ${release}=          Evaluate    __import__('datetime').datetime.utcnow().date().isoformat()
    ${body}=             Create Dictionary
    ...                  title=${title}
    ...                  synopsis=${synopsis}
    ...                  director=${director}
    ...                  genres=${genres}
    ...                  duration=${duration}
    ...                  classification=${classification}
    ...                  poster=${poster}
    ...                  releaseDate=${release}
    RETURN               ${body}

# Se precisar de um payload inválido para testes negativos de movies
Invalid Movie Payload (Docs)
    ${body}=    Create Dictionary    title=${EMPTY}
    RETURN      ${body}

# ============================================================
# THEATER (usado para criar sessão quando não existirem)
# ============================================================
Random Theater Payload
    ${suf}=     Generate Random String    4    [LETTERS]
    ${name}=    Catenate    SEPARATOR=    Sala-    ${suf}
    ${seats}=   Evaluate    60
    ${body}=    Create Dictionary    name=${name}    seats=${seats}
    RETURN      ${body}

# ============================================================
# SESSION (usado para criar sessão quando não existirem)
# ============================================================
Random Session Payload
    [Arguments]     ${movie_id}    ${theater_id}
    # começa em ~10 min para evitar conflitos de validação de "passado"
    ${start}=       Evaluate    (__import__('datetime').datetime.utcnow() + __import__('datetime').timedelta(minutes=10)).isoformat() + 'Z'
    ${price}=       Evaluate    25.0
    ${body}=        Create Dictionary
    ...             movie=${movie_id}
    ...             theater=${theater_id}
    ...             startTime=${start}
    ...             price=${price}
    RETURN          ${body}

# ============================================================
# ASSENTOS (helpers para reservar)
# ============================================================
Make Seat
    [Arguments]    ${row}    ${number}    ${type}=full
    ${seat}=    Create Dictionary    row=${row}    number=${number}    type=${type}
    RETURN      ${seat}

Reservation Seats (Default)
    ${s1}=    Make Seat    A    10    full
    ${s2}=    Make Seat    B    12    half
    ${seats}=    Create List    ${s1}    ${s2}
    RETURN      ${seats}

# ============================================================
# PAYLOAD DA RESERVA
# ============================================================
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

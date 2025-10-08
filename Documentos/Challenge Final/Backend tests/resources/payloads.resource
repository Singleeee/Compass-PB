*** Settings ***
Library     String
Library     Collections

*** Keywords ***
# Payload compatível com a validação do backend
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
    ${body}=    Create Dictionary
    ...         title=${EMPTY}
    ...         synopsis=${EMPTY}
    ...         director=${EMPTY}
    ...         classification=${EMPTY}
    RETURN      ${body}

# (mantive os aleatórios se quiser usar em outras suítes)
Random Movie Payload
    ${title}=       Generate Random String    8
    ${duration}=    Evaluate    90
    ${rating}=      Set Variable    PG-13
    ${genre}=       Set Variable    Action
    ${body}=        Create Dictionary
    ...             title=${title}
    ...             duration=${duration}
    ...             rating=${rating}
    ...             genre=${genre}
    RETURN          ${body}

Random Theater Payload
    ${suf}=         Generate Random String    4    [LETTERS]
    ${name}=        Catenate    SEPARATOR=    Sala-    ${suf}
    ${seats}=       Evaluate    60
    ${body}=        Create Dictionary
    ...             name=${name}
    ...             seats=${seats}
    RETURN          ${body}

Random Session Payload
    [Arguments]     ${movie_id}    ${theater_id}
    ${start}=       Evaluate    (__import__('datetime').datetime.utcnow() + __import__('datetime').timedelta(minutes=5)).isoformat() + 'Z'
    ${price}=       Evaluate    25.0
    ${body}=        Create Dictionary
    ...             movie=${movie_id}
    ...             theater=${theater_id}
    ...             startTime=${start}
    ...             price=${price}
    RETURN          ${body}

Reservation Payload
    [Arguments]     ${session_id}    @{seats}
    ${body}=        Create Dictionary
    ...             session=${session_id}
    ...             seats=${seats}
    RETURN          ${body}

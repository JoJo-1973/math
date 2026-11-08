; ==============================================================================
; FILE:           fp_integers.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per caricare FAC e ARG con un intero binario a 8, 16, 24
;                 o 32 bit, con o senza segno, e per convertire FAC o ARG in un
;                 intero a 32 bit con segno.
; CONTENUTO:      m_Load_FAC_with_UINT8       Carica FAC con UINT8 costante
;                 m_Load_FAC_with_UINT8_Mem   Carica FAC con UINT8 da indirizzo
;                 m_Load_FAC_with_UINT8_Ptr   Carica FAC con UINT8 da puntatore
;                 m_Load_ARG_with_UINT8       Carica ARG con UINT8 costante
;                 m_Load_ARG_with_UINT8_Mem   Carica ARG con UINT8 da indirizzo
;                 m_Load_ARG_with_UINT8_Ptr   Carica ARG con UINT8 da puntatore
;                 m_Load_FAC_with_INT8        Carica FAC con INT8 costante
;                 m_Load_FAC_with_INT8_Mem    Carica FAC con INT8 da indirizzo
;                 m_Load_FAC_with_INT8_Ptr    Carica FAC con INT8 da puntatore
;                 m_Load_ARG_with_INT8        Carica ARG con INT8 costante
;                 m_Load_ARG_with_INT8_Mem    Carica ARG con INT8 da indirizzo
;                 m_Load_ARG_with_INT8_Ptr    Carica ARG con INT8 da puntatore
;                 m_Load_FAC_with_UINT16      Carica FAC con UINT16 costante
;                 m_Load_FAC_with_UINT16_Mem  Carica FAC con UINT16 da indirizzo
;                 m_Load_FAC_with_UINT16_Ptr  Carica FAC con UINT16 da puntatore
;                 m_Load_ARG_with_UINT16      Carica ARG con UINT16 costante
;                 m_Load_ARG_with_UINT16_Mem  Carica ARG con UINT16 da indirizzo
;                 m_Load_ARG_with_UINT16_Ptr  Carica ARG con UINT16 da puntatore
;                 m_Load_FAC_with_INT16       Carica FAC con INT16 costante
;                 m_Load_FAC_with_INT16_Mem   Carica FAC con INT16 da indirizzo
;                 m_Load_FAC_with_INT16_Ptr   Carica FAC con INT16 da puntatore
;                 m_Load_ARG_with_INT16       Carica ARG con INT16 costante
;                 m_Load_ARG_with_INT16_Mem   Carica ARG con INT16 da indirizzo
;                 m_Load_ARG_with_INT16_Ptr   Carica ARG con INT16 da puntatore
;                 m_Load_FAC_with_UINT24      Carica FAC con UINT24 costante
;                 m_Load_FAC_with_UINT24_Mem  Carica FAC con UINT24 da indirizzo
;                 m_Load_FAC_with_UINT24_Ptr  Carica FAC con UINT24 da puntatore
;                 m_Load_ARG_with_UINT24      Carica ARG con UINT24 costante
;                 m_Load_ARG_with_UINT24_Mem  Carica ARG con UINT24 da indirizzo
;                 m_Load_ARG_with_UINT24_Ptr  Carica ARG con UINT24 da puntatore
;                 m_Load_FAC_with_INT24       Carica FAC con INT24 costante
;                 m_Load_FAC_with_INT24_Mem   Carica FAC con INT24 da indirizzo
;                 m_Load_FAC_with_INT24_Ptr   Carica FAC con INT24 da puntatore
;                 m_Load_ARG_with_INT24       Carica ARG con INT24 costante
;                 m_Load_ARG_with_INT24_Mem   Carica ARG con INT24 da indirizzo
;                 m_Load_ARG_with_INT24_Ptr   Carica ARG con INT24 da puntatore
;                 m_Load_FAC_with_UINT32      Carica FAC con UINT32 costante
;                 m_Load_FAC_with_UINT32_Mem  Carica FAC con UINT32 da indirizzo
;                 m_Load_FAC_with_UINT32_Ptr  Carica FAC con UINT32 da puntatore
;                 m_Load_ARG_with_UINT32      Carica ARG con UINT32 costante
;                 m_Load_ARG_with_UINT32_Mem  Carica ARG con UINT32 da indirizzo
;                 m_Load_ARG_with_UINT32_Ptr  Carica ARG con UINT32 da puntatore
;                 m_Load_FAC_with_INT32       Carica FAC con INT32 costante
;                 m_Load_FAC_with_INT32_Mem   Carica FAC con INT32 da indirizzo
;                 m_Load_FAC_with_INT32_Ptr   Carica FAC con INT32 da puntatore
;                 m_Load_ARG_with_INT32       Carica ARG con INT32 costante
;                 m_Load_ARG_with_INT32_Mem   Carica ARG con INT32 da indirizzo
;                 m_Load_ARG_with_INT32_Ptr   Carica ARG con INT32 da puntatore
;                 m_Convert_FAC_into_INT32    Converte FAC in INT32
;                 m_Convert_ARG_into_INT32    Converte ARG in INT32
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   Nessuno
; ==============================================================================

; ==============================================================================
; MACRO: m_Load_FAC_with_UINT8
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero senza segno a 8 bit, passato come
;               costante, e azzera FACOV.
;
;               I bit del valore oltre il bit #7 sono ignorati.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 (numero positivo). ARG non cambia.
;
; Input:
;   - .value_ (1 byte, Macro) : Valore da caricare, senza segno
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_UINT8 .value_ {
  ; Byte del valore, dal LSB al MSB.
  .BYTE_0           = <.value_

    sec                         ; C = 1: converte come intero senza segno.

    lda #.BYTE_0                ; Carica il MSB della mantissa.
    sta FACHO

    !if (.BYTE_0 != 0) {
      lda #0                    ; Azzera i byte restanti della mantissa.
    }

    sta FACMOH
    sta FACMO
    sta FACLO

    ldx #$88                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_UINT8_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero senza segno a 8 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian), e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 (numero positivo). ARG non cambia.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (1 byte, RAM)     : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)           : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_UINT8_Mem .addr_ {
    sec                         ; C = 1: converte come intero senza segno.

    lda .addr_                  ; Carica il MSB della mantissa.
    sta FACHO

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACMOH
    sta FACMO
    sta FACLO

    ldx #$88                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_UINT8_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero senza segno a 8 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 (numero positivo). ARG non cambia.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (1 byte, RAM) : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_UINT8_Ptr .ptr_ {
    sec                         ; C = 1: converte come intero senza segno.

    ldy #0                      ; Carica il MSB della mantissa.
    lda (.ptr_),y
    sta FACHO

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACMOH
    sta FACMO
    sta FACLO

    ldx #$88                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_UINT8
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero senza segno a 8 bit, passato
;               come costante.
;
;               I bit del valore oltre il bit #7 sono ignorati.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_UINT8 e li scambia di nuovo. Dopo
;               la chiamata FAC contiene il valore di prima, arrotondato,
;               e FACOV vale zero; il vecchio ARG si perde e ARISGN non
;               viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .value_ (1 byte, Macro) : Valore da caricare, senza segno
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_UINT8 .value_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_UINT8 .value_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_UINT8_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero senza segno a 8 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian).
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_UINT8_Mem e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (1 byte, RAM)     : Intero, LSB per primo
;   - FAC (7 byte, ZP)           : Valore da conservare, registri da FACEXP a
;                                  FACOV
;
; Output:
;   - ARG (6 byte, ZP)           : Intero convertito, registri da ARGEXP a
;                                  ARGSGN
;   - FAC (7 byte, ZP)           : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_UINT8_Mem .addr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_UINT8_Mem .addr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_UINT8_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero senza segno a 8 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_UINT8_Ptr e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (1 byte, RAM) : Intero, LSB per primo
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_UINT8_Ptr .ptr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_UINT8_Ptr .ptr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_INT8
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero con segno a 8 bit, passato come
;               costante, e azzera FACOV.
;
;               I bit del valore oltre il bit #7 sono ignorati.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 per i numeri senza segno e, per quelli con segno, lo
;               ricava dal bit #7 del MSB (complemento a due). ARG non cambia.
;
; Input:
;   - .value_ (1 byte, Macro) : Valore da caricare, con segno
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_INT8 .value_ {
  ; Byte del valore, dal LSB al MSB.
  .BYTE_0           = <.value_

    lda #.BYTE_0                ; Carica il MSB della mantissa.
    sta FACHO
    eor #$FF                    ; Inverte il bit #7 del MSB.
    rol a                       ; C = 1 se positivo, C = 0 se negativo.

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACMOH
    sta FACMO
    sta FACLO

    ldx #$88                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_INT8_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero con segno a 8 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian), e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 per i numeri senza segno e, per quelli con segno, lo
;               ricava dal bit #7 del MSB (complemento a due). ARG non cambia.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (1 byte, RAM)     : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)           : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_INT8_Mem .addr_ {
    lda .addr_                  ; Carica il MSB della mantissa.
    sta FACHO
    eor #$FF                    ; Inverte il bit #7 del MSB.
    rol a                       ; C = 1 se positivo, C = 0 se negativo.

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACMOH
    sta FACMO
    sta FACLO

    ldx #$88                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_INT8_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero con segno a 8 bit, letto dall'indirizzo
;               indicato da un puntatore in ZP, LSB per primo, e azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 per i numeri senza segno e, per quelli con segno, lo
;               ricava dal bit #7 del MSB (complemento a due). ARG non cambia.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (1 byte, RAM) : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_INT8_Ptr .ptr_ {
    ldy #0                      ; Carica il MSB della mantissa.
    lda (.ptr_),y
    sta FACHO
    eor #$FF                    ; Inverte il bit #7 del MSB.
    rol a                       ; C = 1 se positivo, C = 0 se negativo.

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACMOH
    sta FACMO
    sta FACLO

    ldx #$88                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_INT8
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero con segno a 8 bit, passato
;               come costante.
;
;               I bit del valore oltre il bit #7 sono ignorati.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_INT8 e li scambia di nuovo. Dopo
;               la chiamata FAC contiene il valore di prima, arrotondato,
;               e FACOV vale zero; il vecchio ARG si perde e ARISGN non
;               viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .value_ (1 byte, Macro) : Valore da caricare, con segno
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_INT8 .value_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_INT8 .value_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_INT8_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero con segno a 8 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian).
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_INT8_Mem e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (1 byte, RAM)     : Intero, LSB per primo
;   - FAC (7 byte, ZP)           : Valore da conservare, registri da FACEXP a
;                                  FACOV
;
; Output:
;   - ARG (6 byte, ZP)           : Intero convertito, registri da ARGEXP a
;                                  ARGSGN
;   - FAC (7 byte, ZP)           : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_INT8_Mem .addr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_INT8_Mem .addr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_INT8_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero con segno a 8 bit, letto dall'indirizzo
;               indicato da un puntatore in ZP, LSB per primo.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_INT8_Ptr e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (1 byte, RAM) : Intero, LSB per primo
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_INT8_Ptr .ptr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_INT8_Ptr .ptr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_UINT16
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero senza segno a 16 bit, passato come
;               costante, e azzera FACOV.
;
;               I bit del valore oltre il bit #15 sono ignorati.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 (numero positivo). ARG non cambia.
;
; Input:
;   - .value_ (2 byte, Macro) : Valore da caricare, senza segno
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_UINT16 .value_ {
  ; Byte del valore, dal LSB al MSB.
  .BYTE_0           = <.value_
  .BYTE_1           = >.value_

    sec                         ; C = 1: converte come intero senza segno.

    lda #.BYTE_1                ; Carica il MSB della mantissa.
    sta FACHO

    !if (.BYTE_1 != .BYTE_0) {
      lda #.BYTE_0
    }

    sta FACMOH

    !if (.BYTE_0 != 0) {
      lda #0                    ; Azzera i byte restanti della mantissa.
    }

    sta FACMO
    sta FACLO

    ldx #$90                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_UINT16_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero senza segno a 16 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian), e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 (numero positivo). ARG non cambia.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (2 byte, RAM)     : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)           : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_UINT16_Mem .addr_ {
    sec                         ; C = 1: converte come intero senza segno.

    lda .addr_+1                ; Carica il MSB della mantissa.
    sta FACHO
    lda .addr_
    sta FACMOH

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACMO
    sta FACLO

    ldx #$90                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_UINT16_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero senza segno a 16 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 (numero positivo). ARG non cambia.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (2 byte, RAM) : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_UINT16_Ptr .ptr_ {
    sec                         ; C = 1: converte come intero senza segno.

    ldy #1                      ; Carica il MSB della mantissa.
    lda (.ptr_),y
    sta FACHO
    dey
    lda (.ptr_),y
    sta FACMOH

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACMO
    sta FACLO

    ldx #$90                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_UINT16
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero senza segno a 16 bit, passato
;               come costante.
;
;               I bit del valore oltre il bit #15 sono ignorati.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_UINT16 e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .value_ (2 byte, Macro) : Valore da caricare, senza segno
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_UINT16 .value_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_UINT16 .value_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_UINT16_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero senza segno a 16 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian).
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con la
;               macro m_Load_FAC_with_UINT16_Mem e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (2 byte, RAM)     : Intero, LSB per primo
;   - FAC (7 byte, ZP)           : Valore da conservare, registri da FACEXP a
;                                  FACOV
;
; Output:
;   - ARG (6 byte, ZP)           : Intero convertito, registri da ARGEXP a
;                                  ARGSGN
;   - FAC (7 byte, ZP)           : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_UINT16_Mem .addr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_UINT16_Mem .addr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_UINT16_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero senza segno a 16 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con la
;               macro m_Load_FAC_with_UINT16_Ptr e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (2 byte, RAM) : Intero, LSB per primo
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_UINT16_Ptr .ptr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_UINT16_Ptr .ptr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_INT16
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero con segno a 16 bit, passato come
;               costante, e azzera FACOV.
;
;               I bit del valore oltre il bit #15 sono ignorati.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 per i numeri senza segno e, per quelli con segno, lo
;               ricava dal bit #15 del MSB (complemento a due). ARG non cambia.
;
; Input:
;   - .value_ (2 byte, Macro) : Valore da caricare, con segno
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_INT16 .value_ {
  ; Byte del valore, dal LSB al MSB.
  .BYTE_0           = <.value_
  .BYTE_1           = >.value_

    lda #.BYTE_1                ; Carica il MSB della mantissa.
    sta FACHO
    eor #$FF                    ; Inverte il bit #7 del MSB.
    rol a                       ; C = 1 se positivo, C = 0 se negativo.

    lda #.BYTE_0
    sta FACMOH

    !if (.BYTE_0 != 0) {
      lda #0                    ; Azzera i byte restanti della mantissa.
    }

    sta FACMO
    sta FACLO

    ldx #$90                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_INT16_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero con segno a 16 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian), e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 per i numeri senza segno e, per quelli con segno, lo
;               ricava dal bit #15 del MSB (complemento a due). ARG non cambia.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (2 byte, RAM)     : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)           : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_INT16_Mem .addr_ {
    lda .addr_+1                ; Carica il MSB della mantissa.
    sta FACHO
    eor #$FF                    ; Inverte il bit #7 del MSB.
    rol a                       ; C = 1 se positivo, C = 0 se negativo.
    lda .addr_
    sta FACMOH

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACMO
    sta FACLO

    ldx #$90                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_INT16_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero con segno a 16 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 per i numeri senza segno e, per quelli con segno, lo
;               ricava dal bit #15 del MSB (complemento a due). ARG non cambia.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (2 byte, RAM) : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_INT16_Ptr .ptr_ {
    ldy #1                      ; Carica il MSB della mantissa.
    lda (.ptr_),y
    sta FACHO
    eor #$FF                    ; Inverte il bit #7 del MSB.
    rol a                       ; C = 1 se positivo, C = 0 se negativo.
    dey
    lda (.ptr_),y
    sta FACMOH

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACMO
    sta FACLO

    ldx #$90                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_INT16
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero con segno a 16 bit, passato
;               come costante.
;
;               I bit del valore oltre il bit #15 sono ignorati.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_INT16 e li scambia di nuovo. Dopo
;               la chiamata FAC contiene il valore di prima, arrotondato,
;               e FACOV vale zero; il vecchio ARG si perde e ARISGN non
;               viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .value_ (2 byte, Macro) : Valore da caricare, con segno
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_INT16 .value_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_INT16 .value_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_INT16_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero con segno a 16 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian).
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_INT16_Mem e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (2 byte, RAM)     : Intero, LSB per primo
;   - FAC (7 byte, ZP)           : Valore da conservare, registri da FACEXP a
;                                  FACOV
;
; Output:
;   - ARG (6 byte, ZP)           : Intero convertito, registri da ARGEXP a
;                                  ARGSGN
;   - FAC (7 byte, ZP)           : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_INT16_Mem .addr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_INT16_Mem .addr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_INT16_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero con segno a 16 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_INT16_Ptr e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (2 byte, RAM) : Intero, LSB per primo
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_INT16_Ptr .ptr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_INT16_Ptr .ptr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_UINT24
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero senza segno a 24 bit, passato come
;               costante, e azzera FACOV.
;
;               I bit del valore oltre il bit #23 sono ignorati.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 (numero positivo). ARG non cambia.
;
; Input:
;   - .value_ (3 byte, Macro) : Valore da caricare, senza segno
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_UINT24 .value_ {
  ; Byte del valore, dal LSB al MSB.
  .BYTE_0           = <.value_
  .BYTE_1           = >.value_
  .BYTE_2           = <(.value_ >> 16)

    sec                         ; C = 1: converte come intero senza segno.

    lda #.BYTE_2                ; Carica il MSB della mantissa.
    sta FACHO

    !if (.BYTE_2 != .BYTE_1) {
      lda #.BYTE_1
    }

    sta FACMOH

    !if (.BYTE_1 != .BYTE_0) {
      lda #.BYTE_0
    }

    sta FACMO

    !if (.BYTE_0 != 0) {
      lda #0                    ; Azzera i byte restanti della mantissa.
    }

    sta FACLO

    ldx #$98                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_UINT24_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero senza segno a 24 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian), e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 (numero positivo). ARG non cambia.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (3 byte, RAM)     : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)           : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_UINT24_Mem .addr_ {
    sec                         ; C = 1: converte come intero senza segno.

    lda .addr_+2                ; Carica il MSB della mantissa.
    sta FACHO
    lda .addr_+1
    sta FACMOH
    lda .addr_
    sta FACMO

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACLO

    ldx #$98                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_UINT24_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero senza segno a 24 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 (numero positivo). ARG non cambia.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (3 byte, RAM) : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_UINT24_Ptr .ptr_ {
    sec                         ; C = 1: converte come intero senza segno.

    ldy #2                      ; Carica il MSB della mantissa.
    lda (.ptr_),y
    sta FACHO
    dey
    lda (.ptr_),y
    sta FACMOH
    dey
    lda (.ptr_),y
    sta FACMO

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACLO

    ldx #$98                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_UINT24
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero senza segno a 24 bit, passato
;               come costante.
;
;               I bit del valore oltre il bit #23 sono ignorati.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_UINT24 e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .value_ (3 byte, Macro) : Valore da caricare, senza segno
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_UINT24 .value_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_UINT24 .value_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_UINT24_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero senza segno a 24 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian).
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con la
;               macro m_Load_FAC_with_UINT24_Mem e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (3 byte, RAM)     : Intero, LSB per primo
;   - FAC (7 byte, ZP)           : Valore da conservare, registri da FACEXP a
;                                  FACOV
;
; Output:
;   - ARG (6 byte, ZP)           : Intero convertito, registri da ARGEXP a
;                                  ARGSGN
;   - FAC (7 byte, ZP)           : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_UINT24_Mem .addr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_UINT24_Mem .addr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_UINT24_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero senza segno a 24 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con la
;               macro m_Load_FAC_with_UINT24_Ptr e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (3 byte, RAM) : Intero, LSB per primo
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_UINT24_Ptr .ptr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_UINT24_Ptr .ptr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_INT24
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero con segno a 24 bit, passato come
;               costante, e azzera FACOV.
;
;               I bit del valore oltre il bit #23 sono ignorati.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 per i numeri senza segno e, per quelli con segno, lo
;               ricava dal bit #23 del MSB (complemento a due). ARG non cambia.
;
; Input:
;   - .value_ (3 byte, Macro) : Valore da caricare, con segno
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_INT24 .value_ {
  ; Byte del valore, dal LSB al MSB.
  .BYTE_0           = <.value_
  .BYTE_1           = >.value_
  .BYTE_2           = <(.value_ >> 16)

    lda #.BYTE_2                ; Carica il MSB della mantissa.
    sta FACHO
    eor #$FF                    ; Inverte il bit #7 del MSB.
    rol a                       ; C = 1 se positivo, C = 0 se negativo.

    lda #.BYTE_1
    sta FACMOH

    !if (.BYTE_1 != .BYTE_0) {
      lda #.BYTE_0
    }

    sta FACMO

    !if (.BYTE_0 != 0) {
      lda #0                    ; Azzera i byte restanti della mantissa.
    }

    sta FACLO

    ldx #$98                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_INT24_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero con segno a 24 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian), e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 per i numeri senza segno e, per quelli con segno, lo
;               ricava dal bit #23 del MSB (complemento a due). ARG non cambia.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (3 byte, RAM)     : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)           : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_INT24_Mem .addr_ {
    lda .addr_+2                ; Carica il MSB della mantissa.
    sta FACHO
    eor #$FF                    ; Inverte il bit #7 del MSB.
    rol a                       ; C = 1 se positivo, C = 0 se negativo.
    lda .addr_+1
    sta FACMOH
    lda .addr_
    sta FACMO

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACLO

    ldx #$98                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_INT24_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero con segno a 24 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 per i numeri senza segno e, per quelli con segno, lo
;               ricava dal bit #23 del MSB (complemento a due). ARG non cambia.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (3 byte, RAM) : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_INT24_Ptr .ptr_ {
    ldy #2                      ; Carica il MSB della mantissa.
    lda (.ptr_),y
    sta FACHO
    eor #$FF                    ; Inverte il bit #7 del MSB.
    rol a                       ; C = 1 se positivo, C = 0 se negativo.
    dey
    lda (.ptr_),y
    sta FACMOH
    dey
    lda (.ptr_),y
    sta FACMO

    lda #0                      ; Azzera i byte restanti della mantissa.
    sta FACLO

    ldx #$98                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_INT24
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero con segno a 24 bit, passato
;               come costante.
;
;               I bit del valore oltre il bit #23 sono ignorati.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_INT24 e li scambia di nuovo. Dopo
;               la chiamata FAC contiene il valore di prima, arrotondato,
;               e FACOV vale zero; il vecchio ARG si perde e ARISGN non
;               viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .value_ (3 byte, Macro) : Valore da caricare, con segno
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_INT24 .value_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_INT24 .value_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_INT24_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero con segno a 24 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian).
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_INT24_Mem e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (3 byte, RAM)     : Intero, LSB per primo
;   - FAC (7 byte, ZP)           : Valore da conservare, registri da FACEXP a
;                                  FACOV
;
; Output:
;   - ARG (6 byte, ZP)           : Intero convertito, registri da ARGEXP a
;                                  ARGSGN
;   - FAC (7 byte, ZP)           : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_INT24_Mem .addr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_INT24_Mem .addr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_INT24_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero con segno a 24 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_INT24_Ptr e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (3 byte, RAM) : Intero, LSB per primo
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_INT24_Ptr .ptr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_INT24_Ptr .ptr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_UINT32
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero senza segno a 32 bit, passato come
;               costante, e azzera FACOV.
;
;               I bit del valore oltre il bit #31 sono ignorati.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 (numero positivo). ARG non cambia.
;
; Input:
;   - .value_ (4 byte, Macro) : Valore da caricare, senza segno
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_UINT32 .value_ {
  ; Byte del valore, dal LSB al MSB.
  .BYTE_0           = <.value_
  .BYTE_1           = >.value_
  .BYTE_2           = <(.value_ >> 16)
  .BYTE_3           = >(.value_ >> 16)

    sec                         ; C = 1: converte come intero senza segno.

    lda #.BYTE_3                ; Carica il MSB della mantissa.
    sta FACHO

    !if (.BYTE_3 != .BYTE_2) {
      lda #.BYTE_2
    }

    sta FACMOH

    !if (.BYTE_2 != .BYTE_1) {
      lda #.BYTE_1
    }

    sta FACMO

    !if (.BYTE_1 != .BYTE_0) {
      lda #.BYTE_0
    }

    sta FACLO

    !if (.BYTE_0 != 0) {
      lda #0                    ; Azzera .A: FLOATB lo copia in FACOV e nel segno.
    }

    ldx #$A0                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_UINT32_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero senza segno a 32 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian), e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 (numero positivo). ARG non cambia.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (4 byte, RAM)     : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)           : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_UINT32_Mem .addr_ {
    sec                         ; C = 1: converte come intero senza segno.

    lda .addr_+3                ; Carica il MSB della mantissa.
    sta FACHO
    lda .addr_+2
    sta FACMOH
    lda .addr_+1
    sta FACMO
    lda .addr_
    sta FACLO

    lda #0                      ; Azzera .A: FLOATB lo copia in FACOV e nel segno.

    ldx #$A0                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_UINT32_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero senza segno a 32 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 (numero positivo). ARG non cambia.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (4 byte, RAM) : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_UINT32_Ptr .ptr_ {
    sec                         ; C = 1: converte come intero senza segno.

    ldy #3                      ; Carica il MSB della mantissa.
    lda (.ptr_),y
    sta FACHO
    dey
    lda (.ptr_),y
    sta FACMOH
    dey
    lda (.ptr_),y
    sta FACMO
    dey
    lda (.ptr_),y
    sta FACLO

    lda #0                      ; Azzera .A: FLOATB lo copia in FACOV e nel segno.

    ldx #$A0                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_UINT32
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero senza segno a 32 bit, passato
;               come costante.
;
;               I bit del valore oltre il bit #31 sono ignorati.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_UINT32 e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .value_ (4 byte, Macro) : Valore da caricare, senza segno
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_UINT32 .value_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_UINT32 .value_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_UINT32_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero senza segno a 32 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian).
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con la
;               macro m_Load_FAC_with_UINT32_Mem e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (4 byte, RAM)     : Intero, LSB per primo
;   - FAC (7 byte, ZP)           : Valore da conservare, registri da FACEXP a
;                                  FACOV
;
; Output:
;   - ARG (6 byte, ZP)           : Intero convertito, registri da ARGEXP a
;                                  ARGSGN
;   - FAC (7 byte, ZP)           : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_UINT32_Mem .addr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_UINT32_Mem .addr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_UINT32_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero senza segno a 32 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con la
;               macro m_Load_FAC_with_UINT32_Ptr e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (4 byte, RAM) : Intero, LSB per primo
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_UINT32_Ptr .ptr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_UINT32_Ptr .ptr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_INT32
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero con segno a 32 bit, passato come
;               costante, e azzera FACOV.
;
;               I bit del valore oltre il bit #31 sono ignorati.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 per i numeri senza segno e, per quelli con segno, lo
;               ricava dal bit #31 del MSB (complemento a due). ARG non cambia.
;
; Input:
;   - .value_ (4 byte, Macro) : Valore da caricare, con segno
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_INT32 .value_ {
  ; Byte del valore, dal LSB al MSB.
  .BYTE_0           = <.value_
  .BYTE_1           = >.value_
  .BYTE_2           = <(.value_ >> 16)
  .BYTE_3           = >(.value_ >> 16)

    lda #.BYTE_3                ; Carica il MSB della mantissa.
    sta FACHO
    eor #$FF                    ; Inverte il bit #7 del MSB.
    rol a                       ; C = 1 se positivo, C = 0 se negativo.

    lda #.BYTE_2
    sta FACMOH

    !if (.BYTE_2 != .BYTE_1) {
      lda #.BYTE_1
    }

    sta FACMO

    !if (.BYTE_1 != .BYTE_0) {
      lda #.BYTE_0
    }

    sta FACLO

    !if (.BYTE_0 != 0) {
      lda #0                    ; Azzera .A: FLOATB lo copia in FACOV e nel segno.
    }

    ldx #$A0                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_INT32_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero con segno a 32 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian), e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 per i numeri senza segno e, per quelli con segno, lo
;               ricava dal bit #31 del MSB (complemento a due). ARG non cambia.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (4 byte, RAM)     : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)           : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_INT32_Mem .addr_ {
    lda .addr_+3                ; Carica il MSB della mantissa.
    sta FACHO
    eor #$FF                    ; Inverte il bit #7 del MSB.
    rol a                       ; C = 1 se positivo, C = 0 se negativo.
    lda .addr_+2
    sta FACMOH
    lda .addr_+1
    sta FACMO
    lda .addr_
    sta FACLO

    lda #0                      ; Azzera .A: FLOATB lo copia in FACOV e nel segno.

    ldx #$A0                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_INT32_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un intero con segno a 32 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e
;               azzera FACOV.
;
;               Converte il numero con la routine FLOATB della ROM del BASIC,
;               che normalizza FAC e prende il segno dal Carry: la macro lo
;               imposta a 1 per i numeri senza segno e, per quelli con segno, lo
;               ricava dal bit #31 del MSB (complemento a due). ARG non cambia.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (4 byte, RAM) : Intero, LSB per primo
;
; Output:
;   - FAC (7 byte, ZP)        : Intero convertito, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_INT32_Ptr .ptr_ {
    ldy #3                      ; Carica il MSB della mantissa.
    lda (.ptr_),y
    sta FACHO
    eor #$FF                    ; Inverte il bit #7 del MSB.
    rol a                       ; C = 1 se positivo, C = 0 se negativo.
    dey
    lda (.ptr_),y
    sta FACMOH
    dey
    lda (.ptr_),y
    sta FACMO
    dey
    lda (.ptr_),y
    sta FACLO

    lda #0                      ; Azzera .A: FLOATB lo copia in FACOV e nel segno.

    ldx #$A0                    ; Esponente = $80 + numero di bit.

    jsr FLOATB                  ; Normalizza FAC e imposta il segno dal Carry.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_INT32
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero con segno a 32 bit, passato
;               come costante.
;
;               I bit del valore oltre il bit #31 sono ignorati.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_INT32 e li scambia di nuovo. Dopo
;               la chiamata FAC contiene il valore di prima, arrotondato,
;               e FACOV vale zero; il vecchio ARG si perde e ARISGN non
;               viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .value_ (4 byte, Macro) : Valore da caricare, con segno
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_INT32 .value_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_INT32 .value_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_INT32_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero con segno a 32 bit, letto da un
;               indirizzo assoluto, a partire dal LSB (little-endian).
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_INT32_Mem e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo dell'intero
;   - (.addr_) (4 byte, RAM)     : Intero, LSB per primo
;   - FAC (7 byte, ZP)           : Valore da conservare, registri da FACEXP a
;                                  FACOV
;
; Output:
;   - ARG (6 byte, ZP)           : Intero convertito, registri da ARGEXP a
;                                  ARGSGN
;   - FAC (7 byte, ZP)           : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_INT32_Mem .addr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_INT32_Mem .addr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_with_INT32_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un intero con segno a 32 bit, letto
;               dall'indirizzo indicato da un puntatore in ZP, LSB per primo.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, carica FAC con
;               la macro m_Load_FAC_with_INT32_Ptr e li scambia di nuovo.
;               Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero; il vecchio ARG si perde e
;               ARISGN non viene aggiornato.
;
;               Il contenuto di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - .ptr_ (1 byte, Macro)   : Indirizzo in ZP del puntatore
;   - (.ptr_) (2 byte, ZP)    : Indirizzo dell'intero (LSB, MSB)
;   - ((.ptr_)) (4 byte, RAM) : Intero, LSB per primo
;   - FAC (7 byte, ZP)        : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP)        : Intero convertito, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)        : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_INT32_Ptr .ptr_ {
    +m_Swap_FAC_and_ARG         ; Mette FAC al sicuro in ARG.
    +m_Load_FAC_with_INT32_Ptr .ptr_
    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_Convert_FAC_into_INT32
; ------------------------------------------------------------------------------
; Descrizione:  Converte il numero in virgola mobile di FAC in un intero a 32
;               bit con segno, arrotondato per difetto (verso -infinito, tenendo
;               conto anche di FACOV). Il numero deve stare nell'intervallo da
;               -2147483647 a 2147483647; fuori da questo intervallo il
;               risultato è indefinito.
;
;               L'intero, in complemento a due, va nei 4 byte della mantissa,
;               con il MSB in FACHO. Per ottenere un intero a 24, 16 o 8 bit, se
;               il valore ci sta, si leggono gli ultimi 3, 2 o 1 byte, cioè da
;               FACMOH, da FACMO o FACLO. FACEXP e FACSGN non cambiano, ma FAC
;               non è più un numero valido; FACOV contiene i bit scartati.
;
;               Chiama la routine QINT della ROM del BASIC, che usa la cella $68
;               (byte di overflow di FAC): deve valere zero in ingresso, e la
;               routine la azzera in uscita.
;
; Input:
;   - FAC (7 byte, ZP)   : Registri da FACEXP a FACOV
;
; Output:
;   - FACHO (4 byte, ZP) : Intero con segno, da FACHO a FACLO, MSB per primo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Convert_FAC_into_INT32 {
    jsr QINT                    ; Converte FAC in un intero a 32 bit con segno.
}

; ==============================================================================
; MACRO: m_Convert_ARG_into_INT32
; ------------------------------------------------------------------------------
; Descrizione:  Converte il numero in virgola mobile di ARG in un intero a 32
;               bit con segno, arrotondato per difetto (verso -infinito). Il
;               numero deve stare nell'intervallo da -2147483647 a 2147483647;
;               fuori da questo intervallo il risultato è indefinito.
;
;               L'intero, in complemento a due, va nei 4 byte della mantissa di
;               ARG, con il MSB in ARGHO. Per ottenere un intero a 24, 16 o 8
;               bit, se il valore ci sta, si leggono gli ultimi 3, 2 o 1 byte,
;               cioè da ARGMOH, da ARGMO o ARGLO. ARGEXP e ARGSGN non cambiano,
;               ma ARG non è più un numero valido. ARISGN non viene aggiornato.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, converte con la
;               routine QINT della ROM del BASIC, azzera FACOV e li scambia di
;               nuovo. Dopo la chiamata FAC contiene il valore di prima,
;               arrotondato, e FACOV vale zero. La macro azzera FACOV perché
;               QINT vi lascia i bit scartati, che lo Swap userebbe per
;               arrotondare l'intero.
;
;               QINT usa la cella $68 (byte di overflow di FAC): deve valere
;               zero in ingresso, e la routine la azzera in uscita. Il contenuto
;               di _SCRATCH_2 non è garantito dopo la chiamata.
;
; Input:
;   - ARG (6 byte, ZP)   : Registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)   : Valore da conservare, registri da FACEXP a FACOV
;
; Output:
;   - ARGHO (4 byte, ZP) : Intero con segno, da ARGHO a ARGLO, MSB per primo
;   - FAC (7 byte, ZP)   : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Convert_ARG_into_INT32 {
    +m_Swap_FAC_and_ARG         ; Porta il numero di ARG in FAC.

    jsr QINT                    ; Converte FAC in un intero a 32 bit con segno.

    lda #0                      ; Azzera FACOV, dove QINT lascia i bit scartati:
    sta FACOV                   ; altrimenti lo Swap arrotonderebbe l'intero.

    +m_Swap_FAC_and_ARG         ; Porta l'intero in ARG e ripristina FAC.
}

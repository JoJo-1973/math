; ==============================================================================
; FILE:           fp_memory.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per copiare numeri in virgola mobile (formato MBF) tra la
;                 memoria, FAC e ARG, e per scambiare FAC e ARG.
; CONTENUTO:      m_Load_FAC_from_Mem     Carica FAC da un indirizzo assoluto
;                 m_Load_FAC_from_Ptr     Carica FAC da un indirizzo puntato
;                 m_Load_ARG_from_Mem     Carica ARG da un indirizzo assoluto
;                 m_Load_ARG_from_Ptr     Carica ARG da un indirizzo puntato
;                 m_Store_FAC_to_Mem      Scrive FAC a un indirizzo assoluto
;                 m_Store_FAC_to_Ptr      Scrive FAC a un indirizzo puntato
;                 m_Store_ARG_to_Mem      Scrive ARG a un indirizzo assoluto
;                 m_Store_ARG_to_Ptr      Scrive ARG a un indirizzo puntato
;                 m_Transfer_FAC_to_ARG   Copia FAC in ARG
;                 m_Transfer_ARG_to_FAC   Copia ARG in FAC
;                 m_Swap_FAC_and_ARG      Scambia FAC e ARG
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   Nessuno
; ==============================================================================

; ==============================================================================
; MACRO: m_Load_FAC_from_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in virgola mobile, in formato MBF (5
;               byte), che si trova a un indirizzo assoluto, e azzera FACOV.
;
;               Chiama la routine MOVFM della ROM del BASIC, che altera anche
;               INDEX: il suo contenuto non è garantito dopo la chiamata.
;
; Input:
;   - .addr_ (2 byte, Macro) : Indirizzo del numero da caricare
;   - (.addr_) (5 byte, RAM) : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)       : Numero caricato, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_from_Mem .addr_ {
    lda #<.addr_                ; Punta .A/.Y all'indirizzo.
    ldy #>.addr_

    jsr MOVFM                   ; Copia il numero in FAC.
}

; ==============================================================================
; MACRO: m_Load_FAC_from_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in virgola mobile, in formato MBF (5
;               byte), a cui punta un puntatore, e azzera FACOV.
;
;               Chiama la routine MOVFM della ROM del BASIC, che altera anche
;               INDEX: il suo contenuto non è garantito dopo la chiamata.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro) : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)     : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)   : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)          : Numero caricato, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_from_Ptr .ptr_ {
    lda .ptr_                   ; Punta .A/.Y all'indirizzo.
    ldy .ptr_+1

    jsr MOVFM                   ; Copia il numero in FAC.
}

; ==============================================================================
; MACRO: m_Load_ARG_from_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con il numero in virgola mobile, in formato MBF (5
;               byte), che si trova a un indirizzo assoluto. FAC non cambia.
;
;               Chiama la routine CONUPK della ROM del BASIC, che altera anche
;               INDEX: il suo contenuto non è garantito dopo la chiamata. CONUPK
;               aggiorna ARISGN: il bit #7 vale 1 se i segni di FAC e di ARG
;               sono diversi.
;
; Input:
;   - .addr_ (2 byte, Macro) : Indirizzo del numero da caricare
;   - (.addr_) (5 byte, RAM) : Numero in formato MBF
;
; Output:
;   - ARG (6 byte, ZP)       : Numero caricato, registri da ARGEXP a ARGSGN
;   - ARISGN (1 byte, ZP)    : Bit #7: 0 = segni uguali; 1 = segni diversi
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_from_Mem .addr_ {
    lda #<.addr_                ; Punta .A/.Y all'indirizzo.
    ldy #>.addr_

    jsr CONUPK                  ; Copia il numero in ARG.
}

; ==============================================================================
; MACRO: m_Load_ARG_from_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con il numero in virgola mobile, in formato MBF (5
;               byte), a cui punta un puntatore. FAC non cambia.
;
;               Chiama la routine CONUPK della ROM del BASIC, che altera anche
;               INDEX: il suo contenuto non è garantito dopo la chiamata. CONUPK
;               aggiorna ARISGN: il bit #7 vale 1 se i segni di FAC e di ARG
;               sono diversi.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro) : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)     : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)   : Numero in formato MBF
;
; Output:
;   - ARG (6 byte, ZP)          : Numero caricato, registri da ARGEXP a ARGSGN
;   - ARISGN (1 byte, ZP)       : Bit #7: 0 = segni uguali; 1 = segni diversi
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_from_Ptr .ptr_ {
    lda .ptr_                   ; Punta .A/.Y all'indirizzo.
    ldy .ptr_+1

    jsr CONUPK                  ; Copia il numero in ARG.
}

; ==============================================================================
; MACRO: m_Store_FAC_to_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Scrive FAC in formato MBF (5 byte) a un indirizzo assoluto. FAC
;               viene prima arrotondato, perché il formato in memoria non ha il
;               byte di arrotondamento: dopo la chiamata FAC contiene il valore
;               arrotondato e FACOV vale zero.
;
;               Chiama la routine MOVMF della ROM del BASIC, che altera anche
;               INDEX: il suo contenuto non è garantito dopo la chiamata.
;
; Input:
;   - .addr_ (2 byte, Macro) : Indirizzo di destinazione
;
; Output:
;   - .addr_ (5 byte, Macro) : Riceve FAC in formato MBF
;   - FAC (7 byte, ZP)       : Arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Store_FAC_to_Mem .addr_ {
    ldx #<.addr_                ; Punta .X/.Y all'indirizzo.
    ldy #>.addr_

    jsr MOVMF                   ; Arrotonda FAC e lo copia in memoria.
}

; ==============================================================================
; MACRO: m_Store_FAC_to_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Scrive FAC in formato MBF (5 byte) a un indirizzo a cui punta un
;               puntatore. FAC viene prima arrotondato, perché il formato in
;               memoria non ha il byte di arrotondamento: dopo la chiamata FAC
;               contiene il valore arrotondato e FACOV vale zero.
;
;               Chiama la routine MOVMF della ROM del BASIC, che altera anche
;               INDEX: il suo contenuto non è garantito dopo la chiamata.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro) : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)     : Indirizzo di destinazione (LSB, MSB)
;
; Output:
;   - ((.ptr_)) (5 byte, RAM)   : Riceve FAC in formato MBF
;   - FAC (7 byte, ZP)          : Arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Store_FAC_to_Ptr .ptr_ {
    ldx .ptr_                   ; Punta .X/.Y all'indirizzo.
    ldy .ptr_+1

    jsr MOVMF                   ; Arrotonda FAC e lo copia in memoria.
}

; ==============================================================================
; MACRO: m_Store_ARG_to_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Scrive ARG in formato MBF (5 byte) a un indirizzo assoluto,
;               senza chiamare la ROM del BASIC. Nel MSB della mantissa il
;               bit #7, che in ARG è sempre 1, è sostituito dal segno. ARG non
;               cambia e non va arrotondato, perché lo è già.
;
; Input:
;   - .addr_ (2 byte, Macro) : Indirizzo di destinazione
;   - ARG (6 byte, ZP)       : Registri da ARGEXP a ARGSGN
;
; Output:
;   - .addr_ (5 byte, Macro) : Riceve ARG in formato MBF
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Store_ARG_to_Mem .addr_ {
    lda ARGEXP                  ; Salva il byte dell'esponente.
    sta .addr_

    ; Il segno di ARG è il bit #7 di ARGSGN. La maschera in .A
    ; vale $FF se il segno è negativo e $7F se è positivo:
    ; applicata al MSB della mantissa, che ha sempre il bit #7 a
    ; 1, lo sostituisce con il segno.

    lda ARGSGN
    ora #%01111111
    and ARGHO
    sta .addr_+1

    lda ARGMOH                  ; Salva il secondo byte della mantissa.
    sta .addr_+2

    lda ARGMO                   ; Salva il terzo byte della mantissa.
    sta .addr_+3

    lda ARGLO                   ; Salva il LSB della mantissa.
    sta .addr_+4
}

; ==============================================================================
; MACRO: m_Store_ARG_to_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Scrive ARG in formato MBF (5 byte) a un indirizzo a cui punta un
;               puntatore, senza chiamare la ROM del BASIC. Nel MSB della
;               mantissa il bit #7, che in ARG è sempre 1, è sostituito dal
;               segno. ARG non cambia e non va arrotondato, perché lo è già.
;
;               L'indirizzo di destinazione passa per INDEX, il puntatore
;               temporaneo che la ROM usa per queste operazioni.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro) : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)     : Indirizzo di destinazione (LSB, MSB)
;   - ARG (6 byte, ZP)          : Registri da ARGEXP a ARGSGN
;
; Output:
;   - ((.ptr_)) (5 byte, RAM)   : Riceve ARG in formato MBF
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, Zero), INDEX, INDEX+1
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Store_ARG_to_Ptr .ptr_ {
    ldx .ptr_                   ; Punta .X/.Y all'indirizzo.
    ldy .ptr_+1
    stx INDEX                   ; Copia l'indirizzo in INDEX, puntatore della ROM.
    sty INDEX+1

    ldy #0

    lda ARGEXP                  ; Salva il byte dell'esponente.
    sta (INDEX),y

    iny

    ; Il segno di ARG è il bit #7 di ARGSGN. La maschera in .A
    ; vale $FF se il segno è negativo e $7F se è positivo:
    ; applicata al MSB della mantissa, che ha sempre il bit #7 a
    ; 1, lo sostituisce con il segno.

    lda ARGSGN
    ora #%01111111
    and ARGHO
    sta (INDEX),y

    iny                         ; Salva il secondo byte della mantissa.
    lda ARGMOH
    sta (INDEX),y

    iny                         ; Salva il terzo byte della mantissa.
    lda ARGMO
    sta (INDEX),y

    iny                         ; Salva il LSB della mantissa.
    lda ARGLO
    sta (INDEX),y
}

; ==============================================================================
; MACRO: m_Transfer_FAC_to_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Copia FAC in ARG. FAC viene prima arrotondato, perché ARG non
;               può contenere un valore non arrotondato: dopo la chiamata FAC
;               contiene il valore arrotondato e FACOV vale zero. ARISGN non
;               viene aggiornato.
;
;               Chiama la routine MOVAF della ROM del BASIC.
;
; Input:
;   - FAC (7 byte, ZP) : Registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP) : Copia di FAC, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP) : Arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Transfer_FAC_to_ARG {
    jsr MOVAF                   ; Arrotonda FAC e lo copia in ARG.
}

; ==============================================================================
; MACRO: m_Transfer_ARG_to_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Copia ARG in FAC e azzera FACOV. ARG e ARISGN non cambiano.
;
;               Chiama la routine MOVFA della ROM del BASIC.
;
; Input:
;   - ARG (6 byte, ZP) : Registri da ARGEXP a ARGSGN
;
; Output:
;   - FAC (7 byte, ZP) : Copia di ARG, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Transfer_ARG_to_FAC {
    jsr MOVFA                   ; Copia ARG in FAC.
}

; ==============================================================================
; MACRO: m_Swap_FAC_and_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Scambia FAC e ARG. FAC viene prima arrotondato, perché ARG non
;               può contenere un valore non arrotondato: dopo lo scambio FACOV
;               vale zero. ARISGN non viene aggiornato.
;
;               Salva ARG in _SCRATCH_2 e chiama la routine MOVAF della ROM
;               del BASIC. Il contenuto di _SCRATCH_2 non è garantito dopo
;               la chiamata.
;
; Input:
;   - FAC (7 byte, ZP) : Registri da FACEXP a FACOV
;   - ARG (6 byte, ZP) : Registri da ARGEXP a ARGSGN
;
; Output:
;   - FAC (7 byte, ZP) : Valore di ARG, FACOV azzerato
;   - ARG (6 byte, ZP) : Valore di FAC, arrotondato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry), FAC, _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Swap_FAC_and_ARG {
    +m_Store_ARG_in_Scratch     ; Salva ARG in _SCRATCH_2.

    jsr MOVAF                   ; Arrotonda FAC e lo copia in ARG.

    lda _SCRATCH_2              ; Ripristina il byte dell'esponente di ARG in FAC.
    sta FACEXP

    lda _SCRATCH_2+1            ; Ripristina il MSB della mantissa di ARG in FAC.
    sta FACHO

    lda _SCRATCH_2+2            ; Ripristina il secondo byte della mantissa di ARG in FAC.
    sta FACMOH

    lda _SCRATCH_2+3            ; Ripristina il terzo byte della mantissa di ARG in FAC.
    sta FACMO

    lda _SCRATCH_2+4            ; Ripristina il LSB della mantissa di ARG in FAC.
    sta FACLO

    lda _SCRATCH_2+5            ; Ripristina il byte del segno di ARG in FAC.
    sta FACSGN

    lda #$00                    ; Azzera il byte di arrotondamento di FAC,
    sta FACOV                   ; perché il valore di ARG è sempre arrotondato.
}

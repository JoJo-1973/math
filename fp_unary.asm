; ==============================================================================
; FILE:           fp_unary.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per le funzioni unarie sui numeri in virgola mobile
;                 (formato MBF): cambio di segno, valore assoluto, segno, parte
;                 intera, moltiplicazione e divisione per 2.
; CONTENUTO:      m_Negate_FAC          Cambia il segno di FAC
;                 m_Negate_ARG          Cambia il segno di ARG
;                 m_Negate_Mem          Nega da indirizzo, in FAC
;                 m_Negate_Ptr          Nega da puntatore, in FAC
;                 m_ABS_FAC             Valore assoluto di FAC
;                 m_ABS_ARG             Valore assoluto di ARG
;                 m_ABS_Mem             Valore assoluto da indirizzo
;                 m_ABS_Ptr             Valore assoluto da puntatore
;                 m_Sign_FAC            Segno di FAC in .A
;                 m_Sign_ARG            Segno di ARG in .A
;                 m_Sign_Mem            Segno da indirizzo, in .A
;                 m_Sign_Ptr            Segno da puntatore, in .A
;                 m_SGN_FAC             FAC diventa il suo segno
;                 m_SGN_ARG             ARG diventa il suo segno
;                 m_SGN_Mem             Segno da indirizzo, in FAC
;                 m_SGN_Ptr             Segno da puntatore, in FAC
;                 m_INT_FAC             Arrotonda FAC per difetto
;                 m_INT_ARG             Arrotonda ARG per difetto
;                 m_INT_Mem             Arrotonda da indirizzo, in FAC
;                 m_INT_Ptr             Arrotonda da puntatore, in FAC
;                 m_Multiply_FAC_by_2   Moltiplica FAC per 2
;                 m_Multiply_ARG_by_2   Moltiplica ARG per 2
;                 m_Multiply_Mem_by_2   Per 2 da indirizzo, in FAC
;                 m_Multiply_Ptr_by_2   Per 2 da puntatore, in FAC
;                 m_Divide_FAC_by_2     Divide FAC per 2
;                 m_Divide_ARG_by_2     Divide ARG per 2
;                 m_Divide_Mem_by_2     Diviso 2 da indirizzo, in FAC
;                 m_Divide_Ptr_by_2     Diviso 2 da puntatore, in FAC
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   Nessuno
; ==============================================================================

; ==============================================================================
; MACRO: m_Negate_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Cambia il segno del numero in virgola mobile di FAC.
;
;               Se FAC è zero (FACEXP = 0) il segno non cambia, come fa
;               la routine della ROM del BASIC, per non produrre uno zero
;               con segno.
;
; Input:
;   - FAC (7 byte, ZP)    : Registri da FACEXP a FACOV
;
; Output:
;   - FACSGN (1 byte, ZP) : Segno invertito, solo il bit #7 è significativo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FACSGN
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Negate_FAC {
    lda FACEXP                  ; Se è zero, non cambia il segno.
    beq .Exit_NEGATE_FAC

    lda FACSGN                  ; Inverte il bit #7 del segno.
    eor #$FF
    sta FACSGN

  .Exit_NEGATE_FAC:
}

; ==============================================================================
; MACRO: m_Negate_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Cambia il segno del numero in virgola mobile di ARG.
;
;               Se ARG è zero (ARGEXP = 0) il segno non cambia, come fa la
;               routine della ROM del BASIC, per non produrre uno zero con
;               segno. ARISGN non viene aggiornato.
;
; Input:
;   - ARG (6 byte, ZP)    : Registri da ARGEXP a ARGSGN
;
; Output:
;   - ARGSGN (1 byte, ZP) : Segno invertito, solo il bit #7 è significativo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARGSGN
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Negate_ARG {
    lda ARGEXP                  ; Se è zero, non cambia il segno.
    beq .Exit_NEGATE_ARG

    lda ARGSGN                  ; Inverte il bit #7 del segno.
    eor #$FF
    sta ARGSGN

  .Exit_NEGATE_ARG:
}

; ==============================================================================
; MACRO: m_Negate_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova a un
;               indirizzo assoluto, ne cambia il segno e lascia il risultato
;               in FAC.
;
;               La lettura usa m_Load_FAC_from_Mem, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               Se FAC è zero (FACEXP = 0) il segno non cambia, come fa
;               la routine della ROM del BASIC, per non produrre uno zero
;               con segno.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)     : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)           : Numero letto, con segno invertito, registri
;                                  da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry), FACSGN
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Negate_Mem .addr_ {
    +m_Load_FAC_from_Mem .addr_
    lda FACEXP                  ; Se è zero, non cambia il segno.
    beq .Exit_NEGATE_MEM

    lda FACSGN                  ; Inverte il bit #7 del segno.
    eor #$FF
    sta FACSGN

  .Exit_NEGATE_MEM:
}

; ==============================================================================
; MACRO: m_Negate_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore, ne cambia il segno e
;               lascia il risultato in FAC.
;
;               La lettura usa m_Load_FAC_from_Ptr, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               Se FAC è zero (FACEXP = 0) il segno non cambia, come fa
;               la routine della ROM del BASIC, per non produrre uno zero
;               con segno.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro) : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)     : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)   : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)          : Numero letto, con segno invertito, registri da
;                                 FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry), FACSGN
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Negate_Ptr .ptr_ {
    +m_Load_FAC_from_Ptr .ptr_
    lda FACEXP                  ; Se è zero, non cambia il segno.
    beq .Exit_NEGATE_PTR

    lda FACSGN                  ; Inverte il bit #7 del segno.
    eor #$FF
    sta FACSGN

  .Exit_NEGATE_PTR:
}

; ==============================================================================
; MACRO: m_ABS_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Azzera il segno del numero in virgola mobile di FAC, cioè ne
;               calcola il valore assoluto.
;
;               Basta azzerare il bit #7 del segno.
;
; Input:
;   - FAC (7 byte, ZP)    : Registri da FACEXP a FACOV
;
; Output:
;   - FACSGN (1 byte, ZP) : Bit #7 azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .P (Negative, Zero, Carry), FACSGN
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_ABS_FAC {
    lsr FACSGN                  ; Azzera il bit #7 del segno.
}

; ==============================================================================
; MACRO: m_ABS_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Azzera il segno del numero in virgola mobile di ARG, cioè ne
;               calcola il valore assoluto.
;
;               Basta azzerare il bit #7 del segno. ARISGN non viene aggiornato.
;
; Input:
;   - ARG (6 byte, ZP)    : Registri da ARGEXP a ARGSGN
;
; Output:
;   - ARGSGN (1 byte, ZP) : Bit #7 azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .P (Negative, Zero, Carry), ARGSGN
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_ABS_ARG {
    lsr ARGSGN                  ; Azzera il bit #7 del segno.
}

; ==============================================================================
; MACRO: m_ABS_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova a un
;               indirizzo assoluto e ne calcola il valore assoluto, lasciando il
;               risultato in FAC.
;
;               La lettura usa m_Load_FAC_from_Mem, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               Basta azzerare il bit #7 del segno.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)     : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)           : Valore assoluto, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry), FACSGN
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_ABS_Mem .addr_ {
    +m_Load_FAC_from_Mem .addr_
    lsr FACSGN                  ; Azzera il bit #7 del segno.
}

; ==============================================================================
; MACRO: m_ABS_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e ne calcola il valore
;               assoluto, lasciando il risultato in FAC.
;
;               La lettura usa m_Load_FAC_from_Ptr, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               Basta azzerare il bit #7 del segno.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro) : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)     : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)   : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)          : Valore assoluto, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry), FACSGN
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_ABS_Ptr .ptr_ {
    +m_Load_FAC_from_Ptr .ptr_
    lsr FACSGN                  ; Azzera il bit #7 del segno.
}

; ==============================================================================
; MACRO: m_Sign_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Restituisce in .A il segno del numero in virgola mobile di FAC.
;
;               Chiama la routine SIGN della ROM del BASIC.
;
;               Se il numero è zero il Carry non è garantito.
;
; Input:
;   - FAC (7 byte, ZP)       : Registri da FACEXP a FACOV
;
; Output:
;   - .A (1 byte, CPU)       : $FF = negativo; $00 = zero; $01 = positivo
;   - Flag Carry (1 bit, .P) : 0 = positivo; 1 = negativo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Sign_FAC {
    jsr SIGN                    ; Legge il segno di FAC in .A.
}

; ==============================================================================
; MACRO: m_Sign_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Restituisce in .A il segno del numero in virgola mobile di ARG.
;
;               Il codice è interno alla macro.
;
;               Se il numero è zero il Carry non è garantito.
;
; Input:
;   - ARG (6 byte, ZP)       : Registri da ARGEXP a ARGSGN
;
; Output:
;   - .A (1 byte, CPU)       : $FF = negativo; $00 = zero; $01 = positivo
;   - Flag Carry (1 bit, .P) : 0 = positivo; 1 = negativo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Sign_ARG {
    lda ARGEXP                  ; Se ARG è zero, .A = 0 ed esce.
    beq .Exit_SIGN_ARG

    lda ARGSGN                  ; Altrimenti ruota il segno nel Carry.
    rol a
    lda #$FF                    ; Prepara .A = $FF (negativo)
    bcs .Exit_SIGN_ARG          ; ed esce se C = 1.

    lda #$01                    ; Altrimenti .A = $01 (positivo).

  .Exit_SIGN_ARG:
}

; ==============================================================================
; MACRO: m_Sign_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova a un
;               indirizzo assoluto e restituisce in .A il suo segno.
;
;               La lettura usa m_Load_FAC_from_Mem, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               Chiama la routine SIGN della ROM del BASIC.
;
;               Se il numero è zero il Carry non è garantito.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)     : Numero in formato MBF
;
; Output:
;   - .A (1 byte, CPU)           : $FF = negativo; $00 = zero; $01 = positivo
;   - Flag Carry (1 bit, .P)     : 0 = positivo; 1 = negativo
;   - FAC (7 byte, ZP)           : Numero letto, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Sign_Mem .addr_ {
    +m_Load_FAC_from_Mem .addr_
    jsr SIGN                    ; Legge il segno di FAC in .A.
}

; ==============================================================================
; MACRO: m_Sign_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e restituisce in .A il
;               suo segno.
;
;               La lettura usa m_Load_FAC_from_Ptr, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               Chiama la routine SIGN della ROM del BASIC.
;
;               Se il numero è zero il Carry non è garantito.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro) : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)     : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)   : Numero in formato MBF
;
; Output:
;   - .A (1 byte, CPU)          : $FF = negativo; $00 = zero; $01 = positivo
;   - Flag Carry (1 bit, .P)    : 0 = positivo; 1 = negativo
;   - FAC (7 byte, ZP)          : Numero letto, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Sign_Ptr .ptr_ {
    +m_Load_FAC_from_Ptr .ptr_
    jsr SIGN                    ; Legge il segno di FAC in .A.
}

; ==============================================================================
; MACRO: m_SGN_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Sostituisce il numero in virgola mobile di FAC con il suo segno:
;               -1, 0 o 1.
;
;               Chiama la routine SGN della ROM del BASIC.
;
; Input:
;   - FAC (7 byte, ZP) : Registri da FACEXP a FACOV
;
; Output:
;   - FAC (7 byte, ZP) : -1, 0 o 1, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_SGN_FAC {
    jsr SGN                     ; Sostituisce FAC con il suo segno.
}

; ==============================================================================
; MACRO: m_SGN_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Sostituisce il numero in virgola mobile di ARG con il suo segno:
;               -1, 0 o 1.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, chiama la routine SGN
;               della ROM del BASIC e li scambia di nuovo. Dopo la chiamata FAC
;               contiene il valore di prima, arrotondato, e FACOV vale zero;
;               ARISGN non viene aggiornato. Il contenuto di _SCRATCH_2 non è
;               garantito dopo la chiamata.
;
; Input:
;   - ARG (6 byte, ZP) : Registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP) : Registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP) : -1, 0 o 1, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP) : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_SGN_ARG {
    +m_Swap_FAC_and_ARG         ; Porta ARG in FAC.
    jsr SGN                     ; Sostituisce FAC con il suo segno.
    +m_Swap_FAC_and_ARG         ; Porta il risultato in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_SGN_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova a un
;               indirizzo assoluto e lo sostituisce con il suo segno: -1, 0 o 1.
;
;               La lettura usa m_Load_FAC_from_Mem, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               Chiama la routine SGN della ROM del BASIC.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)     : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)           : -1, 0 o 1, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_SGN_Mem .addr_ {
    +m_Load_FAC_from_Mem .addr_
    jsr SGN                     ; Sostituisce FAC con il suo segno.
}

; ==============================================================================
; MACRO: m_SGN_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e lo sostituisce con il
;               suo segno: -1, 0 o 1.
;
;               La lettura usa m_Load_FAC_from_Ptr, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               Chiama la routine SGN della ROM del BASIC.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro) : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)     : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)   : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)          : -1, 0 o 1, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_SGN_Ptr .ptr_ {
    +m_Load_FAC_from_Ptr .ptr_
    jsr SGN                     ; Sostituisce FAC con il suo segno.
}

; ==============================================================================
; MACRO: m_INT_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Arrotonda per difetto, verso -infinito, il numero in virgola
;               mobile di FAC: 1.2 diventa 1 e -1.2 diventa -2.
;
;               I numeri con esponente maggiore o uguale a $A0, cioè di valore
;               assoluto non inferiore a 2^31, sono già interi e non cambiano.
;
;               Chiama la routine INT della ROM del BASIC.
;
;               La routine INT altera le celle $07 e $68; usa QINT, che richiede
;               $68 = 0 in ingresso e lo azzera in uscita. Il contenuto di $07
;               non è garantito dopo la chiamata.
;
; Input:
;   - FAC (7 byte, ZP) : Registri da FACEXP a FACOV
;
; Output:
;   - FAC (7 byte, ZP) : Numero arrotondato, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_INT_FAC {
    jsr INT                     ; Arrotonda FAC per difetto.
}

; ==============================================================================
; MACRO: m_INT_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Arrotonda per difetto, verso -infinito, il numero in virgola
;               mobile di ARG: 1.2 diventa 1 e -1.2 diventa -2.
;
;               I numeri con esponente maggiore o uguale a $A0, cioè di valore
;               assoluto non inferiore a 2^31, sono già interi e non cambiano.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, chiama la routine INT
;               della ROM del BASIC e li scambia di nuovo. Dopo la chiamata FAC
;               contiene il valore di prima, arrotondato, e FACOV vale zero;
;               ARISGN non viene aggiornato. Il contenuto di _SCRATCH_2 non è
;               garantito dopo la chiamata.
;
;               La routine INT altera le celle $07 e $68; usa QINT, che richiede
;               $68 = 0 in ingresso e lo azzera in uscita. Il contenuto di $07
;               non è garantito dopo la chiamata.
;
; Input:
;   - ARG (6 byte, ZP) : Registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP) : Registri da FACEXP a FACOV
;
; Output:
;   - ARG (6 byte, ZP) : Numero arrotondato, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP) : Valore di prima, arrotondato, FACOV azzerato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), FAC,
;                       _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_INT_ARG {
    +m_Swap_FAC_and_ARG         ; Porta ARG in FAC.
    jsr INT                     ; Arrotonda FAC per difetto.
    +m_Swap_FAC_and_ARG         ; Porta il risultato in ARG e ripristina FAC.
}

; ==============================================================================
; MACRO: m_INT_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova a un
;               indirizzo assoluto e lo arrotonda per difetto, verso -infinito:
;               1.2 diventa 1 e -1.2 diventa -2. Il risultato resta in FAC.
;
;               La lettura usa m_Load_FAC_from_Mem, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               I numeri con esponente maggiore o uguale a $A0, cioè di valore
;               assoluto non inferiore a 2^31, sono già interi e non cambiano.
;
;               Chiama la routine INT della ROM del BASIC.
;
;               La routine INT altera le celle $07 e $68; usa QINT, che richiede
;               $68 = 0 in ingresso e lo azzera in uscita. Il contenuto di $07
;               non è garantito dopo la chiamata.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)     : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)           : Numero arrotondato, registri da FACEXP a
;                                  FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_INT_Mem .addr_ {
    +m_Load_FAC_from_Mem .addr_
    jsr INT                     ; Arrotonda FAC per difetto.
}

; ==============================================================================
; MACRO: m_INT_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e lo arrotonda per
;               difetto, verso -infinito: 1.2 diventa 1 e -1.2 diventa -2. Il
;               risultato resta in FAC.
;
;               La lettura usa m_Load_FAC_from_Ptr, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               I numeri con esponente maggiore o uguale a $A0, cioè di valore
;               assoluto non inferiore a 2^31, sono già interi e non cambiano.
;
;               Chiama la routine INT della ROM del BASIC.
;
;               La routine INT altera le celle $07 e $68; usa QINT, che richiede
;               $68 = 0 in ingresso e lo azzera in uscita. Il contenuto di $07
;               non è garantito dopo la chiamata.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro) : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)     : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)   : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)          : Numero arrotondato, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_INT_Ptr .ptr_ {
    +m_Load_FAC_from_Ptr .ptr_
    jsr INT                     ; Arrotonda FAC per difetto.
}

; ==============================================================================
; MACRO: m_Multiply_FAC_by_2
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica per 2 il numero in virgola mobile di FAC,
;               incrementando l'esponente.
;
;               È molto più veloce di una moltiplicazione o di una divisione
;               vera e propria.
;
;               Se FAC è zero (FACEXP = 0) resta zero. Se l'esponente vale $FF
;               il risultato è zero, senza l'errore di overflow della ROM del
;               BASIC: il valore è troppo grande per il formato MBF.
;
; Input:
;   - FAC (7 byte, ZP)    : Registri da FACEXP a FACOV
;
; Output:
;   - FACEXP (1 byte, ZP) : Esponente incrementato, salvo se il numero è zero
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FACEXP
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Multiply_FAC_by_2 {
    lda FACEXP                  ; Se è zero, lo lascia com'è.
    beq .Exit_MULTIPLY_FAC_BY_2

    inc FACEXP                  ; Cambia l'esponente.

  .Exit_MULTIPLY_FAC_BY_2:
}

; ==============================================================================
; MACRO: m_Multiply_ARG_by_2
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica per 2 il numero in virgola mobile di ARG,
;               incrementando l'esponente.
;
;               È molto più veloce di una moltiplicazione o di una divisione
;               vera e propria.
;
;               Se ARG è zero (ARGEXP = 0) resta zero. Se l'esponente vale $FF
;               il risultato è zero, senza l'errore di overflow della ROM del
;               BASIC: il valore è troppo grande per il formato MBF.
;
; Input:
;   - ARG (6 byte, ZP)    : Registri da ARGEXP a ARGSGN
;
; Output:
;   - ARGEXP (1 byte, ZP) : Esponente incrementato, salvo se il numero è zero
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARGEXP
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Multiply_ARG_by_2 {
    lda ARGEXP                  ; Se è zero, lo lascia com'è.
    beq .Exit_MULTIPLY_ARG_BY_2

    inc ARGEXP                  ; Cambia l'esponente.

  .Exit_MULTIPLY_ARG_BY_2:
}

; ==============================================================================
; MACRO: m_Multiply_Mem_by_2
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova a un
;               indirizzo assoluto e lo moltiplica per 2, incrementando
;               l'esponente. Il risultato resta in FAC.
;
;               La lettura usa m_Load_FAC_from_Mem, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               È molto più veloce di una moltiplicazione o di una divisione
;               vera e propria.
;
;               Se FAC è zero (FACEXP = 0) resta zero. Se l'esponente vale $FF
;               il risultato è zero, senza l'errore di overflow della ROM del
;               BASIC: il valore è troppo grande per il formato MBF.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)     : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)           : Numero letto moltiplicato per 2, registri da
;                                  FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry), FACEXP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Multiply_Mem_by_2 .addr_ {
    +m_Load_FAC_from_Mem .addr_
    lda FACEXP                  ; Se è zero, lo lascia com'è.
    beq .Exit_MULTIPLY_MEM_BY_2

    inc FACEXP                  ; Cambia l'esponente.

  .Exit_MULTIPLY_MEM_BY_2:
}

; ==============================================================================
; MACRO: m_Multiply_Ptr_by_2
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e lo moltiplica per 2,
;               incrementando l'esponente. Il risultato resta in FAC.
;
;               La lettura usa m_Load_FAC_from_Ptr, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               È molto più veloce di una moltiplicazione o di una divisione
;               vera e propria.
;
;               Se FAC è zero (FACEXP = 0) resta zero. Se l'esponente vale $FF
;               il risultato è zero, senza l'errore di overflow della ROM del
;               BASIC: il valore è troppo grande per il formato MBF.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro) : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)     : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)   : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)          : Numero letto moltiplicato per 2, registri da
;                                 FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry), FACEXP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Multiply_Ptr_by_2 .ptr_ {
    +m_Load_FAC_from_Ptr .ptr_
    lda FACEXP                  ; Se è zero, lo lascia com'è.
    beq .Exit_MULTIPLY_PTR_BY_2

    inc FACEXP                  ; Cambia l'esponente.

  .Exit_MULTIPLY_PTR_BY_2:
}

; ==============================================================================
; MACRO: m_Divide_FAC_by_2
; ------------------------------------------------------------------------------
; Descrizione:  Divide per 2 il numero in virgola mobile di FAC,
;               decrementando l'esponente.
;
;               È molto più veloce di una moltiplicazione o di una divisione
;               vera e propria.
;
;               Se FAC è zero (FACEXP = 0) resta zero. Se l'esponente vale 1 il
;               risultato è zero (underflow): il valore è troppo piccolo per il
;               formato MBF.
;
; Input:
;   - FAC (7 byte, ZP)    : Registri da FACEXP a FACOV
;
; Output:
;   - FACEXP (1 byte, ZP) : Esponente decrementato, salvo se il numero è zero
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FACEXP
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Divide_FAC_by_2 {
    lda FACEXP                  ; Se è zero, lo lascia com'è.
    beq .Exit_DIVIDE_FAC_BY_2

    dec FACEXP                  ; Cambia l'esponente.

  .Exit_DIVIDE_FAC_BY_2:
}

; ==============================================================================
; MACRO: m_Divide_ARG_by_2
; ------------------------------------------------------------------------------
; Descrizione:  Divide per 2 il numero in virgola mobile di ARG,
;               decrementando l'esponente.
;
;               È molto più veloce di una moltiplicazione o di una divisione
;               vera e propria.
;
;               Se ARG è zero (ARGEXP = 0) resta zero. Se l'esponente vale 1 il
;               risultato è zero (underflow): il valore è troppo piccolo per il
;               formato MBF.
;
; Input:
;   - ARG (6 byte, ZP)    : Registri da ARGEXP a ARGSGN
;
; Output:
;   - ARGEXP (1 byte, ZP) : Esponente decrementato, salvo se il numero è zero
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARGEXP
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Divide_ARG_by_2 {
    lda ARGEXP                  ; Se è zero, lo lascia com'è.
    beq .Exit_DIVIDE_ARG_BY_2

    dec ARGEXP                  ; Cambia l'esponente.

  .Exit_DIVIDE_ARG_BY_2:
}

; ==============================================================================
; MACRO: m_Divide_Mem_by_2
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova a un
;               indirizzo assoluto e lo divide per 2, decrementando l'esponente.
;               Il risultato resta in FAC.
;
;               La lettura usa m_Load_FAC_from_Mem, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               È molto più veloce di una moltiplicazione o di una divisione
;               vera e propria.
;
;               Se FAC è zero (FACEXP = 0) resta zero. Se l'esponente vale 1 il
;               risultato è zero (underflow): il valore è troppo piccolo per il
;               formato MBF.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)     : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)           : Numero letto diviso per 2, registri da FACEXP
;                                  a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry), FACEXP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Divide_Mem_by_2 .addr_ {
    +m_Load_FAC_from_Mem .addr_
    lda FACEXP                  ; Se è zero, lo lascia com'è.
    beq .Exit_DIVIDE_MEM_BY_2

    dec FACEXP                  ; Cambia l'esponente.

  .Exit_DIVIDE_MEM_BY_2:
}

; ==============================================================================
; MACRO: m_Divide_Ptr_by_2
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e lo divide per 2,
;               decrementando l'esponente. Il risultato resta in FAC.
;
;               La lettura usa m_Load_FAC_from_Ptr, che altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata. Il vecchio
;               contenuto di FAC si perde.
;
;               È molto più veloce di una moltiplicazione o di una divisione
;               vera e propria.
;
;               Se FAC è zero (FACEXP = 0) resta zero. Se l'esponente vale 1 il
;               risultato è zero (underflow): il valore è troppo piccolo per il
;               formato MBF.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro) : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)     : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)   : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)          : Numero letto diviso per 2, registri da FACEXP
;                                 a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry), FACEXP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Divide_Ptr_by_2 .ptr_ {
    +m_Load_FAC_from_Ptr .ptr_
    lda FACEXP                  ; Se è zero, lo lascia com'è.
    beq .Exit_DIVIDE_PTR_BY_2

    dec FACEXP                  ; Cambia l'esponente.

  .Exit_DIVIDE_PTR_BY_2:
}

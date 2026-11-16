; ==============================================================================
; FILE:           fp_transcend.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per le funzioni trascendenti sui numeri in virgola
;                 mobile (formato MBF): logaritmo naturale ed esponenziale (e
;                 elevato a un numero). L'argomento può essere in FAC, in ARG, a
;                 un indirizzo assoluto o puntato da un puntatore; il risultato
;                 è sempre in FAC. L'interruttore __PRESERVE_ARG di config.asm
;                 decide se ARG viene preservato.
; CONTENUTO:      m_LOG_FAC   Logaritmo di FAC
;                 m_LOG_ARG   Logaritmo di ARG
;                 m_LOG_Mem   Logaritmo da indirizzo
;                 m_LOG_Ptr   Logaritmo da puntatore
;                 m_EXP_FAC   Esponenziale di FAC
;                 m_EXP_ARG   Esponenziale di ARG
;                 m_EXP_Mem   Esponenziale da indirizzo
;                 m_EXP_Ptr   Esponenziale da puntatore
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   __FP_SAVED_SP
; ==============================================================================

; ==============================================================================
; MACRO: m_LOG_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il logaritmo naturale del numero in virgola mobile di
;               FAC e lascia il risultato in FAC.
;
;               Chiama la routine LOG della ROM del BASIC. Se il numero è zero o
;               negativo la ROM segnala ILLEGAL QUANTITY ERROR e non ritorna al
;               chiamante: vedi [NOTA #07 in <fp/fp.asm>]. LOG(1) vale zero.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, RESHO, $56, NUMWRK, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #11 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - FAC (7 byte, ZP)               : Registri da FACEXP a FACOV
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Logaritmo, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_LOG_FAC {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr LOG                     ; Calcola LOG di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_LOG_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il logaritmo naturale di ARG e lascia il risultato in
;               FAC, che perde il suo vecchio contenuto.
;
;               Copia prima ARG in FAC con m_Transfer_ARG_to_FAC.
;
;               Chiama la routine LOG della ROM del BASIC. Se il numero è zero o
;               negativo la ROM segnala ILLEGAL QUANTITY ERROR e non ritorna al
;               chiamante: vedi [NOTA #07 in <fp/fp.asm>]. LOG(1) vale zero.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, RESHO, $56, NUMWRK, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #11 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - ARG (6 byte, ZP)               : Registri da ARGEXP a ARGSGN
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Logaritmo, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_LOG_ARG {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Transfer_ARG_to_FAC      ; Copia ARG in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr LOG                     ; Calcola LOG di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_LOG_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il logaritmo naturale del numero in formato MBF che si
;               trova a un indirizzo assoluto e lascia il risultato in FAC, che
;               perde il suo vecchio contenuto.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Mem, che
;               altera INDEX.
;
;               Chiama la routine LOG della ROM del BASIC. Se il numero è zero o
;               negativo la ROM segnala ILLEGAL QUANTITY ERROR e non ritorna al
;               chiamante: vedi [NOTA #07 in <fp/fp.asm>]. LOG(1) vale zero.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, RESHO, $56, NUMWRK, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #11 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro)     : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)         : Numero in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Logaritmo, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_LOG_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Mem .addr_ ; Carica il numero in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr LOG                     ; Calcola LOG di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_LOG_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il logaritmo naturale del numero in formato MBF che si
;               trova all'indirizzo a cui punta un puntatore e lascia il
;               risultato in FAC, che perde il suo vecchio contenuto.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Ptr, che
;               altera INDEX.
;
;               Chiama la routine LOG della ROM del BASIC. Se il numero è zero o
;               negativo la ROM segnala ILLEGAL QUANTITY ERROR e non ritorna al
;               chiamante: vedi [NOTA #07 in <fp/fp.asm>]. LOG(1) vale zero.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, RESHO, $56, NUMWRK, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #11 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro)      : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)          : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)        : Numero in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Logaritmo, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_LOG_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Ptr .ptr_  ; Carica il numero in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr LOG                     ; Calcola LOG di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_EXP_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Calcola e elevato al numero in virgola mobile di FAC e lascia il
;               risultato in FAC.
;
;               Chiama la routine EXP della ROM del BASIC. Se il risultato è
;               troppo grande, cioè per un numero da circa 88.03 in su, la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>]; se è troppo piccolo il risultato è
;               zero. EXP(0) vale 1.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, RESHO, $56, NUMWRK, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #12 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - FAC (7 byte, ZP)               : Registri da FACEXP a FACOV
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Risultato, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_EXP_FAC {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr EXP                     ; Calcola EXP di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_EXP_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Calcola e elevato a ARG e lascia il risultato in FAC, che perde
;               il suo vecchio contenuto.
;
;               Copia prima ARG in FAC con m_Transfer_ARG_to_FAC.
;
;               Chiama la routine EXP della ROM del BASIC. Se il risultato è
;               troppo grande, cioè per un numero da circa 88.03 in su, la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>]; se è troppo piccolo il risultato è
;               zero. EXP(0) vale 1.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, RESHO, $56, NUMWRK, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #12 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - ARG (6 byte, ZP)               : Registri da ARGEXP a ARGSGN
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Risultato, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_EXP_ARG {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Transfer_ARG_to_FAC      ; Copia ARG in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr EXP                     ; Calcola EXP di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_EXP_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Calcola e elevato al numero in formato MBF che si trova a un
;               indirizzo assoluto e lascia il risultato in FAC, che perde il
;               suo vecchio contenuto.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Mem, che
;               altera INDEX.
;
;               Chiama la routine EXP della ROM del BASIC. Se il risultato è
;               troppo grande, cioè per un numero da circa 88.03 in su, la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>]; se è troppo piccolo il risultato è
;               zero. EXP(0) vale 1.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, RESHO, $56, NUMWRK, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #12 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro)     : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)         : Numero in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Risultato, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_EXP_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Mem .addr_ ; Carica il numero in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr EXP                     ; Calcola EXP di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_EXP_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Calcola e elevato al numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e lascia il risultato in
;               FAC, che perde il suo vecchio contenuto.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Ptr, che
;               altera INDEX.
;
;               Chiama la routine EXP della ROM del BASIC. Se il risultato è
;               troppo grande, cioè per un numero da circa 88.03 in su, la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>]; se è troppo piccolo il risultato è
;               zero. EXP(0) vale 1.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, RESHO, $56, NUMWRK, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #12 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro)      : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)          : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)        : Numero in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Risultato, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_EXP_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Ptr .ptr_  ; Carica il numero in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr EXP                     ; Calcola EXP di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

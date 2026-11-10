; ==============================================================================
; FILE:           fp_power.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per l'elevamento a potenza e la radice quadrata di
;                 numeri in virgola mobile (formato MBF). La base può essere in
;                 ARG, a un indirizzo assoluto o puntata da un puntatore; il
;                 risultato è sempre in FAC. L'interruttore __PRESERVE_ARG di
;                 config.asm decide se ARG viene preservato.
; CONTENUTO:      m_Power_ARG_to_FAC  ARG elevato a FAC
;                 m_Power_Mem_to_FAC  Indirizzo elevato a FAC
;                 m_Power_Ptr_to_FAC  Puntatore elevato a FAC
;                 m_SQR_FAC           Radice quadrata di FAC
;                 m_SQR_ARG           Radice quadrata di ARG
;                 m_SQR_Mem           Radice da indirizzo
;                 m_SQR_Ptr           Radice da puntatore
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   __FP_SAVED_SP
; ==============================================================================

; ==============================================================================
; MACRO: m_Power_ARG_to_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Eleva il numero in virgola mobile di ARG alla potenza di FAC e
;               lascia il risultato in FAC: FAC = ARG ^ FAC.
;
;               Chiama la routine FPWRT della ROM del BASIC, che calcola
;               EXP(LOG(ARG) x FAC). I casi particolari sono: se FAC è zero il
;               risultato è 1, anche con base zero; se la base è zero, e FAC non
;               lo è, il risultato è zero, anche con esponente negativo; con
;               base negativa l'esponente deve essere intero, altrimenti la ROM
;               segnala ILLEGAL QUANTITY ERROR; se il risultato è troppo grande
;               la ROM segnala OVERFLOW ERROR, se è troppo piccolo il risultato
;               è zero. Se la ROM segnala un errore non ritorna al chiamante:
;               vedi [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, INDEX2, RESHO, $4E-$52,
;               $56, NUMWRK, $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #11 in <fp/fp.asm>],
;               [NOTA #12 in <fp/fp.asm>] e [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - FAC (7 byte, ZP)               : Registri da FACEXP a FACOV
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
;                       ARISGN, INDEX, INDEX2,
;                       STACK (5 byte, se __PRESERVE_ARG = 1), __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Power_ARG_to_FAC {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    lda FACEXP                  ; Esponente di FAC: se zero, FAC è zero.
    jsr FPWRT                   ; Calcola ARG elevato a FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_Power_Mem_to_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Eleva il numero in formato MBF che si trova a un indirizzo
;               assoluto alla potenza di FAC e lascia il risultato in FAC: FAC =
;               (.addr_) ^ FAC.
;
;               Carica prima il numero in ARG con m_Load_ARG_from_Mem, che
;               aggiorna ARISGN e altera INDEX.
;
;               Chiama la routine FPWRT della ROM del BASIC, che calcola
;               EXP(LOG(ARG) x FAC). I casi particolari sono: se FAC è zero il
;               risultato è 1, anche con base zero; se la base è zero, e FAC non
;               lo è, il risultato è zero, anche con esponente negativo; con
;               base negativa l'esponente deve essere intero, altrimenti la ROM
;               segnala ILLEGAL QUANTITY ERROR; se il risultato è troppo grande
;               la ROM segnala OVERFLOW ERROR, se è troppo piccolo il risultato
;               è zero. Se la ROM segnala un errore non ritorna al chiamante:
;               vedi [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, INDEX2, RESHO, $4E-$52,
;               $56, NUMWRK, $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #11 in <fp/fp.asm>],
;               [NOTA #12 in <fp/fp.asm>] e [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - FAC (7 byte, ZP)               : Registri da FACEXP a FACOV
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
;                       ARISGN, INDEX, INDEX2,
;                       STACK (5 byte, se __PRESERVE_ARG = 1), __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Power_Mem_to_FAC .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    +m_Load_ARG_from_Mem .addr_ ; Carica la base in ARG.
    jsr FPWRT                   ; Calcola ARG elevato a FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_Power_Ptr_to_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Eleva il numero in formato MBF che si trova all'indirizzo a cui
;               punta un puntatore alla potenza di FAC e lascia il risultato in
;               FAC: FAC = ((.ptr_)) ^ FAC.
;
;               Carica prima il numero in ARG con m_Load_ARG_from_Ptr, che
;               aggiorna ARISGN e altera INDEX.
;
;               Chiama la routine FPWRT della ROM del BASIC, che calcola
;               EXP(LOG(ARG) x FAC). I casi particolari sono: se FAC è zero il
;               risultato è 1, anche con base zero; se la base è zero, e FAC non
;               lo è, il risultato è zero, anche con esponente negativo; con
;               base negativa l'esponente deve essere intero, altrimenti la ROM
;               segnala ILLEGAL QUANTITY ERROR; se il risultato è troppo grande
;               la ROM segnala OVERFLOW ERROR, se è troppo piccolo il risultato
;               è zero. Se la ROM segnala un errore non ritorna al chiamante:
;               vedi [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, INDEX2, RESHO, $4E-$52,
;               $56, NUMWRK, $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #11 in <fp/fp.asm>],
;               [NOTA #12 in <fp/fp.asm>] e [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - FAC (7 byte, ZP)               : Registri da FACEXP a FACOV
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
;                       ARISGN, INDEX, INDEX2,
;                       STACK (5 byte, se __PRESERVE_ARG = 1), __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Power_Ptr_to_FAC .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    +m_Load_ARG_from_Ptr .ptr_  ; Carica la base in ARG.
    jsr FPWRT                   ; Calcola ARG elevato a FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_SQR_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Calcola la radice quadrata del numero in virgola mobile di FAC e
;               lascia il risultato in FAC.
;
;               Chiama la routine SQR della ROM del BASIC, che copia FAC in ARG,
;               carica 0.5 in FAC e chiama FPWRT: calcola quindi ARG ^ 0.5. La
;               radice di zero è zero; se il numero è negativo la ROM segnala
;               ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, INDEX2, RESHO, $4E-$52,
;               $56, NUMWRK, $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #09 in <fp/fp.asm>] e
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
;   - FAC (7 byte, ZP)               : Radice quadrata, registri da FACEXP a
;                                      FACOV
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
;                       ARISGN, INDEX, INDEX2,
;                       STACK (5 byte, se __PRESERVE_ARG = 1), __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_SQR_FAC {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr SQR                     ; Calcola la radice quadrata di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_SQR_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Calcola la radice quadrata del numero in virgola mobile di ARG e
;               lascia il risultato in FAC, che perde il suo vecchio contenuto.
;
;               Copia prima ARG in FAC con m_Transfer_ARG_to_FAC.
;
;               Chiama la routine SQR della ROM del BASIC, che copia FAC in ARG,
;               carica 0.5 in FAC e chiama FPWRT: calcola quindi ARG ^ 0.5. La
;               radice di zero è zero; se il numero è negativo la ROM segnala
;               ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, INDEX2, RESHO, $4E-$52,
;               $56, NUMWRK, $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #09 in <fp/fp.asm>] e
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
;   - FAC (7 byte, ZP)               : Radice quadrata, registri da FACEXP a
;                                      FACOV
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
;                       ARISGN, INDEX, INDEX2,
;                       STACK (5 byte, se __PRESERVE_ARG = 1), __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_SQR_ARG {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Transfer_ARG_to_FAC      ; Copia ARG in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr SQR                     ; Calcola la radice quadrata di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_SQR_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Calcola la radice quadrata del numero in formato MBF che si
;               trova a un indirizzo assoluto e lascia il risultato in FAC, che
;               perde il suo vecchio contenuto.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Mem, che
;               altera INDEX.
;
;               Chiama la routine SQR della ROM del BASIC, che copia FAC in ARG,
;               carica 0.5 in FAC e chiama FPWRT: calcola quindi ARG ^ 0.5. La
;               radice di zero è zero; se il numero è negativo la ROM segnala
;               ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, INDEX2, RESHO, $4E-$52,
;               $56, NUMWRK, $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #09 in <fp/fp.asm>] e
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
;   - FAC (7 byte, ZP)               : Radice quadrata, registri da FACEXP a
;                                      FACOV
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
;                       ARISGN, INDEX, INDEX2,
;                       STACK (5 byte, se __PRESERVE_ARG = 1), __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_SQR_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Mem .addr_ ; Carica il numero in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr SQR                     ; Calcola la radice quadrata di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_SQR_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Calcola la radice quadrata del numero in formato MBF che si
;               trova all'indirizzo a cui punta un puntatore e lascia il
;               risultato in FAC, che perde il suo vecchio contenuto.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Ptr, che
;               altera INDEX.
;
;               Chiama la routine SQR della ROM del BASIC, che copia FAC in ARG,
;               carica 0.5 in FAC e chiama FPWRT: calcola quindi ARG ^ 0.5. La
;               radice di zero è zero; se il numero è negativo la ROM segnala
;               ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, INDEX, INDEX2, RESHO, $4E-$52,
;               $56, NUMWRK, $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #09 in <fp/fp.asm>] e
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
;   - FAC (7 byte, ZP)               : Radice quadrata, registri da FACEXP a
;                                      FACOV
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
;                       ARISGN, INDEX, INDEX2,
;                       STACK (5 byte, se __PRESERVE_ARG = 1), __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_SQR_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Ptr .ptr_  ; Carica il numero in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr SQR                     ; Calcola la radice quadrata di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

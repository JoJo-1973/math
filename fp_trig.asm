; ==============================================================================
; FILE:           fp_trig.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per le funzioni trigonometriche sui numeri in virgola
;                 mobile (formato MBF): seno, coseno, tangente e arcotangente.
;                 L'argomento può essere in FAC, in ARG, a un indirizzo assoluto
;                 o puntato da un puntatore; il risultato è sempre in FAC.
;                 L'interruttore __PRESERVE_ARG di config.asm decide se ARG
;                 viene preservato.
; CONTENUTO:      m_SIN_FAC   Seno di FAC
;                 m_SIN_ARG   Seno di ARG
;                 m_SIN_Mem   Seno da indirizzo
;                 m_SIN_Ptr   Seno da puntatore
;                 m_COS_FAC   Coseno di FAC
;                 m_COS_ARG   Coseno di ARG
;                 m_COS_Mem   Coseno da indirizzo
;                 m_COS_Ptr   Coseno da puntatore
;                 m_TAN_FAC   Tangente di FAC
;                 m_TAN_ARG   Tangente di ARG
;                 m_TAN_Mem   Tangente da indirizzo
;                 m_TAN_Ptr   Tangente da puntatore
;                 m_ATN_FAC   Arcotangente di FAC
;                 m_ATN_ARG   Arcotangente di ARG
;                 m_ATN_Mem   Arcotangente da indirizzo
;                 m_ATN_Ptr   Arcotangente da puntatore
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   __FP_SAVED_SP
; ==============================================================================

; ==============================================================================
; MACRO: m_SIN_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il seno del numero in virgola mobile di FAC e lascia il
;               risultato in FAC. L'angolo è in radianti.
;
;               Chiama la routine SIN della ROM del BASIC.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, $12, INDEX, RESHO, $56, NUMWRK,
;               $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #13 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - FAC (7 byte, ZP)               : Registri da FACEXP a FACOV
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Seno, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_SIN_FAC {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    jsr SIN                     ; Calcola il seno di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_SIN_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il seno del numero in virgola mobile di ARG e lascia il
;               risultato in FAC, che perde il suo vecchio contenuto. L'angolo è
;               in radianti.
;
;               Copia prima ARG in FAC con m_Transfer_ARG_to_FAC.
;
;               Chiama la routine SIN della ROM del BASIC.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, $12, INDEX, RESHO, $56, NUMWRK,
;               $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #13 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - ARG (6 byte, ZP)               : Registri da ARGEXP a ARGSGN
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Seno, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_SIN_ARG {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Transfer_ARG_to_FAC      ; Copia ARG in FAC.
    jsr SIN                     ; Calcola il seno di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_SIN_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il seno del numero in formato MBF che si trova a un
;               indirizzo assoluto e lascia il risultato in FAC, che perde il
;               suo vecchio contenuto. L'angolo è in radianti.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Mem, che
;               altera INDEX.
;
;               Chiama la routine SIN della ROM del BASIC.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, $12, INDEX, RESHO, $56, NUMWRK,
;               $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #13 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - .addr_ (1 o 2 byte, Macro)     : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)         : Numero in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Seno, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_SIN_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Mem .addr_ ; Carica il numero in FAC.
    jsr SIN                     ; Calcola il seno di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_SIN_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il seno del numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e lascia il risultato in
;               FAC, che perde il suo vecchio contenuto. L'angolo è in radianti.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Ptr, che
;               altera INDEX.
;
;               Chiama la routine SIN della ROM del BASIC.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, $12, INDEX, RESHO, $56, NUMWRK,
;               $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #13 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro)      : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)          : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)        : Numero in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Seno, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_SIN_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Ptr .ptr_  ; Carica il numero in FAC.
    jsr SIN                     ; Calcola il seno di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_COS_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il coseno del numero in virgola mobile di FAC e lascia
;               il risultato in FAC. L'angolo è in radianti.
;
;               Chiama la routine COS della ROM del BASIC.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, $12, INDEX, RESHO, $56, NUMWRK,
;               $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #14 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - FAC (7 byte, ZP)               : Registri da FACEXP a FACOV
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Coseno, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_COS_FAC {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    jsr COS                     ; Calcola il coseno di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_COS_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il coseno del numero in virgola mobile di ARG e lascia
;               il risultato in FAC, che perde il suo vecchio contenuto.
;               L'angolo è in radianti.
;
;               Copia prima ARG in FAC con m_Transfer_ARG_to_FAC.
;
;               Chiama la routine COS della ROM del BASIC.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, $12, INDEX, RESHO, $56, NUMWRK,
;               $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #14 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - ARG (6 byte, ZP)               : Registri da ARGEXP a ARGSGN
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Coseno, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_COS_ARG {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Transfer_ARG_to_FAC      ; Copia ARG in FAC.
    jsr COS                     ; Calcola il coseno di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_COS_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il coseno del numero in formato MBF che si trova a un
;               indirizzo assoluto e lascia il risultato in FAC, che perde il
;               suo vecchio contenuto. L'angolo è in radianti.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Mem, che
;               altera INDEX.
;
;               Chiama la routine COS della ROM del BASIC.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, $12, INDEX, RESHO, $56, NUMWRK,
;               $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #14 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - .addr_ (1 o 2 byte, Macro)     : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)         : Numero in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Coseno, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_COS_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Mem .addr_ ; Carica il numero in FAC.
    jsr COS                     ; Calcola il coseno di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_COS_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il coseno del numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e lascia il risultato in
;               FAC, che perde il suo vecchio contenuto. L'angolo è in radianti.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Ptr, che
;               altera INDEX.
;
;               Chiama la routine COS della ROM del BASIC.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, $12, INDEX, RESHO, $56, NUMWRK,
;               $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #14 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro)      : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)          : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)        : Numero in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Coseno, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_COS_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Ptr .ptr_  ; Carica il numero in FAC.
    jsr COS                     ; Calcola il coseno di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_TAN_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il tangente del numero in virgola mobile di FAC e lascia
;               il risultato in FAC. L'angolo è in radianti.
;
;               Chiama la routine TAN della ROM del BASIC. Se il coseno è zero
;               la ROM segnala DIVISION BY ZERO ERROR e non ritorna al
;               chiamante: vedi [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, $12, INDEX, RESHO, $4E-$52,
;               $56, NUMWRK, $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #15 in <fp/fp.asm>] e
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
;   - FAC (7 byte, ZP)               : Tangente, registri da FACEXP a FACOV
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
!macro m_TAN_FAC {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr TAN                     ; Calcola il tangente di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_TAN_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il tangente del numero in virgola mobile di ARG e lascia
;               il risultato in FAC, che perde il suo vecchio contenuto.
;               L'angolo è in radianti.
;
;               Copia prima ARG in FAC con m_Transfer_ARG_to_FAC.
;
;               Chiama la routine TAN della ROM del BASIC. Se il coseno è zero
;               la ROM segnala DIVISION BY ZERO ERROR e non ritorna al
;               chiamante: vedi [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, $12, INDEX, RESHO, $4E-$52,
;               $56, NUMWRK, $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #15 in <fp/fp.asm>] e
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
;   - FAC (7 byte, ZP)               : Tangente, registri da FACEXP a FACOV
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
!macro m_TAN_ARG {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Transfer_ARG_to_FAC      ; Copia ARG in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr TAN                     ; Calcola il tangente di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_TAN_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il tangente del numero in formato MBF che si trova a un
;               indirizzo assoluto e lascia il risultato in FAC, che perde il
;               suo vecchio contenuto. L'angolo è in radianti.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Mem, che
;               altera INDEX.
;
;               Chiama la routine TAN della ROM del BASIC. Se il coseno è zero
;               la ROM segnala DIVISION BY ZERO ERROR e non ritorna al
;               chiamante: vedi [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, $12, INDEX, RESHO, $4E-$52,
;               $56, NUMWRK, $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #15 in <fp/fp.asm>] e
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
;   - FAC (7 byte, ZP)               : Tangente, registri da FACEXP a FACOV
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
!macro m_TAN_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Mem .addr_ ; Carica il numero in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr TAN                     ; Calcola il tangente di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_TAN_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il tangente del numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e lascia il risultato in
;               FAC, che perde il suo vecchio contenuto. L'angolo è in radianti.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Ptr, che
;               altera INDEX.
;
;               Chiama la routine TAN della ROM del BASIC. Se il coseno è zero
;               la ROM segnala DIVISION BY ZERO ERROR e non ritorna al
;               chiamante: vedi [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07, $12, INDEX, RESHO, $4E-$52,
;               $56, NUMWRK, $67 e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #15 in <fp/fp.asm>] e
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
;   - FAC (7 byte, ZP)               : Tangente, registri da FACEXP a FACOV
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
!macro m_TAN_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Ptr .ptr_  ; Carica il numero in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr TAN                     ; Calcola il tangente di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_ATN_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il arcotangente del numero in virgola mobile di FAC e
;               lascia il risultato in FAC. Il risultato è un angolo in
;               radianti, tra -PI/2 e PI/2.
;
;               Chiama la routine ATN della ROM del BASIC.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, RESHO, $56, NUMWRK, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #16 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - FAC (7 byte, ZP)               : Registri da FACEXP a FACOV
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Arcotangente, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_ATN_FAC {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    jsr ATN                     ; Calcola il arcotangente di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_ATN_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il arcotangente del numero in virgola mobile di ARG e
;               lascia il risultato in FAC, che perde il suo vecchio contenuto.
;               Il risultato è un angolo in radianti, tra -PI/2 e PI/2.
;
;               Copia prima ARG in FAC con m_Transfer_ARG_to_FAC.
;
;               Chiama la routine ATN della ROM del BASIC.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, RESHO, $56, NUMWRK, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #16 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - ARG (6 byte, ZP)               : Registri da ARGEXP a ARGSGN
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Arcotangente, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_ATN_ARG {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Transfer_ARG_to_FAC      ; Copia ARG in FAC.
    jsr ATN                     ; Calcola il arcotangente di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_ATN_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il arcotangente del numero in formato MBF che si trova a
;               un indirizzo assoluto e lascia il risultato in FAC, che perde il
;               suo vecchio contenuto. Il risultato è un angolo in radianti, tra
;               -PI/2 e PI/2.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Mem, che
;               altera INDEX.
;
;               Chiama la routine ATN della ROM del BASIC.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, RESHO, $56, NUMWRK, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #16 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - .addr_ (1 o 2 byte, Macro)     : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)         : Numero in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Arcotangente, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_ATN_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Mem .addr_ ; Carica il numero in FAC.
    jsr ATN                     ; Calcola il arcotangente di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_ATN_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il arcotangente del numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e lascia il risultato in
;               FAC, che perde il suo vecchio contenuto. Il risultato è un
;               angolo in radianti, tra -PI/2 e PI/2.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Ptr, che
;               altera INDEX.
;
;               Chiama la routine ATN della ROM del BASIC.
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, RESHO, $56, NUMWRK, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #16 in <fp/fp.asm>] e
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro)      : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)          : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)        : Numero in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Arcotangente, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, STACK (5 byte, se __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_ATN_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    +m_Load_FAC_from_Ptr .ptr_  ; Carica il numero in FAC.
    jsr ATN                     ; Calcola il arcotangente di FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

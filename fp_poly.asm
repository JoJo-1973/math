; ==============================================================================
; FILE:           fp_poly.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per calcolare polinomi e polinomi dispari a coefficienti
;                 in virgola mobile (formato MBF). Il punto in cui calcolarli è
;                 in FAC, la tabella dei coefficienti è a un indirizzo assoluto
;                 o puntata da un puntatore; il risultato è in FAC.
;                 L'interruttore __PRESERVE_ARG di config.asm decide se ARG
;                 viene preservato.
; CONTENUTO:      m_Poly_Mem      Polinomio, tabella a indirizzo
;                 m_Poly_Ptr      Polinomio, tabella da puntatore
;                 m_Odd_Poly_Mem  Polinomio dispari, tabella a indirizzo
;                 m_Odd_Poly_Ptr  Polinomio dispari, tabella da puntatore
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   __FP_SAVED_SP
; ==============================================================================

; ==============================================================================
; MACRO: m_Poly_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Calcola in FAC il valore di un polinomio di grado n nel punto x
;               che è in FAC: FAC = a_n*x^n + a_(n-1)*x^(n-1) + ... + a_1*x +
;               a_0. I coefficienti sono in una tabella a un indirizzo assoluto.
;
;               Il primo byte della tabella è n; seguono n+1 numeri in formato
;               MBF, i coefficienti da a_n ad a_0. Il valore di n deve essere
;               almeno 1: con n = 0 la ROM esegue 256 iterazioni sui byte che
;               seguono la tabella e di solito segnala OVERFLOW ERROR.
;
;               Chiama la routine POLY2 della ROM del BASIC, che usa il metodo
;               di Horner. Se un risultato intermedio è troppo grande la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, RESHO, $56, $5C-$60, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - FAC (7 byte, ZP)               : Punto x, registri da FACEXP a FACOV
;   - .addr_ (1 o 2 byte, Macro)     : Indirizzo della tabella
;   - (.addr_) (1 byte, RAM)         : Valore di n, almeno 1
;   - (.addr_+1) (5*n+5 byte, RAM)   : Coefficienti in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Valore del polinomio, registri da FACEXP
;                                      a FACOV
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
!macro m_Poly_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    lda #<.addr_                ; Punta .A/.Y alla tabella.
    ldy #>.addr_
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr POLY2                   ; Calcola il polinomio.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_Poly_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Calcola in FAC il valore di un polinomio di grado n nel punto x
;               che è in FAC: FAC = a_n*x^n + a_(n-1)*x^(n-1) + ... + a_1*x +
;               a_0. I coefficienti sono in una tabella all'indirizzo a cui
;               punta un puntatore.
;
;               Il primo byte della tabella è n; seguono n+1 numeri in formato
;               MBF, i coefficienti da a_n ad a_0. Il valore di n deve essere
;               almeno 1: con n = 0 la ROM esegue 256 iterazioni sui byte che
;               seguono la tabella e di solito segnala OVERFLOW ERROR.
;
;               Chiama la routine POLY2 della ROM del BASIC, che usa il metodo
;               di Horner. Se un risultato intermedio è troppo grande la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera molte celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, RESHO, $56, $5C-$60, $67
;               e $71-$72.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in formato MBF in STACK
;               ($0100-$0104) prima della chiamata e lo ripristina dopo, perché
;               la ROM usa NUMWRK, dove si trova _SCRATCH_2; se vale 0 il
;               contenuto di ARG non è garantito dopo la chiamata. Un ARG uguale
;               a zero (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero. Il
;               contenuto di STACK non è garantito dopo la chiamata.
;
;               Per l'accuratezza del risultato vedi [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - FAC (7 byte, ZP)               : Punto x, registri da FACEXP a FACOV
;   - .ptr_ (1 o 2 byte, Macro)      : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)          : Indirizzo della tabella (LSB, MSB)
;   - ((.ptr_)) (1 byte, RAM)        : Valore di n, almeno 1
;   - ((.ptr_)+1) (5*n+5 byte, RAM)  : Coefficienti in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Valore del polinomio, registri da FACEXP
;                                      a FACOV
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
!macro m_Poly_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    lda .ptr_                   ; Punta .A/.Y alla tabella.
    ldy .ptr_+1
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr POLY2                   ; Calcola il polinomio.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_Odd_Poly_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Calcola in FAC il valore di un polinomio dispari di grado n, con
;               n dispari, nel punto x che è in FAC: FAC = a_n*x^n +
;               a_(n-2)*x^(n-2) + ... + a_3*x^3 + a_1*x. I coefficienti sono in
;               una tabella a un indirizzo assoluto.
;
;               Il primo byte della tabella è d = (n-1)/2; seguono d+1 numeri in
;               formato MBF, i coefficienti da a_n ad a_1. Il valore di d deve
;               essere almeno 1: con d = 0 la ROM esegue 256 iterazioni sui byte
;               che seguono la tabella e di solito segnala OVERFLOW ERROR.
;
;               Chiama la routine POLY1 della ROM del BASIC, che usa il metodo
;               di Horner. Se un risultato intermedio è troppo grande la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
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
;               Per l'accuratezza del risultato vedi [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - FAC (7 byte, ZP)               : Punto x, registri da FACEXP a FACOV
;   - .addr_ (1 o 2 byte, Macro)     : Indirizzo della tabella
;   - (.addr_) (1 byte, RAM)         : Valore di d, almeno 1
;   - (.addr_+1) (5*d+5 byte, RAM)   : Coefficienti in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Valore del polinomio, registri da FACEXP
;                                      a FACOV
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
!macro m_Odd_Poly_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    lda #<.addr_                ; Punta .A/.Y alla tabella.
    ldy #>.addr_
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr POLY1                   ; Calcola il polinomio.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

; ==============================================================================
; MACRO: m_Odd_Poly_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Calcola in FAC il valore di un polinomio dispari di grado n, con
;               n dispari, nel punto x che è in FAC: FAC = a_n*x^n +
;               a_(n-2)*x^(n-2) + ... + a_3*x^3 + a_1*x. I coefficienti sono in
;               una tabella all'indirizzo a cui punta un puntatore.
;
;               Il primo byte della tabella è d = (n-1)/2; seguono d+1 numeri in
;               formato MBF, i coefficienti da a_n ad a_1. Il valore di d deve
;               essere almeno 1: con d = 0 la ROM esegue 256 iterazioni sui byte
;               che seguono la tabella e di solito segnala OVERFLOW ERROR.
;
;               Chiama la routine POLY1 della ROM del BASIC, che usa il metodo
;               di Horner. Se un risultato intermedio è troppo grande la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
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
;               Per l'accuratezza del risultato vedi [NOTA #08 in <fp/fp.asm>].
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - FAC (7 byte, ZP)               : Punto x, registri da FACEXP a FACOV
;   - .ptr_ (1 o 2 byte, Macro)      : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)          : Indirizzo della tabella (LSB, MSB)
;   - ((.ptr_)) (1 byte, RAM)        : Valore di d, almeno 1
;   - ((.ptr_)+1) (5*d+5 byte, RAM)  : Coefficienti in formato MBF
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Valore del polinomio, registri da FACEXP
;                                      a FACOV
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
!macro m_Odd_Poly_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_to_Mem STACK
    }

    lda .ptr_                   ; Punta .A/.Y alla tabella.
    ldy .ptr_+1
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr POLY1                   ; Calcola il polinomio.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Mem STACK
    }
}

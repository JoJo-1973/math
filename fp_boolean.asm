; ==============================================================================
; FILE:           fp_boolean.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per gli operatori booleani bit a bit AND, OR e NOT sui
;                 numeri in virgola mobile (formato MBF), convertiti in interi a
;                 16 bit con segno. Il secondo operando di AND e OR può essere
;                 in ARG, a un indirizzo assoluto o puntato da un puntatore; il
;                 risultato è in FAC. L'interruttore __PRESERVE_ARG di
;                 config.asm decide se ARG viene preservato.
; CONTENUTO:      m_AND_FAC_with_ARG  AND tra FAC e ARG
;                 m_AND_FAC_with_Mem  AND tra FAC e indirizzo
;                 m_AND_FAC_with_Ptr  AND tra FAC e puntatore
;                 m_OR_FAC_with_ARG   OR tra FAC e ARG
;                 m_OR_FAC_with_Mem   OR tra FAC e indirizzo
;                 m_OR_FAC_with_Ptr   OR tra FAC e puntatore
;                 m_NOT_FAC           NOT di FAC
;                 m_NOT_ARG           NOT di ARG, sul posto
;                 m_NOT_Mem           NOT da indirizzo
;                 m_NOT_Ptr           NOT da puntatore
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   __FP_SAVED_SP
; ==============================================================================

; ==============================================================================
; MACRO: m_AND_FAC_with_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un AND bit a bit tra FAC e il numero in formato MBF che è
;               in ARG e lascia il risultato in FAC: FAC = FAC AND ARG.
;
;               Entrambi i numeri sono convertiti in interi a 16 bit con segno,
;               arrotondati per difetto (-1.5 diventa -2); il risultato è
;               riconvertito in virgola mobile.
;
;               Chiama la routine ANDOP della ROM del BASIC. Se FAC o l'altro
;               numero è fuori dall'intervallo da -32768 a 32767, la ROM segnala
;               ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07-$08, $0B e $0D (VALTYP, posto
;               a zero).
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - FAC (7 byte, ZP)           : Registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)           : Registri da ARGEXP a ARGSGN
;
; Output:
;   - FAC (7 byte, ZP)           : Risultato, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)           : Invariato
;   - __FP_SAVED_SP (1 byte, ZP) : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)          : Ritorno al chiamante o, se la ROM segnala un
;                                  errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_AND_FAC_with_ARG {
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr ANDOP                   ; Calcola FAC AND ARG.
}

; ==============================================================================
; MACRO: m_AND_FAC_with_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un AND bit a bit tra FAC e il numero in formato MBF che
;               si trova a un indirizzo assoluto e lascia il risultato in FAC:
;               FAC = FAC AND (.addr_).
;
;               Entrambi i numeri sono convertiti in interi a 16 bit con segno,
;               arrotondati per difetto (-1.5 diventa -2); il risultato è
;               riconvertito in virgola mobile.
;
;               Carica prima il numero in ARG con m_Load_ARG_from_Mem, che
;               aggiorna ARISGN e altera INDEX.
;
;               Chiama la routine ANDOP della ROM del BASIC. Se FAC o l'altro
;               numero è fuori dall'intervallo da -32768 a 32767, la ROM segnala
;               ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07-$08, $0B e $0D (VALTYP, posto
;               a zero).
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima di
;               caricare il numero e lo ripristina dopo; se vale 0 ARG contiene
;               il numero caricato. Un ARG uguale a zero (ARGEXP = 0) torna con
;               ARGHO = $80, ed è ancora zero.
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
;                                      altrimenti contiene il numero
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, _SCRATCH_2 (se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_common.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_AND_FAC_with_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    +m_Load_ARG_from_Mem .addr_ ; Carica il numero in ARG.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr ANDOP                   ; Calcola FAC AND ARG.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_AND_FAC_with_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un AND bit a bit tra FAC e il numero in formato MBF che
;               si trova all'indirizzo a cui punta un puntatore e lascia il
;               risultato in FAC: FAC = FAC AND ((.ptr_)).
;
;               Entrambi i numeri sono convertiti in interi a 16 bit con segno,
;               arrotondati per difetto (-1.5 diventa -2); il risultato è
;               riconvertito in virgola mobile.
;
;               Carica prima il numero in ARG con m_Load_ARG_from_Ptr, che
;               aggiorna ARISGN e altera INDEX.
;
;               Chiama la routine ANDOP della ROM del BASIC. Se FAC o l'altro
;               numero è fuori dall'intervallo da -32768 a 32767, la ROM segnala
;               ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07-$08, $0B e $0D (VALTYP, posto
;               a zero).
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima di
;               caricare il numero e lo ripristina dopo; se vale 0 ARG contiene
;               il numero caricato. Un ARG uguale a zero (ARGEXP = 0) torna con
;               ARGHO = $80, ed è ancora zero.
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
;                                      altrimenti contiene il numero
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, _SCRATCH_2 (se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_common.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_AND_FAC_with_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    +m_Load_ARG_from_Ptr .ptr_  ; Carica il numero in ARG.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr ANDOP                   ; Calcola FAC AND ARG.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_OR_FAC_with_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un OR bit a bit tra FAC e il numero in formato MBF che è
;               in ARG e lascia il risultato in FAC: FAC = FAC OR ARG.
;
;               Entrambi i numeri sono convertiti in interi a 16 bit con segno,
;               arrotondati per difetto (-1.5 diventa -2); il risultato è
;               riconvertito in virgola mobile.
;
;               Chiama la routine OROP della ROM del BASIC. Se FAC o l'altro
;               numero è fuori dall'intervallo da -32768 a 32767, la ROM segnala
;               ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07-$08, $0B e $0D (VALTYP, posto
;               a zero).
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - FAC (7 byte, ZP)           : Registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)           : Registri da ARGEXP a ARGSGN
;
; Output:
;   - FAC (7 byte, ZP)           : Risultato, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)           : Invariato
;   - __FP_SAVED_SP (1 byte, ZP) : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)          : Ritorno al chiamante o, se la ROM segnala un
;                                  errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_OR_FAC_with_ARG {
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr OROP                    ; Calcola FAC OR ARG.
}

; ==============================================================================
; MACRO: m_OR_FAC_with_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un OR bit a bit tra FAC e il numero in formato MBF che si
;               trova a un indirizzo assoluto e lascia il risultato in FAC: FAC
;               = FAC OR (.addr_).
;
;               Entrambi i numeri sono convertiti in interi a 16 bit con segno,
;               arrotondati per difetto (-1.5 diventa -2); il risultato è
;               riconvertito in virgola mobile.
;
;               Carica prima il numero in ARG con m_Load_ARG_from_Mem, che
;               aggiorna ARISGN e altera INDEX.
;
;               Chiama la routine OROP della ROM del BASIC. Se FAC o l'altro
;               numero è fuori dall'intervallo da -32768 a 32767, la ROM segnala
;               ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07-$08, $0B e $0D (VALTYP, posto
;               a zero).
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima di
;               caricare il numero e lo ripristina dopo; se vale 0 ARG contiene
;               il numero caricato. Un ARG uguale a zero (ARGEXP = 0) torna con
;               ARGHO = $80, ed è ancora zero.
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
;                                      altrimenti contiene il numero
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, _SCRATCH_2 (se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_common.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_OR_FAC_with_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    +m_Load_ARG_from_Mem .addr_ ; Carica il numero in ARG.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr OROP                    ; Calcola FAC OR ARG.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_OR_FAC_with_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un OR bit a bit tra FAC e il numero in formato MBF che si
;               trova all'indirizzo a cui punta un puntatore e lascia il
;               risultato in FAC: FAC = FAC OR ((.ptr_)).
;
;               Entrambi i numeri sono convertiti in interi a 16 bit con segno,
;               arrotondati per difetto (-1.5 diventa -2); il risultato è
;               riconvertito in virgola mobile.
;
;               Carica prima il numero in ARG con m_Load_ARG_from_Ptr, che
;               aggiorna ARISGN e altera INDEX.
;
;               Chiama la routine OROP della ROM del BASIC. Se FAC o l'altro
;               numero è fuori dall'intervallo da -32768 a 32767, la ROM segnala
;               ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: $07-$08, $0B e $0D (VALTYP, posto
;               a zero).
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima di
;               caricare il numero e lo ripristina dopo; se vale 0 ARG contiene
;               il numero caricato. Un ARG uguale a zero (ARGEXP = 0) torna con
;               ARGHO = $80, ed è ancora zero.
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
;                                      altrimenti contiene il numero
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, _SCRATCH_2 (se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_common.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_OR_FAC_with_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    +m_Load_ARG_from_Ptr .ptr_  ; Carica il numero in ARG.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr OROP                    ; Calcola FAC OR ARG.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_NOT_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un NOT bit a bit su FAC e lascia il risultato in FAC: FAC
;               = NOT FAC.
;
;               Il numero è convertito in un intero a 16 bit con segno,
;               arrotondato per difetto (-1.5 diventa -2); il risultato, che
;               vale -n-1, è riconvertito in virgola mobile.
;
;               Chiama la routine NOTOP della ROM del BASIC. Se il numero è
;               fuori dall'intervallo da -32768 a 32767, la ROM segnala ILLEGAL
;               QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera la cella di lavoro $0D (VALTYP), che viene posta
;               a zero.
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - FAC (7 byte, ZP)           : Registri da FACEXP a FACOV
;
; Output:
;   - FAC (7 byte, ZP)           : Risultato, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)           : Invariato
;   - __FP_SAVED_SP (1 byte, ZP) : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)          : Ritorno al chiamante o, se la ROM segnala un
;                                  errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_NOT_FAC {
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr NOTOP                   ; Calcola NOT FAC.
}

; ==============================================================================
; MACRO: m_NOT_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un NOT bit a bit su ARG e lascia il risultato in ARG,
;               senza alterare FAC: ARG = NOT ARG. È l'unica macro di questo
;               gruppo che lavora sul posto, e non lascia il risultato in FAC.
;
;               Scambia FAC e ARG con m_Swap_FAC_and_ARG, esegue il NOT su FAC e
;               li scambia di nuovo.
;
;               Il numero è convertito in un intero a 16 bit con segno,
;               arrotondato per difetto (-1.5 diventa -2); il risultato, che
;               vale -n-1, è riconvertito in virgola mobile.
;
;               Chiama la routine NOTOP della ROM del BASIC. Se il numero
;               è fuori dall'intervallo da -32768 a 32767, la ROM segnala
;               ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>]. In questo caso FAC e ARG
;               restano scambiati.
;
;               La ROM altera la cella di lavoro $0D (VALTYP), che viene posta
;               a zero.
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - ARG (6 byte, ZP)           : Registri da ARGEXP a ARGSGN
;
; Output:
;   - ARG (6 byte, ZP)           : Risultato, registri da ARGEXP a ARGSGN
;   - FAC (7 byte, ZP)           : Invariato
;   - __FP_SAVED_SP (1 byte, ZP) : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)          : Ritorno al chiamante o, se la ROM segnala un
;                                  errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       _SCRATCH_2, __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_common.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_NOT_ARG {
    +m_Swap_FAC_and_ARG         ; Porta ARG in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr NOTOP                   ; Calcola NOT FAC.
    +m_Swap_FAC_and_ARG         ; Rimette tutto a posto.
}

; ==============================================================================
; MACRO: m_NOT_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un NOT bit a bit sul numero in formato MBF che si trova a
;               un indirizzo assoluto e lascia il risultato in FAC, che perde il
;               suo vecchio contenuto.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Mem, che
;               altera INDEX.
;
;               Il numero è convertito in un intero a 16 bit con segno,
;               arrotondato per difetto (-1.5 diventa -2); il risultato, che
;               vale -n-1, è riconvertito in virgola mobile.
;
;               Chiama la routine NOTOP della ROM del BASIC. Se il numero è
;               fuori dall'intervallo da -32768 a 32767, la ROM segnala ILLEGAL
;               QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera la cella di lavoro $0D (VALTYP), che viene posta
;               a zero.
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)     : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)           : Risultato, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)           : Invariato
;   - __FP_SAVED_SP (1 byte, ZP) : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)          : Ritorno al chiamante o, se la ROM segnala un
;                                  errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), INDEX,
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_NOT_Mem .addr_ {
    +m_Load_FAC_from_Mem .addr_ ; Carica il numero in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr NOTOP                   ; Calcola NOT FAC.
}

; ==============================================================================
; MACRO: m_NOT_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un NOT bit a bit sul numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e lascia il risultato in
;               FAC, che perde il suo vecchio contenuto.
;
;               Carica prima il numero in FAC con m_Load_FAC_from_Ptr, che
;               altera INDEX.
;
;               Il numero è convertito in un intero a 16 bit con segno,
;               arrotondato per difetto (-1.5 diventa -2); il risultato, che
;               vale -n-1, è riconvertito in virgola mobile.
;
;               Chiama la routine NOTOP della ROM del BASIC. Se il numero è
;               fuori dall'intervallo da -32768 a 32767, la ROM segnala ILLEGAL
;               QUANTITY ERROR e non ritorna al chiamante: vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera la cella di lavoro $0D (VALTYP), che viene posta
;               a zero.
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - .ptr_ (1 o 2 byte, Macro)  : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)      : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)    : Numero in formato MBF
;
; Output:
;   - FAC (7 byte, ZP)           : Risultato, registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)           : Invariato
;   - __FP_SAVED_SP (1 byte, ZP) : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)          : Ritorno al chiamante o, se la ROM segnala un
;                                  errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), INDEX,
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_NOT_Ptr .ptr_ {
    +m_Load_FAC_from_Ptr .ptr_  ; Carica il numero in FAC.
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr NOTOP                   ; Calcola NOT FAC.
}

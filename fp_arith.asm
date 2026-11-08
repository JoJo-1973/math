; ==============================================================================
; FILE:           fp_arith.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per le quattro operazioni aritmetiche sui numeri in
;                 virgola mobile (formato MBF): somma, sottrazione,
;                 moltiplicazione e divisione, con l'altro operando in ARG, a un
;                 indirizzo assoluto o puntato da un puntatore. Il risultato è
;                 sempre in FAC. L'interruttore __PRESERVE_ARG di config.asm
;                 decide se ARG viene preservato.
; CONTENUTO:      m_Add_FAC_to_ARG          Somma ARG a FAC
;                 m_Add_FAC_to_Mem          Somma da indirizzo a FAC
;                 m_Add_FAC_to_Ptr          Somma da puntatore a FAC
;                 m_Subtract_FAC_from_ARG   Sottrae FAC da ARG
;                 m_Subtract_FAC_from_Mem   Sottrae FAC da indirizzo
;                 m_Subtract_FAC_from_Ptr   Sottrae FAC da puntatore
;                 m_Multiply_FAC_by_ARG     Moltiplica FAC per ARG
;                 m_Multiply_FAC_by_Mem     Moltiplica FAC per indirizzo
;                 m_Multiply_FAC_by_Ptr     Moltiplica FAC per puntatore
;                 m_Divide_ARG_by_FAC       Divide ARG per FAC
;                 m_Divide_Mem_by_FAC       Divide indirizzo per FAC
;                 m_Divide_Ptr_by_FAC       Divide puntatore per FAC
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   __FP_SAVED_SP
; ==============================================================================

; ==============================================================================
; MACRO: m_Add_FAC_to_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Somma FAC e un numero in formato MBF che si trova in ARG e
;               lascia il risultato in FAC: FAC = FAC + ARG.
;
;               Calcola il segno del risultato in ARISGN (bit #7 = 0 se i segni
;               di FAC e ARG sono uguali, 1 se sono diversi) e chiama la routine
;               FADDT della ROM del BASIC, che richiede in .A l'esponente di
;               FAC: se è zero, FAC è considerato zero.
;
;               La routine FADDT della ROM del BASIC può alterare ARG.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della chiamata e lo ripristina dopo; se vale 0 il contenuto di
;               ARG non è garantito dopo la chiamata.
;
;               Se il risultato è troppo grande per il formato MBF la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo
;               piccolo il risultato è zero. Per la gestione degli errori vedi
;               [NOTA #07 in <fp/fp.asm>].
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
;   - ARISGN (1 byte, ZP)            : Segno aritmetico, bit #7
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, _SCRATCH_2 (se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Add_FAC_to_ARG {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    lda FACSGN                  ; Segno del risultato: bit #7 di ARISGN.
    eor ARGSGN
    sta ARISGN

    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    lda FACEXP                  ; Esponente di FAC: se zero, FAC è zero.
    jsr FADDT                   ; Somma ARG e FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_Add_FAC_to_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Somma FAC e un numero in formato MBF che si trova a un indirizzo
;               assoluto e lascia il risultato in FAC: FAC = FAC + (.addr_).
;
;               Punta .A (LSB) e .Y (MSB) all'indirizzo del numero e chiama la
;               routine FADD della ROM del BASIC, che lo carica in ARG con
;               CONUPK e aggiorna ARISGN. La routine FADD altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata.
;
;               La routine FADD della ROM del BASIC altera sempre ARG.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della chiamata e lo ripristina dopo; se vale 0 il contenuto di
;               ARG non è garantito dopo la chiamata.
;
;               Se il risultato è troppo grande per il formato MBF la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo
;               piccolo il risultato è zero. Per la gestione degli errori vedi
;               [NOTA #07 in <fp/fp.asm>].
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
;   - ARISGN (1 byte, ZP)            : Segno aritmetico, bit #7
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
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Add_FAC_to_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    lda #<.addr_                ; Punta .A/.Y al numero.
    ldy #>.addr_
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr FADD                    ; Somma il numero a FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_Add_FAC_to_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Somma FAC e un numero in formato MBF che si trova all'indirizzo
;               a cui punta un puntatore e lascia il risultato in FAC:
;               FAC = FAC + ((.ptr_)).
;
;               Punta .A (LSB) e .Y (MSB) all'indirizzo del numero e chiama la
;               routine FADD della ROM del BASIC, che lo carica in ARG con
;               CONUPK e aggiorna ARISGN. La routine FADD altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata.
;
;               La routine FADD della ROM del BASIC altera sempre ARG.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della chiamata e lo ripristina dopo; se vale 0 il contenuto di
;               ARG non è garantito dopo la chiamata.
;
;               Se il risultato è troppo grande per il formato MBF la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo
;               piccolo il risultato è zero. Per la gestione degli errori vedi
;               [NOTA #07 in <fp/fp.asm>].
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
;   - ARISGN (1 byte, ZP)            : Segno aritmetico, bit #7
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
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Add_FAC_to_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    lda .ptr_                   ; Punta .A/.Y al numero.
    ldy .ptr_+1
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr FADD                    ; Somma il numero a FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_Subtract_FAC_from_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Sottrae FAC da un numero in formato MBF che si trova in ARG e
;               lascia il risultato in FAC: FAC = ARG - FAC.
;
;               Chiama la routine FSUBT della ROM del BASIC, che inverte il
;               segno di FAC, calcola ARISGN e tratta da sé il caso di FAC
;               uguale a zero.
;
;               La routine FSUBT della ROM del BASIC può alterare ARG.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della chiamata e lo ripristina dopo; se vale 0 il contenuto di
;               ARG non è garantito dopo la chiamata.
;
;               Se il risultato è troppo grande per il formato MBF la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo
;               piccolo il risultato è zero. Per la gestione degli errori vedi
;               [NOTA #07 in <fp/fp.asm>].
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
;   - ARISGN (1 byte, ZP)            : Segno aritmetico, bit #7
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, _SCRATCH_2 (se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Subtract_FAC_from_ARG {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr FSUBT                   ; Sottrae FAC da ARG.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_Subtract_FAC_from_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Sottrae FAC da un numero in formato MBF che si trova a un
;               indirizzo assoluto e lascia il risultato in FAC:
;               FAC = (.addr_) - FAC.
;
;               Punta .A (LSB) e .Y (MSB) all'indirizzo del numero e chiama la
;               routine FSUB della ROM del BASIC, che lo carica in ARG con
;               CONUPK e aggiorna ARISGN. La routine FSUB altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata.
;
;               La routine FSUB della ROM del BASIC altera sempre ARG.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della chiamata e lo ripristina dopo; se vale 0 il contenuto di
;               ARG non è garantito dopo la chiamata.
;
;               Se il risultato è troppo grande per il formato MBF la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo
;               piccolo il risultato è zero. Per la gestione degli errori vedi
;               [NOTA #07 in <fp/fp.asm>].
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
;   - ARISGN (1 byte, ZP)            : Segno aritmetico, bit #7
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
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Subtract_FAC_from_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    lda #<.addr_                ; Punta .A/.Y al numero.
    ldy #>.addr_
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr FSUB                    ; Sottrae FAC dal numero.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_Subtract_FAC_from_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Sottrae FAC da un numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e lascia il risultato in
;               FAC: FAC = ((.ptr_)) - FAC.
;
;               Punta .A (LSB) e .Y (MSB) all'indirizzo del numero e chiama la
;               routine FSUB della ROM del BASIC, che lo carica in ARG con
;               CONUPK e aggiorna ARISGN. La routine FSUB altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata.
;
;               La routine FSUB della ROM del BASIC altera sempre ARG.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della chiamata e lo ripristina dopo; se vale 0 il contenuto di
;               ARG non è garantito dopo la chiamata.
;
;               Se il risultato è troppo grande per il formato MBF la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo
;               piccolo il risultato è zero. Per la gestione degli errori vedi
;               [NOTA #07 in <fp/fp.asm>].
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
;   - ARISGN (1 byte, ZP)            : Segno aritmetico, bit #7
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
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Subtract_FAC_from_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    lda .ptr_                   ; Punta .A/.Y al numero.
    ldy .ptr_+1
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr FSUB                    ; Sottrae FAC dal numero.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_Multiply_FAC_by_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica FAC per un numero in formato MBF che si trova in ARG
;               e lascia il risultato in FAC: FAC = FAC x ARG.
;
;               Calcola il segno del risultato in ARISGN (bit #7 = 0 se i segni
;               di FAC e ARG sono uguali, 1 se sono diversi) e chiama la routine
;               FMULTT della ROM del BASIC, che richiede in .A l'esponente di
;               FAC: se è zero, FAC è considerato zero.
;
;               La routine FMULTT della ROM del BASIC non altera ARG, quindi la
;               macro non ha bisogno di preservarlo e l'interruttore
;               __PRESERVE_ARG non ha effetto.
;
;               Se il risultato è troppo grande per il formato MBF la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo
;               piccolo il risultato è zero. Per la gestione degli errori vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               Per l'accuratezza del risultato vedi [NOTA #08 in <fp/fp.asm>].
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
;   - ARISGN (1 byte, ZP)        : Segno aritmetico, bit #7
;   - __FP_SAVED_SP (1 byte, ZP) : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)          : Ritorno al chiamante o, se la ROM segnala un
;                                  errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Multiply_FAC_by_ARG {
    lda FACSGN                  ; Segno del risultato: bit #7 di ARISGN.
    eor ARGSGN
    sta ARISGN

    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    lda FACEXP                  ; Esponente di FAC: se zero, FAC è zero.
    jsr FMULTT                  ; Moltiplica FAC per ARG.
}

; ==============================================================================
; MACRO: m_Multiply_FAC_by_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica FAC per un numero in formato MBF che si trova a un
;               indirizzo assoluto e lascia il risultato in FAC:
;               FAC = FAC x (.addr_).
;
;               Punta .A (LSB) e .Y (MSB) all'indirizzo del numero e chiama la
;               routine FMULT della ROM del BASIC, che lo carica in ARG con
;               CONUPK e aggiorna ARISGN. La routine FMULT altera anche INDEX:
;               il suo contenuto non è garantito dopo la chiamata.
;
;               La routine FMULT della ROM del BASIC altera sempre ARG.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della chiamata e lo ripristina dopo; se vale 0 il contenuto di
;               ARG non è garantito dopo la chiamata.
;
;               Se il risultato è troppo grande per il formato MBF la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo
;               piccolo il risultato è zero. Per la gestione degli errori vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               Per l'accuratezza del risultato vedi [NOTA #08 in <fp/fp.asm>].
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
;   - ARISGN (1 byte, ZP)            : Segno aritmetico, bit #7
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
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Multiply_FAC_by_Mem .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    lda #<.addr_                ; Punta .A/.Y al numero.
    ldy #>.addr_
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr FMULT                   ; Moltiplica FAC per il numero.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_Multiply_FAC_by_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica FAC per un numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore e lascia il risultato in
;               FAC: FAC = FAC x ((.ptr_)).
;
;               Punta .A (LSB) e .Y (MSB) all'indirizzo del numero e chiama la
;               routine FMULT della ROM del BASIC, che lo carica in ARG con
;               CONUPK e aggiorna ARISGN. La routine FMULT altera anche INDEX:
;               il suo contenuto non è garantito dopo la chiamata.
;
;               La routine FMULT della ROM del BASIC altera sempre ARG.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della chiamata e lo ripristina dopo; se vale 0 il contenuto di
;               ARG non è garantito dopo la chiamata.
;
;               Se il risultato è troppo grande per il formato MBF la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo
;               piccolo il risultato è zero. Per la gestione degli errori vedi
;               [NOTA #07 in <fp/fp.asm>].
;
;               Per l'accuratezza del risultato vedi [NOTA #08 in <fp/fp.asm>].
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
;   - ARISGN (1 byte, ZP)            : Segno aritmetico, bit #7
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
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Multiply_FAC_by_Ptr .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    lda .ptr_                   ; Punta .A/.Y al numero.
    ldy .ptr_+1
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr FMULT                   ; Moltiplica FAC per il numero.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_Divide_ARG_by_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Divide un numero in formato MBF che si trova in ARG per FAC e
;               lascia il risultato in FAC: FAC = ARG / FAC.
;
;               Calcola il segno del risultato in ARISGN (bit #7 = 0 se i segni
;               di FAC e ARG sono uguali, 1 se sono diversi) e chiama la routine
;               FDIVT della ROM del BASIC, che richiede in .A l'esponente di
;               FAC: se è zero, FAC è considerato zero.
;
;               La routine FDIVT della ROM del BASIC altera sempre ARG.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della chiamata e lo ripristina dopo; se vale 0 il contenuto di
;               ARG non è garantito dopo la chiamata.
;
;               Se FAC è zero la ROM segnala DIVISION BY ZERO ERROR e non
;               ritorna al chiamante.
;
;               Se il risultato è troppo grande per il formato MBF la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo
;               piccolo il risultato è zero. Per la gestione degli errori vedi
;               [NOTA #07 in <fp/fp.asm>].
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
;   - ARISGN (1 byte, ZP)            : Segno aritmetico, bit #7
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, _SCRATCH_2 (se __PRESERVE_ARG = 1),
;                       __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Divide_ARG_by_FAC {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    lda FACSGN                  ; Segno del risultato: bit #7 di ARISGN.
    eor ARGSGN
    sta ARISGN

    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    lda FACEXP                  ; Esponente di FAC: se zero, FAC è zero.
    jsr FDIVT                   ; Divide ARG per FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_Divide_Mem_by_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Divide un numero in formato MBF che si trova a un indirizzo
;               assoluto per FAC e lascia il risultato in FAC:
;               FAC = (.addr_) / FAC.
;
;               Punta .A (LSB) e .Y (MSB) all'indirizzo del numero e chiama la
;               routine FDIV della ROM del BASIC, che lo carica in ARG con
;               CONUPK e aggiorna ARISGN. La routine FDIV altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata.
;
;               La routine FDIV della ROM del BASIC altera sempre ARG.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della chiamata e lo ripristina dopo; se vale 0 il contenuto di
;               ARG non è garantito dopo la chiamata.
;
;               Se FAC è zero la ROM segnala DIVISION BY ZERO ERROR e non
;               ritorna al chiamante.
;
;               Se il risultato è troppo grande per il formato MBF la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo
;               piccolo il risultato è zero. Per la gestione degli errori vedi
;               [NOTA #07 in <fp/fp.asm>].
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
;   - ARISGN (1 byte, ZP)            : Segno aritmetico, bit #7
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
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Divide_Mem_by_FAC .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    lda #<.addr_                ; Punta .A/.Y al numero.
    ldy #>.addr_
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr FDIV                    ; Divide il numero per FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_Divide_Ptr_by_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Divide un numero in formato MBF che si trova all'indirizzo a cui
;               punta un puntatore per FAC e lascia il risultato in FAC:
;               FAC = ((.ptr_)) / FAC.
;
;               Punta .A (LSB) e .Y (MSB) all'indirizzo del numero e chiama la
;               routine FDIV della ROM del BASIC, che lo carica in ARG con
;               CONUPK e aggiorna ARISGN. La routine FDIV altera anche INDEX: il
;               suo contenuto non è garantito dopo la chiamata.
;
;               La routine FDIV della ROM del BASIC altera sempre ARG.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della chiamata e lo ripristina dopo; se vale 0 il contenuto di
;               ARG non è garantito dopo la chiamata.
;
;               Se FAC è zero la ROM segnala DIVISION BY ZERO ERROR e non
;               ritorna al chiamante.
;
;               Se il risultato è troppo grande per il formato MBF la ROM
;               segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo
;               piccolo il risultato è zero. Per la gestione degli errori vedi
;               [NOTA #07 in <fp/fp.asm>].
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
;   - ARISGN (1 byte, ZP)            : Segno aritmetico, bit #7
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
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Divide_Ptr_by_FAC .ptr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    lda .ptr_                   ; Punta .A/.Y al numero.
    ldy .ptr_+1
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr FDIV                    ; Divide il numero per FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

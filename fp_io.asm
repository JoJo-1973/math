; ==============================================================================
; FILE:           fp_io.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per convertire i numeri in virgola mobile (formato MBF)
;                 in stringhe e viceversa, e per stamparli. Le macro di
;                 conversione in stringa e di stampa preservano sempre FAC e
;                 ARG; m_String_to_FAC preserva ARG se l'interruttore
;                 __PRESERVE_ARG di config.asm vale 1; m_String_to_ARG preserva
;                 sempre FAC.
; CONTENUTO:      m_FAC_to_String   Da FAC a stringa
;                 m_ARG_to_String   Da ARG a stringa
;                 m_String_to_FAC   Da stringa a FAC
;                 m_String_to_ARG   Da stringa a ARG
;                 m_Print_FAC       Stampa FAC
;                 m_Print_ARG       Stampa ARG
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   __FP_SAVED_SP
; ==============================================================================

; ==============================================================================
; MACRO: m_FAC_to_String
; ------------------------------------------------------------------------------
; Descrizione:  Converte il numero in virgola mobile di FAC in una stringa e la
;               scrive in STACK.
;
;               La stringa, terminata da zero, è lunga al massimo 15 caratteri
;               più il terminatore: ha uno spazio o il segno meno davanti, e usa
;               la forma esponenziale (1E+10) quando serve. Si trova in STACK,
;               da $0100 in poi.
;
;               Chiama la routine FOUT della ROM del BASIC, che altera FAC e
;               ARG. Con m_Store_FAC_in_Scratch e m_Store_ARG_in_Scratch la
;               macro salva FAC in _SCRATCH_1 e ARG in _SCRATCH_2 prima della
;               chiamata e li ripristina dopo. Per le variabili del BASIC
;               alterate vedi [NOTA #06 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, INDEX2, RESHO, $47, $56,
;               $5D-$5E e $71.
;
;               Per l'accuratezza della conversione vedi
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - FAC (7 byte, ZP)     : Registri da FACEXP a FACOV
;
; Output:
;   - STACK (16 byte, RAM) : Stringa terminata da zero, da $0100
;   - FAC (7 byte, ZP)     : Invariato
;   - ARG (6 byte, ZP)     : Invariato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, _SCRATCH_1, _SCRATCH_2, STACK (16 byte)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_FAC_to_String {
    +m_Store_FAC_in_Scratch     ; Salva FAC e ARG.
    +m_Store_ARG_in_Scratch

    jsr FOUT                    ; Scrive la stringa in STACK.

    +m_Load_FAC_from_Scratch    ; Ripristina FAC e ARG.
    +m_Load_ARG_from_Scratch
}

; ==============================================================================
; MACRO: m_ARG_to_String
; ------------------------------------------------------------------------------
; Descrizione:  Converte il numero in virgola mobile di ARG in una stringa e la
;               scrive in STACK.
;
;               La stringa, terminata da zero, è lunga al massimo 15 caratteri
;               più il terminatore: ha uno spazio o il segno meno davanti, e usa
;               la forma esponenziale (1E+10) quando serve. Si trova in STACK,
;               da $0100 in poi.
;
;               Copia prima ARG in FAC con m_Transfer_ARG_to_FAC, poi chiama la
;               routine FOUT della ROM del BASIC, che altera FAC e ARG. Con
;               m_Store_FAC_in_Scratch e m_Store_ARG_in_Scratch la macro salva
;               FAC in _SCRATCH_1 e ARG in _SCRATCH_2 prima della copia e li
;               ripristina dopo. Per le variabili del BASIC alterate vedi
;               [NOTA #06 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, INDEX2, RESHO, $47, $56,
;               $5D-$5E e $71.
;
;               Per l'accuratezza della conversione vedi
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - ARG (6 byte, ZP)     : Registri da ARGEXP a ARGSGN
;
; Output:
;   - STACK (16 byte, RAM) : Stringa terminata da zero, da $0100
;   - FAC (7 byte, ZP)     : Invariato
;   - ARG (6 byte, ZP)     : Invariato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, _SCRATCH_1, _SCRATCH_2, STACK (16 byte)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_ARG_to_String {
    +m_Store_FAC_in_Scratch     ; Salva FAC e ARG.
    +m_Store_ARG_in_Scratch

    +m_Transfer_ARG_to_FAC      ; Copia ARG in FAC.
    jsr FOUT                    ; Scrive la stringa in STACK.

    +m_Load_FAC_from_Scratch    ; Ripristina FAC e ARG.
    +m_Load_ARG_from_Scratch
}

; ==============================================================================
; MACRO: m_String_to_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Converte una stringa in un numero in virgola mobile e lo scrive
;               in FAC, che perde il suo vecchio contenuto.
;
;               La stringa, terminata da zero, rappresenta un numero: spazi
;               iniziali, segno opzionale, cifre, punto decimale ed esponente,
;               introdotto dal carattere E (codice $45) con segno opzionale. La
;               conversione si ferma al primo carattere non valido, senza
;               errori; senza un numero il risultato è zero. Un esponente troppo
;               piccolo dà zero.
;
;               Dopo avere scritto TXTPTR, la macro chiama CHRGOT, che legge
;               il primo carattere, e FIN della ROM del BASIC. FIN altera
;               sempre ARG.
;
;               La macro scrive l'indirizzo della stringa in TXTPTR, il
;               puntatore al testo del BASIC, e la ROM lo fa avanzare fino al
;               primo carattere dopo il numero. Per le variabili del BASIC
;               alterate vedi [NOTA #06 in <fp/fp.asm>].
;
;               Se il numero è troppo grande la ROM segnala OVERFLOW ERROR e non
;               ritorna al chiamante: vedi [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, RESHO, $56, $5D-$60 e $67.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della conversione e lo ripristina dopo; se vale 0 il contenuto
;               di ARG non è garantito dopo la chiamata. Un ARG uguale a zero
;               (ARGEXP = 0) torna con ARGHO = $80, ed è ancora zero.
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro)     : Indirizzo della stringa
;   - (.addr_) (n byte, RAM)         : Stringa terminata da zero
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Numero convertito, registri da FACEXP a
;                                      FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;   - TXTPTR (2 byte, ZP)            : Indirizzo del primo carattere dopo il
;                                      numero
;   - __FP_SAVED_SP (1 byte, ZP)     : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)              : Ritorno al chiamante o, se la ROM segnala
;                                      un errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, TXTPTR,
;                       _SCRATCH_2 (se __PRESERVE_ARG = 1), __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_String_to_FAC .addr_ {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    lda #<.addr_                ; Scrive l'indirizzo della stringa in TXTPTR.
    sta TXTPTR
    lda #>.addr_
    sta TXTPTR+1
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr CHRGOT                  ; Legge il primo carattere della stringa.
    jsr FIN                     ; Converte la stringa in FAC.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_String_to_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Converte una stringa in un numero in virgola mobile e lo scrive
;               in ARG, che perde il suo vecchio contenuto. FAC non cambia.
;
;               La stringa, terminata da zero, rappresenta un numero: spazi
;               iniziali, segno opzionale, cifre, punto decimale ed esponente,
;               introdotto dal carattere E (codice $45) con segno opzionale. La
;               conversione si ferma al primo carattere non valido, senza
;               errori; senza un numero il risultato è zero. Un esponente troppo
;               piccolo dà zero.
;
;               Dopo avere scritto TXTPTR, la macro chiama CHRGOT, che legge il
;               primo carattere, e FIN della ROM del BASIC, che converte la
;               stringa in FAC e altera ARG; poi chiama MOVAF per copiare FAC in
;               ARG. Con m_Store_FAC_in_Scratch la macro salva FAC in _SCRATCH_1
;               prima della conversione e con m_Load_FAC_from_Scratch lo
;               ripristina dopo.
;
;               La macro scrive l'indirizzo della stringa in TXTPTR, il
;               puntatore al testo del BASIC, e la ROM lo fa avanzare fino al
;               primo carattere dopo il numero. Per le variabili del BASIC
;               alterate vedi [NOTA #06 in <fp/fp.asm>].
;
;               Se il numero è troppo grande la ROM segnala OVERFLOW ERROR e non
;               ritorna al chiamante: vedi [NOTA #07 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, RESHO, $56, $5D-$60 e $67.
;
;               Prima della chiamata alla ROM la macro salva .S in
;               __FP_SAVED_SP, a uso di FP_ERROR_HANDLER.
;
; Input:
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo della stringa
;   - (.addr_) (n byte, RAM)     : Stringa terminata da zero
;
; Output:
;   - ARG (6 byte, ZP)           : Numero convertito, registri da ARGEXP a
;                                  ARGSGN
;   - FAC (7 byte, ZP)           : Invariato
;   - TXTPTR (2 byte, ZP)        : Indirizzo del primo carattere dopo il numero
;   - __FP_SAVED_SP (1 byte, ZP) : Valore di .S prima della chiamata
;   - .PC (2 byte, CPU)          : Ritorno al chiamante o, se la ROM segnala un
;                                  errore, salto al vettore IERROR
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, TXTPTR, _SCRATCH_1, __FP_SAVED_SP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_String_to_ARG .addr_ {
    +m_Store_FAC_in_Scratch

    lda #<.addr_                ; Scrive l'indirizzo della stringa in TXTPTR.
    sta TXTPTR
    lda #>.addr_
    sta TXTPTR+1
    tsx                         ; Salva .S per FP_ERROR_HANDLER.
    stx __FP_SAVED_SP
    jsr CHRGOT                  ; Legge il primo carattere della stringa.
    jsr FIN                     ; Converte la stringa in FAC.
    jsr MOVAF                   ; Copia FAC in ARG.

    +m_Load_FAC_from_Scratch
}

; ==============================================================================
; MACRO: m_Print_FAC
; ------------------------------------------------------------------------------
; Descrizione:  Converte il numero in virgola mobile di FAC in una stringa e
;               la stampa.
;
;               La stringa, terminata da zero, è lunga al massimo 15 caratteri
;               più il terminatore: ha uno spazio o il segno meno davanti, e usa
;               la forma esponenziale (1E+10) quando serve. Si trova in STACK,
;               da $0100 in poi.
;
;               La stringa è stampata con la subroutine __PUTSTRING, un punto di
;               personalizzazione di config.asm: per default è STROUT della ROM
;               del BASIC. Una subroutine alternativa deve stampare la stringa
;               in STACK, terminata da $00; ne riceve l'indirizzo in .A (LSB) e
;               .Y (MSB).
;
;               Chiama la routine FOUT della ROM del BASIC, che altera FAC e
;               ARG, e poi __PUTSTRING con l'indirizzo di STACK. Con
;               m_Store_FAC_in_Scratch e m_Store_ARG_in_Scratch la macro salva
;               FAC in _SCRATCH_1 e ARG in _SCRATCH_2 prima della chiamata e li
;               ripristina dopo. Per le variabili del BASIC alterate vedi
;               [NOTA #06 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, INDEX2, RESHO, $47, $56,
;               $5D-$5E e $71.
;
;               La subroutine __PUTSTRING può alterare a sua volta registri e
;               celle, che non sono elencati qui.
;
;               Per l'accuratezza della conversione vedi
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - FAC (7 byte, ZP)            : Registri da FACEXP a FACOV
;   - __PUTSTRING (2 byte, Macro) : Indirizzo della subroutine di stampa
;
; Output:
;   - STACK (16 byte, RAM)        : Stringa terminata da zero, da $0100
;   - FAC (7 byte, ZP)            : Invariato
;   - ARG (6 byte, ZP)            : Invariato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, _SCRATCH_1, _SCRATCH_2, STACK (16 byte)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Print_FAC {
    +m_Store_FAC_in_Scratch     ; Salva FAC e ARG.
    +m_Store_ARG_in_Scratch

    jsr FOUT                    ; Scrive la stringa in STACK.
    lda #<STACK                 ; Punta .A/.Y alla stringa.
    ldy #>STACK
    jsr __PUTSTRING             ; Stampa la stringa.

    +m_Load_FAC_from_Scratch    ; Ripristina FAC e ARG.
    +m_Load_ARG_from_Scratch
}

; ==============================================================================
; MACRO: m_Print_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Converte il numero in virgola mobile di ARG in una stringa e
;               la stampa.
;
;               La stringa, terminata da zero, è lunga al massimo 15 caratteri
;               più il terminatore: ha uno spazio o il segno meno davanti, e usa
;               la forma esponenziale (1E+10) quando serve. Si trova in STACK,
;               da $0100 in poi.
;
;               La stringa è stampata con la subroutine __PUTSTRING, un punto di
;               personalizzazione di config.asm: per default è STROUT della ROM
;               del BASIC. Una subroutine alternativa deve stampare la stringa
;               in STACK, terminata da $00; ne riceve l'indirizzo in .A (LSB) e
;               .Y (MSB).
;
;               Copia prima ARG in FAC con m_Transfer_ARG_to_FAC, poi chiama la
;               routine FOUT della ROM del BASIC, che altera FAC e ARG, e poi
;               __PUTSTRING con l'indirizzo di STACK. Con m_Store_FAC_in_Scratch
;               e m_Store_ARG_in_Scratch la macro salva FAC in _SCRATCH_1 e ARG
;               in _SCRATCH_2 prima della copia e li ripristina dopo. Per le
;               variabili del BASIC alterate vedi [NOTA #06 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, INDEX2, RESHO, $47, $56,
;               $5D-$5E e $71.
;
;               La subroutine __PUTSTRING può alterare a sua volta registri e
;               celle, che non sono elencati qui.
;
;               Per l'accuratezza della conversione vedi
;               [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - ARG (6 byte, ZP)            : Registri da ARGEXP a ARGSGN
;   - __PUTSTRING (2 byte, Macro) : Indirizzo della subroutine di stampa
;
; Output:
;   - STACK (16 byte, RAM)        : Stringa terminata da zero, da $0100
;   - FAC (7 byte, ZP)            : Invariato
;   - ARG (6 byte, ZP)            : Invariato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, _SCRATCH_1, _SCRATCH_2, STACK (16 byte)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Print_ARG {
    +m_Store_FAC_in_Scratch     ; Salva FAC e ARG.
    +m_Store_ARG_in_Scratch

    +m_Transfer_ARG_to_FAC      ; Copia ARG in FAC.
    jsr FOUT                    ; Scrive la stringa in STACK.
    lda #<STACK                 ; Punta .A/.Y alla stringa.
    ldy #>STACK
    jsr __PUTSTRING             ; Stampa la stringa.

    +m_Load_FAC_from_Scratch    ; Ripristina FAC e ARG.
    +m_Load_ARG_from_Scratch
}

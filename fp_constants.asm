; ==============================================================================
; FILE:           fp_constants.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per caricare FAC e ARG con un numero in virgola mobile
;                 in formato MBF, byte per byte o tra quelle predefinite.
; CONTENUTO:      m_Load_FAC_with           Carica FAC con 5 byte MBF
;                 m_Load_ARG_with           Carica ARG con 5 byte MBF
;                 m_Load_FAC_with_0         Carica FAC con 0
;                 m_Load_FAC_with_0_25      Carica FAC con 0,25
;                 m_Load_FAC_with_0_5       Carica FAC con 0,5
;                 m_Load_FAC_with_1         Carica FAC con 1
;                 m_Load_FAC_with_MINUS_1   Carica FAC con -1
;                 m_Load_FAC_with_2         Carica FAC con 2
;                 m_Load_FAC_with_10        Carica FAC con 10
;                 m_Load_FAC_with_0_1       Carica FAC con 0,1
;                 m_Load_FAC_with_PI4       Carica FAC con π/4
;                 m_Load_FAC_with_PI2       Carica FAC con π/2
;                 m_Load_FAC_with_PI        Carica FAC con π
;                 m_Load_FAC_with_2PI       Carica FAC con 2π
;                 m_Load_FAC_with_PI180     Carica FAC con π/180
;                 m_Load_FAC_with_PI200     Carica FAC con π/200
;                 m_Load_FAC_with_180PI     Carica FAC con 180/π
;                 m_Load_FAC_with_200PI     Carica FAC con 200/π
;                 m_Load_FAC_with_SQR2      Carica FAC con √2
;                 m_Load_FAC_with_SQR3      Carica FAC con √3
;                 m_Load_FAC_with_e         Carica FAC con e
;                 m_Load_FAC_with_LOG2      Carica FAC con ln 2
;                 m_Load_FAC_with_LOG10     Carica FAC con ln 10
;                 m_Load_FAC_with_eps       Carica FAC con eps
;                 m_Load_FAC_with_MINR      Carica FAC con MINR
;                 m_Load_FAC_with_MAXR      Carica FAC con MAXR
;                 m_Load_ARG_with_0         Carica ARG con 0
;                 m_Load_ARG_with_0_25      Carica ARG con 0,25
;                 m_Load_ARG_with_0_5       Carica ARG con 0,5
;                 m_Load_ARG_with_1         Carica ARG con 1
;                 m_Load_ARG_with_MINUS_1   Carica ARG con -1
;                 m_Load_ARG_with_2         Carica ARG con 2
;                 m_Load_ARG_with_10        Carica ARG con 10
;                 m_Load_ARG_with_0_1       Carica ARG con 0,1
;                 m_Load_ARG_with_PI4       Carica ARG con π/4
;                 m_Load_ARG_with_PI2       Carica ARG con π/2
;                 m_Load_ARG_with_PI        Carica ARG con π
;                 m_Load_ARG_with_2PI       Carica ARG con 2π
;                 m_Load_ARG_with_PI180     Carica ARG con π/180
;                 m_Load_ARG_with_PI200     Carica ARG con π/200
;                 m_Load_ARG_with_180PI     Carica ARG con 180/π
;                 m_Load_ARG_with_200PI     Carica ARG con 200/π
;                 m_Load_ARG_with_SQR2      Carica ARG con √2
;                 m_Load_ARG_with_SQR3      Carica ARG con √3
;                 m_Load_ARG_with_e         Carica ARG con e
;                 m_Load_ARG_with_LOG2      Carica ARG con ln 2
;                 m_Load_ARG_with_LOG10     Carica ARG con ln 10
;                 m_Load_ARG_with_eps       Carica ARG con eps
;                 m_Load_ARG_with_MINR      Carica ARG con MINR
;                 m_Load_ARG_with_MAXR      Carica ARG con MAXR
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   Nessuno
; ==============================================================================

; ==============================================================================
; MACRO: m_Load_FAC_with
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con un numero in virgola mobile in formato MBF a
;               precisione estesa (5 byte), scrivendo ogni byte con istruzioni
;               lda e sta, senza chiamare la ROM del BASIC. Il valore caricato
;               in FAC è sempre considerato arrotondato: FACOV viene azzerato.
;
;               Quando un byte è uguale al precedente la macro omette il
;               caricamento in .A. Gli operandi devono essere definiti prima
;               dell'invocazione, perché la macro li confronta per scegliere
;               il ramo.
;
; Input:
;   - .exp_ (1 byte, Macro) : Esponente
;   - .ho_ (1 byte, Macro)  : MSB della mantissa, con il segno nel bit #7
;   - .moh_ (1 byte, Macro) : Secondo byte della mantissa
;   - .mo_ (1 byte, Macro)  : Terzo byte della mantissa
;   - .lo_ (1 byte, Macro)  : LSB della mantissa
;
; Output:
;   - FAC (7 byte, ZP)      : Numero caricato, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with .exp_, .ho_, .moh_, .mo_, .lo_ {
    lda #.exp_                  ; Carica il byte dell'esponente.
    sta FACEXP

    !if ((.ho_ OR %10000000) - .exp_) {
      lda #(.ho_ OR %10000000)  ; Ripristina il bit #7 del MSB della mantissa.
    }

    sta FACHO

    !if (.moh_ - (.ho_ OR %10000000)) {
      lda #.moh_                ; Carica il secondo byte della mantissa.
    }

    sta FACMOH

    !if (.mo_ - .moh_) {
      lda #.mo_                 ; Carica il terzo byte della mantissa.
    }

    sta FACMO

    !if (.lo_ - .mo_) {
      lda #.lo_                 ; Carica il LSB della mantissa.
    }

    sta FACLO

    !if (.ho_ AND %10000000) {  ; Controlla il segno del valore.
      !if ($FF - .lo_) {
        lda #$FF
      }
    } else {
      !if (.lo_) {
        lda #$00
      }
    }

    sta FACSGN                  ; Imposta il byte del segno.

    !if (.ho_ AND %10000000) {
      lda #0                    ; Azzera il byte di arrotondamento di FAC.
    }

    sta FACOV
}

; ==============================================================================
; MACRO: m_Load_ARG_with
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con un numero in virgola mobile in formato MBF a
;               precisione estesa (5 byte), scrivendo ogni byte con istruzioni
;               lda e sta, senza chiamare la ROM del BASIC.
;
;               Quando un byte è uguale al precedente la macro omette il
;               caricamento in .A. Gli operandi devono essere definiti prima
;               dell'invocazione, perché la macro li confronta per scegliere
;               il ramo.
;
; Input:
;   - .exp_ (1 byte, Macro) : Esponente
;   - .ho_ (1 byte, Macro)  : MSB della mantissa, con il segno nel bit #7
;   - .moh_ (1 byte, Macro) : Secondo byte della mantissa
;   - .mo_ (1 byte, Macro)  : Terzo byte della mantissa
;   - .lo_ (1 byte, Macro)  : LSB della mantissa
;
; Output:
;   - ARG (6 byte, ZP)      : Numero caricato, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with .exp_, .ho_, .moh_, .mo_, .lo_ {
    lda #.exp_                  ; Carica il byte dell'esponente.
    sta ARGEXP

    !if ((.ho_ OR %10000000) - .exp_) {
      lda #(.ho_ OR %10000000)  ; Ripristina il bit #7 del MSB della mantissa.
    }

    sta ARGHO

    !if (.moh_ - (.ho_ OR %10000000)) {
      lda #.moh_                ; Carica il secondo byte della mantissa.
    }

    sta ARGMOH

    !if (.mo_ - .moh_) {
      lda #.mo_                 ; Carica il terzo byte della mantissa.
    }

    sta ARGMO

    !if (.lo_ - .mo_) {
      lda #.lo_                 ; Carica il LSB della mantissa.
    }

    sta ARGLO

    !if (.ho_ AND %10000000) {  ; Controlla il segno del valore.
      !if ($FF - .lo_) {
        lda #$FF
      }
    } else {
      !if (.lo_) {
        lda #$00
      }
    }

    sta ARGSGN                  ; Imposta il byte del segno.
}

; ==============================================================================
; MACRO: m_Load_FAC_with_0
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante 0. FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($00, $00, $00, $00, $00) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
;               FACEXP vale zero, quindi il valore è zero per la ROM del BASIC;
;               il MSB della mantissa vale $80 (il bit implicito).
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_0 {
    +m_Load_FAC_with $00, $00, $00, $00, $00
}

; ==============================================================================
; MACRO: m_Load_FAC_with_0_25
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante 0,25. FACOV viene azzerato.
;
;               Legge la costante da FR4 ($E2EA) nella ROM del BASIC con
;               m_Load_FAC_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_FAC_with_0_25 {
    +m_Load_FAC_from_Mem FR4
}

; ==============================================================================
; MACRO: m_Load_FAC_with_0_5
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante 0,5. FACOV viene azzerato.
;
;               Legge la costante da FHALF ($BF11) nella ROM del BASIC con
;               m_Load_FAC_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_FAC_with_0_5 {
    +m_Load_FAC_from_Mem FHALF
}

; ==============================================================================
; MACRO: m_Load_FAC_with_1
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante 1. FACOV viene azzerato.
;
;               Legge la costante da FONE ($B9BC) nella ROM del BASIC con
;               m_Load_FAC_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_FAC_with_1 {
    +m_Load_FAC_from_Mem FONE
}

; ==============================================================================
; MACRO: m_Load_FAC_with_MINUS_1
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante -1. FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($81, $80, $00, $00, $00) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_MINUS_1 {
    +m_Load_FAC_with $81, $80, $00, $00, $00
}

; ==============================================================================
; MACRO: m_Load_FAC_with_2
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante 2. FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($82, $00, $00, $00, $00) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_2 {
    +m_Load_FAC_with $82, $00, $00, $00, $00
}

; ==============================================================================
; MACRO: m_Load_FAC_with_10
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante 10. FACOV viene azzerato.
;
;               Legge la costante da TENC ($BAF9) nella ROM del BASIC con
;               m_Load_FAC_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_FAC_with_10 {
    +m_Load_FAC_from_Mem TENC
}

; ==============================================================================
; MACRO: m_Load_FAC_with_0_1
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante 0,1. FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($7D, $4C, $CC, $CC, $CD) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_0_1 {
    +m_Load_FAC_with $7D, $4C, $CC, $CC, $CD
}

; ==============================================================================
; MACRO: m_Load_FAC_with_PI4
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante π/4. FACOV viene azzerato.
;
;               Carica π/2 dalla ROM del BASIC con m_Load_FAC_from_Mem, che
;               altera anche INDEX: il suo contenuto non è garantito dopo
;               la chiamata. Poi decrementa l'esponente di FAC, che dimezza
;               il valore.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry), FACEXP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_FAC_with_PI4 {
    +m_Load_FAC_with_PI2
    dec FACEXP
}

; ==============================================================================
; MACRO: m_Load_FAC_with_PI2
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante π/2. FACOV viene azzerato.
;
;               Legge la costante da PI2 ($E2E0) nella ROM del BASIC con
;               m_Load_FAC_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_FAC_with_PI2 {
    +m_Load_FAC_from_Mem PI2
}

; ==============================================================================
; MACRO: m_Load_FAC_with_PI
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante π. FACOV viene azzerato.
;
;               Legge la costante da PIVAL ($AEA8) nella ROM del BASIC con
;               m_Load_FAC_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
;               Il valore della ROM non è il più vicino a π:
;               vedi [NOTA #17 in <fp/fp.asm>].
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_FAC_with_PI {
    +m_Load_FAC_from_Mem PIVAL
}

; ==============================================================================
; MACRO: m_Load_FAC_with_2PI
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante 2π. FACOV viene azzerato.
;
;               Legge la costante da TWOPI ($E2E5) nella ROM del BASIC con
;               m_Load_FAC_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_FAC_with_2PI {
    +m_Load_FAC_from_Mem TWOPI
}

; ==============================================================================
; MACRO: m_Load_FAC_with_PI180
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante π/180. FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($7B, $0E, $FA, $35, $13) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_PI180 {
    +m_Load_FAC_with $7B, $0E, $FA, $35, $13
}

; ==============================================================================
; MACRO: m_Load_FAC_with_PI200
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante π/200. FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($7B, $00, $AD, $FC, $91) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_PI200 {
    +m_Load_FAC_with $7B, $00, $AD, $FC, $91
}

; ==============================================================================
; MACRO: m_Load_FAC_with_180PI
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante 180/π. FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($86, $65, $2E, $E0, $D3) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_180PI {
    +m_Load_FAC_with $86, $65, $2E, $E0, $D3
}

; ==============================================================================
; MACRO: m_Load_FAC_with_200PI
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante 200/π. FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($86, $7E, $A5, $DD, $5C) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_200PI {
    +m_Load_FAC_with $86, $7E, $A5, $DD, $5C
}

; ==============================================================================
; MACRO: m_Load_FAC_with_SQR2
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante √2. FACOV viene azzerato.
;
;               Legge la costante da FSQR2 ($B9DB) nella ROM del BASIC con
;               m_Load_FAC_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_FAC_with_SQR2 {
    +m_Load_FAC_from_Mem FSQR2
}

; ==============================================================================
; MACRO: m_Load_FAC_with_SQR3
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante √3. FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($81, $5D, $B3, $D7, $43) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_SQR3 {
    +m_Load_FAC_with $81, $5D, $B3, $D7, $43
}

; ==============================================================================
; MACRO: m_Load_FAC_with_e
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante e. FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($82, $2D, $F8, $54, $59) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_e {
    +m_Load_FAC_with $82, $2D, $F8, $54, $59
}

; ==============================================================================
; MACRO: m_Load_FAC_with_LOG2
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante ln 2. FACOV viene azzerato.
;
;               Legge la costante da FLOG2 ($B9E5) nella ROM del BASIC con
;               m_Load_FAC_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_FAC_with_LOG2 {
    +m_Load_FAC_from_Mem FLOG2
}

; ==============================================================================
; MACRO: m_Load_FAC_with_LOG10
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con la costante ln 10. FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($82, $13, $5D, $8D, $DE) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_LOG10 {
    +m_Load_FAC_with $82, $13, $5D, $8D, $DE
}

; ==============================================================================
; MACRO: m_Load_FAC_with_eps
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con l'epsilon di macchina. FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($62, $00, $00, $00, $00) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
;               Vale 4,65661287*10^-10 ed è la differenza tra 1 e il numero in
;               virgola mobile successivo.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_eps {
    +m_Load_FAC_with $62, $00, $00, $00, $00
}

; ==============================================================================
; MACRO: m_Load_FAC_with_MINR
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il più piccolo numero rappresentabile (MINR).
;               FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($01, $00, $00, $00, $00) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
;               Vale 2,93873588*10^-39 ed è il più piccolo numero diverso da
;               zero rappresentabile in formato MBF.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_MINR {
    +m_Load_FAC_with $01, $00, $00, $00, $00
}

; ==============================================================================
; MACRO: m_Load_FAC_with_MAXR
; ------------------------------------------------------------------------------
; Descrizione:  Carica FAC con il più grande numero rappresentabile (MAXR).
;               FACOV viene azzerato.
;
;               Scrive i 5 byte della costante ($FF, $7F, $FF, $FF, $FF) con
;               m_Load_FAC_with, senza chiamare la ROM del BASIC.
;
;               Vale 1,70141183*10^38 ed è il più grande numero rappresentabile
;               in formato MBF.
;
; Input:
;   - Nessuno
;
; Output:
;   - FAC (7 byte, ZP) : Costante caricata, registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_with_MAXR {
    +m_Load_FAC_with $FF, $7F, $FF, $FF, $FF
}

; ==============================================================================
; MACRO: m_Load_ARG_with_0
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante 0. FAC non cambia.
;
;               Scrive i 5 byte della costante ($00, $00, $00, $00, $00) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
;               FACEXP vale zero, quindi il valore è zero per la ROM del BASIC;
;               il MSB della mantissa vale $80 (il bit implicito).
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_0 {
    +m_Load_ARG_with $00, $00, $00, $00, $00
}

; ==============================================================================
; MACRO: m_Load_ARG_with_0_25
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante 0,25. FAC non cambia.
;
;               Legge la costante da FR4 ($E2EA) nella ROM del BASIC con
;               m_Load_ARG_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
;               La routine CONUPK della ROM aggiorna anche ARISGN: il bit #7
;               vale 1 se i segni di FAC e di ARG sono diversi.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP)    : Costante caricata, registri da ARGEXP a ARGSGN
;   - ARISGN (1 byte, ZP) : Bit #7: 0 = segni uguali; 1 = segni diversi
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_0_25 {
    +m_Load_ARG_from_Mem FR4
}

; ==============================================================================
; MACRO: m_Load_ARG_with_0_5
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante 0,5. FAC non cambia.
;
;               Legge la costante da FHALF ($BF11) nella ROM del BASIC con
;               m_Load_ARG_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
;               La routine CONUPK della ROM aggiorna anche ARISGN: il bit #7
;               vale 1 se i segni di FAC e di ARG sono diversi.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP)    : Costante caricata, registri da ARGEXP a ARGSGN
;   - ARISGN (1 byte, ZP) : Bit #7: 0 = segni uguali; 1 = segni diversi
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_0_5 {
    +m_Load_ARG_from_Mem FHALF
}

; ==============================================================================
; MACRO: m_Load_ARG_with_1
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante 1. FAC non cambia.
;
;               Legge la costante da FONE ($B9BC) nella ROM del BASIC con
;               m_Load_ARG_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
;               La routine CONUPK della ROM aggiorna anche ARISGN: il bit #7
;               vale 1 se i segni di FAC e di ARG sono diversi.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP)    : Costante caricata, registri da ARGEXP a ARGSGN
;   - ARISGN (1 byte, ZP) : Bit #7: 0 = segni uguali; 1 = segni diversi
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_1 {
    +m_Load_ARG_from_Mem FONE
}

; ==============================================================================
; MACRO: m_Load_ARG_with_MINUS_1
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante -1. FAC non cambia.
;
;               Scrive i 5 byte della costante ($81, $80, $00, $00, $00) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_MINUS_1 {
    +m_Load_ARG_with $81, $80, $00, $00, $00
}

; ==============================================================================
; MACRO: m_Load_ARG_with_2
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante 2. FAC non cambia.
;
;               Scrive i 5 byte della costante ($82, $00, $00, $00, $00) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_2 {
    +m_Load_ARG_with $82, $00, $00, $00, $00
}

; ==============================================================================
; MACRO: m_Load_ARG_with_10
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante 10. FAC non cambia.
;
;               Legge la costante da TENC ($BAF9) nella ROM del BASIC con
;               m_Load_ARG_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
;               La routine CONUPK della ROM aggiorna anche ARISGN: il bit #7
;               vale 1 se i segni di FAC e di ARG sono diversi.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP)    : Costante caricata, registri da ARGEXP a ARGSGN
;   - ARISGN (1 byte, ZP) : Bit #7: 0 = segni uguali; 1 = segni diversi
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_10 {
    +m_Load_ARG_from_Mem TENC
}

; ==============================================================================
; MACRO: m_Load_ARG_with_0_1
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante 0,1. FAC non cambia.
;
;               Scrive i 5 byte della costante ($7D, $4C, $CC, $CC, $CD) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_0_1 {
    +m_Load_ARG_with $7D, $4C, $CC, $CC, $CD
}

; ==============================================================================
; MACRO: m_Load_ARG_with_PI4
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante π/4. FAC non cambia.
;
;               Carica π/2 dalla ROM del BASIC con m_Load_ARG_from_Mem, che
;               altera anche INDEX: il suo contenuto non è garantito dopo
;               la chiamata. Poi decrementa l'esponente di ARG, che dimezza
;               il valore.
;
;               La routine CONUPK della ROM aggiorna anche ARISGN: il bit #7
;               vale 1 se i segni di FAC e di ARG sono diversi.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP)    : Costante caricata, registri da ARGEXP a ARGSGN
;   - ARISGN (1 byte, ZP) : Bit #7: 0 = segni uguali; 1 = segni diversi
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry), ARGEXP
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_PI4 {
    +m_Load_ARG_with_PI2
    dec ARGEXP
}

; ==============================================================================
; MACRO: m_Load_ARG_with_PI2
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante π/2. FAC non cambia.
;
;               Legge la costante da PI2 ($E2E0) nella ROM del BASIC con
;               m_Load_ARG_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
;               La routine CONUPK della ROM aggiorna anche ARISGN: il bit #7
;               vale 1 se i segni di FAC e di ARG sono diversi.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP)    : Costante caricata, registri da ARGEXP a ARGSGN
;   - ARISGN (1 byte, ZP) : Bit #7: 0 = segni uguali; 1 = segni diversi
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_PI2 {
    +m_Load_ARG_from_Mem PI2
}

; ==============================================================================
; MACRO: m_Load_ARG_with_PI
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante π. FAC non cambia.
;
;               Legge la costante da PIVAL ($AEA8) nella ROM del BASIC con
;               m_Load_ARG_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
;               Il valore della ROM non è il più vicino a π:
;               vedi [NOTA #17 in <fp/fp.asm>].
;
;               La routine CONUPK della ROM aggiorna anche ARISGN: il bit #7
;               vale 1 se i segni di FAC e di ARG sono diversi.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP)    : Costante caricata, registri da ARGEXP a ARGSGN
;   - ARISGN (1 byte, ZP) : Bit #7: 0 = segni uguali; 1 = segni diversi
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_PI {
    +m_Load_ARG_from_Mem PIVAL
}

; ==============================================================================
; MACRO: m_Load_ARG_with_2PI
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante 2π. FAC non cambia.
;
;               Legge la costante da TWOPI ($E2E5) nella ROM del BASIC con
;               m_Load_ARG_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
;               La routine CONUPK della ROM aggiorna anche ARISGN: il bit #7
;               vale 1 se i segni di FAC e di ARG sono diversi.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP)    : Costante caricata, registri da ARGEXP a ARGSGN
;   - ARISGN (1 byte, ZP) : Bit #7: 0 = segni uguali; 1 = segni diversi
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_2PI {
    +m_Load_ARG_from_Mem TWOPI
}

; ==============================================================================
; MACRO: m_Load_ARG_with_PI180
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante π/180. FAC non cambia.
;
;               Scrive i 5 byte della costante ($7B, $0E, $FA, $35, $13) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_PI180 {
    +m_Load_ARG_with $7B, $0E, $FA, $35, $13
}

; ==============================================================================
; MACRO: m_Load_ARG_with_PI200
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante π/200. FAC non cambia.
;
;               Scrive i 5 byte della costante ($7B, $00, $AD, $FC, $91) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_PI200 {
    +m_Load_ARG_with $7B, $00, $AD, $FC, $91
}

; ==============================================================================
; MACRO: m_Load_ARG_with_180PI
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante 180/π. FAC non cambia.
;
;               Scrive i 5 byte della costante ($86, $65, $2E, $E0, $D3) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_180PI {
    +m_Load_ARG_with $86, $65, $2E, $E0, $D3
}

; ==============================================================================
; MACRO: m_Load_ARG_with_200PI
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante 200/π. FAC non cambia.
;
;               Scrive i 5 byte della costante ($86, $7E, $A5, $DD, $5C) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_200PI {
    +m_Load_ARG_with $86, $7E, $A5, $DD, $5C
}

; ==============================================================================
; MACRO: m_Load_ARG_with_SQR2
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante √2. FAC non cambia.
;
;               Legge la costante da FSQR2 ($B9DB) nella ROM del BASIC con
;               m_Load_ARG_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
;               La routine CONUPK della ROM aggiorna anche ARISGN: il bit #7
;               vale 1 se i segni di FAC e di ARG sono diversi.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP)    : Costante caricata, registri da ARGEXP a ARGSGN
;   - ARISGN (1 byte, ZP) : Bit #7: 0 = segni uguali; 1 = segni diversi
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_SQR2 {
    +m_Load_ARG_from_Mem FSQR2
}

; ==============================================================================
; MACRO: m_Load_ARG_with_SQR3
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante √3. FAC non cambia.
;
;               Scrive i 5 byte della costante ($81, $5D, $B3, $D7, $43) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_SQR3 {
    +m_Load_ARG_with $81, $5D, $B3, $D7, $43
}

; ==============================================================================
; MACRO: m_Load_ARG_with_e
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante e. FAC non cambia.
;
;               Scrive i 5 byte della costante ($82, $2D, $F8, $54, $59) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_e {
    +m_Load_ARG_with $82, $2D, $F8, $54, $59
}

; ==============================================================================
; MACRO: m_Load_ARG_with_LOG2
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante ln 2. FAC non cambia.
;
;               Legge la costante da FLOG2 ($B9E5) nella ROM del BASIC con
;               m_Load_ARG_from_Mem, che altera anche INDEX: il suo contenuto
;               non è garantito dopo la chiamata.
;
;               La routine CONUPK della ROM aggiorna anche ARISGN: il bit #7
;               vale 1 se i segni di FAC e di ARG sono diversi.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP)    : Costante caricata, registri da ARGEXP a ARGSGN
;   - ARISGN (1 byte, ZP) : Bit #7: 0 = segni uguali; 1 = segni diversi
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .Y, .P (Negative, oVerflow, Zero, Carry)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Load_ARG_with_LOG2 {
    +m_Load_ARG_from_Mem FLOG2
}

; ==============================================================================
; MACRO: m_Load_ARG_with_LOG10
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con la costante ln 10. FAC non cambia.
;
;               Scrive i 5 byte della costante ($82, $13, $5D, $8D, $DE) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_LOG10 {
    +m_Load_ARG_with $82, $13, $5D, $8D, $DE
}

; ==============================================================================
; MACRO: m_Load_ARG_with_eps
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con l'epsilon di macchina. FAC non cambia.
;
;               Scrive i 5 byte della costante ($62, $00, $00, $00, $00) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
;               Vale 4,65661287*10^-10 ed è la differenza tra 1 e il numero in
;               virgola mobile successivo.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_eps {
    +m_Load_ARG_with $62, $00, $00, $00, $00
}

; ==============================================================================
; MACRO: m_Load_ARG_with_MINR
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con il più piccolo numero rappresentabile (MINR). FAC
;               non cambia.
;
;               Scrive i 5 byte della costante ($01, $00, $00, $00, $00) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
;               Vale 2,93873588*10^-39 ed è il più piccolo numero diverso da
;               zero rappresentabile in formato MBF.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_MINR {
    +m_Load_ARG_with $01, $00, $00, $00, $00
}

; ==============================================================================
; MACRO: m_Load_ARG_with_MAXR
; ------------------------------------------------------------------------------
; Descrizione:  Carica ARG con il più grande numero rappresentabile (MAXR). FAC
;               non cambia.
;
;               Scrive i 5 byte della costante ($FF, $7F, $FF, $FF, $FF) con
;               m_Load_ARG_with, senza chiamare la ROM del BASIC.
;
;               Vale 1,70141183*10^38 ed è il più grande numero rappresentabile
;               in formato MBF.
;
; Input:
;   - Nessuno
;
; Output:
;   - ARG (6 byte, ZP) : Costante caricata, registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_with_MAXR {
    +m_Load_ARG_with $FF, $7F, $FF, $FF, $FF
}

; ==============================================================================
; FILE:           fp_scratch.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Aree di appoggio e macro per salvare e ripristinare una copia
;                 di FAC e di ARG, ad uso interno della libreria fp.
; CONTENUTO:      m_Store_FAC_in_Scratch    Salva FAC nell'area di appoggio
;                 m_Store_ARG_in_Scratch    Salva ARG nell'area di appoggio
;                 m_Load_FAC_from_Scratch   Ripristina FAC dall'area di appoggio
;                 m_Load_ARG_from_Scratch   Ripristina ARG dall'area di appoggio
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   _SCRATCH_1, _SCRATCH_2
; ==============================================================================

; ------------------------------------------------------------------------------
; Aree di appoggio
; ------------------------------------------------------------------------------

; Queste due aree sono usate solo dal BASIC e si possono usare
; in sicurezza come aree di appoggio, per salvare e
; ripristinare copie di FAC e di ARG. Sono ad uso interno
; della libreria.

_SCRATCH_1          = $3D       ; Appoggio per FAC (7 byte)
_SCRATCH_2          = NUMWRK    ; Appoggio per ARG (6 byte)

; ==============================================================================
; MACRO: m_Store_FAC_in_Scratch
; ------------------------------------------------------------------------------
; Descrizione:  Copia in _SCRATCH_1 il contenuto di FAC, un registro alla volta.
;               Uso interno della libreria.
;
; Input:
;   - FAC (7 byte, ZP)        : Registri da FACEXP a FACOV
;
; Output:
;   - _SCRATCH_1 (7 byte, ZP) : Copia di FAC
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), _SCRATCH_1
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Store_FAC_in_Scratch {
    lda FACEXP                  ; Salva il byte dell'esponente.
    sta _SCRATCH_1

    lda FACHO                   ; Salva il MSB della mantissa.
    sta _SCRATCH_1+1

    lda FACMOH                  ; Salva il secondo byte della mantissa.
    sta _SCRATCH_1+2

    lda FACMO                   ; Salva il terzo byte della mantissa.
    sta _SCRATCH_1+3

    lda FACLO                   ; Salva il LSB della mantissa.
    sta _SCRATCH_1+4

    lda FACSGN                  ; Salva il byte del segno.
    sta _SCRATCH_1+5

    lda FACOV                   ; Salva il byte di arrotondamento.
    sta _SCRATCH_1+6
}

; ==============================================================================
; MACRO: m_Store_ARG_in_Scratch
; ------------------------------------------------------------------------------
; Descrizione:  Copia in _SCRATCH_2 il contenuto di ARG, un registro alla volta.
;               Uso interno della libreria.
;
; Input:
;   - ARG (6 byte, ZP)        : Registri da ARGEXP a ARGSGN
;
; Output:
;   - _SCRATCH_2 (6 byte, ZP) : Copia di ARG
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), _SCRATCH_2
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Store_ARG_in_Scratch {
    lda ARGEXP                  ; Salva il byte dell'esponente.
    sta _SCRATCH_2

    lda ARGHO                   ; Salva il MSB della mantissa.
    sta _SCRATCH_2+1

    lda ARGMOH                  ; Salva il secondo byte della mantissa.
    sta _SCRATCH_2+2

    lda ARGMO                   ; Salva il terzo byte della mantissa.
    sta _SCRATCH_2+3

    lda ARGLO                   ; Salva il LSB della mantissa.
    sta _SCRATCH_2+4

    lda ARGSGN                  ; Salva il byte del segno.
    sta _SCRATCH_2+5
}

; ==============================================================================
; MACRO: m_Load_FAC_from_Scratch
; ------------------------------------------------------------------------------
; Descrizione:  Copia il contenuto di _SCRATCH_1 in FAC, un registro alla volta.
;               Uso interno della libreria.
;
; Input:
;   - _SCRATCH_1 (7 byte, ZP) : Copia di FAC
;
; Output:
;   - FAC (7 byte, ZP)        : Registri da FACEXP a FACOV
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), FAC
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_FAC_from_Scratch {
    lda _SCRATCH_1              ; Ripristina il byte dell'esponente.
    sta FACEXP

    lda _SCRATCH_1+1            ; Ripristina il MSB della mantissa.
    sta FACHO

    lda _SCRATCH_1+2            ; Ripristina il secondo byte della mantissa.
    sta FACMOH

    lda _SCRATCH_1+3            ; Ripristina il terzo byte della mantissa.
    sta FACMO

    lda _SCRATCH_1+4            ; Ripristina il LSB della mantissa.
    sta FACLO

    lda _SCRATCH_1+5            ; Ripristina il byte del segno.
    sta FACSGN

    lda _SCRATCH_1+6            ; Ripristina il byte di arrotondamento.
    sta FACOV
}

; ==============================================================================
; MACRO: m_Load_ARG_from_Scratch
; ------------------------------------------------------------------------------
; Descrizione:  Copia il contenuto di _SCRATCH_2 in ARG, un registro alla volta.
;               Uso interno della libreria.
;
; Input:
;   - _SCRATCH_2 (6 byte, ZP) : Copia di ARG
;
; Output:
;   - ARG (6 byte, ZP)        : Registri da ARGEXP a ARGSGN
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), ARG
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Load_ARG_from_Scratch {
    lda _SCRATCH_2              ; Ripristina il byte dell'esponente.
    sta ARGEXP

    lda _SCRATCH_2+1            ; Ripristina il MSB della mantissa.
    sta ARGHO

    lda _SCRATCH_2+2            ; Ripristina il secondo byte della mantissa.
    sta ARGMOH

    lda _SCRATCH_2+3            ; Ripristina il terzo byte della mantissa.
    sta ARGMO

    lda _SCRATCH_2+4            ; Ripristina il LSB della mantissa.
    sta ARGLO

    lda _SCRATCH_2+5            ; Ripristina il byte del segno.
    sta ARGSGN
}

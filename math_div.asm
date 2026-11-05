; ==============================================================================
; FILE:           math_div.asm
; PROGETTO:       Libreria Matematica (math)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Nuclei aritmetici (macro) e subroutine per la divisione intera
;                 unsigned e signed (Restoring Division) da 8 a 32 bit.
; DIPENDENZE:     <c64/symbols.asm>, once, <c64/errors.asm>, once
; REQUISITI ZP:   DIV_1, DIV_QUOT, DIV_2, DIV_REM
; ==============================================================================

; ------------------------------------------------------------------------------
; INCLUSIONE DIPENDENZE ESTERNE
; ------------------------------------------------------------------------------
!source <c64/symbols.asm>, once
!source <c64/errors.asm>, once

; ==============================================================================
; SECTION 0: SIMBOLI GLOBALI DI ZP
; ==============================================================================

DIV_1               = NUMWRK          ; Dividendo (In, fino a 32 bit)
DIV_QUOT            = DIV_1           ; Quoziente (Out, sovrascrive DIV_1)
DIV_2               = NUMWRK+4        ; Divisore (In, fino a 32 bit)
DIV_REM             = NUMWRK+8        ; Resto / Modulo (Out, fino a 32 bit)

; ==============================================================================
; SECTION 1: NUCLEI ARITMETICI (MACRO)
; ==============================================================================

; ==============================================================================
; MACRO: m_Div_Core_8x8
; ------------------------------------------------------------------------------
; Descrizione: Restoring Division per 2 interi ad 8 bit senza segno.
;
; Input:
;   - DIV_1+0              (1 byte, ZP) : Dividendo (8 bit)
;   - DIV_2+0              (1 byte, ZP) : Divisore (8 bit)
;
; Output:
;   - DIV_QUOT+0           (1 byte, ZP) : Quoziente (8 bit)
;   - DIV_REM+0            (1 byte, ZP) : Resto (8 bit)
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_8x8 {
    lda #0
    sta DIV_REM+0                      ; Resto parziale a 0

    lda DIV_1+0                        ; Carica Dividendo in .A
    ldx #8                             ; 8 bit

  .Loop_Div:
    asl a                              ; Shift Dividendo/Quoziente: LSB -> Carry
    rol DIV_REM+0                      ; Propaga MSB del dividendo nel Resto

    pha                                ; Salva Quoziente parziale
    lda DIV_REM+0                      ; Sottrazione esplorativa: Resto - Divisore
    sec
    sbc DIV_2+0
    bcc @Skip_Sub                      ; Se Resto < Divisore (Carry = 0), non sottrae

    sta DIV_REM+0                      ; Aggiorna il Resto
    pla                                ; Recupera Quoziente
    ora #1                             ; Inserisce 1 nel LSB del Quoziente
    jmp .Next_Div

  @Skip_Sub:
    pla                                ; Recupera Quoziente

  .Next_Div:
    dex
    bne .Loop_Div

    sta DIV_QUOT+0                     ; Deposita Quoziente in ZP
}

; ==============================================================================
; MACRO: m_Div_Core_16x8
; ------------------------------------------------------------------------------
; Descrizione: Restoring Division per dividendo a 16 bit e divisore a 8 bit.
;
; Input:
;   - DIV_1+0 .. DIV_1+1   (2 byte, ZP) : Dividendo (16 bit)
;   - DIV_2+0              (1 byte, ZP) : Divisore (8 bit)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+1          : Quoziente (16 bit in ZP)
;   - DIV_REM+0            (1 byte, ZP) : Resto (8 bit in ZP)
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .Y, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_16x8 {
    lda #0
    sta DIV_REM+0                      ; Resto parziale a 0 (8 bit)

    ldy #16                            ; Contatore a 16 bit

  .Loop_Div:
    asl DIV_1+0                        ; Shift a sinistra del Dividendo a 16 bit
    rol DIV_1+1
    rol DIV_REM+0                      ; Propaga MSB del dividendo nel Resto

    lda DIV_REM+0                      ; Sottrazione esplorativa: Resto - Divisore
    sec
    sbc DIV_2+0
    bcc @Skip_Sub                      ; Se Resto < Divisore (Carry = 0), non sottrae

    sta DIV_REM+0                      ; Aggiorna il Resto
    inc DIV_1+0                        ; Inserisce 1 nel LSB del Quoziente

  @Skip_Sub:
    dey
    bne .Loop_Div
}

; ==============================================================================
; MACRO: m_Div_Core_24x8
; ------------------------------------------------------------------------------
; Descrizione: Restoring Division per dividendo a 24 bit e divisore a 8 bit.
;
; Input:
;   - DIV_1+0 .. DIV_1+2   (3 byte, ZP) : Dividendo (24 bit)
;   - DIV_2+0              (1 byte, ZP) : Divisore (8 bit)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+2          : Quoziente (24 bit in ZP)
;   - DIV_REM+0            (1 byte, ZP) : Resto (8 bit in ZP)
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .Y, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_24x8 {
    lda #0
    sta DIV_REM+0                      ; Resto parziale a 0 (8 bit)

    ldy #24                            ; Contatore a 24 bit

  .Loop_Div:
    asl DIV_1+0                        ; Shift a sinistra del Dividendo a 24 bit
    rol DIV_1+1
    rol DIV_1+2
    rol DIV_REM+0                      ; Propaga MSB del dividendo nel Resto

    lda DIV_REM+0                      ; Sottrazione esplorativa: Resto - Divisore
    sec
    sbc DIV_2+0
    bcc @Skip_Sub

    sta DIV_REM+0                      ; Aggiorna il Resto
    inc DIV_1+0                        ; Inserisce 1 nel LSB del Quoziente

  @Skip_Sub:
    dey
    bne .Loop_Div
}

; ==============================================================================
; MACRO: m_Div_Core_32x8
; ------------------------------------------------------------------------------
; Descrizione: Restoring Division per dividendo a 32 bit e divisore a 8 bit.
;
; Input:
;   - DIV_1+0 .. DIV_1+3   (4 byte, ZP) : Dividendo (32 bit)
;   - DIV_2+0              (1 byte, ZP) : Divisore (8 bit)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+3          : Quoziente (32 bit in ZP)
;   - DIV_REM+0            (1 byte, ZP) : Resto (8 bit in ZP)
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .Y, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_32x8 {
    lda #0
    sta DIV_REM+0                      ; Resto parziale a 0 (8 bit)

    ldy #32                            ; Contatore a 32 bit

  .Loop_Div:
    asl DIV_1+0                        ; Shift a sinistra del Dividendo a 32 bit
    rol DIV_1+1
    rol DIV_1+2
    rol DIV_1+3
    rol DIV_REM+0                      ; Propaga MSB del dividendo nel Resto

    lda DIV_REM+0                      ; Sottrazione esplorativa: Resto - Divisore
    sec
    sbc DIV_2+0
    bcc @Skip_Sub

    sta DIV_REM+0                      ; Aggiorna il Resto
    inc DIV_1+0                        ; Inserisce 1 nel LSB del Quoziente

  @Skip_Sub:
    dey
    bne .Loop_Div
}

; ==============================================================================
; MACRO: m_Div_Core_16x16
; ------------------------------------------------------------------------------
; Descrizione: Restoring Division per dividendo e divisore a 16 bit.
;
; Input:
;   - DIV_1+0 .. DIV_1+1   (2 byte, ZP) : Dividendo (16 bit)
;   - DIV_2+0 .. DIV_2+1   (2 byte, ZP) : Divisore (16 bit)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+1          : Quoziente (16 bit in ZP)
;   - DIV_REM+0 .. DIV_REM+1            : Resto (16 bit in ZP)
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .Y, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_16x16 {
    lda #0
    sta DIV_REM+0                      ; Resto parziale a 0 (16 bit)
    sta DIV_REM+1

    ldy #16                            ; Contatore a 16 bit

  .Loop_Div:
    asl DIV_1+0                        ; Shift a sinistra del Dividendo a 16 bit
    rol DIV_1+1
    rol DIV_REM+0
    rol DIV_REM+1

    lda DIV_REM+0                      ; Sottrazione esplorativa (16 bit)
    sec
    sbc DIV_2+0
    tax

    lda DIV_REM+1
    sbc DIV_2+1
    bcc @Skip_Sub

    sta DIV_REM+1
    stx DIV_REM+0
    inc DIV_1+0

  @Skip_Sub:
    dey
    bne .Loop_Div
}

; ==============================================================================
; MACRO: m_Div_Core_24x16
; ------------------------------------------------------------------------------
; Descrizione: Restoring Division per dividendo a 24 bit e divisore a 16 bit.
;
; Input:
;   - DIV_1+0 .. DIV_1+2   (3 byte, ZP) : Dividendo (24 bit)
;   - DIV_2+0 .. DIV_2+1   (2 byte, ZP) : Divisore (16 bit)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+2          : Quoziente (24 bit in ZP)
;   - DIV_REM+0 .. DIV_REM+1            : Resto (16 bit in ZP)
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .Y, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_24x16 {
    lda #0
    sta DIV_REM+0                      ; Resto parziale a 0 (16 bit)
    sta DIV_REM+1

    ldy #24                            ; Contatore a 24 bit

  .Loop_Div:
    asl DIV_1+0                        ; Shift a sinistra del Dividendo a 24 bit
    rol DIV_1+1
    rol DIV_1+2
    rol DIV_REM+0
    rol DIV_REM+1

    lda DIV_REM+0                      ; Sottrazione esplorativa (16 bit)
    sec
    sbc DIV_2+0
    tax

    lda DIV_REM+1
    sbc DIV_2+1
    bcc @Skip_Sub

    sta DIV_REM+1
    stx DIV_REM+0
    inc DIV_1+0

  @Skip_Sub:
    dey
    bne .Loop_Div
}

; ==============================================================================
; MACRO: m_Div_Core_32x16
; ------------------------------------------------------------------------------
; Descrizione: Restoring Division per dividendo a 32 bit e divisore a 16 bit.
;
; Input:
;   - DIV_1+0 .. DIV_1+3   (4 byte, ZP) : Dividendo (32 bit)
;   - DIV_2+0 .. DIV_2+1   (2 byte, ZP) : Divisore (16 bit)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+3          : Quoziente (32 bit in ZP)
;   - DIV_REM+0 .. DIV_REM+1            : Resto (16 bit in ZP)
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .Y, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_32x16 {
    lda #0
    sta DIV_REM+0                      ; Resto parziale a 0 (16 bit)
    sta DIV_REM+1

    ldy #32                            ; Contatore a 32 bit

  .Loop_Div:
    asl DIV_1+0                        ; Shift a sinistra del Dividendo a 32 bit
    rol DIV_1+1
    rol DIV_1+2
    rol DIV_1+3
    rol DIV_REM+0
    rol DIV_REM+1

    lda DIV_REM+0                      ; Sottrazione esplorativa (16 bit)
    sec
    sbc DIV_2+0
    tax

    lda DIV_REM+1
    sbc DIV_2+1
    bcc @Skip_Sub

    sta DIV_REM+1
    stx DIV_REM+0
    inc DIV_1+0

  @Skip_Sub:
    dey
    bne .Loop_Div
}

; ==============================================================================
; MACRO: m_Div_Core_24x24
; ------------------------------------------------------------------------------
; Descrizione: Restoring Division per dividendo e divisore a 24 bit.
;
; Input:
;   - DIV_1+0 .. DIV_1+2   (3 byte, ZP) : Dividendo (24 bit)
;   - DIV_2+0 .. DIV_2+2   (3 byte, ZP) : Divisore (24 bit)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+2          : Quoziente (24 bit in ZP)
;   - DIV_REM+0 .. DIV_REM+2            : Resto (24 bit in ZP)
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .Y, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_24x24 {
    lda #0
    sta DIV_REM+0                      ; Resto parziale a 0 (24 bit)
    sta DIV_REM+1
    sta DIV_REM+2

    ldy #24                            ; Contatore a 24 bit

  .Loop_Div:
    asl DIV_1+0                        ; Shift a sinistra del Dividendo a 24 bit
    rol DIV_1+1
    rol DIV_1+2
    rol DIV_REM+0
    rol DIV_REM+1
    rol DIV_REM+2

    lda DIV_REM+0                      ; Sottrazione esplorativa (24 bit)
    sec
    sbc DIV_2+0
    tax

    lda DIV_REM+1
    sbc DIV_2+1
    pha

    lda DIV_REM+2
    sbc DIV_2+2
    bcc @Skip_Sub

    sta DIV_REM+2
    pla
    sta DIV_REM+1
    stx DIV_REM+0
    inc DIV_1+0
    jmp +

  @Skip_Sub:
    pla

  +
    dey
    bne .Loop_Div
}

; ==============================================================================
; MACRO: m_Div_Core_32x24
; ------------------------------------------------------------------------------
; Descrizione: Restoring Division per dividendo a 32 bit e divisore a 24 bit.
;
; Input:
;   - DIV_1+0 .. DIV_1+3   (4 byte, ZP) : Dividendo (32 bit)
;   - DIV_2+0 .. DIV_2+2   (3 byte, ZP) : Divisore (24 bit)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+3          : Quoziente (32 bit in ZP)
;   - DIV_REM+0 .. DIV_REM+2            : Resto (24 bit in ZP)
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .Y, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_32x24 {
    lda #0
    sta DIV_REM+0                      ; Resto parziale a 0 (24 bit)
    sta DIV_REM+1
    sta DIV_REM+2

    ldy #32                            ; Contatore a 32 bit

  .Loop_Div:
    asl DIV_1+0                        ; Shift a sinistra del Dividendo a 32 bit
    rol DIV_1+1
    rol DIV_1+2
    rol DIV_1+3
    rol DIV_REM+0
    rol DIV_REM+1
    rol DIV_REM+2

    lda DIV_REM+0                      ; Sottrazione esplorativa (24 bit)
    sec
    sbc DIV_2+0
    tax

    lda DIV_REM+1
    sbc DIV_2+1
    pha

    lda DIV_REM+2
    sbc DIV_2+2
    bcc @Skip_Sub

    sta DIV_REM+2
    pla
    sta DIV_REM+1
    stx DIV_REM+0
    inc DIV_1+0
    jmp +

  @Skip_Sub:
    pla

  +
    dey
    bne .Loop_Div
}

; ==============================================================================
; MACRO: m_Div_Core_32x32
; ------------------------------------------------------------------------------
; Descrizione: Restoring Division per dividendo e divisore a 32 bit.
;
; Input:
;   - DIV_1+0 .. DIV_1+3   (4 byte, ZP) : Dividendo (32 bit)
;   - DIV_2+0 .. DIV_2+3   (4 byte, ZP) : Divisore (32 bit)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+3          : Quoziente (32 bit in ZP)
;   - DIV_REM+0 .. DIV_REM+3            : Resto (32 bit in ZP)
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .Y, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_32x32 {
    lda #0
    sta DIV_REM+0                      ; Resto parziale a 0 (32 bit)
    sta DIV_REM+1
    sta DIV_REM+2
    sta DIV_REM+3

    ldy #32                            ; Contatore a 32 bit

  .Loop_Div:
    asl DIV_1+0                        ; Shift a sinistra del Dividendo a 32 bit
    rol DIV_1+1
    rol DIV_1+2
    rol DIV_1+3
    rol DIV_REM+0
    rol DIV_REM+1
    rol DIV_REM+2
    rol DIV_REM+3

    lda DIV_REM+0                      ; Sottrazione esplorativa (32 bit)
    sec
    sbc DIV_2+0
    tax

    lda DIV_REM+1
    sbc DIV_2+1
    pha

    lda DIV_REM+2
    sbc DIV_2+2
    pha

    lda DIV_REM+3
    sbc DIV_2+3
    bcc @Skip_Sub

    sta DIV_REM+3
    pla
    sta DIV_REM+2
    pla
    sta DIV_REM+1
    stx DIV_REM+0
    inc DIV_1+0
    jmp +

  @Skip_Sub:
    pla
    pla

  +
    dey
    bne .Loop_Div
}

; ==============================================================================
; SECTION 2: SUBROUTINE PER LA FAMIGLIA 8X8
; ==============================================================================

!ifdef __USE_DIV_8X8 {
  ; ==============================================================================
  ; SUBROUTINE: DIV_8X8 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra 2 interi ad 8 bit senza segno.
  ;
  ; Input:
  ;   - .A                   (1 byte, CPU) : Dividendo (8 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Divisore (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Resto / Modulo (8 bit)
  ;   - DIV_QUOT+0                         : Quoziente in ZP
  ;   - DIV_REM+0                          : Resto in ZP
  ;   - Flag Carry (.P)                    : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Div_8x8

    DIV_8X8:
      sta DIV_1+0                      ; Salva Dividendo
      stx DIV_2+0                      ; Salva Divisore

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      txa                              ; Verifica divisore nullo (DIV_2 == 0)
      beq .Exit_DIV_8X8_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo (DIV_1 == 0)
      beq .Exit_DIV_8X8_Zero_Dividend

      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_8x8                  ; Esegue divisione 8x8 Unsigned

    .Exit_DIV_8X8_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente
      ldx DIV_REM+0                    ; .X = Resto
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_8X8_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_REM+0                    ; Resto = 0
      tax                              ; .X = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_8X8_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO        ; Codice errore ($14 = 20)
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

!ifdef __USE_SDIV_8X8 {
  ; ==============================================================================
  ; SUBROUTINE: SDIV_8X8 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra 2 interi ad 8 bit con segno (complemento a 2).
  ;
  ; Input:
  ;   - .A                   (1 byte, CPU) : Dividendo (8 bit signed)
  ;   - .X                   (1 byte, CPU) : Divisore (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Resto / Modulo (8 bit)
  ;   - DIV_QUOT+0                         : Quoziente in ZP
  ;   - DIV_REM+0                          : Resto in ZP
  ;   - Flag Carry (.P)                    : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Sdiv_8x8

    SDIV_8X8:
      sta DIV_1+0                      ; Salva Dividendo
      stx DIV_2+0                      ; Salva Divisore

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      txa                              ; Verifica divisore nullo (DIV_2 == 0)
      beq .Exit_SDIV_8X8_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo (DIV_1 == 0)
      beq .Exit_SDIV_8X8_Zero_Dividend

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda DIV_1+0
      eor DIV_2+0                      ; Bit 7 = Segno del Quoziente
      pha                              ; Salva segno quoziente

      lda DIV_1+0                      ; Bit 7 = Segno del Resto
      pha                              ; Salva segno resto

      lda DIV_1+0                      ; Normalizza Dividendo (|DIV_1|)
      bpl @A_Is_Positive
      eor #$FF                         ; Complemento a 2 a 8 bit
      clc
      adc #1
      sta DIV_1+0

    @A_Is_Positive:
      lda DIV_2+0                      ; Normalizza Divisore (|DIV_2|)
      bpl @B_Is_Positive
      eor #$FF                         ; Complemento a 2 a 8 bit
      clc
      adc #1
      sta DIV_2+0

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_8x8                  ; Esegue divisione 8x8 Unsigned sui valori assoluti

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Resto
      bpl @Check_Quotient_Sign

      sec                              ; Inverte segno Resto (0 - DIV_REM)
      lda #0
      sbc DIV_REM+0
      sta DIV_REM+0

    @Check_Quotient_Sign:
      pla                              ; Recupera segno Quoziente
      bpl .Exit_SDIV_8X8_Success

      sec                              ; Inverte segno Quoziente (0 - DIV_QUOT)
      lda #0
      sbc DIV_QUOT+0
      sta DIV_QUOT+0

    .Exit_SDIV_8X8_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente
      ldx DIV_REM+0                    ; .X = Resto
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_8X8_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_REM+0                    ; Resto = 0
      tax                              ; .X = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_8X8_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO        ; Codice errore ($14 = 20)
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

; ==============================================================================
; SECTION 3: SUBROUTINE PER LA FAMIGLIA 16X8
; ==============================================================================

!ifdef __USE_DIV_16X8 {
  ; ==============================================================================
  ; SUBROUTINE: DIV_16X8 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra un intero a 16 bit e uno ad 8 bit senza segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+1 (2 byte, ZP) : Dividendo (16 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Divisore (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente MSB
  ;   - .Y                   (1 byte, CPU) : Resto (8 bit)
  ;   - DIV_QUOT+0 .. DIV_QUOT+1          : Quoziente a 16 bit in ZP
  ;   - DIV_REM+0                          : Resto ad 8 bit in ZP
  ;   - Flag Carry (.P)                    : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Div_16x8

    DIV_16X8:
      sta DIV_2+0                      ; Salva Divisore in ZP

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      beq .Exit_DIV_16X8_Div_Zero      ; Se Divisore == 0, errore

      lda DIV_1+0                      ; Verifica dividendo nullo (DIV_1 == 0)
      ora DIV_1+1
      beq .Exit_DIV_16X8_Zero_Dividend

      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_16x8

    .Exit_DIV_16X8_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente MSB
      ldy DIV_REM+0                    ; .Y = Resto
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_16X8_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_REM+0                    ; Resto = 0
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_16X8_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO        ; Codice errore ($14 = 20)
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

!ifdef __USE_SDIV_16X8 {
  ; ==============================================================================
  ; SUBROUTINE: SDIV_16X8 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra un intero a 16 bit ed uno ad 8 bit con segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+1 (2 byte, ZP) : Dividendo (16 bit signed)
  ;   - .A                   (1 byte, CPU) : Divisore (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente MSB
  ;   - .Y                   (1 byte, CPU) : Resto (8 bit)
  ;   - DIV_QUOT+0 .. DIV_QUOT+1          : Quoziente a 16 bit in ZP
  ;   - DIV_REM+0                          : Resto ad 8 bit in ZP
  ;   - Flag Carry (.P)                    : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Sdiv_16x8

    SDIV_16X8:
      sta DIV_2+0                      ; Salva Divisore in ZP

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      beq .Exit_SDIV_16X8_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      beq .Exit_SDIV_16X8_Zero_Dividend

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda DIV_1+1
      eor DIV_2+0                      ; Bit 7 = Segno del Quoziente
      pha                              ; Salva segno quoziente

      lda DIV_1+1                      ; Bit 7 = Segno del Resto
      pha                              ; Salva segno resto

      lda DIV_1+1                      ; Normalizza Dividendo (|DIV_1|) a 16 bit
      bpl @A_Is_Positive

      sec                              ; Negazione a 16 bit: 0 - DIV_1
      lda #0
      sbc DIV_1+0
      sta DIV_1+0

      lda #0
      sbc DIV_1+1
      sta DIV_1+1

    @A_Is_Positive:
      lda DIV_2+0                      ; Normalizza Divisore (|DIV_2|) a 8 bit
      bpl @B_Is_Positive
      eor #$FF                         ; Complemento a 2 a 8 bit
      clc
      adc #1
      sta DIV_2+0

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_16x8                 ; Esegue divisione 16x8 Unsigned sui valori assoluti

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno del Resto
      bpl @Check_Quotient_Sign

      sec                              ; Inverte segno Resto ad 8 bit (0 - DIV_REM)
      lda #0
      sbc DIV_REM+0
      sta DIV_REM+0

    @Check_Quotient_Sign:
      pla                              ; Recupera segno del Quoziente
      bpl .Exit_SDIV_16X8_Success

      sec                              ; Inverte segno Quoziente a 16 bit (0 - DIV_QUOT)
      lda #0
      sbc DIV_QUOT+0
      sta DIV_QUOT+0

      lda #0
      sbc DIV_QUOT+1
      sta DIV_QUOT+1

    .Exit_SDIV_16X8_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente MSB
      ldy DIV_REM+0                    ; .Y = Resto
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_16X8_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_REM+0                    ; Resto = 0
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_16X8_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO        ; Codice errore ($14 = 20)
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

; ==============================================================================
; SECTION 4: SUBROUTINE PER LA FAMIGLIA 24X8
; ==============================================================================

!ifdef __USE_DIV_24X8 {
  ; ==============================================================================
  ; SUBROUTINE: DIV_24X8 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra un intero a 24 bit ed uno ad 8 bit senza segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP) : Dividendo (24 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Divisore (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente MID
  ;   - .Y                   (1 byte, CPU) : Quoziente MSB
  ;   - DIV_QUOT+0 .. DIV_QUOT+2          : Quoziente a 24 bit in ZP
  ;   - DIV_REM+0                          : Resto ad 8 bit in ZP
  ;   - Flag Carry (.P)                    : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Div_24x8

    DIV_24X8:
      sta DIV_2+0                      ; Salva Divisore in ZP

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      beq .Exit_DIV_24X8_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      beq .Exit_DIV_24X8_Zero_Dividend

      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_24x8

    .Exit_DIV_24X8_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente MID
      ldy DIV_QUOT+2                   ; .Y = Quoziente MSB
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_24X8_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_REM+0                    ; Resto = 0
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_24X8_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

!ifdef __USE_SDIV_24X8 {
  ; ==============================================================================
  ; SUBROUTINE: SDIV_24X8 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra un intero a 24 bit ed uno ad 8 bit con segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP) : Dividendo (24 bit signed)
  ;   - .A                   (1 byte, CPU) : Divisore (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente MID
  ;   - .Y                   (1 byte, CPU) : Quoziente MSB
  ;   - DIV_QUOT+0 .. DIV_QUOT+2          : Quoziente a 24 bit in ZP
  ;   - DIV_REM+0                          : Resto ad 8 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Sdiv_24x8

    SDIV_24X8:
      sta DIV_2+0                      ; Salva Divisore in ZP

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      beq .Exit_SDIV_24X8_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      beq .Exit_SDIV_24X8_Zero_Dividend

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda DIV_1+2
      eor DIV_2+0                      ; Bit 7 = Segno del Quoziente
      pha                              ; Salva segno quoziente

      lda DIV_1+2                      ; Bit 7 = Segno del Resto
      pha                              ; Salva segno resto

      lda DIV_1+2                      ; Normalizza Dividendo (|DIV_1|) a 24 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 24 bit: 0 - DIV_1
      lda #0
      sbc DIV_1+0
      sta DIV_1+0

      lda #0
      sbc DIV_1+1
      sta DIV_1+1

      lda #0
      sbc DIV_1+2
      sta DIV_1+2

    @A_Is_Positive:
      lda DIV_2+0                      ; Normalizza Divisore (|DIV_2|) ad 8 bit
      bpl @B_Is_Positive
      eor #$FF
      clc
      adc #1
      sta DIV_2+0

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_24x8

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Resto
      bpl @Check_Quotient_Sign

      sec                              ; Inverte segno Resto (0 - DIV_REM)
      lda #0
      sbc DIV_REM+0
      sta DIV_REM+0

    @Check_Quotient_Sign:
      pla                              ; Recupera segno Quoziente
      bpl .Exit_SDIV_24X8_Success

      sec                              ; Inverte segno Quoziente 24 bit (0 - DIV_QUOT)
      lda #0
      sbc DIV_QUOT+0
      sta DIV_QUOT+0

      lda #0
      sbc DIV_QUOT+1
      sta DIV_QUOT+1

      lda #0
      sbc DIV_QUOT+2
      sta DIV_QUOT+2

    .Exit_SDIV_24X8_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente MID
      ldy DIV_QUOT+2                   ; .Y = Quoziente MSB
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_24X8_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_REM+0                    ; Resto = 0
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_24X8_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

; ==============================================================================
; SECTION 5: SUBROUTINE PER LA FAMIGLIA 32X8
; ==============================================================================

!ifdef __USE_DIV_32X8 {
  ; ==============================================================================
  ; SUBROUTINE: DIV_32X8 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra un intero a 32 bit ed uno ad 8 bit senza segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP) : Dividendo (32 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Divisore (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente Byte 1
  ;   - .Y                   (1 byte, CPU) : Quoziente Byte 2
  ;   - DIV_QUOT+0 .. DIV_QUOT+3          : Quoziente a 32 bit in ZP
  ;   - DIV_REM+0                          : Resto ad 8 bit in ZP
  ;   - Flag Carry (.P)                    : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Div_32x8

    DIV_32X8:
      sta DIV_2+0                      ; Salva Divisore in ZP

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      beq .Exit_DIV_32X8_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      ora DIV_1+3
      beq .Exit_DIV_32X8_Zero_Dividend

      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_32x8

    .Exit_DIV_32X8_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente Byte 1
      ldy DIV_QUOT+2                   ; .Y = Quoziente Byte 2
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_32X8_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_QUOT+3
      sta DIV_REM+0                    ; Resto = 0
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_32X8_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

!ifdef __USE_SDIV_32X8 {
  ; ==============================================================================
  ; SUBROUTINE: SDIV_32X8 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra un intero a 32 bit ed uno ad 8 bit con segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP) : Dividendo (32 bit signed)
  ;   - .A                   (1 byte, CPU) : Divisore (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente Byte 1
  ;   - .Y                   (1 byte, CPU) : Quoziente Byte 2
  ;   - DIV_QUOT+0 .. DIV_QUOT+3          : Quoziente a 32 bit in ZP
  ;   - DIV_REM+0                          : Resto ad 8 bit in ZP
  ;   - Flag Carry (.P)                    : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Sdiv_32x8

    SDIV_32X8:
      sta DIV_2+0                      ; Salva Divisore in ZP

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      beq .Exit_SDIV_32X8_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      ora DIV_1+3
      beq .Exit_SDIV_32X8_Zero_Dividend

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda DIV_1+3
      eor DIV_2+0                      ; Bit 7 = Segno del Quoziente
      pha                              ; Salva segno quoziente

      lda DIV_1+3                      ; Bit 7 = Segno del Resto
      pha                              ; Salva segno resto

      lda DIV_1+3                      ; Normalizza Dividendo (|DIV_1|) a 32 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 32 bit: 0 - DIV_1
      lda #0
      sbc DIV_1+0
      sta DIV_1+0

      lda #0
      sbc DIV_1+1
      sta DIV_1+1

      lda #0
      sbc DIV_1+2
      sta DIV_1+2

      lda #0
      sbc DIV_1+3
      sta DIV_1+3

    @A_Is_Positive:
      lda DIV_2+0                      ; Normalizza Divisore (|DIV_2|) ad 8 bit
      bpl @B_Is_Positive
      eor #$FF
      clc
      adc #1
      sta DIV_2+0

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_32x8

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Resto
      bpl @Check_Quotient_Sign

      sec                              ; Inverte segno Resto (0 - DIV_REM)
      lda #0
      sbc DIV_REM+0
      sta DIV_REM+0

    @Check_Quotient_Sign:
      pla                              ; Recupera segno Quoziente
      bpl .Exit_SDIV_32X8_Success

      sec                              ; Inverte segno Quoziente 32 bit (0 - DIV_QUOT)
      lda #0
      sbc DIV_QUOT+0
      sta DIV_QUOT+0

      lda #0
      sbc DIV_QUOT+1
      sta DIV_QUOT+1

      lda #0
      sbc DIV_QUOT+2
      sta DIV_QUOT+2

      lda #0
      sbc DIV_QUOT+3
      sta DIV_QUOT+3

    .Exit_SDIV_32X8_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente Byte 1
      ldy DIV_QUOT+2                   ; .Y = Quoziente Byte 2
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_32X8_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_QUOT+3
      sta DIV_REM+0                    ; Resto = 0
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_32X8_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

; ==============================================================================
; SECTION 6: SUBROUTINE PER LA FAMIGLIA 16X16
; ==============================================================================

!ifdef __USE_DIV_16X16 {
  ; ==============================================================================
  ; SUBROUTINE: DIV_16X16 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra due interi a 16 bit senza segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+1 (2 byte, ZP) : Dividendo (16 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Divisore LSB (8 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Divisore MSB (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente MSB
  ;   - DIV_QUOT+0 .. DIV_QUOT+1          : Quoziente a 16 bit in ZP
  ;   - DIV_REM+0 .. DIV_REM+1            : Resto a 16 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Div_16x16

    DIV_16X16:
      sta DIV_2+0                      ; Salva Divisore in ZP
      stx DIV_2+1

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      ora DIV_2+1                      ; Verifica divisore nullo (DIV_2 == 0)
      beq .Exit_DIV_16X16_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo (DIV_1 == 0)
      ora DIV_1+1
      beq .Exit_DIV_16X16_Zero_Dividend

      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_16x16                ; Esegue divisione 16x16 Unsigned

    .Exit_DIV_16X16_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente MSB
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_16X16_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_REM+0                    ; Resto = 0
      sta DIV_REM+1
      tax                              ; .X = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_16X16_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO        ; Codice errore ($14 = 20)
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

!ifdef __USE_SDIV_16X16 {
  ; ==============================================================================
  ; SUBROUTINE: SDIV_16X16 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra due interi a 16 bit con segno (complemento a 2).
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+1 (2 byte, ZP) : Dividendo (16 bit signed)
  ;   - .A                   (1 byte, CPU) : Divisore LSB (8 bit signed)
  ;   - .X                   (1 byte, CPU) : Divisore MSB (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente MSB
  ;   - DIV_QUOT+0 .. DIV_QUOT+1          : Quoziente a 16 bit in ZP
  ;   - DIV_REM+0 .. DIV_REM+1            : Resto a 16 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Sdiv_16x16

    SDIV_16X16:
      sta DIV_2+0                      ; Salva Divisore in ZP
      stx DIV_2+1

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      ora DIV_2+1                      ; Verifica divisore nullo (DIV_2 == 0)
      beq .Exit_SDIV_16X16_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo (DIV_1 == 0)
      ora DIV_1+1
      beq .Exit_SDIV_16X16_Zero_Dividend

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda DIV_1+1
      eor DIV_2+1                      ; Bit 7 = Segno del Quoziente
      pha                              ; Salva segno del quoziente sullo stack

      lda DIV_1+1                      ; Bit 7 = Segno del Resto
      pha                              ; Salva segno del resto sullo stack

      lda DIV_1+1                      ; Normalizza Dividendo (|DIV_1|) a 16 bit
      bpl @A_Is_Positive

      sec                              ; Negazione a 16 bit: 0 - DIV_1
      lda #0
      sbc DIV_1+0
      sta DIV_1+0

      lda #0
      sbc DIV_1+1
      sta DIV_1+1

    @A_Is_Positive:
      lda DIV_2+1                      ; Normalizza Divisore (|DIV_2|) a 16 bit
      bpl @B_Is_Positive

      sec                              ; Negazione a 16 bit: 0 - DIV_2
      lda #0
      sbc DIV_2+0
      sta DIV_2+0

      lda #0
      sbc DIV_2+1
      sta DIV_2+1

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_16x16                ; Esegue divisione 16x16 Unsigned sui valori assoluti

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno del Resto
      bpl @Check_Quotient_Sign

      sec                              ; Inverte segno Resto a 16 bit (0 - DIV_REM)
      lda #0
      sbc DIV_REM+0
      sta DIV_REM+0

      lda #0
      sbc DIV_REM+1
      sta DIV_REM+1

    @Check_Quotient_Sign:
      pla                              ; Recupera segno del Quoziente
      bpl .Exit_SDIV_16X16_Success

      sec                              ; Inverte segno Quoziente a 16 bit (0 - DIV_QUOT)
      lda #0
      sbc DIV_QUOT+0
      sta DIV_QUOT+0

      lda #0
      sbc DIV_QUOT+1
      sta DIV_QUOT+1

    .Exit_SDIV_16X16_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente MSB
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_16X16_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_REM+0                    ; Resto = 0
      sta DIV_REM+1
      tax                              ; .X = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_16X16_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO        ; Codice errore ($14 = 20)
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

; ==============================================================================
; SECTION 7: SUBROUTINE PER LA FAMIGLIA 24X16
; ==============================================================================

!ifdef __USE_DIV_24X16 {
  ; ==============================================================================
  ; SUBROUTINE: DIV_24X16 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra un intero a 24 bit e uno a 16 bit senza segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP) : Dividendo (24 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Divisore LSB (8 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Divisore MSB (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente MID
  ;   - .Y                   (1 byte, CPU) : Quoziente MSB
  ;   - DIV_QUOT+0 .. DIV_QUOT+2          : Quoziente a 24 bit in ZP
  ;   - DIV_REM+0 .. DIV_REM+1            : Resto a 16 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Div_24x16

    DIV_24X16:
      sta DIV_2+0                      ; Salva Divisore in ZP
      stx DIV_2+1

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      ora DIV_2+1                      ; Verifica divisore nullo
      beq .Exit_DIV_24X16_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      beq .Exit_DIV_24X16_Zero_Dividend

      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_24x16

    .Exit_DIV_24X16_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente MID
      ldy DIV_QUOT+2                   ; .Y = Quoziente MSB
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_24X16_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_REM+0                    ; Resto = 0
      sta DIV_REM+1
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_24X16_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

!ifdef __USE_SDIV_24X16 {
  ; ==============================================================================
  ; SUBROUTINE: SDIV_24X16 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra un intero a 24 bit e uno a 16 bit con segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP) : Dividendo (24 bit signed)
  ;   - .A                   (1 byte, CPU) : Divisore LSB (8 bit signed)
  ;   - .X                   (1 byte, CPU) : Divisore MSB (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente MID
  ;   - .Y                   (1 byte, CPU) : Quoziente MSB
  ;   - DIV_QUOT+0 .. DIV_QUOT+2          : Quoziente a 24 bit in ZP
  ;   - DIV_REM+0 .. DIV_REM+1            : Resto a 16 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Sdiv_24x16

    SDIV_24X16:
      sta DIV_2+0                      ; Salva Divisore in ZP
      stx DIV_2+1

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      ora DIV_2+1                      ; Verifica divisore nullo
      beq .Exit_SDIV_24X16_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      beq .Exit_SDIV_24X16_Zero_Dividend

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda DIV_1+2
      eor DIV_2+1                      ; Bit 7 = Segno del Quoziente
      pha                              ; Salva segno quoziente

      lda DIV_1+2                      ; Bit 7 = Segno del Resto
      pha                              ; Salva segno resto

      lda DIV_1+2                      ; Normalizza Dividendo (|DIV_1|) a 24 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 24 bit: 0 - DIV_1
      lda #0
      sbc DIV_1+0
      sta DIV_1+0

      lda #0
      sbc DIV_1+1
      sta DIV_1+1

      lda #0
      sbc DIV_1+2
      sta DIV_1+2

    @A_Is_Positive:
      lda DIV_2+1                      ; Normalizza Divisore (|DIV_2|) a 16 bit
      bpl @B_Is_Positive

      sec                              ; Negazione 16 bit: 0 - DIV_2
      lda #0
      sbc DIV_2+0
      sta DIV_2+0

      lda #0
      sbc DIV_2+1
      sta DIV_2+1

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_24x16

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Resto
      bpl @Check_Quotient_Sign

      sec                              ; Inverte segno Resto 16 bit (0 - DIV_REM)
      lda #0
      sbc DIV_REM+0
      sta DIV_REM+0

      lda #0
      sbc DIV_REM+1
      sta DIV_REM+1

    @Check_Quotient_Sign:
      pla                              ; Recupera segno Quoziente
      bpl .Exit_SDIV_24X16_Success

      sec                              ; Inverte segno Quoziente 24 bit (0 - DIV_QUOT)
      lda #0
      sbc DIV_QUOT+0
      sta DIV_QUOT+0

      lda #0
      sbc DIV_QUOT+1
      sta DIV_QUOT+1

      lda #0
      sbc DIV_QUOT+2
      sta DIV_QUOT+2

    .Exit_SDIV_24X16_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente MID
      ldy DIV_QUOT+2                   ; .Y = Quoziente MSB
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_24X16_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_REM+0                    ; Resto = 0
      sta DIV_REM+1
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_24X16_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

; ==============================================================================
; SECTION 8: SUBROUTINE PER LA FAMIGLIA 32X16
; ==============================================================================

!ifdef __USE_DIV_32X16 {
  ; ==============================================================================
  ; SUBROUTINE: DIV_32X16 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra un intero a 32 bit e uno a 16 bit senza segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP) : Dividendo (32 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Divisore LSB (8 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Divisore MSB (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente Byte 1
  ;   - .Y                   (1 byte, CPU) : Quoziente Byte 2
  ;   - DIV_QUOT+0 .. DIV_QUOT+3          : Quoziente a 32 bit in ZP
  ;   - DIV_REM+0 .. DIV_REM+1            : Resto a 16 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Div_32x16

    DIV_32X16:
      sta DIV_2+0                      ; Salva Divisore in ZP
      stx DIV_2+1

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      ora DIV_2+1                      ; Verifica divisore nullo
      beq .Exit_DIV_32X16_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      ora DIV_1+3
      beq .Exit_DIV_32X16_Zero_Dividend

      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_32x16

    .Exit_DIV_32X16_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente Byte 1
      ldy DIV_QUOT+2                   ; .Y = Quoziente Byte 2
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_32X16_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_QUOT+3
      sta DIV_REM+0                    ; Resto = 0
      sta DIV_REM+1
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_32X16_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

!ifdef __USE_SDIV_32X16 {
  ; ==============================================================================
  ; SUBROUTINE: SDIV_32X16 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra un intero a 32 bit e uno a 16 bit con segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP) : Dividendo (32 bit signed)
  ;   - .A                   (1 byte, CPU) : Divisore LSB (8 bit signed)
  ;   - .X                   (1 byte, CPU) : Divisore MSB (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente Byte 1
  ;   - .Y                   (1 byte, CPU) : Quoziente Byte 2
  ;   - DIV_QUOT+0 .. DIV_QUOT+3          : Quoziente a 32 bit in ZP
  ;   - DIV_REM+0 .. DIV_REM+1            : Resto a 16 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Sdiv_32x16

    SDIV_32X16:
      sta DIV_2+0                      ; Salva Divisore in ZP
      stx DIV_2+1

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      ora DIV_2+1                      ; Verifica divisore nullo
      beq .Exit_SDIV_32X16_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      ora DIV_1+3
      beq .Exit_SDIV_32X16_Zero_Dividend

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda DIV_1+3
      eor DIV_2+1                      ; Bit 7 = Segno del Quoziente
      pha                              ; Salva segno quoziente

      lda DIV_1+3                      ; Bit 7 = Segno del Resto
      pha                              ; Salva segno resto

      lda DIV_1+3                      ; Normalizza Dividendo (|DIV_1|) a 32 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 32 bit: 0 - DIV_1
      lda #0
      sbc DIV_1+0
      sta DIV_1+0

      lda #0
      sbc DIV_1+1
      sta DIV_1+1

      lda #0
      sbc DIV_1+2
      sta DIV_1+2

      lda #0
      sbc DIV_1+3
      sta DIV_1+3

    @A_Is_Positive:
      lda DIV_2+1                      ; Normalizza Divisore (|DIV_2|) a 16 bit
      bpl @B_Is_Positive

      sec                              ; Negazione 16 bit: 0 - DIV_2
      lda #0
      sbc DIV_2+0
      sta DIV_2+0

      lda #0
      sbc DIV_2+1
      sta DIV_2+1

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_32x16

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Resto
      bpl @Check_Quotient_Sign

      sec                              ; Inverte segno Resto 16 bit (0 - DIV_REM)
      lda #0
      sbc DIV_REM+0
      sta DIV_REM+0

      lda #0
      sbc DIV_REM+1
      sta DIV_REM+1

    @Check_Quotient_Sign:
      pla                              ; Recupera segno Quoziente
      bpl .Exit_SDIV_32X16_Success

      sec                              ; Inverte segno Quoziente 32 bit (0 - DIV_QUOT)
      lda #0
      sbc DIV_QUOT+0
      sta DIV_QUOT+0

      lda #0
      sbc DIV_QUOT+1
      sta DIV_QUOT+1

      lda #0
      sbc DIV_QUOT+2
      sta DIV_QUOT+2

      lda #0
      sbc DIV_QUOT+3
      sta DIV_QUOT+3

    .Exit_SDIV_32X16_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente Byte 1
      ldy DIV_QUOT+2                   ; .Y = Quoziente Byte 2
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_32X16_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_QUOT+3
      sta DIV_REM+0                    ; Resto = 0
      sta DIV_REM+1
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_32X16_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

; ==============================================================================
; SECTION 9: SUBROUTINE PER LA FAMIGLIA 24X24
; ==============================================================================

!ifdef __USE_DIV_24X24 {
  ; ==============================================================================
  ; SUBROUTINE: DIV_24X24 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra zwei interi a 24 bit senza segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP) : Dividendo (24 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Divisore LSB (8 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Divisore MID (8 bit unsigned)
  ;   - .Y                   (1 byte, CPU) : Divisore MSB (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente MID
  ;   - .Y                   (1 byte, CPU) : Quoziente MSB
  ;   - DIV_QUOT+0 .. DIV_QUOT+2          : Quoziente a 24 bit in ZP
  ;   - DIV_REM+0 .. DIV_REM+2            : Resto a 24 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Div_24x24

    DIV_24X24:
      sta DIV_2+0                      ; Salva Divisore in ZP
      stx DIV_2+1
      sty DIV_2+2

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      ora DIV_2+1                      ; Verifica divisore nullo
      ora DIV_2+2
      beq .Exit_DIV_24X24_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      beq .Exit_DIV_24X24_Zero_Dividend

      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_24x24

    .Exit_DIV_24X24_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente MID
      ldy DIV_QUOT+2                   ; .Y = Quoziente MSB
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_24X24_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_REM+0                    ; Resto = 0
      sta DIV_REM+1
      sta DIV_REM+2
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_24X24_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

!ifdef __USE_SDIV_24X24 {
  ; ==============================================================================
  ; SUBROUTINE: SDIV_24X24 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra due interi a 24 bit con segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP) : Dividendo (24 bit signed)
  ;   - .A                   (1 byte, CPU) : Divisore LSB (8 bit signed)
  ;   - .X                   (1 byte, CPU) : Divisore MID (8 bit signed)
  ;   - .Y                   (1 byte, CPU) : Divisore MSB (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente MID
  ;   - .Y                   (1 byte, CPU) : Quoziente MSB
  ;   - DIV_QUOT+0 .. DIV_QUOT+2          : Quoziente a 24 bit in ZP
  ;   - DIV_REM+0 .. DIV_REM+2            : Resto a 24 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Sdiv_24x24

    SDIV_24X24:
      sta DIV_2+0                      ; Salva Divisore in ZP
      stx DIV_2+1
      sty DIV_2+2

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      ora DIV_2+1                      ; Verifica divisore nullo
      ora DIV_2+2
      beq .Exit_SDIV_24X24_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      beq .Exit_SDIV_24X24_Zero_Dividend

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda DIV_1+2
      eor DIV_2+2                      ; Bit 7 = Segno del Quoziente
      pha                              ; Salva segno quoziente

      lda DIV_1+2                      ; Bit 7 = Segno del Resto
      pha                              ; Salva segno resto

      lda DIV_1+2                      ; Normalizza Dividendo (|DIV_1|) a 24 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 24 bit: 0 - DIV_1
      lda #0
      sbc DIV_1+0
      sta DIV_1+0

      lda #0
      sbc DIV_1+1
      sta DIV_1+1

      lda #0
      sbc DIV_1+2
      sta DIV_1+2

    @A_Is_Positive:
      lda DIV_2+2                      ; Normalizza Divisore (|DIV_2|) a 24 bit
      bpl @B_Is_Positive

      sec                              ; Negazione 24 bit: 0 - DIV_2
      lda #0
      sbc DIV_2+0
      sta DIV_2+0

      lda #0
      sbc DIV_2+1
      sta DIV_2+1

      lda #0
      sbc DIV_2+2
      sta DIV_2+2

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_24x24

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Resto
      bpl @Check_Quotient_Sign

      sec                              ; Inverte segno Resto 24 bit (0 - DIV_REM)
      lda #0
      sbc DIV_REM+0
      sta DIV_REM+0

      lda #0
      sbc DIV_REM+1
      sta DIV_REM+1

      lda #0
      sbc DIV_REM+2
      sta DIV_REM+2

    @Check_Quotient_Sign:
      pla                              ; Recupera segno Quoziente
      bpl .Exit_SDIV_24X24_Success

      sec                              ; Inverte segno Quoziente 24 bit (0 - DIV_QUOT)
      lda #0
      sbc DIV_QUOT+0
      sta DIV_QUOT+0

      lda #0
      sbc DIV_QUOT+1
      sta DIV_QUOT+1

      lda #0
      sbc DIV_QUOT+2
      sta DIV_QUOT+2

    .Exit_SDIV_24X24_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente MID
      ldy DIV_QUOT+2                   ; .Y = Quoziente MSB
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_24X24_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_REM+0                    ; Resto = 0
      sta DIV_REM+1
      sta DIV_REM+2
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_24X24_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

; ==============================================================================
; SECTION 10: SUBROUTINE PER LA FAMIGLIA 32X24
; ==============================================================================

!ifdef __USE_DIV_32X24 {
  ; ==============================================================================
  ; SUBROUTINE: DIV_32X24 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra un intero a 32 bit e uno a 24 bit senza segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP) : Dividendo (32 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Divisore LSB (8 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Divisore MID (8 bit unsigned)
  ;   - .Y                   (1 byte, CPU) : Divisore MSB (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente Byte 1
  ;   - .Y                   (1 byte, CPU) : Quoziente Byte 2
  ;   - DIV_QUOT+0 .. DIV_QUOT+3          : Quoziente a 32 bit in ZP
  ;   - DIV_REM+0 .. DIV_REM+2            : Resto a 24 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Div_32x24

    DIV_32X24:
      sta DIV_2+0                      ; Salva Divisore in ZP
      stx DIV_2+1
      sty DIV_2+2

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      ora DIV_2+1                      ; Verifica divisore nullo
      ora DIV_2+2
      beq .Exit_DIV_32X24_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      ora DIV_1+3
      beq .Exit_DIV_32X24_Zero_Dividend

      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_32x24

    .Exit_DIV_32X24_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente Byte 1
      ldy DIV_QUOT+2                   ; .Y = Quoziente Byte 2
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_32X24_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_QUOT+3
      sta DIV_REM+0                    ; Resto = 0
      sta DIV_REM+1
      sta DIV_REM+2
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_32X24_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

!ifdef __USE_SDIV_32X24 {
  ; ==============================================================================
  ; SUBROUTINE: SDIV_32X24 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra un intero a 32 bit e uno a 24 bit con segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP) : Dividendo (32 bit signed)
  ;   - .A                   (1 byte, CPU) : Divisore LSB (8 bit signed)
  ;   - .X                   (1 byte, CPU) : Divisore MID (8 bit signed)
  ;   - .Y                   (1 byte, CPU) : Divisore MSB (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente Byte 1
  ;   - .Y                   (1 byte, CPU) : Quoziente Byte 2
  ;   - DIV_QUOT+0 .. DIV_QUOT+3          : Quoziente a 32 bit in ZP
  ;   - DIV_REM+0 .. DIV_REM+2            : Resto a 24 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Sdiv_32x24

    SDIV_32X24:
      sta DIV_2+0                      ; Salva Divisore in ZP
      stx DIV_2+1
      sty DIV_2+2

      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      ora DIV_2+1                      ; Verifica divisore nullo
      ora DIV_2+2
      beq .Exit_SDIV_32X24_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      ora DIV_1+3
      beq .Exit_SDIV_32X24_Zero_Dividend

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda DIV_1+3
      eor DIV_2+2                      ; Bit 7 = Segno del Quoziente
      pha                              ; Salva segno quoziente

      lda DIV_1+3                      ; Bit 7 = Segno del Resto
      pha                              ; Salva segno resto

      lda DIV_1+3                      ; Normalizza Dividendo (|DIV_1|) a 32 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 32 bit: 0 - DIV_1
      lda #0
      sbc DIV_1+0
      sta DIV_1+0

      lda #0
      sbc DIV_1+1
      sta DIV_1+1

      lda #0
      sbc DIV_1+2
      sta DIV_1+2

      lda #0
      sbc DIV_1+3
      sta DIV_1+3

    @A_Is_Positive:
      lda DIV_2+2                      ; Normalizza Divisore (|DIV_2|) a 24 bit
      bpl @B_Is_Positive

      sec                              ; Negazione 24 bit: 0 - DIV_2
      lda #0
      sbc DIV_2+0
      sta DIV_2+0

      lda #0
      sbc DIV_2+1
      sta DIV_2+1

      lda #0
      sbc DIV_2+2
      sta DIV_2+2

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_32x24

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Resto
      bpl @Check_Quotient_Sign

      sec                              ; Inverte segno Resto 24 bit (0 - DIV_REM)
      lda #0
      sbc DIV_REM+0
      sta DIV_REM+0

      lda #0
      sbc DIV_REM+1
      sta DIV_REM+1

      lda #0
      sbc DIV_REM+2
      sta DIV_REM+2

    @Check_Quotient_Sign:
      pla                              ; Recupera segno Quoziente
      bpl .Exit_SDIV_32X24_Success

      sec                              ; Inverte segno Quoziente 32 bit (0 - DIV_QUOT)
      lda #0
      sbc DIV_QUOT+0
      sta DIV_QUOT+0

      lda #0
      sbc DIV_QUOT+1
      sta DIV_QUOT+1

      lda #0
      sbc DIV_QUOT+2
      sta DIV_QUOT+2

      lda #0
      sbc DIV_QUOT+3
      sta DIV_QUOT+3

    .Exit_SDIV_32X24_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente Byte 1
      ldy DIV_QUOT+2                   ; .Y = Quoziente Byte 2
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_32X24_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_QUOT+3
      sta DIV_REM+0                    ; Resto = 0
      sta DIV_REM+1
      sta DIV_REM+2
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_32X24_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

; ==============================================================================
; SECTION 11: SUBROUTINE PER LA FAMIGLIA 32X32
; ==============================================================================

!ifdef __USE_DIV_32X32 {
  ; ==============================================================================
  ; SUBROUTINE: DIV_32X32 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra due interi a 32 bit senza segno.
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP) : Dividendo (32 bit unsigned)
  ;   - DIV_2+0 .. DIV_2+3 (4 byte, ZP) : Divisore (32 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente Byte 1
  ;   - .Y                   (1 byte, CPU) : Quoziente Byte 2
  ;   - DIV_QUOT+0 .. DIV_QUOT+3          : Quoziente a 32 bit in ZP
  ;   - DIV_REM+0 .. DIV_REM+3            : Resto a 32 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Div_32x32

    DIV_32X32:
      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      lda DIV_2+0                      ; Verifica divisore nullo
      ora DIV_2+1
      ora DIV_2+2
      ora DIV_2+3
      beq .Exit_DIV_32X32_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      ora DIV_1+3
      beq .Exit_DIV_32X32_Zero_Dividend

      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_32x32

    .Exit_DIV_32X32_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente Byte 1
      ldy DIV_QUOT+2                   ; .Y = Quoziente Byte 2
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_32X32_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_QUOT+3
      sta DIV_REM+0                    ; Resto = 0
      sta DIV_REM+1
      sta DIV_REM+2
      sta DIV_REM+3
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_DIV_32X32_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

!ifdef __USE_SDIV_32X32 {
  ; ==============================================================================
  ; SUBROUTINE: SDIV_32X32 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Divisione tra due interi a 32 bit con segno (complemento a 2).
  ;
  ; Input:
  ;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP) : Dividendo (32 bit signed)
  ;   - DIV_2+0 .. DIV_2+3 (4 byte, ZP) : Divisore (32 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Quoziente LSB o ERR_DIVISION_BY_ZERO
  ;   - .X                   (1 byte, CPU) : Quoziente Byte 1
  ;   - .Y                   (1 byte, CPU) : Quoziente Byte 2
  ;   - DIV_QUOT+0 .. DIV_QUOT+3          : Quoziente a 32 bit in ZP
  ;   - DIV_REM+0 .. DIV_REM+3            : Resto a 32 bit in ZP
  ;   - Flag Carry (.P)                   : 0 = Successo, 1 = Divisione per zero
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Sdiv_32x32

    SDIV_32X32:
      ; --- PREAMBOLO: CONTROLLO CORNER CASES ---
      lda DIV_2+0                      ; Verifica divisore nullo
      ora DIV_2+1
      ora DIV_2+2
      ora DIV_2+3
      beq .Exit_SDIV_32X32_Div_Zero

      lda DIV_1+0                      ; Verifica dividendo nullo
      ora DIV_1+1
      ora DIV_1+2
      ora DIV_1+3
      beq .Exit_SDIV_32X32_Zero_Dividend

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda DIV_1+3
      eor DIV_2+3                      ; Bit 7 = Segno del Quoziente
      pha                              ; Salva segno quoziente

      lda DIV_1+3                      ; Bit 7 = Segno del Resto
      pha                              ; Salva segno resto

      lda DIV_1+3                      ; Normalizza Dividendo (|DIV_1|) a 32 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 32 bit: 0 - DIV_1
      lda #0
      sbc DIV_1+0
      sta DIV_1+0

      lda #0
      sbc DIV_1+1
      sta DIV_1+1

      lda #0
      sbc DIV_1+2
      sta DIV_1+2

      lda #0
      sbc DIV_1+3
      sta DIV_1+3

    @A_Is_Positive:
      lda DIV_2+3                      ; Normalizza Divisore (|DIV_2|) a 32 bit
      bpl @B_Is_Positive

      sec                              ; Negazione 32 bit: 0 - DIV_2
      lda #0
      sbc DIV_2+0
      sta DIV_2+0

      lda #0
      sbc DIV_2+1
      sta DIV_2+1

      lda #0
      sbc DIV_2+2
      sta DIV_2+2

      lda #0
      sbc DIV_2+3
      sta DIV_2+3

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Div_Core_32x32

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Resto
      bpl @Check_Quotient_Sign

      sec                              ; Inverte segno Resto 32 bit (0 - DIV_REM)
      lda #0
      sbc DIV_REM+0
      sta DIV_REM+0

      lda #0
      sbc DIV_REM+1
      sta DIV_REM+1

      lda #0
      sbc DIV_REM+2
      sta DIV_REM+2

      lda #0
      sbc DIV_REM+3
      sta DIV_REM+3

    @Check_Quotient_Sign:
      pla                              ; Recupera segno Quoziente
      bpl .Exit_SDIV_32X32_Success

      sec                              ; Inverte segno Quoziente 32 bit (0 - DIV_QUOT)
      lda #0
      sbc DIV_QUOT+0
      sta DIV_QUOT+0

      lda #0
      sbc DIV_QUOT+1
      sta DIV_QUOT+1

      lda #0
      sbc DIV_QUOT+2
      sta DIV_QUOT+2

      lda #0
      sbc DIV_QUOT+3
      sta DIV_QUOT+3

    .Exit_SDIV_32X32_Success:
      lda DIV_QUOT+0                   ; .A = Quoziente LSB
      ldx DIV_QUOT+1                   ; .X = Quoziente Byte 1
      ldy DIV_QUOT+2                   ; .Y = Quoziente Byte 2
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_32X32_Zero_Dividend:
      sta DIV_QUOT+0                   ; Quoziente = 0
      sta DIV_QUOT+1
      sta DIV_QUOT+2
      sta DIV_QUOT+3
      sta DIV_REM+0                    ; Resto = 0
      sta DIV_REM+1
      sta DIV_REM+2
      sta DIV_REM+3
      tax                              ; .X = 0
      tay                              ; .Y = 0
      clc                              ; Successo: Carry = 0
      rts

    .Exit_SDIV_32X32_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO
      sec                              ; Errore: Carry = 1
      rts

  !zone
}

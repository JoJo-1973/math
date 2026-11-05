; ==============================================================================
; FILE:           math_mult.asm
; PROGETTO:       Libreria Matematica (math)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Nuclei aritmetici (macro) e subroutine per la moltiplicazione
;                 intera unsigned e signed (Shift-and-Add) a 8, 16, 24 e 32 bit.
; DIPENDENZE:     <c64/symbols.asm>, once, <c64/errors.asm>, once
; REQUISITI ZP:   MUL_1, MUL_2, MUL_RES, WORK_RES
; ==============================================================================

; ------------------------------------------------------------------------------
; INCLUSIONE DIPENDENZE ESTERNE
; ------------------------------------------------------------------------------
!source <c64/symbols.asm>, once
!source <c64/errors.asm>, once

; ==============================================================================
; SECTION 0: SIMBOLI GLOBALI DI ZP
; ==============================================================================

MUL_1               = NUMWRK          ; Moltiplicatore (In, fino a 32 bit)
MUL_2               = NUMWRK+4        ; Moltiplicando (In, fino a 32 bit)
MUL_RES             = NUMWRK+8        ; Risultato (Out, fino a 64 bit)
WORK_RES            = NUMWRK+16       ; Accumulatore temporaneo lavoro (32 bit)

; ==============================================================================
; SECTION 1: NUCLEI ARITMETICI (MACRO)
; ==============================================================================

; ==============================================================================
; MACRO: m_Mul_Core_8x8
; ------------------------------------------------------------------------------
; Descrizione: Shift-and-Add per moltiplicatore e moltiplicando a 8 bit.
;
; Input:
;   - MUL_1+0              (1 byte, ZP) : Moltiplicatore (8 bit)
;   - MUL_2+0              (1 byte, ZP) : Moltiplicando (8 bit)
;
; Output:
;   - MUL_RES+0 .. MUL_RES+1 (2 byte, ZP): Risultato a 16 bit
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_8x8 {
    lda #0
    sta MUL_RES+1                      ; MSB risultato parziale a 0

    ldx #8                             ; 8 iterazioni

  .Loop_Mul:
    lsr MUL_1                          ; Shift a destra del moltiplicatore
    bcc @Skip_Add

    clc
    lda MUL_RES+1
    adc MUL_2                          ; Somma moltiplicando al byte MSB
    sta MUL_RES+1

  @Skip_Add:
    ror MUL_RES+1                      ; Shift combinato MSB -> LSB
    ror MUL_RES+0
    dex
    bne .Loop_Mul
}

; ==============================================================================
; MACRO: m_Mul_Core_16x8
; ------------------------------------------------------------------------------
; Descrizione: Shift-and-Add per moltiplicatore a 16 bit e moltiplicando a 8 bit.
;
; Input:
;   - MUL_1+0 .. MUL_1+1   (2 byte, ZP) : Moltiplicatore (16 bit)
;   - MUL_2+0              (1 byte, ZP) : Moltiplicando (8 bit)
;
; Output:
;   - MUL_RES+0 .. MUL_RES+2 (3 byte, ZP): Risultato a 24 bit
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_16x8 {
    lda #0
    sta MUL_RES+0                      ; Inizializza risultato a 24 bit
    sta MUL_RES+1
    sta MUL_RES+2

    ldx #16                            ; 16 iterazioni

  .Loop_Mul:
    lsr MUL_1+1                        ; Shift a destra del moltiplicatore
    ror MUL_1+0
    bcc @Skip_Add

    clc
    lda MUL_RES+0
    adc MUL_2+0
    sta MUL_RES+0

    lda MUL_RES+1
    adc #0
    sta MUL_RES+1

    lda MUL_RES+2
    adc #0
    sta MUL_RES+2

  @Skip_Add:
    asl MUL_2+0                        ; Shift a sinistra del moltiplicando
    dex
    bne .Loop_Mul
}

; ==============================================================================
; MACRO: m_Mul_Core_24x8
; ------------------------------------------------------------------------------
; Descrizione: Shift-and-Add per moltiplicatore a 24 bit e moltiplicando a 8 bit.
;
; Input:
;   - MUL_1+0 .. MUL_1+2   (3 byte, ZP) : Moltiplicatore (24 bit)
;   - MUL_2+0              (1 byte, ZP) : Moltiplicando (8 bit)
;
; Output:
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP): Risultato a 32 bit
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_24x8 {
    lda #0
    sta WORK_RES+0
    sta WORK_RES+1
    sta WORK_RES+2
    sta WORK_RES+3

    ldx #24                            ; 24 iterazioni

  .Loop_Mul:
    lsr MUL_1+2                        ; Shift a destra del moltiplicatore
    ror MUL_1+1
    ror MUL_1+0
    bcc @Skip_Add

    clc
    lda WORK_RES+0
    adc MUL_2+0
    sta WORK_RES+0

    lda WORK_RES+1
    adc #0
    sta WORK_RES+1

    lda WORK_RES+2
    adc #0
    sta WORK_RES+2

    lda WORK_RES+3
    adc #0
    sta WORK_RES+3

  @Skip_Add:
    asl MUL_2+0                        ; Shift a sinistra del moltiplicando
    dex
    bne .Loop_Mul

    lda WORK_RES+0
    sta MUL_RES+0
    lda WORK_RES+1
    sta MUL_RES+1
    lda WORK_RES+2
    sta MUL_RES+2
    lda WORK_RES+3
    sta MUL_RES+3
}

; ==============================================================================
; MACRO: m_Mul_Core_32x8
; ------------------------------------------------------------------------------
; Descrizione: Shift-and-Add per moltiplicatore a 32 bit e moltiplicando a 8 bit.
;
; Input:
;   - MUL_1+0 .. MUL_1+3   (4 byte, ZP) : Moltiplicatore (32 bit)
;   - MUL_2+0              (1 byte, ZP) : Moltiplicando (8 bit)
;
; Output:
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP): Risultato LSB a 32 bit
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_32x8 {
    lda #0
    sta WORK_RES+0
    sta WORK_RES+1
    sta WORK_RES+2
    sta WORK_RES+3

    ldx #32                            ; 32 iterazioni

  .Loop_Mul:
    lsr MUL_1+3                        ; Shift a destra del moltiplicatore
    ror MUL_1+2
    ror MUL_1+1
    ror MUL_1+0
    bcc @Skip_Add

    clc
    lda WORK_RES+0
    adc MUL_2+0
    sta WORK_RES+0

    lda WORK_RES+1
    adc #0
    sta WORK_RES+1

    lda WORK_RES+2
    adc #0
    sta WORK_RES+2

    lda WORK_RES+3
    adc #0
    sta WORK_RES+3

  @Skip_Add:
    asl MUL_2+0                        ; Shift a sinistra del moltiplicando
    dex
    bne .Loop_Mul

    lda WORK_RES+0
    sta MUL_RES+0
    lda WORK_RES+1
    sta MUL_RES+1
    lda WORK_RES+2
    sta MUL_RES+2
    lda WORK_RES+3
    sta MUL_RES+3
}

; ==============================================================================
; MACRO: m_Mul_Core_16x16
; ------------------------------------------------------------------------------
; Descrizione: Shift-and-Add per moltiplicatore e moltiplicando a 16 bit.
;
; Input:
;   - MUL_1+0 .. MUL_1+1   (2 byte, ZP) : Moltiplicatore (16 bit)
;   - MUL_2+0 .. MUL_2+1   (2 byte, ZP) : Moltiplicando (16 bit)
;
; Output:
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP): Risultato a 32 bit
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_16x16 {
    lda #0
    sta MUL_RES+0                      ; Inizializza risultato a 32 bit
    sta MUL_RES+1
    sta MUL_RES+2
    sta MUL_RES+3

    ldx #16                            ; 16 iterazioni

  .Loop_Mul:
    lsr MUL_1+1                        ; Shift a destra del moltiplicatore
    ror MUL_1+0
    bcc @Skip_Add

    clc
    lda MUL_RES+0
    adc MUL_2+0
    sta MUL_RES+0

    lda MUL_RES+1
    adc MUL_2+1
    sta MUL_RES+1

    lda MUL_RES+2
    adc #0
    sta MUL_RES+2

    lda MUL_RES+3
    adc #0
    sta MUL_RES+3

  @Skip_Add:
    asl MUL_2+0                        ; Shift a sinistra del moltiplicando
    rol MUL_2+1
    dex
    bne .Loop_Mul
}

; ==============================================================================
; MACRO: m_Mul_Core_24x16
; ------------------------------------------------------------------------------
; Descrizione: Shift-and-Add per moltiplicatore a 24 bit e moltiplicando a 16 bit.
;
; Input:
;   - MUL_1+0 .. MUL_1+2   (3 byte, ZP) : Moltiplicatore (24 bit)
;   - MUL_2+0 .. MUL_2+1   (2 byte, ZP) : Moltiplicando (16 bit)
;
; Output:
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP): Risultato a 32 bit
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_24x16 {
    lda #0
    sta WORK_RES+0
    sta WORK_RES+1
    sta WORK_RES+2
    sta WORK_RES+3

    ldx #24                            ; 24 iterazioni

  .Loop_Mul:
    lsr MUL_1+2                        ; Shift a destra del moltiplicatore
    ror MUL_1+1
    ror MUL_1+0
    bcc @Skip_Add

    clc
    lda WORK_RES+0
    adc MUL_2+0
    sta WORK_RES+0

    lda WORK_RES+1
    adc MUL_2+1
    sta WORK_RES+1

    lda WORK_RES+2
    adc #0
    sta WORK_RES+2

    lda WORK_RES+3
    adc #0
    sta WORK_RES+3

  @Skip_Add:
    asl MUL_2+0                        ; Shift a sinistra del moltiplicando
    rol MUL_2+1

    dex
    bne .Loop_Mul

    lda WORK_RES+0
    sta MUL_RES+0
    lda WORK_RES+1
    sta MUL_RES+1
    lda WORK_RES+2
    sta MUL_RES+2
    lda WORK_RES+3
    sta MUL_RES+3
}

; ==============================================================================
; MACRO: m_Mul_Core_32x16
; ------------------------------------------------------------------------------
; Descrizione: Shift-and-Add per moltiplicatore a 32 bit e moltiplicando a 16 bit.
;
; Input:
;   - MUL_1+0 .. MUL_1+3   (4 byte, ZP) : Moltiplicatore (32 bit)
;   - MUL_2+0 .. MUL_2+1   (2 byte, ZP) : Moltiplicando (16 bit)
;
; Output:
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP): Risultato a 32 bit
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_32x16 {
    lda #0
    sta WORK_RES+0
    sta WORK_RES+1
    sta WORK_RES+2
    sta WORK_RES+3

    ldx #32                            ; 32 iterazioni

  .Loop_Mul:
    lsr MUL_1+3                        ; Shift a destra del moltiplicatore
    ror MUL_1+2
    ror MUL_1+1
    ror MUL_1+0
    bcc @Skip_Add

    clc
    lda WORK_RES+0
    adc MUL_2+0
    sta WORK_RES+0

    lda WORK_RES+1
    adc MUL_2+1
    sta WORK_RES+1

    lda WORK_RES+2
    adc #0
    sta WORK_RES+2

    lda WORK_RES+3
    adc #0
    sta WORK_RES+3

  @Skip_Add:
    asl MUL_2+0                        ; Shift a sinistra del moltiplicando
    rol MUL_2+1

    dex
    bne .Loop_Mul

    lda WORK_RES+0
    sta MUL_RES+0
    lda WORK_RES+1
    sta MUL_RES+1
    lda WORK_RES+2
    sta MUL_RES+2
    lda WORK_RES+3
    sta MUL_RES+3
}

; ==============================================================================
; MACRO: m_Mul_Core_24x24
; ------------------------------------------------------------------------------
; Descrizione: Shift-and-Add per moltiplicatore e moltiplicando a 24 bit.
;
; Input:
;   - MUL_1+0 .. MUL_1+2   (3 byte, ZP) : Moltiplicatore (24 bit)
;   - MUL_2+0 .. MUL_2+2   (3 byte, ZP) : Moltiplicando (24 bit)
;
; Output:
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP): Risultato LSB a 32 bit
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_24x24 {
    lda #0
    sta WORK_RES+0
    sta WORK_RES+1
    sta WORK_RES+2
    sta WORK_RES+3

    ldx #24                            ; 24 iterazioni

  .Loop_Mul:
    lsr MUL_1+2                        ; Shift a destra del moltiplicatore
    ror MUL_1+1
    ror MUL_1+0
    bcc @Skip_Add

    clc
    lda WORK_RES+0
    adc MUL_2+0
    sta WORK_RES+0

    lda WORK_RES+1
    adc MUL_2+1
    sta WORK_RES+1

    lda WORK_RES+2
    adc MUL_2+2
    sta WORK_RES+2

    lda WORK_RES+3
    adc #0
    sta WORK_RES+3

  @Skip_Add:
    asl MUL_2+0                        ; Shift a sinistra del moltiplicando
    rol MUL_2+1
    rol MUL_2+2

    dex
    bne .Loop_Mul

    lda WORK_RES+0
    sta MUL_RES+0
    lda WORK_RES+1
    sta MUL_RES+1
    lda WORK_RES+2
    sta MUL_RES+2
    lda WORK_RES+3
    sta MUL_RES+3
}

; ==============================================================================
; MACRO: m_Mul_Core_32x24
; ------------------------------------------------------------------------------
; Descrizione: Shift-and-Add per moltiplicatore a 32 bit e moltiplicando a 24 bit.
;
; Input:
;   - MUL_1+0 .. MUL_1+3   (4 byte, ZP) : Moltiplicatore (32 bit)
;   - MUL_2+0 .. MUL_2+2   (3 byte, ZP) : Moltiplicando (24 bit)
;
; Output:
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP): Risultato LSB a 32 bit
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_32x24 {
    lda #0
    sta WORK_RES+0
    sta WORK_RES+1
    sta WORK_RES+2
    sta WORK_RES+3

    ldx #32                            ; 32 iterazioni

  .Loop_Mul:
    lsr MUL_1+3                        ; Shift a destra del moltiplicatore
    ror MUL_1+2
    ror MUL_1+1
    ror MUL_1+0
    bcc @Skip_Add

    clc
    lda WORK_RES+0
    adc MUL_2+0
    sta WORK_RES+0

    lda WORK_RES+1
    adc MUL_2+1
    sta WORK_RES+1

    lda WORK_RES+2
    adc MUL_2+2
    sta WORK_RES+2

    lda WORK_RES+3
    adc #0
    sta WORK_RES+3

  @Skip_Add:
    asl MUL_2+0                        ; Shift a sinistra del moltiplicando
    rol MUL_2+1
    rol MUL_2+2

    dex
    bne .Loop_Mul

    lda WORK_RES+0
    sta MUL_RES+0
    lda WORK_RES+1
    sta MUL_RES+1
    lda WORK_RES+2
    sta MUL_RES+2
    lda WORK_RES+3
    sta MUL_RES+3
}

; ==============================================================================
; MACRO: m_Mul_Core_32x32
; ------------------------------------------------------------------------------
; Descrizione: Shift-and-Add per moltiplicatore e moltiplicando a 32 bit.
;
; Input:
;   - MUL_1+0 .. MUL_1+3   (4 byte, ZP) : Moltiplicatore (32 bit)
;   - MUL_2+0 .. MUL_2+3   (4 byte, ZP) : Moltiplicando (32 bit)
;
; Output:
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP): Risultato LSB a 32 bit
;
; Variazione Stack (.S):
;   - Stabile (0 byte)
;
; Registri Modificati: .A, .X, .P
; Dipendenze Esterne:  <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_32x32 {
    lda #0
    sta WORK_RES+0                     ; Inizializza accumulatore temporaneo
    sta WORK_RES+1
    sta WORK_RES+2
    sta WORK_RES+3

    ldx #32                            ; 32 iterazioni

  .Loop_Mul:
    lsr MUL_1+3                        ; Shift a destra del moltiplicatore
    ror MUL_1+2
    ror MUL_1+1
    ror MUL_1+0
    bcc @Skip_Add

    clc
    lda WORK_RES+0
    adc MUL_2+0
    sta WORK_RES+0

    lda WORK_RES+1
    adc MUL_2+1
    sta WORK_RES+1

    lda WORK_RES+2
    adc MUL_2+2
    sta WORK_RES+2

    lda WORK_RES+3
    adc MUL_2+3
    sta WORK_RES+3

  @Skip_Add:
    asl MUL_2+0                        ; Shift a sinistra del moltiplicando
    rol MUL_2+1
    rol MUL_2+2
    rol MUL_2+3

    dex
    bne .Loop_Mul

    lda WORK_RES+0                     ; Copia il risultato finale in MUL_RES
    sta MUL_RES+0

    lda WORK_RES+1
    sta MUL_RES+1

    lda WORK_RES+2
    sta MUL_RES+2

    lda WORK_RES+3
    sta MUL_RES+3
}

; ==============================================================================
; SECTION 2: SUBROUTINE PER LA FAMIGLIA 8X8
; ==============================================================================

!ifdef __USE_MUL_8X8 {
  ; ==============================================================================
  ; SUBROUTINE: MUL_8X8 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra due interi ad 8 bit senza segno.
  ;
  ; Input:
  ;   - .A                   (1 byte, CPU) : Moltiplicatore (8 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Moltiplicando (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato MSB (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+1            : Risultato a 16 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Mul_8x8

    MUL_8X8:
      sta MUL_1+0                      ; Salva Moltiplicatore in ZP
      stx MUL_2+0                      ; Salva Moltiplicando in ZP

      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_8x8

    .Exit_MUL_8X8_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato MSB
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

!ifdef __USE_SMUL_8X8 {
  ; ==============================================================================
  ; SUBROUTINE: SMUL_8X8 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra due interi ad 8 bit con segno.
  ;
  ; Input:
  ;   - .A                   (1 byte, CPU) : Moltiplicatore (8 bit signed)
  ;   - .X                   (1 byte, CPU) : Moltiplicando (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato MSB (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+1            : Risultato a 16 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Smul_8x8

    SMUL_8X8:
      sta MUL_1+0                      ; Salva Moltiplicatore in ZP
      stx MUL_2+0                      ; Salva Moltiplicando in ZP

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda MUL_1+0
      eor MUL_2+0                      ; Bit 7 = Segno del Risultato
      pha                              ; Salva segno risultato

      lda MUL_1+0                      ; Normalizza Moltiplicatore (|MUL_1|)
      bpl @A_Is_Positive
      eor #$FF                         ; Complemento a 2 a 8 bit
      clc
      adc #1
      sta MUL_1+0

    @A_Is_Positive:
      lda MUL_2+0                      ; Normalizza Moltiplicando (|MUL_2|)
      bpl @B_Is_Positive
      eor #$FF                         ; Complemento a 2 a 8 bit
      clc
      adc #1
      sta MUL_2+0

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_8x8

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Risultato
      bpl .Exit_SMUL_8X8_Success

      sec                              ; Inverte segno Risultato 16 bit (0 - MUL_RES)
      lda #0
      sbc MUL_RES+0
      sta MUL_RES+0

      lda #0
      sbc MUL_RES+1
      sta MUL_RES+1

    .Exit_SMUL_8X8_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato MSB
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

; ==============================================================================
; SECTION 3: SUBROUTINE PER LA FAMIGLIA 16X8
; ==============================================================================

!ifdef __USE_MUL_16X8 {
  ; ==============================================================================
  ; SUBROUTINE: MUL_16X8 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra un intero a 16 bit ed uno a 8 bit senza segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+1 (2 byte, ZP) : Moltiplicatore (16 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Moltiplicando (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato MID (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato MSB (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+2            : Risultato a 24 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Mul_16x8

    MUL_16X8:
      stx MUL_2+0                      ; Salva Moltiplicando in ZP

      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_16x8

    .Exit_MUL_16X8_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato MID
      ldy MUL_RES+2                    ; .Y = Risultato MSB
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

!ifdef __USE_SMUL_16X8 {
  ; ==============================================================================
  ; SUBROUTINE: SMUL_16X8 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra un intero a 16 bit ed uno a 8 bit con segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+1 (2 byte, ZP) : Moltiplicatore (16 bit signed)
  ;   - .X                   (1 byte, CPU) : Moltiplicando (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato MID (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato MSB (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+2            : Risultato a 24 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Smul_16x8

    SMUL_16X8:
      stx MUL_2+0                      ; Salva Moltiplicando in ZP

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda MUL_1+1
      eor MUL_2+0                      ; Bit 7 = Segno del Risultato
      pha                              ; Salva segno risultato

      lda MUL_1+1                      ; Normalizza Moltiplicatore (|MUL_1|) a 16 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 16 bit: 0 - MUL_1
      lda #0
      sbc MUL_1+0
      sta MUL_1+0

      lda #0
      sbc MUL_1+1
      sta MUL_1+1

    @A_Is_Positive:
      lda MUL_2+0                      ; Normalizza Moltiplicando (|MUL_2|) a 8 bit
      bpl @B_Is_Positive

      eor #$FF                         ; Complemento a 2 a 8 bit
      clc
      adc #1
      sta MUL_2+0

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_16x8

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Risultato
      bpl .Exit_SMUL_16X8_Success

      sec                              ; Inverte segno Risultato 24 bit (0 - MUL_RES)
      lda #0
      sbc MUL_RES+0
      sta MUL_RES+0

      lda #0
      sbc MUL_RES+1
      sta MUL_RES+1

      lda #0
      sbc MUL_RES+2
      sta MUL_RES+2

    .Exit_SMUL_16X8_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato MID
      ldy MUL_RES+2                    ; .Y = Risultato MSB
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

; ==============================================================================
; SECTION 4: SUBROUTINE PER LA FAMIGLIA 24X8
; ==============================================================================

!ifdef __USE_MUL_24X8 {
  ; ==============================================================================
  ; SUBROUTINE: MUL_24X8 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra un intero a 24 bit ed uno a 8 bit senza segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP) : Moltiplicatore (24 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Moltiplicando (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Mul_24x8

    MUL_24X8:
      stx MUL_2+0                      ; Salva Moltiplicando in ZP

      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_24x8

    .Exit_MUL_24X8_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

!ifdef __USE_SMUL_24X8 {
  ; ==============================================================================
  ; SUBROUTINE: SMUL_24X8 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra un intero a 24 bit ed uno a 8 bit con segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP) : Moltiplicatore (24 bit signed)
  ;   - .X                   (1 byte, CPU) : Moltiplicando (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Smul_24x8

    SMUL_24X8:
      stx MUL_2+0                      ; Salva Moltiplicando in ZP

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda MUL_1+2
      eor MUL_2+0                      ; Bit 7 = Segno del Risultato
      pha                              ; Salva segno risultato

      lda MUL_1+2                      ; Normalizza Moltiplicatore (|MUL_1|) a 24 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 24 bit: 0 - MUL_1
      lda #0
      sbc MUL_1+0
      sta MUL_1+0

      lda #0
      sbc MUL_1+1
      sta MUL_1+1

      lda #0
      sbc MUL_1+2
      sta MUL_1+2

    @A_Is_Positive:
      lda MUL_2+0                      ; Normalizza Moltiplicando (|MUL_2|) a 8 bit
      bpl @B_Is_Positive

      eor #$FF                         ; Complemento a 2 a 8 bit
      clc
      adc #1
      sta MUL_2+0

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_24x8

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Risultato
      bpl .Exit_SMUL_24X8_Success

      sec                              ; Inverte segno Risultato 32 bit (0 - MUL_RES)
      lda #0
      sbc MUL_RES+0
      sta MUL_RES+0

      lda #0
      sbc MUL_RES+1
      sta MUL_RES+1

      lda #0
      sbc MUL_RES+2
      sta MUL_RES+2

      lda #0
      sbc MUL_RES+3
      sta MUL_RES+3

    .Exit_SMUL_24X8_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

; ==============================================================================
; SECTION 5: SUBROUTINE PER LA FAMIGLIA 32X8
; ==============================================================================

!ifdef __USE_MUL_32X8 {
  ; ==============================================================================
  ; SUBROUTINE: MUL_32X8 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra un intero a 32 bit ed uno a 8 bit senza segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP) : Moltiplicatore (32 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Moltiplicando (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Mul_32x8

    MUL_32X8:
      stx MUL_2+0                      ; Salva Moltiplicando in ZP

      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_32x8

    .Exit_MUL_32X8_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

!ifdef __USE_SMUL_32X8 {
  ; ==============================================================================
  ; SUBROUTINE: SMUL_32X8 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra un intero a 32 bit ed uno a 8 bit con segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP) : Moltiplicatore (32 bit signed)
  ;   - .X                   (1 byte, CPU) : Moltiplicando (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Smul_32x8

    SMUL_32X8:
      stx MUL_2+0                      ; Salva Moltiplicando in ZP

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda MUL_1+3
      eor MUL_2+0                      ; Bit 7 = Segno del Risultato
      pha                              ; Salva segno risultato

      lda MUL_1+3                      ; Normalizza Moltiplicatore (|MUL_1|) a 32 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 32 bit: 0 - MUL_1
      lda #0
      sbc MUL_1+0
      sta MUL_1+0

      lda #0
      sbc MUL_1+1
      sta MUL_1+1

      lda #0
      sbc MUL_1+2
      sta MUL_1+2

      lda #0
      sbc MUL_1+3
      sta MUL_1+3

    @A_Is_Positive:
      lda MUL_2+0                      ; Normalizza Moltiplicando (|MUL_2|) a 8 bit
      bpl @B_Is_Positive

      eor #$FF                         ; Complemento a 2 a 8 bit
      clc
      adc #1
      sta MUL_2+0

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_32x8

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Risultato
      bpl .Exit_SMUL_32X8_Success

      sec                              ; Inverte segno Risultato 32 bit (0 - MUL_RES)
      lda #0
      sbc MUL_RES+0
      sta MUL_RES+0

      lda #0
      sbc MUL_RES+1
      sta MUL_RES+1

      lda #0
      sbc MUL_RES+2
      sta MUL_RES+2

      lda #0
      sbc MUL_RES+3
      sta MUL_RES+3

    .Exit_SMUL_32X8_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

; ==============================================================================
; SECTION 6: SUBROUTINE PER LA FAMIGLIA 16X16
; ==============================================================================

!ifdef __USE_MUL_16X16 {
  ; ==============================================================================
  ; SUBROUTINE: MUL_16X16 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra due interi a 16 bit senza segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+1 (2 byte, ZP) : Moltiplicatore (16 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Moltiplicando LSB (8 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Moltiplicando MSB (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Mul_16x16

    MUL_16X16:
      sta MUL_2+0                      ; Salva Moltiplicando in ZP
      stx MUL_2+1

      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_16x16

    .Exit_MUL_16X16_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

!ifdef __USE_SMUL_16X16 {
  ; ==============================================================================
  ; SUBROUTINE: SMUL_16X16 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra due interi a 16 bit con segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+1 (2 byte, ZP) : Moltiplicatore (16 bit signed)
  ;   - .A                   (1 byte, CPU) : Moltiplicando LSB (8 bit signed)
  ;   - .X                   (1 byte, CPU) : Moltiplicando MSB (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Smul_16x16

    SMUL_16X16:
      sta MUL_2+0                      ; Salva Moltiplicando in ZP
      stx MUL_2+1

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda MUL_1+1
      eor MUL_2+1                      ; Bit 7 = Segno del Risultato
      pha                              ; Salva segno risultato

      lda MUL_1+1                      ; Normalizza Moltiplicatore (|MUL_1|) a 16 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 16 bit: 0 - MUL_1
      lda #0
      sbc MUL_1+0
      sta MUL_1+0

      lda #0
      sbc MUL_1+1
      sta MUL_1+1

    @A_Is_Positive:
      lda MUL_2+1                      ; Normalizza Moltiplicando (|MUL_2|) a 16 bit
      bpl @B_Is_Positive

      sec                              ; Negazione 16 bit: 0 - MUL_2
      lda #0
      sbc MUL_2+0
      sta MUL_2+0

      lda #0
      sbc MUL_2+1
      sta MUL_2+1

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_16x16

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Risultato
      bpl .Exit_SMUL_16X16_Success

      sec                              ; Inverte segno Risultato 32 bit (0 - MUL_RES)
      lda #0
      sbc MUL_RES+0
      sta MUL_RES+0

      lda #0
      sbc MUL_RES+1
      sta MUL_RES+1

      lda #0
      sbc MUL_RES+2
      sta MUL_RES+2

      lda #0
      sbc MUL_RES+3
      sta MUL_RES+3

    .Exit_SMUL_16X16_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

; ==============================================================================
; SECTION 7: SUBROUTINE PER LA FAMIGLIA 24X16
; ==============================================================================

!ifdef __USE_MUL_24X16 {
  ; ==============================================================================
  ; SUBROUTINE: MUL_24X16 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra un intero a 24 bit ed uno a 16 bit senza segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP) : Moltiplicatore (24 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Moltiplicando LSB (8 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Moltiplicando MSB (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Mul_24x16

    MUL_24X16:
      sta MUL_2+0                      ; Salva Moltiplicando in ZP
      stx MUL_2+1

      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_24x16

    .Exit_MUL_24X16_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

!ifdef __USE_SMUL_24X16 {
  ; ==============================================================================
  ; SUBROUTINE: SMUL_24X16 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra un intero a 24 bit ed uno a 16 bit con segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP) : Moltiplicatore (24 bit signed)
  ;   - .A                   (1 byte, CPU) : Moltiplicando LSB (8 bit signed)
  ;   - .X                   (1 byte, CPU) : Moltiplicando MSB (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Smul_24x16

    SMUL_24X16:
      sta MUL_2+0                      ; Salva Moltiplicando in ZP
      stx MUL_2+1

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda MUL_1+2
      eor MUL_2+1                      ; Bit 7 = Segno del Risultato
      pha                              ; Salva segno risultato

      lda MUL_1+2                      ; Normalizza Moltiplicatore (|MUL_1|) a 24 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 24 bit: 0 - MUL_1
      lda #0
      sbc MUL_1+0
      sta MUL_1+0

      lda #0
      sbc MUL_1+1
      sta MUL_1+1

      lda #0
      sbc MUL_1+2
      sta MUL_1+2

    @A_Is_Positive:
      lda MUL_2+1                      ; Normalizza Moltiplicando (|MUL_2|) a 16 bit
      bpl @B_Is_Positive

      sec                              ; Negazione 16 bit: 0 - MUL_2
      lda #0
      sbc MUL_2+0
      sta MUL_2+0

      lda #0
      sbc MUL_2+1
      sta MUL_2+1

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_24x16

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Risultato
      bpl .Exit_SMUL_24X16_Success

      sec                              ; Inverte segno Risultato 32 bit (0 - MUL_RES)
      lda #0
      sbc MUL_RES+0
      sta MUL_RES+0

      lda #0
      sbc MUL_RES+1
      sta MUL_RES+1

      lda #0
      sbc MUL_RES+2
      sta MUL_RES+2

      lda #0
      sbc MUL_RES+3
      sta MUL_RES+3

    .Exit_SMUL_24X16_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

; ==============================================================================
; SECTION 8: SUBROUTINE PER LA FAMIGLIA 32X16
; ==============================================================================

!ifdef __USE_MUL_32X16 {
  ; ==============================================================================
  ; SUBROUTINE: MUL_32X16 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra un intero a 32 bit ed uno a 16 bit senza segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP) : Moltiplicatore (32 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Moltiplicando LSB (8 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Moltiplicando MSB (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Mul_32x16

    MUL_32X16:
      sta MUL_2+0                      ; Salva Moltiplicando in ZP
      stx MUL_2+1

      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_32x16

    .Exit_MUL_32X16_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

!ifdef __USE_SMUL_32X16 {
  ; ==============================================================================
  ; SUBROUTINE: SMUL_32X16 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra un intero a 32 bit ed uno a 16 bit con segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP) : Moltiplicatore (32 bit signed)
  ;   - .A                   (1 byte, CPU) : Moltiplicando LSB (8 bit signed)
  ;   - .X                   (1 byte, CPU) : Moltiplicando MSB (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Smul_32x16

    SMUL_32X16:
      sta MUL_2+0                      ; Salva Moltiplicando in ZP
      stx MUL_2+1

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda MUL_1+3
      eor MUL_2+1                      ; Bit 7 = Segno del Risultato
      pha                              ; Salva segno risultato

      lda MUL_1+3                      ; Normalizza Moltiplicatore (|MUL_1|) a 32 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 32 bit: 0 - MUL_1
      lda #0
      sbc MUL_1+0
      sta MUL_1+0

      lda #0
      sbc MUL_1+1
      sta MUL_1+1

      lda #0
      sbc MUL_1+2
      sta MUL_1+2

      lda #0
      sbc MUL_1+3
      sta MUL_1+3

    @A_Is_Positive:
      lda MUL_2+1                      ; Normalizza Moltiplicando (|MUL_2|) a 16 bit
      bpl @B_Is_Positive

      sec                              ; Negazione 16 bit: 0 - MUL_2
      lda #0
      sbc MUL_2+0
      sta MUL_2+0

      lda #0
      sbc MUL_2+1
      sta MUL_2+1

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_32x16

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Risultato
      bpl .Exit_SMUL_32X16_Success

      sec                              ; Inverte segno Risultato 32 bit (0 - MUL_RES)
      lda #0
      sbc MUL_RES+0
      sta MUL_RES+0

      lda #0
      sbc MUL_RES+1
      sta MUL_RES+1

      lda #0
      sbc MUL_RES+2
      sta MUL_RES+2

      lda #0
      sbc MUL_RES+3
      sta MUL_RES+3

    .Exit_SMUL_32X16_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

; ==============================================================================
; SECTION 9: SUBROUTINE PER LA FAMIGLIA 24X24
; ==============================================================================

!ifdef __USE_MUL_24X24 {
  ; ==============================================================================
  ; SUBROUTINE: MUL_24X24 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra due interi a 24 bit senza segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP) : Moltiplicatore (24 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Moltiplicando LSB (8 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Moltiplicando MID (8 bit unsigned)
  ;   - .Y                   (1 byte, CPU) : Moltiplicando MSB (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Mul_24x24

    MUL_24X24:
      sta MUL_2+0                      ; Salva Moltiplicando in ZP
      stx MUL_2+1
      sty MUL_2+2

      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_24x24

    .Exit_MUL_24X24_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

!ifdef __USE_SMUL_24X24 {
  ; ==============================================================================
  ; SUBROUTINE: SMUL_24X24 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra due interi a 24 bit con segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP) : Moltiplicatore (24 bit signed)
  ;   - .A                   (1 byte, CPU) : Moltiplicando LSB (8 bit signed)
  ;   - .X                   (1 byte, CPU) : Moltiplicando MID (8 bit signed)
  ;   - .Y                   (1 byte, CPU) : Moltiplicando MSB (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Smul_24x24

    SMUL_24X24:
      sta MUL_2+0                      ; Salva Moltiplicando in ZP
      stx MUL_2+1
      sty MUL_2+2

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda MUL_1+2
      eor MUL_2+2                      ; Bit 7 = Segno del Risultato
      pha                              ; Salva segno risultato

      lda MUL_1+2                      ; Normalizza Moltiplicatore (|MUL_1|) a 24 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 24 bit: 0 - MUL_1
      lda #0
      sbc MUL_1+0
      sta MUL_1+0

      lda #0
      sbc MUL_1+1
      sta MUL_1+1

      lda #0
      sbc MUL_1+2
      sta MUL_1+2

    @A_Is_Positive:
      lda MUL_2+2                      ; Normalizza Moltiplicando (|MUL_2|) a 24 bit
      bpl @B_Is_Positive

      sec                              ; Negazione 24 bit: 0 - MUL_2
      lda #0
      sbc MUL_2+0
      sta MUL_2+0

      lda #0
      sbc MUL_2+1
      sta MUL_2+1

      lda #0
      sbc MUL_2+2
      sta MUL_2+2

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_24x24

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Risultato
      bpl .Exit_SMUL_24X24_Success

      sec                              ; Inverte segno Risultato 32 bit (0 - MUL_RES)
      lda #0
      sbc MUL_RES+0
      sta MUL_RES+0

      lda #0
      sbc MUL_RES+1
      sta MUL_RES+1

      lda #0
      sbc MUL_RES+2
      sta MUL_RES+2

      lda #0
      sbc MUL_RES+3
      sta MUL_RES+3

    .Exit_SMUL_24X24_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

; ==============================================================================
; SECTION 10: SUBROUTINE PER LA FAMIGLIA 32X24
; ==============================================================================

!ifdef __USE_MUL_32X24 {
  ; ==============================================================================
  ; SUBROUTINE: MUL_32X24 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra un intero a 32 bit ed uno a 24 bit senza segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP) : Moltiplicatore (32 bit unsigned)
  ;   - .A                   (1 byte, CPU) : Moltiplicando LSB (8 bit unsigned)
  ;   - .X                   (1 byte, CPU) : Moltiplicando MID (8 bit unsigned)
  ;   - .Y                   (1 byte, CPU) : Moltiplicando MSB (8 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Mul_32x24

    MUL_32X24:
      sta MUL_2+0                      ; Salva Moltiplicando in ZP
      stx MUL_2+1
      sty MUL_2+2

      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_32x24

    .Exit_MUL_32X24_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

!ifdef __USE_SMUL_32X24 {
  ; ==============================================================================
  ; SUBROUTINE: SMUL_32X24 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra un intero a 32 bit ed uno a 24 bit con segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP) : Moltiplicatore (32 bit signed)
  ;   - .A                   (1 byte, CPU) : Moltiplicando LSB (8 bit signed)
  ;   - .X                   (1 byte, CPU) : Moltiplicando MID (8 bit signed)
  ;   - .Y                   (1 byte, CPU) : Moltiplicando MSB (8 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Smul_32x24

    SMUL_32X24:
      sta MUL_2+0                      ; Salva Moltiplicando in ZP
      stx MUL_2+1
      sty MUL_2+2

      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda MUL_1+3
      eor MUL_2+2                      ; Bit 7 = Segno del Risultato
      pha                              ; Salva segno risultato

      lda MUL_1+3                      ; Normalizza Moltiplicatore (|MUL_1|) a 32 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 32 bit: 0 - MUL_1
      lda #0
      sbc MUL_1+0
      sta MUL_1+0

      lda #0
      sbc MUL_1+1
      sta MUL_1+1

      lda #0
      sbc MUL_1+2
      sta MUL_1+2

      lda #0
      sbc MUL_1+3
      sta MUL_1+3

    @A_Is_Positive:
      lda MUL_2+2                      ; Normalizza Moltiplicando (|MUL_2|) a 24 bit
      bpl @B_Is_Positive

      sec                              ; Negazione 24 bit: 0 - MUL_2
      lda #0
      sbc MUL_2+0
      sta MUL_2+0

      lda #0
      sbc MUL_2+1
      sta MUL_2+1

      lda #0
      sbc MUL_2+2
      sta MUL_2+2

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_32x24

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Risultato
      bpl .Exit_SMUL_32X24_Success

      sec                              ; Inverte segno Risultato 32 bit (0 - MUL_RES)
      lda #0
      sbc MUL_RES+0
      sta MUL_RES+0

      lda #0
      sbc MUL_RES+1
      sta MUL_RES+1

      lda #0
      sbc MUL_RES+2
      sta MUL_RES+2

      lda #0
      sbc MUL_RES+3
      sta MUL_RES+3

    .Exit_SMUL_32X24_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

; ==============================================================================
; SECTION 11: SUBROUTINE PER LA FAMIGLIA 32X32
; ==============================================================================

!ifdef __USE_MUL_32X32 {
  ; ==============================================================================
  ; SUBROUTINE: MUL_32X32 (Unsigned)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra due interi a 32 bit senza segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP) : Moltiplicatore (32 bit unsigned)
  ;   - MUL_2+0 .. MUL_2+3 (4 byte, ZP) : Moltiplicando (32 bit unsigned)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Mul_32x32

    MUL_32X32:
      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_32x32

    .Exit_MUL_32X32_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

!ifdef __USE_SMUL_32X32 {
  ; ==============================================================================
  ; SUBROUTINE: SMUL_32X32 (Signed)
  ; ------------------------------------------------------------------------------
  ; Descrizione: Moltiplicazione tra due interi a 32 bit con segno.
  ;
  ; Input:
  ;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP) : Moltiplicatore (32 bit signed)
  ;   - MUL_2+0 .. MUL_2+3 (4 byte, ZP) : Moltiplicando (32 bit signed)
  ;
  ; Output:
  ;   - .A                   (1 byte, CPU) : Risultato LSB (8 bit)
  ;   - .X                   (1 byte, CPU) : Risultato Byte 1 (8 bit)
  ;   - .Y                   (1 byte, CPU) : Risultato Byte 2 (8 bit)
  ;   - MUL_RES+0 .. MUL_RES+3            : Risultato a 32 bit in ZP
  ;   - Flag Carry (.P)                   : Sempre 0 (Successo)
  ;
  ; Variazione Stack (.S):
  ;   - Stabile (0 byte)
  ;
  ; Registri Modificati: .A, .X, .Y, .P
  ; Dipendenze Esterne:  <c64/symbols.asm>, <c64/errors.asm>
  ; ==============================================================================
  !zone Smul_32x32

    SMUL_32X32:
      ; --- PREAMBOLO: NORMALIZZAZIONE E SALVATAGGIO SEGNI ---
      lda MUL_1+3
      eor MUL_2+3                      ; Bit 7 = Segno del Risultato
      pha                              ; Salva segno risultato

      lda MUL_1+3                      ; Normalizza Moltiplicatore (|MUL_1|) a 32 bit
      bpl @A_Is_Positive

      sec                              ; Negazione 32 bit: 0 - MUL_1
      lda #0
      sbc MUL_1+0
      sta MUL_1+0

      lda #0
      sbc MUL_1+1
      sta MUL_1+1

      lda #0
      sbc MUL_1+2
      sta MUL_1+2

      lda #0
      sbc MUL_1+3
      sta MUL_1+3

    @A_Is_Positive:
      lda MUL_2+3                      ; Normalizza Moltiplicando (|MUL_2|) a 32 bit
      bpl @B_Is_Positive

      sec                              ; Negazione 32 bit: 0 - MUL_2
      lda #0
      sbc MUL_2+0
      sta MUL_2+0

      lda #0
      sbc MUL_2+1
      sta MUL_2+1

      lda #0
      sbc MUL_2+2
      sta MUL_2+2

      lda #0
      sbc MUL_2+3
      sta MUL_2+3

    @B_Is_Positive:
      ; --- NUCLEO ARITMETICO ---
      +m_Mul_Core_32x32

      ; --- POSTAMBOLO: APPLICAZIONE SEGNI ---
      pla                              ; Recupera segno Risultato
      bpl .Exit_SMUL_32X32_Success

      sec                              ; Inverte segno Risultato 32 bit (0 - MUL_RES)
      lda #0
      sbc MUL_RES+0
      sta MUL_RES+0

      lda #0
      sbc MUL_RES+1
      sta MUL_RES+1

      lda #0
      sbc MUL_RES+2
      sta MUL_RES+2

      lda #0
      sbc MUL_RES+3
      sta MUL_RES+3

    .Exit_SMUL_32X32_Success:
      lda MUL_RES+0                    ; .A = Risultato LSB
      ldx MUL_RES+1                    ; .X = Risultato Byte 1
      ldy MUL_RES+2                    ; .Y = Risultato Byte 2
      clc                              ; Successo: Carry = 0
      rts

  !zone
}

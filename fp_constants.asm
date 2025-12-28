; -----------------------------------------------
; Loading Floating Point Constants into FAC / ARG
; -----------------------------------------------

; Title:                  MACRO: Load FAC or ARG with an MBF floating point number
; Name:                   Load_FAC_with
;                         Load_ARG_with
; Description:            Load FAC or ARG with an extended precision (5 bytes) Microsoft Binary Format floating point number.
;                         Values loaded in FAC are always considered rounded.
; Input parameters:       exp_: Exponent
;                         ho_:  MSB of the mantissa with encoded sign
;                         moh_: Second MSB of the mantissa
;                         mo_:  Third MSB of the mantissa
;                         lo_:  LSB of the mantissa
; Output parameters:      ---
; Altered registers:      .A
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Load_FAC_with exp_, ho_, moh_, mo_, lo_ {
  lda #exp_                     ; Exponent byte.
  sta FACEXP

  !if ((ho_ or %10000000) - exp_) {
    lda #(ho_ or %10000000)     ; Restore bit #7 of MSB of mantissa.
  }
  sta FACHO

  !if (moh_ - (ho_ or %10000000)) {
    lda #moh_                   ; 2nd MSB of mantissa.
  }
  sta FACMOH

  !if (mo_ - moh_) {
    lda #mo_                    ; 3rd MSB of mantissa.
  }
  sta FACMO

  !if (lo_ - mo_) {
    lda #lo_                    ; LSB of mantissa.
  }
  sta FACLO

  !if (ho_ and %10000000) {     ; Check sign of 5-bytes floating point value.
    !if ($FF - lo_) {
      lda #$FF
    }
  } else {
    !if (lo_) {
      lda #$00
    }
  }
  sta FACSGN                    ; Sign byte.

  !if (ho_ and %10000000) {
    lda #$00                    ; Rounding byte of FAC.
  }
  sta FACOV
}

!macro Load_ARG_with exp_, ho_, moh_, mo_, lo_ {
  lda #exp_                     ; Exponent byte.
  sta ARGEXP

  !if ((ho_ or %10000000) - exp_) {
    lda #(ho_ or %10000000)     ; Restore bit #7 of MSB of mantissa.
  }
  sta ARGHO

  !if (moh_ - (ho_ or %10000000)) {
    lda #moh_                   ; 2nd MSB of mantissa.
  }
  sta ARGMOH

  !if (mo_ - moh_) {
    lda #mo_                    ; 3rd MSB of mantissa.
  }
  sta ARGMO

  !if (lo_ - mo_) {
    lda #lo_                    ; LSB of mantissa.
  }
  sta ARGLO

  !if (ho_ and %10000000) {     ; Check sign of 5-bytes floating point value.
    !if ($FF - lo_) {
      lda #$FF
    }
  } else {
    !if (lo_) {
      lda #$00
    }
  }
  sta ARGSGN                    ; Sign byte.
}

; Title:                  MACRO: Load FAC or ARG with predefined constants
; Name:                   Load_FAC_with_[...]
;                         Load_ARG_with_[...]
; Description:            Load FAC or ARG with a predefined constant.
;                         The name of the constant is part of the macro name. Currently supported constants are:
;                           "0"
;                           "0.25"
;                           "0.5"
;                           "1"
;                           "MINUS_1" (-1)
;                           "2"
;                           "10"
;                           "0.1"
;                           "PI4"     (π/4)
;                           "PI2"     (π/2)
;                           "PI"      (π)
;                           "2PI"     (2π)
;                           "PI180"   (π/180)
;                           "PI200"   (π/200)
;                           "180PI"   (180/π)
;                           "200PI"   (200/π)
;                           "SQR2"    (√2)
;                           "SQR3"    (√3)
;                           "e"
;                           "LOG2"    (ln 2)
;                           "LOG10"   (ln 10)
;                           "eps"     (4.65661287*10^-10: machine epsilon, defined as the difference between 1 and the next larger floating point number)
;                           "MINR"    (2.93873588*10^-39: smallest non-zero floating point number representable in Microsoft Binary Format)
;                           "MAXR"    (1.70141183*10^38: largest floating point number representable in Microsoft Binary Format)
; Input parameters:       ---
; Output parameters:      ---
; Altered registers:      .A
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Load_FAC_with_0 {
  +Load_FAC_with $00, $00, $00, $00, $00
}

!macro Load_ARG_with_0 {
  +Load_ARG_with $00, $00, $00, $00, $00
}

!macro Load_FAC_with_0.25 {
  +Load_FAC_from_Mem FR4
}

!macro Load_ARG_with_0.25 {
  +Load_ARG_from_Mem FR4
}

!macro Load_FAC_with_0.5 {
  +Load_FAC_from_Mem FHALF
}

!macro Load_ARG_with_0.5 {
  +Load_ARG_from_Mem FHALF
}

!macro Load_FAC_with_1 {
  +Load_FAC_from_Mem FONE
}

!macro Load_ARG_with_1 {
  +Load_ARG_from_Mem FONE
}

!macro Load_FAC_with_MINUS_1 {
  +Load_FAC_with $81, $80, $00, $00, $00
}

!macro Load_ARG_with_MINUS_1 {
  +Load_ARG_with $81, $80, $00, $00, $00
}

!macro Load_FAC_with_2 {
  +Load_FAC_with $82, $00, $00, $00, $00
}

!macro Load_ARG_with_2 {
  +Load_ARG_with $82, $00, $00, $00, $00
}

!macro Load_FAC_with_10 {
  +Load_FAC_from_Mem TENC
}

!macro Load_ARG_with_10 {
  +Load_ARG_from_Mem TENC
}

!macro Load_FAC_with_0.1 {
  +Load_FAC_with $7D, $4C, $CC, $CC, $CD
}

!macro Load_ARG_with_0.1 {
  +Load_ARG_with $7D, $4C, $CC, $CC, $CD
}

!macro Load_FAC_with_PI4 {
  +Load_FAC_with_PI2
  dec FACEXP
}

!macro Load_ARG_with_PI4 {
  +Load_ARG_with_PI2
  dec ARGEXP
}

!macro Load_FAC_with_PI2 {
  +Load_FAC_from_Mem PI2
}

!macro Load_ARG_with_PI2 {
  +Load_ARG_from_Mem PI2
}

!macro Load_FAC_with_PI {
  +Load_FAC_from_Mem PIVAL
}

!macro Load_ARG_with_PI {
  +Load_ARG_from_Mem PIVAL
}

!macro Load_FAC_with_2PI {
  +Load_FAC_from_Mem TWOPI
}

!macro Load_ARG_with_2PI {
  +Load_ARG_from_Mem TWOPI
}

!macro Load_FAC_with_PI180 {
  +Load_FAC_with $7B, $0E, $FA, $35, $12
}

!macro Load_ARG_with_PI180 {
  +Load_ARG_with $7B, $0E, $FA, $35, $12
}

!macro Load_FAC_with_PI200 {
  +Load_FAC_with $7B, $00, $AD, $FC, $90
}

!macro Load_ARG_with_PI200 {
  +Load_ARG_with $7B, $00, $AD, $FC, $90
}

!macro Load_FAC_with_180PI {
  +Load_FAC_with $86, $65, $2E, $E0, $D4
}

!macro Load_ARG_with_180PI {
  +Load_ARG_with $86, $65, $2E, $E0, $D4
}

!macro Load_FAC_with_200PI {
  +Load_FAC_with $86, $7E, $A5, $DD, $5E
}

!macro Load_ARG_with_200PI {
  +Load_ARG_with $86, $7E, $A5, $DD, $5E
}

!macro Load_FAC_with_SQR2 {
  +Load_FAC_from_Mem FSQR2
}

!macro Load_ARG_with_SQR2 {
  +Load_ARG_from_Mem FSQR2
}

!macro Load_FAC_with_SQR3 {
  +Load_FAC_with $81, $5D, $B3, $D7, $43
}

!macro Load_ARG_with_SQR3 {
  +Load_ARG_with $81, $5D, $B3, $D7, $43
}

!macro Load_FAC_with_e {
  +Load_FAC_with $82, $2D, $F8, $54, $59
}

!macro Load_ARG_with_e {
  +Load_ARG_with $82, $2D, $F8, $54, $59
}

!macro Load_FAC_with_LOG2 {
  +Load_FAC_from_Mem FLOG2
}

!macro Load_ARG_with_LOG2 {
  +Load_ARG_from_Mem FLOG2
}

!macro Load_FAC_with_LOG10 {
  +Load_FAC_with $82, $13, $5D, $8D, $DE
}

!macro Load_ARG_with_LOG10 {
  +Load_ARG_with $82, $13, $5D, $8D, $DE
}

!macro Load_FAC_with_eps {
  +Load_FAC_with $62, $00 ,$00, $00, $00
}

!macro Load_ARG_with_eps {
  +Load_ARG_with $62, $00 ,$00, $00, $00
}

!macro Load_FAC_with_MINR {
  +Load_FAC_with $01, $00 ,$00, $00, $00
}

!macro Load_ARG_with_MINR {
  +Load_ARG_with $01, $00 ,$00, $00, $00
}

!macro Load_FAC_with_MAXR {
  +Load_FAC_with $FF, $7F, $FF, $FF, $FF
}

!macro Load_ARG_with_MAXR {
  +Load_ARG_with $FF, $7F, $FF, $FF, $FF
}

; --------------------------------
; Loading Constants into FAC / ARG
; --------------------------------

; Macro +Load_[FAC/ARG]_with: Load [FAC/ARG] with a 5-bytes floating point value.
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
    !if ($80 - lo_) {
      lda #$80
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

  +Adjust_Signs
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
    !if ($80 - lo_) {
      lda #$80
    }
  } else {
    !if (lo_) {
      lda #$00
    }
  }
  sta ARGSGN                    ; Sign byte.

  +Adjust_Signs
}

; Macro +Load_[FAC/ARG]_with_...: Load [FAC/ARG] with predefined constants.
!macro Load_FAC_with_0 {
  +Load_FAC_with $00,$00,$00,$00,$00
}

!macro Load_ARG_with_0 {
  +Load_ARG_with $00,$00,$00,$00,$00
}

!macro Load_FAC_with_0.25 {
  +Load_FAC_with_Mem FR4
}

!macro Load_ARG_with_0.25 {
  +Load_ARG_with_Mem FR4
}

!macro Load_FAC_with_0.5 {
  +Load_FAC_with_Mem FHALF
}

!macro Load_ARG_with_0.5 {
  +Load_ARG_with_Mem FHALF
}

!macro Load_FAC_with_1 {
  +Load_FAC_with_Mem FONE
}

!macro Load_ARG_with_1 {
  +Load_ARG_with_Mem FONE
}

!macro Load_FAC_with_MINUS_1 {
  +Load_FAC_with $81, $80, $00, $00, $00
}

!macro Load_ARG_with_MINUS_1 {
  +Load_ARG_with $81, $80, $00, $00, $00
}

!macro Load_FAC_with_2 {
  +Load_FAC_with_1
  inc FACEXP
}

!macro Load_ARG_with_2 {
  +Load_ARG_with_1
  inc ARGEXP
}

!macro Load_FAC_with_10 {
  +Load_FAC_with_Mem TENC
}

!macro Load_ARG_with_10 {
  +Load_ARG_with_Mem TENC
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
  +Load_FAC_with_Mem PI2
}

!macro Load_ARG_with_PI2 {
  +Load_ARG_with_Mem PI2
}

!macro Load_FAC_with_PI {
  +Load_FAC_with_Mem PIVAL
}

!macro Load_ARG_with_PI {
  +Load_ARG_with_Mem PIVAL
}

!macro Load_FAC_with_2PI {
  +Load_FAC_with_Mem TWOPI
}

!macro Load_ARG_with_2PI {
  +Load_ARG_with_Mem TWOPI
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
  +Load_FAC_with_Mem FSQR2
}

!macro Load_ARG_with_SQR2 {
  +Load_ARG_with_Mem FSQR2
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
  +Load_FAC_with_Mem FLOG2
}

!macro Load_ARG_with_LOG2 {
  +Load_ARG_with_Mem FLOG2
}

!macro Load_FAC_with_LOG10 {
  +Load_FAC_with $82, $13, $5D, $8D, $DE
}

!macro Load_ARG_with_LOG10 {
  +Load_ARG_with $82, $13, $5D, $8D, $DE
}

!macro Load_FAC_with_MAXR {
  +Load_FAC_with $FF, $7F, $FF, $FF, $FF
}

!macro Load_ARG_with_MAXR {
  +Load_ARG_with $FF, $7F, $FF, $FF, $FF
}

!macro Load_FAC_with_eps {
  +Load_FAC_with $01, $00 ,$00, $00, $00
}

!macro Load_ARG_with_eps {
  +Load_ARG_with $01, $00 ,$00, $00, $00
}

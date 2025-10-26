; --------------------------
; Loading constants into FAC
; --------------------------

; Macro +Load_[FAC/ARG]_with: Load [FAC/ARG] with a 5-bytes floating point value.
!macro Load_FAC_with exp, ho, moh, mo, lo {
  lda #exp                      ; Exponent byte.
  sta FACEXP

  lda #(ho or %10000000)        ; Restore bit #7 of MSB of mantissa.
  sta FACHO

  lda #moh                      ; 2nd MSB of mantissa.
  sta FACMOH

  lda #mo                       ; 3rd MSB of mantissa.
  sta FACMO

  lda #lo                       ; LSB of mantissa.
  sta FACLO

  !if (ho and %10000000) {      ; Check sign of 5-bytes floating point value.
    lda #$FF
  } else {
    lda #$00
  }
  sta FACSGN                    ; Sign byte.

  lda #$00                      ; Rounding byte of FAC.
  sta FACOV

  +Adjust_Signs
}

!macro Load_ARG_with exp, ho, moh, mo, lo {
  lda #exp                      ; Exponent byte.
  sta ARGEXP

  lda #(ho or %10000000)        ; Restore bit #7 of MSB of mantissa.
  sta ARGHO

  lda #moh                      ; 2nd MSB of mantissa.
  sta ARGMOH

  lda #mo                       ; 3rd MSB of mantissa.
  sta ARGMO

  lda #lo                       ; LSB of mantissa.
  sta ARGLO

  !if (ho and %10000000) {      ; Check sign of 5-bytes floating point value.
    lda #$FF
  } else {
    lda #$00
  }
  sta ARGSGN                    ; Sign byte.

  +Adjust_Signs
}

; Load a constant stored into FAC
!macro LoadFAC v1,v2 {
  !if (v1 - 2) {
    ldy #<v2
    lda #>v2
    jsr GIVAYF
    +AdjustSigns
  } else {
    +PutFACinPAD 1
    ldy #<v2
    lda #>v2
    jsr GIVAYF
    +CopyFAC1toFAC2
    +GetFACfromPAD 1
    +AdjustSigns
  }
}

; Macro +Load_[FAC/ARG]_with_0: Load [FAC/ARG] with 0.
!macro Load_FAC_with_0 {
  lda #$00
  sta FACEXP
  sta FACHO
  sta FACMOH
  sta FACMO
  sta FACLO
  sta FACSGN
  sta FACOV

  +Adjust_Signs
}

!macro Load_ARG_with_0 {
  lda #$00
  sta ARGEXP
  sta ARGHO
  sta ARGMOH
  sta ARGMO
  sta ARGLO
  sta ARGSGN

  +Adjust_Signs
}

!macro Load0inFAC v1 {
  !if (v1 - 2) {
    lda #$00
    sta FAC1_EXP
    sta FAC1_MANT
    sta FAC1_MANT+1
    sta FAC1_MANT+2
    sta FAC1_MANT+3
    sta FAC1_SIGN
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$00
    sta FAC2_EXP
    sta FAC2_MANT
    sta FAC2_MANT+1
    sta FAC2_MANT+2
    sta FAC2_MANT+3
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Load 1/4 in FAC
!macro Load0.25inFAC v1 {
  +LoadMEMinFAC v1,FR4
}

; Load 1/2 in FAC
!macro Load0.5inFAC v1 {
  +LoadMEMinFAC v1,FHALF
}

; Load 1 in FAC
!macro Load1inFAC v1 {
  !if (v1 - 2) {
    ldx #$81
    stx FAC1_EXP
    dex
    stx FAC1_MANT
    ldx #$00
    stx FAC1_MANT+1
    stx FAC1_MANT+2
    stx FAC1_MANT+3
    stx FAC1_SIGN
    stx FAC1_ROUND
    +AdjustSigns
  } else {
    ldx #$81
    stx FAC2_EXP
    dex
    stx FAC2_MANT
    ldx #$00
    stx FAC2_MANT+1
    stx FAC2_MANT+2
    stx FAC2_MANT+3
    stx FAC2_SIGN
    +AdjustSigns
  }
}

; Load 2 in FAC
!macro Load2inFAC v1 {
  !if (v1 - 2) {
    ldx #$82
    stx FAC1_EXP
    dex
    dex
    stx FAC1_MANT
    ldx #$00
    stx FAC1_MANT+1
    stx FAC1_MANT+2
    stx FAC1_MANT+3
    stx FAC1_SIGN
    stx FAC1_ROUND
    +AdjustSigns
  } else {
    ldx #$82
    stx FAC2_EXP
    dex
    dex
    stx FAC2_MANT
    ldx #$00
    stx FAC2_MANT+1
    stx FAC2_MANT+2
    stx FAC2_MANT+3
    stx FAC2_SIGN
    +AdjustSigns
  }
}

; Load 10 in FAC
!macro Load10inFAC v1 {
  +LoadMEMinFAC v1,TENC
}

; Load PI/4 in FAC
!macro LoadPI4inFAC v1 {
  !if (v1 - 2) {
    +LoadPI2inFAC 1
    dec FAC1_EXP
  } else {
    +LoadPI2inFAC 2
    dec FAC2_EXP
  }
}

; Load PI/2 in FAC
!macro LoadPI2inFAC v1 {
  +LoadMEMinFAC v1,PI2
}

; Load PI in FAC
!macro LoadPIinFAC v1 {
  +LoadMEMinFAC v1,PIVAL
}

; Load 2*PI in FAC
!macro Load2PIinFAC v1 {
  +LoadMEMinFAC v1,TWOPI
}

; Load PI/180 in FAC
!macro LoadPI180inFAC v1 {
  !if (v1 - 2) {
    lda #$7B
    sta FAC1_EXP
    lda #$8E
    sta FAC1_MANT
    lda #$FA
    sta FAC1_MANT+1
    lda #$35
    sta FAC1_MANT+2
    lda #$11
    sta FAC1_MANT+3
    lda #$00
    sta FAC1_SIGN
    lda #$00
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$7B
    sta FAC2_EXP
    lda #$8E
    sta FAC2_MANT
    lda #$FA
    sta FAC2_MANT+1
    lda #$35
    sta FAC2_MANT+2
    lda #$11
    sta FAC2_MANT+3
    lda #$00
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Load 180/PI in FAC
!macro Load180PIinFAC v1 {
  !if (v1 - 2) {
    lda #$86
    sta FAC1_EXP
    lda #$E5
    sta FAC1_MANT
    lda #$2E
    sta FAC1_MANT+1
    lda #$E0
    sta FAC1_MANT+2
    lda #$D4
    sta FAC1_MANT+3
    lda #$00
    sta FAC1_SIGN
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$86
    sta FAC2_EXP
    lda #$E5
    sta FAC2_MANT
    lda #$2E
    sta FAC2_MANT+1
    lda #$E0
    sta FAC2_MANT+2
    lda #$D4
    sta FAC2_MANT+3
    lda #$00
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Load SQR(2) in FAC
!macro LoadSQR2inFAC v1 {
  !if (v1 - 2) {
    lda #$81
    sta FAC1_EXP
    lda #$B5
    sta FAC1_MANT
    lda #$04
    sta FAC1_MANT+1
    lda #$F3
    sta FAC1_MANT+2
    lda #$34
    sta FAC1_MANT+3
    lda #$00
    sta FAC1_SIGN
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$81
    sta FAC2_EXP
    lda #$B5
    sta FAC2_MANT
    lda #$04
    sta FAC2_MANT+1
    lda #$F3
    sta FAC2_MANT+2
    lda #$34
    sta FAC2_MANT+3
    lda #$00
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Load SQR(3) in FAC
!macro LoadSQR3inFAC v1 {
  !if (v1 - 2) {
    lda #$81
    sta FAC1_EXP
    lda #$DD
    sta FAC1_MANT
    lda #$B3
    sta FAC1_MANT+1
    lda #$D7
    sta FAC1_MANT+2
    lda #$42
    sta FAC1_MANT+3
    lda #$00
    sta FAC1_SIGN
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$81
    sta FAC2_EXP
    lda #$DD
    sta FAC2_MANT
    lda #$B3
    sta FAC2_MANT+1
    lda #$D7
    sta FAC2_MANT+2
    lda #$42
    sta FAC2_MANT+3
    lda #$00
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Load EXP(1) in FAC
!macro LoadeinFAC v1 {
  !if (v1 - 2) {
    lda #$82
    sta FAC1_EXP
    lda #$AD
    sta FAC1_MANT
    lda #$F8
    sta FAC1_MANT+1
    lda #$54
    sta FAC1_MANT+2
    lda #$58
    sta FAC1_MANT+3
    lda #$00
    sta FAC1_SIGN
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$82
    sta FAC2_EXP
    lda #$AD
    sta FAC2_MANT
    lda #$F8
    sta FAC2_MANT+1
    lda #$54
    sta FAC2_MANT+2
    lda #$58
    sta FAC2_MANT+3
    lda #$00
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Load LN(10) in FAC
!macro LoadLN10inFAC v1 {
  !if (v1 - 2) {
    lda #$82
    sta FAC1_EXP
    lda #$93
    sta FAC1_MANT
    lda #$5D
    sta FAC1_MANT+1
    lda #$8D
    sta FAC1_MANT+2
    lda #$DD
    sta FAC1_MANT+3
    lda #$00
    sta FAC1_SIGN
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$82
    sta FAC2_EXP
    lda #$93
    sta FAC2_MANT
    lda #$5D
    sta FAC2_MANT+1
    lda #$8D
    sta FAC2_MANT+2
    lda #$DD
    sta FAC2_MANT+3
    lda #$00
    sta FAC2_SIGN
    +AdjustSigns
  }
}

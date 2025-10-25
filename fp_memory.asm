; ----------------------------
; Macros for internal use only
; ----------------------------

; Adjust ARISGN according to the law of signs when FAC1 or FAC2 are modified
!macro AdjustSigns {
  lda FAC1_SIGN                 ; Apply the law of signs
  eor FAC2_SIGN                 ; Bit #7 is 0 (+) when signs are like and 1 when signs are unlike (-)
  sta ARISGN
}

; Copy a FAC to scratchpad area
!macro PutFACinPAD fac {
  !if (fac - 2) {
    lda FAC1_ROUND              ; Copy FAC1 to Scratchpad #1
    sta SCRATCHPAD+6
    lda FAC1+5
    sta SCRATCHPAD+5
    lda FAC1+4
    sta SCRATCHPAD+4
    lda FAC1+3
    sta SCRATCHPAD+3
    lda FAC1+2
    sta SCRATCHPAD+2
    lda FAC1+1
    sta SCRATCHPAD+1
    lda FAC1
    sta SCRATCHPAD
  } else {
    lda FAC2_SIGN               ; Copy FAC2 to Scratchpad #2
    sta SCRATCHPAD2+5
    lda FAC2_MANT+3
    sta SCRATCHPAD2+4
    lda FAC2_MANT+2
    sta SCRATCHPAD2+3
    lda FAC2_MANT+1
    sta SCRATCHPAD2+2
    lda FAC2_MANT
    sta SCRATCHPAD2+1
    lda FAC2_EXP
    sta SCRATCHPAD2
  }
}

; Copy a FAC from scratchpad area
!macro GetFACfromPAD fac {
  !if (fac - 2) {
    lda SCRATCHPAD+6            ; Copy Scratchpad #1 to FAC1
    sta FAC1_ROUND
    lda SCRATCHPAD+5
    sta FAC1_SIGN
    lda SCRATCHPAD+4
    sta FAC1_MANT+3
    lda SCRATCHPAD+3
    sta FAC1_MANT+2
    lda SCRATCHPAD+2
    sta FAC1_MANT+1
    lda SCRATCHPAD+1
    sta FAC1_MANT
    lda SCRATCHPAD
    sta FAC1_EXP
  } else {
    lda SCRATCHPAD2+5           ; Copy Scratchpad #2 to FAC2
    sta FAC2_SIGN
    lda SCRATCHPAD2+4
    sta FAC2_MANT+3
    lda SCRATCHPAD2+3
    sta FAC2_MANT+2
    lda SCRATCHPAD2+2
    sta FAC2_MANT+1
    lda SCRATCHPAD2+1
    sta FAC2_MANT
    lda SCRATCHPAD2
    sta FAC2_EXP
  }
  +AdjustSigns
}

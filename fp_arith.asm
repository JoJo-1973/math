; Multiply FAC by 2
!macro MultiplyFACby2 v1 {
  !if (v1 - 2) {
    inc FAC1_EXP                ; No need to adjust signs
  } else {
    inc FAC2_EXP                ; No need to adjust signs
  }
}

; Divide FAC by 2
!macro DivideFACby2 v1 {
  !if (v1 - 2) {
    dec FAC1_EXP                ; No need to adjust signs
  } else {
    dec FAC2_EXP                ; No need to adjust signs
  }
}


; ----------------
; Basic arithmetic
; ----------------

; Addition: FAC1 = FAC2 + FAC1
!macro AddFAC2toFAC1 {
  lda FAC1_EXP                  ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; addition routine needs to be notified of the condition to treat properly the case
  jsr FADDT
  +AdjustSigns
}

; Addition: FAC1 = Memory + FAC1
!macro AddMEMtoFAC1 v1 {
  +LoadMEMinFAC 2,v1
  +AddFAC2toFAC1
}

; Addition: FAC1 = (Memory) + FAC1
!macro AddMEMtoFAC1_Ind v1 {
  +LoadMEMinFAC_Ind 2,v1
  +AddFAC2toFAC1
}

; Subtraction: FAC1 = FAC2 - FAC1
!macro SubtractFAC1fromFAC2 {
  jsr FSUBT                     ; No need to prepare Zero flag: the routine is already self-contained
  +AdjustSigns
}

; Subtraction: FAC1 = Memory - FAC1
!macro SubtractFAC1fromMEM v1 {
  +LoadMEMinFAC 2,v1
  +SubtractFAC1fromFAC2
}

; Subtraction: FAC1 = (Memory) - FAC1
!macro SubtractFAC1fromMEM_Ind v1 {
  +LoadMEMinFAC_Ind 2,v1
  +SubtractFAC1fromFAC2
}

; Multiplication: FAC1 = FAC2 * FAC1
!macro MultiplyFAC2byFAC1 {
  lda FAC1_EXP                  ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; addition routine needs to be notified of the condition to treat properly the case
  jsr FMULTT
  +AdjustSigns
}

; Multiplication: FAC1 = Memory * FAC1
!macro MultiplyMEMbyFAC1 v1 {
  +LoadMEMinFAC 2,v1
  +MultiplyFAC2byFAC1
}

; Multiplication: FAC1 = (Memory) * FAC1
!macro MultiplyMEMbyFAC1_Ind v1 {
  +LoadMEMinFAC_Ind 2,v1
  +MultiplyFAC2byFAC1
}

; Division: FAC1 = FAC2 / FAC1
!macro DivideFAC2byFAC1 {
  lda FAC1_EXP                  ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; addition routine needs to be notified of the condition to treat properly the case
  jsr FDIVT
  +AdjustSigns
}

; Division: FAC1 = Memory / FAC1
!macro DivideMEMbyFAC1 v1 {
  +LoadMEMinFAC 2,v1
  +DivideFAC2byFAC1
}

; Division: FAC1 = (Memory) / FAC1
!macro DivideMEMbyFAC1_Ind v1 {
  +LoadMEMinFAC_Ind 2,v1
  +DivideFAC2byFAC1
}

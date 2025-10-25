; ---------------
; Unary functions
; ---------------

; Change sign: FAC = -FAC
!macro NegateFAC v1 {
  !if (v1 - 2) {
    lda FAC1_SIGN
    eor #$FF
    sta FAC1_SIGN
    +AdjustSigns
  } else {
    lda FAC2_SIGN
    eor #$FF
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Absolute value: FAC = ABS(FAC)
!macro AbsFAC v1
  !if (v1 - 2) {
    lsr FAC1_SIGN               ; Just replace bit #7 with 0
    +AdjustSigns
  } else {
    lsr FAC2_SIGN               ; Just replace bit #7 with 0
    +AdjustSigns
  }
}

; Sign of FAC
; .A = $FF if FAC < 0
; .A = $00 if FAC = 0
; .A = $01 if FAC > 0
!macro SignFAC v1
  !if (v1 - 2) {
    jsr SIGN
  } else {
    lda FAC2_EXP
    beq +++++                   ; If .A = 0, exit
    lda FAC2_SIGN               ; else put sign bit in carry
    rol a
    lda #$FF                    ; Prepare negative sign answer
    bcs +++++                   ; and deliver it if C = 1
    lda #$01                    ; else deliver positive sign answer
+++++
    rts
  }
}

; ---------------
; Unary functions
; ---------------

; Macro Negate_[FAC/ARG]: Change the sign of FAC/ARG.
!macro Negate_FAC {
  lda FACSGN
  eor #$FF
  sta FACSGN

  +Adjust_Signs
}

!macro Negate_ARG {
  lda ARGSGN
  eor #$FF
  sta ARGSGN

  +Adjust_Signs
}

; Macro Abs_[FAC/ARG]: Compute the absolute value of FAC/ARG.
!macro Abs_FAC {
  lsr FACSGN                    ; Just replace bit #7 of sign with 0.

  +Adjust_Signs
}

!macro Abs_ARG {
  lsr ARGSGN                    ; Just replace bit #7 of sign with 0.

  +Adjust_Signs
}

; Macro Sign_[FAC/ARG]: Sign of FAC/ARG.
; .A = $FF if FAC/ARG < 0
; .A = $00 if FAC/ARG = 0
; .A = $01 if FAC/ARG > 0
!macro Sign_FAC {
  jsr SIGN
}

!macro Sign_ARG {
  lda ARGEXP
  beq +++++                     ; If .A = 0, exit

  lda ARGSGN                    ; else rotate sign bit in carry.
  rol a
  lda #$FF                      ; Prepare negative sign answer
  bcs +++++                     ; and deliver it if .C = 1
  lda #$01                      ; else deliver positive sign answer
+++++
  rts
}

; Macro Int_[FAC/ARG]: Rounds FAC/ARG towards minus infinity.
!macro Int_FAC {
  jsr INT
}

!macro Int_ARG {
  +Swap_FAC_and_ARG
  jsr INT
  +Swap_FAC_and_ARG
}
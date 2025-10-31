; ---------------
; Unary Functions
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
  beq @Exit                     ; If .A = 0, exit

  lda ARGSGN                    ; else rotate sign bit in carry.
  rol a
  lda #$FF                      ; Prepare negative sign answer
  bcs @Exit                     ; and deliver it if .C = 1
  lda #$01                      ; else deliver positive sign answer
@Exit
}

; Macro Int_[FAC/ARG]: Rounds FAC/ARG towards minus infinity.
; Operation on ARG is discouraged because of the swaps of FAC and ARG:
; the macro is provided just in case.
!macro Int_FAC {
  jsr INT
}

!macro Int_ARG {
  +Swap_FAC_and_ARG
  jsr INT
  +Swap_FAC_and_ARG
}

; Macro Multiply_[FAC/ARG]_by_2: Double FAC/ARG by exponent manipulation.
!macro Multiply_FAC_by_2 {
  inc FACEXP
}

!macro Multiply_ARG_by_2 {
  inc ARGEXP
}

; Macro Divide_[FAC/ARG]_by_2: Halve FAC/ARG by exponent manipulation.
!macro Divide_FAC_by_2 {
  dec FACEXP
}

!macro Divide_ARG_by_2 {
  dec ARGEXP
}

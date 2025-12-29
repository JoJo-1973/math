; ---------------
; Unary Functions
; ---------------

; Title:                  MACRO: Negate FAC or ARG
; Name:                   Negate_FAC
;                         Negate_ARG
; Description:            Flip the sign of the value stored in FAC or ARG.
; Input parameters:       ---
; Output parameters:      ---
; Altered registers:      .A
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Negate_FAC {
  lda FACSGN
  eor #$FF
  sta FACSGN
}

!macro Negate_ARG {
  lda ARGSGN
  eor #$FF
  sta ARGSGN
}

; Title:                  MACRO: Absolute value of FAC or ARG
; Name:                   Abs_FAC
;                         Abs_ARG
; Description:            Compute the absolute value of FAC or ARG by clearing MSB of sign.
; Input parameters:       ---
; Output parameters:      ---
; Altered registers:      ---
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Abs_FAC {
  lsr FACSGN                    ; Just replace bit #7 of sign with 0.
}

!macro Abs_ARG {
  lsr ARGSGN                    ; Just replace bit #7 of sign with 0.
}

; Title:                  MACRO: Return sign of FAC or ARG
; Name:                   Sign_FAC
;                         Sign_ARG
; Description:            Return the sign of FAC or ARG in .A.
;                           .A = $FF if FAC/ARG < 0.
;                           .A = $00 if FAC/ARG = 0.
;                           .A = $01 if FAC/ARG > 0.
; Input parameters:       ---
; Output parameters:      .A
; Altered registers:      .A
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
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

; Title:                  MACRO: Round FAC or ARG towards negative infinity
; Name:                   Int_FAC
;                         Int_ARG
; Description:            Return FAC or ARG rounded towards negative infinity, i.e. 1.2 becomes 1 and -1.2 becomes -2.
; Input parameters:       ---
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Int_FAC {
  jsr INT
}

!macro Int_ARG {
  +Swap_FAC_and_ARG
  jsr INT
  +Swap_FAC_and_ARG
}

; Title:                  MACRO: Multiply or divide FAC or ARG by 2
; Name:                   Multiply_FAC_by_2
;                         Multiply_ARG_by_2
;                         Divide_FAC_by_2
;                         Divide_ARG_by_2
; Description:            Multiply or divide FAC or ARG by 2 manipulating the exponent byte rather than using division.
; Input parameters:       ---
; Output parameters:      ---
; Altered registers:      ---
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Multiply_FAC_by_2 {
  inc FACEXP
}

!macro Multiply_ARG_by_2 {
  inc ARGEXP
}

!macro Divide_FAC_by_2 {
  dec FACEXP
}

!macro Divide_ARG_by_2 {
  dec ARGEXP
}

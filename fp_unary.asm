; ---------------
; Unary Functions
; ---------------

; Title:                  MACRO: Negate a floating point number and store the result in FAC
; Name:                   Negate_FAC
;                         Negate_ARG
;                         Negate_Mem
;                         Negate_Ptr
; Description:            Negate a Microsoft Binary Format floating point number and store the result in FAC.
;                         Negate_ARG is an exception because it operates in place rather than storing the result in FAC.
;                         The data can be located in FAC, in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_: a memory address
;                         ptr_:  a pointer
; Output parameters:      ---
; Altered registers:      .A, .Y
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

!macro Negate_Mem addr_ {
  +Load_FAC_from_Mem addr_
  lda FACSGN
  eor #$FF
  sta FACSGN
}

!macro Negate_Ptr ptr_ {
  +Load_FAC_from_Ptr ptr_
  lda FACSGN
  eor #$FF
  sta FACSGN
}

; Title:                  MACRO: Compute the absolute value of a floating point number and store the result in FAC
; Name:                   ABS_FAC
;                         ABS_ARG
;                         ABS_Mem
;                         ABS_Ptr
; Description:            Compute the absolute value of a Microsoft Binary Format floating point number and store the result in FAC.
;                         ABS_ARG is an exception because it operates in place rather than storing the result in FAC.
;                         The data can be located in FAC, in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_: a memory address
;                         ptr_:  a pointer
; Output parameters:      ---
; Altered registers:      .A, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro ABS_FAC {
  lsr FACSGN                    ; Just replace bit #7 of sign with 0.
}

!macro ABS_ARG {
  lsr ARGSGN                    ; Just replace bit #7 of sign with 0.
}

!macro ABS_Mem addr_ {
  +Load_FAC_from_Mem addr_
  lsr FACSGN
}

!macro ABS_Ptr ptr_ {
  +Load_FAC_from_Ptr ptr_
  lsr FACSGN
}

; Title:                  MACRO: Return the sign of a floating point number and store the result in .A
; Name:                   Sign_FAC
;                         Sign_ARG
;                         Sign_Mem
;                         Sign_Ptr
; Description:            Return the sign of a Microsoft Binary Format floating point number and store the result in .A.
;                         Sign_ARG is an exception because it operates in place rather than storing the result in FAC.
;                         The data can be located in FAC, in ARG, at an absolute memory address or referenced to by a pointer.
;                           .A = $FF if data < 0.
;                           .A = $00 if data = 0.
;                           .A = $01 if data > 0.
; Input parameters:       addr_: a memory address
;                         ptr_:  a pointer
; Output parameters:      .A
; Altered registers:      .A, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Sign_FAC {
  jsr SIGN
}

!macro Sign_ARG {
  lda ARGEXP                    ; Test exponent,
  beq @Exit                     ; if .A = 0, exit

  lda ARGSGN                    ; else rotate sign bit in carry.
  rol a
  lda #$FF                      ; Prepare negative sign answer
  bcs @Exit                     ; and deliver it if C = 1
  lda #$01                      ; else deliver positive sign answer.
@Exit
}

!macro Sign_Mem addr_ {
  +Load_FAC_from_Mem addr_
  jsr SIGN
}

!macro Sign_Ptr ptr_ {
  +Load_FAC_from_Ptr ptr_
  jsr SIGN
}

; Title:                  MACRO: Round a floating point number towards negative infinity and store the result in FAC
; Name:                   INT_FAC
;                         INT_ARG
;                         INT_Mem
;                         INT_Ptr
; Description:            Round a Microsoft Binary Format floating point number towards negative infinity and store the result in FAC.
;                         For example, 1.2 becomes 1 and -1.2 becomes -2.
;                         INT_ARG is an exception because it operates in place rather than storing the result in FAC.
;                         The data can be located in FAC, in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_: a memory address
;                         ptr_:  a pointer
; Output parameters:      ---
; Altered registers:      .A, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro INT_FAC {
  jsr INT
}

!macro INT_ARG {
  +Swap_FAC_and_ARG
  jsr INT
  +Swap_FAC_and_ARG
}

!macro INT_Mem addr_ {
  +Load_FAC_from_Mem addr_
  jsr INT
}

!macro INT_Ptr ptr_ {
  +Load_FAC_from_Ptr ptr_
  jsr INT
}

; Title:                  MACRO: Multiply or divide a floating point number by 2 and store the result in FAC
; Name:                   Multiply_FAC_by_2
;                         Multiply_ARG_by_2
;                         Multiply_Mem_by_2
;                         Multiply_Ptr_by_2
;                         Divide_FAC_by_2
;                         Divide_ARG_by_2
;                         Divide_Mem_by_2
;                         Divide_Ptr_by_2
; Description:            Multiply or divide a floating point number by 2 and store the result in FAC.
;                         The operation is performed by changing the exponent byte and it's much faster
;                         than a proper multiplication or division.
;                         Operations on ARG are exceptions because they operate in place rather than storing the result in FAC.
;                         The data can be located in FAC, in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_: a memory address
;                         ptr_:  a pointer
; Output parameters:      ---
; Altered registers:      .A, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Multiply_FAC_by_2 {
  inc FACEXP
}

!macro Multiply_ARG_by_2 {
  inc ARGEXP
}

!macro Multiply_Mem_by_2 addr_ {
  +Load_FAC_from_Mem addr_
  inc FACEXP
}

!macro Multiply_Ptr_by_2 ptr_ {
  +Load_FAC_from_Ptr ptr_
  inc FACEXP
}

!macro Divide_FAC_by_2 {
  dec FACEXP
}

!macro Divide_ARG_by_2 {
  dec ARGEXP
}

!macro Divide_Mem_by_2 addr_ {
  +Load_FAC_from_Mem addr_
  dec FACEXP
}

!macro Divide_Ptr_by_2 ptr_ {
  +Load_FAC_from_Ptr ptr_
  dec FACEXP
}

; -----------------
; Boolean Operators
; -----------------

; Title:                  MACRO: Compute bitwise AND and store the result in FAC
; Name:                   AND_FAC_with_ARG
;                         AND_FAC_with_Mem
;                         AND_FAC_with_Ptr
; Description:            Perform a bitwise AND between FAC and a Microsoft Binary Format floating point number and store the result in FAC.
;                         The data can be located in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:     a memory address
;                         ptr_:      a pointer
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro AND_FAC_with_ARG preserve_ {
  jsr ANDOP
}

!macro AND_FAC_with_Mem addr_, preserve_ {
  +Load_ARG_from_Mem addr_
  jsr ANDOP
}

!macro AND_FAC_with_Ptr ptr_, preserve_ {
  +Load_ARG_from_Ptr ptr_
  jsr ANDOP
}

; Title:                  MACRO: Compute bitwise OR and store the result in FAC
; Name:                   OR_FAC_with_ARG
;                         OR_FAC_with_Mem
;                         OR_FAC_with_Ptr
; Description:            Perform a bitwise OR between FAC and a Microsoft Binary Format floating point number and store the result in FAC.
;                         The data can be located in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:     a memory address
;                         ptr_:      a pointer
;                         preserve_: ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro OR_FAC_with_ARG preserve_ {
  jsr OROP
}

!macro OR_FAC_with_Mem addr_, preserve_ {
  +Load_ARG_from_Mem addr_
  jsr OROP
}

!macro OR_FAC_with_Ptr ptr_, preserve_ {
  +Load_ARG_from_Ptr ptr_
  jsr OROP
}

; Title:                  MACRO: Compute bitwise NOT and store the result in FAC
; Name:                   NOT_FAC
;                         NOT_ARG
;                         NOT_Mem
;                         NOT_Ptr
; Description:            Perform a bitwise NOT and store the result in FAC.
;                         NOT_ARG is an exception because it operates in place rather than storing the result in FAC.
;                         The data can be located in FAC, in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:     a memory address
;                         ptr_:      a pointer
;                         preserve_: ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro NOT_FAC {
  jsr NOTOP
}

!macro NOT_ARG {
  +Swap_FAC_and_ARG
  jsr NOTOP
  +Swap_FAC_and_ARG
}

!macro NOT_Mem addr_ {
  +Load_FAC_from_Mem addr_
  jsr NOTOP
}

!macro NOT_Ptr ptr_ {
  +Load_FAC_from_Ptr ptr_
  jsr NOTOP
}
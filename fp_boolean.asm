; -----------------
; Boolean Operators
; -----------------

; Title:                  MACRO: Perform FAC AND ARG
; Name:                   AND_FAC_with_ARG
;                         AND_FAC_with_MEM
;                         AND_FAC_with_PTR
; Description:            Perform a bitwise AND between FAC and ARG.
;                         FAC and ARG must contain values that can be represented as 16-bit signed integers.
;                         ARG is destroyed in the process unless 'preserve_' is <> 0.
; Input parameters:       addr_:     a 16-bit memory address
;                         ptr_:      a zero-page pointer
;                         preserve_: if this parameter is <> 0 the contents of ARG are not destroyed by the operation
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro AND_FAC_with_ARG preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  jsr ANDOP

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro AND_FAC_with_MEM addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG addr_
  +AND_FAC_with_ARG 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro AND_FAC_with_PTR ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG_Ptr ptr_
  +AND_FAC_with_ARG 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

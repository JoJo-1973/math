; -----------------
; Boolean Operators
; -----------------

; Title:                  MACRO: Perform bitwise AND
; Name:                   AND_FAC_with_ARG
;                         AND_FAC_with_MEM
;                         AND_FAC_with_PTR
; Description:            Perform a bitwise AND between FAC and ARG / absolute address / pointed address.
;                         FAC and ARG must contain values that can be represented as 16-bit signed integers.
;                         ARG is destroyed in the process unless 'preserve_' flag is set.
; Input parameters:       addr_:     a 16-bit memory address
;                         ptr_:      a zero-page pointer
;                         preserve_: if this flag is set then the contents of ARG are undisturbed
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

  +Load_ARG_from_Mem addr_
  +AND_FAC_with_ARG 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro AND_FAC_with_PTR ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG_from_Ptr ptr_
  +AND_FAC_with_ARG 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

; Title:                  MACRO: Perform bitwise OR
; Name:                   OR_FAC_with_ARG
;                         OR_FAC_with_MEM
;                         OR_FAC_with_PTR
; Description:            Perform a bitwise OR between FAC and ARG / absolute address / pointed address.
;                         FAC and ARG must contain values that can be represented as 16-bit signed integers.
;                         ARG is destroyed in the process unless 'preserve_' flag is set.
; Input parameters:       addr_:     a 16-bit memory address
;                         ptr_:      a zero-page pointer
;                         preserve_: if this flag is set then the contents of ARG are undisturbed
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro OR_FAC_with_ARG preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  jsr OROP

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro OR_FAC_with_MEM addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG_from_Mem addr_
  +OR_FAC_with_ARG 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro OR_FAC_with_PTR ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG_from_Ptr ptr_
  +OR_FAC_with_ARG 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

; Title:                  MACRO: Perform bitwise NOT
; Name:                   NOT_FAC
;                         NOT_ARG
;                         NOT_PTR
;                         NOT_MEM
; Description:            Perform a bitwise NOT of FAC / ARG / absolute address / pointed address.
;                         Argument must contain value that can be represented as 16-bit signed integer.
;                         ARG is destroyed in the process unless 'preserve_' flag is set.
;                         NOT_FAC and NOT_ARG work in place, NOT_MEM and NOT_PTR actually perform
;                         FAC = NOT(addr_) and FAC = NOT((ptr_))
; Input parameters:       addr_:     a 16-bit memory address
;                         ptr_:      a zero-page pointer
;                         preserve_: if this flag is set then the contents of ARG are undisturbed
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro NOT_FAC {
  jsr NOTOP
}

!macro NOT_ARG {
  +Swap_FAC_and_ARG
  +NOT_FAC
  +Swap_FAC_and_ARG
}

!macro NOT_MEM addr_ {
  +Load_FAC_from_Mem addr_
  +NOT_FAC
}

!macro NOT_PTR ptr_ {
  +Load_FAC_from_Ptr ptr_
  +NOT_FAC
}
; -----------------------
; Trascendental Functions
; -----------------------

; Title:                  MACRO: Compute the natural logarithm and store the result in FAC
; Name:                   LOG_FAC
;                         LOG_Mem
;                         LOG_Ptr
; Description:            Compute the natural logarithm of a Microsoft Binary Format floating point number and store the result in FAC.
;                         The data can be located in FAC, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:      a memory address
;                         ptr_:       a pointer
;                         preserve_ : ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro LOG_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr LOG

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro LOG_Mem addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Mem addr_
  jsr LOG

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro LOG_Ptr ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Ptr ptr_
  jsr LOG

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

; Title:                  MACRO: Raise e to power and store the result in FAC
; Name:                   EXP_FAC
;                         EXP_Mem
;                         EXP_Ptr
; Description:            Raise e to the power of a Microsoft Binary Format floating point number and store the result in FAC.
;                         The data can be located in FAC, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:      a memory address
;                         ptr_:       a pointer
;                         preserve_ : ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro EXP_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr EXP

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro EXP_Mem addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Mem addr_
  jsr EXP

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro EXP_Ptr ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Ptr ptr_
  jsr EXP

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

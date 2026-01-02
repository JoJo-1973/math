; -----------------------
; Exponentiation and Root
; -----------------------

; Title:                  MACRO: Compute floating point exponentiation and store the result in FAC
; Name:                   Power_ARG_to_FAC
;                         Power_Mem_to_FAC
;                         Power_Ptr_to_FAC
; Description:            Raise a Microsoft Binary Format floating point number to the FAC power and store the result in FAC.
;                         The data can be located in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:     a memory address
;                         ptr_:      a pointer
;                         preserve_: ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Power_ARG_to_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  lda FACEXP                    ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; exponentiation routine needs to be notified of the condition to treat properly the case.
  jsr FPWRT

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro Power_Mem_to_FAC addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_ARG_from_Mem addr_
  jsr FPWRT

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro Power_Ptr_to_FAC ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_ARG_from_Ptr ptr_
  jsr FPWRT

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

; Title:                  MACRO: Compute the square root and store the result in FAC
; Name:                   SQR_FAC
;                         SQR_ARG
;                         SQR_Mem
;                         SQR_Ptr
; Description:            Compute the square root of a Microsoft Binary Format floating point number and store the result in FAC.
;                         The data can be located in FAC, in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:     a memory address
;                         ptr_:      a pointer
;                         preserve_: ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro SQR_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr SQR                       ; Perform square root: no need to prepare FACEXP in advance.

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro SQR_ARG preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Transfer_ARG_to_FAC
  jsr SQR                       ; Perform square root: no need to prepare FACEXP in advance.

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro SQR_Mem addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Mem addr_
  jsr SQR

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro SQR_Ptr ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Ptr ptr_
  jsr SQR

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

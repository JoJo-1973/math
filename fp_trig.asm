; -----------------------
; Trigonometric Functions
; -----------------------

; Title:                  MACRO: Compute the sine and store the result in FAC
; Name:                   SIN_FAC
;                         SIN_Mem
;                         SIN_Ptr
; Description:            Compute the sine of a Microsoft Binary Format floating point number and store the result in FAC.
;                         The data can be located in FAC, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:      a memory address
;                         ptr_:       a pointer
;                         preserve_ : ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro SIN_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr SIN

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro SIN_Mem addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Mem addr_
  jsr SIN

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro SIN_Ptr ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Ptr ptr_
  jsr SIN

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

; Title:                  MACRO: Compute the cosine and store the result in FAC
; Name:                   COS_FAC
;                         COS_Mem
;                         COS_Ptr
; Description:            Compute the cosine of a Microsoft Binary Format floating point number and store the result in FAC.
;                         The data can be located in FAC, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:      a memory address
;                         ptr_:       a pointer
;                         preserve_ : ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro COS_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr COS

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro COS_Mem addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Mem addr_
  jsr COS

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro COS_Ptr ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Ptr ptr_
  jsr COS

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

; Title:                  MACRO: Compute the tangent and store the result in FAC
; Name:                   TAN_FAC
;                         TAN_Mem
;                         TAN_Ptr
; Description:            Compute the tangent of a Microsoft Binary Format floating point number and store the result in FAC.
;                         The data can be located in FAC, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:      a memory address
;                         ptr_:       a pointer
;                         preserve_ : ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro TAN_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr TAN

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro TAN_Mem addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Mem addr_
  jsr TAN

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro TAN_Ptr ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Ptr ptr_
  jsr TAN

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

; Title:                  MACRO: Compute the arctangent and store the result in FAC
; Name:                   ATN_FAC
;                         ATN_Mem
;                         ATN_Ptr
; Description:            Compute the arctangent of a Microsoft Binary Format floating point number and store the result in FAC.
;                         The data can be located in FAC, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:      a memory address
;                         ptr_:       a pointer
;                         preserve_ : ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro ATN_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr ATN

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro ATN_Mem addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Mem addr_
  jsr ATN

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro ATN_Ptr ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_from_Ptr ptr_
  jsr ATN

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

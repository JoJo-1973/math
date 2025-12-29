; ----------------
; Basic Arithmetic
; ----------------

; Title:                  MACRO: Perform floating point addition and store the result in FAC
; Name:                   Add_FAC_to_ARG
;                         Add_FAC_to_Mem
;                         Add_FAC_to_Ptr
; Description:            Add FAC to a Microsoft Binary Format floating point number and store the result in FAC.
;                         The data can be located in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:      a memory address
;                         ptr_:       a pointer
;                         preserve_ : ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Add_FAC_to_ARG preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda FACSGN                    ; Apply the law of signs: bit #7 of ARISGN is 0 (+) when signs are like and 1 when signs are unlike (-).
  eor ARGSGN
  sta ARISGN

  lda FACEXP                    ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; addition routine needs to be notified of the condition to treat properly the case.
  jsr FADDT                     ; Perform addition.

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro Add_FAC_to_Mem addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda #<addr_                   ; Point .A/.Y to address.
  ldy #>addr_
  jsr FADD                      ; Perform addition: no need to prepare FACEXP or adjust signs in advance.

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro Add_FAC_to_Ptr ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda ptr_                      ; Point .A/.Y to address.
  ldy ptr_+1
  jsr FADD                      ; Perform addition: no need to prepare FACEXP or adjust signs in advance.

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

; Title:                  MACRO: Perform floating point subtraction and store the result in FAC
; Name:                   Subtract_FAC_from_ARG
;                         Subtract_FAC_from_Mem
;                         Subtract_FAC_from_Ptr
; Description:            Subtract FAC from a Microsoft Binary Format floating point number and store the result in FAC.
;                         The data can be located in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:      a memory address
;                         ptr_:       a pointer
;                         preserve_ : ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Subtract_FAC_from_ARG preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  jsr FSUBT                     ; Perform subtraction: no need to prepare FACEXP or adjust signs in advance.

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro Subtract_FAC_from_Mem addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda #<addr_                   ; Point .A/.Y to address.
  ldy #>addr_
  jsr FSUB                      ; Perform subtraction: no need to prepare FACEXP or adjust signs in advance.

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro Subtract_FAC_from_Ptr ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda ptr_                      ; Point .A/.Y to address.
  ldy ptr_+1
  jsr FSUB                      ; Perform subtraction: no need to prepare FACEXP or adjust signs in advance.

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

; Title:                  MACRO: Perform floating point multiplication and store the result in FAC
; Name:                   Multiply_FAC_by_ARG
;                         Multiply_FAC_by_Mem
;                         Multiply_FAC_by_Ptr
; Description:            Multiply FAC by a Microsoft Binary Format floating point number and store the result in FAC.
;                         The data can be located in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:      a memory address
;                         ptr_:       a pointer
;                         preserve_ : ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Multiply_FAC_by_ARG preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda FACSGN                    ; Apply the law of signs: bit #7 of ARISGN is 0 (+) when signs are like and 1 when signs are unlike (-).
  eor ARGSGN
  sta ARISGN

  lda FACEXP                    ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; multiplication routine needs to be notified of the condition to treat properly the case
  jsr FMULTT                    ; Perform multiplication.

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro Multiply_FAC_by_Mem addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda #<addr_                   ; Point .A/.Y to address.
  ldy #>addr_
  jsr FMULT                     ; Perform multiplication: no need to prepare FACEXP or adjust signs in advance.

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro Multiply_FAC_by_Ptr ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda ptr_                      ; Point .A/.Y to address.
  ldy ptr_+1
  jsr FMULT                     ; Perform multiplication: no need to prepare FACEXP or adjust signs in advance.

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

; Title:                  MACRO: Perform floating point division and store the result in FAC
; Name:                   Divide_ARG_by_FAC
;                         Divide_Mem_by_FAC
;                         Divide_Ptr_by_FAC
; Description:            Divide a Microsoft Binary Format floating point number by FAC and store the result in FAC.
;                         The data can be located in ARG, at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_:      a memory address
;                         ptr_:       a pointer
;                         preserve_ : ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Divide_ARG_by_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda FACSGN                    ; Apply the law of signs: bit #7 of ARISGN is 0 (+) when signs are like and 1 when signs are unlike (-).
  eor ARGSGN
  sta ARISGN

  lda FACEXP                    ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; division routine needs to be notified of the condition to treat properly the case
  jsr FDIVT                     ; Perform division.

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro Divide_Mem_by_FAC addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda #<addr_                   ; Point .A/.Y to address.
  ldy #>addr_
  jsr FDIV                      ; Perform division: no need to prepare FACEXP or adjust signs in advance.

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

!macro Divide_Ptr_by_FAC ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda ptr_                      ; Point .A/.Y to address.
  ldy ptr_+1
  jsr FDIV                      ; Perform division: no need to prepare FACEXP or adjust signs in advance.

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

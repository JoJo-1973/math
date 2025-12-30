; -----------
; Polynomials
; -----------

; Title:                  MACRO: Compute an univariate polynomial of n-th degree
; Name:                   Poly_Mem
;                         Poly_Ptr
; Description:            Compute a polynomial at a point stored in FAC using a table of coefficients.
;                         The polynomial is expressed as a_n*x^n + a_(n-1)*x^(n-1) + ... + a_2*x^2 + a_1*x + a_0.
;                         The data can be located at an absolute memory address or referenced to by a pointer.
;                         The first byte of the table is 'n', the degree of the polynomial;
;                         following there are n floating point values in Microsoft Binary Format,
;                         expressing the coefficients from a_n to a_0.
; Input parameters:       addr_:     a memory address
;                         ptr_:      a pointer
;                         preserve_: ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Poly_Mem addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  lda #<addr_
  ldy #>addr_
  jsr POLY2

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro Poly_Ptr ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  lda ptr_
  ldy ptr_+1
  jsr POLY2

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

; Title:                  MACRO: Compute an univariate odd polynomial of n-th degree
; Name:                   Odd_Poly_Mem
;                         Odd_Poly_Ptr
; Description:            Compute an odd polynomial at a point stored in FAC using a table of coefficients.
;                         The polynomial is expressed as a_n*x^n + a_(n-2)*x^(n-2) + ... + a_3*x^3 + a_1*x, where 'n' is an odd number.
;                         The data can be located at an absolute memory address or referenced to by a pointer.
;                         The first byte of the table is '(n-1)/2', the degree of the polynomial;
;                         following there are (n-1)/2 floating point values in Microsoft Binary Format,
;                         expressing the coefficients from a_n to a_1.
; Input parameters:       addr_:     a memory address
;                         ptr_:      a pointer
;                         preserve_: ARG is destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Odd_Poly_Mem addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  lda #<addr_
  ldy #>addr_
  jsr POLY1

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

!macro Odd_Poly_Ptr ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK     ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  lda ptr_
  ldy ptr_+1
  jsr POLY1

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
}

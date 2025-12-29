; -----------
; Polynomials
; -----------

; Macro Polynomial_in_FAC: Computes an univariate polynomial of nth degree whose variable is FAC.
; ARG is destroyed in the process unless 'preserve_' is <> 0.
;
; The polynomial is expressed as a_n*x^n + a_(n-1)*x^(n-1) + ... + a_2*x^2 + a_1*x + a_0
;
; The parameter 'coeff_' points to a memory area where the first byte is
; 'n', the degree of the polynomial, followed by n floating point values
; in Microsoft Binary Format, from a_n to a_0.
!macro Polynomial_in_FAC coeff_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  lda #<coeff_
  ldy #>coeff_

  jsr POLY2

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
  +Adjust_Signs
}

; Macro Odd_Polynomial_in_FAC: Computes an univariate odd polynomial of nth degree whose variable is FAC.
; ARG is destroyed in the process unless 'preserve_' is <> 0.
;
; The polynomial is expressed as a_n*x^n + a_(n-2)*x^(n-2) + ... + a_3*x^3 + a_1*x, where n is an odd number.
;
; The parameter 'coeff_' points to a memory area where the first byte is
; '(n-1)/2', the degree of the polynomial, followed by '(n+1)/2' floating point values
; in Microsoft Binary Format, from a_n to a_0.
!macro Odd_Polynomial_in_FAC coeff_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  lda #<coeff_
  ldy #>coeff_

  jsr POLY1

  !if (preserve_) {
    +Load_ARG_from_Mem STACK
  }
  +Adjust_Signs
}
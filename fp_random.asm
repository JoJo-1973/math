; ------------------------
; Random Numbers Generator
; ------------------------

; Title:                  MACRO: Generate a pseudo-random number and put it into FAC
; Name:                   Load_FAC_with_RND
; Description:            A pseudo-random floating point number between 0 and 1 (excluded) is generated into FAC.
;                         The random number generator must be seeded in advance.
;                         Current FAC content dictates how the random number is generated:
;                           * FAC > 0: value is replaced with new pseudo-random number in the actual sequence.
;                           * FAC = 0: a new seed is generated from timer values in register of CIA #1 and put into FAC.
;                           * FAC < 0: the pseudo-random number generator is re-seeded with the number in FAC.
;
;                         The behaviour of FAC = 0 is flawed because the relevant registers are not properly initialized
;                         on startup and some of them work in BCD mode, meaning that they will never return all possible
;                         values, restricting the space of the possible seeds.
;                         For each possible negative value of arg_ the same pseudo-random sequence will be generated:
;                         an useful property for testing and debug.
; Input parameters:       ---
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Load_FAC_with_RND preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  jsr RND

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
}

; Title:                  MACRO: Initialize the pseudo-random number generator
; Name:                   Randomize
; Description:            The pseudo-random number generator is seeded with -TI: since TI is a 24-bits number
;                         the remaining 8 bit will always be 0, limiting the space of possible seeds.
;                         To minimize the issue a new seed is immediately generated from the full 32-bits number
;                         now available in the FAC. In BASIC language the seed is RND(-RND(-TI)).
;
;                         WARNING: ARG is destroyed in the process!
; Input parameters:       ---
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Randomize {
  +Load_FAC_with_UINT24_Mem TIME; Ensure that FAC is loaded with a positive number
  +Negate_FAC                   ; but the MSB of the mantissa is always $00; then
  jsr RND                       ; negate it and seed the pseudo-RNG.

  +Negate_FAC                   ; FAC is certainly positive, but all 32 bits of the mantissa are now properly set
  jsr RND                       ; therefore FAC can be negated and used to reseed the pseudo-RNG.
}

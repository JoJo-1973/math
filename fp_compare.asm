; -----------
; Comparisons
; -----------

; Title:                  MACRO: Compare FAC with a floating point number
; Name:                   Compare_FAC_to_ARG
;                         Compare_FAC_to_Mem
;                         Compare_FAC_to_Ptr
; Description:            Compare a Microsoft Binary Format floating point number by FAC and return the result in .A.
;                         The data can be located in ARG, at an absolute memory address or referenced to by a pointer.
;                           .A = $00 if FAC = ARG
;                           .A = $01 if FAC > ARG
;                           .A = $FF if FAC < ARG
; Input parameters:       addr_: a memory address
;                         ptr_:  a pointer
; Output parameters:      .A
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Compare_FAC_to_ARG {
  +Store_ARG_to_Mem STACK       ; The BASIC routine FCOMP can't work directly with ARG because it contains
                                ; UNPACKED floating point numbers: therefore ARG is stored in packed format
                                ; in a temporary location (the bottom of stack).
  lda #<STACK                   ; Point .A/.Y to address.
  ldy #>STACK
  jsr FCOMP
}

!macro Compare_FAC_to_Mem addr_ {
  lda #<addr_                   ; Point .A/.Y to address.
  ldy #>addr_
  jsr FCOMP
}

!macro Compare_FAC_to_Ptr ptr_ {
  lda ptr_                      ; Point .A/.Y to address.
  ldy ptr_+1
  jsr FCOMP
}

; -----------
; Comparisons
; -----------

; Macro Compare [FAC/ARG]_to_0: Fast comparison of FAC / Arg with 0.
!macro Compare_FAC_to_0 {
  lda FACEXP                    ; Any fp value with null exponent is considered 0: set .Z flag accordingly.
}

!macro Compare_ARG_to_0 {
  lda ARGEXP                    ; Any fp value with null exponent is considered 0: set .Z flag accordingly.
}

; Macro Compare FAC to ARG: comparison of FAC to ARG.
; .A = $00 if FAC = ARG; .A = $01 if FAC > ARG; .A = $FF if FAC < ARG.
!macro Compare_FAC_to_ARG {
  +Store_ARG STACK              ; The BASIC routine FCOMP can't work directly with ARG because
                                ; it expects a 5-bytes floating point, therefore ARG is stored
                                ; in a temporary location (the bottom of stack).
  lda #<STACK
  ldy #>STACK
  jsr FCOMP
}

; Macro Compare FAC with MEM: comparison of FAC to Memory.
; .A = $00 if FAC = Memory; .A = $01 if FAC > Memory; .A = $FF if FAC < Memory.
!macro Compare_FAC_to_MEM addr_ {
  lda #<addr_
  ldy #>addr_
  jsr FCOMP
}

; Macro Compare FAC with PTR: comparison of FAC to (Ptr).
; .A = $00 if FAC = (Ptr); .A = $01 if FAC > (Ptr); .A = $FF if FAC < (Ptr).
!macro Compare_FAC_to_PTR ptr_ {
  lda ptr_
  ldy ptr_+1
  jsr FCOMP
}

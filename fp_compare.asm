; -----------
; Comparisons
; -----------

; Macro Compare FAC to ARG: comparison of FAC to ARG.
; .A = $00 if FAC = ARG; .A = $01 if FAC > ARG; .A = $FF if FAC < ARG.
!macro Compare_FAC_to_ARG {
  +Store_ARG_to_Mem STACK              ; The BASIC routine FCOMP can't work directly with ARG because
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

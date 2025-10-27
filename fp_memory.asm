; --------------------------
; Memory manipulation macros
; --------------------------

; Macro +Load_[FAC/ARG]: Load FAC or ARG with a 5-bytes floating point value stored at a memory address.
!macro Load_FAC addr_ {
  lda #<addr_                   ; Point .A/.Y to address.
  ldy #>addr_

  jsr MOVFM                     ; Copy to ARG and adjust signs.
  +Adjust_Signs
}

!macro Load_ARG addr_ {
  lda #<addr_                   ; Point .A/.Y to address.
  ldy #>addr_

  jsr CONUPK                    ; Copy to ARG and adjust signs.
  +Adjust_Signs
}

; Macro +Load_[FAC/ARG]_Ptr: Load FAC or ARG with a 5-bytes floating point value stored at a memory address in a pointer.
!macro Load_FAC_Ptr ptr_ {
  lda ptr_                      ; Point .A/.Y to address.
  ldy ptr_+1

  jsr MOVFM                     ; Copy to ARG and adjust signs.
  +Adjust_Signs
}

!macro Load_ARG_Ptr ptr_ {
  lda ptr_                      ; Point .A/.Y to address.
  ldy ptr_+1

  jsr CONUPK                    ; Copy to ARG and adjust signs.
  +Adjust_Signs
}

; Macro +Store_[FAC/ARG]: Store FAC or ARG to a memory address in 5-bytes format.
!macro Store_FAC addr_ {
  ldx #<addr_                   ; Point .X/.Y to address.
  ldy #>addr_

  jsr ROUND                     ; Round FAC1 then store it.
  jsr MOV2F+16                  ; MOV2F has multiple entry points, skip them.
}

!macro Store_ARG addr_ {
  ldx #<addr_                   ; Point .X/.Y to address.
  ldy #>addr_
  stx INDEX                     ; Store address in INDEX, the pointer used by kernal for this kind of operations.
  sty INDEX+1

  ldy #$04                      ; 5 bytes to move.

  lda ARGLO                     ; Store LSB of mantissa.
  sta (INDEX),y
  dey

  lda ARGMO                     ; Store 3rd MSB of mantissa.
  sta (INDEX),y
  dey

  lda ARGMOH                    ; Store 2nd MSB of mantissa:
  sta (INDEX),y
  dey

  lda ARGSGN                    ; Create a bitmask in .A:
  ora #%01111111                ; $7F if ARGSGN is negative, $FF if ARGSGN is positive
  and ARGHO                     ; and apply it to MSB of mantissa, then store it.
  sta (INDEX),y
  dey

  lda ARGEXP                    ; Store exponent byte.
  sta (INDEX),y
  rts
}

; Macro +Store_[FAC/ARG]_Ptr: Store FAC or ARG to a memory address in a pointer in 5-bytes format.
!macro Store_FAC_Ptr ptr_ {
  ldx ptr_                      ; Point .X/.Y to address.
  ldy ptr_+1

  jsr ROUND                     ; Round FAC1 then store it.
  jsr MOV2F+16                  ; MOV2F has multiple entry points, skip them.
}

!macro Store_ARG_Ptr ptr_ {
  ldx ptr_                      ; Point .X/.Y to address.
  ldy ptr_+1
  stx INDEX                     ; Store address in INDEX, the pointer used by kernal for this kind of operations.
  sty INDEX+1

  ldy #$04                      ; 5 bytes to move.

  lda ARGLO                     ; Store LSB of mantissa.
  sta (INDEX),y
  dey

  lda ARGMO                     ; Store 3rd MSB of mantissa.
  sta (INDEX),y
  dey

  lda ARGMOH                    ; Store 2nd MSB of mantissa:
  sta (INDEX),y
  dey

  lda ARGSGN                    ; Create a bitmask in .A:
  ora #%01111111                ; $7F if ARGSGN is negative, $FF if ARGSGN is positive
  and ARGHO                     ; and apply it to MSB of mantissa, then store it.
  sta (INDEX),y
  dey

  lda ARGEXP                    ; Store exponent byte.
  sta (INDEX),y
  rts
}

; Macro +Transfer_FAC_to_ARG: Copy a rounded value of FAC into ARG.
!macro Transfer_FAC_to_ARG {
  jsr MOVAF                     ; Copy FAC to ARG:
  stx ARISGN                    ; now FAC and ARG have same signs.
}

; Macro +Transfer_ARG_to_FAC: Copy ARG into FAC.
!macro Transfer_ARG_to_FAC {
  jsr MOVFA                     ; Copy ARG to FAC:
  stx ARISGN                    ; now FAC and ARG have same signs.
}

; Macro +Swap_FAC_and_ARG: Swap contents of FAC and ARG.
!macro Swap_FAC_and_ARG {
  jsr ROUND                     ; Anything moving out of FAC must be rounded before.
  +Store_FAC_in_Scratch         ; Save rounded FAC in _SCRATCH_1.

  jsr MOVFA                     ; Copy ARG to FAC.

  lda _SCRATCH_1                ; Restore exponent byte of FAC into ARG.
  sta ARGEXP

  lda _SCRATCH_1+1              ; Restore MSB of mantissa of FAC into ARG.
  sta ARGHO

  lda _SCRATCH_1+2              ; Restore 2nd MSB of mantissa of FAC into ARG.
  sta ARGMOH

  lda _SCRATCH_1+3              ; Restore 3rd MSB of mantissa of FAC into ARG.
  sta ARGMO

  lda _SCRATCH_1+4              ; Restore LSB of mantissa of FAC into ARG.
  sta ARGLO

  lda _SCRATCH_1+5              ; Restore sign byte of FAC into ARG.
  sta ARGSGN

  +Adjust_Signs
}

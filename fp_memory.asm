; -------------------
; Memory Manipulation
; -------------------

; Title:                  MACRO: Load data from memory into FAC or ARG
; Name:                   Load_FAC_from_Mem
;                         Load_FAC_from_Ptr
;                         Load_ARG_from_Mem
;                         Load_ARG_from_Ptr
; Description:            Load floating point accumulator with a Microsoft Binary Format floating point number from memory.
;                         The data can be located at an absolute memory address or referenced to by a pointer.
; Input parameters:       addr_: a memory address
;                         ptr_:  a pointer
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Load_FAC_from_Mem addr_ {
  lda #<addr_                   ; Point .A/.Y to address.
  ldy #>addr_

  jsr MOVFM                     ; Copy to FAC.
}

!macro Load_FAC_from_Ptr ptr_ {
  lda ptr_                      ; Point .A/.Y to address.
  ldy ptr_+1

  jsr MOVFM                     ; Copy to FAC.
}

!macro Load_ARG_from_Mem addr_ {
  lda #<addr_                   ; Point .A/.Y to address.
  ldy #>addr_

  jsr CONUPK                    ; Copy to ARG.
}

!macro Load_ARG_from_Ptr ptr_ {
  lda ptr_                      ; Point .A/.Y to address.
  ldy ptr_+1

  jsr CONUPK                    ; Copy to ARG.
}

; Title:                  MACRO: Store FAC or ARG to memory
; Name:                   Store_FAC_to_Mem
;                         Store_FAC_to_Ptr
;                         Store_ARG_to_Mem
;                         Store_ARG_to_Ptr
; Description:            Store FAC or ARG to an absolute memory address or to a location referenced by a pointer.
; Input parameters:       addr_: a  memory address
;                         ptr_:  a pointer
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Store_FAC_to_Mem addr_ {
  ldx #<addr_                   ; Point .X/.Y to address.
  ldy #>addr_

  jsr MOVMF                     ; Round FAC then store it.
}

!macro Store_FAC_to_Ptr ptr_ {
  ldx ptr_                      ; Point .X/.Y to address.
  ldy ptr_+1

  jsr MOVMF                     ; Round FAC then store it.
}

!macro Store_ARG_to_Mem addr_ {
  lda ARGEXP                    ; Store exponent byte.
  sta addr_

  lda ARGSGN                    ; Store MSB of mantissa:
  ora #%01111111                ; create a bitmask in .A:
  and ARGHO                     ; $7F if ARGSGN is negative, $FF if ARGSGN is positive
  sta addr_+1                   ; and apply it to MSB of mantissa, then store it.

  lda ARGMOH                    ; Store 2nd MSB of mantissa.
  sta addr_+2

  lda ARGMO                     ; Store 3rd MSB of mantissa.
  sta addr_+3

  lda ARGLO                     ; Store LSB of mantissa.
  sta addr_+4
}

!macro Store_ARG_to_Ptr ptr_ {
  ldx ptr_                      ; Point .X/.Y to address.
  ldy ptr_+1
  stx INDEX                     ; Store address in INDEX, the pointer used by kernal for this kind of operations.
  sty INDEX+1

  ldy #$00

  lda ARGEXP                    ; Store exponent byte.
  sta (INDEX),y

  iny                           ; Store MSB of mantissa:
  lda ARGSGN                    ; create a bitmask in .A:
  ora #%01111111                ; $7F if ARGSGN is negative, $FF if ARGSGN is positive
  and ARGHO                     ; and apply it to MSB of mantissa, then store it.
  sta (INDEX),y

  iny                           ; Store 2nd MSB of mantissa.
  lda ARGMOH
  sta (INDEX),y

  iny                           ; Store 3rd MSB of mantissa.
  lda ARGMO
  sta (INDEX),y

  iny                           ; Store LSB of mantissa.
  lda ARGLO
  sta (INDEX),y
}

; Title:                  MACRO: Transfer FAC to ARG or viceversa
; Name:                   Transfer_FAC_to_ARG
;                         Transfer_ARG_to_FAC
; Description:            Copy FAC to ARG or viceversa. FAC is rounded before transfer because ARG can't handle unrounded values.
; Input parameters:       ---
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Transfer_FAC_to_ARG {
  jsr MOVAF                     ; Round FAC and copy it to ARG.
}

!macro Transfer_ARG_to_FAC {
  jsr MOVFA                     ; Copy ARG to FAC.
}

; Title:                  MACRO: Swap FAC and ARG
; Name:                   Swap_FAC_and_ARG
; Description:            Swap FAC and ARG. FAC is rounded before transfer because ARG can't handle unrounded values.
; Input parameters:       ---
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Swap_FAC_and_ARG {
  +Store_ARG_in_Scratch         ; Save ARG in _SCRATCH_2.

  jsr MOVAF                     ; Round FAC and copy it to ARG.

  lda _SCRATCH_2                ; Restore exponent byte of ARG into FAC.
  sta FACEXP

  lda _SCRATCH_2+1              ; Restore MSB of mantissa of ARG into FAC.
  sta FACHO

  lda _SCRATCH_2+2              ; Restore 2nd MSB of mantissa of ARG into FAC.
  sta FACMOH

  lda _SCRATCH_2+3              ; Restore 3rd MSB of mantissa of ARG into FAC.
  sta FACMO

  lda _SCRATCH_2+4              ; Restore LSB of mantissa of ARG into FAC.
  sta FACLO

  lda _SCRATCH_2+5              ; Restore sign byte of ARG into FAC.
  sta FACSGN

  lda #$00                      ; Clear FAC rounding byte since value in ARG is always rounded.
  sta FACOV
}

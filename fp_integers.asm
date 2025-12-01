; -------------------------------
; Loading Integers into FAC / ARG
; -------------------------------

; Title:                  MACRO: Load unsigned 8-bit integer into FAC
; Name:                   Load_FAC_with_UINT8
;                         Load_FAC_with_UINT8_Mem
;                         Load_FAC_with_UINT8_Ptr
; Description:            Load floating point accumulator with an unsigned 8-bit integer.
;                         The value can be expressed directly as argument of the macro,
;                         can be stored at a memory address or can be pointed at
;                         by a zero-page pointer.
; Input parameters:       value_: an 8-bit number
;                         addr_:  a 16-bit memory address
;                         ptr_:   a zero-page pointer
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  symbols.asm, standard.asm, kernal.asm, vic_ii.asm
!macro Load_FAC_with_UNIT8 value_ {
  lda #(value & $FF)            ; Prepare mantissa.
  sta FACHO
  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.
  jsr $BC4F
}

!macro Load_FAC_with_UNIT8_Mem addr_ {
  lda addr_                     ; Prepare mantissa.
  sta FACHO
  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.
  jsr $BC4F
}

!macro Load_FAC_with_UNIT8_Ptr ptr_ {
  ldy #0                        ; Prepare mantissa.
  lda (ptr_),y
  sta FACHO
  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.
  jsr $BC4F
}

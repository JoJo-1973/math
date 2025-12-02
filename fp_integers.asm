; -------------------------------
; Loading Integers into FAC / ARG
; -------------------------------

; Title:                  MACRO: Load unsigned 8-bit integer into FAC or ARG
; Name:                   Load_FAC_with_UINT8
;                         Load_FAC_with_UINT8_Mem
;                         Load_FAC_with_UINT8_Ptr
;                         Load_ARG_with_UINT8
;                         Load_ARG_with_UINT8_Mem
;                         Load_ARG_with_UINT8_Ptr
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
!macro Load_FAC_with_UINT8 value_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  lda #(value_ & $FF)           ; Prepare mantissa.
  sta FACHO

  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  jsr $BC4F
}

!macro Load_FAC_with_UINT8_Mem addr_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  lda addr_                     ; Prepare mantissa.
  sta FACHO
  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  jsr $BC4F
}

!macro Load_FAC_with_UINT8_Ptr ptr_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  ldy #0                        ; Prepare mantissa.
  lda (ptr_),y
  sta FACHO
  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  jsr $BC4F
}

!macro Load_ARG_with_UINT8 value_ {
  +Swap_FAC_and_ARG
  lda #(value_ & $FF)           ; Prepare mantissa.
  sta FACHO
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  jsr $BC4F
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_UINT8_Mem addr_ {
  +Swap_FAC_and_ARG
  lda addr_                     ; Prepare mantissa.
  sta FACHO
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  jsr $BC4F
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_UINT8_Ptr ptr_ {
  +Swap_FAC_and_ARG
  ldy #0                        ; Prepare mantissa.
  lda (ptr_),y
  sta FACHO
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  jsr $BC4F
  +Swap_FAC_and_ARG
}

; Title:                  MACRO: Load signed 8-bit integer into FAC or ARG
; Name:                   Load_FAC_with_INT8
;                         Load_FAC_with_INT8_Mem
;                         Load_FAC_with_INT8_Ptr
;                         Load_ARG_with_INT8
;                         Load_ARG_with_INT8_Mem
;                         Load_ARG_with_INT8_Ptr
; Description:            Load floating point accumulator with a signed 8-bit integer.
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
!macro Load_FAC_with_INT8 value_ {
  lda #(value_ & $FF)            ; Prepare mantissa.
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  jsr $BC4F
}

!macro Load_FAC_with_INT8_Mem addr_ {
  lda addr_                     ; Prepare mantissa.
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  jsr $BC4F
}

!macro Load_FAC_with_INT8_Ptr ptr_ {
  ldy #0                        ; Prepare mantissa.
  lda (ptr_),y
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  jsr $BC4F
}

!macro Load_ARG_with_INT8 value_ {
  +Swap_FAC_and_ARG
  lda #(value_ & $FF)            ; Prepare mantissa.
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  jsr $BC4F
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_INT8_Mem addr_ {
  +Swap_FAC_and_ARG
  lda addr_                     ; Prepare mantissa.
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  jsr $BC4F
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_INT8_Ptr ptr_ {
  +Swap_FAC_and_ARG
  ldy #0                        ; Prepare mantissa.
  lda (ptr_),y
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits

  jsr $BC4F
  +Swap_FAC_and_ARG
}

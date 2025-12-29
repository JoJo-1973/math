; --------------------------------------
; Loading Binary Integers into FAC / ARG
; --------------------------------------

; Title:                  MACRO: Load unsigned 8-bits integer into FAC or ARG
; Name:                   Load_FAC_with_UINT8
;                         Load_FAC_with_UINT8_Mem
;                         Load_FAC_with_UINT8_Ptr
;                         Load_ARG_with_UINT8
;                         Load_ARG_with_UINT8_Mem
;                         Load_ARG_with_UINT8_Ptr
; Description:            Load floating point accumulator with an unsigned 8-bits integer.
;                         The value can be expressed directly as argument of the macro,
;                         can be stored at a memory address or referenced to by a pointer.
; Input parameters:       value_: an 8-bits constant
;                         addr_:  a  memory address
;                         ptr_:   a pointer
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Load_FAC_with_UINT8 value_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  lda #(value_ & $FF)           ; Prepare mantissa.
  sta FACHO

  !if (value_ & $FF) {
    lda #0
  }
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
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

  ldx #$88                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
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

  ldx #$88                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_ARG_with_UINT8 value_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_UINT8 value_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_UINT8_Mem addr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_UINT8_Mem addr_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_UINT8_Ptr ptr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_UINT8_Ptr ptr_
  +Swap_FAC_and_ARG
}

; Title:                  MACRO: Load signed 8-bits integer into FAC or ARG
; Name:                   Load_FAC_with_INT8
;                         Load_FAC_with_INT8_Mem
;                         Load_FAC_with_INT8_Ptr
;                         Load_ARG_with_INT8
;                         Load_ARG_with_INT8_Mem
;                         Load_ARG_with_INT8_Ptr
; Description:            Load floating point accumulator with a signed 8-bits integer.
;                         The value can be expressed directly as argument of the macro,
;                         can be stored at a memory address or referenced to by a pointer.
; Input parameters:       value_: an 8-bits constant
;                         addr_:  a  memory address
;                         ptr_:   a pointer
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Load_FAC_with_INT8 value_ {
  lda #(value_ & $FF)            ; Prepare mantissa.
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda #0
  sta FACMOH
  sta FACMO
  sta FACLO

  ldx #$88                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
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

  ldx #$88                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
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

  ldx #$88                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_ARG_with_INT8 value_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_INT8 value_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_INT8_Mem addr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_INT8_Mem addr_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_INT8_Ptr ptr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_INT8_Ptr ptr_
  +Swap_FAC_and_ARG
}

; Title:                  MACRO: Load unsigned 16-bits integer into FAC or ARG
; Name:                   Load_FAC_with_UINT16
;                         Load_FAC_with_UINT16_Mem
;                         Load_FAC_with_UINT16_Ptr
;                         Load_ARG_with_UINT16
;                         Load_ARG_with_UINT16_Mem
;                         Load_ARG_with_UINT16_Ptr
; Description:            Load floating point accumulator with an unsigned 16-bits integer.
;                         The value can be expressed directly as argument of the macro,
;                         can be stored at a memory address or referenced to by a pointer.
; Input parameters:       value_: a 16-bits constant
;                         addr_:  a memory address
;                         ptr_:   a pointer
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Load_FAC_with_UINT16 value_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  lda #(value_ & $FF00) >> 8    ; Prepare mantissa.
  sta FACHO

  !if ((value_ & $FF00) >> 8) - (value_ & $00FF) {
    lda #(value_ & $00FF)
  }
  sta FACMOH

  !if (value_ & $00FF) {
    lda #0
  }
  sta FACMO
  sta FACLO

  ldx #$90                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_FAC_with_UINT16_Mem addr_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  lda addr_+1                   ; Prepare mantissa.
  sta FACHO
  lda addr_
  sta FACMOH

  lda #0
  sta FACMO
  sta FACLO

  ldx #$90                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_FAC_with_UINT16_Ptr ptr_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  ldy #1                        ; Prepare mantissa.
  lda (ptr_),y
  sta FACHO
  dey
  lda (ptr_),y
  sta FACMOH

  lda #0
  sta FACMO
  sta FACLO

  ldx #$90                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_ARG_with_UINT16 value_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_UINT16 value_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_UINT16_Mem addr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_UINT16_Mem addr_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_UINT16_Ptr ptr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_UINT16_Ptr ptr_
  +Swap_FAC_and_ARG
}

; Title:                  MACRO: Load signed 16-bits integer into FAC or ARG
; Name:                   Load_FAC_with_INT16
;                         Load_FAC_with_INT16_Mem
;                         Load_FAC_with_INT16_Ptr
;                         Load_ARG_with_INT16
;                         Load_ARG_with_INT16_Mem
;                         Load_ARG_with_INT16_Ptr
; Description:            Load floating point accumulator with a signed 16-bits integer.
;                         The value can be expressed directly as argument of the macro,
;                         can be stored at a memory address or referenced to by a pointer.
; Input parameters:       value_: a 16-bits constant
;                         addr_:  a memory address
;                         ptr_:   a pointer
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Load_FAC_with_INT16 value_ {
  lda #(value_ & $FF00) >> 8    ; Prepare mantissa.
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda #(value_ & $00FF)
  sta FACMOH

  !if (value_ & $00FF) {
    lda #0
  }
  sta FACMO
  sta FACLO

  ldx #$90                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_FAC_with_INT16_Mem addr_ {
  lda addr_+1                   ; Prepare mantissa.
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda addr_
  sta FACMOH

  lda #0
  sta FACMO
  sta FACLO

  ldx #$90                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_FAC_with_INT16_Ptr ptr_ {
  ldy #1                        ; Prepare mantissa.
  lda (ptr_),y
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  dey
  lda (ptr_),y
  sta FACMOH

  lda #0
  sta FACMO
  sta FACLO

  ldx #$90                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_ARG_with_INT16 value_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_INT16 value_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_INT16_Mem addr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_INT16_Mem addr_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_INT16_Ptr ptr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_INT16_Ptr ptr_
  +Swap_FAC_and_ARG
}

; Title:                  MACRO: Load unsigned 24-bits integer into FAC or ARG
; Name:                   Load_FAC_with_UINT24
;                         Load_FAC_with_UINT24_Mem
;                         Load_FAC_with_UINT24_Ptr
;                         Load_ARG_with_UINT24
;                         Load_ARG_with_UINT24_Mem
;                         Load_ARG_with_UINT24_Ptr
; Description:            Load floating point accumulator with an unsigned 24-bits integer.
;                         The value can be expressed directly as argument of the macro,
;                         can be stored at a memory address or referenced to by a pointer.
; Input parameters:       value_: a 24-bits constant
;                         addr_:  a memory address
;                         ptr_:   a pointer
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Load_FAC_with_UINT24 value_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  lda #(value_ & $FF0000) >> 16 ; Prepare mantissa.
  sta FACHO

  !if ((value_ & $FF0000) >> 16) - ((value_ & $00FF00) >> 8) {
    lda #(value_ & $00FF00) >> 8
  }
  sta FACMOH

  !if ((value_ & $00FF00) >> 8) - (value_ &0000FF) {
    lda #(value_ &0000FF)
  }
  sta FACMO

  !if (value_ &0000FF) {
    lda #0
  }
  sta FACLO

  ldx #$98                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_FAC_with_UINT24_Mem addr_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  lda addr_+2                   ; Prepare mantissa.
  sta FACHO
  lda addr_+1
  sta FACMOH
  lda addr_
  sta FACMO

  lda #0
  sta FACLO

  ldx #$98                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_FAC_with_UINT24_Ptr ptr_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  ldy #2                        ; Prepare mantissa.
  lda (ptr_),y
  sta FACHO
  dey
  lda (ptr_),y
  sta FACMOH
  dey
  lda (ptr_),y
  sta FACMO

  lda #0
  sta FACLO

  ldx #$98                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_ARG_with_UINT24 value_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_UINT24 value_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_UINT24_Mem addr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_UINT24_Mem addr_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_UINT24_Ptr ptr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_UINT24_Ptr ptr_
  +Swap_FAC_and_ARG
}

; Title:                  MACRO: Load signed 24-bits integer into FAC or ARG
; Name:                   Load_FAC_with_INT24
;                         Load_FAC_with_INT24_Mem
;                         Load_FAC_with_INT24_Ptr
;                         Load_ARG_with_INT24
;                         Load_ARG_with_INT24_Mem
;                         Load_ARG_with_INT24_Ptr
; Description:            Load floating point accumulator with a signed 24-bits integer.
;                         The value can be expressed directly as argument of the macro,
;                         can be stored at a memory address or referenced to by a pointer.
; Input parameters:       value_: a 24-bits constant
;                         addr_:  a memory address
;                         ptr_:   a pointer
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Load_FAC_with_INT24 value_ {
  lda #(value_ & $FF0000) >> 16 ; Prepare mantissa.
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda #(value_ & $00FF00) >> 8
  sta FACMOH

  !if ((value_ & $00FF00) >> 8) - (value_ & $0000FF) {
    lda #(value_ & $0000FF)
  }
  sta FACMO

  !if (value_ & $0000FF) {
    lda #0
  }
  sta FACLO

  ldx #$98                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_FAC_with_INT24_Mem addr_ {
  lda addr_+2                   ; Prepare mantissa.
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda addr_+1
  sta FACMOH
  lda addr_
  sta FACMO

  lda #0
  sta FACLO

  ldx #$98                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_FAC_with_INT24_Ptr ptr_ {
  ldy #2                        ; Prepare mantissa.
  lda (ptr_),y
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  dey
  lda (ptr_),y
  sta FACMOH
  dey
  lda (ptr_),y
  sta FACMO

  lda #0
  sta FACLO

  ldx #$98                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_ARG_with_INT24 value_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_INT24 value_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_INT24_Mem addr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_INT24_Mem addr_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_INT24_Ptr ptr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_INT24_Ptr ptr_
  +Swap_FAC_and_ARG
}

; Title:                  MACRO: Load unsigned 32-bits integer into FAC or ARG
; Name:                   Load_FAC_with_UINT32
;                         Load_FAC_with_UINT32_Mem
;                         Load_FAC_with_UINT32_Ptr
;                         Load_ARG_with_UINT32
;                         Load_ARG_with_UINT32_Mem
;                         Load_ARG_with_UINT32_Ptr
; Description:            Load floating point accumulator with an unsigned 32-bits integer.
;                         The value can be expressed directly as argument of the macro,
;                         can be stored at a memory address or referenced to by a pointer.
; Input parameters:       value_: a 32-bits constant
;                         addr_:  a memory address
;                         ptr_:   a pointer
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Load_FAC_with_UINT32 value_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  lda #(value_ & $FF000000) >> 24 ; Prepare mantissa.
  sta FACHO

  !if ((value_ & $FF000000) >> 24) - ((value_ & $00FF0000) >> 16) {
    lda #(value_ & $00FF0000) >> 16
  }
  sta FACMOH

  !if ((value_ & $00FF0000) >> 16) - ((value_ & $0000FF00) >> 8) {
    lda #(value_ & $0000FF00) >> 8
  }
  sta FACMO

  !if ((value_ &0000FF00) >> 8) - (value_ & $000000FF) {
    lda #(value_ & $000000FF)
  }
  sta FACLO

  !if (value_ & $000000FF) {
    lda #0
  }
  ldx #$A0                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_FAC_with_UINT32_Mem addr_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  lda addr_+3                   ; Prepare mantissa.
  sta FACHO
  lda addr_+2
  sta FACMOH
  lda addr_+1
  sta FACMO
  lda addr_
  sta FACLO

  lda #0
  ldx #$A0                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_FAC_with_UINT32_Ptr ptr_ {
  sec                           ; C = 1, force conversion to unsigned integer.
                                ; C = 0, force conversion to signed integer.

  ldy #3                        ; Prepare mantissa.
  lda (ptr_),y
  sta FACHO
  dey
  lda (ptr_),y
  sta FACMOH
  dey
  lda (ptr_),y
  sta FACMO
  dey
  lda (ptr_),y
  sta FACLO

  lda #0
  ldx #$A0                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_ARG_with_UINT32 value_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_UINT32 value_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_UINT32_Mem addr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_UINT32_Mem addr_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_UINT32_Ptr ptr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_UINT32_Ptr ptr_
  +Swap_FAC_and_ARG
}

; Title:                  MACRO: Load signed 32-bits integer into FAC or ARG
; Name:                   Load_FAC_with_INT32
;                         Load_FAC_with_INT32_Mem
;                         Load_FAC_with_INT32_Ptr
;                         Load_ARG_with_INT32
;                         Load_ARG_with_INT32_Mem
;                         Load_ARG_with_INT32_Ptr
; Description:            Load floating point accumulator with a signed 32-bits integer.
;                         The value can be expressed directly as argument of the macro,
;                         can be stored at a memory address or referenced to by a pointer.
; Input parameters:       value_: a 32-bits constant
;                         addr_:  a memory address
;                         ptr_:   a pointer
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Load_FAC_with_INT32 value_ {
  lda #(value_ & $FF000000) >> 24 ; Prepare mantissa.
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda #(value_ & $00FF0000) >> 16
  sta FACMOH

  !if ((value_ & $00FF0000) >> 16) - ((value_ & $0000FF00) >> 8) {
    lda #(value_ & $0000FF00) >> 8
  }
  sta FACMO

  !if ((value_ & $0000FF00) >> 8) - (value_ & $000000FF) {
    lda #(value_ & $000000FF)
  }
  sta FACLO

  !if (value_ & $000000FF) {
    lda #0
  }
  ldx #$A0                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_FAC_with_INT32_Mem addr_ {
  lda addr_+3                   ; Prepare mantissa.
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  lda addr_+2
  sta FACMOH
  lda addr_+1
  sta FACMO
  lda addr_
  sta FACLO

  lda #0
  ldx #$A0                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_FAC_with_INT32_Ptr ptr_ {
  ldy #3                        ; Prepare mantissa.
  lda (ptr_),y
  sta FACHO
  eor #$FF                      ; C = 1, force conversion to unsigned integer.
  rol a                         ; C = 0, force conversion to signed integer.

  dey
  lda (ptr_),y
  sta FACMOH
  dey
  lda (ptr_),y
  sta FACMO
  dey
  lda (ptr_),y
  sta FACLO

  lda #0
  ldx #$A0                      ; Prepare exponent = $80 + number of bits.

  jsr FLOATB
}

!macro Load_ARG_with_INT32 value_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_INT32 value_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_INT32_Mem addr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_INT32_Mem addr_
  +Swap_FAC_and_ARG
}

!macro Load_ARG_with_INT32_Ptr ptr_ {
  +Swap_FAC_and_ARG
  +Load_FAC_with_INT32_Ptr ptr_
  +Swap_FAC_and_ARG
}

; Title:                  MACRO: Convert FAC or ARG into 32-bits signed integer
; Name:                   Convert_FAC_into_INT32
;                         Convert_ARG_into_INT32
; Description:            Convert a floating point number stored into FAC or ARG into a signed 32-bits integer.
;                         The value is stored in big-endian format, in the mantissa field, therefore a 24-, 16- or
;                         8-bits conversion can be obtained just retrieving the bytes at the proper offset from the
;                         first byte of the FAC / ARG.
; Input parameters:       ---
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Convert_FAC_into_INT32 {
  jsr QINT
}

!macro Convert_ARG_into_INT32 {
  +Swap_FAC_and_ARG
  jsr QINT
  +Swap_FAC_and_ARG
}

; Commodore BASIC Floating Point macros
; (c) 2024 Stefano Priore

!source <c64_symbols.asm>

;!source "macro_internal.asm"        ; Internal use only
;!source "macro_string_conv.asm"     ; Floating point to/from string
;!source "macro_data_manip.asm"      ; Load and store FAC into RAM

; Local variables
_SCRATCH_1        = $4E         ; These two areas are used only by BASIC and are safe to use as scratchpad area
_SCRATCH_2        = NUMWRK      ; to store and retrieve copies of FAC and ARG. They are meant for internal use are


; There are three locations where floating point numbers can be stored into:
;
; 1) Accumulators (FAC1 & FAC2)
; 2) Scratchpad
; 3) Memory (as a content of a variable or array element)
;
; The scratchpad is a dedicated area in ZP used to store a copy of a FAC
;
; IMPORTANT NOTE #1! Numbers in FAC are stored in a different format
; from numbers in memory.
;
; Numbers in memory are encoded like this:
;
;   Byte 0   Byte 1   Byte 2   Byte 3   Byte 4
; |76543210|76543210|76543210|76543210|76543210|
; |Exp.+$80|S<------------Mantissa------------>|
;
; Since the mantissa is stored in normalized form,
; bit #7 of byte 1 is by definition always "1".
; Knowing this, bit #7 of byte 1 is actually used to
; encode the sign of the number: "+"=0 and "-"=1,
; the advantage being a memory-saving representation.
;
; When the number is stored in or moved to a FAC the
; representation is expanded to a form more suitable
; for numerical manipulation:
;
;   Byte 0   Byte 1   Byte 2   Byte 3   Byte 4   Byte 5
; |76543210|76543210|76543210|76543210|76543210|76543210|
; |Exp.+$80|<------------Mantissa------------->|S<unus.>|
;
; In this representation bit #7 of byte 1 is restored to "1"
; while bit #7 of the extra byte is used to encode the sign: "+"=0, "-"=1
;
; IMPORTANT NOTE #2: location $6F stores $00 if the signs of
; FAC1 & FAC2 are the same and non-$00 if they are different
; but this is guaranteed to work only if FAC2 is updated AFTER FAC1
; Too simplify the task of the programmer the following macros
; lift the limitation updating location $6F whenever FAC1 is modified.
;
; IMPORTANT NOTE #3: Anything goes out of FAC1 is rounded according to
; the value of $70.
;
; The transfer between FAC1/2 and memory is operated in two addressing modes:
; INDIRECT addressing, useful when the target is calculated (e.g. BASIC variables payload) but slower.
; DIRECT addressing, faster especially if the target is in ZP. Code is inlined and unrolled for maximum speed


; Macro +Adjust_Signs: Make sure that ARISGN is consistent with the signs of FAC and ARG.
; If the value of ARISGN is not consistent, subtle bugs can be introduced in calculations:
; the BASIC routines avoid the issue because they update ARG after FAC: since the floating point
; macros aim to hide the internal details from the user this macro, intended for INTERNAL USE ONLY
; will be used to keep ARISGN consistent.

!macro Adjust_Signs {
  lda FACSGN                    ; Apply the law of signs: bit #7 of ARISGN is 0 (+) when signs are like and 1 when signs are unlike (-)
  eor ARGSGN
  sta ARISGN
}

; Macro +Store[FAC/ARG]_in_Scratch: these macros copy the content of FAC or ARG in their reserved scratch area.
; For INTERNAL USE ONLY!
!macro Store_FAC_in_Scratch {
  lda FACEXP                    ; Store exponent byte
  sta _SCRATCH_1

  lda FACHO                     ; Store MSB of mantissa
  sta _SCRATCH_1+1

  lda FACMOH                    ; Store 2nd MSB of mantissa
  sta _SCRATCH_1+2

  lda FACMO                     ; Store 3rd MSB of mantissa
  sta _SCRATCH_1+3

  lda FACLO                     ; Store LSB of mantissa
  sta _SCRATCH_1+4

  lda FACSGN                    ; Store sign byte
  sta _SCRATCH_1+5

  lda FACOV                     ; Store rounding byte
  sta _SCRATCH_1+6
}

!macro Store_ARG_in_Scratch {
  lda ARGEXP                    ; Store exponent byte
  sta _SCRATCH_2

  lda ARGHO                     ; Store MSB of mantissa
  sta _SCRATCH_2+1

  lda ARGMOH                    ; Store 2nd MSB of mantissa
  sta _SCRATCH_2+2

  lda ARGMO                     ; Store 3rd MSB of mantissa
  sta _SCRATCH_2+3

  lda ARGLO                     ; Store LSB of mantissa
  sta _SCRATCH_2+4

  lda ARGSGN                    ; Store sign byte
  sta _SCRATCH_2+5
}

; Macro +Load_[FAC/ARG]_from_Scratch: these macros restore the content of FAC or ARG from their reserved scratch area.
; For INTERNAL USE ONLY!
!macro Load_FAC_from_Scratch {
  lda _SCRATCH_1                ; Restore exponent byte
  sta FACEXP

  lda _SCRATCH_1+1              ; Restore MSB of mantissa
  sta FACHO

  lda _SCRATCH_1+2              ; Restore 2nd MSB of mantissa
  sta FACMOH

  lda _SCRATCH_1+3              ; Restore 3rd MSB of mantissa
  sta FACMO

  lda _SCRATCH_1+4              ; Restore LSB of mantissa
  sta FACLO

  lda _SCRATCH_1+5              ; Restore sign byte
  sta FACSGN

  lda _SCRATCH_1+6              ; Restore rounding byte
  sta FACOV

  +Adjust_Signs
}

!macro Load_ARG_from_Scratch {
  lda _SCRATCH_2                ; Restore exponent byte
  sta ARGEXP

  lda _SCRATCH_2+1              ; Restore MSB of mantissa
  sta ARGHO

  lda _SCRATCH_2+2              ; Restore 2nd MSB of mantissa
  sta ARGMOH

  lda _SCRATCH_2+3              ; Restore 3rd MSB of mantissa
  sta ARGMO

  lda _SCRATCH_2+4              ; Restore LSB of mantissa
  sta ARGLO

  lda _SCRATCH_2+5              ; Restore sign byte
  sta ARGSGN

  +Adjust_Signs
}



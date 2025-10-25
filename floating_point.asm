; Commodore BASIC Floating Point macros
; (c) 2024 Stefano Priore

!source <c64_symbols.asm>

!source "macro_internal.asm"        ; Internal use only
!source "macro_string_conv.asm"     ; Floating point to/from string
!source "macro_data_manip.asm"      ; Load and store FAC into RAM

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









; --------------------------
; Loading constants into FAC
; --------------------------

; Load a constant stored into FAC
!macro LoadFAC v1,v2 {
  !if (v1 - 2) {
    ldy #<v2
    lda #>v2
    jsr GIVAYF
    +AdjustSigns
  } else {
    +PutFACinPAD 1
    ldy #<v2
    lda #>v2
    jsr GIVAYF
    +CopyFAC1toFAC2
    +GetFACfromPAD 1
    +AdjustSigns
  }
}

; Load zero in FAC
!macro Load0inFAC v1 {
  !if (v1 - 2) {
    lda #$00
    sta FAC1_EXP
    sta FAC1_MANT
    sta FAC1_MANT+1
    sta FAC1_MANT+2
    sta FAC1_MANT+3
    sta FAC1_SIGN
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$00
    sta FAC2_EXP
    sta FAC2_MANT
    sta FAC2_MANT+1
    sta FAC2_MANT+2
    sta FAC2_MANT+3
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Load 1/4 in FAC
!macro Load0.25inFAC v1 {
  +LoadMEMinFAC v1,FR4
}

; Load 1/2 in FAC
!macro Load0.5inFAC v1 {
  +LoadMEMinFAC v1,FHALF
}

; Load 1 in FAC
!macro Load1inFAC v1 {
  !if (v1 - 2) {
    ldx #$81
    stx FAC1_EXP
    dex
    stx FAC1_MANT
    ldx #$00
    stx FAC1_MANT+1
    stx FAC1_MANT+2
    stx FAC1_MANT+3
    stx FAC1_SIGN
    stx FAC1_ROUND
    +AdjustSigns
  } else {
    ldx #$81
    stx FAC2_EXP
    dex
    stx FAC2_MANT
    ldx #$00
    stx FAC2_MANT+1
    stx FAC2_MANT+2
    stx FAC2_MANT+3
    stx FAC2_SIGN
    +AdjustSigns
  }
}

; Load 2 in FAC
!macro Load2inFAC v1 {
  !if (v1 - 2) {
    ldx #$82
    stx FAC1_EXP
    dex
    dex
    stx FAC1_MANT
    ldx #$00
    stx FAC1_MANT+1
    stx FAC1_MANT+2
    stx FAC1_MANT+3
    stx FAC1_SIGN
    stx FAC1_ROUND
    +AdjustSigns
  } else {
    ldx #$82
    stx FAC2_EXP
    dex
    dex
    stx FAC2_MANT
    ldx #$00
    stx FAC2_MANT+1
    stx FAC2_MANT+2
    stx FAC2_MANT+3
    stx FAC2_SIGN
    +AdjustSigns
  }
}

; Load 10 in FAC
!macro Load10inFAC v1 {
  +LoadMEMinFAC v1,TENC
}

; Load PI/4 in FAC
!macro LoadPI4inFAC v1 {
  !if (v1 - 2) {
    +LoadPI2inFAC 1
    dec FAC1_EXP
  } else {
    +LoadPI2inFAC 2
    dec FAC2_EXP
  }
}

; Load PI/2 in FAC
!macro LoadPI2inFAC v1 {
  +LoadMEMinFAC v1,PI2
}

; Load PI in FAC
!macro LoadPIinFAC v1 {
  +LoadMEMinFAC v1,PIVAL
}

; Load 2*PI in FAC
!macro Load2PIinFAC v1 {
  +LoadMEMinFAC v1,TWOPI
}

; Load PI/180 in FAC
!macro LoadPI180inFAC v1 {
  !if (v1 - 2) {
    lda #$7B
    sta FAC1_EXP
    lda #$8E
    sta FAC1_MANT
    lda #$FA
    sta FAC1_MANT+1
    lda #$35
    sta FAC1_MANT+2
    lda #$11
    sta FAC1_MANT+3
    lda #$00
    sta FAC1_SIGN
    lda #$00
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$7B
    sta FAC2_EXP
    lda #$8E
    sta FAC2_MANT
    lda #$FA
    sta FAC2_MANT+1
    lda #$35
    sta FAC2_MANT+2
    lda #$11
    sta FAC2_MANT+3
    lda #$00
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Load 180/PI in FAC
!macro Load180PIinFAC v1 {
  !if (v1 - 2) {
    lda #$86
    sta FAC1_EXP
    lda #$E5
    sta FAC1_MANT
    lda #$2E
    sta FAC1_MANT+1
    lda #$E0
    sta FAC1_MANT+2
    lda #$D4
    sta FAC1_MANT+3
    lda #$00
    sta FAC1_SIGN
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$86
    sta FAC2_EXP
    lda #$E5
    sta FAC2_MANT
    lda #$2E
    sta FAC2_MANT+1
    lda #$E0
    sta FAC2_MANT+2
    lda #$D4
    sta FAC2_MANT+3
    lda #$00
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Load SQR(2) in FAC
!macro LoadSQR2inFAC v1 {
  !if (v1 - 2) {
    lda #$81
    sta FAC1_EXP
    lda #$B5
    sta FAC1_MANT
    lda #$04
    sta FAC1_MANT+1
    lda #$F3
    sta FAC1_MANT+2
    lda #$34
    sta FAC1_MANT+3
    lda #$00
    sta FAC1_SIGN
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$81
    sta FAC2_EXP
    lda #$B5
    sta FAC2_MANT
    lda #$04
    sta FAC2_MANT+1
    lda #$F3
    sta FAC2_MANT+2
    lda #$34
    sta FAC2_MANT+3
    lda #$00
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Load SQR(3) in FAC
!macro LoadSQR3inFAC v1 {
  !if (v1 - 2) {
    lda #$81
    sta FAC1_EXP
    lda #$DD
    sta FAC1_MANT
    lda #$B3
    sta FAC1_MANT+1
    lda #$D7
    sta FAC1_MANT+2
    lda #$42
    sta FAC1_MANT+3
    lda #$00
    sta FAC1_SIGN
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$81
    sta FAC2_EXP
    lda #$DD
    sta FAC2_MANT
    lda #$B3
    sta FAC2_MANT+1
    lda #$D7
    sta FAC2_MANT+2
    lda #$42
    sta FAC2_MANT+3
    lda #$00
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Load EXP(1) in FAC
!macro LoadeinFAC v1 {
  !if (v1 - 2) {
    lda #$82
    sta FAC1_EXP
    lda #$AD
    sta FAC1_MANT
    lda #$F8
    sta FAC1_MANT+1
    lda #$54
    sta FAC1_MANT+2
    lda #$58
    sta FAC1_MANT+3
    lda #$00
    sta FAC1_SIGN
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$82
    sta FAC2_EXP
    lda #$AD
    sta FAC2_MANT
    lda #$F8
    sta FAC2_MANT+1
    lda #$54
    sta FAC2_MANT+2
    lda #$58
    sta FAC2_MANT+3
    lda #$00
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Load LN(10) in FAC
!macro LoadLN10inFAC v1 {
  !if (v1 - 2) {
    lda #$82
    sta FAC1_EXP
    lda #$93
    sta FAC1_MANT
    lda #$5D
    sta FAC1_MANT+1
    lda #$8D
    sta FAC1_MANT+2
    lda #$DD
    sta FAC1_MANT+3
    lda #$00
    sta FAC1_SIGN
    sta FAC1_ROUND
    +AdjustSigns
  } else {
    lda #$82
    sta FAC2_EXP
    lda #$93
    sta FAC2_MANT
    lda #$5D
    sta FAC2_MANT+1
    lda #$8D
    sta FAC2_MANT+2
    lda #$DD
    sta FAC2_MANT+3
    lda #$00
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; ---------------
; Unary functions
; ---------------

; Change sign: FAC = -FAC
!macro NegateFAC v1 {
  !if (v1 - 2) {
    lda FAC1_SIGN
    eor #$FF
    sta FAC1_SIGN
    +AdjustSigns
  } else {
    lda FAC2_SIGN
    eor #$FF
    sta FAC2_SIGN
    +AdjustSigns
  }
}

; Absolute value: FAC = ABS(FAC)
!macro AbsFAC v1
  !if (v1 - 2) {
    lsr FAC1_SIGN               ; Just replace bit #7 with 0
    +AdjustSigns
  } else {
    lsr FAC2_SIGN               ; Just replace bit #7 with 0
    +AdjustSigns
  }
}

; Multiply FAC by 2
!macro MultiplyFACby2 v1 {
  !if (v1 - 2) {
    inc FAC1_EXP                ; No need to adjust signs
  } else {
    inc FAC2_EXP                ; No need to adjust signs
  }
}

; Divide FAC by 2
!macro DivideFACby2 v1 {
  !if (v1 - 2) {
    dec FAC1_EXP                ; No need to adjust signs
  } else {
    dec FAC2_EXP                ; No need to adjust signs
  }
}

; Sign of FAC
; .A = $FF if FAC < 0
; .A = $00 if FAC = 0
; .A = $01 if FAC > 0
!macro SignFAC v1
  !if (v1 - 2) {
    jsr SIGN
  } else {
    lda FAC2_EXP
    beq +++++                   ; If .A = 0, exit
    lda FAC2_SIGN               ; else put sign bit in carry
    rol a
    lda #$FF                    ; Prepare negative sign answer
    bcs +++++                   ; and deliver it if C = 1
    lda #$01                    ; else deliver positive sign answer
+++++
    rts
  }
}

; ----------------
; Basic arithmetic
; ----------------

; Addition: FAC1 = FAC2 + FAC1
!macro AddFAC2toFAC1 {
  lda FAC1_EXP                  ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; addition routine needs to be notified of the condition to treat properly the case
  jsr FADDT
  +AdjustSigns
}

; Addition: FAC1 = Memory + FAC1
!macro AddMEMtoFAC1 v1 {
  +LoadMEMinFAC 2,v1
  +AddFAC2toFAC1
}

; Addition: FAC1 = (Memory) + FAC1
!macro AddMEMtoFAC1_Ind v1 {
  +LoadMEMinFAC_Ind 2,v1
  +AddFAC2toFAC1
}

; Subtraction: FAC1 = FAC2 - FAC1
!macro SubtractFAC1fromFAC2 {
  jsr FSUBT                     ; No need to prepare Zero flag: the routine is already self-contained
  +AdjustSigns
}

; Subtraction: FAC1 = Memory - FAC1
!macro SubtractFAC1fromMEM v1 {
  +LoadMEMinFAC 2,v1
  +SubtractFAC1fromFAC2
}

; Subtraction: FAC1 = (Memory) - FAC1
!macro SubtractFAC1fromMEM_Ind v1 {
  +LoadMEMinFAC_Ind 2,v1
  +SubtractFAC1fromFAC2
}

; Multiplication: FAC1 = FAC2 * FAC1
!macro MultiplyFAC2byFAC1 {
  lda FAC1_EXP                  ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; addition routine needs to be notified of the condition to treat properly the case
  jsr FMULTT
  +AdjustSigns
}

; Multiplication: FAC1 = Memory * FAC1
!macro MultiplyMEMbyFAC1 v1 {
  +LoadMEMinFAC 2,v1
  +MultiplyFAC2byFAC1
}

; Multiplication: FAC1 = (Memory) * FAC1
!macro MultiplyMEMbyFAC1_Ind v1 {
  +LoadMEMinFAC_Ind 2,v1
  +MultiplyFAC2byFAC1
}

; Division: FAC1 = FAC2 / FAC1
!macro DivideFAC2byFAC1 {
  lda FAC1_EXP                  ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; addition routine needs to be notified of the condition to treat properly the case
  jsr FDIVT
  +AdjustSigns
}

; Division: FAC1 = Memory / FAC1
!macro DivideMEMbyFAC1 v1 {
  +LoadMEMinFAC 2,v1
  +DivideFAC2byFAC1
}

; Division: FAC1 = (Memory) / FAC1
!macro DivideMEMbyFAC1_Ind v1 {
  +LoadMEMinFAC_Ind 2,v1
  +DivideFAC2byFAC1
}

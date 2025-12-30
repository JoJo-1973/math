; --------------
; Input / Output
; --------------

; Title:                  MACRO: Convert the content of FAC or ARG to a string
; Name:                   FAC_to_String
;                         ARG_to_String
; Description:            Convert the content of FAC or ARG to a null-terminated string and place it at the bottom of the stack at $0100.
; Input parameters:       preserve_: FAC and ARG are destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro FAC_to_String preserve_ {
  !if (preserve_) {
    +Store_FAC_in_Scratch       ; Save copies of FAC and ARG.
    +Store_ARG_in_Scratch
  }

  jsr FOUT                      ; FOUT places converted FAC in $0100 destroying FAC and ARG in the process.

  !if (preserve_) {
    +Load_FAC_from_Scratch      ; Restore the copies of FAC and ARG.
    +Load_ARG_from_Scratch
  }
}

!macro ARG_to_String preserve_ {
  !if (preserve_) {
    +Store_FAC_in_Scratch       ; Save copies of FAC and ARG.
    +Store_ARG_in_Scratch
  }

  +Transfer_ARG_to_FAC          ; Copy ARG in FAC.
  jsr FOUT                      ; FOUT places converted FAC in $0100 destroying FAC and ARG in the process.

  !if (preserve_) {
    +Load_FAC_from_Scratch      ; Restore the copies of FAC and ARG.
    +Load_ARG_from_Scratch
  }
}

; Title:                  MACRO: Convert a string to a floating point number
; Name:                   String_to_FAC
;                         String_to_ARG
; Description:            Convert a null-terminated string representing a valid floating point number
;                         to a floating point number and place it in FAC or ARG.
; Input parameters:       addr_:     a memory address
;                         preserve_: FAC and ARG are destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro String_to_FAC addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch       ; Save a copy of ARG.
  }

  lda #<addr_                   ; Store the address of the string in TXTPTR.
  sta TXTPTR
  lda #>addr_
  sta TXTPTR+1
  jsr CHRGOT                    ; and place the first character of the string in the input stream
  jsr FIN                       ; then start the conversion, destroying ARG in the process.

  !if (preserve_) {
    +Load_ARG_from_Scratch      ; Restore ARG from the copy.
  }
}

!macro String_to_ARG addr_, preserve_ {
  !if (preserve_) {
    +Store_FAC_in_Scratch       ; Save a copy of FAC.
  }

  lda #<addr_                   ; Store the address of the string in TXTPTR.
  sta TXTPTR
  lda #>addr_
  sta TXTPTR+1
  jsr CHRGOT                    ; and place the first character of the string in the input stream
  jsr FIN                       ; then start the conversion, destroying ARG in the process.
  jsr MOVAF                     ; FAC can be moved to ARG.

  !if (preserve_) {
    +Load_FAC_from_Scratch      ; Restore FAC from the copy.
  }
}

; Title:                  MACRO: Convert the content of FAC or ARG to a string and send it to the output channel
; Name:                   Print_FAC
;                         Print_ARG
; Description:            Convert the content of FAC or ARG to a null-terminated string and send it to the output channel.
;                         By default the macro uses the STROUT routine from BASIC ROM to output the string.
;                         If the programmer wants to use a custom print routine for whatever reason, an alternative is provided:
;                         the programmer can define a special label __PRINT with the address of a custom printing routine
;                         that prints a null-terminated string whose address is stored inn .A/.Y.
; Input parameters:       preserve_: FAC and ARG are destroyed by the operation unless this parameter is <> 0
; Output parameters:      ---
; Altered registers:      .A, .X, .Y
; Altered zero-page:      ---
; External dependencies:  standard.asm, symbols.asm, kernal.asm
!macro Print_FAC preserve_ {
  !ifndef __PRINT {
    __PRINT = STROUT
  }

  !if (preserve_) {
    +Store_FAC_in_Scratch       ; Save copies of FAC and ARG.
    +Store_ARG_in_Scratch
  }

  jsr FOUT                      ; FOUT places converted FAC in $0100 destroying FAC and ARG in the process.
  lda #<STACK                   ; String is stored at bottom of stack.
  ldy #>STACK
  jsr __PRINT

  !if (preserve_) {
    +Load_FAC_from_Scratch      ; Restore the copies of FAC and ARG.
    +Load_ARG_from_Scratch
  }
}

!macro Print_ARG preserve_ {
  !ifndef __PRINT {
    __PRINT = STROUT
  }

  !if (preserve_) {
    +Store_FAC_in_Scratch       ; Save copies of FAC and ARG.
    +Store_ARG_in_Scratch
  }

  +Transfer_ARG_to_FAC          ; Copy ARG in FAC.
  jsr FOUT                      ; FOUT places converted FAC in $0100 destroying FAC and ARG in the process.
  lda #<STACK                   ; String is stored at bottom of stack.
  ldy #>STACK
  jsr __PRINT

  !if (preserve_) {
    +Load_FAC_from_Scratch      ; Restore the copies of FAC and ARG.
    +Load_ARG_from_Scratch
  }
}

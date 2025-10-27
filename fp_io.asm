; ----------
; I/O macros
; ----------

; Macro +FAC_to_String: Convert FAC to a string. The operation destroys FAC and ARG, unless label __PRESERVE is defined.
!macro FAC_to_String {
  !ifdef __PRESERVE {
    +Store_FAC_in_Scratch       ; Save copies of FAC and ARG.
    +Store_ARG_in_Scratch
  }

  jsr FOUT                      ; FOUT places converted FAC in $0100 destroying FAC and ARG in the process.

  !ifdef __PRESERVE {
    +Load_FAC_from_Scratch      ; Restore the copies of FAC and ARG.
    +Load_ARG_from_Scratch
  }

  +Adjust_Signs
}

; Macro +ARG_to_String: Convert ARG to a string. The operation destroys FAC and ARG, unless label __PRESERVE is defined.
!macro ARG_to_String {
  !ifdef __PRESERVE {
    +Store_FAC_in_Scratch       ; Save copies of FAC and ARG.
    +Store_ARG_in_Scratch
  }

  +Transfer_ARG_to_FAC          ; Copy ARG in FAC.
  jsr FOUT                      ; FOUT places converted FAC in $0100 destroying FAC and ARG in the process.

  !ifdef __PRESERVE {
    +Load_FAC_from_Scratch      ; Restore the copies of FAC and ARG.
    +Load_ARG_from_Scratch
  }

  +Adjust_Signs
}

; Macro +String_to_FAC: Convert a string to float and stores it into FAC. The operation destroys ARG, unless label __PRESERVE is defined.
!macro String_to_FAC addr {
  !ifdef __PRESERVE {
    +Store_ARG_in_Scratch       ; Save a copy of ARG.
  }

  lda #<addr                    ; Store the address of the string in TXTPTR
  sta TXTPTR
  lda #>addr
  sta TXTPTR+1
  jsr CHRGOT                    ; and place the first character of the string in the input stream
  jsr FIN                       ; then start the conversion, destroying ARG in the process.

  !ifdef __PRESERVE {
    +Load_ARG_from_Scratch      ; Restore ARG from the copy.
  }

  +Adjust_Signs
}

; Macro +String_to_ARG: Convert a string to float and stores it into ARG. The operation destroys FAC, unless label __PRESERVE is defined.
!macro String_to_ARG addr {
  !ifdef __PRESERVE {
    +Store_FAC_in_Scratch       ; Save a copy of FAC.
  }

  lda #<addr                    ; Store the address of the string in TXTPTR
  sta TXTPTR
  lda #>addr
  sta TXTPTR+1
  jsr CHRGOT                    ; and place the first character of the string in the input stream
  jsr FIN                       ; then start the conversion, destroying ARG in the process.
  jsr MOVAF                     ; FAC can be moved to ARG.

  !ifdef __PRESERVE {
    +Load_FAC_from_Scratch      ; Restore FAC from the copy.
  }

  +Adjust_Signs
}


; Macro +Print_FAC: Print FAC to screen. The operation destroys FAC and ARG, unless label __PRESERVE is defined.
!macro Print_FAC {
  +FAC_to_String
  lda #<STACK                   ; String is stored at bottom of stack.
  ldy #>STACK
  jsr STROUT
}

; Macro +Print_ARG: Print ARG to screen. The operation destroys FAC and ARG, unless label __PRESERVE is defined.
!macro Print_ARG {
  +ARG_to_String
  lda #<STACK                   ; String is stored at bottom of stack.
  ldy #>STACK
  jsr STROUT
}

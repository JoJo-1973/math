; ----------
; I/O macros
; ----------

; Macro +[FAC/ARG]_to_String: Convert FAC to a string.
; The kernal routine that does the conversion destroys both FAC and ARG:
; The 'preserve' parameter avoids this but bloats the resulting code
; therefore it can be disabled if you know what you are doing.
!macro FAC_to_String preserve {
  !if (preserve) {
    +Store_FAC_in_Scratch       ; Save copies of FAC and ARG.
    +Store_ARG_in_Scratch
  }

  jsr FOUT                      ; FOUT places converted FAC in $0100 destroying FAC and ARG in the process.

  !if (preserve) {
    +Load_FAC_from_Scratch      ; Restore the copies of FAC and ARG.
    +Load_ARG_from_Scratch
  }

  +Adjust_Signs
}

!macro ARG_to_String preserve {
  !if (preserve) {
    +Store_FAC_in_Scratch       ; Save copies of FAC and ARG.
    +Store_ARG_in_Scratch
  }

  +Transfer_ARG_to_FAC          ; Copy ARG in FAC.
  jsr FOUT                      ; FOUT places converted FAC in $0100 destroying FAC and ARG in the process.

  !if (preserve) {
    +Load_FAC_from_Scratch      ; Restore the copies of FAC and ARG.
    +Load_ARG_from_Scratch
  }

  +Adjust_Signs
}

; Macro +String_to_[FAC/ARG]: Convert a string to float and stores it into FAC.
; The kernal routine that does the conversion destroys both FAC and ARG:
; The 'preserve' parameter avoids this but bloats the resulting code
; therefore it can be disabled if you know what you are doing.
!macro String_to_FAC addr,preserve {
  !if (preserve) {
    +Store_ARG_in_Scratch       ; Save a copy of ARG.
  }

  lda #<addr                    ; Store the address of the string in TXTPTR
  sta TXTPTR
  lda #>addr
  sta TXTPTR+1
  jsr CHRGOT                    ; and place the first character of the string in the input stream
  jsr FIN                       ; then start the conversion, destroying ARG in the process.

  !if (preserve) {
    +Load_ARG_from_Scratch      ; Restore ARG from the copy.
  }

  +Adjust_Signs
}

!macro String_to_ARG addr,preserve {
  !if (preserve) {
    +Store_FAC_in_Scratch       ; Save a copy of FAC.
  }

  lda #<addr                    ; Store the address of the string in TXTPTR
  sta TXTPTR
  lda #>addr
  sta TXTPTR+1
  jsr CHRGOT                    ; and place the first character of the string in the input stream
  jsr FIN                       ; then start the conversion, destroying ARG in the process.
  jsr MOVAF                     ; FAC can be moved to ARG.

  !if (preserve) {
    +Load_FAC_from_Scratch      ; Restore FAC from the copy.
  }

  +Adjust_Signs
}

; Macro +Print_[FAC/ARG]: Print FAC to screen.
; The kernal routine that does the conversion destroys both FAC and ARG:
; The 'preserve' parameter avoids this but bloats the resulting code
; therefore it can be disabled if you know what you are doing.
!macro Print_FAC preserve {
  !if (preserve) {
    +Store_FAC_in_Scratch       ; Save copies of FAC and ARG.
    +Store_ARG_in_Scratch
  }

  jsr FOUT                      ; FOUT places converted FAC in $0100 destroying FAC and ARG in the process.
  lda #<STACK                   ; String is stored at bottom of stack.
  ldy #>STACK
  jsr STROUT

  !if (preserve) {
    +Load_FAC_from_Scratch      ; Restore the copies of FAC and ARG.
    +Load_ARG_from_Scratch
  }

  +Adjust_Signs
}

!macro Print_ARG preserve {
  !if (preserve) {
    +Store_FAC_in_Scratch       ; Save copies of FAC and ARG.
    +Store_ARG_in_Scratch
  }

  +Transfer_ARG_to_FAC          ; Copy ARG in FAC.
  jsr FOUT                      ; FOUT places converted FAC in $0100 destroying FAC and ARG in the process.
  lda #<STACK                   ; String is stored at bottom of stack.
  ldy #>STACK
  jsr STROUT

  !if (preserve) {
    +Load_FAC_from_Scratch      ; Restore the copies of FAC and ARG.
    +Load_ARG_from_Scratch
  }

  +Adjust_Signs
}

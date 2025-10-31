; --------------
; Input / Output
; --------------

; Macro +[FAC/ARG]_to_String: Convert FAC to a string.
; The kernal routine that does the conversion destroys both FAC and ARG:
; The 'preserve_' parameter avoids this but bloats the resulting code
; therefore it can be disabled if you know what you are doing.
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

  +Adjust_Signs
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

  +Adjust_Signs
}

; Macro +String_to_[FAC/ARG]: Convert a string to float and stores it into FAC.
; The kernal routine that does the conversion destroys both FAC and ARG:
; The 'preserve_' parameter avoids this but bloats the resulting code
; therefore it can be disabled if you know what you are doing.
!macro String_to_FAC addr, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch       ; Save a copy of ARG.
  }

  lda #<addr                    ; Store the address of the string in TXTPTR
  sta TXTPTR
  lda #>addr
  sta TXTPTR+1
  jsr CHRGOT                    ; and place the first character of the string in the input stream
  jsr FIN                       ; then start the conversion, destroying ARG in the process.

  !if (preserve_) {
    +Load_ARG_from_Scratch      ; Restore ARG from the copy.
  }

  +Adjust_Signs
}

!macro String_to_ARG addr, preserve_ {
  !if (preserve_) {
    +Store_FAC_in_Scratch       ; Save a copy of FAC.
  }

  lda #<addr                    ; Store the address of the string in TXTPTR
  sta TXTPTR
  lda #>addr
  sta TXTPTR+1
  jsr CHRGOT                    ; and place the first character of the string in the input stream
  jsr FIN                       ; then start the conversion, destroying ARG in the process.
  jsr MOVAF                     ; FAC can be moved to ARG.

  !if (preserve_) {
    +Load_FAC_from_Scratch      ; Restore FAC from the copy.
  }

  +Adjust_Signs
}

; Macro +Print_[FAC/ARG]: Print FAC to screen.
; The kernal routine that does the conversion destroys both FAC and ARG:
; The 'preserve_' parameter avoids this but bloats the resulting code
; therefore it can be disabled if you know what you are doing.
;
; __PRINT must point to an actual printing routine. It's strongly
; discouraged to use STROUT since it trashes FAC and ARG.
!macro Print_FAC preserve_ {
  !if (preserve_) {
    +Store_FAC_in_Scratch       ; Save copies of FAC and ARG.
    +Store_ARG_in_Scratch
  }

  jsr FOUT                      ; FOUT places converted FAC in $0100 destroying FAC and ARG in the process.
  lda #<STACK                   ; String is stored at bottom of stack.
  ldy #>STACK
  jsr STROUT

  !if (preserve_) {
    +Load_FAC_from_Scratch      ; Restore the copies of FAC and ARG.
    +Load_ARG_from_Scratch
  }

  +Adjust_Signs
}

!macro Print_ARG preserve_ {
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

  +Adjust_Signs
}

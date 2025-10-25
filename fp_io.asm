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
}

; Convert a string to a FAC
!macro StringtoFAC addr,fac {
  !ifdef __PRESERVE {
    !if (fac - 2) {
      +PutFACinPAD 2            ; Save FAC2 in scratchpad
    } else {
      +PutFACinPAD 1            ; Save FAC1 in scratchpad
    }
  }

  lda #<addr                    ; Prepare the pointer in CHRGOT
  sta TXTPTR
  lda #>addr
  sta TXTPTR+1
  jsr CHRGOT                    ; Place first character of the string in the pipeline
  jsr FIN                       ; and start the conversion, which incidentally destroys FAC2

  !if (fac - 2) {
    !ifdef __PRESERVE {
      +GetFACfromPAD 2          ; Restore FAC2
    }
  } else {
    +CopyFAC1toFAC2             ; Move the result to FAC2
    !ifdef __PRESERVE {
      +GetFACfromPAD 1          ; Restore FAC1
    }
  }
  +AdjustSigns
}

; Print the contents of the selected FAC to the screen
!macro PrintFAC fac {
  +FACtoString fac
  lda #$00                      ; String is stored at $0100
  ldy #$01
  jsr STROUT
}

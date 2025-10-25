; ----------
; I/O macros
; ----------

!macro FACtoString fac {
  !ifdef __PRESERVE {
    +PutFACinPAD 1              ; Save FAC1 in scratchpad
    +PutFACinPAD 2              ; Save FAC2 in scratchpad
  }

  !if (fac - 2) {
    } else {
    +CopyFAC2toFAC1
  }
  jsr FOUT                      ; FOUT places converted FAC1 in $0100 destroying FAC1/2 in the process

  !ifdef __PRESERVE {
    +GetFACfromPAD 1            ; Restore FAC1
    +GetFACfromPAD 2            ; Restore FAC2
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

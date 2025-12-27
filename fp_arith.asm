; ----------------
; Basic Arithmetic
; ----------------

; Macro Add_ARG_to_FAC: FAC = ARG + FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Add_ARG_to_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda FACEXP                    ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; addition routine needs to be notified of the condition to treat properly the case.
  jsr FADDT

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
  +Adjust_Signs
}

; Macro Add_MEM_to_FAC: FAC = Memory + FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Add_MEM_to_FAC addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG_from_Mem addr_

  +Add_ARG_to_FAC 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
  +Adjust_Signs
}

; Macro Add_PTR_to_FAC: FAC = (Ptr) + FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Add_PTR_to_FAC ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG_from_Ptr ptr_

  +Add_ARG_to_FAC 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
  +Adjust_Signs
}

; Macro Subtract_ARG_from_FAC: FAC = ARG - FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Subtract_ARG_from_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  jsr FSUBT                     ; No need to prepare Zero flag: the routine is already self-contained

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
  +Adjust_Signs
}

; Macro Subtract_MEM_from_FAC: FAC = Memory - FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Subtract_MEM_from_FAC addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG_from_Mem addr_

  +Subtract_ARG_from_FAC 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
  +Adjust_Signs
}

; Macro Subtract_PTR_from_FAC: FAC = (Ptr) - FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Subtract_PTR_from_FAC ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG_from_Ptr ptr_

  +Subtract_ARG_from_FAC 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
  +Adjust_Signs
}

; Macro Multiply_ARG_by_FAC: FAC = ARG * FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Multiply_ARG_by_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda FACEXP                    ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; multiplication routine needs to be notified of the condition to treat properly the case
  jsr FMULTT

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
  +Adjust_Signs
}

; Macro Multiply_MEM_by_FAC: FAC = Memory * FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Multiply_MEM_by_FAC addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG_from_Mem addr_

  +Multiply_ARG_by_FAC 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
  +Adjust_Signs
}

; Macro Multiply_PTR_by_FAC: FAC = (Ptr) * FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Multiply_PTR_by_FAC ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG_from_Ptr ptr_

  +Multiply_ARG_by_FAC 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
  +Adjust_Signs
}

; Macro Divide_ARG_by_FAC: FAC = ARG / FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Divide_ARG_by_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  lda FACEXP                    ; When exponent of FAC is zero, the whole FAC is considered zero, regardless of mantissa:
                                ; division routine needs to be notified of the condition to treat properly the case
  jsr FDIVT

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
  +Adjust_Signs
}

; Macro Divide_MEM_by_FAC: FAC = Memory / FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Divide_MEM_by_FAC addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG_from_Mem addr_

  +Divide_ARG_by_FAC 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
  +Adjust_Signs
}

; Macro Divide_PTR_by_FAC: FAC = (Ptr) / FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Divide_PTR_by_FAC ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_in_Scratch
  }

  +Load_ARG_from_Ptr ptr_

  +Divide_ARG_by_FAC 0

  !if (preserve_) {
    +Load_ARG_from_Scratch
  }
  +Adjust_Signs
}

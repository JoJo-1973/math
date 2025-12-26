; -----------------------
; Trascendental Functions
; -----------------------

; Macro LOG_FAC: FAC = LOG(FAC)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro LOG_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr LOG

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro LOG_MEM: FAC = LOG(Memory)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro LOG_MEM addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_with_Mem addr_

  +LOG_FAC 0

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro LOG_PTR: FAC = LOG((Pointer))
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro LOG_PTR ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_with_Ptr ptr_

  +LOG_FAC 0

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro EXP_FAC: FAC = EXP(FAC)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro EXP_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr EXP

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro EXP_MEM: FAC = EXP(Memory)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro EXP_MEM addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_with_Mem addr_

  +EXP_FAC 0

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro EXP_PTR: FAC = EXP((Pointer))
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro EXP_PTR ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_with_Ptr ptr_

  +EXP_FAC 0

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; -----------------------
; Trigonometric Functions
; -----------------------

; Macro SIN_FAC: FAC = SIN(FAC)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro SIN_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr SIN

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro SIN_MEM: FAC = SIN(Memory)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro SIN_MEM addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_with_Mem addr_

  +SIN_FAC 0

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro SIN_PTR: FAC = SIN((Pointer))
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro SIN_PTR ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_with_Ptr ptr_

  +SIN_FAC 0

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro COS_FAC: FAC = COS(FAC)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro COS_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr COS

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro COS_MEM: FAC = COS(Memory)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro COS_MEM addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_with_Mem addr_

  +COS_FAC 0

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro COS_PTR: FAC = COS((Pointer))
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro COS_PTR ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_with_Ptr ptr_

  +COS_FAC 0

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro TAN_FAC: FAC = TAN(FAC)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro TAN_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr TAN

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro TAN_MEM: FAC = TAN(Memory)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro TAN_MEM addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_with_Mem addr_

  +TAN_FAC 0

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro TAN_PTR: FAC = TAN((Pointer))
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro TAN_PTR ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_with_Ptr ptr_

  +TAN_FAC 0

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro ATN_FAC: FAC = ATN(FAC)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro ATN_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr ATN

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro ATN_MEM: FAC = ATN(Memory)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro ATN_MEM addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_with_Mem addr_

  +ATN_FAC 0

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

; Macro ATN_PTR: FAC = ATN((Pointer))
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro ATN_PTR ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG_to_Mem STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_with_Ptr ptr_

  +ATN_FAC 0

  !if (preserve_) {
    +Load_ARG_with_Mem STACK
  }
  +Adjust_Signs
}

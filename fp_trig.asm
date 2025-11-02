; -----------------------
; Trigonometric Functions
; -----------------------
; Macro SIN_FAC: FAC = SIN(FAC)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro SIN_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr SIN

  !if (preserve_) {
    +Load_ARG STACK
  }
  +Adjust_Signs
}

; Macro SIN_MEM: FAC = SIN(Memory)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro SIN_MEM addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC addr_

  +SIN_FAC 0

  !if (preserve_) {
    +Load_ARG STACK
  }
  +Adjust_Signs
}

; Macro SIN_PTR: FAC = SIN((Pointer))
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro SIN_PTR ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_Ptr ptr_

  +SIN_FAC 0

  !if (preserve_) {
    +Load_ARG STACK
  }
  +Adjust_Signs
}

; Macro COS_FAC: FAC = COS(FAC)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro COS_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr COS

  !if (preserve_) {
    +Load_ARG STACK
  }
  +Adjust_Signs
}

; Macro COS_MEM: FAC = COS(Memory)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro COS_MEM addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC addr_

  +COS_FAC 0

  !if (preserve_) {
    +Load_ARG STACK
  }
  +Adjust_Signs
}

; Macro COS_PTR: FAC = COS((Pointer))
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro COS_PTR ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_Ptr ptr_

  +COS_FAC 0

  !if (preserve_) {
    +Load_ARG STACK
  }
  +Adjust_Signs
}

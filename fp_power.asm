; -----------------------
; Exponentiation and Root
; -----------------------

; Macro Power_ARG_to_FAC: FAC = ARG ^ FAC.
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Power_ARG_to_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr FPWRT

  !if (preserve_) {
    +Load_ARG STACK
  }
  +Adjust_Signs
}

; Macro Power_MEM_to_FAC: FAC = Memory ^ FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Power_MEM_to_FAC addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_ARG addr_

  +Power_ARG_to_FAC 0

  !if (preserve_) {
    +Load_ARG STACK
  }
  +Adjust_Signs
}

; Macro Power_PTR_to_FAC: FAC = (Ptr) + FAC
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro Power_PTR_to_FAC ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_ARG_Ptr ptr_

  +Power_ARG_to_FAC 0

  !if (preserve_) {
    +Load_ARG STACK
  }
  +Adjust_Signs
}

; Macro SQR_FAC: FAC = SQR(FAC)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro SQR_FAC preserve_ {
  !if (preserve_) {
    +Store_ARG STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  jsr SQR

  !if (preserve_) {
    +Load_ARG STACK
  }
  +Adjust_Signs
}

; Macro SQR_MEM: FAC = SQR(Memory)
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro SQR_MEM addr_, preserve_ {
  !if (preserve_) {
    +Store_ARG STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC addr_

  +SQR_FAC 0

  !if (preserve_) {
    +Load_ARG STACK
  }
  +Adjust_Signs
}

; Macro SQR_PTR: FAC = SQR((Pointer))
; ARG is destroyed in the process unless 'preserve_' is <> 0.
!macro SQR_PTR ptr_, preserve_ {
  !if (preserve_) {
    +Store_ARG STACK            ; Power routine messes with contents of _SCRATCH_2, so we need a different place to save ARG.
  }

  +Load_FAC_Ptr ptr_

  +SQR_FAC 0

  !if (preserve_) {
    +Load_ARG STACK
  }
  +Adjust_Signs
}

; --------------------------------
; Integers to Floating point tests
; --------------------------------
!macro Prepare_FAC_8 {
  lda #$88
  sta FACEXP,x

  lda ADDR
  sta FACHO,x

  lda #0
  sta FACMOH,x
  sta FACMO,x
  sta FACLO,x
}

!macro Prepare_FAC_16 {
  lda #$90
  sta FACEXP,x

  lda ADDR+1
  sta FACHO,x
  lda ADDR
  sta FACMOH,x

  lda #0
  sta FACMO,x
  sta FACLO,x
}

TEST_UINT8_FAC:
  ldx #0                        ; Load integer into FAC.
  +Prepare_FAC_8

  inc RVS                       ; Print loaded FAC.
  ldx #0
  jsr PRINT_FAC_ARG
  lda #13
  jsr __PUTCHAR

  +Load_FAC_with_UINT8_Mem ADDR ; Do the conversion.
  ldx #0
  jsr PRINT_FAC_ARG

  +Print_FAC 1                  ; Print the result too.
  lda #13
  jsr __PUTCHAR
  jsr __PUTCHAR

  rts

TEST_UINT8_ARG:
  ldx #8                        ; Load integer into ARG.
  +Prepare_FAC_8

  inc RVS                       ; Print loaded ARG.
  ldx #8
  jsr PRINT_FAC_ARG
  lda #13
  jsr __PUTCHAR

  +Load_ARG_with_UINT8_Mem ADDR ; Do the conversion.
  ldx #8
  jsr PRINT_FAC_ARG

  +Print_ARG 1                  ; Print the result too.
  lda #13
  jsr __PUTCHAR
  jsr __PUTCHAR

  rts

TEST_INT8_FAC:
  ldx #0                        ; Load integer into FAC.
  +Prepare_FAC_8

  inc RVS                       ; Print loaded FAC.
  ldx #0
  jsr PRINT_FAC_ARG
  lda #13
  jsr __PUTCHAR

  +Load_FAC_with_INT8_Mem ADDR  ; Do the conversion.
  ldx #0
  jsr PRINT_FAC_ARG

  +Print_FAC 1                  ; Print the result too.
  lda #13
  jsr __PUTCHAR
  jsr __PUTCHAR

  rts

TEST_INT8_ARG:
  ldx #8                        ; Load integer into ARG.
  +Prepare_FAC_8

  inc RVS                       ; Print loaded ARG.
  ldx #8
  jsr PRINT_FAC_ARG
  lda #13
  jsr __PUTCHAR

  +Load_ARG_with_INT8_Mem ADDR  ; Do the conversion.
  ldx #8
  jsr PRINT_FAC_ARG

  +Print_ARG 1                  ; Print the result too.
  lda #13
  jsr __PUTCHAR
  jsr __PUTCHAR

  rts

TEST_UINT16_FAC:
  ldx #0                        ; Load integer into FAC.
  +Prepare_FAC_16

  inc RVS                       ; Print loaded FAC.
  ldx #0
  jsr PRINT_FAC_ARG
  lda #13
  jsr __PUTCHAR

  +Load_FAC_with_UINT16_Mem ADDR; Do the conversion.
  ldx #0
  jsr PRINT_FAC_ARG

  +Print_FAC 1                  ; Print the result too.
  lda #13
  jsr __PUTCHAR
  jsr __PUTCHAR

  rts

TEST_UINT16_ARG:
  ldx #8                        ; Load integer into ARG.
  +Prepare_FAC_16

  inc RVS                       ; Print loaded ARG.
  ldx #8
  jsr PRINT_FAC_ARG
  lda #13
  jsr __PUTCHAR

  +Load_ARG_with_UINT16_Mem ADDR; Do the conversion.
  ldx #8
  jsr PRINT_FAC_ARG

  +Print_ARG 1                  ; Print the result too.
  lda #13
  jsr __PUTCHAR
  jsr __PUTCHAR

  rts

TEST_INT16_FAC:
  ldx #0                        ; Load integer into FAC.
  +Prepare_FAC_16

  inc RVS                       ; Print loaded FAC.
  ldx #0
  jsr PRINT_FAC_ARG
  lda #13
  jsr __PUTCHAR

  +Load_FAC_with_INT16_Mem ADDR ; Do the conversion.
  ldx #0
  jsr PRINT_FAC_ARG

  +Print_FAC 1                  ; Print the result too.
  lda #13
  jsr __PUTCHAR
  jsr __PUTCHAR

  rts

TEST_INT16_ARG:
  ldx #8                        ; Load integer into ARG.
  +Prepare_FAC_16

  inc RVS                       ; Print loaded ARG.
  ldx #8
  jsr PRINT_FAC_ARG
  lda #13
  jsr __PUTCHAR

  +Load_ARG_with_INT16_Mem ADDR ; Do the conversion.
  ldx #8
  jsr PRINT_FAC_ARG

  +Print_ARG 1                  ; Print the result too.
  lda #13
  jsr __PUTCHAR
  jsr __PUTCHAR

  rts

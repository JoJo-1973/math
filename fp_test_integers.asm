!source <system/standard.asm>
!source <c64/symbols.asm>
!source <c64/kernal.asm>
!source <chip/vic_ii.asm>
!source <system/print.asm>
!source "floating_point.asm"

!to "fp test integers",cbm

; Global variables
ADDR              = FREMEM
MSG_PTR           = ZP_1
CNT               = TEMP_1

+BASIC_Preamble 10,TEST_INTEGERS,"FLOATING POINT MACRO LIBRARY TEST INTEGERS SUITE"

TEST_INTEGERS:
  jsr CLRSCR

UINT8_FAC:
  jsr PRINT_IMM
  !text 0,20,18,"UINT8",146,0

  jsr PRINT_FAC_HEADER
  lda #0
  sta CNT

.Loop_Test_UINT8_FAC
  ldy CNT

  lda INT8_TABLE,y
  sta ADDR
  jsr TEST_UINT8_FAC

  inc CNT
  lda CNT
  cmp #(END_INT8_TABLE - INT8_TABLE)
  bcc .Loop_Test_UINT8_FAC
  jsr WAIT_KEY

UINT8_ARG:
  jsr PRINT_IMM
  !text 0,20,18,"UINT8",146,0

  jsr PRINT_ARG_HEADER
  lda #0
  sta CNT

.Loop_Test_UINT8_ARG
  ldy CNT

  lda INT8_TABLE,y
  sta ADDR
  jsr TEST_UINT8_ARG

  inc CNT
  lda CNT
  cmp #(END_INT8_TABLE - INT8_TABLE)
  bcc .Loop_Test_UINT8_ARG
  jsr WAIT_KEY

INT8_FAC:
  jsr PRINT_IMM
  !text 0,20,18,"INT8",146,0

  jsr PRINT_FAC_HEADER
  lda #0
  sta CNT

.Loop_Test_INT8_FAC
  ldy CNT

  lda INT8_TABLE,y
  sta ADDR
  jsr TEST_INT8_FAC

  inc CNT
  lda CNT
  cmp #(END_INT8_TABLE - INT8_TABLE)
  bcc .Loop_Test_INT8_FAC
  jsr WAIT_KEY

INT8_ARG:
  jsr PRINT_IMM
  !text 0,20,18,"INT8",146,0

  jsr PRINT_ARG_HEADER
  lda #0
  sta CNT

.Loop_Test_INT8_ARG
  ldy CNT

  lda INT8_TABLE,y
  sta ADDR
  jsr TEST_INT8_ARG

  inc CNT
  lda CNT
  cmp #(END_INT8_TABLE - INT8_TABLE)
  bcc .Loop_Test_INT8_ARG
  jsr WAIT_KEY

UINT16_FAC:
  jsr PRINT_IMM
  !text 0,20,18,"UINT16",146,0

  jsr PRINT_FAC_HEADER
  lda #0
  sta CNT

.Loop_Test_UINT16_FAC
  lda CNT
  asl a
  tay

  lda INT16_TABLE,y
  sta ADDR
  lda INT16_TABLE+1,y
  sta ADDR+1
  jsr TEST_UINT16_FAC

  inc CNT
  lda CNT
  cmp #((END_INT16_TABLE - INT16_TABLE) / 2)
  bcc .Loop_Test_UINT16_FAC
  jsr WAIT_KEY

UINT16_ARG:
  jsr PRINT_IMM
  !text 0,20,18,"UINT16",146,0

  jsr PRINT_ARG_HEADER
  lda #0
  sta CNT

.Loop_Test_UINT16_ARG
  lda CNT
  asl a
  tay

  lda INT16_TABLE,y
  sta ADDR
  lda INT16_TABLE+1,y
  sta ADDR+1
  jsr TEST_UINT16_ARG

  inc CNT
  lda CNT
  cmp #((END_INT16_TABLE - INT16_TABLE) / 2)
  bcc .Loop_Test_UINT16_ARG
  jsr WAIT_KEY

INT16_FAC:
  jsr PRINT_IMM
  !text 0,20,18,"INT16",146,0

  jsr PRINT_FAC_HEADER
  lda #0
  sta CNT

.Loop_Test_INT16_FAC
  lda CNT
  asl a
  tay

  lda INT16_TABLE,y
  sta ADDR
  lda INT16_TABLE+1,y
  sta ADDR+1
  jsr TEST_INT16_FAC

  inc CNT
  lda CNT
  cmp #((END_INT16_TABLE - INT16_TABLE) / 2)
  bcc .Loop_Test_INT16_FAC
  jsr WAIT_KEY

INT16_ARG:
  jsr PRINT_IMM
  !text 0,20,18,"INT16",146,0

  jsr PRINT_ARG_HEADER
  lda #0
  sta CNT

.Loop_Test_INT16_ARG
  lda CNT
  asl a
  tay

  lda INT16_TABLE,y
  sta ADDR
  lda INT16_TABLE+1,y
  sta ADDR+1
  jsr TEST_INT16_ARG

  inc CNT
  lda CNT
  cmp #((END_INT16_TABLE - INT16_TABLE) / 2)
  bcc .Loop_Test_INT16_ARG
  jsr WAIT_KEY

.Exit_TEST_INTEGERS:
  rts

WAIT_KEY:
  jsr GETIN
  beq WAIT_KEY

.Exit_WAIT_KEY
  jsr CLRSCR
  rts

PRINT_FAC_HEADER:
  ldy #0
  lda #<MSG_TABLE_FAC
  sta MSG_PTR
  lda #>MSG_TABLE_FAC
  sta MSG_PTR+1

.Loop_Print_FAC_Headers:
  lda #MSG_PTR
  jsr PRINT_MSG
  bcc .Loop_Print_FAC_Headers

  lda #13
  jsr __PUTCHAR

.Exit_PRINT_FAC_HEADER:
  rts

PRINT_ARG_HEADER:
  ldy #0
  lda #<MSG_TABLE_ARG
  sta MSG_PTR
  lda #>MSG_TABLE_ARG
  sta MSG_PTR+1

.Loop_Print_ARG_Headers:
  lda #MSG_PTR
  jsr PRINT_MSG
  bcc .Loop_Print_ARG_Headers

  lda #13
  jsr __PUTCHAR

.Exit_PRINT_ARG_HEADER:
  rts

PRINT_FAC_ARG:
  lda FACEXP,x
  jsr PRINT_BYTE
  lda #" "
  jsr __PUTCHAR

  lda FACHO,x
  jsr PRINT_BYTE
  lda #" "
  jsr __PUTCHAR

  lda FACMOH,x
  jsr PRINT_BYTE
  lda #" "
  jsr __PUTCHAR

  lda FACMO,x
  jsr PRINT_BYTE
  lda #" "
  jsr __PUTCHAR

  lda FACLO,x
  jsr PRINT_BYTE
  lda #146
  jsr __PUTCHAR
  lda #" "
  jsr __PUTCHAR

  lda FACSGN,x
  jsr PRINT_BYTE
  jsr PRINT_IMM
  !text $FF,$00,29,29,29,0

.Exit_PRINT_FAC_ARG:
  rts

PRINT_BYTE:
  pha                           ; Save byte on stack.
  lsr a                         ; Isolate and print high nibble.
  lsr a
  lsr a
  lsr a
  jsr PRINT_HEX_DIGIT

  pla                           ; Isolate and print low nibble.
  and #$0F

.Exit_PRINT_BYTE:
  jmp PRINT_HEX_DIGIT

PRINT_HEX_DIGIT:
  clc                           ; Turn digit to ASCII
  adc #$30
  cmp #$3A
  bcc .Exit_PRINT_HEX_DIGIT
  adc #$06

.Exit_PRINT_HEX_DIGIT:
  jsr __PUTCHAR
  rts

INT8_TABLE:
  !byte $00, $01, $7F, $80, $FF
END_INT8_TABLE:

INT16_TABLE:
  !word $00, $01, $FF, $100, $7FFF, $8000, $FFFF
END_INT16_TABLE

INT24_TABLE:
  !byte $00, $00, $00
  !byte $FF, $00, $00
  !byte $FF, $FF, $00
  !byte $FF, $FF, $7F
  !byte $00, $00, $80
  !byte $FF, $FF, $FF
END_INT_24_TABLE:

INT32_TABLE:
  !dword $00, $FF, $FFFF, $FFFFFF, $7FFFFFFF, $80FFFFFF, $FFFFFFFF
END_INT32_TABLE:


MSG_TABLE_FAC:
  !text 0,37,18,"FAC",146,0
  !text 0,0,"EX M1 M2 M3 M4 SI",0
  !text 1,0,"-----------------",0
  !text $FF,$FF

MSG_TABLE_ARG:
  !text 0,37,18,"ARG",146,0
  !text 0,0,"EX M1 M2 M3 M4 SI",0
  !text 1,0,"-----------------",0
  !text $FF,$FF

; Install print macros
+Print_Msg
+Print_Nth
+Print_Imm
+Print_Raw

!source "fp_int_tests.asm"
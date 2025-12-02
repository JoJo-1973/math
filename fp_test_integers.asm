!source <system/standard.asm>
!source <c64/symbols.asm>
!source <c64/kernal.asm>
!source <chip/vic_ii.asm>
!source <system/print.asm>
!source "floating_point.asm"

!to "fp test integers",cbm

!macro Prepare_FAC value_ {
  lda #(value_ & $000000FF)
  sta FACHO,x
  lda #(value_ & $0000FF00) >> 8
  sta FACMOH,x
  lda #(value_ & $00FF0000) >> 16
  sta FACMO,x
  lda #(value_ & $FF000000) >> 24
  sta FACLO,x
}

; Global variables
ADDR              = FREMEM
PTR               = ZP_1
MSG_PTR           = ZP_2

+BASIC_Preamble 10,TEST_INTEGERS,"FLOATING POINT MACRO LIBRARY TEST INTEGERS SUITE"

TEST_INTEGERS:
  jsr CLRSCR
  jsr PRINT_FAC_HEADER

  ldx #0
  +Prepare_FAC $00
  ldx #0
  jsr PRINT_FAC_ARG
  +Load_FAC_with_UINT8 $00
  +Print_FAC 1
  lda #13
  jsr __PUTCHAR

  ldx #0
  +Prepare_FAC $01
  ldx #0
  jsr PRINT_FAC_ARG
  +Load_FAC_with_UINT8 $01
  +Print_FAC 1
  lda #13
  jsr __PUTCHAR

  ldx #0
  +Prepare_FAC $7F
  ldx #0
  jsr PRINT_FAC_ARG
  +Load_FAC_with_UINT8 $7F
  +Print_FAC 1
  lda #13
  jsr __PUTCHAR

  ldx #0
  +Prepare_FAC $80
  ldx #0
  jsr PRINT_FAC_ARG
  +Load_FAC_with_UINT8 $80
  +Print_FAC 1
  lda #13
  jsr __PUTCHAR

  ldx #0
  +Prepare_FAC $FF
  ldx #0
  jsr PRINT_FAC_ARG
  +Load_FAC_with_UINT8 $FF
  +Print_FAC 1
  lda #13
  jsr __PUTCHAR

.Exit_TEST_INTEGERS:
  rts

PRINT_FAC_HEADER:
  ldy #0
  lda #<MSG_TABLE_FAC
  sta MSG_PTR
  lda #>MSG_TABLE_FAC
  sta MSG_PTR+1

.Loop_Print_Headers:
  lda #MSG_PTR
  jsr PRINT_MSG
  bcc .Loop_Print_Headers

  lda #13
  jsr __PUTCHAR

.Exit_PRINT_HEADERS:
  rts

PRINT_FAC_ARG:
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
  jsr PRINT_IMM
  !text $FF,$00,"   ",0

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
  bcc .Print_Hex
  adc #$06

.Print_Hex:
  jsr __PUTCHAR

.Exit_PRINT_HEX_DIGIT:
  rts

MSG_TABLE_FAC:
  !text 2,0,18,"FAC",146,0
  !text 4,0,"62 63 64 65",0
  !text 5,0,"-----------",0
  !text $FF,$FF

MSG_TABLE_ARG:
  !text 2,0,18,"ARG",146,0
  !text 4,0,"6A 6B 6C 6D",0
  !text 5,0,"-----------",0
  !text $FF,$FF

; Install print macros
+Print_Msg
+Print_Nth
+Print_Imm
+Print_Raw

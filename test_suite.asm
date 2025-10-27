!source <standard.asm>
!source <c64_symbols.asm>
!source <kernal.asm>
!source <vic.asm>
!source "floating_point.asm"

!macro PrintAt row_, col_, string_ {
  clc                           ; Locate cursor
  ldx #row_
  ldy #col_
  jsr PLOT

  lda #<string_                 ; then print string.
  ldy #>string_
  jsr STROUT
}

+BASIC_Preamble 10,INIT,"FLOATING POINT MACRO LIBRARY TEST SUITE"

; Global variables

__PRESERVE        = 1

_TEST_NUM         = TEMP_1
_TEST_COUNT       = (END_TEST_JUMP_TABLE - TEST_JUMP_TABLE) / 6
_TEST_DESC_PTR    = ZP_1
_JUMP_VECTOR      = FREMEM

INIT:
  lda #VIC_BLACK                ; Black screen, orange chars.
  sta EXTCOL
  sta BGCOL0

  lda #00                       ; Init counter
  sta _TEST_NUM

  lda #VIC_ORANGE
  sta COLOR

MAIN:
  +PrintAt 0,0,MSG_TEST         ; STROUT messes with FAC, so let's print as much as possible before tests.
  lda #0                        ; Print the test number
  ldx _TEST_NUM
  inx
  jsr LINPRT
  lda #":"
  jsr CHROUT

  +PrintAt 2,0,MSG_BEFORE
  +PrintAt 4,0,MSG_FAC
  +PrintAt 5,0,MSG_ARG

  +PrintAt 10,0,MSG_AFTER
  +PrintAt 12,0,MSG_FAC
  +PrintAt 13,0,MSG_ARG

  +PrintAt 23,9,MSG_NAVBAR

  lda _TEST_NUM                 ; Multiply by 6
  asl a
  clc
  adc _TEST_NUM
  asl a

  pha
  tay

  lda TEST_JUMP_TABLE+2,y       ; Print description message.
  sta ZP_1
  lda TEST_JUMP_TABLE+3,y
  sta ZP_1+1
  clc
  ldx #0
  ldy #10
  jsr PLOT
  lda _TEST_DESC_PTR
  ldy _TEST_DESC_PTR+1
  jsr STROUT

  pla
  pha
  tay

  lda TEST_JUMP_TABLE+4,y         ; Set jump vector address for init routine.
  sta _JUMP_VECTOR
  lda TEST_JUMP_TABLE+5,y
  sta _JUMP_VECTOR+1
  jsr .Run_Test                 ; Init FAC and ARG.

;  +Load_FAC_with_0              ; Print FAC "before".
  clc
  ldx #4
  ldy #6
  jsr PLOT
  +Print_FAC

;  +Load_ARG_with_0              ; Print ARG "before".
  clc
  ldx #5
  ldy #6
  jsr PLOT
  +Print_ARG

  pla
  tay

  lda TEST_JUMP_TABLE,y         ; Set jump vector address for test routine.
  sta _JUMP_VECTOR
  lda TEST_JUMP_TABLE+1,y
  sta _JUMP_VECTOR+1
  jsr .Run_Test                 ; Run the test.

  clc                           ; Print FAC "after".
  ldx #12
  ldy #6
  jsr PLOT
  +Print_FAC

  clc                           ; Print ARG "after".
  ldx #13
  ldy #6
  jsr PLOT
  +Print_ARG

.Loop_Any_Key:
  jsr GETIN
  beq .Loop_Any_Key

  inc _TEST_NUM
  lda _TEST_NUM
  cmp #_TEST_COUNT
  bcs .Exit
  jmp MAIN


.Exit:
  +PrintAt 0,0,MSG_DONE
  rts

.Run_Test:
  jmp (_JUMP_VECTOR)

; UI messages
!align 255,0,0
MSG_TEST:
  !text 147,"TEST #",0
MSG_BEFORE:
  !text "BEFORE:",0
MSG_AFTER:
  !text "AFTER:",0
MSG_FAC:
  !text 18," FAC: ",146,0
MSG_ARG:
  !text 18," ARG: ",146,0
MSG_NAVBAR:
  !text 18," CRSR <> NAVIGATE    R/S ABORT ",146,0
MSG_DONE:
  !text 147,18,"TEST COMPLETED!",146,13,0

; Place all tests here
!align 255,0,0
TEST_JUMP_TABLE:
  !word LOAD_0.25,    DESC_0.25,    INIT_0
  !word LOAD_0.5,     DESC_0.5,     INIT_0
  !word LOAD_1,       DESC_1,       INIT_0
  !word LOAD_MINUS_1, DESC_MINUS_1, INIT_0
  !word LOAD_2,       DESC_2,       INIT_0
  !word LOAD_10,      DESC_10,      INIT_0
  !word LOAD_0.1,     DESC_0.1,     INIT_0
  !word LOAD_PI4,     DESC_PI4,     INIT_0
  !word LOAD_PI2,     DESC_PI2,     INIT_0
  !word LOAD_PI,      DESC_PI,      INIT_0
  !word LOAD_2PI,     DESC_2PI,     INIT_0
  !word LOAD_PI180,   DESC_PI180,   INIT_0
  !word LOAD_180PI,   DESC_180PI,   INIT_0
  !word LOAD_PI200,   DESC_PI200,   INIT_0
  !word LOAD_200PI,   DESC_200PI,   INIT_0
  !word LOAD_SQR2,    DESC_SQR2,    INIT_0
  !word LOAD_SQR3,    DESC_SQR3,    INIT_0
  !word LOAD_e,       DESC_e,       INIT_0
  !word LOAD_LOG2,    DESC_LOG2,    INIT_0
  !word LOAD_LOG10,   DESC_LOG10,   INIT_0
  !word COPY_FAC_ARG, DESC_FAC_ARG, INIT_TRANSFER
  !word COPY_ARG_FAC, DESC_ARG_FAC, INIT_TRANSFER
  !word SWAP_FAC_ARG, DESC_SWAP,    INIT_TRANSFER
END_TEST_JUMP_TABLE:

!source "tests.asm"

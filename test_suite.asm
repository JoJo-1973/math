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
  jsr SAFE_PRINT
}

+BASIC_Preamble 10,INIT,"FLOATING POINT MACRO LIBRARY TEST SUITE"

; Global variables
_TEST_NUM         = TEMP_1
_TEST_COUNT       = (END_TEST_JUMP_TABLE - TEST_JUMP_TABLE) / 2
_TEST_DESC_PTR    = ZP_1
_JUMP_VECTOR      = FREMEM

; Global constants
__PRINT           = SAFE_PRINT
N32768            = $B1A5

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

  lda _TEST_NUM
  asl a

  pha
  tay

  lda DESC_JUMP_TABLE,y         ; Print description message.
  sta ZP_1
  lda DESC_JUMP_TABLE+1,y
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

  lda INIT_JUMP_TABLE,y         ; Set jump vector address for init routine.
  sta _JUMP_VECTOR
  lda INIT_JUMP_TABLE+1,y
  sta _JUMP_VECTOR+1
  jsr .Run_Test                 ; Init FAC and ARG.

  clc                           ; Print "before" FAC.
  ldx #4
  ldy #6
  jsr PLOT
  +Print_FAC 1

  clc                           ; Print "before" ARG.
  ldx #5
  ldy #6
  jsr PLOT
  +Print_ARG 1

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
  +Print_FAC 1

  clc                           ; Print ARG "after".
  ldx #13
  ldy #6
  jsr PLOT
  +Print_ARG 1

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
  !word LOAD_0.25
  !word LOAD_0.5
  !word LOAD_1
  !word LOAD_MINUS_1
  !word LOAD_2
  !word LOAD_10
  !word LOAD_0.1
  !word LOAD_PI4
  !word LOAD_PI2
  !word LOAD_PI
  !word LOAD_2PI
  !word LOAD_PI180
  !word LOAD_180PI
  !word LOAD_PI200
  !word LOAD_200PI
  !word LOAD_SQR2
  !word LOAD_SQR3
  !word LOAD_e
  !word LOAD_LOG2
  !word LOAD_LOG10
  !word LOAD_MAXR
  !word COPY_FAC_ARG
  !word COPY_ARG_FAC
  !word SWAP_FAC_ARG
  !word NEGATE
  !word ABS
  !word SIGNUM
  !word INTG
  !word MUL2
  !word DIV2
  !word ADD
  !word ADD_MEM
  !word ADD_PTR
  !word SUB
  !word SUB_MEM
  !word SUB_PTR
  !word MULT
  !word MULT_MEM
  !word MULT_PTR
END_TEST_JUMP_TABLE:

!align 255,0,0
DESC_JUMP_TABLE:
  !word DESC_0.25
  !word DESC_0.5
  !word DESC_1
  !word DESC_MINUS_1
  !word DESC_2
  !word DESC_10
  !word DESC_0.1
  !word DESC_PI4
  !word DESC_PI2
  !word DESC_PI
  !word DESC_2PI
  !word DESC_PI180
  !word DESC_180PI
  !word DESC_PI200
  !word DESC_200PI
  !word DESC_SQR2
  !word DESC_SQR3
  !word DESC_e
  !word DESC_LOG2
  !word DESC_LOG10
  !word DESC_MAXR
  !word DESC_FAC_ARG
  !word DESC_ARG_FAC
  !word DESC_SWAP
  !word DESC_NEGATE
  !word DESC_ABS
  !word DESC_SIGNUM
  !word DESC_INTG
  !word DESC_MUL2
  !word DESC_DIV2
  !word DESC_ADD
  !word DESC_ADD_MEM
  !word DESC_ADD_PTR
  !word DESC_SUB
  !word DESC_SUB_MEM
  !word DESC_SUB_PTR
  !word DESC_MULT
  !word DESC_MULT_MEM
  !word DESC_MULT_PTR
END_DESC_JUMP_TABLE:

!align 255,0,0
INIT_JUMP_TABLE:
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_0
  !word INIT_MAXR
  !word INIT_TRANSFER
  !word INIT_TRANSFER
  !word INIT_TRANSFER
  !word INIT_UNARY
  !word INIT_UNARY
  !word INIT_SIGNUM
  !word INIT_UNARY
  !word INIT_UNARY
  !word INIT_UNARY
  !word INIT_ARITH
  !word INIT_ARITH_MEM
  !word INIT_ARITH_PTR
  !word INIT_ARITH
  !word INIT_ARITH_MEM
  !word INIT_ARITH_PTR
  !word INIT_ARITH
  !word INIT_ARITH_MEM
  !word INIT_ARITH_PTR
END_INIT_JUMP_TABLE:

!source "tests.asm"

SAFE_PRINT:
  sta ZP_2
  sty ZP_2+1
  ldy #0

.Loop_Print:
  lda (ZP_2),y
  beq .Exit_SAFE_PRINT
  jsr CHROUT
  iny
  bne .Loop_Print

.Exit_SAFE_PRINT:
  rts

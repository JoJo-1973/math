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
_TEST_COUNT       = (END_TEST_JUMP_TABLE - TEST_JUMP_TABLE) / 2
_JUMP_VECTOR      = FREMEM

INIT:
  lda #VIC_BLACK                ; Black screen, orange chars.
  sta EXTCOL
  sta BGCOL0

  lda #0                        ; Init counter
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

  +PrintAt 23,9,MSG_ANYKEY

  +Load_FAC_with_0              ; Print FAC "before".
  clc
  ldx #4
  ldy #6
  jsr PLOT
  +Print_FAC

  +Load_ARG_with_0              ; Print ARG "before".
  clc
  ldx #5
  ldy #6
  jsr PLOT
  +Print_ARG

  lda _TEST_NUM                 ; Set jump vector address
  asl
  tay
  lda TEST_JUMP_TABLE,y
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
  jsr CLRSCR
  rts

.Run_Test:
  jmp (_JUMP_VECTOR)

; UI messages
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
MSG_ANYKEY:
  !text 18,"   PRESS ANY KEY TO CONTINUE   ",146,0

; Place all tests here
TEST_JUMP_TABLE:
  !word LOAD_0.25
  !word LOAD_0.5
  !word LOAD_1
  !word LOAD_2
  !word LOAD_10
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
END_TEST_JUMP_TABLE:


!source "tests.asm"

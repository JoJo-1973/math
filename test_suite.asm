!source <standard.asm>
!source <c64_symbols.asm>
!source <vic.asm>
!source "floating_point.asm"

+BASIC_Preamble 10,MAIN,"FLOATING POINT MACRO LIBRARY TEST SUITE"

; Global variables

_TEST_NUM         = TEMP_1
_TOTAL            = (END_TEST_JUMP_TABLE - TEST_JUMP_TABLE) / 2

MAIN:
  lda #VIC_BLACK
  sta EXTCOL
  sta BGCOL0

  lda #VIC_ORANGE
  sta COLOR

  jsr CLRSCR
  rts

TEST_JUMP_TABLE:
  !word LOAD_0.25
END_TEST_JUMP_TABLE:

!source "tests.asm"

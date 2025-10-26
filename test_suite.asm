!source <standard.asm>
!source <c64_symbols.asm>
!source "floating_point.asm"

+BASIC_Preamble 10,START,"FLOATING POINT MACRO LIBRARY TEST SUITE"

START:
  +Load_FAC MINUS1
  nop
  +Load_ARG_with $11,$11,$11,$11,$12
  rts

MINUS1
  !byte $81,$80,$00,$00,$00

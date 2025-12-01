!source <system/standard.asm>
!source <c64/symbols.asm>
!source <c64/kernal.asm>
!source <chip/vic_ii.asm>
!source <system/print.asm>
!source "floating_point.asm"

!to "fp test integers",cbm

+BASIC_Preamble 10,INIT,"FLOATING POINT MACRO LIBRARY TEST INTEGERS SUITE"

INIT:
  rts
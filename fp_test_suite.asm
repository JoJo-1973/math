!source <system/standard.asm>
!source <c64/symbols.asm>
!source <c64/kernal.asm>
!source <chip/vic_ii.asm>
!source <system/print.asm>
!source "floating_point.asm"

!to "fp test suite",cbm

+BASIC_Preamble 10,INIT,"FLOATING POINT MACRO LIBRARY TEST SUITE"

; Global variables
_TEST_NUM         = TEMP_1
_TEST_START       = 1
_TEST_COUNT       = (END_TEST_JUMP_TABLE - TEST_JUMP_TABLE) / 2
_TEST_DESC_PTR    = ZP_3
_TEST_PRESERVE    = 1
_JUMP_VECTOR      = FREMEM

; Global constants

INIT:
  lda #VIC_BLACK                ; Black screen, orange chars.
  sta EXTCOL
  sta BGCOL0

  lda #VIC_ORANGE
  sta COLOR

  lda #_TEST_START-1            ; Init counter
  sta _TEST_NUM

TEST_SUITE:
  lda #<MSG_TABLE
  sta ZP_2
  lda #>MSG_TABLE
  sta ZP_2+1

  lda #ZP_2                     ; Print the first text message followed by the test number.
  jsr PRINT_MSG
  lda #0
  ldx _TEST_NUM
  inx
  jsr LINPRT
  lda #":"
  jsr __PUTCHAR

.Loop_Msg:
  lda #ZP_2
  jsr PRINT_MSG
  bcc .Loop_Msg

  lda _TEST_NUM
  asl a

  pha
  tay

  lda DESC_JUMP_TABLE,y         ; Print description message.
  sta _TEST_DESC_PTR
  lda DESC_JUMP_TABLE+1,y
  sta _TEST_DESC_PTR+1

  +At 0,10
  lda _TEST_DESC_PTR
  ldy _TEST_DESC_PTR+1
  jsr PRINT_RAW

  pla
  pha
  tay

  lda INIT_JUMP_TABLE,y         ; Set jump vector address for init routine.
  sta _JUMP_VECTOR
  lda INIT_JUMP_TABLE+1,y
  sta _JUMP_VECTOR+1
  jsr .Run_Test                 ; Init FAC and ARG.

  +At 4,6                       ; Print "before" FAC.
  +Print_FAC 1

  +At 5,6                       ; Print "before" ARG.
  +Print_ARG 1

  lda #_TEST_PRESERVE
  beq .Do_Test

  +At 0,39                      ; If _TEST_PRESERVE is on, print an asterisk.
  lda #"*"
  jsr __PUTCHAR

.Do_Test:
  pla
  tay

  lda TEST_JUMP_TABLE,y         ; Set jump vector address for test routine.
  sta _JUMP_VECTOR
  lda TEST_JUMP_TABLE+1,y
  sta _JUMP_VECTOR+1
  jsr .Run_Test                 ; Run the test.

  +At 12,6                      ; Print FAC "after".
  +Print_FAC 1

  +At 13,6                      ; Print ARG "after".
  +Print_ARG 1

.Loop_Any_Key:
  jsr GETIN
  beq .Loop_Any_Key

  cmp #3
  beq .Exit_TEST_SUITE_Abort

  inc _TEST_NUM
  lda _TEST_NUM
  cmp #_TEST_COUNT
  bcs .Exit_TEST_SUITE
  jmp TEST_SUITE

.Exit_TEST_SUITE_Abort:
  jsr PRINT_IMM
  !text 0,0,147,18,"TEST SUITE ABORTED!",146,13,0
  +Bra .To_BASIC

.Exit_TEST_SUITE:
  jsr PRINT_IMM
  !text 0,0,147,18,"TEST SUITE COMPLETED!",146,13,0

.To_BASIC:
  +Exit_to_BASIC

.Run_Test:
  jmp (_JUMP_VECTOR)

; Installation of "print.asm" macros
!align 255,0,0
+Print_Msg
+Print_Imm
+Print_Raw
__PRINT           = PRINT_RAW


; UI messages
!align 255,0,0
MSG_TABLE:
  !text 0,0,147,"TEST #",0
  !text 2,0,"BEFORE:",0
  !text 4,0,18," FAC: ",146,0
  !text 5,0,18," ARG: ",146,0
  !text 10,0,"AFTER:",0
  !text 12,0,18," FAC: ",146,0
  !text 13,0,18," ARG: ",146,0
  !text 23,9,18," CRSR <> NAVIGATE    R/S ABORT ",146,0
  !text $FF,$FF

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
  !word DIV
  !word DIV_MEM
  !word DIV_PTR
  !word COMP
  !word COMP_MEM
  !word COMP_PTR
  !word PWR
  !word PWR_MEM
  !word PWR_PTR
  !word SQRT
  !word SQRT_MEM
  !word SQRT_PTR
  !word SINE
  !word SINE_MEM
  !word SINE_PTR
  !word COSINE
  !word COSINE_MEM
  !word COSINE_PTR
  !word TANG
  !word TANG_MEM
  !word TANG_PTR
  !word ARCTAN
  !word ARCTAN_MEM
  !word ARCTAN_PTR
  !word LN
  !word LN_MEM
  !word LN_PTR
  !word EXPN
  !word EXPN_MEM
  !word EXPN_PTR
  !word POLY
  !word POLY_ODD
  !word BAND
  !word BAND_MEM
  !word BAND_PTR
  !word BOR
  !word BOR_MEM
  !word BOR_PTR
  !word BNOT_FAC
  !word BNOT_ARG
  !word BNOT_MEM
  !word BNOT_PTR
  !word RND_FAC
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
  !word DESC_DIV
  !word DESC_DIV_MEM
  !word DESC_DIV_PTR
  !word DESC_COMP
  !word DESC_COMP_MEM
  !word DESC_COMP_PTR
  !word DESC_PWR
  !word DESC_PWR_MEM
  !word DESC_PWR_PTR
  !word DESC_SQRT
  !word DESC_SQRT_MEM
  !word DESC_SQRT_PTR
  !word DESC_SINE
  !word DESC_SINE_MEM
  !word DESC_SINE_PTR
  !word DESC_COSINE
  !word DESC_COSINE_MEM
  !word DESC_COSINE_PTR
  !word DESC_TANG
  !word DESC_TANG_MEM
  !word DESC_TANG_PTR
  !word DESC_ARCTAN
  !word DESC_ARCTAN_MEM
  !word DESC_ARCTAN_PTR
  !word DESC_LN
  !word DESC_LN_MEM
  !word DESC_LN_PTR
  !word DESC_EXPN
  !word DESC_EXPN_MEM
  !word DESC_EXPN_PTR
  !word DESC_POLY
  !word DESC_POLY_ODD
  !word DESC_BAND
  !word DESC_BAND_MEM
  !word DESC_BAND_PTR
  !word DESC_BOR
  !word DESC_BOR_MEM
  !word DESC_BOR_PTR
  !word DESC_BNOT_FAC
  !word DESC_BNOT_ARG
  !word DESC_BNOT_MEM
  !word DESC_BNOT_PTR
  !word DESC_RND_FAC
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
  !word INIT_ARITH
  !word INIT_ARITH_MEM
  !word INIT_ARITH_PTR
  !word INIT_COMP
  !word INIT_COMP_MEM
  !word INIT_COMP_PTR
  !word INIT_PWR
  !word INIT_PWR_MEM
  !word INIT_PWR_PTR
  !word INIT_SQRT
  !word INIT_SQRT_MEM
  !word INIT_SQRT_PTR
  !word INIT_SIN_COS
  !word INIT_SIN_COS_MEM
  !word INIT_SIN_COS_PTR
  !word INIT_SIN_COS
  !word INIT_SIN_COS_MEM
  !word INIT_SIN_COS_PTR
  !word INIT_TANG
  !word INIT_TANG_MEM
  !word INIT_TANG_PTR
  !word INIT_ARCTAN
  !word INIT_ARCTAN_MEM
  !word INIT_ARCTAN_PTR
  !word INIT_LN
  !word INIT_LN_MEM
  !word INIT_LN_PTR
  !word INIT_EXPN
  !word INIT_EXPN_MEM
  !word INIT_EXPN_PTR
  !word INIT_POLY
  !word INIT_POLY_ODD
  !word INIT_BOOL
  !word INIT_BOOL_MEM
  !word INIT_BOOL_PTR
  !word INIT_BOOL
  !word INIT_BOOL_MEM
  !word INIT_BOOL_PTR
  !word INIT_BOOL
  !word INIT_BOOL
  !word INIT_BOOL_MEM
  !word INIT_BOOL_PTR
  !word INIT_RND
END_INIT_JUMP_TABLE:

!align 255,0,0
!source "fp_tests.asm"

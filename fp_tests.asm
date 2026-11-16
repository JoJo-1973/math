; ----------------------------
; Floating point library tests
; ----------------------------

; ----------------------------

INIT_0:
  +m_Load_FAC_with_0
  +m_Load_ARG_with_0
  rts

; ----------------------------

INIT_TRANSFER:
  +m_Load_FAC_with_e
  +m_Load_ARG_with_PI
  rts

; ----------------------------

INIT_UNARY:
  +m_Load_FAC_with_PI
  +m_Load_ARG_with $81, $C6, $66, $66, $66
  rts

; ----------------------------

INIT_SIGNUM:
  jsr PRINT_IMM
  !text 12,20,"SIGN:",0
  jsr PRINT_IMM
  !text 13,20,"SIGN:",0

  +m_Load_FAC_with_PI
  +m_Load_ARG_with $81, $C6, $66, $66, $66
  rts

; ----------------------------

INIT_MAXR:
  +m_Load_FAC_with_MINR
  +m_Load_ARG_with_MINR
  rts

; ----------------------------

INIT_ARITH:
  +m_Load_FAC_with_MINUS_1
  +m_Load_ARG_with_0_1
  rts

INIT_ARITH_MEM:
  +m_Load_FAC_with_MINUS_1
  +m_Load_ARG_with_0

  jsr PRINT_IMM
  !text 8,10,"MEM = -32768",0
  rts

INIT_ARITH_PTR:
  lda #<N32768
  sta ZP_3
  lda #>N32768
  sta ZP_3+1

  +m_Load_FAC_with_MINUS_1
  +m_Load_ARG_with_0

  jsr PRINT_IMM
  !text 8,10,"(PTR) = -32768",0
  rts

; ----------------------------

INIT_COMP:
  +m_Load_FAC_with_1
  +m_Load_ARG_with_0

  jsr PRINT_IMM
  !text 13,20,"CMP:",0
  rts

INIT_COMP_MEM:
  +m_Load_FAC_with_1
  +m_Load_ARG_with_0

  jsr PRINT_IMM
  !text 8,10,"MEM = -32768",0
  jsr PRINT_IMM
  !text 13,20,"CMP:",0
  rts

INIT_COMP_PTR:
  lda #<N32768
  sta ZP_3
  lda #>N32768
  sta ZP_3+1

  +m_Load_FAC_with_1
  +m_Load_ARG_with_0

  jsr PRINT_IMM
  !text 8,10,"(PTR) = -32768",0
  jsr PRINT_IMM
  !text 13,20,"CMP:",0
  rts

; ----------------------------

INIT_PWR:
  +m_Load_FAC_with $82, $40, $00, $00, $00
  +m_Load_ARG_with_2
  +m_Negate_ARG
  rts

INIT_PWR_MEM:
  +m_Load_FAC_with $82, $40, $00, $00, $00
  +m_Load_ARG_with_0

  jsr PRINT_IMM
  !text 8,10,"MEM = 10",0
  rts

INIT_PWR_PTR:
  lda #<N32768
  sta ZP_3
  lda #>N32768
  sta ZP_3+1

  +m_Load_FAC_with_2
  +m_Load_ARG_with_0

  jsr PRINT_IMM
  !text 8,10,"(PTR) = -32768",0
  rts

; ----------------------------

INIT_SQRT:
  +m_Load_FAC_with_2
  +m_Load_ARG_with_2PI
  rts

INIT_SQRT_MEM:
  +m_Load_FAC_with $82, $40, $00, $00, $00
  +m_Load_ARG_with_2PI

  jsr PRINT_IMM
  !text 8,10,"MEM = 10",0
  rts

INIT_SQRT_PTR:
  +m_Load_FAC_with $8B, $00, $00, $00, $00
  +m_Store_FAC_to_Mem $C000
  +m_Load_FAC_with_0
  +m_Load_ARG_with_2PI

  lda #$00
  sta ZP_3
  lda #$C0
  sta ZP_3+1

  jsr PRINT_IMM
  !text 8,10,"(PTR) = 1024",0
  rts

; ----------------------------

INIT_SIN_COS:
  +m_Load_FAC_with_PI4
  +m_Load_ARG_with_2PI
  rts

INIT_SIN_COS_MEM:
  +m_Load_FAC_with $80, $06, $0A, $91, $C1
  +m_Store_FAC_to_Mem $C000
  +m_Load_FAC_with_0
  +m_Load_ARG_with_2PI

  jsr PRINT_IMM
  !text 8,10,"MEM = ",126,"/6",0
  rts

INIT_SIN_COS_PTR:
  +m_Load_FAC_with_PI2
  +m_Store_FAC_to_Mem $C000
  +m_Load_FAC_with_0
  +m_Load_ARG_with_2PI

  lda #$00
  sta ZP_3
  lda #$C0
  sta ZP_3+1

  jsr PRINT_IMM
  !text 8,10,"(PTR) = ",126,"/2",0
  rts

; ----------------------------

INIT_TANG:
  +m_Load_FAC_with_PI4
  +m_Load_ARG_with_2PI
  rts

INIT_TANG_MEM:
  +m_Load_FAC_with $80, $06, $0A, $91, $C1
  +m_Store_FAC_to_Mem $C000
  +m_Load_FAC_with_0
  +m_Load_ARG_with_2PI

  jsr PRINT_IMM
  !text 8,10,"MEM = ",126,"/6",0
  rts

INIT_TANG_PTR:
  +m_Load_FAC_with $81, $06, $0A, $91, $C1
  +m_Store_FAC_to_Mem $C000
  +m_Load_FAC_with_0
  +m_Load_ARG_with_2PI

  lda #$00
  sta ZP_3
  lda #$C0
  sta ZP_3+1

  jsr PRINT_IMM
  !text 8,10,"(PTR) = ",126,"/3",0
  rts

; ----------------------------

INIT_ARCTAN:
  +m_Load_FAC_with_1
  +m_Load_ARG_with_1
  rts

INIT_ARCTAN_MEM:
  +m_Load_FAC_with_SQR3
  +m_Store_FAC_to_Mem $C000
  +m_Load_FAC_with_0
  +m_Load_ARG_with_1

  jsr PRINT_IMM
  !text 8,10,"MEM = SQR(3)",0
  rts

INIT_ARCTAN_PTR:
  +m_Load_FAC_with_SQR3
  +m_Load_ARG_with_2
  +m_Add_FAC_to_ARG 0
  +m_Store_FAC_to_Mem $C000
  +m_Load_FAC_with_0
  +m_Load_ARG_with_1

  lda #$00
  sta ZP_3
  lda #$C0
  sta ZP_3+1

  jsr PRINT_IMM
  !text 8,10,"(PTR) = 2+SQR(3)",0
  rts

; ----------------------------

INIT_LN:
  +m_Load_FAC_with_1
  +m_Load_ARG_with_2PI
  rts

INIT_LN_MEM:
  +m_Load_FAC_with_e
  +m_Store_FAC_to_Mem $C000
  +m_Load_ARG_with_2PI

  jsr PRINT_IMM
  !text 8,10,"MEM = EXP(1)",0
  rts

INIT_LN_PTR:
  +m_Load_ARG_with_e
  +m_Load_FAC_with_2
  +m_Multiply_FAC_by_2
  +m_Power_ARG_to_FAC 0
  +m_Store_FAC_to_Mem $C000
  +m_Load_FAC_with_1
  +m_Load_ARG_with_2PI

  lda #$00
  sta ZP_3
  lda #$C0
  sta ZP_3+1

  jsr PRINT_IMM
  !text 8,10,"(PTR) = EXP(4)",0
  rts

; ----------------------------

INIT_EXPN:
  +m_Load_FAC_with_1
  +m_Load_ARG_with_2PI
  rts

INIT_EXPN_MEM:
  +m_Load_FAC_with_2
  +m_Store_FAC_to_Mem $C000
  +m_Load_ARG_with_2PI

  jsr PRINT_IMM
  !text 8,10,"MEM = 2",0
  rts

INIT_EXPN_PTR:
  +m_Load_FAC_with_2
  +m_Multiply_FAC_by_2
  +m_Store_FAC_to_Mem $C000
  +m_Load_FAC_with_1
  +m_Load_ARG_with_2PI

  lda #$00
  sta ZP_3
  lda #$C0
  sta ZP_3+1

  jsr PRINT_IMM
  !text 8,10,"(PTR) = 4",0
  rts

; ----------------------------

INIT_POLY:
  +m_Load_FAC_with_0_1
  +m_Load_ARG_with_2PI
  rts

.Coeff_GAMMA:                   ; This 8-th degree polynomial approximates with
                                ; excellent precision the gamma function between
                                ; 0 and 1.
  !byte 8
  !byte $7C, $12, $EA, $AF, $02 ; a_8 =  .035868343
  !byte $7E, $C6, $2C, $28, $05 ; a_7 = -.193527818
  !byte $7F, $76, $E2, $D6, $CA ; a_6 =  .482199394
  !byte $80, $C1, $B7, $5B, $C5 ; a_5 = -.756704078
  !byte $80, $6B, $0F, $9A, $C5 ; a_4 =  .918206857
  !byte $80, $E5, $A5, $85, $FD ; a_3 = -.897056937
  !byte $80, $7C, $FB, $20, $78 ; a_2 =  .988206891
  !byte $80, $93, $C2, $D5, $04 ; a_1 = -.577191652
  !byte $81, $00, $00, $00, $00 ; a_0 = 1.

INIT_POLY_ODD:
  +m_Load_FAC_with_2
  +m_Load_ARG_with_2PI
  rts

.Coeff_Test:                    ; A sample odd polynomial of degree 7:
                                ; -.11*x^7 + .5*x^3 + 6

  !byte 3                       ; (7 - 1) / 2 = 3
  !byte $7D, $E1, $47, $AE, $15 ; a_7 = -.11
  !byte $00, $00, $00, $00, $00 ; a_5 = 0.
  !byte $80, $00, $00, $00, $00 ; a_3 =  .5
  !byte $83, $40, $00, $00, $00 ; a_1 = 6.

; ------------------------------

INIT_BOOL:
  +m_Load_FAC_with_INT16 $AAAA
  +m_Load_ARG_with_UINT16 $FF
  rts

INIT_BOOL_MEM:
  +m_Load_FAC_with_UINT16 $FF
  +m_Store_FAC_to_Mem $C000
  +m_Load_FAC_with_INT16 $AAAA
  +m_Load_ARG_with_UINT16 $FF

  jsr PRINT_IMM
  !text 8,10,"MEM = 255",0

  rts

INIT_BOOL_PTR:
  +m_Load_FAC_with_UINT16 $FF
  +m_Store_FAC_to_Mem $C000
  +m_Load_FAC_with_INT16 $AAAA
  +m_Load_ARG_with_UINT16 $FF

  lda #$00
  sta ZP_3
  lda #$C0
  sta ZP_3+1

  jsr PRINT_IMM
  !text 8,10,"(PTR) = 255",0

  rts

; ------------------------------

INIT_RND:
  +m_Randomize _TEST_PRESERVE
  +m_Load_FAC_with_1
  +m_Load_ARG_with_2PI

  rts

; ------------------------------

LOAD_0.25:
  +m_Load_FAC_with_0_25
  nop
  nop
  nop
  +m_Load_ARG_with_0_25
  rts

DESC_0.25:
  !text "LOAD WITH CONSTANT 1/4",0

; ------------------------------

LOAD_0.5:
  +m_Load_FAC_with_0_5
  nop
  nop
  nop
  +m_Load_ARG_with_0_5
  rts

DESC_0.5:
  !text "LOAD WITH CONSTANT 1/2",0

; ------------------------------

LOAD_1:
  +m_Load_FAC_with_1
  nop
  nop
  nop
  +m_Load_ARG_with_1
  rts

DESC_1:
  !text "LOAD WITH CONSTANT 1",0

; ------------------------------

LOAD_MINUS_1:
  +m_Load_FAC_with_MINUS_1
  nop
  nop
  nop
  +m_Load_ARG_with_MINUS_1
  rts

DESC_MINUS_1:
  !text "LOAD WITH CONSTANT -1",0

; ------------------------------

LOAD_2:
  +m_Load_FAC_with_2
  nop
  nop
  nop
  +m_Load_ARG_with_2
  rts

DESC_2:
  !text "LOAD WITH CONSTANT 2",0

; ------------------------------

LOAD_10:
  +m_Load_FAC_with_10
  nop
  nop
  nop
  +m_Load_ARG_with_10
  rts

DESC_10:
  !text "LOAD WITH CONSTANT 10",0

; ------------------------------

LOAD_0.1:
  +m_Load_FAC_with_0_1
  nop
  nop
  nop
  +m_Load_ARG_with_0_1
  rts

DESC_0.1:
  !text "LOAD WITH CONSTANT 1/10",0

; ------------------------------

LOAD_PI4:
  +m_Load_FAC_with_PI4
  nop
  nop
  nop
  +m_Load_ARG_with_PI4
  rts

DESC_PI4:
  !text "LOAD WITH CONSTANT ",126,"/4",0

; ------------------------------

LOAD_PI2:
  +m_Load_FAC_with_PI2
  nop
  nop
  nop
  +m_Load_ARG_with_PI2
  rts

DESC_PI2:
  !text "LOAD WITH CONSTANT ",126,"/2",0

; ------------------------------

LOAD_PI:
  +m_Load_FAC_with_PI
  nop
  nop
  nop
  +m_Load_ARG_with_PI
  rts

DESC_PI:
  !text "LOAD WITH CONSTANT ",126,0

; ------------------------------

LOAD_2PI:
  +m_Load_FAC_with_2PI
  nop
  nop
  nop
  +m_Load_ARG_with_2PI
  rts

DESC_2PI:
  !text "LOAD WITH CONSTANT 2",126,0

; ------------------------------

LOAD_PI180:
  +m_Load_FAC_with_PI180
  nop
  nop
  nop
  +m_Load_ARG_with_PI180
  rts

DESC_PI180:
  !text "LOAD WITH CONSTANT ",126,"/180",0

; ------------------------------

LOAD_180PI:
  +m_Load_FAC_with_180PI
  nop
  nop
  nop
  +m_Load_ARG_with_180PI
  rts

DESC_180PI:
  !text "LOAD WITH CONSTANT 180/",126,0

; ------------------------------

LOAD_PI200:
  +m_Load_FAC_with_PI200
  nop
  nop
  nop
  +m_Load_ARG_with_PI200
  rts

DESC_PI200:
  !text "LOAD WITH CONSTANT ",126,"/200",0

; ------------------------------

LOAD_200PI:
  +m_Load_FAC_with_200PI
  nop
  nop
  nop
  +m_Load_ARG_with_200PI
  rts

DESC_200PI:
  !text "LOAD WITH CONSTANT 200/",126,0

; ------------------------------

LOAD_SQR2:
  +m_Load_FAC_with_SQR2
  nop
  nop
  nop
  +m_Load_ARG_with_SQR2
  rts

DESC_SQR2:
  !text "LOAD WITH CONSTANT SQR(2)",0

; ------------------------------

LOAD_SQR3:
  +m_Load_FAC_with_SQR3
  nop
  nop
  nop
  +m_Load_ARG_with_SQR3
  rts

DESC_SQR3:
  !text "LOAD WITH CONSTANT SQR(3)",0

; ------------------------------

LOAD_e:
  +m_Load_FAC_with_e
  nop
  nop
  nop
  +m_Load_ARG_with_e
  rts

DESC_e:
  !text "LOAD WITH CONSTANT EXP(1)",0

; ------------------------------

LOAD_LOG2:
  +m_Load_FAC_with_LOG2
  nop
  nop
  nop
  +m_Load_ARG_with_LOG2
  rts

DESC_LOG2:
  !text "LOAD WITH CONSTANT LOG(2)",0

; ------------------------------

LOAD_LOG10:
  +m_Load_FAC_with_LOG10
  nop
  nop
  nop
  +m_Load_ARG_with_LOG10
  rts

DESC_LOG10:
  !text "LOAD WITH CONSTANT LOG(10)",0

; ------------------------------

LOAD_EPS:
  +m_Load_FAC_with_eps
  nop
  nop
  nop
  +m_Load_ARG_with_eps
  rts

DESC_EPS:
  !text "LOAD WITH CONSTANT EPS",0

; ------------------------------

LOAD_MAXR:
  +m_Load_FAC_with_MAXR
  nop
  nop
  nop
  +m_Load_ARG_with_MAXR
  rts

DESC_MAXR:
  !text "MINR & MAXR",0

; ------------------------------

COPY_FAC_ARG:
  +m_Transfer_FAC_to_ARG
  rts

DESC_FAC_ARG:
  !text "COPY FAC TO ARG",0

; ------------------------------

COPY_ARG_FAC:
  +m_Transfer_ARG_to_FAC
  rts

DESC_ARG_FAC:
  !text "COPY ARG TO FAC",0

; ------------------------------

SWAP_FAC_ARG:
  +m_Swap_FAC_and_ARG
  rts

DESC_SWAP:
  !text "SWAP FAC AND ARG",0

; ------------------------------

NEGATE:
  +m_Negate_FAC
  nop
  nop
  nop
  +m_Negate_ARG
  rts

DESC_NEGATE:
  !text "NEGATE VALUE",0

; ------------------------------

ABS:
  +m_ABS_FAC
  nop
  nop
  nop
  +m_ABS_ARG
  rts

DESC_ABS:
  !text "ABSOLUTE VALUE",0

; ------------------------------

SIGNUM:
  +m_Sign_FAC
  pha

  clc
  ldx #12
  ldy #26
  jsr PLOT

  pla
  beq ++
  bpl +
  lda #"-"
  +Skip2
+ lda #"+"
  +Skip2
++ lda #"0"
  jsr CHROUT

  nop
  nop
  nop

  +m_Sign_ARG
  pha

  clc
  ldx #13
  ldy #26
  jsr PLOT

  pla
  beq ++
  bpl +
  lda #"-"
  +Skip2
+ lda #"+"
  +Skip2
++ lda #"0"
  jsr CHROUT

  rts

DESC_SIGNUM:
  !text "SIGN",0

; ------------------------------

INTG:
  +m_INT_FAC
  nop
  nop
  nop
  +m_INT_ARG
  rts

DESC_INTG:
  !text "INTEGER VALUE",0

; ------------------------------

MUL2:
  +m_Multiply_FAC_by_2
  nop
  nop
  nop
  +m_Multiply_ARG_by_2
  rts

DESC_MUL2:
  !text "MULTIPLY BY 2",0

; ------------------------------

DIV2:
  +m_Divide_FAC_by_2
  nop
  nop
  nop
  +m_Divide_ARG_by_2
  rts

DESC_DIV2:
  !text "DIVIDE BY 2",0

; ------------------------------

ADD:
  +m_Add_FAC_to_ARG _TEST_PRESERVE
  rts

ADD_MEM:
  +m_Add_FAC_to_Mem N32768, _TEST_PRESERVE
  rts

ADD_PTR:
  +m_Add_FAC_to_Ptr ZP_3, _TEST_PRESERVE
  rts

DESC_ADD:
  !text "FAC = FAC + ARG",0

DESC_ADD_MEM:
  !text "FAC = FAC + MEMORY",0

DESC_ADD_PTR:
  !text "FAC = FAC + (POINTER)",0

; ------------------------------

SUB:
  +m_Subtract_FAC_from_ARG _TEST_PRESERVE
  rts

SUB_MEM:
  +m_Subtract_FAC_from_Mem N32768, _TEST_PRESERVE
  rts

SUB_PTR:
  +m_Subtract_FAC_from_Ptr ZP_3, _TEST_PRESERVE
  rts

DESC_SUB:
  !text "FAC = ARG - FAC",0

DESC_SUB_MEM:
  !text "FAC = MEMORY - FAC",0

DESC_SUB_PTR:
  !text "FAC = (POINTER) - FAC",0

; ------------------------------

MULT:
  +m_Multiply_FAC_by_ARG _TEST_PRESERVE
  rts

MULT_MEM:
  +m_Multiply_FAC_by_Mem N32768, _TEST_PRESERVE
  rts

MULT_PTR:
  +m_Multiply_FAC_by_Ptr ZP_3, _TEST_PRESERVE
  rts

DESC_MULT:
  !text "FAC = FAC * ARG",0

DESC_MULT_MEM:
  !text "FAC = FAC * MEMORY",0

DESC_MULT_PTR:
  !text "FAC = FAC * (POINTER)",0

; ------------------------------

DIV:
  +m_Divide_ARG_by_FAC _TEST_PRESERVE
  rts

DIV_MEM:
  +m_Divide_Mem_by_FAC N32768, _TEST_PRESERVE
  rts

DIV_PTR:
  +m_Divide_Ptr_by_FAC ZP_3, _TEST_PRESERVE
  rts

DESC_DIV:
  !text "FAC = ARG / FAC",0

DESC_DIV_MEM:
  !text "FAC = MEMORY / FAC",0

DESC_DIV_PTR:
  !text "FAC = (POINTER) / FAC",0

; ------------------------------

COMP:
  +m_Compare_FAC_to_ARG
  pha

  clc
  ldx #13
  ldy #25
  jsr PLOT

  pla
  beq ++
  bpl +
  lda #"<"
  +Skip2
+ lda #">"
  +Skip2
++  lda #"="
  jsr CHROUT
  rts

COMP_MEM:
  +m_Compare_FAC_to_Mem N32768
  pha

  clc
  ldx #13
  ldy #25
  jsr PLOT

  pla
  beq ++
  bpl +
  lda #"<"
  +Skip2
+ lda #">"
  +Skip2
++  lda #"="
  jsr CHROUT
  rts

COMP_PTR:
  +m_Compare_FAC_to_Ptr ZP_3
  pha

  clc
  ldx #13
  ldy #25
  jsr PLOT

  pla
  beq ++
  bpl +
  lda #"<"
  +Skip2
+ lda #">"
  +Skip2
++  lda #"="
  jsr CHROUT
  rts

DESC_COMP:
  !text "COMPARE FAC TO ARG",0

DESC_COMP_MEM:
  !text "COMPARE FAC TO MEMORY",0

DESC_COMP_PTR:
  !text "COMPARE FAC TO (POINTER)",0

; ------------------------------

PWR:
  +m_Power_ARG_to_FAC _TEST_PRESERVE
  rts

PWR_MEM:
  +m_Power_Mem_to_FAC TENC, _TEST_PRESERVE
  rts

PWR_PTR:
  +m_Power_Ptr_to_FAC ZP_3, _TEST_PRESERVE
  rts

DESC_PWR:
  !text "FAC = ARG ^ FAC",0

DESC_PWR_MEM:
  !text "FAC = MEMORY ^ FAC",0

DESC_PWR_PTR:
  !text "FAC = (POINTER) ^ FAC",0

; ------------------------------

SQRT:
  +m_SQR_FAC _TEST_PRESERVE
  rts

SQRT_MEM:
  +m_SQR_Mem TENC, _TEST_PRESERVE
  rts

SQRT_PTR:
  +m_SQR_Ptr ZP_3, _TEST_PRESERVE
  rts

DESC_SQRT:
  !text "FAC = SQR(FAC)",0

DESC_SQRT_MEM:
  !text "FAC = SQR(MEMORY)",0

DESC_SQRT_PTR:
  !text "FAC = SQR((POINTER))",0

; ------------------------------

SINE:
  +m_SIN_FAC _TEST_PRESERVE
  rts

SINE_MEM:
  +m_SIN_Mem $C000, _TEST_PRESERVE
  rts

SINE_PTR:
  +m_SIN_Ptr ZP_3, _TEST_PRESERVE
  rts

DESC_SINE:
  !text "FAC = SIN(FAC)",0

DESC_SINE_MEM:
  !text "FAC = SIN(MEMORY)",0

DESC_SINE_PTR:
  !text "FAC = SIN((POINTER))",0

; ------------------------------

COSINE:
  +m_COS_FAC _TEST_PRESERVE
  rts

COSINE_MEM:
  +m_COS_Mem $C000, _TEST_PRESERVE
  rts

COSINE_PTR:
  +m_COS_Ptr ZP_3, _TEST_PRESERVE
  rts

DESC_COSINE:
  !text "FAC = COS(FAC)",0

DESC_COSINE_MEM:
  !text "FAC = COS(MEMORY)",0

DESC_COSINE_PTR:
  !text "FAC = COS((POINTER))",0

; ------------------------------

TANG:
  +m_TAN_FAC _TEST_PRESERVE
  rts

TANG_MEM:
  +m_TAN_Mem $C000, _TEST_PRESERVE
  rts

TANG_PTR:
  +m_TAN_Ptr ZP_3, _TEST_PRESERVE
  rts

DESC_TANG:
  !text "FAC = TAN(FAC)",0

DESC_TANG_MEM:
  !text "FAC = TAN(MEMORY)",0

DESC_TANG_PTR:
  !text "FAC = TAN((POINTER))",0

; ------------------------------

ARCTAN:
  +m_ATN_FAC _TEST_PRESERVE
  rts

ARCTAN_MEM:
  +m_ATN_Mem $C000, _TEST_PRESERVE
  rts

ARCTAN_PTR:
  +m_ATN_Ptr ZP_3, _TEST_PRESERVE
  rts

DESC_ARCTAN:
  !text "FAC = ATN(FAC)",0

DESC_ARCTAN_MEM:
  !text "FAC = ATN(MEMORY)",0

DESC_ARCTAN_PTR:
  !text "FAC = ATN((POINTER))",0

; ------------------------------

LN:
  +m_LOG_FAC _TEST_PRESERVE
  rts

LN_MEM:
  +m_LOG_Mem $C000, _TEST_PRESERVE
  rts

LN_PTR:
  +m_LOG_Ptr ZP_3, _TEST_PRESERVE
  rts

DESC_LN:
  !text "FAC = LOG(FAC)",0

DESC_LN_MEM:
  !text "FAC = LOG(MEMORY)",0

DESC_LN_PTR:
  !text "FAC = LOG((POINTER))",0

; ------------------------------

EXPN:
  +m_EXP_FAC _TEST_PRESERVE
  rts

EXPN_MEM:
  +m_EXP_Mem $C000, _TEST_PRESERVE
  rts

EXPN_PTR:
  +m_EXP_Ptr ZP_3, _TEST_PRESERVE
  rts

DESC_EXPN:
  !text "FAC = EXP(FAC)",0

DESC_EXPN_MEM:
  !text "FAC = EXP(MEMORY)",0

DESC_EXPN_PTR:
  !text "FAC = EXP((POINTER))",0

; ------------------------------

POLY:
  +m_Poly_Mem .Coeff_GAMMA, _TEST_PRESERVE
  rts

DESC_POLY:
  !text "FAC = GAMMA(X), 0 < X < 1",0

POLY_ODD:
  +m_Odd_Poly_Mem .Coeff_Test, _TEST_PRESERVE
  rts

DESC_POLY_ODD:
  !text "FAC = -0.11*X^7+0.5*X^3+6*X",0

; ------------------------------

BAND:
  +m_AND_FAC_with_ARG _TEST_PRESERVE
  rts

BAND_MEM:
  +m_AND_FAC_with_Mem $C000, _TEST_PRESERVE
  rts

BAND_PTR:
  +m_AND_FAC_with_Ptr ZP_3, _TEST_PRESERVE
  rts

DESC_BAND:
  !text "FAC = FAC AND ARG",0

DESC_BAND_MEM:
  !text "FAC = FAC AND MEM",0

DESC_BAND_PTR:
  !text "FAC = FAC AND (PTR)",0

; ------------------------------

BOR:
  +m_OR_FAC_with_ARG _TEST_PRESERVE
  rts

BOR_MEM:
  +m_OR_FAC_with_Mem $C000, _TEST_PRESERVE
  rts

BOR_PTR:
  +m_OR_FAC_with_Ptr ZP_3, _TEST_PRESERVE
  rts

DESC_BOR:
  !text "FAC = FAC OR ARG",0

DESC_BOR_MEM:
  !text "FAC = FAC OR MEM",0

DESC_BOR_PTR:
  !text "FAC = FAC OR (PTR)",0

; ------------------------------

BNOT_FAC:
  +m_NOT_FAC
  rts

BNOT_ARG:
  +m_NOT_ARG
  rts

BNOT_MEM:
  +m_NOT_Mem $C000
  rts

BNOT_PTR:
  +m_NOT_Ptr ZP_3
  rts

DESC_BNOT_FAC:
  !text "FAC = NOT FAC",0

DESC_BNOT_ARG:
  !text "ARG = NOT ARG",0

DESC_BNOT_MEM:
  !text "FAC = NOT MEM",0

DESC_BNOT_PTR:
  !text "FAC = NOT (PTR)",0

; ------------------------------

RND_FAC:
  +m_Load_FAC_with_RND _TEST_PRESERVE
  rts

DESC_RND_FAC:
  !text "FAC = RND(1)",0

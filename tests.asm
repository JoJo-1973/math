; ----------------------------
; Floating Point library tests
; ----------------------------
INIT_0:
  +Load_FAC_with_0
  +Load_ARG_with_0
  rts

INIT_TRANSFER:
  +Load_FAC_with_e
  +Load_ARG_with_PI
  rts

INIT_UNARY:
  +Load_FAC_with_PI
  +Load_ARG_with $81, $C6, $66, $66, $66
  rts

INIT_SIGNUM:
  +PrintAt 12,20,.MSG_SIGNUM
  +PrintAt 13,20,.MSG_SIGNUM

  +Load_FAC_with_PI
  +Load_ARG_with $81, $C6, $66, $66, $66
  rts

.MSG_SIGNUM:
  !text "SIGN:",0

INIT_MAXR:
  +Load_FAC_with_eps
  +Load_ARG_with_eps
  rts

INIT_ARITH:
  +Load_FAC_with_MINUS_1
  +Load_ARG_with_0.1
  rts

INIT_ARITH_MEM:
  +Load_FAC_with_MINUS_1
  +Load_ARG_with_0

  +PrintAt 8,10,.MSG_MEM
  rts

.MSG_MEM
  !text "MEM = -32768",0

INIT_ARITH_PTR:
  lda #<N32768
  sta ZP_3
  lda #>N32768
  sta ZP_3+1

  +Load_FAC_with_MINUS_1
  +Load_ARG_with_0

  +PrintAt 8,10,.MSG_PTR
  rts

.MSG_PTR
  !text "(PTR) = -32768",0

INIT_COMP:
  +Load_FAC_with_1
  +Load_ARG_with_0

  +PrintAt 13,20,.MSG_COMP
  rts

.MSG_COMP:
  !text "CMP:",0

INIT_COMP_MEM:
  +Load_FAC_with_1
  +Load_ARG_with_0

  +PrintAt 8,10,.MSG_MEM
  +PrintAt 13,20,.MSG_COMP
  rts

INIT_COMP_PTR:
  lda #<N32768
  sta ZP_3
  lda #>N32768
  sta ZP_3+1

  +Load_FAC_with_1
  +Load_ARG_with_0

  +PrintAt 8,10,.MSG_PTR
  +PrintAt 13,20,.MSG_COMP
  rts

INIT_PWR:
  +Load_FAC_with $82, $40, $00, $00, $00
  +Load_ARG_with_2
  +Negate_ARG
  rts

INIT_PWR_MEM:
  +Load_FAC_with $82, $40, $00, $00, $00
  +Load_ARG_with_0

  +PrintAt 8,10,.MSG_PWR_MEM
  rts

.MSG_PWR_MEM
  !text "MEM = 10",0

INIT_PWR_PTR:
  lda #<N32768
  sta ZP_3
  lda #>N32768
  sta ZP_3+1

  +Load_FAC_with_2
  +Load_ARG_with_0

  +PrintAt 8,10,.MSG_PWR_PTR
  rts

.MSG_PWR_PTR
  !text "(PTR) = -32768",0

; ------------------------------

LOAD_0.25:
  +Load_FAC_with_0.25
  nop
  nop
  nop
  +Load_ARG_with_0.25
  rts

DESC_0.25:
  !text "LOAD WITH CONSTANT 1/4",0

; ------------------------------

LOAD_0.5:
  +Load_FAC_with_0.5
  nop
  nop
  nop
  +Load_ARG_with_0.5
  rts

DESC_0.5:
  !text "LOAD WITH CONSTANT 1/2",0

; ------------------------------

LOAD_1:
  +Load_FAC_with_1
  nop
  nop
  nop
  +Load_ARG_with_1
  rts

DESC_1:
  !text "LOAD WITH CONSTANT 1",0

; ------------------------------

LOAD_MINUS_1:
  +Load_FAC_with_MINUS_1
  nop
  nop
  nop
  +Load_ARG_with_MINUS_1
  rts

DESC_MINUS_1:
  !text "LOAD WITH CONSTANT -1",0

; ------------------------------

LOAD_2:
  +Load_FAC_with_2
  nop
  nop
  nop
  +Load_ARG_with_2
  rts

DESC_2:
  !text "LOAD WITH CONSTANT 2",0

; ------------------------------

LOAD_10:
  +Load_FAC_with_10
  nop
  nop
  nop
  +Load_ARG_with_10
  rts

DESC_10:
  !text "LOAD WITH CONSTANT 10",0

; ------------------------------

LOAD_0.1:
  +Load_FAC_with_0.1
  nop
  nop
  nop
  +Load_ARG_with_0.1
  rts

DESC_0.1:
  !text "LOAD WITH CONSTANT 1/10",0

; ------------------------------

LOAD_PI4:
  +Load_FAC_with_PI4
  nop
  nop
  nop
  +Load_ARG_with_PI4
  rts

DESC_PI4:
  !text "LOAD WITH CONSTANT ",126,"/4",0

; ------------------------------

LOAD_PI2:
  +Load_FAC_with_PI2
  nop
  nop
  nop
  +Load_ARG_with_PI2
  rts

DESC_PI2:
  !text "LOAD WITH CONSTANT ",126,"/2",0

; ------------------------------

LOAD_PI:
  +Load_FAC_with_PI
  nop
  nop
  nop
  +Load_ARG_with_PI
  rts

DESC_PI:
  !text "LOAD WITH CONSTANT ",126,0

; ------------------------------

LOAD_2PI:
  +Load_FAC_with_2PI
  nop
  nop
  nop
  +Load_ARG_with_2PI
  rts

DESC_2PI:
  !text "LOAD WITH CONSTANT 2",126,",0

; ------------------------------

LOAD_PI180:
  +Load_FAC_with_PI180
  nop
  nop
  nop
  +Load_ARG_with_PI180
  rts

DESC_PI180:
  !text "LOAD WITH CONSTANT ",126,"/180",0

; ------------------------------

LOAD_180PI:
  +Load_FAC_with_180PI
  nop
  nop
  nop
  +Load_ARG_with_180PI
  rts

DESC_180PI:
  !text "LOAD WITH CONSTANT 180/",126,0

; ------------------------------

LOAD_PI200:
  +Load_FAC_with_PI200
  nop
  nop
  nop
  +Load_ARG_with_PI200
  rts

DESC_PI200:
  !text "LOAD WITH CONSTANT ",126,"/200",0

; ------------------------------

LOAD_200PI:
  +Load_FAC_with_200PI
  nop
  nop
  nop
  +Load_ARG_with_200PI
  rts

DESC_200PI:
  !text "LOAD WITH CONSTANT 200/",126,0

; ------------------------------

LOAD_SQR2:
  +Load_FAC_with_SQR2
  nop
  nop
  nop
  +Load_ARG_with_SQR2
  rts

DESC_SQR2:
  !text "LOAD WITH CONSTANT SQR(2)",0

; ------------------------------

LOAD_SQR3:
  +Load_FAC_with_SQR3
  nop
  nop
  nop
  +Load_ARG_with_SQR3
  rts

DESC_SQR3:
  !text "LOAD WITH CONSTANT SQR(3)",0

; ------------------------------

LOAD_e:
  +Load_FAC_with_e
  nop
  nop
  nop
  +Load_ARG_with_e
  rts

DESC_e:
  !text "LOAD WITH CONSTANT EXP(1)",0

; ------------------------------

LOAD_LOG2:
  +Load_FAC_with_LOG2
  nop
  nop
  nop
  +Load_ARG_with_LOG2
  rts

DESC_LOG2:
  !text "LOAD WITH CONSTANT LOG(2)",0

; ------------------------------

LOAD_LOG10:
  +Load_FAC_with_LOG10
  nop
  nop
  nop
  +Load_ARG_with_LOG10
  rts

DESC_LOG10:
  !text "LOAD WITH CONSTANT LOG(10)",0

; ------------------------------

LOAD_MAXR:
  +Load_FAC_with_MAXR
  nop
  nop
  nop
  +Load_ARG_with_MAXR
  rts

DESC_MAXR:
  !text "EPS & MAXR",0

; ------------------------------

COPY_FAC_ARG:
  +Transfer_FAC_to_ARG
  rts

DESC_FAC_ARG:
  !text "COPY FAC TO ARG",0

; ------------------------------

COPY_ARG_FAC:
  +Transfer_ARG_to_FAC
  rts

DESC_ARG_FAC:
  !text "COPY ARG TO FAC",0

; ------------------------------

SWAP_FAC_ARG:
  +Swap_FAC_and_ARG
  rts

DESC_SWAP:
  !text "SWAP FAC AND ARG",0

; ------------------------------

NEGATE:
  +Negate_FAC
  nop
  nop
  nop
  +Negate_ARG
  rts

DESC_NEGATE:
  !text "NEGATE VALUE",0

; ------------------------------

ABS:
  +Abs_FAC
  nop
  nop
  nop
  +Abs_ARG
  rts

DESC_ABS:
  !text "ABSOLUTE VALUE",0

; ------------------------------

SIGNUM:
  +Sign_FAC
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

  +Sign_ARG
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
  +Int_FAC
  nop
  nop
  nop
  +Int_ARG
  rts

DESC_INTG:
  !text "INTEGER VALUE",0

; ------------------------------

MUL2:
  +Multiply_FAC_by_2
  nop
  nop
  nop
  +Multiply_ARG_by_2
  rts

DESC_MUL2:
  !text "MULTIPLY BY 2",0

; ------------------------------

DIV2:
  +Divide_FAC_by_2
  nop
  nop
  nop
  +Divide_ARG_by_2
  rts

DESC_DIV2:
  !text "DIVIDE BY 2",0

; ------------------------------

ADD:
  +Add_ARG_to_FAC 1
  rts

DESC_ADD:
  !text "FAC = ARG + FAC",0

; ------------------------------

ADD_MEM:
  +Add_MEM_to_FAC N32768,1
  rts

DESC_ADD_MEM:
  !text "FAC = MEMORY + FAC",0

; ------------------------------

ADD_PTR:
  +Add_PTR_to_FAC ZP_3,1
  rts

DESC_ADD_PTR:
  !text "FAC = (POINTER) + FAC",0

; ------------------------------

SUB:
  +Subtract_ARG_from_FAC 1
  rts

DESC_SUB:
  !text "FAC = ARG - FAC",0

; ------------------------------

SUB_MEM:
  +Subtract_MEM_from_FAC N32768,1
  rts

DESC_SUB_MEM:
  !text "FAC = MEMORY - FAC",0

; ------------------------------

SUB_PTR:
  +Subtract_PTR_from_FAC ZP_3,1
  rts

DESC_SUB_PTR:
  !text "FAC = (POINTER) - FAC",0

; ------------------------------

MULT:
  +Multiply_ARG_by_FAC 1
  rts

DESC_MULT:
  !text "FAC = ARG * FAC",0

; ------------------------------

MULT_MEM:
  +Multiply_MEM_by_FAC N32768,1
  rts

DESC_MULT_MEM:
  !text "FAC = MEMORY * FAC",0

; ------------------------------

MULT_PTR:
  +Multiply_PTR_by_FAC ZP_3,1
  rts

DESC_MULT_PTR:
  !text "FAC = (POINTER) * FAC",0

; ------------------------------

DIV:
  +Divide_ARG_by_FAC 1
  rts

DESC_DIV:
  !text "FAC = ARG / FAC",0

; ------------------------------

DIV_MEM:
  +Divide_MEM_by_FAC N32768,1
  rts

DESC_DIV_MEM:
  !text "FAC = MEMORY / FAC",0

; ------------------------------

DIV_PTR:
  +Divide_PTR_by_FAC ZP_3,1
  rts

DESC_DIV_PTR:
  !text "FAC = (POINTER) / FAC",0

; ------------------------------

COMP:
  +Compare_FAC_to_ARG
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

; ------------------------------

COMP_MEM:
  +Compare_FAC_to_MEM N32768
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

DESC_COMP_MEM:
  !text "COMPARE FAC TO MEMORY",0

; ------------------------------

COMP_PTR:
  +Compare_FAC_to_PTR ZP_3
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

DESC_COMP_PTR:
  !text "COMPARE FAC TO (POINTER)",0

; ------------------------------

PWR:
  +Power_ARG_to_FAC 1
  rts

DESC_PWR:
  !text "FAC = ARG ^ FAC",0

; ------------------------------

PWR_MEM:
  +Power_MEM_to_FAC TENC,1
  rts

DESC_PWR_MEM:
  !text "FAC = MEMORY ^ FAC",0

; ------------------------------

PWR_PTR:
  +Power_PTR_to_FAC ZP_3,1
  rts

DESC_PWR_PTR:
  !text "FAC = (POINTER) ^ FAC",0

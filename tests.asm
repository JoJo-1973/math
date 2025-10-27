; ----------------------------
; Floating Point library tests
; ----------------------------
INIT_0:
  +Load_FAC_with_0
  +Load_ARG_with_0
  rts

LOAD_0.25:
  +Load_FAC_with_0.25
  nop
  nop
  nop
  +Load_ARG_with_0.25
  rts

DESC_0.25:
  !text "LOAD WITH CONSTANT 1/4",0

LOAD_0.5:
  +Load_FAC_with_0.5
  nop
  nop
  nop
  +Load_ARG_with_0.5
  rts

DESC_0.5:
  !text "LOAD WITH CONSTANT 1/2",0

LOAD_1:
  +Load_FAC_with_1
  nop
  nop
  nop
  +Load_ARG_with_1
  rts

DESC_1:
  !text "LOAD WITH CONSTANT 1",0

LOAD_MINUS_1:
  +Load_FAC_with_MINUS_1
  nop
  nop
  nop
  +Load_ARG_with_MINUS_1
  rts

DESC_MINUS_1:
  !text "LOAD WITH CONSTANT -1",0

LOAD_2:
  +Load_FAC_with_2
  nop
  nop
  nop
  +Load_ARG_with_2
  rts

DESC_2:
  !text "LOAD WITH CONSTANT 2",0

LOAD_10:
  +Load_FAC_with_10
  nop
  nop
  nop
  +Load_ARG_with_10
  rts

DESC_10:
  !text "LOAD WITH CONSTANT 10",0

LOAD_0.1:
  +Load_FAC_with_0.1
  nop
  nop
  nop
  +Load_ARG_with_0.1
  rts

DESC_0.1:
  !text "LOAD WITH CONSTANT 1/10",0

LOAD_PI4:
  +Load_FAC_with_PI4
  nop
  nop
  nop
  +Load_ARG_with_PI4
  rts

DESC_PI4:
  !text "LOAD WITH CONSTANT ",126,"/4",0

LOAD_PI2:
  +Load_FAC_with_PI2
  nop
  nop
  nop
  +Load_ARG_with_PI2
  rts

DESC_PI2:
  !text "LOAD WITH CONSTANT ",126,"/2",0

LOAD_PI:
  +Load_FAC_with_PI
  nop
  nop
  nop
  +Load_ARG_with_PI
  rts

DESC_PI:
  !text "LOAD WITH CONSTANT ",126,0

LOAD_2PI:
  +Load_FAC_with_2PI
  nop
  nop
  nop
  +Load_ARG_with_2PI
  rts

DESC_2PI:
  !text "LOAD WITH CONSTANT 2",126,",0

LOAD_PI180:
  +Load_FAC_with_PI180
  nop
  nop
  nop
  +Load_ARG_with_PI180
  rts

DESC_PI180:
  !text "LOAD WITH CONSTANT ",126,"/180",0

LOAD_180PI:
  +Load_FAC_with_180PI
  nop
  nop
  nop
  +Load_ARG_with_180PI
  rts

DESC_180PI:
  !text "LOAD WITH CONSTANT 180/",126,0

LOAD_PI200:
  +Load_FAC_with_PI200
  nop
  nop
  nop
  +Load_ARG_with_PI200
  rts

DESC_PI200:
  !text "LOAD WITH CONSTANT ",126,"/200",0

LOAD_200PI:
  +Load_FAC_with_200PI
  nop
  nop
  nop
  +Load_ARG_with_200PI
  rts

DESC_200PI:
  !text "LOAD WITH CONSTANT 200/",126,0

LOAD_SQR2:
  +Load_FAC_with_SQR2
  nop
  nop
  nop
  +Load_ARG_with_SQR2
  rts

DESC_SQR2:
  !text "LOAD WITH CONSTANT SQR(2)",0

LOAD_SQR3:
  +Load_FAC_with_SQR3
  nop
  nop
  nop
  +Load_ARG_with_SQR3
  rts

DESC_SQR3:
  !text "LOAD WITH CONSTANT SQR(3)",0

LOAD_e:
  +Load_FAC_with_e
  nop
  nop
  nop
  +Load_ARG_with_e
  rts

DESC_e:
  !text "LOAD WITH CONSTANT EXP(1)",0

LOAD_LOG2:
  +Load_FAC_with_LOG2
  nop
  nop
  nop
  +Load_ARG_with_LOG2
  rts

DESC_LOG2:
  !text "LOAD WITH CONSTANT LOG(2)",0

LOAD_LOG10:
  +Load_FAC_with_LOG10
  nop
  nop
  nop
  +Load_ARG_with_LOG10
  rts

DESC_LOG10:
  !text "LOAD WITH CONSTANT LOG(10)",0

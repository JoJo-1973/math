; Macro per operazioni matematiche con valori a 32 bit

; Titolo:                 MACRO: Somma 2 valori a 32 bit
; Nome:                   Add32
; Descrizione:            Somma 2 valori a 32 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 32 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 32 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         add1: Primo addendo
;                         add2: Secondo addendo
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Add32 mode, add1, add2, res {
  !if (mode = ADDR_IMM) {
    !if (add2 != 0) {
      clc

      lda add1
      adc #(add2 & $000000FF) >> 0
      sta res

      lda add1+1
      adc #(add2 & $0000FF00) >> 8
      sta res+1

      lda add1+2
      adc #(add2 & $00FF0000) >> 16
      sta res+2

      lda add1+3
      adc #(add2 & $FF000000) >> 24
      sta res+3
    } else {
      clc

      lda add1
      sta res

      lda add1+1
      sta res+1

      lda add1+2
      sta res+2

      lda add1+3
      sta res+3
    }
  } else if (mode = ADDR_ABS) {
    clc

    lda+2 add1
    adc+2 add2
    sta res

    lda+2 add1+1
    adc+2 add2+1
    sta res+1

    lda+2 add1+2
    adc+2 add2+2
    sta res+2

    lda+2 add1+3
    adc+2 add2+3
    sta res+3
  } else if (mode = ADDR_ZER) {
    clc

    lda+1 add1
    adc+1 add2
    sta res

    lda+1 add1+1
    adc+1 add2+1
    sta res+1

    lda+1 add1+2
    adc+1 add2+2
    sta res+2

    lda+1 add1+3
    adc+1 add2+3
    sta res+3
  }
}

; Titolo:                 MACRO: Sottrazione di 2 valori a 32 bit
; Nome:                   Sub32
; Descrizione:            Sottrae 2 valori a 32 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 32 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 32 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         min:  Minuendo
;                         sub:  Sottraendo
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Sub32 mode, min, sub, res {
  !if (mode = ADDR_IMM) {
    !if (sub != 0) {
      sec

      lda min
      sbc #(sub & $000000FF) >> 0
      sta res

      lda min+1
      sbc #(sub & $0000FF00) >> 8
      sta res+1

      lda min+2
      sbc #(sub & $00FF0000) >> 16
      sta res+2

      lda min+3
      sbc #(sub & $FF000000) >> 24
      sta res+3
    } else {
      sec

      lda min
      sta res

      lda min+1
      sta res+1

      lda min+2
      sta res+2

      lda min+3
      sta res+3
    }
  } else if (mode = ADDR_ABS) {
    !if (min != sub) {
      sec

      lda+2 min
      sbc+2 sub
      sta res

      lda+2 min+1
      sbc+2 sub+1
      sta res+1

      lda+2 min+2
      sbc+2 sub+2
      sta res+2

      lda+2 min+3
      sbc+2 sub+3
      sta res+3
    } else {
      sec
      lda #0
      sta res
      sta res+1
      sta res+2
      sta res+3
    }
  } else if (mode = ADDR_ZER) {
    !if (min != sub) {
      sec

      lda+1 min
      sbc+1 sub
      sta res

      lda+1 min+1
      sbc+1 sub+1
      sta res+1

      lda+1 min+2
      sbc+1 sub+2
      sta res+2

      lda+1 min+3
      sbc+1 sub+3
      sta res+3
    } else {
      sec
      lda #0
      sta res
      sta res+1
      sta res+2
      sta res+3
    }
  }
}

; Titolo:                 MACRO: Negazione di un valore a 32 bit
; Nome:                   Neg32
; Descrizione:            Sottrae un valore a 32 bit da 0 usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 32 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 32 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Neg32 mode, op, res {
  !if (mode = ADDR_IMM) {
    !if (op != 0) {
      sec

      lda #0
      sbc #(op & $000000FF) >> 0
      sta res

      lda #0
      sbc #(op & $0000FF00) >> 8
      sta res+1

      lda #0
      sbc #(op & $00FF0000) >> 16
      sta res+2

      lda #0
      sbc #(op & $FF000000) >> 24
      sta res+3
    } else {
      sec
      lda #0
      sta res
      sta res+1
      sta res+2
      sta res+3
    }
  } else if (mode = ADDR_ABS) {
    sec

    lda #0
    sbc+2 op
    sta res

    lda #0
    sbc+2 op+1
    sta res+1

    lda #0
    sbc+2 op+2
    sta res+2

    lda #0
    sbc+2 op+3
    sta res+3
  } else if (mode = ADDR_ZER) {
    sec

    lda #0
    sbc+1 op
    sta res

    lda #0
    sbc+1 op+1
    sta res+1

    lda #0
    sbc+1 op+2
    sta res+2
  }
}

; Titolo:                 MACRO: NOT booleano di un valore a 32 bit
; Nome:                   Not32
; Descrizione:            Inverte un valore a 32 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 32 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 32 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Not32 mode, op, res {
  !if (mode = ADDR_IMM) {
    !if (op = 0) {
      +Mov32 ADDR_IMM,$FFFFFFFF,res
    } else if (op = $FFFFFFFF) {
      +Mov32 ADDR_IMM,0,res
    } else {
      lda #(op & $000000FF) >> 0
      eor #$FF
      sta res

      lda #(op & $0000FF00) >> 8
      eor #$FF
      sta res+1

      lda #(op & $00FF0000) >> 16
      eor #$FF
      sta res+2

      lda #(op & $FF000000) >> 24
      eor #$FF
      sta res+3
    }
  } else if (mode = ADDR_ABS) {
    lda+2 op
    eor #$FF
    sta res

    lda+2 op+1
    eor #$FF
    sta res+1

    lda+2 op+2
    eor #$FF
    sta res+2

    lda+2 op+3
    eor #$FF
    sta res+3
  } else if (mode = ADDR_ZER) {
    lda+1 op
    eor #$FF
    sta res

    lda+1 op+1
    eor #$FF
    sta res+1

    lda+1 op+2
    eor #$FF
    sta res+2

    lda+1 op+3
    eor #$FF
    sta res+3
  }
}

; Titolo:                 MACRO: AND booleano di due valori a 32 bit
; Nome:                   And32
; Descrizione:            Esegue un AND booleano tra due valori a 32 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 32 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 32 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         op1:  Primo operando
;                         op2:  Secondo operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro And32 mode, op1, op2, res {
  !if (mode = ADDR_IMM) {
    !if (op2 = 0) {
      +Mov32 ADDR_IMM,0,res
    } else if (op2 = $FFFFFFFF) {
      lda op1
      sta res

      lda op1+1
      sta res+1

      lda op1+2
      sta res+2

      lda op1+3
      sta res+3
    } else {
      lda op1
      and #(op2 & $000000FF) >> 0
      sta res

      lda op1+1
      and #(op2 & $0000FF00) >> 8
      sta res+1

      lda op1+2
      and #(op2 & $00FF0000) >> 16
      sta res+2

      lda op1+3
      and #(op2 & $FF000000) >> 24
      sta res+3
    }
  } else if (mode = ADDR_ABS) {
    !if (op1 != op2) {
      lda+2 op1
      and+2 op2
      sta res

      lda+2 op1+1
      and+2 op2+1
      sta res+1

      lda+2 op1+2
      and+2 op2+2
      sta res+2

      lda+2 op1+3
      and+2 op2+3
      sta res+3
    } else {
      lda+2 op1
      sta res

      lda+2 op1+1
      sta res+1

      lda+2 op1+2
      sta res+2

      lda+2 op1+3
      sta res+3
    }
  } else if (mode = ADDR_ZER) {
    !if (op1 != op2) {
      lda+1 op1
      and+1 op2
      sta res

      lda+1 op1+1
      and+1 op2+1
      sta res+1

      lda+1 op1+2
      and+1 op2+2
      sta res+2

      lda+1 op1+3
      and+1 op2+3
      sta res+3
    } else {
      lda+1 op1
      sta res

      lda+1 op1+1
      sta res+1

      lda+1 op1+2
      sta res+2

      lda+1 op1+3
      sta res+3
    }
  }
}

; Titolo:                 MACRO: OR booleano di due valori a 32 bit
; Nome:                   Ora32
; Descrizione:            Esegue un OR booleano tra due valori a 32 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 32 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 32 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         op1:  Primo operando
;                         op2:  Secondo operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Ora32 mode, op1, op2, res {
  !if (mode = ADDR_IMM) {
    !if (op2 = 0) {
      lda op1
      sta res

      lda op1+1
      sta res+1

      lda op1+2
      sta res+2

      lda op1+3
      sta res+3
    } else if (op2 = $FFFFFFFF) {
      +Mov32 ADDR_IMM,$FFFFFFFF,res
    } else {
      lda op1
      ora #(op2 & $000000FF) >> 0
      sta res

      lda op1+1
      ora #(op2 & $0000FF00) >> 8
      sta res+1

      lda op1+2
      ora #(op2 & $00FF0000) >> 16
      sta res+2

      lda op1+3
      ora #(op2 & $FF000000) >> 24
      sta res+3
    }
  } else if (mode = ADDR_ABS) {
    !if (op1 != op2) {
      lda+2 op1
      ora+2 op2
      sta res

      lda+2 op1+1
      ora+2 op2+1
      sta res+1

      lda+2 op1+2
      ora+2 op2+2
      sta res+2

      lda+2 op1+3
      ora+2 op2+3
      sta res+3
    } else {
      lda+2 op1
      sta res

      lda+2 op1+1
      sta res+1

      lda+2 op1+2
      sta res+2

      lda+2 op1+3
      sta res+3
    }
  } else if (mode = ADDR_ZER) {
    !if (op1 != op2) {
      lda+1 op1
      ora+1 op2
      sta res

      lda+1 op1+1
      ora+1 op2+1
      sta res+1

      lda+1 op1+2
      ora+1 op2+2
      sta res+2

      lda+1 op1+3
      ora+1 op2+3
      sta res+3
    } else {
      lda+1 op1
      sta res

      lda+1 op1+1
      sta res+1

      lda+1 op1+2
      sta res+2

      lda+1 op1+3
      sta res+3
    }
  }
}

; Titolo:                 MACRO: EOR booleano di due valori a 32 bit
; Nome:                   Eor32
; Descrizione:            Esegue un EOR booleano tra due valori a 32 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 32 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 32 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         op1:  Primo operando
;                         op2:  Secondo operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Eor32 mode, op1, op2, res {
  !if (mode = ADDR_IMM) {
    !if (op2 = 0) {
      lda op1
      sta res

      lda op1+1
      sta res+1

      lda op1+2
      sta res+2

      lda op1+3
      sta res+3
    } else {
      lda op1
      eor #(op2 & $000000FF) >> 0
      sta res

      lda op1+1
      eor #(op2 & $0000FF00) >> 8
      sta res+1

      lda op1+2
      eor #(op2 & $00FF0000) >> 16
      sta res+2

      lda op1+3
      eor #(op2 & $FF000000) >> 24
      sta res+3
    }
  } else if (mode = ADDR_ABS) {
    !if (op1 != op2) {
      lda+2 op1
      eor+2 op2
      sta res

      lda+2 op1+1
      eor+2 op2+1
      sta res+1

      lda+2 op1+2
      eor+2 op2+2
      sta res+2

      lda+2 op1+3
      eor+2 op2+3
      sta res+3
    } else {
      +Mov32 ADDR_IMM,0,res
    }
  } else if (mode = ADDR_ZER) {
    !if (op1 != op2) {
      lda+1 op1
      eor+1 op2
      sta res

      lda+1 op1+1
      eor+1 op2+1
      sta res+1

      lda+1 op1+2
      eor+1 op2+2
      sta res+2

      lda+1 op1+3
      eor+1 op2+3
      sta res+3
    } else {
      +Mov32 ADDR_IMM,0,res
    }
  }
}

; Titolo:                 MACRO: Spostamento aritmetico a sinistra di un valore a 32 bit
; Nome:                   Asl32
; Descrizione:            Esegue uno spostamento aritmetico a sinistra di un valore a 32 bit usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         In realtà è uno spostamento logico, non aritmetico, perché non viene tenuta traccia di un eventuale overflow.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 32 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   ---
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Asl32 mode, op, res {
  !if (mode = ADDR_ABS) {
    !if (op = res) {
      asl+2 op
      rol+2 op+1
      rol+2 op+2
      rol+2 op+3
    } else {
      lda+2 op
      asl a
      sta res

      lda+2 op+1
      rol a
      sta res+1

      lda+2 op+2
      rol a
      sta res+2

      lda+2 op+3
      rol a
      sta res+3
    }
  } else if (mode = ADDR_ZER) {
    !if (op = res) {
      asl+1 op
      rol+1 op+1
      rol+1 op+2
      rol+1 op+3
    } else {
      lda+1 op
      asl a
      sta res

      lda+1 op+1
      rol a
      sta res+1

      lda+1 op+2
      rol a
      sta res+2

      lda+1 op+3
      rol a
      sta res+3
    }
  }
}

; Titolo:                 MACRO: Spostamento aritmetico a sinistra di un valore a 32 bit con segno
; Nome:                   AslS32
; Descrizione:            Esegue uno spostamento aritmetico a sinistra di un valore a 32 bit con segno usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         A differenza di Asl32 l'eventuale cambiamento di segno dovuto alla fuoriuscita del bit più alto è segnalato dal flag V.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 32 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro AslS32 mode, op, res {
  !if (mode = ADDR_ABS) {
    !if (op = res) {
      asl+2 op
      rol+2 op+1
      rol+2 op+2

      lda+2 op+3
      adc+2 op+3
      sta op+3
    } else {
      lda+2 op
      asl
      sta res

      lda+2 op+1
      rol a
      sta res+1

      lda+2 op+2
      rol a
      sta res+2

      lda+2 op+3
      adc+2 op+3
      sta res+3
    }
  } else if (mode = ADDR_ZER) {
    !if (op = res) {
      asl+1 op
      rol+1 op+1
      rol+1 op+2

      lda+1 op+3
      adc+1 op+3
      sta op+3
    } else {
      lda+1 op
      asl a
      sta res

      lda+1 op+1
      rol a
      sta res+1

      lda+1 op+2
      rol a
      sta res+2

      lda+1 op+3
      adc+1 op+3
      sta res+3
    }
  }
}

; Titolo:                 MACRO: Spostamento logico a destra di un valore a 32 bit
; Nome:                   Lsr32
; Descrizione:            Esegue uno spostamento logico a destra di un valore a 32 bit usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 32 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   ---
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Lsr32 mode, op, res {
  !if (mode = ADDR_ABS) {
    !if (op = res) {
      lsr+2 op+3
      ror+2 op+2
      ror+2 op+1
      ror+2 op
    } else {
      lda+2 op+3
      lsr a
      sta res+3

      lda+2 op+2
      ror a
      sta res+2

      lda+2 op+1
      ror a
      sta res+1

      lda+2 op
      ror a
      sta res
    }
  } else if (mode = ADDR_ZER) {
    !if (op = res) {
      lsr+1 op+3
      ror+1 op+2
      ror+1 op+1
      ror+1 op
    } else {
      lda+1 op+3
      lsr a
      sta res+3

      lda+1 op+2
      ror a
      sta res+2

      lda+1 op+1
      ror a
      sta res+1

      lda+1 op
      ror a
      sta res
    }
  }
}

; Titolo:                 MACRO: Spostamento aritmetico a destra di un valore a 32 bit con segno
; Nome:                   AsrS32
; Descrizione:            Esegue uno spostamento aritmetico a destra di un valore a 32 bit con segno usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 32 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro AsrS32 mode, op, res {
  !if (mode = ADDR_ABS) {
    !if (op = res) {
      lda+2 op+3
      asl a

      ror+2 op+3
      ror+2 op+2
      ror+2 op+1
      ror+2 op
    } else {
      lda+2 op+3
      asl a

      lda+2 op+3
      ror a
      sta res+3

      lda+2 op+2
      ror a
      sta res+2

      lda+2 op+1
      ror a
      sta res+1

      lda+2 op
      ror a
      sta res
    }
  } else if (mode = ADDR_ZER) {
    !if (op = res) {
      lda+1 op+3
      asl a

      ror+1 op+3
      ror+1 op+2
      ror+1 op+1
      ror+1 op
    } else {
      lda+1 op+3
      asl a

      lda+1 op+3
      ror a
      sta res+3

      lda+1 op+2
      ror a
      sta res+2

      lda+1 op+1
      ror a
      sta res+1

      lda+1 op
      ror a
      sta res
    }
  }
}

; Titolo:                 MACRO: Rotazione a sinistra di un valore a 32 bit attraverso il Carry
; Nome:                   Rol32
; Descrizione:            Esegue una rotazione a sinistra di un valore a 32 bit usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         Il bit di ordine più elevato finisce nel flag C.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 32 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   ---
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Rol32 mode, op, res {
  !if (mode = ADDR_ABS) {
    !if (op = res) {
      rol+2 op
      rol+2 op+1
      rol+2 op+2
      rol+2 op+3
    } else {
      lda+2 op
      rol a
      sta res

      lda+2 op+1
      rol a
      sta res+1

      lda+2 op+2
      rol a
      sta res+2

      lda+2 op+3
      rol a
      sta res+3
    }
  } else if (mode = ADDR_ZER) {
    !if (op = res) {
      rol+1 op
      rol+1 op+1
      rol+1 op+2
      rol+1 op+3
    } else {
      lda+1 op
      rol a
      sta res

      lda+1 op+1
      rol a
      sta res+1

      lda+1 op+2
      rol a
      sta res+2

      lda+1 op+3
      rol a
      sta res+3
    }
  }
}

; Titolo:                 MACRO: Rotazione a sinistra di un valore a 32 bit
; Nome:                   Rl32
; Descrizione:            Esegue una rotazione a sinistra di un valore a 32 bit senza passare per il Carry usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         Il bit di ordine più elevato finisce nella posizione di ordine meno elevato.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 32 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Rl32 mode, op, res {
  !if (mode = ADDR_ABS) {
    lda+2 op+3
    rol a
    +Rol32 ADDR_ABS, op, res
  } else if (mode = ADDR_ZER) {
    lda+1 op+3
    rol a
    +Rol32 ADDR_ZER, op, res
  }
}

; Titolo:                 MACRO: Rotazione a destra di un valore a 32 bit attraverso il Carry
; Nome:                   Ror32
; Descrizione:            Esegue una rotazione a destra di un valore a 32 bit usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         Il bit di ordine meno elevato finisce nel flag C.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 32 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   ---
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Ror32 mode, op, res {
  !if (mode = ADDR_ABS) {
    !if (op = res) {
      ror+2 op+3
      ror+2 op+2
      ror+2 op+1
      ror+2 op
    } else {
      lda+2 op+3
      ror a
      sta res+3

      lda+2 op+2
      ror a
      sta res+2

      lda+2 op+1
      ror a
      sta res+1

      lda+2 op
      ror a
      sta res
    }
  } else if (mode = ADDR_ZER) {
    !if (op = res) {
      ror+1 op+3
      ror+1 op+2
      ror+1 op+1
      ror+1 op
    } else {
      lda+1 op+3
      ror a
      sta res+3

      lda+1 op+2
      ror a
      sta res+2

      lda+1 op+1
      ror a
      sta res+1

      lda+1 op
      ror a
      sta res
    }
  }
}

; Titolo:                 MACRO: Rotazione a destra di un valore a 32 bit
; Nome:                   Rr32
; Descrizione:            Esegue una rotazione a destra di un valore a 32 bit senza passare per il Carry usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         Il bit di ordine meno elevato finisce nella posizione di ordine più elevato.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 32 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Rr32 mode, op, res {
  !if (mode = ADDR_ABS) {
    lda+2 op
    ror a
    +Ror32 ADDR_ABS, op, res
  } else if (mode = ADDR_ZER) {
    lda+1 op
    ror a
    +Ror32 ADDR_ZER, op, res
  }
}
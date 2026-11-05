; Macro per operazioni matematiche con valori a 16 bit

; Titolo:                 MACRO: Somma 2 valori a 16 bit
; Nome:                   Add16
; Descrizione:            Somma 2 valori a 16 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 16 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 16 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         add1: Primo addendo
;                         add2: Secondo addendo
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Add16 mode, add1, add2, res {
  !if (mode = ADDR_IMM) {
    !if (add2 != 0) {
      clc

      lda add1
      adc #<add2
      sta res

      lda add1+1
      adc #>add2
      sta res+1
    } else {
      clc

      lda add1
      sta res

      lda add1+1
      sta res+1
    }
  } else if (mode = ADDR_ABS) {
    clc

    lda+2 add1
    adc+2 add2
    sta res

    lda+2 add1+1
    adc+2 add2+1
    sta res+1
  } else if (mode = ADDR_ZER) {
    clc

    lda+1 add1
    adc+1 add2
    sta res

    lda+1 add1+1
    adc+1 add2+1
    sta res+1
  }
}

; Titolo:                 MACRO: Sottrazione di 2 valori a 16 bit
; Nome:                   Sub16
; Descrizione:            Sottrae 2 valori a 16 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 16 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 16 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         min:  Minuendo
;                         sub:  Sottraendo
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Sub16 mode, min, sub, res {
  !if (mode = ADDR_IMM) {
    !if (sub != 0) {
      sec

      lda min
      sbc #<sub
      sta res

      lda min+1
      sbc #>sub
      sta res+1
    } else {
      sec

      lda min
      sta res

      lda min+1
      sta res+1
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
    } else {
      sec
      lda #0
      sta res
      sta res+1
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
    } else {
      sec
      lda #0
      sta res
      sta res+1
    }
  }
}

; Titolo:                 MACRO: Negazione di un valore a 16 bit
; Nome:                   Neg16
; Descrizione:            Sottrae un valore a 16 bit da 0 usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 16 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 16 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Neg16 mode, op, res {
  !if (mode = ADDR_IMM) {
    !if (op != 0) {
      sec

      lda #0
      sbc #<op
      sta res

      lda #0
      sbc #>op
      sta res+1
    } else {
      sec
      lda #0
      sta res
      sta res+1
    }
  } else if (mode = ADDR_ABS) {
    sec

    lda #0
    sbc+2 op
    sta res

    lda #0
    sbc+2 op+1
    sta res+1
  } else if (mode = ADDR_ZER) {
    sec

    lda #0
    sbc+1 op
    sta res

    lda #0
    sbc+1 op+1
    sta res+1
  }
}

; Titolo:                 MACRO: NOT booleano di un valore a 16 bit
; Nome:                   Not16
; Descrizione:            Inverte un valore a 16 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 16 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 16 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Not16 mode, op, res {
  !if (mode = ADDR_IMM) {
    !if (op = 0) {
      +Mov16 ADDR_IMM,$FFFF,res
    } else if (op = $FFFF) {
      +Mov16 ADDR_IMM,0,res
    } else {
      lda #<op
      eor #$FF
      sta res

      lda #>op
      eor #$FF
      sta res+1
    }
  } else if (mode = ADDR_ABS) {
    lda+2 op
    eor #$FF
    sta res

    lda+2 op+1
    eor #$FF
    sta res+1
  } else if (mode = ADDR_ZER) {
    lda+1 op
    eor #$FF
    sta res

    lda+1 op+1
    eor #$FF
    sta res+1
  }
}

; Titolo:                 MACRO: AND booleano di due valori a 16 bit
; Nome:                   And16
; Descrizione:            Esegue un AND booleano tra due valori a 16 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 16 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 16 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         op1:  Primo operando
;                         op2:  Secondo operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro And16 mode, op1, op2, res {
  !if (mode = ADDR_IMM) {
    !if (op2 = 0) {
      +Mov16 ADDR_IMM,0,res
    } else if (op2 = $FFFF) {
      lda op1
      sta res

      lda op1+1
      sta res+1
    } else {
      lda op1
      and #<op2
      sta res

      lda op1+1
      and #>op2
      sta res+1
    }
  } else if (mode = ADDR_ABS) {
    !if (op1 != op2) {
      lda+2 op1
      and+2 op2
      sta res

      lda+2 op1+1
      and+2 op2+1
      sta res+1
    } else {
      lda+2 op1
      sta res

      lda+2 op1+1
      sta res+1
    }
  } else if (mode = ADDR_ZER) {
    !if (op1 != op2) {
      lda+1 op1
      and+1 op2
      sta res

      lda+1 op1+1
      and+1 op2+1
      sta res+1
    } else {
      lda+1 op1
      sta res

      lda+1 op1+1
      sta res+1
    }
  }
}

; Titolo:                 MACRO: OR booleano di due valori a 16 bit
; Nome:                   Ora16
; Descrizione:            Esegue un OR booleano tra due valori a 16 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 16 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 16 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         op1:  Primo operando
;                         op2:  Secondo operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Ora16 mode, op1, op2, res {
  !if (mode = ADDR_IMM) {
    !if (op2 = 0) {
      lda op1
      sta res

      lda op1+1
      sta res+1
    } else if (op2 = $FFFF) {
      +Mov16 ADDR_IMM,$FFFF,res
    } else {
      lda op1
      ora #<op2
      sta res

      lda op1+1
      ora #>op2
      sta res+1
    }
  } else if (mode = ADDR_ABS) {
    !if (op1 != op2) {
      lda+2 op1
      ora+2 op2
      sta res

      lda+2 op1+1
      ora+2 op2+1
      sta res+1
    } else {
      lda+2 op1
      sta res

      lda+2 op1+1
      sta res+1
    }
  } else if (mode = ADDR_ZER) {
    !if (op1 != op2) {
      lda+1 op1
      ora+1 op2
      sta res

      lda+1 op1+1
      ora+1 op2+1
      sta res+1
    } else {
      lda+1 op1
      sta res

      lda+1 op1+1
      sta res+1
    }
  }
}

; Titolo:                 MACRO: EOR booleano di due valori a 16 bit
; Nome:                   Eor16
; Descrizione:            Esegue un EOR booleano tra due valori a 16 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_IMM = Immediato: il primo operando è un indirizzo, il secondo è un valore a 16 bit
;                               ADDR_ABS = Assoluto: entrambi gli operandi sono indirizzi a 16 bit
;                               ADDR_ZER = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         op1:  Primo operando
;                         op2:  Secondo operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Eor16 mode, op1, op2, res {
  !if (mode = ADDR_IMM) {
    !if (op2 = 0) {
      lda op1
      sta res

      lda op1+1
      sta res+1
    } else {
      lda op1
      eor #<op2
      sta res

      lda op1+1
      eor #>op2
      sta res+1
    }
  } else if (mode = ADDR_ABS) {
    !if (op1 != op2) {
      lda+2 op1
      eor+2 op2
      sta res

      lda+2 op1+1
      eor+2 op2+1
      sta res+1
    } else {
      +Mov16 ADDR_IMM,0,res
    }
  } else if (mode = ADDR_ZER) {
    !if (op1 != op2) {
      lda+1 op1
      eor+1 op2
      sta res

      lda+1 op1+1
      eor+1 op2+1
      sta res+1
    } else {
      +Mov16 ADDR_IMM,0,res
    }
  }
}

; Titolo:                 MACRO: Spostamento aritmetico a sinistra di un valore a 16 bit
; Nome:                   Asl16
; Descrizione:            Esegue uno spostamento aritmetico a sinistra di un valore a 16 bit usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         In realtà è uno spostamento logico, non aritmetico, perché non viene tenuta traccia di un eventuale overflow.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 16 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   ---
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Asl16 mode, op, res {
  !if (mode = ADDR_ABS) {
    !if (op = res) {
      asl+2 op
      rol+2 op+1
    } else {
      lda+2 op
      asl a
      sta res

      lda+2 op+1
      rol a
      sta res+1
    }
  } else if (mode = ADDR_ZER) {
    !if (op = res) {
      asl+1 op
      rol+1 op+1
    } else {
      lda+1 op
      asl a
      sta res

      lda+1 op+1
      rol a
      sta res+1
    }
  }
}

; Titolo:                 MACRO: Spostamento aritmetico a sinistra di un valore a 16 bit con segno
; Nome:                   AslS16
; Descrizione:            Esegue uno spostamento aritmetico a sinistra di un valore a 16 bit con segno usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         A differenza di Asl16 l'eventuale cambiamento di segno dovuto alla fuoriuscita del bit più alto è segnalato dal flag V.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 16 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro AslS16 mode, op, res {
  !if (mode = ADDR_ABS) {
    !if (op = res) {
      asl+2 op

      lda+2 op+1
      adc+2 op+1
      sta op+1
    } else {
      lda+2 op
      asl a
      sta res

      lda+2 op+1
      adc+2 op+1
      sta res+1
    }
  } else if (mode = ADDR_ZER) {
    !if (op = res) {
      asl+1 op

      lda+1 op+1
      adc+1 op+1
      sta op+1
    } else {
      lda+1 op
      asl a
      sta res

      lda+1 op+1
      adc+1 op+1
      sta res+1
    }
  }
}

; Titolo:                 MACRO: Spostamento logico a destra di un valore a 16 bit
; Nome:                   Lsr16
; Descrizione:            Esegue uno spostamento logico a destra di un valore a 16 bit usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 16 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   ---
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Lsr16 mode, op, res {
  !if (mode = ADDR_ABS) {
    !if (op = res) {
      lsr+2 op+1
      ror+2 op
    } else {
      lda+2 op+1
      lsr a
      sta res+1

      lda+2 op
      ror a
      sta res
    }
  } else if (mode = ADDR_ZER) {
    !if (op = res) {
      lsr+1 op+1
      ror+1 op
    } else {
      lda+1 op+1
      lsr a
      sta res+1

      lda+1 op
      ror a
      sta res
    }
  }
}

; Titolo:                 MACRO: Spostamento aritmetico a destra di un valore a 16 bit con segno
; Nome:                   AsrS16
; Descrizione:            Esegue uno spostamento aritmetico a destra di un valore a 16 bit con segno usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 16 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro AsrS16 mode, op, res {
  !if (mode = ADDR_ABS) {
    !if (op = res) {
      lda+2 op+1
      asl a

      ror+2 op+1
      ror+2 op
    } else {
      lda+2 op+1
      asl a

      lda+2 op+1
      ror a
      sta res+1

      lda+2 op
      ror a
      sta res
    }
  } else if (mode = ADDR_ZER) {
    !if (op = res) {
      lda+1 op+1
      asl a

      ror+1 op+1
      ror+1 op
    } else {
      lda+1 op+1
      asl a

      lda+1 op+1
      ror a
      sta res+1

      lda+1 op
      ror a
      sta res
    }
  }
}

; Titolo:                 MACRO: Rotazione a sinistra di un valore a 16 bit attraverso il Carry
; Nome:                   Rol16
; Descrizione:            Esegue una rotazione a sinistra di un valore a 16 bit usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         Il bit di ordine più elevato finisce nel flag C.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 16 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   ---
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Rol16 mode, op, res {
  !if (mode = ADDR_ABS) {
    !if (op = res) {
      rol+2 op
      rol+2 op+1
    } else {
      lda+2 op
      rol a
      sta res

      lda+2 op+1
      rol a
      sta res+1
    }
  } else if (mode = ADDR_ZER) {
    !if (op = res) {
      rol+1 op
      rol+1 op+1
    } else {
      lda+1 op
      rol a
      sta res

      lda+1 op+1
      rol a
      sta res+1
    }
  }
}

; Titolo:                 MACRO: Rotazione a sinistra di un valore a 16 bit
; Nome:                   Rl16
; Descrizione:            Esegue una rotazione a sinistra di un valore a 16 bit senza passare per il Carry usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         Il bit di ordine più elevato finisce nella posizione di ordine meno elevato.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 16 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Rl16 mode, op, res {
  !if (mode = ADDR_ABS) {
    lda+2 op+1
    rol a
    +Rol16 ADDR_ABS, op, res
  } else if (mode = ADDR_ZER) {
    lda+1 op+1
    rol a
    +Rol16 ADDR_ZER, op, res
  }
}

; Titolo:                 MACRO: Rotazione a destra di un valore a 16 bit attraverso il Carry
; Nome:                   Ror16
; Descrizione:            Esegue una rotazione a destra di un valore a 16 bit usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         Il bit di ordine meno elevato finisce nel flag C.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 16 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   ---
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Ror16 mode, op, res {
  !if (mode = ADDR_ABS) {
    !if (op = res) {
      ror+2 op+1
      ror+2 op
    } else {
      lda+2 op+1
      ror a
      sta res+1

      lda+2 op
      ror a
      sta res
    }
  } else if (mode = ADDR_ZER) {
    !if (op = res) {
      ror+1 op+1
      ror+1 op
    } else {
      lda+1 op+1
      ror a
      sta res+1

      lda+1 op+1
      ror a
      sta res
    }
  }
}

; Titolo:                 MACRO: Rotazione a destra di un valore a 16 bit
; Nome:                   Rr16
; Descrizione:            Esegue una rotazione a destra di un valore a 16 bit senza passare per il Carry usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         Il bit di ordine meno elevato finisce nella posizione di ordine più elevato.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               ADDR_ABS = Assoluto: l'operando è un indirizzo assoluto a 16 bit
;                               ADDR_ZER = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Rr16 mode, op, res {
  !if (mode = ADDR_ABS) {
    lda+2 op
    ror a
    +Ror16 ADDR_ABS, op, res
  } else if (mode = ADDR_ZER) {
    lda+1 op
    ror a
    +Ror16 ADDR_ZER, op, res
  }
}
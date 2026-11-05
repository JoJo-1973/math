; Macro per operazioni matematiche con valori a 8 bit

; Titolo:                 MACRO: Negazione di un valore a 8 bit
; Nome:                   Neg
; Descrizione:            Sottrae un valore a 8 bit da 0 usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               "IMM" = Immediato: il primo operando è un indirizzo, il secondo è un valore a 8 bit
;                               "ABS" = Assoluto: entrambi gli operandi sono indirizzi a 8 bit
;                               "ZER" = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Neg mode, op, res {
  !if (mode = "IMM") {
    !if (op != 0) {
      sec

      lda #0
      sbc #op
      sta res
    } else {
      sec
      lda #0
      sta res
    }
  } else if (mode = "ABS") {
    sec

    lda #0
    sbc+2 op
    sta res
  } else if (mode = "ZER") {
    sec

    lda #0
    sbc+1 op
    sta res
  }
}

; Titolo:                 MACRO: NOT booleano di un valore a 8 bit
; Nome:                   Not
; Descrizione:            Inverte un valore a 8 bit usando l'indirizzamento scelto e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               "IMM" = Immediato: il primo operando è un indirizzo, il secondo è un valore a 8 bit
;                               "ABS" = Assoluto: entrambi gli operandi sono indirizzi a 8 bit
;                               "ZER" = Pagina Zero: entrambi gli operandi sono indirizzi in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Not mode, op, res {
  !if (mode = "IMM") {
    !if (op = 0) {
      lda #$FF
      sta res
    } else if (op = $FF) {
      lda #$0
      sta res
    } else {
      lda #op
      eor #$FF
      sta res
    }
  } else if (mode = "ABS") {
    lda+2 op
    eor #$FF
    sta res
  } else if (mode = "ZER") {
    lda+1 op
    eor #$FF
    sta res
  }
}

; Titolo:                 MACRO: Spostamento aritmetico a sinistra di un valore a 8 bit con segno
; Nome:                   AslS
; Descrizione:            Esegue uno spostamento aritmetico a sinistra di un valore a 8 bit con segno usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         A differenza di Asl8 l'eventuale cambiamento di segno dovuto alla fuoriuscita del bit più alto è segnalato dal flag V.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               "ACC" = Accumulatore: l'operando ed il risultato sono contenuti nell'accumulatore
;                               "ABS" = Assoluto: l'operando è un indirizzo assoluto a 8 bit
;                               "ZER" = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  TEMP_1
; Dipendenze esterne:     c64_symbols.asm, standard.asm
!macro AslS mode, op, res {
  !if (mode = "ACC") {
    clc
    sta TEMP_1
    adc TEMP_1
  } else if (mode = "ABS") {
    clc
    lda+2 op
    adc+2 op
    sta res
  } else if (mode = "ZER") {
    clc
    lda+1 op
    adc+1 op
    sta res
  }
}

; Titolo:                 MACRO: Spostamento aritmetico a destra di un valore a 8 bit con segno
; Nome:                   AsrS
; Descrizione:            Esegue uno spostamento aritmetico a destra di un valore a 8 bit con segno usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               "ACC" = Accumulatore: l'operando ed il risultato sono contenuti nell'accumulatore
;                               "ABS" = Assoluto: l'operando è un indirizzo assoluto a 8 bit
;                               "ZER" = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro AsrS mode, op, res {
  !if (mode = "ACC") {
    cmp #%10000000
    ror a
  } else if (mode = "ABS") {
    !if (op = res) {
      lda+2 op
      asl a
      ror+2 op
    } else {
      lda+2 op
      cmp #%10000000
      ror a
      sta res
    }
  } else if (mode = "ZER") {
    !if (op = res) {
      lda+1 op
      asl a
      ror+1 op
    } else {
      lda+1 op
      cmp #%10000000
      ror a
      sta res
    }
  }
}

; Titolo:                 MACRO: Rotazione a sinistra di un valore a 8 bit
; Nome:                   Rl8
; Descrizione:            Esegue una rotazione a sinistra di un valore a 8 bit senza passare per il Carry usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         Il bit di ordine più elevato finisce nella posizione di ordine meno elevato.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               "ACC" = Accumulatore: l'operando ed il risultato sono contenuti nell'accumulatore
;                               "ABS" = Assoluto: l'operando è un indirizzo assoluto a 8 bit
;                               "ZER" = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Rl8 mode, op, res {
  !if (mode = "ACC") {
    cmp #%10000000
    rol a
  } else if (mode = "ABS") {
    !if (op = res) {
      lda+2 op
      rol a
      rol+2 op
    } else {
      lda+1 op
      cmp #%10000000
      rol a
      sta res
    }
  } else if (mode = "ZER") {
    !if (op = res) {
      lda+1 op
      rol a
      rol+1 op
    } else {
      lda+1 op
      cmp #%10000000
      rol a
      sta res
    }
  }
}

; Titolo:                 MACRO: Rotazione a destra di un valore a 8 bit
; Nome:                   Rr8
; Descrizione:            Esegue una rotazione a destra di un valore a 8 bit senza passare per il Carry usando l'indirizzamento scelto
;                         e memorizza il risultato nella locazione desiderata.
;                         Il bit di ordine meno elevato finisce nella posizione di ordine più elevato.
; Parametri di ingresso:  mode: Indirizzamento da usare:
;                               "ACC" = Accumulatore: l'operando ed il risultato sono contenuti nell'accumulatore
;                               "ABS" = Assoluto: l'operando è un indirizzo assoluto a 8 bit
;                               "ZER" = Pagina Zero: l'operando è un indirizzo in pagina zero
;                         op:   Operando
;                         res:  Indirizzo di memoria del risultato; può essere assoluto o in pagina zero indipendentemente dall'indirizzamento
; Parametri di uscita:    ---
; Alterazioni registri:   .A
; Alterazioni pag. zero:  ---
; Dipendenze esterne:     standard.asm
!macro Rr8 mode, op, res {
  !if (mode = "ACC") {
    pha
    ror a
    pla
    ror a
  } else if (mode = "ABS") {
    !if (op = res) {
      lda+2 op
      ror a
      ror+2 op
    } else {
      lda+2 op
      pha
      ror a
      pla
      ror a
      sta res
    }
   } else if (mode = "ZER") {
    !if (op = res) {
      lda+1 op
      ror a
      ror+1 op
    } else {
      lda+1 op
      pha
      ror a
      pla
      ror a
      sta res
    }
  }
}

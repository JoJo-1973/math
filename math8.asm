; ==============================================================================
; FILE:           math8.asm
; PROGETTO:       Libreria di Sistema (math.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per operazioni matematiche su valori a 8 bit.
; CONTENUTO:      m_Neg   Nega un valore a 8 bit
;                 m_Not   NOT booleano di un valore a 8 bit
;                 m_AslS  Scorrimento aritmetico a sinistra con segno
;                 m_AsrS  Scorrimento aritmetico a destra con segno
;                 m_Rl8   Rotazione a sinistra senza passare per il Carry
;                 m_Rr8   Rotazione a destra senza passare per il Carry
; DIPENDENZE:     <c64/symbols.asm>
; REQUISITI ZP:   Nessuno
; ==============================================================================

!source "../c64/symbols.asm", once

; ==============================================================================
; MACRO: m_Neg
; ------------------------------------------------------------------------------
; Descrizione:  Sottrae un valore a 8 bit da zero, secondo l'indirizzamento
;               scelto, e memorizza il risultato nella locazione desiderata.
;
;                 "IMM"  .op_ è un valore a 8 bit.
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Valore (IMM) o indirizzo dell'operando
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (1 byte, Macro)     : Riceve il risultato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, oVerflow, Zero, Carry), .res_
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Neg .mode_, .op_, .res_ {
    !if (.mode_ = "IMM") {
      !if (.op_ = 0) {
        lda #0                  ; Il negato di zero è zero.
      } else {
        lda #$FF-.op_+1         ; Il complemento a 2 è noto all'assemblaggio.
      }

      sta .res_                 ; Memorizza il risultato.
    } else if (.mode_ = "ABS") {
      sec                       ; Nessun prestito iniziale.
      lda #0
      sbc+2 .op_                ; Zero meno il valore: complemento a 2.
      sta .res_                 ; Memorizza il risultato.
    } else if (.mode_ = "ZP") {
      sec                       ; Nessun prestito iniziale.
      lda #0
      sbc+1 .op_                ; Zero meno il valore: complemento a 2.
      sta .res_                 ; Memorizza il risultato.
    }
}

; ==============================================================================
; MACRO: m_Not
; ------------------------------------------------------------------------------
; Descrizione:  Inverte tutti i bit di un valore a 8 bit, secondo
;               l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata.
;
;                 "IMM"  .op_ è un valore a 8 bit.
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Valore (IMM) o indirizzo dell'operando
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (1 byte, Macro)     : Riceve il risultato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), .res_
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Not .mode_, .op_, .res_ {
    !if (.mode_ = "IMM") {
      lda #$FF-.op_             ; Il NOT è noto all'assemblaggio.
      sta .res_                 ; Memorizza il risultato.
    } else if (.mode_ = "ABS") {
      lda+2 .op_                ; Carica il valore.
      eor #$FF                  ; Inverte tutti i bit.
      sta .res_                 ; Memorizza il risultato.
    } else if (.mode_ = "ZP") {
      lda+1 .op_                ; Carica il valore.
      eor #$FF                  ; Inverte tutti i bit.
      sta .res_                 ; Memorizza il risultato.
    }
}

; ==============================================================================
; MACRO: m_AslS
; ------------------------------------------------------------------------------
; Descrizione:  Fa scorrere a sinistra di un bit un valore a 8 bit con segno,
;               secondo l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata. A differenza di un semplice ASL, il
;               cambiamento di segno dovuto all'uscita del bit più alto è
;               segnalato dal flag di oVerflow.
;
;                 "ACC"  L'operando e il risultato sono in .A.
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Con "ACC" la macro usa NUMWRK+0 come cella di appoggio.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "ACC", "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Indirizzo dell'operando (ignorato con "ACC")
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato (ignorato con "ACC")
;   - .A (1 byte, CPU)          : Operando (solo con "ACC")
;
; Output:
;   - .A (1 byte, CPU)          : Risultato (solo con "ACC")
;   - .res_ (1 byte, Macro)     : Riceve il risultato (con "ABS" e "ZP")
;   - Flag oVerflow (1 bit, .P) : 0 = segno invariato; 1 = segno cambiato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, oVerflow, Zero, Carry),
;                       NUMWRK+0 (se .mode_ = "ACC"),
;                       .res_ (se .mode_ = "ABS" o "ZP")
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_AslS .mode_, .op_, .res_ {
    !if (.mode_ = "ACC") {
      clc                       ; Il Carry deve valere 0 prima della somma.
      sta NUMWRK+0              ; Salva il valore: servirà come secondo addendo.
      adc NUMWRK+0              ; Somma il valore a se stesso: raddoppia e imposta V.
    } else if (.mode_ = "ABS") {
      clc                       ; Il Carry deve valere 0 prima della somma.
      lda+2 .op_                ; Carica il valore.
      adc+2 .op_                ; Somma il valore a se stesso: raddoppia e imposta V.
      sta .res_                 ; Memorizza il risultato.
    } else if (.mode_ = "ZP") {
      clc                       ; Il Carry deve valere 0 prima della somma.
      lda+1 .op_                ; Carica il valore.
      adc+1 .op_                ; Somma il valore a se stesso: raddoppia e imposta V.
      sta .res_                 ; Memorizza il risultato.
    }
}

; ==============================================================================
; MACRO: m_AsrS
; ------------------------------------------------------------------------------
; Descrizione:  Fa scorrere a destra di un bit un valore a 8 bit con segno,
;               secondo l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata. Il bit di segno si conserva e il bit
;               uscito finisce nel Carry.
;
;                 "ACC"  L'operando e il risultato sono in .A.
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "ACC", "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Indirizzo dell'operando (ignorato con "ACC")
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato (ignorato con "ACC")
;   - .A (1 byte, CPU)          : Operando (solo con "ACC")
;
; Output:
;   - .A (1 byte, CPU)          : Risultato (solo con "ACC")
;   - .res_ (1 byte, Macro)     : Riceve il risultato (con "ABS" e "ZP")
;   - Flag Carry (1 bit, .P)    : 0 = bit uscito 0; 1 = bit uscito 1
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero, Carry),
;                       .res_ (se .mode_ = "ABS" o "ZP")
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_AsrS .mode_, .op_, .res_ {
    !if (.mode_ = "ACC") {
      cmp #%10000000            ; Il Carry riceve il bit di segno.
      ror a                     ; Il segno rientra dall'alto: il segno si conserva.
    } else if (.mode_ = "ABS") {
      !if (.op_ = .res_) {
        lda+2 .op_              ; Carica il valore.
        asl a                   ; Il Carry riceve il bit di segno.
        ror+2 .op_              ; Il segno rientra dall'alto, in memoria.
      } else {
        lda+2 .op_              ; Carica il valore.
        cmp #%10000000          ; Il Carry riceve il bit di segno.
        ror a                   ; Il segno rientra dall'alto: il segno si conserva.
        sta .res_               ; Memorizza il risultato.
      }
    } else if (.mode_ = "ZP") {
      !if (.op_ = .res_) {
        lda+1 .op_              ; Carica il valore.
        asl a                   ; Il Carry riceve il bit di segno.
        ror+1 .op_              ; Il segno rientra dall'alto, in memoria.
      } else {
        lda+1 .op_              ; Carica il valore.
        cmp #%10000000          ; Il Carry riceve il bit di segno.
        ror a                   ; Il segno rientra dall'alto: il segno si conserva.
        sta .res_               ; Memorizza il risultato.
      }
    }
}

; ==============================================================================
; MACRO: m_Rl8
; ------------------------------------------------------------------------------
; Descrizione:  Ruota a sinistra di un bit un valore a 8 bit senza passare per
;               il Carry, secondo l'indirizzamento scelto, e memorizza il
;               risultato nella locazione desiderata. Il bit più alto finisce
;               nella posizione più bassa.
;
;                 "ACC"  L'operando e il risultato sono in .A.
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "ACC", "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Indirizzo dell'operando (ignorato con "ACC")
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato (ignorato con "ACC")
;   - .A (1 byte, CPU)          : Operando (solo con "ACC")
;
; Output:
;   - .A (1 byte, CPU)          : Risultato (solo con "ACC")
;   - .res_ (1 byte, Macro)     : Riceve il risultato (con "ABS" e "ZP")
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero, Carry),
;                       .res_ (se .mode_ = "ABS" o "ZP")
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Rl8 .mode_, .op_, .res_ {
    !if (.mode_ = "ACC") {
      cmp #%10000000            ; Il Carry riceve il bit #7.
      rol a                     ; Il bit #7 rientra dal basso.
    } else if (.mode_ = "ABS") {
      !if (.op_ = .res_) {
        lda+2 .op_              ; Carica il valore.
        rol a                   ; Il Carry riceve il bit #7.
        rol+2 .op_              ; Il bit #7 rientra dal basso, in memoria.
      } else {
        lda+2 .op_              ; Carica il valore.
        cmp #%10000000          ; Il Carry riceve il bit #7.
        rol a                   ; Il bit #7 rientra dal basso.
        sta .res_               ; Memorizza il risultato.
      }
    } else if (.mode_ = "ZP") {
      !if (.op_ = .res_) {
        lda+1 .op_              ; Carica il valore.
        rol a                   ; Il Carry riceve il bit #7.
        rol+1 .op_              ; Il bit #7 rientra dal basso, in memoria.
      } else {
        lda+1 .op_              ; Carica il valore.
        cmp #%10000000          ; Il Carry riceve il bit #7.
        rol a                   ; Il bit #7 rientra dal basso.
        sta .res_               ; Memorizza il risultato.
      }
    }
}

; ==============================================================================
; MACRO: m_Rr8
; ------------------------------------------------------------------------------
; Descrizione:  Ruota a destra di un bit un valore a 8 bit senza passare per il
;               Carry, secondo l'indirizzamento scelto, e memorizza il risultato
;               nella locazione desiderata. Il bit più basso finisce nella
;               posizione più alta.
;
;                 "ACC"  L'operando e il risultato sono in .A.
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "ACC", "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Indirizzo dell'operando (ignorato con "ACC")
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato (ignorato con "ACC")
;   - .A (1 byte, CPU)          : Operando (solo con "ACC")
;
; Output:
;   - .A (1 byte, CPU)          : Risultato (solo con "ACC")
;   - .res_ (1 byte, Macro)     : Riceve il risultato (con "ABS" e "ZP")
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero, Carry),
;                       .res_ (se .mode_ = "ABS" o "ZP")
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Rr8 .mode_, .op_, .res_ {
    !if (.mode_ = "ACC") {
      pha                       ; Conserva il valore.
      ror a                     ; Il Carry riceve il bit #0.
      pla                       ; Recupera il valore: il Carry non cambia.
      ror a                     ; Il bit #0 rientra dall'alto.
    } else if (.mode_ = "ABS") {
      !if (.op_ = .res_) {
        lda+2 .op_              ; Carica il valore.
        ror a                   ; Il Carry riceve il bit #0.
        ror+2 .op_              ; Il bit #0 rientra dall'alto, in memoria.
      } else {
        lda+2 .op_              ; Carica il valore.
        pha                     ; Conserva il valore.
        ror a                   ; Il Carry riceve il bit #0.
        pla                     ; Recupera il valore: il Carry non cambia.
        ror a                   ; Il bit #0 rientra dall'alto.
        sta .res_               ; Memorizza il risultato.
      }
    } else if (.mode_ = "ZP") {
      !if (.op_ = .res_) {
        lda+1 .op_              ; Carica il valore.
        ror a                   ; Il Carry riceve il bit #0.
        ror+1 .op_              ; Il bit #0 rientra dall'alto, in memoria.
      } else {
        lda+1 .op_              ; Carica il valore.
        pha                     ; Conserva il valore.
        ror a                   ; Il Carry riceve il bit #0.
        pla                     ; Recupera il valore: il Carry non cambia.
        ror a                   ; Il bit #0 rientra dall'alto.
        sta .res_               ; Memorizza il risultato.
      }
    }
}

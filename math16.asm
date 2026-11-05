; ==============================================================================
; FILE:           math16.asm
; PROGETTO:       Libreria di Sistema (math.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per operazioni matematiche su valori a 16 bit.
; CONTENUTO:      m_Asl16   Scorrimento a sinistra di un valore a 16 bit
;                 m_Add16   Somma due valori a 16 bit
;                 m_Sub16   Sottrae due valori a 16 bit
;                 m_Neg16   Nega un valore a 16 bit
;                 m_Not16   NOT booleano di un valore a 16 bit
;                 m_And16   AND booleano di due valori a 16 bit
;                 m_Ora16   OR booleano di due valori a 16 bit
;                 m_Eor16   EOR booleano di due valori a 16 bit
;                 m_AslS16  Scorrimento a sinistra con segno, segnala V
;                 m_Lsr16   Scorrimento logico a destra a 16 bit
;                 m_AsrS16  Scorrimento aritmetico a destra con segno
;                 m_Rol16   Rotazione a sinistra attraverso il Carry
;                 m_Rl16    Rotazione a sinistra senza passare per il Carry
;                 m_Ror16   Rotazione a destra attraverso il Carry
;                 m_Rr16    Rotazione a destra senza passare per il Carry
; DIPENDENZE:     <mem/mem16.asm>
; REQUISITI ZP:   Nessuno
; ==============================================================================

!source "../mem/mem16.asm", once

; ==============================================================================
; MACRO: m_Asl16
; ------------------------------------------------------------------------------
; Descrizione:  Fa scorrere a sinistra di un bit un valore a 16 bit, secondo
;               l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata. È uno scorrimento logico: non si tiene
;               traccia di un eventuale overflow.
;
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Indirizzo dell'operando
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;   - Flag Carry (1 bit, .P)    : 0 = bit uscito 0; 1 = bit uscito 1
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A (se .op_ != .res_), .P (Negative, Zero, Carry),
;                       .res_+0 .. +1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Asl16 .mode_, .op_, .res_ {
    !if (.mode_ = "ABS") {
      !if (.op_ = .res_) {
        asl+2 .op_                          ; Scorre il byte 0: il bit #7 va nel Carry.
        rol+2 .op_+1                        ; Ruota il byte 1 con il Carry.
      } else {
        lda+2 .op_                          ; Byte 0 dell'operando.
        asl a                               ; Scorre il byte 0: il bit #7 va nel Carry.
        sta .res_                           ; Byte 0 del risultato.

        lda+2 .op_+1                        ; Byte 1 dell'operando.
        rol a                               ; Ruota il byte 1 con il Carry.
        sta .res_+1                         ; Byte 1 del risultato.
      }
    } else if (.mode_ = "ZP") {
      !if (.op_ = .res_) {
        asl+1 .op_                          ; Scorre il byte 0: il bit #7 va nel Carry.
        rol+1 .op_+1                        ; Ruota il byte 1 con il Carry.
      } else {
        lda+1 .op_                          ; Byte 0 dell'operando.
        asl a                               ; Scorre il byte 0: il bit #7 va nel Carry.
        sta .res_                           ; Byte 0 del risultato.

        lda+1 .op_+1                        ; Byte 1 dell'operando.
        rol a                               ; Ruota il byte 1 con il Carry.
        sta .res_+1                         ; Byte 1 del risultato.
      }
    }
}

; ==============================================================================
; MACRO: m_Add16
; ------------------------------------------------------------------------------
; Descrizione:  Somma due valori a 16 bit, secondo l'indirizzamento scelto, e
;               memorizza il risultato nella locazione desiderata.
;
;                 "IMM"  Immediato: .add1_ è un indirizzo e .add2_ è un
;                        valore a 16 bit.
;                 "ABS"  Assoluto: gli operandi sono indirizzi
;                        assoluti.
;                 "ZP"   Pagina Zero: gli operandi sono indirizzi in
;                        pagina zero.
;
;               Se i due addendi coincidono ("ABS" e "ZP") il raddoppio è
;               eseguito da m_Asl16, che non imposta V.
;
;               Se .res_ coincide con il primo operando le copie sono omesse, e
;               N e Z non riflettono il risultato.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)    : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .add1_ (1 o 2 byte, Macro) : Indirizzo del primo addendo
;   - .add2_ (2 byte, Macro)     : Secondo addendo: valore (IMM) o indirizzo
;   - .res_ (1 o 2 byte, Macro)  : Indirizzo del risultato, assoluto o in pagina
;                                  zero
;
; Output:
;   - .res_ (2 byte, Macro)      : Riceve il risultato a 16 bit
;   - Flag Carry (1 bit, .P)     : 0 = riporto assente; 1 = riporto
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, oVerflow, Zero, Carry), .res_+0 .. +1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Add16 .mode_, .add1_, .add2_, .res_ {
    !if (.mode_ = "IMM") {
      !if (.add2_ != 0) {
        clc                                 ; Nessun riporto iniziale.

        lda .add1_                          ; Byte 0 del primo addendo.
        adc #<.add2_                        ; Somma il byte 0 della costante.
        sta .res_                           ; Byte 0 del risultato.

        lda .add1_+1                        ; Byte 1 del primo addendo.
        adc #>.add2_                        ; Somma il byte 1 della costante. Con il riporto.
        sta .res_+1                         ; Byte 1 del risultato.
      } else {
        clc                                 ; Con zero il risultato è il primo operando.

        !if (.add1_ != .res_) {
          lda .add1_                        ; Byte 0 del primo addendo.
          sta .res_                         ; Byte 0 del risultato.

          lda .add1_+1                      ; Byte 1 del primo addendo.
          sta .res_+1                       ; Byte 1 del risultato.
        }
      }
    } else if (.mode_ = "ABS") {
      !if (.add1_ = .add2_) {
        +m_Asl16 "ABS", .add1_, .res_       ; Un valore sommato a se stesso è il suo doppio.
      } else {
        clc                                 ; Nessun riporto iniziale.

        lda+2 .add1_                        ; Byte 0 del primo addendo.
        adc+2 .add2_                        ; Somma il byte 0 del secondo addendo.
        sta .res_                           ; Byte 0 del risultato.

        lda+2 .add1_+1                      ; Byte 1 del primo addendo.
        adc+2 .add2_+1                      ; Somma il byte 1 del secondo addendo. Con il riporto.
        sta .res_+1                         ; Byte 1 del risultato.
      }
    } else if (.mode_ = "ZP") {
      !if (.add1_ = .add2_) {
        +m_Asl16 "ZP", .add1_, .res_        ; Un valore sommato a se stesso è il suo doppio.
      } else {
        clc                                 ; Nessun riporto iniziale.

        lda+1 .add1_                        ; Byte 0 del primo addendo.
        adc+1 .add2_                        ; Somma il byte 0 del secondo addendo.
        sta .res_                           ; Byte 0 del risultato.

        lda+1 .add1_+1                      ; Byte 1 del primo addendo.
        adc+1 .add2_+1                      ; Somma il byte 1 del secondo addendo. Con il riporto.
        sta .res_+1                         ; Byte 1 del risultato.
      }
    }
}

; ==============================================================================
; MACRO: m_Sub16
; ------------------------------------------------------------------------------
; Descrizione:  Sottrae il sottraendo dal minuendo, due valori a 16 bit, secondo
;               l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata.
;
;                 "IMM"  Immediato: .min_ è un indirizzo e .sub_ è un
;                        valore a 16 bit.
;                 "ABS"  Assoluto: gli operandi sono indirizzi
;                        assoluti.
;                 "ZP"   Pagina Zero: gli operandi sono indirizzi in
;                        pagina zero.
;
;               Se .res_ coincide con il minuendo e il sottraendo vale zero, la
;               copia è omessa, e N e Z non riflettono il risultato.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .min_ (1 o 2 byte, Macro) : Indirizzo del minuendo
;   - .sub_ (2 byte, Macro)     : Sottraendo: valore (IMM) o indirizzo
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;   - Flag Carry (1 bit, .P)    : 0 = prestito; 1 = nessun prestito
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, oVerflow, Zero, Carry), .res_+0 .. +1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Sub16 .mode_, .min_, .sub_, .res_ {
    !if (.mode_ = "IMM") {
      !if (.sub_ != 0) {
        sec                                 ; Nessun prestito iniziale.

        lda .min_                           ; Byte 0 del minuendo.
        sbc #<.sub_                         ; Sottrae il byte 0 della costante.
        sta .res_                           ; Byte 0 del risultato.

        lda .min_+1                         ; Byte 1 del minuendo.
        sbc #>.sub_                         ; Sottrae il byte 1 della costante. Con il prestito.
        sta .res_+1                         ; Byte 1 del risultato.
      } else {
        sec                                 ; Con zero il risultato è il primo operando.

        !if (.min_ != .res_) {
          lda .min_                         ; Byte 0 del minuendo.
          sta .res_                         ; Byte 0 del risultato.

          lda .min_+1                       ; Byte 1 del minuendo.
          sta .res_+1                       ; Byte 1 del risultato.
        }
      }
    } else if (.mode_ = "ABS") {
      !if (.min_ != .sub_) {
        sec                                 ; Nessun prestito iniziale.

        lda+2 .min_                         ; Byte 0 del minuendo.
        sbc+2 .sub_                         ; Sottrae il byte 0 del sottraendo.
        sta .res_                           ; Byte 0 del risultato.

        lda+2 .min_+1                       ; Byte 1 del minuendo.
        sbc+2 .sub_+1                       ; Sottrae il byte 1 del sottraendo. Con il prestito.
        sta .res_+1                         ; Byte 1 del risultato.
      } else {
        sec                                 ; Un valore meno se stesso: nessun prestito.
        lda #0                              ; Il risultato è zero.
        sta .res_                           ; Azzera il byte 0 del risultato.
        sta .res_+1                         ; Azzera il byte 1 del risultato.
      }
    } else if (.mode_ = "ZP") {
      !if (.min_ != .sub_) {
        sec                                 ; Nessun prestito iniziale.

        lda+1 .min_                         ; Byte 0 del minuendo.
        sbc+1 .sub_                         ; Sottrae il byte 0 del sottraendo.
        sta .res_                           ; Byte 0 del risultato.

        lda+1 .min_+1                       ; Byte 1 del minuendo.
        sbc+1 .sub_+1                       ; Sottrae il byte 1 del sottraendo. Con il prestito.
        sta .res_+1                         ; Byte 1 del risultato.
      } else {
        sec                                 ; Un valore meno se stesso: nessun prestito.
        lda #0                              ; Il risultato è zero.
        sta .res_                           ; Azzera il byte 0 del risultato.
        sta .res_+1                         ; Azzera il byte 1 del risultato.
      }
    }
}

; ==============================================================================
; MACRO: m_Neg16
; ------------------------------------------------------------------------------
; Descrizione:  Sottrae un valore a 16 bit da zero, secondo l'indirizzamento
;               scelto, e memorizza il risultato nella locazione desiderata.
;
;                 "IMM"  .op_ è un valore a 16 bit.
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Con "IMM" il risultato è calcolato dall'assemblatore e caricato
;               da m_Mov16.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op_ (2 byte, Macro)      : Valore (IMM) o indirizzo dell'operando
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, oVerflow, Zero, Carry), .res_+0 .. +1
; Dipendenze Esterne:   <mem/mem16.asm>
; ==============================================================================
!macro m_Neg16 .mode_, .op_, .res_ {
    !if (.mode_ = "IMM") {
      !if (.op_ = 0) {
        +m_Mov16 "IMM", 0, .res_            ; Il negato di zero è zero.
      } else {
        +m_Mov16 "IMM", $FFFF-.op_+1, .res_ ; Il complemento a 2 è noto all'assemblaggio.
      }
    } else if (.mode_ = "ABS") {
      sec                                   ; Nessun prestito iniziale.

      lda #0
      sbc+2 .op_                            ; Sottrae il byte 0.
      sta .res_                             ; Byte 0 del risultato.

      lda #0
      sbc+2 .op_+1                          ; Sottrae il byte 1. Con il prestito.
      sta .res_+1                           ; Byte 1 del risultato.
    } else if (.mode_ = "ZP") {
      sec                                   ; Nessun prestito iniziale.

      lda #0
      sbc+1 .op_                            ; Sottrae il byte 0.
      sta .res_                             ; Byte 0 del risultato.

      lda #0
      sbc+1 .op_+1                          ; Sottrae il byte 1. Con il prestito.
      sta .res_+1                           ; Byte 1 del risultato.
    }
}

; ==============================================================================
; MACRO: m_Not16
; ------------------------------------------------------------------------------
; Descrizione:  Inverte tutti i bit di un valore a 16 bit, secondo
;               l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata.
;
;                 "IMM"  .op_ è un valore a 16 bit.
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Con "IMM" il risultato è calcolato dall'assemblatore e caricato
;               da m_Mov16.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op_ (2 byte, Macro)      : Valore (IMM) o indirizzo dell'operando
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), .res_+0 .. +1
; Dipendenze Esterne:   <mem/mem16.asm>
; ==============================================================================
!macro m_Not16 .mode_, .op_, .res_ {
    !if (.mode_ = "IMM") {
      +m_Mov16 "IMM", $FFFF-.op_, .res_     ; Il NOT è noto all'assemblaggio.
    } else if (.mode_ = "ABS") {
      lda+2 .op_                            ; Byte 0 dell'operando.
      eor #$FF                              ; Inverte tutti i bit.
      sta .res_                             ; Byte 0 del risultato.

      lda+2 .op_+1                          ; Byte 1 dell'operando.
      eor #$FF                              ; Inverte tutti i bit.
      sta .res_+1                           ; Byte 1 del risultato.
    } else if (.mode_ = "ZP") {
      lda+1 .op_                            ; Byte 0 dell'operando.
      eor #$FF                              ; Inverte tutti i bit.
      sta .res_                             ; Byte 0 del risultato.

      lda+1 .op_+1                          ; Byte 1 dell'operando.
      eor #$FF                              ; Inverte tutti i bit.
      sta .res_+1                           ; Byte 1 del risultato.
    }
}

; ==============================================================================
; MACRO: m_And16
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un AND booleano tra due valori a 16 bit, secondo
;               l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata.
;
;                 "IMM"  Immediato: .op1_ è un indirizzo e .op2_ è un
;                        valore a 16 bit.
;                 "ABS"  Assoluto: gli operandi sono indirizzi
;                        assoluti.
;                 "ZP"   Pagina Zero: gli operandi sono indirizzi in
;                        pagina zero.
;
;               Con "IMM" i byte della costante pari a $00 o $FF sono trattati a
;               parte: azzerano il byte o lo lasciano com'è.
;
;               Se .res_ coincide con il primo operando le copie inutili sono
;               omesse, e N e Z non riflettono il risultato.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op1_ (1 o 2 byte, Macro) : Indirizzo del primo operando
;   - .op2_ (2 byte, Macro)     : Secondo operando: valore (IMM) o indirizzo
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), .res_+0 .. +1
; Dipendenze Esterne:   <mem/mem16.asm>
; ==============================================================================
!macro m_And16 .mode_, .op1_, .op2_, .res_ {
    !if (.mode_ = "IMM") {
      !if (.op2_ = 0) {
        +m_Mov16 "IMM", 0, .res_            ; AND con zero: il risultato è zero.
      } else {
        !if ((.op2_ & $FF) = 0) {
          lda #0                            ; AND con zero: il byte 0 è zero.
          sta .res_                         ; Byte 0 del risultato.
        } else if ((.op2_ & $FF) = $FF) {
          !if (.op1_ != .res_) {
            lda .op1_                       ; Byte 0 del primo operando.
            sta .res_                       ; Byte 0 del risultato.
          }
        } else {
          lda .op1_                         ; Byte 0 del primo operando.
          and #<.op2_                       ; AND con il byte 0 della costante.
          sta .res_                         ; Byte 0 del risultato.
        }

        !if (((.op2_ >> 8) & $FF) = 0) {
          lda #0                            ; AND con zero: il byte 1 è zero.
          sta .res_+1                       ; Byte 1 del risultato.
        } else if (((.op2_ >> 8) & $FF) = $FF) {
          !if (.op1_ != .res_) {
            lda .op1_+1                     ; Byte 1 del primo operando.
            sta .res_+1                     ; Byte 1 del risultato.
          }
        } else {
          lda .op1_+1                       ; Byte 1 del primo operando.
          and #>.op2_                       ; AND con il byte 1 della costante.
          sta .res_+1                       ; Byte 1 del risultato.
        }
      }
    } else if (.mode_ = "ABS") {
      !if (.op1_ != .op2_) {
        lda+2 .op1_                         ; Byte 0 del primo operando.
        and+2 .op2_                         ; AND con il byte 0 del secondo operando.
        sta .res_                           ; Byte 0 del risultato.

        lda+2 .op1_+1                       ; Byte 1 del primo operando.
        and+2 .op2_+1                       ; AND con il byte 1 del secondo operando.
        sta .res_+1                         ; Byte 1 del risultato.
      } else {
        !if (.op1_ != .res_) {
          lda+2 .op1_                       ; Byte 0 del primo operando.
          sta .res_                         ; Byte 0 del risultato.

          lda+2 .op1_+1                     ; Byte 1 del primo operando.
          sta .res_+1                       ; Byte 1 del risultato.
        }
      }
    } else if (.mode_ = "ZP") {
      !if (.op1_ != .op2_) {
        lda+1 .op1_                         ; Byte 0 del primo operando.
        and+1 .op2_                         ; AND con il byte 0 del secondo operando.
        sta .res_                           ; Byte 0 del risultato.

        lda+1 .op1_+1                       ; Byte 1 del primo operando.
        and+1 .op2_+1                       ; AND con il byte 1 del secondo operando.
        sta .res_+1                         ; Byte 1 del risultato.
      } else {
        !if (.op1_ != .res_) {
          lda+1 .op1_                       ; Byte 0 del primo operando.
          sta .res_                         ; Byte 0 del risultato.

          lda+1 .op1_+1                     ; Byte 1 del primo operando.
          sta .res_+1                       ; Byte 1 del risultato.
        }
      }
    }
}

; ==============================================================================
; MACRO: m_Ora16
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un OR booleano tra due valori a 16 bit, secondo
;               l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata.
;
;                 "IMM"  Immediato: .op1_ è un indirizzo e .op2_ è un
;                        valore a 16 bit.
;                 "ABS"  Assoluto: gli operandi sono indirizzi
;                        assoluti.
;                 "ZP"   Pagina Zero: gli operandi sono indirizzi in
;                        pagina zero.
;
;               Con "IMM" i byte della costante pari a $00 o $FF sono trattati a
;               parte: lasciano il byte com'è o lo portano a $FF.
;
;               Se .res_ coincide con il primo operando le copie inutili sono
;               omesse, e N e Z non riflettono il risultato.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op1_ (1 o 2 byte, Macro) : Indirizzo del primo operando
;   - .op2_ (2 byte, Macro)     : Secondo operando: valore (IMM) o indirizzo
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), .res_+0 .. +1
; Dipendenze Esterne:   <mem/mem16.asm>
; ==============================================================================
!macro m_Ora16 .mode_, .op1_, .op2_, .res_ {
    !if (.mode_ = "IMM") {
      !if (.op2_ = $FFFF) {
        +m_Mov16 "IMM", $FFFF, .res_        ; OR con tutto uno: il risultato è tutto uno.
      } else {
        !if ((.op2_ & $FF) = 0) {
          !if (.op1_ != .res_) {
            lda .op1_                       ; Byte 0 del primo operando.
            sta .res_                       ; Byte 0 del risultato.
          }
        } else if ((.op2_ & $FF) = $FF) {
          lda #$FF                          ; OR con tutto uno: il byte 0 è $FF.
          sta .res_                         ; Byte 0 del risultato.
        } else {
          lda .op1_                         ; Byte 0 del primo operando.
          ora #<.op2_                       ; OR con il byte 0 della costante.
          sta .res_                         ; Byte 0 del risultato.
        }

        !if (((.op2_ >> 8) & $FF) = 0) {
          !if (.op1_ != .res_) {
            lda .op1_+1                     ; Byte 1 del primo operando.
            sta .res_+1                     ; Byte 1 del risultato.
          }
        } else if (((.op2_ >> 8) & $FF) = $FF) {
          lda #$FF                          ; OR con tutto uno: il byte 1 è $FF.
          sta .res_+1                       ; Byte 1 del risultato.
        } else {
          lda .op1_+1                       ; Byte 1 del primo operando.
          ora #>.op2_                       ; OR con il byte 1 della costante.
          sta .res_+1                       ; Byte 1 del risultato.
        }
      }
    } else if (.mode_ = "ABS") {
      !if (.op1_ != .op2_) {
        lda+2 .op1_                         ; Byte 0 del primo operando.
        ora+2 .op2_                         ; OR con il byte 0 del secondo operando.
        sta .res_                           ; Byte 0 del risultato.

        lda+2 .op1_+1                       ; Byte 1 del primo operando.
        ora+2 .op2_+1                       ; OR con il byte 1 del secondo operando.
        sta .res_+1                         ; Byte 1 del risultato.
      } else {
        !if (.op1_ != .res_) {
          lda+2 .op1_                       ; Byte 0 del primo operando.
          sta .res_                         ; Byte 0 del risultato.

          lda+2 .op1_+1                     ; Byte 1 del primo operando.
          sta .res_+1                       ; Byte 1 del risultato.
        }
      }
    } else if (.mode_ = "ZP") {
      !if (.op1_ != .op2_) {
        lda+1 .op1_                         ; Byte 0 del primo operando.
        ora+1 .op2_                         ; OR con il byte 0 del secondo operando.
        sta .res_                           ; Byte 0 del risultato.

        lda+1 .op1_+1                       ; Byte 1 del primo operando.
        ora+1 .op2_+1                       ; OR con il byte 1 del secondo operando.
        sta .res_+1                         ; Byte 1 del risultato.
      } else {
        !if (.op1_ != .res_) {
          lda+1 .op1_                       ; Byte 0 del primo operando.
          sta .res_                         ; Byte 0 del risultato.

          lda+1 .op1_+1                     ; Byte 1 del primo operando.
          sta .res_+1                       ; Byte 1 del risultato.
        }
      }
    }
}

; ==============================================================================
; MACRO: m_Eor16
; ------------------------------------------------------------------------------
; Descrizione:  Esegue un EOR booleano tra due valori a 16 bit, secondo
;               l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata.
;
;                 "IMM"  Immediato: .op1_ è un indirizzo e .op2_ è un
;                        valore a 16 bit.
;                 "ABS"  Assoluto: gli operandi sono indirizzi
;                        assoluti.
;                 "ZP"   Pagina Zero: gli operandi sono indirizzi in
;                        pagina zero.
;
;               Con "IMM" i byte della costante pari a $00 sono trattati a
;               parte: lasciano il byte com'è.
;
;               Se .res_ coincide con il primo operando le copie inutili sono
;               omesse, e N e Z non riflettono il risultato.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "IMM", "ABS" oppure "ZP"
;   - .op1_ (1 o 2 byte, Macro) : Indirizzo del primo operando
;   - .op2_ (2 byte, Macro)     : Secondo operando: valore (IMM) o indirizzo
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero), .res_+0 .. +1
; Dipendenze Esterne:   <mem/mem16.asm>
; ==============================================================================
!macro m_Eor16 .mode_, .op1_, .op2_, .res_ {
    !if (.mode_ = "IMM") {
      !if (.op2_ != 0) {
        !if ((.op2_ & $FF) = 0) {
          !if (.op1_ != .res_) {
            lda .op1_                       ; Byte 0 del primo operando.
            sta .res_                       ; Byte 0 del risultato.
          }
        } else {
          lda .op1_                         ; Byte 0 del primo operando.
          eor #<.op2_                       ; EOR con il byte 0 della costante.
          sta .res_                         ; Byte 0 del risultato.
        }

        !if (((.op2_ >> 8) & $FF) = 0) {
          !if (.op1_ != .res_) {
            lda .op1_+1                     ; Byte 1 del primo operando.
            sta .res_+1                     ; Byte 1 del risultato.
          }
        } else {
          lda .op1_+1                       ; Byte 1 del primo operando.
          eor #>.op2_                       ; EOR con il byte 1 della costante.
          sta .res_+1                       ; Byte 1 del risultato.
        }
      } else {
        !if (.op1_ != .res_) {
          lda .op1_                         ; Byte 0 del primo operando.
          sta .res_                         ; Byte 0 del risultato.

          lda .op1_+1                       ; Byte 1 del primo operando.
          sta .res_+1                       ; Byte 1 del risultato.
        }
      }
    } else if (.mode_ = "ABS") {
      !if (.op1_ != .op2_) {
        lda+2 .op1_                         ; Byte 0 del primo operando.
        eor+2 .op2_                         ; EOR con il byte 0 del secondo operando.
        sta .res_                           ; Byte 0 del risultato.

        lda+2 .op1_+1                       ; Byte 1 del primo operando.
        eor+2 .op2_+1                       ; EOR con il byte 1 del secondo operando.
        sta .res_+1                         ; Byte 1 del risultato.
      } else {
        +m_Mov16 "IMM", 0, .res_            ; EOR di un valore con se stesso: zero.
      }
    } else if (.mode_ = "ZP") {
      !if (.op1_ != .op2_) {
        lda+1 .op1_                         ; Byte 0 del primo operando.
        eor+1 .op2_                         ; EOR con il byte 0 del secondo operando.
        sta .res_                           ; Byte 0 del risultato.

        lda+1 .op1_+1                       ; Byte 1 del primo operando.
        eor+1 .op2_+1                       ; EOR con il byte 1 del secondo operando.
        sta .res_+1                         ; Byte 1 del risultato.
      } else {
        +m_Mov16 "IMM", 0, .res_            ; EOR di un valore con se stesso: zero.
      }
    }
}

; ==============================================================================
; MACRO: m_AslS16
; ------------------------------------------------------------------------------
; Descrizione:  Fa scorrere a sinistra di un bit un valore a 16 bit con segno,
;               secondo l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata. A differenza di m_Asl16 il cambiamento di
;               segno dovuto all'uscita del bit più alto è segnalato da V.
;
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Indirizzo dell'operando
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;   - Flag oVerflow (1 bit, .P) : 0 = segno invariato; 1 = segno cambiato
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, oVerflow, Zero, Carry), .res_+0 .. +1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_AslS16 .mode_, .op_, .res_ {
    !if (.mode_ = "ABS") {
      !if (.op_ = .res_) {
        asl+2 .op_                          ; Scorre il byte 0: il bit #7 va nel Carry.

        lda+2 .op_+1                        ; Byte più alto: la somma imposta V.
        adc+2 .op_+1                        ; Raddoppia con il Carry: V segnala il cambio di segno.
        sta .op_+1                          ; Memorizza il byte più alto.
      } else {
        lda+2 .op_                          ; Byte 0 dell'operando.
        asl a                               ; Scorre il byte 0: il bit #7 va nel Carry.
        sta .res_                           ; Byte 0 del risultato.

        lda+2 .op_+1                        ; Byte 1 dell'operando.
        adc+2 .op_+1                        ; Raddoppia con il Carry: V segnala il cambio di segno.
        sta .res_+1                         ; Byte 1 del risultato.
      }
    } else if (.mode_ = "ZP") {
      !if (.op_ = .res_) {
        asl+1 .op_                          ; Scorre il byte 0: il bit #7 va nel Carry.

        lda+1 .op_+1                        ; Byte più alto: la somma imposta V.
        adc+1 .op_+1                        ; Raddoppia con il Carry: V segnala il cambio di segno.
        sta .op_+1                          ; Memorizza il byte più alto.
      } else {
        lda+1 .op_                          ; Byte 0 dell'operando.
        asl a                               ; Scorre il byte 0: il bit #7 va nel Carry.
        sta .res_                           ; Byte 0 del risultato.

        lda+1 .op_+1                        ; Byte 1 dell'operando.
        adc+1 .op_+1                        ; Raddoppia con il Carry: V segnala il cambio di segno.
        sta .res_+1                         ; Byte 1 del risultato.
      }
    }
}

; ==============================================================================
; MACRO: m_Lsr16
; ------------------------------------------------------------------------------
; Descrizione:  Fa scorrere a destra di un bit un valore a 16 bit, secondo
;               l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata. Il bit più alto del risultato vale zero.
;
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Indirizzo dell'operando
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;   - Flag Carry (1 bit, .P)    : 0 = bit uscito 0; 1 = bit uscito 1
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A (se .op_ != .res_), .P (Negative, Zero, Carry),
;                       .res_+0 .. +1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Lsr16 .mode_, .op_, .res_ {
    !if (.mode_ = "ABS") {
      !if (.op_ = .res_) {
        lsr+2 .op_+1                        ; Scorre il byte 1: il bit #0 va nel Carry.
        ror+2 .op_                          ; Ruota il byte 0 con il Carry.
      } else {
        lda+2 .op_+1                        ; Byte 1 dell'operando.
        lsr a                               ; Scorre il byte 1: il bit #0 va nel Carry.
        sta .res_+1                         ; Byte 1 del risultato.

        lda+2 .op_                          ; Byte 0 dell'operando.
        ror a                               ; Ruota il byte 0 con il Carry.
        sta .res_                           ; Byte 0 del risultato.
      }
    } else if (.mode_ = "ZP") {
      !if (.op_ = .res_) {
        lsr+1 .op_+1                        ; Scorre il byte 1: il bit #0 va nel Carry.
        ror+1 .op_                          ; Ruota il byte 0 con il Carry.
      } else {
        lda+1 .op_+1                        ; Byte 1 dell'operando.
        lsr a                               ; Scorre il byte 1: il bit #0 va nel Carry.
        sta .res_+1                         ; Byte 1 del risultato.

        lda+1 .op_                          ; Byte 0 dell'operando.
        ror a                               ; Ruota il byte 0 con il Carry.
        sta .res_                           ; Byte 0 del risultato.
      }
    }
}

; ==============================================================================
; MACRO: m_AsrS16
; ------------------------------------------------------------------------------
; Descrizione:  Fa scorrere a destra di un bit un valore a 16 bit con segno,
;               secondo l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata. Il bit di segno si conserva.
;
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Indirizzo dell'operando
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;   - Flag Carry (1 bit, .P)    : 0 = bit uscito 0; 1 = bit uscito 1
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero, Carry), .res_+0 .. +1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_AsrS16 .mode_, .op_, .res_ {
    !if (.mode_ = "ABS") {
      !if (.op_ = .res_) {
        lda+2 .op_+1                        ; Byte più alto: il bit #7 è il segno.
        asl a                               ; Il Carry riceve il bit di segno.

        ror+2 .op_+1                        ; Il segno rientra dall'alto: il segno si conserva.
        ror+2 .op_                          ; Ruota il byte 0 con il Carry.
      } else {
        lda+2 .op_+1                        ; Byte più alto: il bit #7 è il segno.
        asl a                               ; Il Carry riceve il bit di segno.

        lda+2 .op_+1                        ; Byte 1 dell'operando.
        ror a                               ; Il segno rientra dall'alto: il segno si conserva.
        sta .res_+1                         ; Byte 1 del risultato.

        lda+2 .op_                          ; Byte 0 dell'operando.
        ror a                               ; Ruota il byte 0 con il Carry.
        sta .res_                           ; Byte 0 del risultato.
      }
    } else if (.mode_ = "ZP") {
      !if (.op_ = .res_) {
        lda+1 .op_+1                        ; Byte più alto: il bit #7 è il segno.
        asl a                               ; Il Carry riceve il bit di segno.

        ror+1 .op_+1                        ; Il segno rientra dall'alto: il segno si conserva.
        ror+1 .op_                          ; Ruota il byte 0 con il Carry.
      } else {
        lda+1 .op_+1                        ; Byte più alto: il bit #7 è il segno.
        asl a                               ; Il Carry riceve il bit di segno.

        lda+1 .op_+1                        ; Byte 1 dell'operando.
        ror a                               ; Il segno rientra dall'alto: il segno si conserva.
        sta .res_+1                         ; Byte 1 del risultato.

        lda+1 .op_                          ; Byte 0 dell'operando.
        ror a                               ; Ruota il byte 0 con il Carry.
        sta .res_                           ; Byte 0 del risultato.
      }
    }
}

; ==============================================================================
; MACRO: m_Rol16
; ------------------------------------------------------------------------------
; Descrizione:  Ruota a sinistra di un bit un valore a 16 bit attraverso il
;               Carry, secondo l'indirizzamento scelto, e memorizza il risultato
;               nella locazione desiderata. Il bit più alto esce nel Carry.
;
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Indirizzo dell'operando
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;   - Flag Carry (1 bit, .P)    : 0 = bit uscito 0; 1 = bit uscito 1
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A (se .op_ != .res_), .P (Negative, Zero, Carry),
;                       .res_+0 .. +1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Rol16 .mode_, .op_, .res_ {
    !if (.mode_ = "ABS") {
      !if (.op_ = .res_) {
        rol+2 .op_                          ; Ruota il byte 0: il Carry entra dal basso.
        rol+2 .op_+1                        ; Ruota il byte 1: il Carry entra dal basso.
      } else {
        lda+2 .op_                          ; Byte 0 dell'operando.
        rol a                               ; Ruota il byte 0: il Carry entra dal basso.
        sta .res_                           ; Byte 0 del risultato.

        lda+2 .op_+1                        ; Byte 1 dell'operando.
        rol a                               ; Ruota il byte 1: il Carry entra dal basso.
        sta .res_+1                         ; Byte 1 del risultato.
      }
    } else if (.mode_ = "ZP") {
      !if (.op_ = .res_) {
        rol+1 .op_                          ; Ruota il byte 0: il Carry entra dal basso.
        rol+1 .op_+1                        ; Ruota il byte 1: il Carry entra dal basso.
      } else {
        lda+1 .op_                          ; Byte 0 dell'operando.
        rol a                               ; Ruota il byte 0: il Carry entra dal basso.
        sta .res_                           ; Byte 0 del risultato.

        lda+1 .op_+1                        ; Byte 1 dell'operando.
        rol a                               ; Ruota il byte 1: il Carry entra dal basso.
        sta .res_+1                         ; Byte 1 del risultato.
      }
    }
}

; ==============================================================================
; MACRO: m_Rl16
; ------------------------------------------------------------------------------
; Descrizione:  Ruota a sinistra di un bit un valore a 16 bit senza passare per
;               il Carry, secondo l'indirizzamento scelto, e memorizza il
;               risultato nella locazione desiderata. Il bit più alto finisce
;               nella posizione più bassa.
;
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Indirizzo dell'operando
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero, Carry), .res_+0 .. +1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Rl16 .mode_, .op_, .res_ {
    !if (.mode_ = "ABS") {
      lda+2 .op_+1                          ; Byte più alto: il bit #7 deve rientrare dal basso.
      rol a                                 ; Il Carry riceve il bit più alto.
      +m_Rol16 "ABS", .op_, .res_           ; La rotazione col Carry lo fa rientrare nel byte 0.
    } else if (.mode_ = "ZP") {
      lda+1 .op_+1                          ; Byte più alto: il bit #7 deve rientrare dal basso.
      rol a                                 ; Il Carry riceve il bit più alto.
      +m_Rol16 "ZP", .op_, .res_            ; La rotazione col Carry lo fa rientrare nel byte 0.
    }
}

; ==============================================================================
; MACRO: m_Ror16
; ------------------------------------------------------------------------------
; Descrizione:  Ruota a destra di un bit un valore a 16 bit attraverso il Carry,
;               secondo l'indirizzamento scelto, e memorizza il risultato nella
;               locazione desiderata. Il bit più basso esce nel Carry.
;
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Indirizzo dell'operando
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;   - Flag Carry (1 bit, .P)    : 0 = bit uscito 0; 1 = bit uscito 1
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A (se .op_ != .res_), .P (Negative, Zero, Carry),
;                       .res_+0 .. +1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Ror16 .mode_, .op_, .res_ {
    !if (.mode_ = "ABS") {
      !if (.op_ = .res_) {
        ror+2 .op_+1                        ; Ruota il byte 1: il Carry entra dall'alto.
        ror+2 .op_                          ; Ruota il byte 0: il Carry entra dall'alto.
      } else {
        lda+2 .op_+1                        ; Byte 1 dell'operando.
        ror a                               ; Ruota il byte 1: il Carry entra dall'alto.
        sta .res_+1                         ; Byte 1 del risultato.

        lda+2 .op_                          ; Byte 0 dell'operando.
        ror a                               ; Ruota il byte 0: il Carry entra dall'alto.
        sta .res_                           ; Byte 0 del risultato.
      }
    } else if (.mode_ = "ZP") {
      !if (.op_ = .res_) {
        ror+1 .op_+1                        ; Ruota il byte 1: il Carry entra dall'alto.
        ror+1 .op_                          ; Ruota il byte 0: il Carry entra dall'alto.
      } else {
        lda+1 .op_+1                        ; Byte 1 dell'operando.
        ror a                               ; Ruota il byte 1: il Carry entra dall'alto.
        sta .res_+1                         ; Byte 1 del risultato.

        lda+1 .op_                          ; Byte 0 dell'operando.
        ror a                               ; Ruota il byte 0: il Carry entra dall'alto.
        sta .res_                           ; Byte 0 del risultato.
      }
    }
}

; ==============================================================================
; MACRO: m_Rr16
; ------------------------------------------------------------------------------
; Descrizione:  Ruota a destra di un bit un valore a 16 bit senza passare per il
;               Carry, secondo l'indirizzamento scelto, e memorizza il risultato
;               nella locazione desiderata. Il bit più basso finisce nella
;               posizione più alta.
;
;                 "ABS"  .op_ è un indirizzo assoluto.
;                 "ZP"   .op_ è un indirizzo in pagina zero.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mode_ (stringa, Macro)   : Indirizzamento: "ABS" oppure "ZP"
;   - .op_ (1 o 2 byte, Macro)  : Indirizzo dell'operando
;   - .res_ (1 o 2 byte, Macro) : Indirizzo del risultato, assoluto o in pagina
;                                 zero
;
; Output:
;   - .res_ (2 byte, Macro)     : Riceve il risultato a 16 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, Zero, Carry), .res_+0 .. +1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Rr16 .mode_, .op_, .res_ {
    !if (.mode_ = "ABS") {
      lda+2 .op_                            ; Byte 0: il bit #0 deve rientrare dall'alto.
      ror a                                 ; Il Carry riceve il bit più basso.
      +m_Ror16 "ABS", .op_, .res_           ; La rotazione col Carry lo fa rientrare nel byte più alto.
    } else if (.mode_ = "ZP") {
      lda+1 .op_                            ; Byte 0: il bit #0 deve rientrare dall'alto.
      ror a                                 ; Il Carry riceve il bit più basso.
      +m_Ror16 "ZP", .op_, .res_            ; La rotazione col Carry lo fa rientrare nel byte più alto.
    }
}

; ==============================================================================
; FILE:           rng.asm
; PROGETTO:       Libreria di Sistema (math.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Generatori di numeri pseudocasuali. Per ora c'è solo
;                 XORSHIFT_16, di Bumbershoot, adattato in formato ACME. Lo
;                 stato del generatore, 4 byte di RAM, è interno al modulo e si
;                 assembla solo se una delle due routine è attiva.
; CONTENUTO:      RANDOMIZE_XORSHIFT_16   Inizializza lo stato con l'orologio
;                 RND_XORSHIFT_16         Calcola il numero casuale seguente
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   Nessuno
; ==============================================================================

; ****************************************************************
; * TO-DO: implementare XORSHIFT_8.                              *
; *                                                              *
; * Che cosa fa il codice: il modulo offre solo il generatore    *
; * XORSHIFT_16, che calcola con 16 bit di stato.                *
; *                                                              *
; * Che cosa succede davvero: manca la variante a 8 bit di       *
; * Edward Rosten, più piccola e più veloce, adatta a chi non ha *
; * bisogno di 16 bit.                                           *
; *                                                              *
; * Conseguenze: chi vuole un generatore a 8 bit deve            *
; * scriverselo, oppure usare XORSHIFT_16 e scartare un byte.    *
; *                                                              *
; * Correzione: aggiungere RANDOMIZE_XORSHIFT_8 e                *
; * RND_XORSHIFT_8, con i relativi __USE_ nel modello di         *
; * configurazione, partendo dal codice C originale, indicato    *
; * qui sotto.                                                   *
; *                                                              *
; * Fonte: nota nella bozza del modulo, 2026-11-20.              *
; ****************************************************************
; Codice C originale di XORSHIFT_8, di Edward Rosten:
; https://github.com/edrosten/8bit_rng/blob/master/rng-4261412736.c

; ==============================================================================
; SUBROUTINE: RANDOMIZE_XORSHIFT_16
; ------------------------------------------------------------------------------
; Descrizione:  Inizializza lo stato di XORSHIFT_16 con il valore dei due byte
;               meno significativi dell'orologio di sistema (RDTIM). Entrambe le
;               metà dello stato, x e y, ricevono lo stesso seme di 16 bit.
;
;               Se i due byte dell'orologio valgono zero, lo stato resta nullo e
;               RND_XORSHIFT_16 restituisce sempre zero.
;
; Input:
;   - Nessuno
;
; Output:
;   - Nessuno
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       _XORSHIFT_16_X, _XORSHIFT_16_Y
;
; Dipendenze Esterne:   <c64/kernal.asm>
; ==============================================================================
!if (__USE_RANDOMIZE_XORSHIFT_16 = 1) {
  !zone Randomize_Xorshift_16

    RANDOMIZE_XORSHIFT_16:
      ; Algoritmo XORSHIFT_16 di Bumbershoot, adattato in ACME.
      ; Codice originale:
      ; https://github.com/michaelcmartin/bumbershoot/blob/master/asm/xorshift.s

      jsr RDTIM                 ; .A = byte basso, .X = byte medio.
      sta _XORSHIFT_16_X
      sta _XORSHIFT_16_Y
      stx _XORSHIFT_16_X+1
      stx _XORSHIFT_16_Y+1

    .Exit_RANDOMIZE_XORSHIFT_16:
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: RND_XORSHIFT_16
; ------------------------------------------------------------------------------
; Descrizione:  Calcola il numero pseudocasuale a 16 bit seguente e lo
;               restituisce in .YA. Lo stato interno del generatore va
;               inizializzato prima con RANDOMIZE_XORSHIFT_16: senza, resta
;               nullo e la subroutine restituisce sempre zero.
;
;               L'algoritmo consta di tre passi:
;
;                 1. t = x ^ (x << 5)
;                 2. x = y
;                 3. y = (y ^ (y >> 1)) ^ (t ^ (t >> 3))
;
;               che la subroutine spezza in:
;
;                 1. x = x ^ (x << 5)
;                 2. x = x ^ (x >> 3)
;                 3. Salva y sullo stack
;                 4. y = y ^ (y >> 1)
;                 5. y = y ^ x
;                 6. Recupera y dallo stack e mettilo in x
;
;               L'algoritmo XORSHIFT_16 per 6502 è di Bumbershoot, adattato in
;               formato ACME. Codice originale:
;               https://github.com/michaelcmartin/bumbershoot/blob/master/asm/xorshift.s
;
; Input:
;   - Nessuno
;
; Output:
;   - .A (1 byte, CPU)             : Byte basso del numero pseudocasuale
;   - .Y (1 byte, CPU)             : Byte alto del numero pseudocasuale
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, Zero, Carry),
;                       _XORSHIFT_16_X, _XORSHIFT_16_Y
;
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!if (__USE_RND_XORSHIFT_16 = 1) {
  !zone Rnd_Xorshift_16

    RND_XORSHIFT_16:
      ; Passo 1: x = x ^ (x << 5).
      lda _XORSHIFT_16_X        ; .A = LSB(x).
      ldy _XORSHIFT_16_X+1      ; .Y = MSB(x).
      ldx #5                    ; FOR (Inizializzazione)

    .Loop_Shift_Left:
      asl a                     ; FOR (Corpo)
      rol _XORSHIFT_16_X+1
      dex                       ; NEXT: 5 volte
      bne .Loop_Shift_Left      ; NEXT: 5 volte

      ; All'uscita del ciclo .A = LSB(x << 5), _XORSHIFT_16_X+1 =
      ; MSB(x << 5).
      eor _XORSHIFT_16_X
      sta _XORSHIFT_16_X        ; LSB(x ^ (x << 5)).

      tya
      eor _XORSHIFT_16_X+1
      sta _XORSHIFT_16_X+1      ; MSB(x ^ (x << 5)).

      ; Passo 2: x = x ^ (x >> 3).
      ldy _XORSHIFT_16_X        ; .Y = LSB(x), .A = MSB(x).
      ldx #3                    ; FOR (Inizializzazione)

    .Loop_Shift_Right:
      lsr a                     ; FOR (Corpo)
      ror _XORSHIFT_16_X
      dex                       ; NEXT: 3 volte
      bne .Loop_Shift_Right     ; NEXT: 3 volte

      ; All'uscita del ciclo _XORSHIFT_16_X = LSB(x >> 3), .A =
      ; MSB(x >> 3).
      eor _XORSHIFT_16_X+1
      sta _XORSHIFT_16_X+1      ; MSB(x ^ (x >> 3)).
      tya
      eor _XORSHIFT_16_X
      sta _XORSHIFT_16_X        ; LSB(x ^ (x >> 3)).

      ; Passo 3: salva y sullo stack, perché nel passo 6 diventa x.
      lda _XORSHIFT_16_Y
      pha
      lda _XORSHIFT_16_Y+1
      pha

      ; Passi 4, 5 e 6, non necessariamente in questo ordine: si
      ; eseguono prima sul MSB e poi sul LSB.
      lsr a                     ; .A = MSB(y >> 1).
      ror _XORSHIFT_16_Y        ; LSB(y >> 1).

      eor _XORSHIFT_16_X+1      ; Passo 4: MSB(y) = MSB(y >> 1) ^ MSB(x).
      sta _XORSHIFT_16_Y+1

      pla                       ; Passo 6: MSB(x) = MSB(y).
      sta _XORSHIFT_16_X+1

      eor _XORSHIFT_16_Y+1      ; Passo 5: MSB(y) = MSB(y) ^ MSB(x).
      sta _XORSHIFT_16_Y+1

      pla                       ; .A = .X = LSB(y).
      tax

      eor _XORSHIFT_16_Y        ; Passi 4 e 5: LSB(y) = LSB(y >> 1) ^ LSB(x).
      eor _XORSHIFT_16_X
      sta _XORSHIFT_16_Y

      stx _XORSHIFT_16_X        ; Passo 6: LSB(x) = LSB(y).

      lda _XORSHIFT_16_X        ; Restituisce il numero in .YA.
      ldy _XORSHIFT_16_X+1

    .Exit_RND_XORSHIFT_16:
      rts

  !zone
}

; ------------------------------------------------------------------------------
; Stato del generatore XORSHIFT_16
; ------------------------------------------------------------------------------

!if (__USE_RANDOMIZE_XORSHIFT_16 = 1) or (__USE_RND_XORSHIFT_16 = 1) {

  _XORSHIFT_16_X:
    !word $0000

  _XORSHIFT_16_Y:
    !word $0000
}

; ==============================================================================
; FILE:           fp_error.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Gestione delle condizioni d'errore segnalate dalle routine in
;                 virgola mobile della ROM del BASIC.
; CONTENUTO:      FP_ERROR_HANDLER  Gestore delle tre condizioni d'errore
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   __FP_SAVED_SP
; ==============================================================================

; ==============================================================================
; SUBROUTINE: FP_ERROR_HANDLER
; ------------------------------------------------------------------------------
; Descrizione:  Gestore delle condizioni d'errore che le routine in virgola
;               mobile della ROM possono segnalare. È pensato per essere
;               installato nel vettore IERROR, al posto del gestore del BASIC:
;               la ROM carica in .X il codice d'errore e salta all'indirizzo
;               contenuto in IERROR.
;
;               Le macro che possono provocare un errore salvano .S in
;               __FP_SAVED_SP prima di chiamare la ROM. Il gestore lo
;               ripristina, meno i 2 byte dell'indirizzo di ritorno della
;               chiamata, così l'rts finale ritorna alla macro subito dopo
;               la chiamata, qualunque sia la profondità dello stack nella
;               ROM. Per la macro lo stack resta quindi com'era prima della
;               chiamata. Il gestore è valido solo per gli errori segnalati
;               durante l'esecuzione di queste macro.
;
;               Le condizioni sono tre: ILLEGAL QUANTITY, OVERFLOW e
;               DIVISION BY ZERO. Per ciascuna c'è un punto di gestione
;               distinto; per il momento tutti e tre pongono a 1 il Carry e
;               terminano con rts. Con qualunque altro codice, che non
;               dovrebbe presentarsi, la subroutine pone a 0 il Carry e ritorna.
;
; Input:
;   - .X (1 byte, CPU)           : Codice d'errore (ERR_ILLEGAL_QUANTITY,
;                                  ERR_OVERFLOW o ERR_DIVISION_BY_ZERO)
;   - __FP_SAVED_SP (1 byte, ZP) : Valore di .S prima della chiamata alla ROM
;
; Output:
;   - Flag Carry (1 bit, .P)     : 0 = altro codice; 1 = condizione prevista
;   - .PC (2 byte, CPU)          : Ritorno alla macro che ha chiamato la ROM,
;                                  subito dopo la chiamata
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, Zero, Carry), .S
; Dipendenze Esterne:   <c64/errors.asm>
; ==============================================================================
!if (__USE_FP_ERROR_HANDLER = 1) {
  !zone Fp_Error_Handler

    FP_ERROR_HANDLER:
      txa                       ; Conserva il codice d'errore.

      ; Ripristina .S come prima della chiamata alla ROM, meno i 2
      ; byte dell'indirizzo di ritorno.
      ldx __FP_SAVED_SP
      dex
      dex
      txs

      tax                       ; Rimette il codice d'errore in .X.

      cpx #ERR_ILLEGAL_QUANTITY
      beq .Illegal_Quantity

      cpx #ERR_OVERFLOW
      beq .Overflow

      cpx #ERR_DIVISION_BY_ZERO
      beq .Division_By_Zero

    .Exit_FP_ERROR_HANDLER:
      clc
      rts

    .Illegal_Quantity:
      ; Qui ci potrà andare una routine di gestione dell'errore
      ; ILLEGAL QUANTITY più sofisticata.
      nop

    .Exit_FP_ERROR_HANDLER_Illegal_Quantity:
      sec
      rts

    .Overflow:
      ; Qui ci potrà andare una routine di gestione dell'errore
      ; OVERFLOW più sofisticata.
      nop

    .Exit_FP_ERROR_HANDLER_Overflow:
      sec
      rts

    .Division_By_Zero:
      ; Qui ci potrà andare una routine di gestione dell'errore
      ; DIVISION BY ZERO più sofisticata.
      nop

    .Exit_FP_ERROR_HANDLER_Division_By_Zero:
      sec
      rts

  !zone
}

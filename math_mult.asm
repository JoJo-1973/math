; ==============================================================================
; FILE:           math_mult.asm
; PROGETTO:       Libreria di Sistema (math.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Moltiplicazione intera senza segno e con segno per tutte le
;                 combinazioni di operandi da 8 a 32 bit. Il prodotto ha sempre
;                 la lunghezza esatta m+n bit, senza perdita di precisione.
; CONTENUTO:      m_Mul_Negate      Nega un valore a più byte in pagina zero
;                 m_Mul_Stage       Elabora un byte del moltiplicatore
;                 m_Mul_Core        Nucleo generico senza segno
;                 m_Mul_Core_8x8    Nucleo senza segno 8x8 bit
;                 m_Mul_Core_16x8   Nucleo senza segno 16x8 bit
;                 m_Mul_Core_24x8   Nucleo senza segno 24x8 bit
;                 m_Mul_Core_32x8   Nucleo senza segno 32x8 bit
;                 m_Mul_Core_16x16  Nucleo senza segno 16x16 bit
;                 m_Mul_Core_24x16  Nucleo senza segno 24x16 bit
;                 m_Mul_Core_32x16  Nucleo senza segno 32x16 bit
;                 m_Mul_Core_24x24  Nucleo senza segno 24x24 bit
;                 m_Mul_Core_32x24  Nucleo senza segno 32x24 bit
;                 m_Mul_Core_32x32  Nucleo senza segno 32x32 bit
;                 MUL_8X8           Prodotto 8x8 bit senza segno
;                 SMUL_8X8          Prodotto 8x8 bit con segno
;                 MUL_16X8          Prodotto 16x8 bit senza segno
;                 SMUL_16X8         Prodotto 16x8 bit con segno
;                 MUL_24X8          Prodotto 24x8 bit senza segno
;                 SMUL_24X8         Prodotto 24x8 bit con segno
;                 MUL_32X8          Prodotto 32x8 bit senza segno
;                 SMUL_32X8         Prodotto 32x8 bit con segno
;                 MUL_16X16         Prodotto 16x16 bit senza segno
;                 SMUL_16X16        Prodotto 16x16 bit con segno
;                 MUL_24X16         Prodotto 24x16 bit senza segno
;                 SMUL_24X16        Prodotto 24x16 bit con segno
;                 MUL_32X16         Prodotto 32x16 bit senza segno
;                 SMUL_32X16        Prodotto 32x16 bit con segno
;                 MUL_24X24         Prodotto 24x24 bit senza segno
;                 SMUL_24X24        Prodotto 24x24 bit con segno
;                 MUL_32X24         Prodotto 32x24 bit senza segno
;                 SMUL_32X24        Prodotto 32x24 bit con segno
;                 MUL_32X32         Prodotto 32x32 bit senza segno
;                 SMUL_32X32        Prodotto 32x32 bit con segno
; DIPENDENZE:     <c64/symbols.asm>
; REQUISITI ZP:   MUL_1, MUL_2, MUL_RES
; ==============================================================================

; ******************************************************************************
; NOTE D'USO
; ******************************************************************************
;
; NOTA #01
; --------
; Il primo operando è il più lungo e fa da moltiplicando; il secondo è il
; moltiplicatore. Le routine con operandi in registri usano, dal byte più
; basso al più alto, .A, .X e .Y (cioè la terna .YXA, come nell'ordine di
; memoria). I byte del prodotto oltre il terzo non entrano nei registri: si
; leggono da MUL_RES+3 in poi.
;
;   Routine  1º operando    2º operando    Registri in uscita
;   -------  -------------  -------------  ------------------
;   8x8      .A             .X             .A, .X
;   16x8     .A basso,      .Y             .A, .X, .Y
;            .X alto
;   24x8     MUL_1 (ZP)     .A             .A, .X, .Y
;   32x8     MUL_1 (ZP)     .A             .A, .X, .Y
;   16x16    MUL_1 (ZP)     .A basso,      .A, .X, .Y
;                           .X alto
;   24x16    MUL_1 (ZP)     .A basso,      .A, .X, .Y
;                           .X alto
;   32x16    MUL_1 (ZP)     .A basso,      .A, .X, .Y
;                           .X alto
;   24x24    MUL_1 (ZP)     .A, .X, .Y     .A, .X, .Y
;   32x24    MUL_1 (ZP)     .A, .X, .Y     .A, .X, .Y
;   32x32    MUL_1 (ZP)     MUL_2 (ZP)     .A, .X, .Y
;
; Per le versioni con segno gli operandi sono in complemento a 2 e il prodotto
; ha il segno corretto. L'input non si conserva: il moltiplicatore viene
; consumato e, nelle versioni con segno, gli operandi diventano positivi.
;
;
; NOTA #02
; --------
; Le routine lavorano in pagina zero sui 12 byte da NUMWRK a NUMWRK+11, cioè
; NUMWRK più i primi due byte di FAC, che sono liberi finché non si usa la
; matematica in virgola mobile del BASIC.
;
;   MUL_1    NUMWRK+0 .. NUMWRK+3     Moltiplicando (primo operando)
;   MUL_2    NUMWRK+4 .. NUMWRK+7     Moltiplicatore (secondo operando)
;   MUL_RES  NUMWRK+4 .. NUMWRK+11    Prodotto, da 2 a 8 byte
;
; MUL_2 e MUL_RES coincidono: il moltiplicatore occupa i byte bassi del
; prodotto e viene consumato mentre i byte definitivi prendono il suo posto,
; bit dopo bit. I byte alti di MUL_RES ospitano l'accumulatore. Per questo il
; moltiplicatore non si conserva e MUL_2 e MUL_RES non si usano insieme.
;
; La stessa area è condivisa con ZPL_1 e ZPL_2 (puntatori utente a 24/32 bit)
; e con le routine di divisione: non si possono usare contemporaneamente.
;
;
; NOTA #03
; --------
; Si elabora un byte del moltiplicatore alla volta, con 8 iterazioni di
; shift-and-add: se il bit meno significativo vale 1 si somma il moltiplicando
; all'accumulatore alto, poi tutto scorre di un bit a destra. Il moltiplicando
; non si sposta mai e ogni iterazione fa scorrere solo l'accumulatore e il
; byte in esame del moltiplicatore, non l'intero prodotto. Il byte più alto
; dell'accumulatore resta in .A per tutta l'elaborazione e si scrive in
; memoria una sola volta, alla fine.
;
; I cicli medi con operandi casuali comprendono il caricamento dei registri
; e l'rts, ma non la jsr.
;
;   Routine  Senza segno  Con segno
;   8x8            167       214
;   16x8           270       315
;   24x8           336       390
;   32x8           415       466
;   16x16          496       555
;   24x16          663       700
;   32x16          818       864
;   24x24          982      1007
;   32x24         1222      1234
;   32x32         1582      1624
; ******************************************************************************

!source "../c64/symbols.asm", once

; ------------------------------------------------------------------------------
; Simboli di pagina zero
; ------------------------------------------------------------------------------

MUL_1               = NUMWRK        ; Primo operando (moltiplicando), da 1 a 4 byte
MUL_2               = NUMWRK+4      ; Secondo operando (moltiplicatore), da 1 a 4 byte
MUL_RES             = NUMWRK+4      ; Prodotto, da 2 a 8 byte (sovrapposto a MUL_2)

; ------------------------------------------------------------------------------
; Nuclei aritmetici (macro)
; ------------------------------------------------------------------------------

; ==============================================================================
; MACRO: m_Mul_Negate
; ------------------------------------------------------------------------------
; Descrizione:  Nega sul posto un valore a più byte in pagina zero, cioè lo
;               sostituisce con il suo complemento a 2. Serve per rendere
;               positivi gli operandi e per correggere il segno del prodotto.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .address_ (1 byte, Macro)   : Indirizzo in pagina zero del byte meno
;                                   significativo
;   - .bytes_ (1 byte, Macro)     : Numero di byte del valore (da 1 a 8)
;
; Output:
;   - .address_ (1 .. 8 byte, ZP) : Il valore negato, nelle stesse locazioni
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, oVerflow, Zero, Carry),
;                       .address_+0 .. .address_+.bytes_-1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Mul_Negate .address_, .bytes_ {
    ; Si sottrae da zero un byte per volta, partendo dal meno
    ; significativo, e il prestito si propaga con il Carry.
    sec                             ; Nessun prestito iniziale.
    lda #0
    sbc .address_+0                 ; Zero meno il byte 0.
    sta .address_+0

    !if (.bytes_ > 1) {
      lda #0
      sbc .address_+1               ; Zero meno il byte 1 meno il prestito.
      sta .address_+1
    }

    !if (.bytes_ > 2) {
      lda #0
      sbc .address_+2               ; Zero meno il byte 2 meno il prestito.
      sta .address_+2
    }

    !if (.bytes_ > 3) {
      lda #0
      sbc .address_+3               ; Zero meno il byte 3 meno il prestito.
      sta .address_+3
    }

    !if (.bytes_ > 4) {
      lda #0
      sbc .address_+4               ; Zero meno il byte 4 meno il prestito.
      sta .address_+4
    }

    !if (.bytes_ > 5) {
      lda #0
      sbc .address_+5               ; Zero meno il byte 5 meno il prestito.
      sta .address_+5
    }

    !if (.bytes_ > 6) {
      lda #0
      sbc .address_+6               ; Zero meno il byte 6 meno il prestito.
      sta .address_+6
    }

    !if (.bytes_ > 7) {
      lda #0
      sbc .address_+7               ; Zero meno il byte 7 meno il prestito.
      sta .address_+7
    }
}

; ==============================================================================
; MACRO: m_Mul_Stage
; ------------------------------------------------------------------------------
; Descrizione:  Elabora un byte del moltiplicatore con 8 iterazioni di
;               shift-and-add. Ogni iterazione somma il moltiplicando
;               all'accumulatore alto se il bit in esame vale 1, poi fa scorrere
;               a destra l'accumulatore e il byte in esame. I bit esaminati
;               escono dal byte del moltiplicatore e al loro posto entrano i bit
;               bassi dell'accumulatore, che formano un byte definitivo del
;               prodotto finale.
;
;               Se il moltiplicando ha un solo byte l'accumulatore alto sta
;               tutto in .A. Altrimenti il byte più alto dell'accumulatore sta
;               in .A e gli altri nei byte di MUL_RES che seguono quelli del
;               moltiplicatore; il byte più alto si scrive in memoria solo alla
;               fine di m_Mul_Core.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .stage_ (1 byte, Macro)        : Indice del byte del moltiplicatore (0 =
;                                      il meno significativo)
;   - .mcand_bytes_ (1 byte, Macro)  : Byte del moltiplicando (da 1 a 4)
;   - .mplier_bytes_ (1 byte, Macro) : Byte del moltiplicatore (da 1 a 4)
;   - MUL_1 (1 .. 4 byte, ZP)        : Moltiplicando
;   - MUL_RES (2 .. 8 byte, ZP)      : Moltiplicatore e accumulatore alto
;   - .A (1 byte, CPU)               : Byte più alto dell'accumulatore
;
; Output:
;   - MUL_RES (2 .. 8 byte, ZP)      : Il byte .stage_ diventa un byte
;                                      definitivo del prodotto
;   - .A (1 byte, CPU)               : Byte più alto dell'accumulatore
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y (se .mcand_bytes_ > 1),
;                       .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+6
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Stage .stage_, .mcand_bytes_, .mplier_bytes_ {
    ; Il bit #0 del byte in esame entra nel Carry e decide se si
    ; somma alla prima iterazione.
    lsr MUL_RES+.stage_             ; Estrae il bit #0 del moltiplicatore.
    ldx #8                          ; FOR (Inizializzazione)

  .Loop_Mul_Bit:
    ; Il Carry contiene il bit da esaminare: se vale 0 non si
    ; somma nulla.
    bcc @No_Add                     ; FOR (Corpo)

    !if (.mcand_bytes_ = 1) {
      clc
      adc MUL_1+0                   ; Somma il moltiplicando all'accumulatore.
    } else {
      ; Si somma il moltiplicando a più byte all'accumulatore, dal
      ; byte meno significativo. .A contiene il byte più alto, che
      ; si mette al sicuro in .Y e si riprende per ultimo.
      tay                           ; Mette al sicuro il byte più alto.
      clc
      lda MUL_RES+.mplier_bytes_+0  ; Somma il byte 0 del moltiplicando.
      adc MUL_1+0
      sta MUL_RES+.mplier_bytes_+0

      !if (.mcand_bytes_ > 2) {
        lda MUL_RES+.mplier_bytes_+1
        adc MUL_1+1                 ; Somma il byte 1 con il riporto.
        sta MUL_RES+.mplier_bytes_+1
      }

      !if (.mcand_bytes_ > 3) {
        lda MUL_RES+.mplier_bytes_+2
        adc MUL_1+2                 ; Somma il byte 2 con il riporto.
        sta MUL_RES+.mplier_bytes_+2
      }

      tya                           ; Recupera il byte più alto.
      adc MUL_1+.mcand_bytes_-1     ; Somma il byte più alto con il riporto.
    }

  @No_Add:
    ; L'accumulatore scorre a destra: il Carry della somma entra
    ; dall'alto e il bit più basso esce nel moltiplicatore.
    !if (.mcand_bytes_ = 1) {
      ror a                         ; Lo scorrimento parte dall'accumulatore.
    } else if (.mcand_bytes_ = 2) {
      ror a                         ; Lo scorrimento parte dal byte più alto.
      ror MUL_RES+.mplier_bytes_+0
    } else if (.mcand_bytes_ = 3) {
      ror a                         ; Lo scorrimento parte dal byte più alto.
      ror MUL_RES+.mplier_bytes_+1
      ror MUL_RES+.mplier_bytes_+0
    } else {
      ror a                         ; Lo scorrimento parte dal byte più alto.
      ror MUL_RES+.mplier_bytes_+2
      ror MUL_RES+.mplier_bytes_+1
      ror MUL_RES+.mplier_bytes_+0
    }

    ror MUL_RES+.stage_             ; Il bit uscente è il prossimo da esaminare.

  .Next_Mul_Bit:
    dex                             ; NEXT: conta le iterazioni
    bne .Loop_Mul_Bit               ; NEXT: ripete finché .X è diverso da 0
}

; ==============================================================================
; MACRO: m_Mul_Core
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica due valori senza segno con l'algoritmo shift-and-add
;               elaborando un byte del moltiplicatore alla volta (m_Mul_Stage).
;               Il moltiplicatore sta nei byte bassi di MUL_RES, che a fine
;               operazione contengono il prodotto di .mcand_bytes_ +
;               .mplier_bytes_ byte.
;
;               Conviene usare come moltiplicando l'operando più lungo, perché
;               il costo cresce con il numero di byte del moltiplicatore.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .mcand_bytes_ (1 byte, Macro)  : Byte del moltiplicando (da 1 a 4)
;   - .mplier_bytes_ (1 byte, Macro) : Byte del moltiplicatore (da 1 a 4)
;   - MUL_1 (1 .. 4 byte, ZP)        : Moltiplicando (senza segno)
;   - MUL_2 (1 .. 4 byte, ZP)        : Moltiplicatore (senza segno)
;
; Output:
;   - MUL_RES (2 .. 8 byte, ZP)      : Prodotto della moltiplicazione
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y (se .mcand_bytes_ > 1),
;                       .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+7
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core .mcand_bytes_, .mplier_bytes_ {
    ; L'accumulatore alto parte da zero.
    ; Il suo byte più alto sta in .A, gli altri in MUL_RES.
    lda #0

    !if (.mcand_bytes_ > 1) {
      sta MUL_RES+.mplier_bytes_+0
    }

    !if (.mcand_bytes_ > 2) {
      sta MUL_RES+.mplier_bytes_+1
    }

    !if (.mcand_bytes_ > 3) {
      sta MUL_RES+.mplier_bytes_+2
    }

    +m_Mul_Stage 0, .mcand_bytes_, .mplier_bytes_

    !if (.mplier_bytes_ > 1) {
      +m_Mul_Stage 1, .mcand_bytes_, .mplier_bytes_
    }

    !if (.mplier_bytes_ > 2) {
      +m_Mul_Stage 2, .mcand_bytes_, .mplier_bytes_
    }

    !if (.mplier_bytes_ > 3) {
      +m_Mul_Stage 3, .mcand_bytes_, .mplier_bytes_
    }

    ; Il byte più alto del prodotto è ancora in .A: si scrive ora.
    sta MUL_RES+.mplier_bytes_+.mcand_bytes_-1
}

; ==============================================================================
; MACRO: m_Mul_Core_8x8
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplicazione senza segno tra due valori a 8 bit con il nucleo
;               generico m_Mul_Core.
;
; Input:
;   - MUL_1+0 (1 byte, ZP)                : Moltiplicando
;   - MUL_2+0 (1 byte, ZP)                : Moltiplicatore
;
; Output:
;   - MUL_RES+0 .. MUL_RES+1 (2 byte, ZP) : Prodotto a 16 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+1
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_8x8 {
    +m_Mul_Core 1, 1
}

; ==============================================================================
; MACRO: m_Mul_Core_16x8
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplicazione senza segno tra un valore a 16 bit
;               (moltiplicando) e uno a 8 bit (moltiplicatore) con il nucleo
;               generico m_Mul_Core.
;
; Input:
;   - MUL_1+0 .. MUL_1+1 (2 byte, ZP)     : Moltiplicando
;   - MUL_2+0 (1 byte, ZP)                : Moltiplicatore
;
; Output:
;   - MUL_RES+0 .. MUL_RES+2 (3 byte, ZP) : Prodotto a 24 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+2
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_16x8 {
    +m_Mul_Core 2, 1
}

; ==============================================================================
; MACRO: m_Mul_Core_24x8
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplicazione senza segno tra un valore a 24 bit
;               (moltiplicando) e uno a 8 bit (moltiplicatore) con il nucleo
;               generico m_Mul_Core.
;
; Input:
;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP)     : Moltiplicando
;   - MUL_2+0 (1 byte, ZP)                : Moltiplicatore
;
; Output:
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP) : Prodotto a 32 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+3
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_24x8 {
    +m_Mul_Core 3, 1
}

; ==============================================================================
; MACRO: m_Mul_Core_32x8
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplicazione senza segno tra un valore a 32 bit
;               (moltiplicando) e uno a 8 bit (moltiplicatore) con il nucleo
;               generico m_Mul_Core.
;
; Input:
;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP)     : Moltiplicando
;   - MUL_2+0 (1 byte, ZP)                : Moltiplicatore
;
; Output:
;   - MUL_RES+0 .. MUL_RES+4 (5 byte, ZP) : Prodotto a 40 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+4
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_32x8 {
    +m_Mul_Core 4, 1
}

; ==============================================================================
; MACRO: m_Mul_Core_16x16
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplicazione senza segno tra due valori a 16 bit con il
;               nucleo generico m_Mul_Core.
;
; Input:
;   - MUL_1+0 .. MUL_1+1 (2 byte, ZP)     : Moltiplicando
;   - MUL_2+0 .. MUL_2+1 (2 byte, ZP)     : Moltiplicatore
;
; Output:
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP) : Prodotto a 32 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+3
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_16x16 {
    +m_Mul_Core 2, 2
}

; ==============================================================================
; MACRO: m_Mul_Core_24x16
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplicazione senza segno tra un valore a 24 bit
;               (moltiplicando) e uno a 16 bit (moltiplicatore) con il nucleo
;               generico m_Mul_Core.
;
; Input:
;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP)     : Moltiplicando
;   - MUL_2+0 .. MUL_2+1 (2 byte, ZP)     : Moltiplicatore
;
; Output:
;   - MUL_RES+0 .. MUL_RES+4 (5 byte, ZP) : Prodotto a 40 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+4
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_24x16 {
    +m_Mul_Core 3, 2
}

; ==============================================================================
; MACRO: m_Mul_Core_32x16
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplicazione senza segno tra un valore a 32 bit
;               (moltiplicando) e uno a 16 bit (moltiplicatore) con il nucleo
;               generico m_Mul_Core.
;
; Input:
;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP)     : Moltiplicando
;   - MUL_2+0 .. MUL_2+1 (2 byte, ZP)     : Moltiplicatore
;
; Output:
;   - MUL_RES+0 .. MUL_RES+5 (6 byte, ZP) : Prodotto a 48 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+5
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_32x16 {
    +m_Mul_Core 4, 2
}

; ==============================================================================
; MACRO: m_Mul_Core_24x24
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplicazione senza segno tra due valori a 24 bit con il
;               nucleo generico m_Mul_Core.
;
; Input:
;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP)     : Moltiplicando
;   - MUL_2+0 .. MUL_2+2 (3 byte, ZP)     : Moltiplicatore
;
; Output:
;   - MUL_RES+0 .. MUL_RES+5 (6 byte, ZP) : Prodotto a 48 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+5
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_24x24 {
    +m_Mul_Core 3, 3
}

; ==============================================================================
; MACRO: m_Mul_Core_32x24
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplicazione senza segno tra un valore a 32 bit
;               (moltiplicando) e uno a 24 bit (moltiplicatore) con il nucleo
;               generico m_Mul_Core.
;
; Input:
;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP)     : Moltiplicando
;   - MUL_2+0 .. MUL_2+2 (3 byte, ZP)     : Moltiplicatore
;
; Output:
;   - MUL_RES+0 .. MUL_RES+6 (7 byte, ZP) : Prodotto a 56 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+6
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_32x24 {
    +m_Mul_Core 4, 3
}

; ==============================================================================
; MACRO: m_Mul_Core_32x32
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplicazione senza segno tra due valori a 32 bit con il
;               nucleo generico m_Mul_Core.
;
; Input:
;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP)     : Moltiplicando
;   - MUL_2+0 .. MUL_2+3 (4 byte, ZP)     : Moltiplicatore
;
; Output:
;   - MUL_RES+0 .. MUL_RES+7 (8 byte, ZP) : Prodotto a 64 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+7
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Mul_Core_32x32 {
    +m_Mul_Core 4, 4
}

; ------------------------------------------------------------------------------
; Subroutine di moltiplicazione
; ------------------------------------------------------------------------------

; ==============================================================================
; SUBROUTINE: MUL_8X8
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica due interi a 8 bit, senza segno.
;
; Input:
;   - .A (1 byte, CPU)                    : Primo operando (moltiplicando)
;   - .X (1 byte, CPU)                    : Secondo operando (moltiplicatore)
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - MUL_RES+0 .. MUL_RES+1 (2 byte, ZP) : Prodotto a 16 bit
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry), MUL_1+0,
;                       MUL_RES+0 .. MUL_RES+1
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_MUL_8X8 = 1) {
  !zone Mul_8x8

    MUL_8X8:
      sta MUL_1+0                   ; Salva il moltiplicando.
      stx MUL_2+0                   ; Salva il moltiplicatore.

      +m_Mul_Core_8x8

    .Exit_MUL_8X8:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SMUL_8X8
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica due interi a 8 bit, con segno.
;
;               Rende positivi gli operandi, esegue il nucleo senza segno e, se
;               i segni erano diversi, nega il prodotto.
;
; Input:
;   - .A (1 byte, CPU)                    : Primo operando con segno
;                                           (moltiplicando)
;   - .X (1 byte, CPU)                    : Secondo operando con segno
;                                           (moltiplicatore)
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - MUL_RES+0 .. MUL_RES+1 (2 byte, ZP) : Prodotto a 16 bit con segno
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry), MUL_1+0,
;                       MUL_RES+0 .. MUL_RES+1
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_SMUL_8X8 = 1) {
  !zone Smul_8x8

    SMUL_8X8:
      sta MUL_1+0                   ; Salva il moltiplicando.
      stx MUL_2+0                   ; Salva il moltiplicatore.

      ; Il segno del prodotto è l'XOR dei segni degli operandi
      ; (bit #7 dei byte più alti). Lo si calcola ora e lo si
      ; conserva nello stack.
      lda MUL_1+0                   ; Il bit #7 dei byte più alti è il segno.
      eor MUL_2+0                   ; Segni diversi: il prodotto è negativo.
      pha                           ; Salva il segno del prodotto.

      ; Un moltiplicando negativo si nega sul posto: il nucleo
      ; lavora solo su valori senza segno.
      lda MUL_1+0
      bpl .No_Negate_Multiplicand

      +m_Mul_Negate MUL_1, 1

    .No_Negate_Multiplicand:
      ; Lo stesso vale per il moltiplicatore.
      lda MUL_2+0
      bpl .No_Negate_Multiplier

      +m_Mul_Negate MUL_2, 1

    .No_Negate_Multiplier:
      +m_Mul_Core_8x8

      ; Se i segni degli operandi erano diversi il prodotto si nega.
      pla                           ; Recupera il segno del prodotto.
      bpl .Exit_SMUL_8X8

      +m_Mul_Negate MUL_RES, 2

    .Exit_SMUL_8X8:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: MUL_16X8
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica un intero a 16 bit per uno a 8 bit, senza segno.
;
; Input:
;   - .A (1 byte, CPU)                    : Primo operando, byte basso
;   - .X (1 byte, CPU)                    : Primo operando, byte alto
;   - .Y (1 byte, CPU)                    : Secondo operando (moltiplicatore)
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+2 (3 byte, ZP) : Prodotto a 24 bit
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_1+0 .. MUL_1+1, MUL_RES+0 .. MUL_RES+2
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_MUL_16X8 = 1) {
  !zone Mul_16x8

    MUL_16X8:
      sta MUL_1+0                   ; Salva il byte basso del moltiplicando.
      stx MUL_1+1                   ; Salva il byte alto del moltiplicando.
      sty MUL_2+0                   ; Salva il moltiplicatore.

      +m_Mul_Core_16x8

    .Exit_MUL_16X8:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SMUL_16X8
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica un intero a 16 bit per uno a 8 bit, con segno.
;
;               Rende positivi gli operandi, esegue il nucleo senza segno e, se
;               i segni erano diversi, nega il prodotto.
;
; Input:
;   - .A (1 byte, CPU)                    : Primo operando con segno, byte basso
;   - .X (1 byte, CPU)                    : Primo operando con segno, byte alto
;   - .Y (1 byte, CPU)                    : Secondo operando con segno
;                                           (moltiplicatore)
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+2 (3 byte, ZP) : Prodotto a 24 bit con segno
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_1+0 .. MUL_1+1, MUL_RES+0 .. MUL_RES+2
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_SMUL_16X8 = 1) {
  !zone Smul_16x8

    SMUL_16X8:
      sta MUL_1+0                   ; Salva il byte basso del moltiplicando.
      stx MUL_1+1                   ; Salva il byte alto del moltiplicando.
      sty MUL_2+0                   ; Salva il moltiplicatore.

      ; Il segno del prodotto è l'XOR dei segni degli operandi
      ; (bit #7 dei byte più alti). Lo si calcola ora e lo si
      ; conserva nello stack.
      lda MUL_1+1                   ; Il bit #7 dei byte più alti è il segno.
      eor MUL_2+0                   ; Segni diversi: il prodotto è negativo.
      pha                           ; Salva il segno del prodotto.

      ; Un moltiplicando negativo si nega sul posto: il nucleo
      ; lavora solo su valori senza segno.
      lda MUL_1+1
      bpl .No_Negate_Multiplicand

      +m_Mul_Negate MUL_1, 2

    .No_Negate_Multiplicand:
      ; Lo stesso vale per il moltiplicatore.
      lda MUL_2+0
      bpl .No_Negate_Multiplier

      +m_Mul_Negate MUL_2, 1

    .No_Negate_Multiplier:
      +m_Mul_Core_16x8

      ; Se i segni degli operandi erano diversi il prodotto si nega.
      pla                           ; Recupera il segno del prodotto.
      bpl .Exit_SMUL_16X8

      +m_Mul_Negate MUL_RES, 3

    .Exit_SMUL_16X8:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: MUL_24X8
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica un intero a 24 bit per uno a 8 bit, senza segno.
;
; Input:
;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP)     : Primo operando (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando (moltiplicatore)
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP) : Prodotto a 32 bit
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+3
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_MUL_24X8 = 1) {
  !zone Mul_24x8

    MUL_24X8:
      sta MUL_2+0                   ; Salva il moltiplicatore.

      +m_Mul_Core_24x8

    .Exit_MUL_24X8:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SMUL_24X8
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica un intero a 24 bit per uno a 8 bit, con segno.
;
;               Rende positivi gli operandi, esegue il nucleo senza segno e, se
;               i segni erano diversi, nega il prodotto.
;
; Input:
;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP)     : Primo operando con segno
;                                           (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando con segno
;                                           (moltiplicatore)
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP) : Prodotto a 32 bit con segno
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_1+0 .. MUL_1+2, MUL_RES+0 .. MUL_RES+3
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_SMUL_24X8 = 1) {
  !zone Smul_24x8

    SMUL_24X8:
      sta MUL_2+0                   ; Salva il moltiplicatore.

      ; Il segno del prodotto è l'XOR dei segni degli operandi
      ; (bit #7 dei byte più alti). Lo si calcola ora e lo si
      ; conserva nello stack.
      lda MUL_1+2                   ; Il bit #7 dei byte più alti è il segno.
      eor MUL_2+0                   ; Segni diversi: il prodotto è negativo.
      pha                           ; Salva il segno del prodotto.

      ; Un moltiplicando negativo si nega sul posto: il nucleo
      ; lavora solo su valori senza segno.
      lda MUL_1+2
      bpl .No_Negate_Multiplicand

      +m_Mul_Negate MUL_1, 3

    .No_Negate_Multiplicand:
      ; Lo stesso vale per il moltiplicatore.
      lda MUL_2+0
      bpl .No_Negate_Multiplier

      +m_Mul_Negate MUL_2, 1

    .No_Negate_Multiplier:
      +m_Mul_Core_24x8

      ; Se i segni degli operandi erano diversi il prodotto si nega.
      pla                           ; Recupera il segno del prodotto.
      bpl .Exit_SMUL_24X8

      +m_Mul_Negate MUL_RES, 4

    .Exit_SMUL_24X8:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: MUL_32X8
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica un intero a 32 bit per uno a 8 bit, senza segno.
;
; Input:
;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP)     : Primo operando (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando (moltiplicatore)
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+4 (5 byte, ZP) : Prodotto a 40 bit
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+4
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_MUL_32X8 = 1) {
  !zone Mul_32x8

    MUL_32X8:
      sta MUL_2+0                   ; Salva il moltiplicatore.

      +m_Mul_Core_32x8

    .Exit_MUL_32X8:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SMUL_32X8
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica un intero a 32 bit per uno a 8 bit, con segno.
;
;               Rende positivi gli operandi, esegue il nucleo senza segno e, se
;               i segni erano diversi, nega il prodotto.
;
; Input:
;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP)     : Primo operando con segno
;                                           (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando con segno
;                                           (moltiplicatore)
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+4 (5 byte, ZP) : Prodotto a 40 bit con segno
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_1+0 .. MUL_1+3, MUL_RES+0 .. MUL_RES+4
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_SMUL_32X8 = 1) {
  !zone Smul_32x8

    SMUL_32X8:
      sta MUL_2+0                   ; Salva il moltiplicatore.

      ; Il segno del prodotto è l'XOR dei segni degli operandi
      ; (bit #7 dei byte più alti). Lo si calcola ora e lo si
      ; conserva nello stack.
      lda MUL_1+3                   ; Il bit #7 dei byte più alti è il segno.
      eor MUL_2+0                   ; Segni diversi: il prodotto è negativo.
      pha                           ; Salva il segno del prodotto.

      ; Un moltiplicando negativo si nega sul posto: il nucleo
      ; lavora solo su valori senza segno.
      lda MUL_1+3
      bpl .No_Negate_Multiplicand

      +m_Mul_Negate MUL_1, 4

    .No_Negate_Multiplicand:
      ; Lo stesso vale per il moltiplicatore.
      lda MUL_2+0
      bpl .No_Negate_Multiplier

      +m_Mul_Negate MUL_2, 1

    .No_Negate_Multiplier:
      +m_Mul_Core_32x8

      ; Se i segni degli operandi erano diversi il prodotto si nega.
      pla                           ; Recupera il segno del prodotto.
      bpl .Exit_SMUL_32X8

      +m_Mul_Negate MUL_RES, 5

    .Exit_SMUL_32X8:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: MUL_16X16
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica due interi a 16 bit, senza segno.
;
; Input:
;   - MUL_1+0 .. MUL_1+1 (2 byte, ZP)     : Primo operando (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando, byte 0
;   - .X (1 byte, CPU)                    : Secondo operando, byte 1
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP) : Prodotto a 32 bit
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+3
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_MUL_16X16 = 1) {
  !zone Mul_16x16

    MUL_16X16:
      sta MUL_2+0                   ; Salva il byte 0 del moltiplicatore.
      stx MUL_2+1                   ; Salva il byte 1 del moltiplicatore.

      +m_Mul_Core_16x16

    .Exit_MUL_16X16:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SMUL_16X16
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica due interi a 16 bit, con segno.
;
;               Rende positivi gli operandi, esegue il nucleo senza segno e, se
;               i segni erano diversi, nega il prodotto.
;
; Input:
;   - MUL_1+0 .. MUL_1+1 (2 byte, ZP)     : Primo operando con segno
;                                           (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando con segno, byte 0
;   - .X (1 byte, CPU)                    : Secondo operando con segno, byte 1
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+3 (4 byte, ZP) : Prodotto a 32 bit con segno
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_1+0 .. MUL_1+1, MUL_RES+0 .. MUL_RES+3
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_SMUL_16X16 = 1) {
  !zone Smul_16x16

    SMUL_16X16:
      sta MUL_2+0                   ; Salva il byte 0 del moltiplicatore.
      stx MUL_2+1                   ; Salva il byte 1 del moltiplicatore.

      ; Il segno del prodotto è l'XOR dei segni degli operandi
      ; (bit #7 dei byte più alti). Lo si calcola ora e lo si
      ; conserva nello stack.
      lda MUL_1+1                   ; Il bit #7 dei byte più alti è il segno.
      eor MUL_2+1                   ; Segni diversi: il prodotto è negativo.
      pha                           ; Salva il segno del prodotto.

      ; Un moltiplicando negativo si nega sul posto: il nucleo
      ; lavora solo su valori senza segno.
      lda MUL_1+1
      bpl .No_Negate_Multiplicand

      +m_Mul_Negate MUL_1, 2

    .No_Negate_Multiplicand:
      ; Lo stesso vale per il moltiplicatore.
      lda MUL_2+1
      bpl .No_Negate_Multiplier

      +m_Mul_Negate MUL_2, 2

    .No_Negate_Multiplier:
      +m_Mul_Core_16x16

      ; Se i segni degli operandi erano diversi il prodotto si nega.
      pla                           ; Recupera il segno del prodotto.
      bpl .Exit_SMUL_16X16

      +m_Mul_Negate MUL_RES, 4

    .Exit_SMUL_16X16:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: MUL_24X16
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica un intero a 24 bit per uno a 16 bit, senza segno.
;
; Input:
;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP)     : Primo operando (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando, byte 0
;   - .X (1 byte, CPU)                    : Secondo operando, byte 1
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+4 (5 byte, ZP) : Prodotto a 40 bit
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+4
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_MUL_24X16 = 1) {
  !zone Mul_24x16

    MUL_24X16:
      sta MUL_2+0                   ; Salva il byte 0 del moltiplicatore.
      stx MUL_2+1                   ; Salva il byte 1 del moltiplicatore.

      +m_Mul_Core_24x16

    .Exit_MUL_24X16:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SMUL_24X16
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica un intero a 24 bit per uno a 16 bit, con segno.
;
;               Rende positivi gli operandi, esegue il nucleo senza segno e, se
;               i segni erano diversi, nega il prodotto.
;
; Input:
;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP)     : Primo operando con segno
;                                           (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando con segno, byte 0
;   - .X (1 byte, CPU)                    : Secondo operando con segno, byte 1
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+4 (5 byte, ZP) : Prodotto a 40 bit con segno
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_1+0 .. MUL_1+2, MUL_RES+0 .. MUL_RES+4
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_SMUL_24X16 = 1) {
  !zone Smul_24x16

    SMUL_24X16:
      sta MUL_2+0                   ; Salva il byte 0 del moltiplicatore.
      stx MUL_2+1                   ; Salva il byte 1 del moltiplicatore.

      ; Il segno del prodotto è l'XOR dei segni degli operandi
      ; (bit #7 dei byte più alti). Lo si calcola ora e lo si
      ; conserva nello stack.
      lda MUL_1+2                   ; Il bit #7 dei byte più alti è il segno.
      eor MUL_2+1                   ; Segni diversi: il prodotto è negativo.
      pha                           ; Salva il segno del prodotto.

      ; Un moltiplicando negativo si nega sul posto: il nucleo
      ; lavora solo su valori senza segno.
      lda MUL_1+2
      bpl .No_Negate_Multiplicand

      +m_Mul_Negate MUL_1, 3

    .No_Negate_Multiplicand:
      ; Lo stesso vale per il moltiplicatore.
      lda MUL_2+1
      bpl .No_Negate_Multiplier

      +m_Mul_Negate MUL_2, 2

    .No_Negate_Multiplier:
      +m_Mul_Core_24x16

      ; Se i segni degli operandi erano diversi il prodotto si nega.
      pla                           ; Recupera il segno del prodotto.
      bpl .Exit_SMUL_24X16

      +m_Mul_Negate MUL_RES, 5

    .Exit_SMUL_24X16:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: MUL_32X16
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica un intero a 32 bit per uno a 16 bit, senza segno.
;
; Input:
;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP)     : Primo operando (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando, byte 0
;   - .X (1 byte, CPU)                    : Secondo operando, byte 1
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+5 (6 byte, ZP) : Prodotto a 48 bit
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+5
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_MUL_32X16 = 1) {
  !zone Mul_32x16

    MUL_32X16:
      sta MUL_2+0                   ; Salva il byte 0 del moltiplicatore.
      stx MUL_2+1                   ; Salva il byte 1 del moltiplicatore.

      +m_Mul_Core_32x16

    .Exit_MUL_32X16:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SMUL_32X16
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica un intero a 32 bit per uno a 16 bit, con segno.
;
;               Rende positivi gli operandi, esegue il nucleo senza segno e, se
;               i segni erano diversi, nega il prodotto.
;
; Input:
;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP)     : Primo operando con segno
;                                           (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando con segno, byte 0
;   - .X (1 byte, CPU)                    : Secondo operando con segno, byte 1
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+5 (6 byte, ZP) : Prodotto a 48 bit con segno
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_1+0 .. MUL_1+3, MUL_RES+0 .. MUL_RES+5
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_SMUL_32X16 = 1) {
  !zone Smul_32x16

    SMUL_32X16:
      sta MUL_2+0                   ; Salva il byte 0 del moltiplicatore.
      stx MUL_2+1                   ; Salva il byte 1 del moltiplicatore.

      ; Il segno del prodotto è l'XOR dei segni degli operandi
      ; (bit #7 dei byte più alti). Lo si calcola ora e lo si
      ; conserva nello stack.
      lda MUL_1+3                   ; Il bit #7 dei byte più alti è il segno.
      eor MUL_2+1                   ; Segni diversi: il prodotto è negativo.
      pha                           ; Salva il segno del prodotto.

      ; Un moltiplicando negativo si nega sul posto: il nucleo
      ; lavora solo su valori senza segno.
      lda MUL_1+3
      bpl .No_Negate_Multiplicand

      +m_Mul_Negate MUL_1, 4

    .No_Negate_Multiplicand:
      ; Lo stesso vale per il moltiplicatore.
      lda MUL_2+1
      bpl .No_Negate_Multiplier

      +m_Mul_Negate MUL_2, 2

    .No_Negate_Multiplier:
      +m_Mul_Core_32x16

      ; Se i segni degli operandi erano diversi il prodotto si nega.
      pla                           ; Recupera il segno del prodotto.
      bpl .Exit_SMUL_32X16

      +m_Mul_Negate MUL_RES, 6

    .Exit_SMUL_32X16:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: MUL_24X24
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica due interi a 24 bit, senza segno.
;
; Input:
;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP)     : Primo operando (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando, byte 0
;   - .X (1 byte, CPU)                    : Secondo operando, byte 1
;   - .Y (1 byte, CPU)                    : Secondo operando, byte 2
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+5 (6 byte, ZP) : Prodotto a 48 bit
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+5
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_MUL_24X24 = 1) {
  !zone Mul_24x24

    MUL_24X24:
      sta MUL_2+0                   ; Salva il byte 0 del moltiplicatore.
      stx MUL_2+1                   ; Salva il byte 1 del moltiplicatore.
      sty MUL_2+2                   ; Salva il byte 2 del moltiplicatore.

      +m_Mul_Core_24x24

    .Exit_MUL_24X24:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SMUL_24X24
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica due interi a 24 bit, con segno.
;
;               Rende positivi gli operandi, esegue il nucleo senza segno e, se
;               i segni erano diversi, nega il prodotto.
;
; Input:
;   - MUL_1+0 .. MUL_1+2 (3 byte, ZP)     : Primo operando con segno
;                                           (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando con segno, byte 0
;   - .X (1 byte, CPU)                    : Secondo operando con segno, byte 1
;   - .Y (1 byte, CPU)                    : Secondo operando con segno, byte 2
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+5 (6 byte, ZP) : Prodotto a 48 bit con segno
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_1+0 .. MUL_1+2, MUL_RES+0 .. MUL_RES+5
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_SMUL_24X24 = 1) {
  !zone Smul_24x24

    SMUL_24X24:
      sta MUL_2+0                   ; Salva il byte 0 del moltiplicatore.
      stx MUL_2+1                   ; Salva il byte 1 del moltiplicatore.
      sty MUL_2+2                   ; Salva il byte 2 del moltiplicatore.

      ; Il segno del prodotto è l'XOR dei segni degli operandi
      ; (bit #7 dei byte più alti). Lo si calcola ora e lo si
      ; conserva nello stack.
      lda MUL_1+2                   ; Il bit #7 dei byte più alti è il segno.
      eor MUL_2+2                   ; Segni diversi: il prodotto è negativo.
      pha                           ; Salva il segno del prodotto.

      ; Un moltiplicando negativo si nega sul posto: il nucleo
      ; lavora solo su valori senza segno.
      lda MUL_1+2
      bpl .No_Negate_Multiplicand

      +m_Mul_Negate MUL_1, 3

    .No_Negate_Multiplicand:
      ; Lo stesso vale per il moltiplicatore.
      lda MUL_2+2
      bpl .No_Negate_Multiplier

      +m_Mul_Negate MUL_2, 3

    .No_Negate_Multiplier:
      +m_Mul_Core_24x24

      ; Se i segni degli operandi erano diversi il prodotto si nega.
      pla                           ; Recupera il segno del prodotto.
      bpl .Exit_SMUL_24X24

      +m_Mul_Negate MUL_RES, 6

    .Exit_SMUL_24X24:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: MUL_32X24
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica un intero a 32 bit per uno a 24 bit, senza segno.
;
; Input:
;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP)     : Primo operando (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando, byte 0
;   - .X (1 byte, CPU)                    : Secondo operando, byte 1
;   - .Y (1 byte, CPU)                    : Secondo operando, byte 2
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+6 (7 byte, ZP) : Prodotto a 56 bit
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+6
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_MUL_32X24 = 1) {
  !zone Mul_32x24

    MUL_32X24:
      sta MUL_2+0                   ; Salva il byte 0 del moltiplicatore.
      stx MUL_2+1                   ; Salva il byte 1 del moltiplicatore.
      sty MUL_2+2                   ; Salva il byte 2 del moltiplicatore.

      +m_Mul_Core_32x24

    .Exit_MUL_32X24:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SMUL_32X24
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica un intero a 32 bit per uno a 24 bit, con segno.
;
;               Rende positivi gli operandi, esegue il nucleo senza segno e, se
;               i segni erano diversi, nega il prodotto.
;
; Input:
;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP)     : Primo operando con segno
;                                           (moltiplicando)
;   - .A (1 byte, CPU)                    : Secondo operando con segno, byte 0
;   - .X (1 byte, CPU)                    : Secondo operando con segno, byte 1
;   - .Y (1 byte, CPU)                    : Secondo operando con segno, byte 2
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+6 (7 byte, ZP) : Prodotto a 56 bit con segno
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_1+0 .. MUL_1+3, MUL_RES+0 .. MUL_RES+6
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_SMUL_32X24 = 1) {
  !zone Smul_32x24

    SMUL_32X24:
      sta MUL_2+0                   ; Salva il byte 0 del moltiplicatore.
      stx MUL_2+1                   ; Salva il byte 1 del moltiplicatore.
      sty MUL_2+2                   ; Salva il byte 2 del moltiplicatore.

      ; Il segno del prodotto è l'XOR dei segni degli operandi
      ; (bit #7 dei byte più alti). Lo si calcola ora e lo si
      ; conserva nello stack.
      lda MUL_1+3                   ; Il bit #7 dei byte più alti è il segno.
      eor MUL_2+2                   ; Segni diversi: il prodotto è negativo.
      pha                           ; Salva il segno del prodotto.

      ; Un moltiplicando negativo si nega sul posto: il nucleo
      ; lavora solo su valori senza segno.
      lda MUL_1+3
      bpl .No_Negate_Multiplicand

      +m_Mul_Negate MUL_1, 4

    .No_Negate_Multiplicand:
      ; Lo stesso vale per il moltiplicatore.
      lda MUL_2+2
      bpl .No_Negate_Multiplier

      +m_Mul_Negate MUL_2, 3

    .No_Negate_Multiplier:
      +m_Mul_Core_32x24

      ; Se i segni degli operandi erano diversi il prodotto si nega.
      pla                           ; Recupera il segno del prodotto.
      bpl .Exit_SMUL_32X24

      +m_Mul_Negate MUL_RES, 7

    .Exit_SMUL_32X24:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: MUL_32X32
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica due interi a 32 bit, senza segno.
;
; Input:
;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP)     : Primo operando (moltiplicando)
;   - MUL_2+0 .. MUL_2+3 (4 byte, ZP)     : Secondo operando (moltiplicatore)
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+7 (8 byte, ZP) : Prodotto a 64 bit
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_RES+0 .. MUL_RES+7
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_MUL_32X32 = 1) {
  !zone Mul_32x32

    MUL_32X32:
      +m_Mul_Core_32x32

    .Exit_MUL_32X32:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SMUL_32X32
; ------------------------------------------------------------------------------
; Descrizione:  Moltiplica due interi a 32 bit, con segno.
;
;               Rende positivi gli operandi, esegue il nucleo senza segno e, se
;               i segni erano diversi, nega il prodotto.
;
; Input:
;   - MUL_1+0 .. MUL_1+3 (4 byte, ZP)     : Primo operando con segno
;                                           (moltiplicando)
;   - MUL_2+0 .. MUL_2+3 (4 byte, ZP)     : Secondo operando con segno
;                                           (moltiplicatore)
;
; Output:
;   - .A (1 byte, CPU)                    : Byte 0 del prodotto
;   - .X (1 byte, CPU)                    : Byte 1 del prodotto
;   - .Y (1 byte, CPU)                    : Byte 2 del prodotto
;   - MUL_RES+0 .. MUL_RES+7 (8 byte, ZP) : Prodotto a 64 bit con segno
;   - Flag Carry (1 bit, .P)              : sempre 0
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       MUL_1+0 .. MUL_1+3, MUL_RES+0 .. MUL_RES+7
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!if (__USE_SMUL_32X32 = 1) {
  !zone Smul_32x32

    SMUL_32X32:
      ; Il segno del prodotto è l'XOR dei segni degli operandi
      ; (bit #7 dei byte più alti). Lo si calcola ora e lo si
      ; conserva nello stack.
      lda MUL_1+3                   ; Il bit #7 dei byte più alti è il segno.
      eor MUL_2+3                   ; Segni diversi: il prodotto è negativo.
      pha                           ; Salva il segno del prodotto.

      ; Un moltiplicando negativo si nega sul posto: il nucleo
      ; lavora solo su valori senza segno.
      lda MUL_1+3
      bpl .No_Negate_Multiplicand

      +m_Mul_Negate MUL_1, 4

    .No_Negate_Multiplicand:
      ; Lo stesso vale per il moltiplicatore.
      lda MUL_2+3
      bpl .No_Negate_Multiplier

      +m_Mul_Negate MUL_2, 4

    .No_Negate_Multiplier:
      +m_Mul_Core_32x32

      ; Se i segni degli operandi erano diversi il prodotto si nega.
      pla                           ; Recupera il segno del prodotto.
      bpl .Exit_SMUL_32X32

      +m_Mul_Negate MUL_RES, 8

    .Exit_SMUL_32X32:
      lda MUL_RES+0                 ; Byte 0 del prodotto in .A.
      ldx MUL_RES+1                 ; Byte 1 del prodotto in .X.
      ldy MUL_RES+2                 ; Byte 2 del prodotto in .Y.
      clc                           ; Nessun errore possibile.
      rts

  !zone
}

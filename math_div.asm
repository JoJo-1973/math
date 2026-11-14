; ==============================================================================
; FILE:           math_div.asm
; PROGETTO:       Libreria di Sistema (math.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Divisione intera senza segno e con segno per tutte le
;                 combinazioni di operandi da 8 a 32 bit. Il quoziente ha la
;                 lunghezza del dividendo e il resto quella del divisore, senza
;                 perdita di precisione.
; CONTENUTO:      m_Div_Negate      Nega un valore a più byte in pagina zero
;                 m_Div_Roll        Fa scorrere a sinistra un valore a più byte
;                 m_Div_Core_Byte   Nucleo senza segno con divisore a 8 bit
;                 m_Div_Core_Multi  Nucleo senza segno con divisore a più byte
;                 m_Div_Core_8x8    Nucleo senza segno 8x8 bit
;                 m_Div_Core_16x8   Nucleo senza segno 16x8 bit
;                 m_Div_Core_24x8   Nucleo senza segno 24x8 bit
;                 m_Div_Core_32x8   Nucleo senza segno 32x8 bit
;                 m_Div_Core_16x16  Nucleo senza segno 16x16 bit
;                 m_Div_Core_24x16  Nucleo senza segno 24x16 bit
;                 m_Div_Core_32x16  Nucleo senza segno 32x16 bit
;                 m_Div_Core_24x24  Nucleo senza segno 24x24 bit
;                 m_Div_Core_32x24  Nucleo senza segno 32x24 bit
;                 m_Div_Core_32x32  Nucleo senza segno 32x32 bit
;                 DIV_8X8           Divisione 8x8 bit senza segno
;                 SDIV_8X8          Divisione 8x8 bit con segno
;                 DIV_16X8          Divisione 16x8 bit senza segno
;                 SDIV_16X8         Divisione 16x8 bit con segno
;                 DIV_24X8          Divisione 24x8 bit senza segno
;                 SDIV_24X8         Divisione 24x8 bit con segno
;                 DIV_32X8          Divisione 32x8 bit senza segno
;                 SDIV_32X8         Divisione 32x8 bit con segno
;                 DIV_16X16         Divisione 16x16 bit senza segno
;                 SDIV_16X16        Divisione 16x16 bit con segno
;                 DIV_24X16         Divisione 24x16 bit senza segno
;                 SDIV_24X16        Divisione 24x16 bit con segno
;                 DIV_32X16         Divisione 32x16 bit senza segno
;                 SDIV_32X16        Divisione 32x16 bit con segno
;                 DIV_24X24         Divisione 24x24 bit senza segno
;                 SDIV_24X24        Divisione 24x24 bit con segno
;                 DIV_32X24         Divisione 32x24 bit senza segno
;                 SDIV_32X24        Divisione 32x24 bit con segno
;                 DIV_32X32         Divisione 32x32 bit senza segno
;                 SDIV_32X32        Divisione 32x32 bit con segno
; DIPENDENZE:     <c64/errors.asm>
;                 <c64/symbols.asm>
; REQUISITI ZP:   DIV_1, DIV_2, DIV_QUOT, DIV_REM
; ==============================================================================

; ******************************************************************************
; NOTE D'USO
; ******************************************************************************
;
; NOTA #01
; --------
; Il dividendo ha m byte e il divisore n byte, con m maggiore o uguale a n.
; Il quoziente ha la lunghezza del dividendo e il resto quella del divisore,
; quindi nessuna informazione va persa. I valori a più byte si scambiano con i
; registri dal byte più basso al più alto: byte 0 in .A, byte 1 in .X e byte 2
; in .Y (cioè la terna .YXA, come nell'ordine di memoria). I byte del
; quoziente oltre il terzo si leggono da DIV_QUOT+3.
;
; Il resto si legge sempre da DIV_REM. Quando il resto ha un solo byte ed è
; rimasto un registro libero, la routine lo restituisce anche in quel registro.
;
;   Routine  Dividendo   Divisore    Quoziente        Resto
;   -------  ----------  ----------  ---------------  ------------
;   8x8      .A          .X          .A               .X e DIV_REM
;   16x8     DIV_1 (ZP)  .A          .A, .X           .Y e DIV_REM
;   24x8     DIV_1 (ZP)  .A          .A, .X, .Y       DIV_REM
;   32x8     DIV_1 (ZP)  .A          .A, .X, .Y (*)   DIV_REM
;   16x16    DIV_1 (ZP)  .A, .X      .A, .X           DIV_REM
;   24x16    DIV_1 (ZP)  .A, .X      .A, .X, .Y       DIV_REM
;   32x16    DIV_1 (ZP)  .A, .X      .A, .X, .Y (*)   DIV_REM
;   24x24    DIV_1 (ZP)  .A, .X, .Y  .A, .X, .Y       DIV_REM
;   32x24    DIV_1 (ZP)  .A, .X, .Y  .A, .X, .Y (*)   DIV_REM
;   32x32    DIV_1 (ZP)  DIV_2 (ZP)  .A, .X, .Y (*)   DIV_REM
;
;   (*) Il byte 3 del quoziente si legge da DIV_QUOT+3.
;
; Per le versioni con segno gli operandi sono in complemento a 2. Il resto ha il
; segno del dividendo e il quoziente si tronca verso zero, come nella divisione
; intera dei linguaggi di alto livello.
;
;
; NOTA #02
; --------
; Le routine lavorano in pagina zero sui 12 byte da NUMWRK a NUMWRK+11, cioè
; NUMWRK più i primi due byte di FAC, che sono liberi finché non si usa la
; matematica in virgola mobile del BASIC.
;
;   DIV_1     NUMWRK+0 .. NUMWRK+3     Dividendo (primo operando)
;   DIV_QUOT  NUMWRK+0 .. NUMWRK+3     Quoziente, coincide con DIV_1
;   DIV_2     NUMWRK+4 .. NUMWRK+7     Divisore (secondo operando)
;   DIV_REM   NUMWRK+8 .. NUMWRK+11    Resto
;
; DIV_QUOT coincide con DIV_1: il dividendo viene consumato bit dopo bit e al
; suo posto entrano i bit del quoziente. Per questo il dividendo non si
; conserva. Nelle versioni con segno anche il divisore diventa positivo.
;
; La stessa area è condivisa con ZPL_1 e ZPL_2 (puntatori utente a 24/32 bit)
; e con le routine di moltiplicazione: non si possono usare contemporaneamente.
;
;
; NOTA #03
; --------
; Si elabora un bit del dividendo alla volta, dal più alto. Il resto parziale
; scorre a sinistra e riceve il bit; se è maggiore o uguale al divisore si
; sottrae e il bit di quoziente vale 1, altrimenti vale 0 e il resto non si
; tocca: non esiste nessun ripristino. Il bit di quoziente è il Carry lasciato
; dal confronto ed entra dal basso nel dividendo alla rotazione successiva.
; Dividendo e quoziente condividono gli stessi byte e il quoziente non richiede
; nessun passo a parte.
;
; Con un divisore di un byte il resto sta in .A per tutto il tempo. Con più
; byte sta in DIV_REM e il confronto parte dal byte più alto: si ferma appena
; l'esito è noto, cioè di solito dopo un solo byte.
;
; I cicli medi con operandi casuali comprendono il caricamento dei registri
; e l'rts, ma non la jsr. Il divisore è casuale e non nullo, in parte più
; corto dell'operando.
;
;   Routine  Senza segno  Con segno
;   8x8            200       267
;   16x8           451       528
;   24x8           783       869
;   32x8          1195      1289
;   16x16          686       768
;   24x16         1188      1279
;   32x16         1775      1876
;   24x24         1335      1431
;   32x24         1991      2095
;   32x32         2152      2244
;
;
; NOTA #04
; --------
; Divisione per zero: la routine esce con il Carry a 1 e .A uguale a
; ERR_DIVISION_BY_ZERO, senza toccare il quoziente e il resto.
;
; Un dividendo nullo non ha un percorso a parte: il ciclo lo elabora come ogni
; altro valore e dà quoziente e resto uguali a zero.
;
; Overflow nelle versioni con segno: l'unico caso è il dividendo più negativo
; diviso per -1, per esempio -128 / -1 a 8 bit. Il quoziente corretto (+128)
; non entra in 8 bit con il segno: la routine restituisce il quoziente
; troncato ai bit bassi ($80, che letto con il segno vale -128), pone il flag
; di oVerflow a 1 e lascia il Carry a 0. Il bit perso è il bit di segno del
; quoziente vero, che qui vale sempre 0: chi vuole il risultato esatto lo
; ricostruisce con un byte in più a zero. In tutti gli altri casi il flag di
; oVerflow vale 0.
; ******************************************************************************

; PROVA TEMPORANEA: once sospeso (LIB-01).
; !source "../c64/errors.asm", once
; !source "../c64/symbols.asm", once

; ------------------------------------------------------------------------------
; Simboli di pagina zero
; ------------------------------------------------------------------------------

DIV_1               = NUMWRK        ; Primo operando (dividendo), da 1 a 4 byte
DIV_QUOT            = DIV_1         ; Quoziente, da 1 a 4 byte (sovrapposto a DIV_1)
DIV_2               = NUMWRK+4      ; Secondo operando (divisore), da 1 a 4 byte
DIV_REM             = NUMWRK+8      ; Resto, da 1 a 4 byte

; ------------------------------------------------------------------------------
; Nuclei aritmetici (macro)
; ------------------------------------------------------------------------------

; ==============================================================================
; MACRO: m_Div_Negate
; ------------------------------------------------------------------------------
; Descrizione:  Nega sul posto un valore a più byte in pagina zero, cioè lo
;               sostituisce con il suo complemento a 2. Serve per rendere
;               positivi dividendo e divisore e per correggere il segno di
;               quoziente e resto.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .address_ (1 byte, Macro)   : Indirizzo in pagina zero del byte meno
;                                   significativo
;   - .bytes_ (1 byte, Macro)     : Numero di byte del valore (da 1 a 4)
;
; Output:
;   - .address_ (1 .. 4 byte, ZP) : Il valore negato, nelle stesse locazioni
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .P (Negative, oVerflow, Zero, Carry),
;                       .address_+0 .. .address_+.bytes_-1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Div_Negate .address_, .bytes_ {
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
}

; ==============================================================================
; MACRO: m_Div_Roll
; ------------------------------------------------------------------------------
; Descrizione:  Fa scorrere a sinistra di un bit un valore a più byte in pagina
;               zero. Il Carry entra nel bit meno significativo e il bit più
;               alto del valore esce nel Carry.
;
;               Gli operandi devono essere definiti prima dell'invocazione,
;               perché la macro li confronta per scegliere il ramo.
;
; Input:
;   - .address_ (1 byte, Macro)   : Indirizzo in pagina zero del byte meno
;                                   significativo
;   - .bytes_ (1 byte, Macro)     : Numero di byte del valore (da 1 a 4)
;   - Flag Carry (1 bit, .P)      : 0 = entra uno 0; 1 = entra un 1
;
; Output:
;   - .address_ (1 .. 4 byte, ZP) : Il valore scorso di un bit
;   - Flag Carry (1 bit, .P)      : 0 = esce uno 0; 1 = esce un 1
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .P (Negative, oVerflow, Zero, Carry),
;                       .address_+0 .. .address_+.bytes_-1
; Dipendenze Esterne:   Nessuna
; ==============================================================================
!macro m_Div_Roll .address_, .bytes_ {
    !if (.bytes_ = 1) {
      rol .address_+0
    } else if (.bytes_ = 2) {
      rol .address_+0
      rol .address_+1
    } else if (.bytes_ = 3) {
      rol .address_+0
      rol .address_+1
      rol .address_+2
    } else {
      rol .address_+0
      rol .address_+1
      rol .address_+2
      rol .address_+3
    }
}

; ==============================================================================
; MACRO: m_Div_Core_Byte
; ------------------------------------------------------------------------------
; Descrizione:  Divisione senza segno con un divisore a 8 bit e un dividendo da
;               1 a 4 byte. Per ogni bit del dividendo, dal più alto, il resto
;               parziale scorre a sinistra e riceve il bit; se è maggiore o
;               uguale al divisore si sottrae e il bit di quoziente vale 1. Quel
;               bit entra nel dividendo alla rotazione seguente, quindi il
;               quoziente prende il posto del dividendo.
;
;               Il resto parziale sta in .A per tutta l'elaborazione e si scrive
;               in memoria una sola volta, alla fine. Il divisore deve essere
;               diverso da zero: la macro non lo controlla.
;
; Input:
;   - .dvd_bytes_ (1 byte, Macro) : Byte del dividendo (da 1 a 4)
;   - DIV_1 (1 .. 4 byte, ZP)     : Dividendo (senza segno)
;   - DIV_2+0 (1 byte, ZP)        : Divisore (senza segno, diverso da zero)
;
; Output:
;   - DIV_QUOT (1 .. 4 byte, ZP)  : Quoziente
;   - DIV_REM+0 (1 byte, ZP)      : Resto
;   - .A (1 byte, CPU)            : Resto (uguale a DIV_REM+0)
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+.dvd_bytes_-1, DIV_REM+0
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_Byte .dvd_bytes_ {
    lda #0                          ; Il resto parziale parte da zero e vive in .A.
    ldx #.dvd_bytes_*8              ; FOR (Inizializzazione)

  .Loop_Div_Bit:
    ; Il dividendo scorre a sinistra: il suo bit più alto esce nel
    ; Carry e al suo posto entra l'ultimo bit di quoziente.
    +m_Div_Roll DIV_1, .dvd_bytes_  ; FOR (Corpo)
    rol a                           ; Il bit uscito entra nel resto parziale.
    bcs @Remainder_Overflow         ; Se il resto esce da 8 bit supera il divisore.

    cmp DIV_2+0                     ; Il Carry vale 1 se resto >= divisore.
    bcc .Next_Div_Bit               ; Resto minore: bit #0 di quoziente e niente sottrazione.

    sbc DIV_2+0                     ; Sottrae: il Carry resta 1, bit #1 di quoziente.

  .Next_Div_Bit:
    dex                             ; NEXT: conta i bit del dividendo
    bne .Loop_Div_Bit               ; NEXT: ripete finché .X è diverso da 0

    jmp @Insert_Last_Bit            ; Scavalca il ramo dell'overflow del resto.

  @Remainder_Overflow:
    ; Il resto parziale è uscito da 8 bit: ora vale 2^8 più quello
    ; che resta, quindi supera di certo il divisore. Si sottrae
    ; senza confrontare e il bit di quoziente vale 1.
    sbc DIV_2+0                     ; Il Carry vale già 1: resto meno divisore.
    sec                             ; Bit 1 di quoziente.
    dex                             ; NEXT: conta i bit del dividendo
    bne .Loop_Div_Bit               ; NEXT: ripete finché .X è diverso da 0

  @Insert_Last_Bit:
    ; L'ultimo bit di quoziente è nel Carry: una rotazione finale
    ; lo porta nel dividendo, che diventa il quoziente.
    sta DIV_REM+0                   ; Il resto è l'ultimo valore di .A.
    +m_Div_Roll DIV_1, .dvd_bytes_
}

; ==============================================================================
; MACRO: m_Div_Core_Multi
; ------------------------------------------------------------------------------
; Descrizione:  Divisione senza segno con un divisore da 2 a 4 byte e un
;               dividendo da 1 a 4 byte. Per ogni bit del dividendo, dal più
;               alto, il resto parziale scorre a sinistra e riceve il bit; se è
;               maggiore o uguale al divisore si sottrae e il bit di quoziente
;               vale 1. Quel bit entra nel dividendo alla rotazione seguente,
;               quindi il quoziente prende il posto del dividendo.
;
;               Il confronto parte dal byte più alto e si ferma appena l'esito è
;               noto. Se il resto parziale esce dai suoi byte si sottrae senza
;               confrontare. Il divisore deve essere diverso da zero: la macro
;               non lo controlla.
;
; Input:
;   - .dvd_bytes_ (1 byte, Macro) : Byte del dividendo (da 1 a 4)
;   - .dvs_bytes_ (1 byte, Macro) : Byte del divisore (da 2 a 4)
;   - DIV_1 (1 .. 4 byte, ZP)     : Dividendo (senza segno)
;   - DIV_2 (2 .. 4 byte, ZP)     : Divisore (senza segno, diverso da zero)
;
; Output:
;   - DIV_QUOT (1 .. 4 byte, ZP)  : Quoziente
;   - DIV_REM (2 .. 4 byte, ZP)   : Resto
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+.dvd_bytes_-1,
;                       DIV_REM+0 .. DIV_REM+.dvs_bytes_-1
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_Multi .dvd_bytes_, .dvs_bytes_ {
    ; Il resto parziale parte da zero.
    lda #0
    sta DIV_REM+0
    sta DIV_REM+1

    !if (.dvs_bytes_ > 2) {
      sta DIV_REM+2
    }

    !if (.dvs_bytes_ > 3) {
      sta DIV_REM+3
    }

    ldx #.dvd_bytes_*8              ; FOR (Inizializzazione)

  .Loop_Div_Multi_Bit:
    ; Il dividendo scorre a sinistra: il suo bit più alto esce nel
    ; Carry e al suo posto entra l'ultimo bit di quoziente. Il bit
    ; uscito entra poi nel resto parziale.
    +m_Div_Roll DIV_1, .dvd_bytes_  ; FOR (Corpo)
    +m_Div_Roll DIV_REM, .dvs_bytes_
    bcs @Remainder_Overflow         ; Se il resto esce dai suoi byte supera il divisore.

    ; Il resto si confronta con il divisore dal byte più alto:
    ; appena due byte differiscono l'esito è noto. Il Carry finale
    ; è il bit di quoziente.
    lda DIV_REM+.dvs_bytes_-1
    cmp DIV_2+.dvs_bytes_-1
    bcc .Next_Div_Multi_Bit         ; Resto minore: bit #0 di quoziente.

    bne @Subtract                   ; Resto maggiore: si sottrae.

    !if (.dvs_bytes_ > 2) {
      lda DIV_REM+.dvs_bytes_-2
      cmp DIV_2+.dvs_bytes_-2
      bcc .Next_Div_Multi_Bit

      bne @Subtract
    } else if (.dvs_bytes_ = 2) {
      lda DIV_REM+.dvs_bytes_-2
      cmp DIV_2+.dvs_bytes_-2
      bcc .Next_Div_Multi_Bit
    }

    !if (.dvs_bytes_ > 3) {
      lda DIV_REM+.dvs_bytes_-3
      cmp DIV_2+.dvs_bytes_-3
      bcc .Next_Div_Multi_Bit

      bne @Subtract
    } else if (.dvs_bytes_ = 3) {
      lda DIV_REM+.dvs_bytes_-3
      cmp DIV_2+.dvs_bytes_-3
      bcc .Next_Div_Multi_Bit
    }

    !if (.dvs_bytes_ = 4) {
      lda DIV_REM+.dvs_bytes_-4
      cmp DIV_2+.dvs_bytes_-4
      bcc .Next_Div_Multi_Bit
    }

  @Subtract:
    lda DIV_REM+0                   ; Resto meno divisore, il Carry vale già 1.
    sbc DIV_2+0
    sta DIV_REM+0

    !if (.dvs_bytes_ > 1) {
      lda DIV_REM+1
      sbc DIV_2+1
      sta DIV_REM+1
    }

    !if (.dvs_bytes_ > 2) {
      lda DIV_REM+2
      sbc DIV_2+2
      sta DIV_REM+2
    }

    !if (.dvs_bytes_ > 3) {
      lda DIV_REM+3
      sbc DIV_2+3
      sta DIV_REM+3
    }

  .Next_Div_Multi_Bit:
    dex                             ; NEXT: conta i bit del dividendo
    bne .Loop_Div_Multi_Bit         ; NEXT: ripete finché .X è diverso da 0

    jmp @Insert_Last_Bit            ; Scavalca il ramo dell'overflow del resto.

  @Remainder_Overflow:
    ; Il resto parziale è uscito dai suoi byte: ora vale 2 elevato
    ; al numero dei suoi bit più quello che resta, quindi supera
    ; di certo il divisore. Si sottrae senza confrontare e il bit
    ; di quoziente vale 1.

    sec                             ; Nessun prestito iniziale.
    lda DIV_REM+0
    sbc DIV_2+0
    sta DIV_REM+0

    !if (.dvs_bytes_ > 1) {
      lda DIV_REM+1
      sbc DIV_2+1
      sta DIV_REM+1
    }

    !if (.dvs_bytes_ > 2) {
      lda DIV_REM+2
      sbc DIV_2+2
      sta DIV_REM+2
    }

    !if (.dvs_bytes_ > 3) {
      lda DIV_REM+3
      sbc DIV_2+3
      sta DIV_REM+3
    }

    sec                             ; Bit 1 di quoziente.
    dex                             ; NEXT: conta i bit del dividendo
    bne .Loop_Div_Multi_Bit         ; NEXT: ripete finché .X è diverso da 0

  @Insert_Last_Bit:
    ; L'ultimo bit di quoziente è nel Carry: una rotazione finale
    ; lo porta nel dividendo, che diventa il quoziente.
    +m_Div_Roll DIV_1, .dvd_bytes_
}

; ==============================================================================
; MACRO: m_Div_Core_8x8
; ------------------------------------------------------------------------------
; Descrizione:  Divisione senza segno tra due valori a 8 bit con il nucleo
;               generico m_Div_Core_Multi.
;
;               Il divisore deve essere diverso da zero: la macro non lo
;               controlla.
;
; Input:
;   - DIV_1+0 (1 byte, ZP)    : Dividendo (senza segno)
;   - DIV_2+0 (1 byte, ZP)    : Divisore (senza segno, diverso da zero)
;
; Output:
;   - .A (1 byte, CPU)        : Resto (uguale a DIV_REM+0)
;   - DIV_QUOT+0 (1 byte, ZP) : Quoziente a 8 bit
;   - DIV_REM+0 (1 byte, ZP)  : Resto a 8 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0, DIV_REM+0
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_8x8 {
    +m_Div_Core_Byte 1
}

; ==============================================================================
; MACRO: m_Div_Core_16x8
; ------------------------------------------------------------------------------
; Descrizione:  Divisione senza segno tra un valore a 16 bit (dividendo) e uno a
;               8 bit (divisore) con il nucleo generico m_Div_Core_Byte.
;
;               Il divisore deve essere diverso da zero: la macro non lo
;               controlla.
;
; Input:
;   - DIV_1+0 .. DIV_1+1 (2 byte, ZP)       : Dividendo (senza segno)
;   - DIV_2+0 (1 byte, ZP)                  : Divisore (senza segno, diverso da
;                                             zero)
;
; Output:
;   - .A (1 byte, CPU)                      : Resto (uguale a DIV_REM+0)
;   - DIV_QUOT+0 .. DIV_QUOT+1 (2 byte, ZP) : Quoziente a 16 bit
;   - DIV_REM+0 (1 byte, ZP)                : Resto a 8 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+1, DIV_REM+0
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_16x8 {
    +m_Div_Core_Byte 2
}

; ==============================================================================
; MACRO: m_Div_Core_24x8
; ------------------------------------------------------------------------------
; Descrizione:  Divisione senza segno tra un valore a 24 bit (dividendo) e uno a
;               8 bit (divisore) con il nucleo generico m_Div_Core_Byte.
;
;               Il divisore deve essere diverso da zero: la macro non lo
;               controlla.
;
; Input:
;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP)       : Dividendo (senza segno)
;   - DIV_2+0 (1 byte, ZP)                  : Divisore (senza segno, diverso da
;                                             zero)
;
; Output:
;   - .A (1 byte, CPU)                      : Resto (uguale a DIV_REM+0)
;   - DIV_QUOT+0 .. DIV_QUOT+2 (3 byte, ZP) : Quoziente a 24 bit
;   - DIV_REM+0 (1 byte, ZP)                : Resto a 8 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+2, DIV_REM+0
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_24x8 {
    +m_Div_Core_Byte 3
}

; ==============================================================================
; MACRO: m_Div_Core_32x8
; ------------------------------------------------------------------------------
; Descrizione:  Divisione senza segno tra un valore a 32 bit (dividendo) e uno a
;               8 bit (divisore) con il nucleo generico m_Div_Core_Byte.
;
;               Il divisore deve essere diverso da zero: la macro non lo
;               controlla.
;
; Input:
;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP)       : Dividendo (senza segno)
;   - DIV_2+0 (1 byte, ZP)                  : Divisore (senza segno, diverso da
;                                             zero)
;
; Output:
;   - .A (1 byte, CPU)                      : Resto (uguale a DIV_REM+0)
;   - DIV_QUOT+0 .. DIV_QUOT+3 (4 byte, ZP) : Quoziente a 32 bit
;   - DIV_REM+0 (1 byte, ZP)                : Resto a 8 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+3, DIV_REM+0
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_32x8 {
    +m_Div_Core_Byte 4
}

; ==============================================================================
; MACRO: m_Div_Core_16x16
; ------------------------------------------------------------------------------
; Descrizione:  Divisione senza segno tra due valori a 16 bit con il nucleo
;               generico m_Div_Core_Multi.
;
;               Il divisore deve essere diverso da zero: la macro non lo
;               controlla.
;
; Input:
;   - DIV_1+0 .. DIV_1+1 (2 byte, ZP)       : Dividendo (senza segno)
;   - DIV_2+0 .. DIV_2+1 (2 byte, ZP)       : Divisore (senza segno, diverso da
;                                             zero)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+1 (2 byte, ZP) : Quoziente a 16 bit
;   - DIV_REM+0 .. DIV_REM+1 (2 byte, ZP)   : Resto a 16 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+1, DIV_REM+0 .. DIV_REM+1
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_16x16 {
    +m_Div_Core_Multi 2, 2
}

; ==============================================================================
; MACRO: m_Div_Core_24x16
; ------------------------------------------------------------------------------
; Descrizione:  Divisione senza segno tra un valore a 24 bit (dividendo) e uno a
;               16 bit (divisore) con il nucleo generico m_Div_Core_Multi.
;
;               Il divisore deve essere diverso da zero: la macro non lo
;               controlla.
;
; Input:
;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP)       : Dividendo (senza segno)
;   - DIV_2+0 .. DIV_2+1 (2 byte, ZP)       : Divisore (senza segno, diverso da
;                                             zero)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+2 (3 byte, ZP) : Quoziente a 24 bit
;   - DIV_REM+0 .. DIV_REM+1 (2 byte, ZP)   : Resto a 16 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+2, DIV_REM+0 .. DIV_REM+1
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_24x16 {
    +m_Div_Core_Multi 3, 2
}

; ==============================================================================
; MACRO: m_Div_Core_32x16
; ------------------------------------------------------------------------------
; Descrizione:  Divisione senza segno tra un valore a 32 bit (dividendo) e uno a
;               16 bit (divisore) con il nucleo generico m_Div_Core_Multi.
;
;               Il divisore deve essere diverso da zero: la macro non lo
;               controlla.
;
; Input:
;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP)       : Dividendo (senza segno)
;   - DIV_2+0 .. DIV_2+1 (2 byte, ZP)       : Divisore (senza segno, diverso da
;                                             zero)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+3 (4 byte, ZP) : Quoziente a 32 bit
;   - DIV_REM+0 .. DIV_REM+1 (2 byte, ZP)   : Resto a 16 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+3, DIV_REM+0 .. DIV_REM+1
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_32x16 {
    +m_Div_Core_Multi 4, 2
}

; ==============================================================================
; MACRO: m_Div_Core_24x24
; ------------------------------------------------------------------------------
; Descrizione:  Divisione senza segno tra due valori a 24 bit con il nucleo
;               generico m_Div_Core_Multi.
;
;               Il divisore deve essere diverso da zero: la macro non lo
;               controlla.
;
; Input:
;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP)       : Dividendo (senza segno)
;   - DIV_2+0 .. DIV_2+2 (3 byte, ZP)       : Divisore (senza segno, diverso da
;                                             zero)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+2 (3 byte, ZP) : Quoziente a 24 bit
;   - DIV_REM+0 .. DIV_REM+2 (3 byte, ZP)   : Resto a 24 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+2, DIV_REM+0 .. DIV_REM+2
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_24x24 {
    +m_Div_Core_Multi 3, 3
}

; ==============================================================================
; MACRO: m_Div_Core_32x24
; ------------------------------------------------------------------------------
; Descrizione:  Divisione senza segno tra un valore a 32 bit (dividendo) e uno a
;               24 bit (divisore) con il nucleo generico m_Div_Core_Multi.
;
;               Il divisore deve essere diverso da zero: la macro non lo
;               controlla.
;
; Input:
;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP)       : Dividendo (senza segno)
;   - DIV_2+0 .. DIV_2+2 (3 byte, ZP)       : Divisore (senza segno, diverso da
;                                             zero)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+3 (4 byte, ZP) : Quoziente a 32 bit
;   - DIV_REM+0 .. DIV_REM+2 (3 byte, ZP)   : Resto a 24 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+3, DIV_REM+0 .. DIV_REM+2
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_32x24 {
    +m_Div_Core_Multi 4, 3
}

; ==============================================================================
; MACRO: m_Div_Core_32x32
; ------------------------------------------------------------------------------
; Descrizione:  Divisione senza segno tra due valori a 32 bit con il nucleo
;               generico m_Div_Core_Multi.
;
;               Il divisore deve essere diverso da zero: la macro non lo
;               controlla.
;
; Input:
;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP)       : Dividendo (senza segno)
;   - DIV_2+0 .. DIV_2+3 (4 byte, ZP)       : Divisore (senza segno, diverso da
;                                             zero)
;
; Output:
;   - DIV_QUOT+0 .. DIV_QUOT+3 (4 byte, ZP) : Quoziente a 32 bit
;   - DIV_REM+0 .. DIV_REM+3 (4 byte, ZP)   : Resto a 32 bit
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+3, DIV_REM+0 .. DIV_REM+3
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Div_Core_32x32 {
    +m_Div_Core_Multi 4, 4
}

; ------------------------------------------------------------------------------
; Subroutine di divisione
; ------------------------------------------------------------------------------

; ==============================================================================
; SUBROUTINE: DIV_8X8
; ------------------------------------------------------------------------------
; Descrizione:  Divide due interi a 8 bit, senza segno. Il quoziente ha 8 bit e
;               il resto 8 bit.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - .A (1 byte, CPU)        : Dividendo
;   - .X (1 byte, CPU)        : Divisore
;
; Output:
;   - .A (1 byte, CPU)        : Byte 0 del quoziente, o ERR_DIVISION_BY_ZERO se
;                               C = 1
;   - .X (1 byte, CPU)        : Resto (uguale a DIV_REM+0)
;   - DIV_QUOT+0 (1 byte, ZP) : Quoziente a 8 bit
;   - DIV_REM+0 (1 byte, ZP)  : Resto a 8 bit
;   - Flag Carry (1 bit, .P)  : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0, DIV_2+0, DIV_REM+0
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_DIV_8X8 = 1) {
  !zone Div_8x8

    DIV_8X8:
      sta DIV_1+0                   ; Salva il dividendo.
      stx DIV_2+0                   ; Salva il divisore.

      cpx #0                        ; Il divisore è nullo?
      bne .No_Div_Zero

    .Exit_DIV_8X8_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      +m_Div_Core_8x8

    .Exit_DIV_8X8:
      tax                           ; Il resto, ancora in .A, va in .X.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      clc                           ; Nessun errore.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SDIV_8X8
; ------------------------------------------------------------------------------
; Descrizione:  Divide due interi a 8 bit, con segno. Il quoziente ha 8 bit e il
;               resto 8 bit.
;
;               Rende positivi dividendo e divisore, esegue il nucleo senza
;               segno e corregge i segni: il quoziente è negativo se i segni
;               degli operandi sono diversi e il resto ha il segno del
;               dividendo.
;
;               L'unico overflow possibile è -2^7 diviso -1: il quoziente esce
;               troncato ai 8 bit bassi e il flag di oVerflow vale 1.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - .A (1 byte, CPU)          : Dividendo con segno
;   - .X (1 byte, CPU)          : Divisore con segno
;
; Output:
;   - .A (1 byte, CPU)          : Byte 0 del quoziente, o ERR_DIVISION_BY_ZERO
;                                 se C = 1
;   - .X (1 byte, CPU)          : Resto (uguale a DIV_REM+0)
;   - DIV_QUOT+0 (1 byte, ZP)   : Quoziente a 8 bit con segno
;   - DIV_REM+0 (1 byte, ZP)    : Resto a 8 bit con segno
;   - Flag oVerflow (1 bit, .P) : 0 = nessuno; 1 = overflow
;   - Flag Carry (1 bit, .P)    : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0, DIV_2+0, DIV_REM+0
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_SDIV_8X8 = 1) {
  !zone Sdiv_8x8

    SDIV_8X8:
      sta DIV_1+0                   ; Salva il dividendo.
      stx DIV_2+0                   ; Salva il divisore.

      cpx #0                        ; Il divisore è nullo?
      bne .No_Div_Zero

    .Exit_SDIV_8X8_Div_Zero:
      clv                           ; Nessun overflow.
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      ; Il segno del quoziente è l'XOR dei segni degli operandi,
      ; quello del resto è il segno del dividendo (bit #7 dei byte
      ; più alti). Si conservano nello stack.
      lda DIV_1+0                   ; Il bit #7 è il segno del dividendo.
      eor DIV_2+0                   ; Segni diversi: il quoziente è negativo.
      pha                           ; Salva il segno del quoziente.
      lda DIV_1+0
      pha                           ; Salva il segno del resto.

      ; Un dividendo negativo si nega sul posto: il nucleo lavora
      ; solo su valori senza segno.
      bpl .No_Negate_Dividend       ; Il segno del dividendo è ancora in .A.

      +m_Div_Negate DIV_1, 1

    .No_Negate_Dividend:
      ; Lo stesso vale per il divisore.
      lda DIV_2+0
      bpl .No_Negate_Divisor

      +m_Div_Negate DIV_2, 1

    .No_Negate_Divisor:
      +m_Div_Core_8x8

      ; Il resto prende il segno del dividendo.
      pla                           ; Recupera il segno del resto.
      bpl .No_Negate_Remainder

      +m_Div_Negate DIV_REM, 1

    .No_Negate_Remainder:
      ; Il quoziente si nega se i segni degli operandi differiscono.
      pla                           ; Recupera il segno del quoziente.
      bpl .Check_Quotient_Overflow

      +m_Div_Negate DIV_QUOT, 1

    .Exit_SDIV_8X8:
      clv                           ; Nessun overflow.
      clc                           ; Nessun errore.
      ldx DIV_REM+0                 ; Resto in .X.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      rts

    ; Un quoziente positivo con il bit #7 acceso non entra con il
    ; segno: è l'overflow di -2^7 diviso -1.
    .Check_Quotient_Overflow:
      lda DIV_QUOT+0
      bpl .Exit_SDIV_8X8

    ; Il quoziente resta troncato. Una somma che va in overflow
    ; pone V a 1 e, con il Carry a 0, lascia anche C a 0.
    .Exit_SDIV_8X8_Overflow:
      clc
      lda #$40
      adc #$40                      ; $40 + $40 = $80: overflow, V = 1, C = 0.
      ldx DIV_REM+0                 ; Resto in .X.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: DIV_16X8
; ------------------------------------------------------------------------------
; Descrizione:  Divide un intero a 16 bit per uno a 8 bit, senza segno. Il
;               quoziente ha 16 bit e il resto 8 bit.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+1 (2 byte, ZP)       : Dividendo
;   - .A (1 byte, CPU)                      : Divisore
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Resto (uguale a DIV_REM+0)
;   - DIV_QUOT+0 .. DIV_QUOT+1 (2 byte, ZP) : Quoziente a 16 bit
;   - DIV_REM+0 (1 byte, ZP)                : Resto a 8 bit
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+1, DIV_2+0, DIV_REM+0
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_DIV_16X8 = 1) {
  !zone Div_16x8

    DIV_16X8:
      sta DIV_2+0                   ; Salva il divisore.

      cmp #0                        ; Il divisore è nullo?
      bne .No_Div_Zero

    .Exit_DIV_16X8_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      +m_Div_Core_16x8

    .Exit_DIV_16X8:
      tay                           ; Il resto, ancora in .A, va in .Y.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      clc                           ; Nessun errore.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SDIV_16X8
; ------------------------------------------------------------------------------
; Descrizione:  Divide un intero a 16 bit per uno a 8 bit, con segno. Il
;               quoziente ha 16 bit e il resto 8 bit.
;
;               Rende positivi dividendo e divisore, esegue il nucleo senza
;               segno e corregge i segni: il quoziente è negativo se i segni
;               degli operandi sono diversi e il resto ha il segno del
;               dividendo.
;
;               L'unico overflow possibile è -2^15 diviso -1: il quoziente esce
;               troncato ai 16 bit bassi e il flag di oVerflow vale 1.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+1 (2 byte, ZP)       : Dividendo con segno
;   - .A (1 byte, CPU)                      : Divisore con segno
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Resto (uguale a DIV_REM+0)
;   - DIV_QUOT+0 .. DIV_QUOT+1 (2 byte, ZP) : Quoziente a 16 bit con segno
;   - DIV_REM+0 (1 byte, ZP)                : Resto a 8 bit con segno
;   - Flag oVerflow (1 bit, .P)             : 0 = nessuno; 1 = overflow
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+1, DIV_2+0, DIV_REM+0
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_SDIV_16X8 = 1) {
  !zone Sdiv_16x8

    SDIV_16X8:
      sta DIV_2+0                   ; Salva il divisore.

      cmp #0                        ; Il divisore è nullo?
      bne .No_Div_Zero

    .Exit_SDIV_16X8_Div_Zero:
      clv                           ; Nessun overflow.
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      ; Il segno del quoziente è l'XOR dei segni degli operandi,
      ; quello del resto è il segno del dividendo (bit #7 dei byte
      ; più alti). Si conservano nello stack.
      lda DIV_1+1                   ; Il bit #7 è il segno del dividendo.
      eor DIV_2+0                   ; Segni diversi: il quoziente è negativo.
      pha                           ; Salva il segno del quoziente.
      lda DIV_1+1
      pha                           ; Salva il segno del resto.

      ; Un dividendo negativo si nega sul posto: il nucleo lavora
      ; solo su valori senza segno.
      bpl .No_Negate_Dividend       ; Il segno del dividendo è ancora in .A.

      +m_Div_Negate DIV_1, 2

    .No_Negate_Dividend:
      ; Lo stesso vale per il divisore.
      lda DIV_2+0
      bpl .No_Negate_Divisor

      +m_Div_Negate DIV_2, 1

    .No_Negate_Divisor:
      +m_Div_Core_16x8

      ; Il resto prende il segno del dividendo.
      pla                           ; Recupera il segno del resto.
      bpl .No_Negate_Remainder

      +m_Div_Negate DIV_REM, 1

    .No_Negate_Remainder:
      ; Il quoziente si nega se i segni degli operandi differiscono.
      pla                           ; Recupera il segno del quoziente.
      bpl .Check_Quotient_Overflow

      +m_Div_Negate DIV_QUOT, 2

    .Exit_SDIV_16X8:
      clv                           ; Nessun overflow.
      clc                           ; Nessun errore.
      ldy DIV_REM+0                 ; Resto in .Y.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      rts

    ; Un quoziente positivo con il bit #7 acceso non entra con il
    ; segno: è l'overflow di -2^15 diviso -1.
    .Check_Quotient_Overflow:
      lda DIV_QUOT+1
      bpl .Exit_SDIV_16X8

    ; Il quoziente resta troncato. Una somma che va in overflow
    ; pone V a 1 e, con il Carry a 0, lascia anche C a 0.
    .Exit_SDIV_16X8_Overflow:
      clc
      lda #$40
      adc #$40                      ; $40 + $40 = $80: overflow, V = 1, C = 0.
      ldy DIV_REM+0                 ; Resto in .Y.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: DIV_24X8
; ------------------------------------------------------------------------------
; Descrizione:  Divide un intero a 24 bit per uno a 8 bit, senza segno. Il
;               quoziente ha 24 bit e il resto 8 bit.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP)       : Dividendo
;   - .A (1 byte, CPU)                      : Divisore
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+2 (3 byte, ZP) : Quoziente a 24 bit
;   - DIV_REM+0 (1 byte, ZP)                : Resto a 8 bit
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+2, DIV_2+0, DIV_REM+0
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_DIV_24X8 = 1) {
  !zone Div_24x8

    DIV_24X8:
      sta DIV_2+0                   ; Salva il divisore.

      cmp #0                        ; Il divisore è nullo?
      bne .No_Div_Zero

    .Exit_DIV_24X8_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      +m_Div_Core_24x8

    .Exit_DIV_24X8:
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      clc                           ; Nessun errore.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SDIV_24X8
; ------------------------------------------------------------------------------
; Descrizione:  Divide un intero a 24 bit per uno a 8 bit, con segno. Il
;               quoziente ha 24 bit e il resto 8 bit.
;
;               Rende positivi dividendo e divisore, esegue il nucleo senza
;               segno e corregge i segni: il quoziente è negativo se i segni
;               degli operandi sono diversi e il resto ha il segno del
;               dividendo.
;
;               L'unico overflow possibile è -2^23 diviso -1: il quoziente esce
;               troncato ai 24 bit bassi e il flag di oVerflow vale 1.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP)       : Dividendo con segno
;   - .A (1 byte, CPU)                      : Divisore con segno
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+2 (3 byte, ZP) : Quoziente a 24 bit con segno
;   - DIV_REM+0 (1 byte, ZP)                : Resto a 8 bit con segno
;   - Flag oVerflow (1 bit, .P)             : 0 = nessuno; 1 = overflow
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+2, DIV_2+0, DIV_REM+0
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_SDIV_24X8 = 1) {
  !zone Sdiv_24x8

    SDIV_24X8:
      sta DIV_2+0                   ; Salva il divisore.

      cmp #0                        ; Il divisore è nullo?
      bne .No_Div_Zero

    .Exit_SDIV_24X8_Div_Zero:
      clv                           ; Nessun overflow.
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      ; Il segno del quoziente è l'XOR dei segni degli operandi,
      ; quello del resto è il segno del dividendo (bit #7 dei byte
      ; più alti). Si conservano nello stack.
      lda DIV_1+2                   ; Il bit #7 è il segno del dividendo.
      eor DIV_2+0                   ; Segni diversi: il quoziente è negativo.
      pha                           ; Salva il segno del quoziente.
      lda DIV_1+2
      pha                           ; Salva il segno del resto.

      ; Un dividendo negativo si nega sul posto: il nucleo lavora
      ; solo su valori senza segno.
      bpl .No_Negate_Dividend       ; Il segno del dividendo è ancora in .A.

      +m_Div_Negate DIV_1, 3

    .No_Negate_Dividend:
      ; Lo stesso vale per il divisore.
      lda DIV_2+0
      bpl .No_Negate_Divisor

      +m_Div_Negate DIV_2, 1

    .No_Negate_Divisor:
      +m_Div_Core_24x8

      ; Il resto prende il segno del dividendo.
      pla                           ; Recupera il segno del resto.
      bpl .No_Negate_Remainder

      +m_Div_Negate DIV_REM, 1

    .No_Negate_Remainder:
      ; Il quoziente si nega se i segni degli operandi differiscono.
      pla                           ; Recupera il segno del quoziente.
      bpl .Check_Quotient_Overflow

      +m_Div_Negate DIV_QUOT, 3

    .Exit_SDIV_24X8:
      clv                           ; Nessun overflow.
      clc                           ; Nessun errore.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

    ; Un quoziente positivo con il bit #7 acceso non entra con il
    ; segno: è l'overflow di -2^23 diviso -1.
    .Check_Quotient_Overflow:
      lda DIV_QUOT+2
      bpl .Exit_SDIV_24X8

    ; Il quoziente resta troncato. Una somma che va in overflow
    ; pone V a 1 e, con il Carry a 0, lascia anche C a 0.
    .Exit_SDIV_24X8_Overflow:
      clc
      lda #$40
      adc #$40                      ; $40 + $40 = $80: overflow, V = 1, C = 0.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: DIV_32X8
; ------------------------------------------------------------------------------
; Descrizione:  Divide un intero a 32 bit per uno a 8 bit, senza segno. Il
;               quoziente ha 32 bit e il resto 8 bit.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP)       : Dividendo
;   - .A (1 byte, CPU)                      : Divisore
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+3 (4 byte, ZP) : Quoziente a 32 bit
;   - DIV_REM+0 (1 byte, ZP)                : Resto a 8 bit
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+3, DIV_2+0, DIV_REM+0
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_DIV_32X8 = 1) {
  !zone Div_32x8

    DIV_32X8:
      sta DIV_2+0                   ; Salva il divisore.

      cmp #0                        ; Il divisore è nullo?
      bne .No_Div_Zero

    .Exit_DIV_32X8_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      +m_Div_Core_32x8

    .Exit_DIV_32X8:
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      clc                           ; Nessun errore.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SDIV_32X8
; ------------------------------------------------------------------------------
; Descrizione:  Divide un intero a 32 bit per uno a 8 bit, con segno. Il
;               quoziente ha 32 bit e il resto 8 bit.
;
;               Rende positivi dividendo e divisore, esegue il nucleo senza
;               segno e corregge i segni: il quoziente è negativo se i segni
;               degli operandi sono diversi e il resto ha il segno del
;               dividendo.
;
;               L'unico overflow possibile è -2^31 diviso -1: il quoziente esce
;               troncato ai 32 bit bassi e il flag di oVerflow vale 1.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP)       : Dividendo con segno
;   - .A (1 byte, CPU)                      : Divisore con segno
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+3 (4 byte, ZP) : Quoziente a 32 bit con segno
;   - DIV_REM+0 (1 byte, ZP)                : Resto a 8 bit con segno
;   - Flag oVerflow (1 bit, .P)             : 0 = nessuno; 1 = overflow
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+3, DIV_2+0, DIV_REM+0
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_SDIV_32X8 = 1) {
  !zone Sdiv_32x8

    SDIV_32X8:
      sta DIV_2+0                   ; Salva il divisore.

      cmp #0                        ; Il divisore è nullo?
      bne .No_Div_Zero

    .Exit_SDIV_32X8_Div_Zero:
      clv                           ; Nessun overflow.
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      ; Il segno del quoziente è l'XOR dei segni degli operandi,
      ; quello del resto è il segno del dividendo (bit #7 dei byte
      ; più alti). Si conservano nello stack.
      lda DIV_1+3                   ; Il bit #7 è il segno del dividendo.
      eor DIV_2+0                   ; Segni diversi: il quoziente è negativo.
      pha                           ; Salva il segno del quoziente.
      lda DIV_1+3
      pha                           ; Salva il segno del resto.

      ; Un dividendo negativo si nega sul posto: il nucleo lavora
      ; solo su valori senza segno.
      bpl .No_Negate_Dividend       ; Il segno del dividendo è ancora in .A.

      +m_Div_Negate DIV_1, 4

    .No_Negate_Dividend:
      ; Lo stesso vale per il divisore.
      lda DIV_2+0
      bpl .No_Negate_Divisor

      +m_Div_Negate DIV_2, 1

    .No_Negate_Divisor:
      +m_Div_Core_32x8

      ; Il resto prende il segno del dividendo.
      pla                           ; Recupera il segno del resto.
      bpl .No_Negate_Remainder

      +m_Div_Negate DIV_REM, 1

    .No_Negate_Remainder:
      ; Il quoziente si nega se i segni degli operandi differiscono.
      pla                           ; Recupera il segno del quoziente.
      bpl .Check_Quotient_Overflow

      +m_Div_Negate DIV_QUOT, 4

    .Exit_SDIV_32X8:
      clv                           ; Nessun overflow.
      clc                           ; Nessun errore.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

    ; Un quoziente positivo con il bit #7 acceso non entra con il
    ; segno: è l'overflow di -2^31 diviso -1.
    .Check_Quotient_Overflow:
      lda DIV_QUOT+3
      bpl .Exit_SDIV_32X8

    ; Il quoziente resta troncato. Una somma che va in overflow
    ; pone V a 1 e, con il Carry a 0, lascia anche C a 0.
    .Exit_SDIV_32X8_Overflow:
      clc
      lda #$40
      adc #$40                      ; $40 + $40 = $80: overflow, V = 1, C = 0.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: DIV_16X16
; ------------------------------------------------------------------------------
; Descrizione:  Divide due interi a 16 bit, senza segno. Il quoziente ha 16 bit
;               e il resto 16 bit.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+1 (2 byte, ZP)       : Dividendo
;   - .A (1 byte, CPU)                      : Divisore, byte 0
;   - .X (1 byte, CPU)                      : Divisore, byte 1
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+1 (2 byte, ZP) : Quoziente a 16 bit
;   - DIV_REM+0 .. DIV_REM+1 (2 byte, ZP)   : Resto a 16 bit
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+1, DIV_2+0 .. DIV_2+1,
;                       DIV_REM+0 .. DIV_REM+1
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_DIV_16X16 = 1) {
  !zone Div_16x16

    DIV_16X16:
      sta DIV_2+0                   ; Salva il byte 0 del divisore.
      stx DIV_2+1                   ; Salva il byte 1 del divisore.

      ora DIV_2+1                   ; Il divisore è nullo se lo sono entrambi i byte.
      bne .No_Div_Zero

    .Exit_DIV_16X16_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      +m_Div_Core_16x16

    .Exit_DIV_16X16:
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      clc                           ; Nessun errore.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SDIV_16X16
; ------------------------------------------------------------------------------
; Descrizione:  Divide due interi a 16 bit, con segno. Il quoziente ha 16 bit e
;               il resto 16 bit.
;
;               Rende positivi dividendo e divisore, esegue il nucleo senza
;               segno e corregge i segni: il quoziente è negativo se i segni
;               degli operandi sono diversi e il resto ha il segno del
;               dividendo.
;
;               L'unico overflow possibile è -2^15 diviso -1: il quoziente esce
;               troncato ai 16 bit bassi e il flag di oVerflow vale 1.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+1 (2 byte, ZP)       : Dividendo con segno
;   - .A (1 byte, CPU)                      : Divisore con segno, byte 0
;   - .X (1 byte, CPU)                      : Divisore con segno, byte 1
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+1 (2 byte, ZP) : Quoziente a 16 bit con segno
;   - DIV_REM+0 .. DIV_REM+1 (2 byte, ZP)   : Resto a 16 bit con segno
;   - Flag oVerflow (1 bit, .P)             : 0 = nessuno; 1 = overflow
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+1, DIV_2+0 .. DIV_2+1,
;                       DIV_REM+0 .. DIV_REM+1
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_SDIV_16X16 = 1) {
  !zone Sdiv_16x16

    SDIV_16X16:
      sta DIV_2+0                   ; Salva il byte 0 del divisore.
      stx DIV_2+1                   ; Salva il byte 1 del divisore.

      ora DIV_2+1                   ; Il divisore è nullo se lo sono entrambi i byte.
      bne .No_Div_Zero

    .Exit_SDIV_16X16_Div_Zero:
      clv                           ; Nessun overflow.
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      ; Il segno del quoziente è l'XOR dei segni degli operandi,
      ; quello del resto è il segno del dividendo (bit #7 dei byte
      ; più alti). Si conservano nello stack.
      lda DIV_1+1                   ; Il bit #7 è il segno del dividendo.
      eor DIV_2+1                   ; Segni diversi: il quoziente è negativo.
      pha                           ; Salva il segno del quoziente.
      lda DIV_1+1
      pha                           ; Salva il segno del resto.

      ; Un dividendo negativo si nega sul posto: il nucleo lavora
      ; solo su valori senza segno.
      bpl .No_Negate_Dividend       ; Il segno del dividendo è ancora in .A.

      +m_Div_Negate DIV_1, 2

    .No_Negate_Dividend:
      ; Lo stesso vale per il divisore.
      lda DIV_2+1
      bpl .No_Negate_Divisor

      +m_Div_Negate DIV_2, 2

    .No_Negate_Divisor:
      +m_Div_Core_16x16

      ; Il resto prende il segno del dividendo.
      pla                           ; Recupera il segno del resto.
      bpl .No_Negate_Remainder

      +m_Div_Negate DIV_REM, 2

    .No_Negate_Remainder:
      ; Il quoziente si nega se i segni degli operandi differiscono.
      pla                           ; Recupera il segno del quoziente.
      bpl .Check_Quotient_Overflow

      +m_Div_Negate DIV_QUOT, 2

    .Exit_SDIV_16X16:
      clv                           ; Nessun overflow.
      clc                           ; Nessun errore.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      rts

    ; Un quoziente positivo con il bit #7 acceso non entra con il
    ; segno: è l'overflow di -2^15 diviso -1.
    .Check_Quotient_Overflow:
      lda DIV_QUOT+1
      bpl .Exit_SDIV_16X16

    ; Il quoziente resta troncato. Una somma che va in overflow
    ; pone V a 1 e, con il Carry a 0, lascia anche C a 0.
    .Exit_SDIV_16X16_Overflow:
      clc
      lda #$40
      adc #$40                      ; $40 + $40 = $80: overflow, V = 1, C = 0.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: DIV_24X16
; ------------------------------------------------------------------------------
; Descrizione:  Divide un intero a 24 bit per uno a 16 bit, senza segno. Il
;               quoziente ha 24 bit e il resto 16 bit.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP)       : Dividendo
;   - .A (1 byte, CPU)                      : Divisore, byte 0
;   - .X (1 byte, CPU)                      : Divisore, byte 1
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+2 (3 byte, ZP) : Quoziente a 24 bit
;   - DIV_REM+0 .. DIV_REM+1 (2 byte, ZP)   : Resto a 16 bit
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+2, DIV_2+0 .. DIV_2+1,
;                       DIV_REM+0 .. DIV_REM+1
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_DIV_24X16 = 1) {
  !zone Div_24x16

    DIV_24X16:
      sta DIV_2+0                   ; Salva il byte 0 del divisore.
      stx DIV_2+1                   ; Salva il byte 1 del divisore.

      ora DIV_2+1                   ; Il divisore è nullo se lo sono entrambi i byte.
      bne .No_Div_Zero

    .Exit_DIV_24X16_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      +m_Div_Core_24x16

    .Exit_DIV_24X16:
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      clc                           ; Nessun errore.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SDIV_24X16
; ------------------------------------------------------------------------------
; Descrizione:  Divide un intero a 24 bit per uno a 16 bit, con segno. Il
;               quoziente ha 24 bit e il resto 16 bit.
;
;               Rende positivi dividendo e divisore, esegue il nucleo senza
;               segno e corregge i segni: il quoziente è negativo se i segni
;               degli operandi sono diversi e il resto ha il segno del
;               dividendo.
;
;               L'unico overflow possibile è -2^23 diviso -1: il quoziente esce
;               troncato ai 24 bit bassi e il flag di oVerflow vale 1.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP)       : Dividendo con segno
;   - .A (1 byte, CPU)                      : Divisore con segno, byte 0
;   - .X (1 byte, CPU)                      : Divisore con segno, byte 1
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+2 (3 byte, ZP) : Quoziente a 24 bit con segno
;   - DIV_REM+0 .. DIV_REM+1 (2 byte, ZP)   : Resto a 16 bit con segno
;   - Flag oVerflow (1 bit, .P)             : 0 = nessuno; 1 = overflow
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+2, DIV_2+0 .. DIV_2+1,
;                       DIV_REM+0 .. DIV_REM+1
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_SDIV_24X16 = 1) {
  !zone Sdiv_24x16

    SDIV_24X16:
      sta DIV_2+0                   ; Salva il byte 0 del divisore.
      stx DIV_2+1                   ; Salva il byte 1 del divisore.

      ora DIV_2+1                   ; Il divisore è nullo se lo sono entrambi i byte.
      bne .No_Div_Zero

    .Exit_SDIV_24X16_Div_Zero:
      clv                           ; Nessun overflow.
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      ; Il segno del quoziente è l'XOR dei segni degli operandi,
      ; quello del resto è il segno del dividendo (bit #7 dei byte
      ; più alti). Si conservano nello stack.
      lda DIV_1+2                   ; Il bit #7 è il segno del dividendo.
      eor DIV_2+1                   ; Segni diversi: il quoziente è negativo.
      pha                           ; Salva il segno del quoziente.
      lda DIV_1+2
      pha                           ; Salva il segno del resto.

      ; Un dividendo negativo si nega sul posto: il nucleo lavora
      ; solo su valori senza segno.
      bpl .No_Negate_Dividend       ; Il segno del dividendo è ancora in .A.

      +m_Div_Negate DIV_1, 3

    .No_Negate_Dividend:
      ; Lo stesso vale per il divisore.
      lda DIV_2+1
      bpl .No_Negate_Divisor

      +m_Div_Negate DIV_2, 2

    .No_Negate_Divisor:
      +m_Div_Core_24x16

      ; Il resto prende il segno del dividendo.
      pla                           ; Recupera il segno del resto.
      bpl .No_Negate_Remainder

      +m_Div_Negate DIV_REM, 2

    .No_Negate_Remainder:
      ; Il quoziente si nega se i segni degli operandi differiscono.
      pla                           ; Recupera il segno del quoziente.
      bpl .Check_Quotient_Overflow

      +m_Div_Negate DIV_QUOT, 3

    .Exit_SDIV_24X16:
      clv                           ; Nessun overflow.
      clc                           ; Nessun errore.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

    ; Un quoziente positivo con il bit #7 acceso non entra con il
    ; segno: è l'overflow di -2^23 diviso -1.
    .Check_Quotient_Overflow:
      lda DIV_QUOT+2
      bpl .Exit_SDIV_24X16

    ; Il quoziente resta troncato. Una somma che va in overflow
    ; pone V a 1 e, con il Carry a 0, lascia anche C a 0.
    .Exit_SDIV_24X16_Overflow:
      clc
      lda #$40
      adc #$40                      ; $40 + $40 = $80: overflow, V = 1, C = 0.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: DIV_32X16
; ------------------------------------------------------------------------------
; Descrizione:  Divide un intero a 32 bit per uno a 16 bit, senza segno. Il
;               quoziente ha 32 bit e il resto 16 bit.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP)       : Dividendo
;   - .A (1 byte, CPU)                      : Divisore, byte 0
;   - .X (1 byte, CPU)                      : Divisore, byte 1
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+3 (4 byte, ZP) : Quoziente a 32 bit
;   - DIV_REM+0 .. DIV_REM+1 (2 byte, ZP)   : Resto a 16 bit
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+3, DIV_2+0 .. DIV_2+1,
;                       DIV_REM+0 .. DIV_REM+1
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_DIV_32X16 = 1) {
  !zone Div_32x16

    DIV_32X16:
      sta DIV_2+0                   ; Salva il byte 0 del divisore.
      stx DIV_2+1                   ; Salva il byte 1 del divisore.

      ora DIV_2+1                   ; Il divisore è nullo se lo sono entrambi i byte.
      bne .No_Div_Zero

    .Exit_DIV_32X16_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      +m_Div_Core_32x16

    .Exit_DIV_32X16:
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      clc                           ; Nessun errore.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SDIV_32X16
; ------------------------------------------------------------------------------
; Descrizione:  Divide un intero a 32 bit per uno a 16 bit, con segno. Il
;               quoziente ha 32 bit e il resto 16 bit.
;
;               Rende positivi dividendo e divisore, esegue il nucleo senza
;               segno e corregge i segni: il quoziente è negativo se i segni
;               degli operandi sono diversi e il resto ha il segno del
;               dividendo.
;
;               L'unico overflow possibile è -2^31 diviso -1: il quoziente esce
;               troncato ai 32 bit bassi e il flag di oVerflow vale 1.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP)       : Dividendo con segno
;   - .A (1 byte, CPU)                      : Divisore con segno, byte 0
;   - .X (1 byte, CPU)                      : Divisore con segno, byte 1
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+3 (4 byte, ZP) : Quoziente a 32 bit con segno
;   - DIV_REM+0 .. DIV_REM+1 (2 byte, ZP)   : Resto a 16 bit con segno
;   - Flag oVerflow (1 bit, .P)             : 0 = nessuno; 1 = overflow
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+3, DIV_2+0 .. DIV_2+1,
;                       DIV_REM+0 .. DIV_REM+1
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_SDIV_32X16 = 1) {
  !zone Sdiv_32x16

    SDIV_32X16:
      sta DIV_2+0                   ; Salva il byte 0 del divisore.
      stx DIV_2+1                   ; Salva il byte 1 del divisore.

      ora DIV_2+1                   ; Il divisore è nullo se lo sono entrambi i byte.
      bne .No_Div_Zero

    .Exit_SDIV_32X16_Div_Zero:
      clv                           ; Nessun overflow.
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      ; Il segno del quoziente è l'XOR dei segni degli operandi,
      ; quello del resto è il segno del dividendo (bit #7 dei byte
      ; più alti). Si conservano nello stack.
      lda DIV_1+3                   ; Il bit #7 è il segno del dividendo.
      eor DIV_2+1                   ; Segni diversi: il quoziente è negativo.
      pha                           ; Salva il segno del quoziente.
      lda DIV_1+3
      pha                           ; Salva il segno del resto.

      ; Un dividendo negativo si nega sul posto: il nucleo lavora
      ; solo su valori senza segno.
      bpl .No_Negate_Dividend       ; Il segno del dividendo è ancora in .A.

      +m_Div_Negate DIV_1, 4

    .No_Negate_Dividend:
      ; Lo stesso vale per il divisore.
      lda DIV_2+1
      bpl .No_Negate_Divisor

      +m_Div_Negate DIV_2, 2

    .No_Negate_Divisor:
      +m_Div_Core_32x16

      ; Il resto prende il segno del dividendo.
      pla                           ; Recupera il segno del resto.
      bpl .No_Negate_Remainder

      +m_Div_Negate DIV_REM, 2

    .No_Negate_Remainder:
      ; Il quoziente si nega se i segni degli operandi differiscono.
      pla                           ; Recupera il segno del quoziente.
      bpl .Check_Quotient_Overflow

      +m_Div_Negate DIV_QUOT, 4

    .Exit_SDIV_32X16:
      clv                           ; Nessun overflow.
      clc                           ; Nessun errore.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

    ; Un quoziente positivo con il bit #7 acceso non entra con il
    ; segno: è l'overflow di -2^31 diviso -1.
    .Check_Quotient_Overflow:
      lda DIV_QUOT+3
      bpl .Exit_SDIV_32X16

    ; Il quoziente resta troncato. Una somma che va in overflow
    ; pone V a 1 e, con il Carry a 0, lascia anche C a 0.
    .Exit_SDIV_32X16_Overflow:
      clc
      lda #$40
      adc #$40                      ; $40 + $40 = $80: overflow, V = 1, C = 0.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: DIV_24X24
; ------------------------------------------------------------------------------
; Descrizione:  Divide due interi a 24 bit, senza segno. Il quoziente ha 24 bit
;               e il resto 24 bit.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP)       : Dividendo
;   - .A (1 byte, CPU)                      : Divisore, byte 0
;   - .X (1 byte, CPU)                      : Divisore, byte 1
;   - .Y (1 byte, CPU)                      : Divisore, byte 2
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+2 (3 byte, ZP) : Quoziente a 24 bit
;   - DIV_REM+0 .. DIV_REM+2 (3 byte, ZP)   : Resto a 24 bit
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+2, DIV_2+0 .. DIV_2+2,
;                       DIV_REM+0 .. DIV_REM+2
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_DIV_24X24 = 1) {
  !zone Div_24x24

    DIV_24X24:
      sta DIV_2+0                   ; Salva il byte 0 del divisore.
      stx DIV_2+1                   ; Salva il byte 1 del divisore.
      sty DIV_2+2                   ; Salva il byte 2 del divisore.

      ora DIV_2+1                   ; Unisce i byte del divisore: se il risultato
      ora DIV_2+2                   ; è zero, il divisore è nullo.
      bne .No_Div_Zero

    .Exit_DIV_24X24_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      +m_Div_Core_24x24

    .Exit_DIV_24X24:
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      clc                           ; Nessun errore.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SDIV_24X24
; ------------------------------------------------------------------------------
; Descrizione:  Divide due interi a 24 bit, con segno. Il quoziente ha 24 bit e
;               il resto 24 bit.
;
;               Rende positivi dividendo e divisore, esegue il nucleo senza
;               segno e corregge i segni: il quoziente è negativo se i segni
;               degli operandi sono diversi e il resto ha il segno del
;               dividendo.
;
;               L'unico overflow possibile è -2^23 diviso -1: il quoziente esce
;               troncato ai 24 bit bassi e il flag di oVerflow vale 1.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+2 (3 byte, ZP)       : Dividendo con segno
;   - .A (1 byte, CPU)                      : Divisore con segno, byte 0
;   - .X (1 byte, CPU)                      : Divisore con segno, byte 1
;   - .Y (1 byte, CPU)                      : Divisore con segno, byte 2
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+2 (3 byte, ZP) : Quoziente a 24 bit con segno
;   - DIV_REM+0 .. DIV_REM+2 (3 byte, ZP)   : Resto a 24 bit con segno
;   - Flag oVerflow (1 bit, .P)             : 0 = nessuno; 1 = overflow
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+2, DIV_2+0 .. DIV_2+2,
;                       DIV_REM+0 .. DIV_REM+2
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_SDIV_24X24 = 1) {
  !zone Sdiv_24x24

    SDIV_24X24:
      sta DIV_2+0                   ; Salva il byte 0 del divisore.
      stx DIV_2+1                   ; Salva il byte 1 del divisore.
      sty DIV_2+2                   ; Salva il byte 2 del divisore.

      ora DIV_2+1                   ; Unisce i byte del divisore: se il risultato
      ora DIV_2+2                   ; è zero, il divisore è nullo.
      bne .No_Div_Zero

    .Exit_SDIV_24X24_Div_Zero:
      clv                           ; Nessun overflow.
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      ; Il segno del quoziente è l'XOR dei segni degli operandi,
      ; quello del resto è il segno del dividendo (bit #7 dei byte
      ; più alti). Si conservano nello stack.
      lda DIV_1+2                   ; Il bit #7 è il segno del dividendo.
      eor DIV_2+2                   ; Segni diversi: il quoziente è negativo.
      pha                           ; Salva il segno del quoziente.
      lda DIV_1+2
      pha                           ; Salva il segno del resto.

      ; Un dividendo negativo si nega sul posto: il nucleo lavora
      ; solo su valori senza segno.
      bpl .No_Negate_Dividend       ; Il segno del dividendo è ancora in .A.

      +m_Div_Negate DIV_1, 3

    .No_Negate_Dividend:
      ; Lo stesso vale per il divisore.
      lda DIV_2+2
      bpl .No_Negate_Divisor

      +m_Div_Negate DIV_2, 3

    .No_Negate_Divisor:
      +m_Div_Core_24x24

      ; Il resto prende il segno del dividendo.
      pla                           ; Recupera il segno del resto.
      bpl .No_Negate_Remainder

      +m_Div_Negate DIV_REM, 3

    .No_Negate_Remainder:
      ; Il quoziente si nega se i segni degli operandi differiscono.
      pla                           ; Recupera il segno del quoziente.
      bpl .Check_Quotient_Overflow

      +m_Div_Negate DIV_QUOT, 3

    .Exit_SDIV_24X24:
      clv                           ; Nessun overflow.
      clc                           ; Nessun errore.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

    ; Un quoziente positivo con il bit #7 acceso non entra con il
    ; segno: è l'overflow di -2^23 diviso -1.
    .Check_Quotient_Overflow:
      lda DIV_QUOT+2
      bpl .Exit_SDIV_24X24

    ; Il quoziente resta troncato. Una somma che va in overflow
    ; pone V a 1 e, con il Carry a 0, lascia anche C a 0.
    .Exit_SDIV_24X24_Overflow:
      clc
      lda #$40
      adc #$40                      ; $40 + $40 = $80: overflow, V = 1, C = 0.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: DIV_32X24
; ------------------------------------------------------------------------------
; Descrizione:  Divide un intero a 32 bit per uno a 24 bit, senza segno. Il
;               quoziente ha 32 bit e il resto 24 bit.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP)       : Dividendo
;   - .A (1 byte, CPU)                      : Divisore, byte 0
;   - .X (1 byte, CPU)                      : Divisore, byte 1
;   - .Y (1 byte, CPU)                      : Divisore, byte 2
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+3 (4 byte, ZP) : Quoziente a 32 bit
;   - DIV_REM+0 .. DIV_REM+2 (3 byte, ZP)   : Resto a 24 bit
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+3, DIV_2+0 .. DIV_2+2,
;                       DIV_REM+0 .. DIV_REM+2
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_DIV_32X24 = 1) {
  !zone Div_32x24

    DIV_32X24:
      sta DIV_2+0                   ; Salva il byte 0 del divisore.
      stx DIV_2+1                   ; Salva il byte 1 del divisore.
      sty DIV_2+2                   ; Salva il byte 2 del divisore.

      ora DIV_2+1                   ; Unisce i byte del divisore: se il risultato
      ora DIV_2+2                   ; è zero, il divisore è nullo.
      bne .No_Div_Zero

    .Exit_DIV_32X24_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      +m_Div_Core_32x24

    .Exit_DIV_32X24:
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      clc                           ; Nessun errore.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SDIV_32X24
; ------------------------------------------------------------------------------
; Descrizione:  Divide un intero a 32 bit per uno a 24 bit, con segno. Il
;               quoziente ha 32 bit e il resto 24 bit.
;
;               Rende positivi dividendo e divisore, esegue il nucleo senza
;               segno e corregge i segni: il quoziente è negativo se i segni
;               degli operandi sono diversi e il resto ha il segno del
;               dividendo.
;
;               L'unico overflow possibile è -2^31 diviso -1: il quoziente esce
;               troncato ai 32 bit bassi e il flag di oVerflow vale 1.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP)       : Dividendo con segno
;   - .A (1 byte, CPU)                      : Divisore con segno, byte 0
;   - .X (1 byte, CPU)                      : Divisore con segno, byte 1
;   - .Y (1 byte, CPU)                      : Divisore con segno, byte 2
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+3 (4 byte, ZP) : Quoziente a 32 bit con segno
;   - DIV_REM+0 .. DIV_REM+2 (3 byte, ZP)   : Resto a 24 bit con segno
;   - Flag oVerflow (1 bit, .P)             : 0 = nessuno; 1 = overflow
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+3, DIV_2+0 .. DIV_2+2,
;                       DIV_REM+0 .. DIV_REM+2
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_SDIV_32X24 = 1) {
  !zone Sdiv_32x24

    SDIV_32X24:
      sta DIV_2+0                   ; Salva il byte 0 del divisore.
      stx DIV_2+1                   ; Salva il byte 1 del divisore.
      sty DIV_2+2                   ; Salva il byte 2 del divisore.

      ora DIV_2+1                   ; Unisce i byte del divisore: se il risultato
      ora DIV_2+2                   ; è zero, il divisore è nullo.
      bne .No_Div_Zero

    .Exit_SDIV_32X24_Div_Zero:
      clv                           ; Nessun overflow.
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      ; Il segno del quoziente è l'XOR dei segni degli operandi,
      ; quello del resto è il segno del dividendo (bit #7 dei byte
      ; più alti). Si conservano nello stack.
      lda DIV_1+3                   ; Il bit #7 è il segno del dividendo.
      eor DIV_2+2                   ; Segni diversi: il quoziente è negativo.
      pha                           ; Salva il segno del quoziente.
      lda DIV_1+3
      pha                           ; Salva il segno del resto.

      ; Un dividendo negativo si nega sul posto: il nucleo lavora
      ; solo su valori senza segno.
      bpl .No_Negate_Dividend       ; Il segno del dividendo è ancora in .A.

      +m_Div_Negate DIV_1, 4

    .No_Negate_Dividend:
      ; Lo stesso vale per il divisore.
      lda DIV_2+2
      bpl .No_Negate_Divisor

      +m_Div_Negate DIV_2, 3

    .No_Negate_Divisor:
      +m_Div_Core_32x24

      ; Il resto prende il segno del dividendo.
      pla                           ; Recupera il segno del resto.
      bpl .No_Negate_Remainder

      +m_Div_Negate DIV_REM, 3

    .No_Negate_Remainder:
      ; Il quoziente si nega se i segni degli operandi differiscono.
      pla                           ; Recupera il segno del quoziente.
      bpl .Check_Quotient_Overflow

      +m_Div_Negate DIV_QUOT, 4

    .Exit_SDIV_32X24:
      clv                           ; Nessun overflow.
      clc                           ; Nessun errore.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

    ; Un quoziente positivo con il bit #7 acceso non entra con il
    ; segno: è l'overflow di -2^31 diviso -1.
    .Check_Quotient_Overflow:
      lda DIV_QUOT+3
      bpl .Exit_SDIV_32X24

    ; Il quoziente resta troncato. Una somma che va in overflow
    ; pone V a 1 e, con il Carry a 0, lascia anche C a 0.
    .Exit_SDIV_32X24_Overflow:
      clc
      lda #$40
      adc #$40                      ; $40 + $40 = $80: overflow, V = 1, C = 0.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: DIV_32X32
; ------------------------------------------------------------------------------
; Descrizione:  Divide due interi a 32 bit, senza segno. Il quoziente ha 32 bit
;               e il resto 32 bit.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP)       : Dividendo
;   - DIV_2+0 .. DIV_2+3 (4 byte, ZP)       : Divisore
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+3 (4 byte, ZP) : Quoziente a 32 bit
;   - DIV_REM+0 .. DIV_REM+3 (4 byte, ZP)   : Resto a 32 bit
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+3, DIV_REM+0 .. DIV_REM+3
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_DIV_32X32 = 1) {
  !zone Div_32x32

    DIV_32X32:

      lda DIV_2+0                   ; Unisce i byte del divisore: se il risultato
      ora DIV_2+1                   ; è zero, il divisore è nullo.
      ora DIV_2+2
      ora DIV_2+3
      bne .No_Div_Zero

    .Exit_DIV_32X32_Div_Zero:
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      +m_Div_Core_32x32

    .Exit_DIV_32X32:
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      clc                           ; Nessun errore.
      rts

  !zone
}

; ==============================================================================
; SUBROUTINE: SDIV_32X32
; ------------------------------------------------------------------------------
; Descrizione:  Divide due interi a 32 bit, con segno. Il quoziente ha 32 bit e
;               il resto 32 bit.
;
;               Rende positivi dividendo e divisore, esegue il nucleo senza
;               segno e corregge i segni: il quoziente è negativo se i segni
;               degli operandi sono diversi e il resto ha il segno del
;               dividendo.
;
;               L'unico overflow possibile è -2^31 diviso -1: il quoziente esce
;               troncato ai 32 bit bassi e il flag di oVerflow vale 1.
;
;               Se il divisore è zero esce con il Carry a 1 e
;               ERR_DIVISION_BY_ZERO in .A, senza toccare quoziente e resto.
;
; Input:
;   - DIV_1+0 .. DIV_1+3 (4 byte, ZP)       : Dividendo con segno
;   - DIV_2+0 .. DIV_2+3 (4 byte, ZP)       : Divisore con segno
;
; Output:
;   - .A (1 byte, CPU)                      : Byte 0 del quoziente, o
;                                             ERR_DIVISION_BY_ZERO se C = 1
;   - .X (1 byte, CPU)                      : Byte 1 del quoziente
;   - .Y (1 byte, CPU)                      : Byte 2 del quoziente
;   - DIV_QUOT+0 .. DIV_QUOT+3 (4 byte, ZP) : Quoziente a 32 bit con segno
;   - DIV_REM+0 .. DIV_REM+3 (4 byte, ZP)   : Resto a 32 bit con segno
;   - Flag oVerflow (1 bit, .P)             : 0 = nessuno; 1 = overflow
;   - Flag Carry (1 bit, .P)                : 0 = eseguita; 1 = divisore nullo
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       DIV_QUOT+0 .. DIV_QUOT+3, DIV_2+0 .. DIV_2+3,
;                       DIV_REM+0 .. DIV_REM+3
; Dipendenze Esterne:   <c64/errors.asm>
;                       <c64/symbols.asm>
; ==============================================================================
!if (__USE_SDIV_32X32 = 1) {
  !zone Sdiv_32x32

    SDIV_32X32:

      lda DIV_2+0                   ; Unisce i byte del divisore: se il risultato
      ora DIV_2+1                   ; è zero, il divisore è nullo.
      ora DIV_2+2
      ora DIV_2+3
      bne .No_Div_Zero

    .Exit_SDIV_32X32_Div_Zero:
      clv                           ; Nessun overflow.
      lda #ERR_DIVISION_BY_ZERO     ; Codice di errore.
      sec                           ; Errore: il divisore è zero.
      rts

    .No_Div_Zero:
      ; Il segno del quoziente è l'XOR dei segni degli operandi,
      ; quello del resto è il segno del dividendo (bit #7 dei byte
      ; più alti). Si conservano nello stack.
      lda DIV_1+3                   ; Il bit #7 è il segno del dividendo.
      eor DIV_2+3                   ; Segni diversi: il quoziente è negativo.
      pha                           ; Salva il segno del quoziente.
      lda DIV_1+3
      pha                           ; Salva il segno del resto.

      ; Un dividendo negativo si nega sul posto: il nucleo lavora
      ; solo su valori senza segno.
      bpl .No_Negate_Dividend       ; Il segno del dividendo è ancora in .A.

      +m_Div_Negate DIV_1, 4

    .No_Negate_Dividend:
      ; Lo stesso vale per il divisore.
      lda DIV_2+3
      bpl .No_Negate_Divisor

      +m_Div_Negate DIV_2, 4

    .No_Negate_Divisor:
      +m_Div_Core_32x32

      ; Il resto prende il segno del dividendo.
      pla                           ; Recupera il segno del resto.
      bpl .No_Negate_Remainder

      +m_Div_Negate DIV_REM, 4

    .No_Negate_Remainder:
      ; Il quoziente si nega se i segni degli operandi differiscono.
      pla                           ; Recupera il segno del quoziente.
      bpl .Check_Quotient_Overflow

      +m_Div_Negate DIV_QUOT, 4

    .Exit_SDIV_32X32:
      clv                           ; Nessun overflow.
      clc                           ; Nessun errore.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

    ; Un quoziente positivo con il bit #7 acceso non entra con il
    ; segno: è l'overflow di -2^31 diviso -1.
    .Check_Quotient_Overflow:
      lda DIV_QUOT+3
      bpl .Exit_SDIV_32X32

    ; Il quoziente resta troncato. Una somma che va in overflow
    ; pone V a 1 e, con il Carry a 0, lascia anche C a 0.
    .Exit_SDIV_32X32_Overflow:
      clc
      lda #$40
      adc #$40                      ; $40 + $40 = $80: overflow, V = 1, C = 0.
      lda DIV_QUOT+0                ; Byte 0 del quoziente in .A.
      ldx DIV_QUOT+1                ; Byte 1 del quoziente in .X.
      ldy DIV_QUOT+2                ; Byte 2 del quoziente in .Y.
      rts

  !zone
}

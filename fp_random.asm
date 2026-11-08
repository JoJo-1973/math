; ==============================================================================
; FILE:           fp_random.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per generare numeri pseudocasuali in virgola mobile
;                 (formato MBF) con la routine RND della ROM del BASIC, e per
;                 inizializzare il generatore. L'interruttore __PRESERVE_ARG di
;                 config.asm decide se ARG viene preservato.
; CONTENUTO:      m_Load_FAC_with_RND   Numero casuale in FAC
;                 m_Randomize           Inizializza il generatore
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   Nessuno
; ==============================================================================

; ==============================================================================
; MACRO: m_Load_FAC_with_RND
; ------------------------------------------------------------------------------
; Descrizione:  Genera in FAC un numero pseudocasuale in virgola mobile tra 0 e
;               1, 1 escluso, con la routine RND della ROM del BASIC. Il
;               generatore deve essere inizializzato prima: vedi m_Randomize.
;
;               Il segno di FAC prima della chiamata decide il comportamento.
;               Con FAC > 0 FAC è sostituito dal numero successivo della
;               sequenza e il suo valore non conta. Con FAC = 0 il numero deriva
;               dai registri dei timer del CIA #1. Con FAC < 0 il generatore è
;               reinizializzato con il numero che è in FAC, e FAC contiene il
;               nuovo seme: con un seme piccolo è un numero molto piccolo.
;
;               Un seme negativo genera sempre la stessa sequenza: è utile per
;               collaudo e debug. Per i limiti del caso FAC = 0 e per le altre
;               particolarità di RND vedi [NOTA #10 in <fp/fp.asm>].
;
;               La ROM altera queste celle di lavoro, il cui contenuto non è
;               garantito dopo la chiamata: INDEX, RESHO e $56. Aggiorna inoltre
;               il seme, in RNDX.
;
;               Se __PRESERVE_ARG = 1 la macro salva ARG in _SCRATCH_2 prima
;               della chiamata e lo ripristina dopo, perché con FAC > 0 la ROM
;               altera ARG; se vale 0 il contenuto di ARG non è garantito dopo
;               la chiamata. Un ARG uguale a zero (ARGEXP = 0) torna con ARGHO =
;               $80, ed è ancora zero.
;
;               Con FAC > 0 la ROM usa una moltiplicazione: per l'accuratezza
;               vedi [NOTA #08 in <fp/fp.asm>].
;
; Input:
;   - FAC (7 byte, ZP)               : Segno: > 0 numero successivo; = 0 seme
;                                      dal CIA #1; < 0 nuovo seme
;   - __PRESERVE_ARG (1 byte, Macro) : 1 = ARG viene preservato; 0 = ARG può
;                                      essere alterato
;
; Output:
;   - FAC (7 byte, ZP)               : Numero tra 0 e 1, registri da FACEXP a
;                                      FACOV
;   - ARG (6 byte, ZP)               : Invariato se __PRESERVE_ARG = 1;
;                                      altrimenti non garantito
;   - RNDX (5 byte, ZP)              : Seme aggiornato, da RNDX+0 a RNDX+4
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       ARISGN, INDEX, RNDX (5 byte), _SCRATCH_2 (se
;                       __PRESERVE_ARG = 1)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_scratch.asm>
; ==============================================================================
!macro m_Load_FAC_with_RND {
    !if (__PRESERVE_ARG = 1) {
      +m_Store_ARG_in_Scratch
    }

    jsr RND                           ; Genera il numero casuale o reinizializza.

    !if (__PRESERVE_ARG = 1) {
      +m_Load_ARG_from_Scratch
    }
}

; ==============================================================================
; MACRO: m_Randomize
; ------------------------------------------------------------------------------
; Descrizione:  Inizializza il generatore di numeri pseudocasuali con -TI, cioè
;               con il valore dell'orologio jiffy TIME, cambiato di segno.
;               Poiché TI ha 24 bit, 8 bit del seme sarebbero sempre 0, e questo
;               limita i semi possibili.
;
;               Per aggiungere casualità, il numero positivo tra 0 e 1 che la
;               ROM genera con il primo seme è negato e usato come secondo seme:
;               così tutti i 32 bit della mantissa sono valorizzati. Alla fine
;               FAC contiene il seme in uso, un numero positivo tra 0 e 1.
;
;               La macro usa solo i rami di RND con FAC negativo, che non
;               alterano ARG: per questo non ha bisogno di preservarlo e
;               l'interruttore __PRESERVE_ARG non ha effetto. Per le
;               particolarità di RND vedi [NOTA #10 in <fp/fp.asm>].
;
;               La ROM altera la cella di lavoro INDEX, il cui contenuto non è
;               garantito dopo la chiamata. Aggiorna inoltre il seme, in RNDX.
;
; Input:
;   - TIME (3 byte, ZP) : Orologio jiffy
;
; Output:
;   - FAC (7 byte, ZP)  : Seme in uso, numero tra 0 e 1
;   - ARG (6 byte, ZP)  : Invariato
;   - RNDX (5 byte, ZP) : Nuovo seme, da RNDX+0 a RNDX+4
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), INDEX,
;                       RNDX (5 byte)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_integers.asm>
;                       <fp/fp_unary.asm>
; ==============================================================================
!macro m_Randomize {
    +m_Load_FAC_with_UINT24_Mem TIME  ; FAC = TI, positivo, con MSB della mantissa a 0.
    +m_Negate_FAC                     ; Lo nega e lo usa come primo seme.
    jsr RND

    +m_Negate_FAC                     ; FAC è positivo, ma ora i 32 bit della mantissa
    jsr RND                           ; sono tutti valorizzati: lo nega e reinizializza.
}

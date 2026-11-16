; ==============================================================================
; FILE:           fp_compare.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per confrontare FAC con un altro numero in virgola
;                 mobile (formato MBF), che può essere in ARG, a un indirizzo
;                 assoluto o puntato da un puntatore. Il risultato è in .A.
; CONTENUTO:      m_Compare_FAC_to_ARG  Confronta FAC con ARG
;                 m_Compare_FAC_to_Mem  Confronta FAC con indirizzo
;                 m_Compare_FAC_to_Ptr  Confronta FAC con puntatore
; DIPENDENZE:     Nessuna
; REQUISITI ZP:   Nessuno
; ==============================================================================

; ==============================================================================
; MACRO: m_Compare_FAC_to_ARG
; ------------------------------------------------------------------------------
; Descrizione:  Confronta FAC con il numero in virgola mobile di ARG.
;
;               FCOMP non lavora con ARG, che è in formato non impacchettato:
;               la macro lo scrive in formato MBF in 5 byte a partire da
;               STACK ($0100), con m_Store_ARG_to_Mem, e punta FCOMP a
;               quell'indirizzo. Il contenuto di STACK non è garantito dopo
;               la chiamata.
;
;               Chiama la routine FCOMP della ROM del BASIC, che altera INDEX2:
;               il suo contenuto non è garantito dopo la chiamata.
;
;               Il risultato è in .A: $00 se FAC = numero, $01 se FAC > numero,
;               $FF se FAC < numero. Anche i flag Negative e Zero riflettono .A;
;               il Carry vale 1 se FAC < numero e 0 se FAC > numero, mentre non
;               è garantito se sono uguali.
;
;               Il confronto è esatto su tutti i bit della mantissa, FACOV
;               compreso. FAC e ARG non cambiano; due zeri sono uguali,
;               qualunque sia il loro segno.
;
; Input:
;   - FAC (7 byte, ZP)       : Registri da FACEXP a FACOV
;   - ARG (6 byte, ZP)       : Registri da ARGEXP a ARGSGN
;
; Output:
;   - .A (1 byte, CPU)       : $00 = uguali; $01 = FAC maggiore; $FF = FAC
;                              minore
;   - Flag Carry (1 bit, .P) : 0 = FAC maggiore; 1 = FAC minore (non garantito
;                              se uguali)
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry),
;                       INDEX2, STACK (5 byte)
; Dipendenze Esterne:   <c64/symbols.asm>
;                       <fp/fp_memory.asm>
; ==============================================================================
!macro m_Compare_FAC_to_ARG {
    +m_Store_ARG_to_Mem STACK   ; Scrive ARG in formato MBF in STACK.

    lda #<STACK                 ; Punta .A/.Y a STACK.
    ldy #>STACK
    jsr FCOMP                   ; Confronta FAC con il numero.
}

; ==============================================================================
; MACRO: m_Compare_FAC_to_Mem
; ------------------------------------------------------------------------------
; Descrizione:  Confronta FAC con il numero in formato MBF che si trova a un
;               indirizzo assoluto.
;
;               Chiama la routine FCOMP della ROM del BASIC, che altera INDEX2:
;               il suo contenuto non è garantito dopo la chiamata.
;
;               Il risultato è in .A: $00 se FAC = numero, $01 se FAC > numero,
;               $FF se FAC < numero. Anche i flag Negative e Zero riflettono .A;
;               il Carry vale 1 se FAC < numero e 0 se FAC > numero, mentre non
;               è garantito se sono uguali.
;
;               Il confronto è esatto su tutti i bit della mantissa, FACOV
;               compreso. FAC e ARG non cambiano; due zeri sono uguali,
;               qualunque sia il loro segno.
;
; Input:
;   - FAC (7 byte, ZP)           : Registri da FACEXP a FACOV
;   - .addr_ (1 o 2 byte, Macro) : Indirizzo del numero
;   - (.addr_) (5 byte, RAM)     : Numero in formato MBF
;
; Output:
;   - .A (1 byte, CPU)           : $00 = uguali; $01 = FAC maggiore; $FF = FAC
;                                  minore
;   - Flag Carry (1 bit, .P)     : 0 = FAC maggiore; 1 = FAC minore (non
;                                  garantito se uguali)
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), INDEX2
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Compare_FAC_to_Mem .addr_ {
    lda #<.addr_                ; Punta .A/.Y al numero.
    ldy #>.addr_
    jsr FCOMP                   ; Confronta FAC con il numero.
}

; ==============================================================================
; MACRO: m_Compare_FAC_to_Ptr
; ------------------------------------------------------------------------------
; Descrizione:  Confronta FAC con il numero in formato MBF che si trova
;               all'indirizzo a cui punta un puntatore.
;
;               Chiama la routine FCOMP della ROM del BASIC, che altera INDEX2:
;               il suo contenuto non è garantito dopo la chiamata.
;
;               Il risultato è in .A: $00 se FAC = numero, $01 se FAC > numero,
;               $FF se FAC < numero. Anche i flag Negative e Zero riflettono .A;
;               il Carry vale 1 se FAC < numero e 0 se FAC > numero, mentre non
;               è garantito se sono uguali.
;
;               Il confronto è esatto su tutti i bit della mantissa, FACOV
;               compreso. FAC e ARG non cambiano; due zeri sono uguali,
;               qualunque sia il loro segno.
;
; Input:
;   - FAC (7 byte, ZP)          : Registri da FACEXP a FACOV
;   - .ptr_ (1 o 2 byte, Macro) : Indirizzo del puntatore
;   - (.ptr_) (2 byte, RAM)     : Indirizzo del numero (LSB, MSB)
;   - ((.ptr_)) (5 byte, RAM)   : Numero in formato MBF
;
; Output:
;   - .A (1 byte, CPU)          : $00 = uguali; $01 = FAC maggiore; $FF = FAC
;                                 minore
;   - Flag Carry (1 bit, .P)    : 0 = FAC maggiore; 1 = FAC minore (non
;                                 garantito se uguali)
;
; Variazione Stack (.S):
;   - Stabile
;
; Registri Modificati:  .A, .X, .Y, .P (Negative, oVerflow, Zero, Carry), INDEX2
; Dipendenze Esterne:   <c64/symbols.asm>
; ==============================================================================
!macro m_Compare_FAC_to_Ptr .ptr_ {
    lda .ptr_                   ; Punta .A/.Y al numero.
    ldy .ptr_+1
    jsr FCOMP                   ; Confronta FAC con il numero.
}

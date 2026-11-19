; TODO: Implementare xorshift_8 di Edward Rosten
; Codice originale: https://github.com/edrosten/8bit_rng/blob/master/rng-4261412736.c

; L'algoritmo XORSHIFT_16 per 6502 di Bumbershoot portato in formato ACME
; Codice originale: https://github.com/michaelcmartin/bumbershoot/blob/master/asm/xorshift.s

RANDOMIZE_XORSHIFT_16:
        jsr RDTIM
        sta     ._X
        sta     ._Y
        stx     ._X+1
        stx     ._Y+1
        rts

RND_XORSHIFT_16:
; L'algoritmo XORSHIFT_16 consta di tre passi:
;   1. t = x ^ (x << 5)
;   2. x = y
;   3. y = (y ^ (y >> 1)) ^ (t ^ (t >> 3))
;
; che possono essere spezzati in:
;
;   1. x = x ^ (x << 5)
;   2. x = x ^ (x >> 3)
;   3. Salva y sullo stack
;   4. y = y ^ (y >> 1)
;   5. y = y ^ x
;   6. Recupera y dallo stack e mettilo in x

        lda     ._X              ; 1. x = x ^ (x << 5)
        ldy     ._X+1            ; .A = ._X   = LSB(x)
                                ; .Y = ._X+1 = MSB(x)
        ldx     #5

.Loop_Asl:
        asl                     ; All'uscita del ciclo:
        rol     ._X+1            ; .A   = LSB(x << 5)
        dex                     ; ._X+1 = MSB(x << 5)
        bne     .Loop_Asl

        eor     ._X              ; ._X   = LSB(x ^ (x << 5))
        sta     ._X

        tya                     ; ._X+1 = MSB(x ^ (x << 5))
        eor     ._X+1
        sta     ._X+1


        ldy     ._X              ; 2. x = x ^ (x >> 3)
                                ; .Y = ._X   = LSB(x)
                                ; .A = ._X+1 = MSB(x)
        ldx     #$03

.Loop_Lsr:
        lsr                     ; All'uscita del ciclo:
        ror     ._X              ; ._X = LSB(x >> 3)
        dex                     ; .A = MSB(x >> 3)
        bne     .Loop_Lsr

        eor     ._X+1            ; ._X   = LSB(x ^ (x >> 3))
        sta     ._X+1            ; ._X+1 = MSB(x ^ (x >> 3))
        tya
        eor     ._X
        sta     ._X

        lda     ._Y              ; 3. Salva y sullo stack perché poi diventerà ._X nel passo 6.
        pha
        lda     ._Y+1
        pha

                                ; 4. y = y ^ (y >> 1)
                                ; 5. y = y ^ x
                                ; 6. x = y

        lsr                     ; ._Y = LSB(y >> 1)
        ror     ._Y              ; .A = MSB(y >> 1)

                                ; I passi 4., 5. e 6. (non necessariamente in quest'ordine) vengono eseguiti prima sul MSB:

        eor     ._X+1            ; 4. MSB(y) = MSB(y >> 1) ^ MSB(x)
        sta     ._Y+1

        pla                     ; 6. .A = MSB(y)
        sta     ._X+1            ;    MSB(x) = MSB(y)

        eor     ._Y+1            ; 5. MSB(y) = MSB(y) ^ MSB(x)
        sta     ._Y+1

                                ; E poi sul LSB:

        pla                     ; .A = .X = LSB(y)
        tax

        eor     ._Y              ; 4, 5. LSB(y) = LSB(y >> 1) ^ LSB(x)
        eor     ._X
        sta     ._Y

        stx     ._X              ; 6.    LSB(x) = LSB(y)
        rts

._X:
  !word $0000

._Y:
  !word $0000

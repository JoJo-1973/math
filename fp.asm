; ==============================================================================
; FILE:           fp.asm
; PROGETTO:       Libreria di Sistema (fp.c64)
; TARGET:         ACME Assembler / MOS 6510 (Commodore 64)
; DESCRIZIONE:    Macro per l'aritmetica in virgola mobile nel formato MBF del
;                 BASIC Commodore, basate sulle routine della ROM.
; DIPENDENZE:     <c64/errors.asm>
;                 <c64/symbols.asm>
;                 <fp/fp_common.asm>
;                 <fp/fp_arith.asm>
;                 <fp/fp_boolean.asm>
;                 <fp/fp_compare.asm>
;                 <fp/fp_constants.asm>
;                 <fp/fp_error.asm>
;                 <fp/fp_integers.asm>
;                 <fp/fp_io.asm>
;                 <fp/fp_memory.asm>
;                 <fp/fp_poly.asm>
;                 <fp/fp_power.asm>
;                 <fp/fp_random.asm>
;                 <fp/fp_transcend.asm>
;                 <fp/fp_trig.asm>
;                 <fp/fp_unary.asm>
; REQUISITI ZP:   __FP_SAVED_SP, _SCRATCH_1, _SCRATCH_2
; ==============================================================================

; ******************************************************************************
; NOTE D'USO
; ******************************************************************************
;
; NOTA #01
; --------
; I numeri in memoria sono codificati in due formati diversi:
;
; MICROSOFT BINARY FORMAT (MBF)
; -----------------------------
;
;     Byte 0   Byte 1   Byte 2   Byte 3   Byte 4
;   |76543210|76543210|76543210|76543210|76543210|
;   |Esp.+$80|S<------------Mantissa------------>|
;
; Poiché la mantissa è memorizzata in forma normalizzata, il bit #7 del
; byte 1 è per definizione sempre "1". Sfruttando questo fatto, il bit #7
; del byte 1 codifica in realtà il segno del numero: "+" = 0 e "-" = 1, con
; il vantaggio di una rappresentazione che occupa meno memoria.
;
; FORMATO FLOATING POINT ACCUMULATOR (FAC)
; ----------------------------------------
;
; Quando il numero viene memorizzato in un FAC, o trasferito in esso, la
; rappresentazione viene espansa in una forma più adatta alla
; manipolazione numerica:
;
;     Byte 0   Byte 1   Byte 2   Byte 3   Byte 4   Byte 5
;   |76543210|76543210|76543210|76543210|76543210|76543210|
;   |Esp.+$80|<------------Mantissa------------->|S<inut.>|
;
; In questa rappresentazione il bit #7 del byte 1 è ripristinato a "1",
; mentre il bit #7 del byte aggiuntivo codifica il segno: "+" = 0, "-" = 1.
;
;
; NOTA #02
; --------
; Il registro ARISGN contiene $00 se i segni di FAC e ARG sono uguali e un
; valore diverso da $00 se sono diversi, ma questo è garantito solo se ARG
; viene aggiornato DOPO FAC. Per semplificare il compito del programmatore, le
; macro della libreria aggiornano automaticamente il registro ARISGN ogni
; volta che FAC viene modificato.
;
;
; NOTA #03
; --------
; Tutto ciò che esce da FAC viene arrotondato in base al valore del
; registro FACOV.
;
;
; NOTA #04
; --------
; Le librerie math e fp usano le stesse celle di pagina zero. NUMWRK ($57-$60)
; è l'area di lavoro di math_mult, di math8 (NUMWRK+0) e della ROM; anche
; _SCRATCH_2, che contiene la copia di ARG, coincide con NUMWRK. In
; moltiplicazione le celle arrivano fino ai primi due byte di FAC ($61-$62).
; Un dato lasciato in quelle celle da una libreria viene distrutto dall'altra:
; ogni chiamata va considerata autonoma e il suo risultato va copiato altrove
; prima di chiamare l'altra libreria.
;
;
; NOTA #05
; --------
; Le macro chiamano routine della ROM BASIC ($A000-$BFFF) e della sua parte
; residente nella ROM KERNAL ($E000-$E4AC). Entrambe le ROM devono essere
; visibili: LORAM e HIRAM (bit #0 e #1 di $01) devono valere 1, come nella
; configurazione standard ($01 = $37).
;
;
; NOTA #06
; --------
; Le routine della ROM alterano variabili vitali del BASIC. _SCRATCH_1
; ($3D-$43) copre OLDTXT, DATLIN, DATPTR e il byte basso di INPPTR: dopo l'uso
; di fp il comando CONT non è più affidabile e READ e INPUT ripartono da
; puntatori alterati. Vengono inoltre modificati NUMWRK, FAC, ARG, le celle di
; lavoro della ROM e, nelle conversioni da stringa, TXTPTR ($7A/$7B). Un
; programma in LM che non torna al BASIC non è interessato; uno che ci torna
; deve considerare persi questi valori.
;
;
; NOTA #07
; --------
; Le routine della ROM possono segnalare tre errori: ?ILLEGAL QUANTITY ($0E),
; ?OVERFLOW ($0F) e ?DIVISION BY ZERO ($14). La ROM non ritorna al chiamante:
; salta a IERROR tramite il vettore ($0300) con il codice in .X, e il BASIC
; stampa il messaggio e torna a READY.
;
; Con __USE_FP_ERROR_HANDLER = 1 ogni macro a rischio salva .S in
; __FP_SAVED_SP (ZP, $06) prima della chiamata. Se il chiamante fa puntare il
; vettore IERROR a FP_ERROR_HANDLER, il gestore ripristina .S e ritorna subito
; dopo il jsr della macro, con Carry = 1 e il codice d'errore in .X.
; Carry = 0 indica che non c'è stato errore. L'installazione del vettore è
; compito del chiamante.
;
;
; NOTA #08
; --------
; La moltiplicazione in virgola mobile della ROM contiene un bug noto, che
; interessa quasi tutti i BASIC Commodore a 8 bit (non il BASIC 7.0 del C128).
; Per certe coppie di operandi il risultato è sbagliato di pochi bit, e può
; dipendere dall'ordine: con V = 1 + 255/2^31, V*1-V dà 0 mentre 1*V-V non dà
; 0. La causa è in MLTPLY ($BA59): quando un byte della mantissa di ARG è
; zero, la routine salta a MULSHF ($B983), che somma senza controllare il
; Carry e può scorrere di 9 bit invece di 8.
;
; Il bug riguarda ogni macro che moltiplica, direttamente o attraverso la ROM:
; m_Multiply_FAC_by_ARG/_Mem/_Ptr, le conversioni in stringa e le stampe, i
; polinomi, la potenza e SQR, LOG ed EXP, le funzioni trigonometriche e
; m_Load_FAC_with_RND (con FAC positivo).
;
; Fonte: https://www.c64-wiki.com/wiki/Multiply_bug
;
; Nella sola moltiplicazione si può ridurre il problema scambiando i due
; operandi: su 20000 coppie casuali lo scambio corregge circa il 94% dei casi
; in cui un ordine è sbagliato, ma non tutti, perché in 300 casi sono
; sbagliati entrambi. Dopo lo scambio ARISGN va ricalcolato (FACSGN xor
; ARGSGN). Per le altre funzioni il rimedio non si applica: l'ordine delle
; moltiplicazioni interne non dipende dal chiamante.
;
;
; NOTA #09
; --------
; SQR calcola la radice tramite LOG ed EXP, quindi ne eredita i polinomi e il
; bug della moltiplicazione (NOTA #08). Il wiki dichiara un accordo col valore
; vero fino a 30 bit (25 bit per pochi ingressi). Nelle nostre misure, su
; 1500 ingressi casuali, la mediana è 33.0 bit e il minimo 31.0 (la mantissa
; ha 32 bit). SQR(0) = 0; un argomento negativo dà ?ILLEGAL QUANTITY.
;
; Fonte: https://www.c64-wiki.com/wiki/SQR
;
;
; NOTA #10
; --------
; RND dipende dal segno di FAC. Con FAC > 0 restituisce il numero successivo
; della sequenza (seme x 11879546 + 3.927677739E-8, poi i byte della mantissa
; vengono scambiati). Con FAC < 0 FAC diventa il nuovo seme, e lo stesso seme
; dà sempre la stessa sequenza: utile per collaudi e debug. Il risultato di
; quella chiamata è il seme stesso, quindi con un seme piccolo è un numero
; molto piccolo (RND(-1) = 2.99E-8). Con FAC = 0 il seme viene ricavato dai
; timer A e dall'orologio TOD del CIA #1 ($DC04, $DC05, $DC08, $DC09): questi
; registri non sono inizializzati all'avvio e alcuni lavorano in BCD, quindi
; non assumono tutti i valori possibili e lo spazio dei semi si riduce.
;
; m_Randomize usa come seme -TI: TI ha 24 bit, quindi 8 bit della mantissa a
; 32 bit sono sempre zero. Per aggiungere casualità, il numero ottenuto (tra 0
; e 1) viene poi negato e usato per reinizializzare il generatore.
;
; Secondo il wiki l'implementazione può degenerare in sequenze molto corte
; (nel caso peggiore 723 valori distinti); questo non è stato verificato qui.
;
; Fonte: https://www.c64-wiki.com/wiki/RND
;
;
; NOTA #11
; --------
; LOG(V) dà ?ILLEGAL QUANTITY per V <= 0; LOG(1) = 0. Il wiki dichiara un
; accordo col valore vero fino a 29 bit (24 per pochi ingressi), con
; peggioramento vicino a V = 1. Nelle nostre misure su 1500 ingressi casuali
; la mediana è 31.9 bit e il minimo 22.8 (26 ingressi sotto 27 bit). I casi
; peggiori sono vicini a 1: LOG(0.99) dà 24.4 bit, LOG(1.01) 26.9, LOG(1.1)
; 27.7. L'errore assoluto resta piccolo, ma il risultato è piccolo, perciò
; cresce l'errore relativo. Il bug della moltiplicazione (NOTA #08) non è la
; causa: con la ROM corretta i valori sono identici. La potenza (m_Power_*)
; passa da LOG ed EXP e ne eredita i limiti.
;
; Fonte: https://www.c64-wiki.com/wiki/LOG
;
;
; NOTA #12
; --------
; EXP(V) dà ?OVERFLOW per V oltre circa 88.03 (il wiki indica 89.03, ma
; EXP(89.02) dà già errore; EXP(88) = 1.65E38). Per argomenti molto negativi
; il risultato è 0 senza errore (provati -89 e -100). Il wiki dichiara un
; accordo col valore vero fino a 30 bit (26 per pochi ingressi); nelle nostre
; misure su 1500 ingressi casuali la mediana è 33.0 bit e il minimo 30.9.
; EXP(0) = 1. La potenza (m_Power_*) passa da LOG ed EXP: stessi limiti.
;
; Fonte: https://www.c64-wiki.com/wiki/EXP
;
;
; NOTA #13
; --------
; SIN riduce l'argomento a un quarto di periodo e valuta un polinomio. Il wiki
; dichiara un accordo col valore vero fino a 30 bit tra circa -2.6 e +2.6, con
; peggioramento oltre per l'imprecisione di PI (NOTA #17) e per pochi ingressi
; fino a 24 bit. Nelle nostre misure su 1500 ingressi casuali la mediana è
; 32.1 bit e il minimo 27.5. Per argomenti piccoli l'errore relativo sale: da
; 4E-11 per 0.04 a 3.4E-9 per 1E-4 (da 34 a 28 bit), perché i coefficienti del
; polinomio non sono esatti. Un argomento fuori dai limiti della virgola
; mobile dà ?OVERFLOW; SIN stessa non ne ha altri.
;
; Fonte: https://www.c64-wiki.com/wiki/SIN
;
;
; NOTA #14
; --------
; COS(V) è calcolata come SIN(V + PI/2): valgono quindi i limiti della NOTA
; #13 e il bug della moltiplicazione (NOTA #08). Il wiki dichiara un accordo
; col valore vero fino a 29 bit, con pochi ingressi a 24 e peggioramento
; vicino ai multipli dispari di PI/2. Nelle nostre misure su 1500 ingressi
; casuali la mediana è 31.8 bit e il minimo 27.7. La simmetria non è esatta:
; COS(0.9) - COS(-0.9) = -2 x 2^-32 (il wiki riporta 3 x 2^-32).
;
; Fonte: https://www.c64-wiki.com/wiki/COS
;
;
; NOTA #15
; --------
; TAN(V) è calcolata come SIN(V)/COS(V): eredita i limiti di entrambe e perde
; precisione dove le perdono loro. Il wiki dichiara un accordo di circa 29 bit
; (25 per pochi ingressi). Nelle nostre misure su 1500 ingressi casuali la
; mediana è 32.2 bit e il minimo 27.3. Se COS vale 0 la divisione dà ?DIVISION
; BY ZERO (il wiki cita TAN(PI/2)); questo è l'unico errore di TAN oltre a
; ?OVERFLOW. TAN(PI) non è esattamente 0: con PI arrotondato a 3.14159265359
; abbiamo misurato 0, il wiki riporta -7.3E-10.
;
; Fonte: https://www.c64-wiki.com/wiki/TAN
;
;
; NOTA #16
; --------
; ATN usa la simmetria dispari e, per |V| > 1, l'identità PI/2 - ATN(1/V); per
; 0 <= V <= 1 valuta un polinomio. Il wiki dichiara un accordo col valore vero
; fino a 30 bit (25 per pochi ingressi). Nelle nostre misure su 1500 ingressi
; casuali la mediana è 32.1 bit e il minimo 30.6. ATN non dà errori a parte
; ?OVERFLOW per argomenti fuori dai limiti della virgola mobile.
;
; Fonte: https://www.c64-wiki.com/wiki/ATN
;
;
; NOTA #17
; --------
; La costante PI della ROM (5 byte $82 $49 $0F $DA $A1 a $AEA8) vale
; 3.1415926525 invece di 3.1415926536: l'ultimo byte $A1 è meno preciso del
; valore più vicino, che si ottiene con $A2 (errore -1.2E-10 invece di
; -1.05E-9). 2*PI e PI/2, usate da SIN, COS e TAN, hanno invece l'ultimo byte
; $A2. Di conseguenza ATN(1)*4 dà 3.1415926525 (non 3.1415266 come riporta il
; wiki, che è sbagliato). Per usare il valore più vicino a pi greco si può
; caricare una propria costante ($82 $49 $0F $DA $A2).
;
; Fonte: https://www.c64-wiki.com/wiki/Pi
; ******************************************************************************

!source "../c64/errors.asm", once
!source "../c64/symbols.asm", once
!source "fp_common.asm", once
!source "fp_arith.asm", once
!source "fp_boolean.asm", once
!source "fp_compare.asm", once
!source "fp_constants.asm", once
!source "fp_error.asm", once
!source "fp_integers.asm", once
!source "fp_io.asm", once
!source "fp_memory.asm", once
!source "fp_poly.asm", once
!source "fp_power.asm", once
!source "fp_random.asm", once
!source "fp_transcend.asm", once
!source "fp_trig.asm", once
!source "fp_unary.asm", once

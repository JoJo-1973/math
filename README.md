# math

Matematica per il Commodore 64: aritmetica intera su valori da 8 a 32 bit (negazione, operazioni booleane, somma, sottrazione, scorrimenti e rotazioni, moltiplicazione e divisione intere con e senza segno) e aritmetica in virgola mobile nel formato MBF del BASIC Commodore, con macro basate sulle routine della ROM del BASIC. La libreria `math` fa parte della Libreria di Sistema (progetto `math.c64`) ed è scritta in assembly 6510 per C64Studio (sintassi ACME).

Questo documento deriva dai sorgenti. Per ogni dettaglio fanno fede i contratti d'interfaccia nelle intestazioni delle macro e delle subroutine.

Le utilità del modulo `fp.asm` sono 212: 211 macro e una subroutine (`FP_ERROR_HANDLER`). Le macro che hanno lo stesso contratto e differiscono per l'operando (per esempio `_ARG`, `_Mem` e `_Ptr`) sono descritte insieme in una scheda per famiglia: la parte comune del contratto è scritta una volta, e sotto ogni macro compaiono solo le differenze.

<a id="contenuto"></a>
## Contenuto

| Modulo | Utilità | Descrizione |
|---|---|---|
| [`fp.asm`](#modulo-fp) | [`m_Store_FAC_in_Scratch`](#utilita-m_store_fac_in_scratch) | Salva FAC nell'area di appoggio |
| | [`m_Store_ARG_in_Scratch`](#utilita-m_store_arg_in_scratch) | Salva ARG nell'area di appoggio |
| | [`m_Load_FAC_from_Scratch`](#utilita-m_load_fac_from_scratch) | Ripristina FAC dall'area di appoggio |
| | [`m_Load_ARG_from_Scratch`](#utilita-m_load_arg_from_scratch) | Ripristina ARG dall'area di appoggio |
| | [`m_Add_FAC_to_ARG`](#utilita-m_add_fac_to_arg) | Somma ARG a FAC |
| | [`m_Add_FAC_to_Mem`](#utilita-m_add_fac_to_mem) | Somma da indirizzo a FAC |
| | [`m_Add_FAC_to_Ptr`](#utilita-m_add_fac_to_ptr) | Somma da puntatore a FAC |
| | [`m_Subtract_FAC_from_ARG`](#utilita-m_subtract_fac_from_arg) | Sottrae FAC da ARG |
| | [`m_Subtract_FAC_from_Mem`](#utilita-m_subtract_fac_from_mem) | Sottrae FAC da indirizzo |
| | [`m_Subtract_FAC_from_Ptr`](#utilita-m_subtract_fac_from_ptr) | Sottrae FAC da puntatore |
| | [`m_Multiply_FAC_by_ARG`](#utilita-m_multiply_fac_by_arg) | Moltiplica FAC per ARG |
| | [`m_Multiply_FAC_by_Mem`](#utilita-m_multiply_fac_by_mem) | Moltiplica FAC per indirizzo |
| | [`m_Multiply_FAC_by_Ptr`](#utilita-m_multiply_fac_by_ptr) | Moltiplica FAC per puntatore |
| | [`m_Divide_ARG_by_FAC`](#utilita-m_divide_arg_by_fac) | Divide ARG per FAC |
| | [`m_Divide_Mem_by_FAC`](#utilita-m_divide_mem_by_fac) | Divide indirizzo per FAC |
| | [`m_Divide_Ptr_by_FAC`](#utilita-m_divide_ptr_by_fac) | Divide puntatore per FAC |
| | [`m_AND_FAC_with_ARG`](#utilita-m_and_fac_with_arg) | AND tra FAC e ARG |
| | [`m_AND_FAC_with_Mem`](#utilita-m_and_fac_with_mem) | AND tra FAC e indirizzo |
| | [`m_AND_FAC_with_Ptr`](#utilita-m_and_fac_with_ptr) | AND tra FAC e puntatore |
| | [`m_OR_FAC_with_ARG`](#utilita-m_or_fac_with_arg) | OR tra FAC e ARG |
| | [`m_OR_FAC_with_Mem`](#utilita-m_or_fac_with_mem) | OR tra FAC e indirizzo |
| | [`m_OR_FAC_with_Ptr`](#utilita-m_or_fac_with_ptr) | OR tra FAC e puntatore |
| | [`m_NOT_FAC`](#utilita-m_not_fac) | NOT di FAC |
| | [`m_NOT_ARG`](#utilita-m_not_arg) | NOT di ARG, sul posto |
| | [`m_NOT_Mem`](#utilita-m_not_mem) | NOT da indirizzo |
| | [`m_NOT_Ptr`](#utilita-m_not_ptr) | NOT da puntatore |
| | [`m_Compare_FAC_to_ARG`](#utilita-m_compare_fac_to_arg) | Confronta FAC con ARG |
| | [`m_Compare_FAC_to_Mem`](#utilita-m_compare_fac_to_mem) | Confronta FAC con indirizzo |
| | [`m_Compare_FAC_to_Ptr`](#utilita-m_compare_fac_to_ptr) | Confronta FAC con puntatore |
| | [`m_Load_FAC_with`](#utilita-m_load_fac_with) | Carica FAC con 5 byte MBF |
| | [`m_Load_ARG_with`](#utilita-m_load_arg_with) | Carica ARG con 5 byte MBF |
| | [`m_Load_FAC_with_0`](#utilita-m_load_fac_with_0) | Carica FAC con 0 |
| | [`m_Load_FAC_with_0_25`](#utilita-m_load_fac_with_0_25) | Carica FAC con 0.25 |
| | [`m_Load_FAC_with_0_5`](#utilita-m_load_fac_with_0_5) | Carica FAC con 0.5 |
| | [`m_Load_FAC_with_1`](#utilita-m_load_fac_with_1) | Carica FAC con 1 |
| | [`m_Load_FAC_with_MINUS_1`](#utilita-m_load_fac_with_minus_1) | Carica FAC con -1 |
| | [`m_Load_FAC_with_2`](#utilita-m_load_fac_with_2) | Carica FAC con 2 |
| | [`m_Load_FAC_with_10`](#utilita-m_load_fac_with_10) | Carica FAC con 10 |
| | [`m_Load_FAC_with_0_1`](#utilita-m_load_fac_with_0_1) | Carica FAC con 0.1 |
| | [`m_Load_FAC_with_PI4`](#utilita-m_load_fac_with_pi4) | Carica FAC con π/4 |
| | [`m_Load_FAC_with_PI2`](#utilita-m_load_fac_with_pi2) | Carica FAC con π/2 |
| | [`m_Load_FAC_with_PI`](#utilita-m_load_fac_with_pi) | Carica FAC con π |
| | [`m_Load_FAC_with_2PI`](#utilita-m_load_fac_with_2pi) | Carica FAC con 2π |
| | [`m_Load_FAC_with_PI180`](#utilita-m_load_fac_with_pi180) | Carica FAC con π/180 |
| | [`m_Load_FAC_with_PI200`](#utilita-m_load_fac_with_pi200) | Carica FAC con π/200 |
| | [`m_Load_FAC_with_180PI`](#utilita-m_load_fac_with_180pi) | Carica FAC con 180/π |
| | [`m_Load_FAC_with_200PI`](#utilita-m_load_fac_with_200pi) | Carica FAC con 200/π |
| | [`m_Load_FAC_with_SQR2`](#utilita-m_load_fac_with_sqr2) | Carica FAC con √2 |
| | [`m_Load_FAC_with_SQR3`](#utilita-m_load_fac_with_sqr3) | Carica FAC con √3 |
| | [`m_Load_FAC_with_e`](#utilita-m_load_fac_with_e) | Carica FAC con e |
| | [`m_Load_FAC_with_LOG2`](#utilita-m_load_fac_with_log2) | Carica FAC con ln 2 |
| | [`m_Load_FAC_with_LOG10`](#utilita-m_load_fac_with_log10) | Carica FAC con ln 10 |
| | [`m_Load_FAC_with_eps`](#utilita-m_load_fac_with_eps) | Carica FAC con eps |
| | [`m_Load_FAC_with_MINR`](#utilita-m_load_fac_with_minr) | Carica FAC con MINR |
| | [`m_Load_FAC_with_MAXR`](#utilita-m_load_fac_with_maxr) | Carica FAC con MAXR |
| | [`m_Load_ARG_with_0`](#utilita-m_load_arg_with_0) | Carica ARG con 0 |
| | [`m_Load_ARG_with_0_25`](#utilita-m_load_arg_with_0_25) | Carica ARG con 0.25 |
| | [`m_Load_ARG_with_0_5`](#utilita-m_load_arg_with_0_5) | Carica ARG con 0.5 |
| | [`m_Load_ARG_with_1`](#utilita-m_load_arg_with_1) | Carica ARG con 1 |
| | [`m_Load_ARG_with_MINUS_1`](#utilita-m_load_arg_with_minus_1) | Carica ARG con -1 |
| | [`m_Load_ARG_with_2`](#utilita-m_load_arg_with_2) | Carica ARG con 2 |
| | [`m_Load_ARG_with_10`](#utilita-m_load_arg_with_10) | Carica ARG con 10 |
| | [`m_Load_ARG_with_0_1`](#utilita-m_load_arg_with_0_1) | Carica ARG con 0.1 |
| | [`m_Load_ARG_with_PI4`](#utilita-m_load_arg_with_pi4) | Carica ARG con π/4 |
| | [`m_Load_ARG_with_PI2`](#utilita-m_load_arg_with_pi2) | Carica ARG con π/2 |
| | [`m_Load_ARG_with_PI`](#utilita-m_load_arg_with_pi) | Carica ARG con π |
| | [`m_Load_ARG_with_2PI`](#utilita-m_load_arg_with_2pi) | Carica ARG con 2π |
| | [`m_Load_ARG_with_PI180`](#utilita-m_load_arg_with_pi180) | Carica ARG con π/180 |
| | [`m_Load_ARG_with_PI200`](#utilita-m_load_arg_with_pi200) | Carica ARG con π/200 |
| | [`m_Load_ARG_with_180PI`](#utilita-m_load_arg_with_180pi) | Carica ARG con 180/π |
| | [`m_Load_ARG_with_200PI`](#utilita-m_load_arg_with_200pi) | Carica ARG con 200/π |
| | [`m_Load_ARG_with_SQR2`](#utilita-m_load_arg_with_sqr2) | Carica ARG con √2 |
| | [`m_Load_ARG_with_SQR3`](#utilita-m_load_arg_with_sqr3) | Carica ARG con √3 |
| | [`m_Load_ARG_with_e`](#utilita-m_load_arg_with_e) | Carica ARG con e |
| | [`m_Load_ARG_with_LOG2`](#utilita-m_load_arg_with_log2) | Carica ARG con ln 2 |
| | [`m_Load_ARG_with_LOG10`](#utilita-m_load_arg_with_log10) | Carica ARG con ln 10 |
| | [`m_Load_ARG_with_eps`](#utilita-m_load_arg_with_eps) | Carica ARG con eps |
| | [`m_Load_ARG_with_MINR`](#utilita-m_load_arg_with_minr) | Carica ARG con MINR |
| | [`m_Load_ARG_with_MAXR`](#utilita-m_load_arg_with_maxr) | Carica ARG con MAXR |
| | [`FP_ERROR_HANDLER`](#utilita-fp_error_handler) | Gestore delle tre condizioni d'errore |
| | [`m_Load_FAC_with_UINT8`](#utilita-m_load_fac_with_uint8) | Carica FAC con UINT8 costante |
| | [`m_Load_FAC_with_UINT8_Mem`](#utilita-m_load_fac_with_uint8_mem) | Carica FAC con UINT8 da indirizzo |
| | [`m_Load_FAC_with_UINT8_Ptr`](#utilita-m_load_fac_with_uint8_ptr) | Carica FAC con UINT8 da puntatore |
| | [`m_Load_ARG_with_UINT8`](#utilita-m_load_arg_with_uint8) | Carica ARG con UINT8 costante |
| | [`m_Load_ARG_with_UINT8_Mem`](#utilita-m_load_arg_with_uint8_mem) | Carica ARG con UINT8 da indirizzo |
| | [`m_Load_ARG_with_UINT8_Ptr`](#utilita-m_load_arg_with_uint8_ptr) | Carica ARG con UINT8 da puntatore |
| | [`m_Load_FAC_with_INT8`](#utilita-m_load_fac_with_int8) | Carica FAC con INT8 costante |
| | [`m_Load_FAC_with_INT8_Mem`](#utilita-m_load_fac_with_int8_mem) | Carica FAC con INT8 da indirizzo |
| | [`m_Load_FAC_with_INT8_Ptr`](#utilita-m_load_fac_with_int8_ptr) | Carica FAC con INT8 da puntatore |
| | [`m_Load_ARG_with_INT8`](#utilita-m_load_arg_with_int8) | Carica ARG con INT8 costante |
| | [`m_Load_ARG_with_INT8_Mem`](#utilita-m_load_arg_with_int8_mem) | Carica ARG con INT8 da indirizzo |
| | [`m_Load_ARG_with_INT8_Ptr`](#utilita-m_load_arg_with_int8_ptr) | Carica ARG con INT8 da puntatore |
| | [`m_Load_FAC_with_UINT16`](#utilita-m_load_fac_with_uint16) | Carica FAC con UINT16 costante |
| | [`m_Load_FAC_with_UINT16_Mem`](#utilita-m_load_fac_with_uint16_mem) | Carica FAC con UINT16 da indirizzo |
| | [`m_Load_FAC_with_UINT16_Ptr`](#utilita-m_load_fac_with_uint16_ptr) | Carica FAC con UINT16 da puntatore |
| | [`m_Load_ARG_with_UINT16`](#utilita-m_load_arg_with_uint16) | Carica ARG con UINT16 costante |
| | [`m_Load_ARG_with_UINT16_Mem`](#utilita-m_load_arg_with_uint16_mem) | Carica ARG con UINT16 da indirizzo |
| | [`m_Load_ARG_with_UINT16_Ptr`](#utilita-m_load_arg_with_uint16_ptr) | Carica ARG con UINT16 da puntatore |
| | [`m_Load_FAC_with_INT16`](#utilita-m_load_fac_with_int16) | Carica FAC con INT16 costante |
| | [`m_Load_FAC_with_INT16_Mem`](#utilita-m_load_fac_with_int16_mem) | Carica FAC con INT16 da indirizzo |
| | [`m_Load_FAC_with_INT16_Ptr`](#utilita-m_load_fac_with_int16_ptr) | Carica FAC con INT16 da puntatore |
| | [`m_Load_ARG_with_INT16`](#utilita-m_load_arg_with_int16) | Carica ARG con INT16 costante |
| | [`m_Load_ARG_with_INT16_Mem`](#utilita-m_load_arg_with_int16_mem) | Carica ARG con INT16 da indirizzo |
| | [`m_Load_ARG_with_INT16_Ptr`](#utilita-m_load_arg_with_int16_ptr) | Carica ARG con INT16 da puntatore |
| | [`m_Load_FAC_with_UINT24`](#utilita-m_load_fac_with_uint24) | Carica FAC con UINT24 costante |
| | [`m_Load_FAC_with_UINT24_Mem`](#utilita-m_load_fac_with_uint24_mem) | Carica FAC con UINT24 da indirizzo |
| | [`m_Load_FAC_with_UINT24_Ptr`](#utilita-m_load_fac_with_uint24_ptr) | Carica FAC con UINT24 da puntatore |
| | [`m_Load_ARG_with_UINT24`](#utilita-m_load_arg_with_uint24) | Carica ARG con UINT24 costante |
| | [`m_Load_ARG_with_UINT24_Mem`](#utilita-m_load_arg_with_uint24_mem) | Carica ARG con UINT24 da indirizzo |
| | [`m_Load_ARG_with_UINT24_Ptr`](#utilita-m_load_arg_with_uint24_ptr) | Carica ARG con UINT24 da puntatore |
| | [`m_Load_FAC_with_INT24`](#utilita-m_load_fac_with_int24) | Carica FAC con INT24 costante |
| | [`m_Load_FAC_with_INT24_Mem`](#utilita-m_load_fac_with_int24_mem) | Carica FAC con INT24 da indirizzo |
| | [`m_Load_FAC_with_INT24_Ptr`](#utilita-m_load_fac_with_int24_ptr) | Carica FAC con INT24 da puntatore |
| | [`m_Load_ARG_with_INT24`](#utilita-m_load_arg_with_int24) | Carica ARG con INT24 costante |
| | [`m_Load_ARG_with_INT24_Mem`](#utilita-m_load_arg_with_int24_mem) | Carica ARG con INT24 da indirizzo |
| | [`m_Load_ARG_with_INT24_Ptr`](#utilita-m_load_arg_with_int24_ptr) | Carica ARG con INT24 da puntatore |
| | [`m_Load_FAC_with_UINT32`](#utilita-m_load_fac_with_uint32) | Carica FAC con UINT32 costante |
| | [`m_Load_FAC_with_UINT32_Mem`](#utilita-m_load_fac_with_uint32_mem) | Carica FAC con UINT32 da indirizzo |
| | [`m_Load_FAC_with_UINT32_Ptr`](#utilita-m_load_fac_with_uint32_ptr) | Carica FAC con UINT32 da puntatore |
| | [`m_Load_ARG_with_UINT32`](#utilita-m_load_arg_with_uint32) | Carica ARG con UINT32 costante |
| | [`m_Load_ARG_with_UINT32_Mem`](#utilita-m_load_arg_with_uint32_mem) | Carica ARG con UINT32 da indirizzo |
| | [`m_Load_ARG_with_UINT32_Ptr`](#utilita-m_load_arg_with_uint32_ptr) | Carica ARG con UINT32 da puntatore |
| | [`m_Load_FAC_with_INT32`](#utilita-m_load_fac_with_int32) | Carica FAC con INT32 costante |
| | [`m_Load_FAC_with_INT32_Mem`](#utilita-m_load_fac_with_int32_mem) | Carica FAC con INT32 da indirizzo |
| | [`m_Load_FAC_with_INT32_Ptr`](#utilita-m_load_fac_with_int32_ptr) | Carica FAC con INT32 da puntatore |
| | [`m_Load_ARG_with_INT32`](#utilita-m_load_arg_with_int32) | Carica ARG con INT32 costante |
| | [`m_Load_ARG_with_INT32_Mem`](#utilita-m_load_arg_with_int32_mem) | Carica ARG con INT32 da indirizzo |
| | [`m_Load_ARG_with_INT32_Ptr`](#utilita-m_load_arg_with_int32_ptr) | Carica ARG con INT32 da puntatore |
| | [`m_Convert_FAC_into_INT32`](#utilita-m_convert_fac_into_int32) | Converte FAC in INT32 |
| | [`m_Convert_ARG_into_INT32`](#utilita-m_convert_arg_into_int32) | Converte ARG in INT32 |
| | [`m_FAC_to_String`](#utilita-m_fac_to_string) | Da FAC a stringa |
| | [`m_ARG_to_String`](#utilita-m_arg_to_string) | Da ARG a stringa |
| | [`m_String_to_FAC`](#utilita-m_string_to_fac) | Da stringa a FAC |
| | [`m_String_to_ARG`](#utilita-m_string_to_arg) | Da stringa a ARG |
| | [`m_Print_FAC`](#utilita-m_print_fac) | Stampa FAC |
| | [`m_Print_ARG`](#utilita-m_print_arg) | Stampa ARG |
| | [`m_Load_FAC_from_Mem`](#utilita-m_load_fac_from_mem) | Carica FAC da un indirizzo assoluto |
| | [`m_Load_FAC_from_Ptr`](#utilita-m_load_fac_from_ptr) | Carica FAC da un indirizzo puntato |
| | [`m_Load_ARG_from_Mem`](#utilita-m_load_arg_from_mem) | Carica ARG da un indirizzo assoluto |
| | [`m_Load_ARG_from_Ptr`](#utilita-m_load_arg_from_ptr) | Carica ARG da un indirizzo puntato |
| | [`m_Store_FAC_to_Mem`](#utilita-m_store_fac_to_mem) | Scrive FAC a un indirizzo assoluto |
| | [`m_Store_FAC_to_Ptr`](#utilita-m_store_fac_to_ptr) | Scrive FAC a un indirizzo puntato |
| | [`m_Store_ARG_to_Mem`](#utilita-m_store_arg_to_mem) | Scrive ARG a un indirizzo assoluto |
| | [`m_Store_ARG_to_Ptr`](#utilita-m_store_arg_to_ptr) | Scrive ARG a un indirizzo puntato |
| | [`m_Transfer_FAC_to_ARG`](#utilita-m_transfer_fac_to_arg) | Copia FAC in ARG |
| | [`m_Transfer_ARG_to_FAC`](#utilita-m_transfer_arg_to_fac) | Copia ARG in FAC |
| | [`m_Swap_FAC_and_ARG`](#utilita-m_swap_fac_and_arg) | Scambia FAC e ARG |
| | [`m_Poly_Mem`](#utilita-m_poly_mem) | Polinomio, tabella a indirizzo |
| | [`m_Poly_Ptr`](#utilita-m_poly_ptr) | Polinomio, tabella da puntatore |
| | [`m_Odd_Poly_Mem`](#utilita-m_odd_poly_mem) | Polinomio dispari, tabella a indirizzo |
| | [`m_Odd_Poly_Ptr`](#utilita-m_odd_poly_ptr) | Polinomio dispari, tabella da puntatore |
| | [`m_Power_ARG_to_FAC`](#utilita-m_power_arg_to_fac) | ARG elevato a FAC |
| | [`m_Power_Mem_to_FAC`](#utilita-m_power_mem_to_fac) | Indirizzo elevato a FAC |
| | [`m_Power_Ptr_to_FAC`](#utilita-m_power_ptr_to_fac) | Puntatore elevato a FAC |
| | [`m_SQR_FAC`](#utilita-m_sqr_fac) | Radice quadrata di FAC |
| | [`m_SQR_ARG`](#utilita-m_sqr_arg) | Radice quadrata di ARG |
| | [`m_SQR_Mem`](#utilita-m_sqr_mem) | Radice da indirizzo |
| | [`m_SQR_Ptr`](#utilita-m_sqr_ptr) | Radice da puntatore |
| | [`m_Load_FAC_with_RND`](#utilita-m_load_fac_with_rnd) | Numero casuale in FAC |
| | [`m_Randomize`](#utilita-m_randomize) | Inizializza il generatore |
| | [`m_LOG_FAC`](#utilita-m_log_fac) | Logaritmo di FAC |
| | [`m_LOG_ARG`](#utilita-m_log_arg) | Logaritmo di ARG |
| | [`m_LOG_Mem`](#utilita-m_log_mem) | Logaritmo da indirizzo |
| | [`m_LOG_Ptr`](#utilita-m_log_ptr) | Logaritmo da puntatore |
| | [`m_EXP_FAC`](#utilita-m_exp_fac) | Esponenziale di FAC |
| | [`m_EXP_ARG`](#utilita-m_exp_arg) | Esponenziale di ARG |
| | [`m_EXP_Mem`](#utilita-m_exp_mem) | Esponenziale da indirizzo |
| | [`m_EXP_Ptr`](#utilita-m_exp_ptr) | Esponenziale da puntatore |
| | [`m_SIN_FAC`](#utilita-m_sin_fac) | Seno di FAC |
| | [`m_SIN_ARG`](#utilita-m_sin_arg) | Seno di ARG |
| | [`m_SIN_Mem`](#utilita-m_sin_mem) | Seno da indirizzo |
| | [`m_SIN_Ptr`](#utilita-m_sin_ptr) | Seno da puntatore |
| | [`m_COS_FAC`](#utilita-m_cos_fac) | Coseno di FAC |
| | [`m_COS_ARG`](#utilita-m_cos_arg) | Coseno di ARG |
| | [`m_COS_Mem`](#utilita-m_cos_mem) | Coseno da indirizzo |
| | [`m_COS_Ptr`](#utilita-m_cos_ptr) | Coseno da puntatore |
| | [`m_TAN_FAC`](#utilita-m_tan_fac) | Tangente di FAC |
| | [`m_TAN_ARG`](#utilita-m_tan_arg) | Tangente di ARG |
| | [`m_TAN_Mem`](#utilita-m_tan_mem) | Tangente da indirizzo |
| | [`m_TAN_Ptr`](#utilita-m_tan_ptr) | Tangente da puntatore |
| | [`m_ATN_FAC`](#utilita-m_atn_fac) | Arcotangente di FAC |
| | [`m_ATN_ARG`](#utilita-m_atn_arg) | Arcotangente di ARG |
| | [`m_ATN_Mem`](#utilita-m_atn_mem) | Arcotangente da indirizzo |
| | [`m_ATN_Ptr`](#utilita-m_atn_ptr) | Arcotangente da puntatore |
| | [`m_Negate_FAC`](#utilita-m_negate_fac) | Cambia il segno di FAC |
| | [`m_Negate_ARG`](#utilita-m_negate_arg) | Cambia il segno di ARG |
| | [`m_Negate_Mem`](#utilita-m_negate_mem) | Nega da indirizzo, in FAC |
| | [`m_Negate_Ptr`](#utilita-m_negate_ptr) | Nega da puntatore, in FAC |
| | [`m_ABS_FAC`](#utilita-m_abs_fac) | Valore assoluto di FAC |
| | [`m_ABS_ARG`](#utilita-m_abs_arg) | Valore assoluto di ARG |
| | [`m_ABS_Mem`](#utilita-m_abs_mem) | Valore assoluto da indirizzo |
| | [`m_ABS_Ptr`](#utilita-m_abs_ptr) | Valore assoluto da puntatore |
| | [`m_Sign_FAC`](#utilita-m_sign_fac) | Segno di FAC in .A |
| | [`m_Sign_ARG`](#utilita-m_sign_arg) | Segno di ARG in .A |
| | [`m_Sign_Mem`](#utilita-m_sign_mem) | Segno da indirizzo, in .A |
| | [`m_Sign_Ptr`](#utilita-m_sign_ptr) | Segno da puntatore, in .A |
| | [`m_SGN_FAC`](#utilita-m_sgn_fac) | FAC diventa il suo segno |
| | [`m_SGN_ARG`](#utilita-m_sgn_arg) | ARG diventa il suo segno |
| | [`m_SGN_Mem`](#utilita-m_sgn_mem) | Segno da indirizzo, in FAC |
| | [`m_SGN_Ptr`](#utilita-m_sgn_ptr) | Segno da puntatore, in FAC |
| | [`m_INT_FAC`](#utilita-m_int_fac) | Arrotonda FAC per difetto |
| | [`m_INT_ARG`](#utilita-m_int_arg) | Arrotonda ARG per difetto |
| | [`m_INT_Mem`](#utilita-m_int_mem) | Arrotonda da indirizzo, in FAC |
| | [`m_INT_Ptr`](#utilita-m_int_ptr) | Arrotonda da puntatore, in FAC |
| | [`m_Multiply_FAC_by_2`](#utilita-m_multiply_fac_by_2) | Moltiplica FAC per 2 |
| | [`m_Multiply_ARG_by_2`](#utilita-m_multiply_arg_by_2) | Moltiplica ARG per 2 |
| | [`m_Multiply_Mem_by_2`](#utilita-m_multiply_mem_by_2) | Per 2 da indirizzo, in FAC |
| | [`m_Multiply_Ptr_by_2`](#utilita-m_multiply_ptr_by_2) | Per 2 da puntatore, in FAC |
| | [`m_Divide_FAC_by_2`](#utilita-m_divide_fac_by_2) | Divide FAC per 2 |
| | [`m_Divide_ARG_by_2`](#utilita-m_divide_arg_by_2) | Divide ARG per 2 |
| | [`m_Divide_Mem_by_2`](#utilita-m_divide_mem_by_2) | Diviso 2 da indirizzo, in FAC |
| | [`m_Divide_Ptr_by_2`](#utilita-m_divide_ptr_by_2) | Diviso 2 da puntatore, in FAC |
| [`math8.asm`](#modulo-math8) | [`m_Neg`](#utilita-m_neg) | Nega un valore a 8 bit |
| | [`m_Not`](#utilita-m_not) | NOT booleano di un valore a 8 bit |
| | [`m_AslS`](#utilita-m_asls) | Scorrimento aritmetico a sinistra con segno |
| | [`m_AsrS`](#utilita-m_asrs) | Scorrimento aritmetico a destra con segno |
| | [`m_Rl8`](#utilita-m_rl8) | Rotazione a sinistra senza passare per il Carry |
| | [`m_Rr8`](#utilita-m_rr8) | Rotazione a destra senza passare per il Carry |
| [`math16.asm`](#modulo-math16) | [`m_Asl16`](#utilita-m_asl16) | Scorrimento a sinistra di un valore a 16 bit |
| | [`m_Add16`](#utilita-m_add16) | Somma due valori a 16 bit |
| | [`m_Sub16`](#utilita-m_sub16) | Sottrae due valori a 16 bit |
| | [`m_Neg16`](#utilita-m_neg16) | Nega un valore a 16 bit |
| | [`m_Not16`](#utilita-m_not16) | NOT booleano di un valore a 16 bit |
| | [`m_And16`](#utilita-m_and16) | AND booleano di due valori a 16 bit |
| | [`m_Ora16`](#utilita-m_ora16) | OR booleano di due valori a 16 bit |
| | [`m_Eor16`](#utilita-m_eor16) | EOR booleano di due valori a 16 bit |
| | [`m_AslS16`](#utilita-m_asls16) | Scorrimento a sinistra con segno, segnala V |
| | [`m_Lsr16`](#utilita-m_lsr16) | Scorrimento logico a destra a 16 bit |
| | [`m_AsrS16`](#utilita-m_asrs16) | Scorrimento aritmetico a destra con segno |
| | [`m_Rol16`](#utilita-m_rol16) | Rotazione a sinistra attraverso il Carry |
| | [`m_Rl16`](#utilita-m_rl16) | Rotazione a sinistra senza passare per il Carry |
| | [`m_Ror16`](#utilita-m_ror16) | Rotazione a destra attraverso il Carry |
| | [`m_Rr16`](#utilita-m_rr16) | Rotazione a destra senza passare per il Carry |
| [`math24.asm`](#modulo-math24) | [`m_Asl24`](#utilita-m_asl24) | Scorrimento a sinistra di un valore a 24 bit |
| | [`m_Add24`](#utilita-m_add24) | Somma due valori a 24 bit |
| | [`m_Sub24`](#utilita-m_sub24) | Sottrae due valori a 24 bit |
| | [`m_Neg24`](#utilita-m_neg24) | Nega un valore a 24 bit |
| | [`m_Not24`](#utilita-m_not24) | NOT booleano di un valore a 24 bit |
| | [`m_And24`](#utilita-m_and24) | AND booleano di due valori a 24 bit |
| | [`m_Ora24`](#utilita-m_ora24) | OR booleano di due valori a 24 bit |
| | [`m_Eor24`](#utilita-m_eor24) | EOR booleano di due valori a 24 bit |
| | [`m_AslS24`](#utilita-m_asls24) | Scorrimento a sinistra con segno, segnala V |
| | [`m_Lsr24`](#utilita-m_lsr24) | Scorrimento logico a destra a 24 bit |
| | [`m_AsrS24`](#utilita-m_asrs24) | Scorrimento aritmetico a destra con segno |
| | [`m_Rol24`](#utilita-m_rol24) | Rotazione a sinistra attraverso il Carry |
| | [`m_Rl24`](#utilita-m_rl24) | Rotazione a sinistra senza passare per il Carry |
| | [`m_Ror24`](#utilita-m_ror24) | Rotazione a destra attraverso il Carry |
| | [`m_Rr24`](#utilita-m_rr24) | Rotazione a destra senza passare per il Carry |
| [`math32.asm`](#modulo-math32) | [`m_Asl32`](#utilita-m_asl32) | Scorrimento a sinistra di un valore a 32 bit |
| | [`m_Add32`](#utilita-m_add32) | Somma due valori a 32 bit |
| | [`m_Sub32`](#utilita-m_sub32) | Sottrae due valori a 32 bit |
| | [`m_Neg32`](#utilita-m_neg32) | Nega un valore a 32 bit |
| | [`m_Not32`](#utilita-m_not32) | NOT booleano di un valore a 32 bit |
| | [`m_And32`](#utilita-m_and32) | AND booleano di due valori a 32 bit |
| | [`m_Ora32`](#utilita-m_ora32) | OR booleano di due valori a 32 bit |
| | [`m_Eor32`](#utilita-m_eor32) | EOR booleano di due valori a 32 bit |
| | [`m_AslS32`](#utilita-m_asls32) | Scorrimento a sinistra con segno, segnala V |
| | [`m_Lsr32`](#utilita-m_lsr32) | Scorrimento logico a destra a 32 bit |
| | [`m_AsrS32`](#utilita-m_asrs32) | Scorrimento aritmetico a destra con segno |
| | [`m_Rol32`](#utilita-m_rol32) | Rotazione a sinistra attraverso il Carry |
| | [`m_Rl32`](#utilita-m_rl32) | Rotazione a sinistra senza passare per il Carry |
| | [`m_Ror32`](#utilita-m_ror32) | Rotazione a destra attraverso il Carry |
| | [`m_Rr32`](#utilita-m_rr32) | Rotazione a destra senza passare per il Carry |
| [`math_mult.asm`](#modulo-math_mult) | [`m_Mul_Negate`](#utilita-m_mul_negate) | Nega un valore a più byte in pagina zero |
| | [`m_Mul_Stage`](#utilita-m_mul_stage) | Elabora un byte del moltiplicatore |
| | [`m_Mul_Core`](#utilita-m_mul_core) | Nucleo generico senza segno |
| | [`m_Mul_Core_8x8`](#utilita-m_mul_core_8x8) | Nucleo senza segno 8x8 bit |
| | [`m_Mul_Core_16x8`](#utilita-m_mul_core_16x8) | Nucleo senza segno 16x8 bit |
| | [`m_Mul_Core_24x8`](#utilita-m_mul_core_24x8) | Nucleo senza segno 24x8 bit |
| | [`m_Mul_Core_32x8`](#utilita-m_mul_core_32x8) | Nucleo senza segno 32x8 bit |
| | [`m_Mul_Core_16x16`](#utilita-m_mul_core_16x16) | Nucleo senza segno 16x16 bit |
| | [`m_Mul_Core_24x16`](#utilita-m_mul_core_24x16) | Nucleo senza segno 24x16 bit |
| | [`m_Mul_Core_32x16`](#utilita-m_mul_core_32x16) | Nucleo senza segno 32x16 bit |
| | [`m_Mul_Core_24x24`](#utilita-m_mul_core_24x24) | Nucleo senza segno 24x24 bit |
| | [`m_Mul_Core_32x24`](#utilita-m_mul_core_32x24) | Nucleo senza segno 32x24 bit |
| | [`m_Mul_Core_32x32`](#utilita-m_mul_core_32x32) | Nucleo senza segno 32x32 bit |
| | [`MUL_8X8`](#utilita-mul_8x8) | Prodotto 8x8 bit senza segno |
| | [`SMUL_8X8`](#utilita-smul_8x8) | Prodotto 8x8 bit con segno |
| | [`MUL_16X8`](#utilita-mul_16x8) | Prodotto 16x8 bit senza segno |
| | [`SMUL_16X8`](#utilita-smul_16x8) | Prodotto 16x8 bit con segno |
| | [`MUL_24X8`](#utilita-mul_24x8) | Prodotto 24x8 bit senza segno |
| | [`SMUL_24X8`](#utilita-smul_24x8) | Prodotto 24x8 bit con segno |
| | [`MUL_32X8`](#utilita-mul_32x8) | Prodotto 32x8 bit senza segno |
| | [`SMUL_32X8`](#utilita-smul_32x8) | Prodotto 32x8 bit con segno |
| | [`MUL_16X16`](#utilita-mul_16x16) | Prodotto 16x16 bit senza segno |
| | [`SMUL_16X16`](#utilita-smul_16x16) | Prodotto 16x16 bit con segno |
| | [`MUL_24X16`](#utilita-mul_24x16) | Prodotto 24x16 bit senza segno |
| | [`SMUL_24X16`](#utilita-smul_24x16) | Prodotto 24x16 bit con segno |
| | [`MUL_32X16`](#utilita-mul_32x16) | Prodotto 32x16 bit senza segno |
| | [`SMUL_32X16`](#utilita-smul_32x16) | Prodotto 32x16 bit con segno |
| | [`MUL_24X24`](#utilita-mul_24x24) | Prodotto 24x24 bit senza segno |
| | [`SMUL_24X24`](#utilita-smul_24x24) | Prodotto 24x24 bit con segno |
| | [`MUL_32X24`](#utilita-mul_32x24) | Prodotto 32x24 bit senza segno |
| | [`SMUL_32X24`](#utilita-smul_32x24) | Prodotto 32x24 bit con segno |
| | [`MUL_32X32`](#utilita-mul_32x32) | Prodotto 32x32 bit senza segno |
| | [`SMUL_32X32`](#utilita-smul_32x32) | Prodotto 32x32 bit con segno |
| [`math_div.asm`](#modulo-math_div) | [`m_Div_Negate`](#utilita-m_div_negate) | Nega un valore a più byte in pagina zero |
| | [`m_Div_Roll`](#utilita-m_div_roll) | Fa scorrere a sinistra un valore a più byte |
| | [`m_Div_Core_Byte`](#utilita-m_div_core_byte) | Nucleo senza segno con divisore a 8 bit |
| | [`m_Div_Core_Multi`](#utilita-m_div_core_multi) | Nucleo senza segno con divisore a più byte |
| | [`m_Div_Core_8x8`](#utilita-m_div_core_8x8) | Nucleo senza segno 8x8 bit |
| | [`m_Div_Core_16x8`](#utilita-m_div_core_16x8) | Nucleo senza segno 16x8 bit |
| | [`m_Div_Core_24x8`](#utilita-m_div_core_24x8) | Nucleo senza segno 24x8 bit |
| | [`m_Div_Core_32x8`](#utilita-m_div_core_32x8) | Nucleo senza segno 32x8 bit |
| | [`m_Div_Core_16x16`](#utilita-m_div_core_16x16) | Nucleo senza segno 16x16 bit |
| | [`m_Div_Core_24x16`](#utilita-m_div_core_24x16) | Nucleo senza segno 24x16 bit |
| | [`m_Div_Core_32x16`](#utilita-m_div_core_32x16) | Nucleo senza segno 32x16 bit |
| | [`m_Div_Core_24x24`](#utilita-m_div_core_24x24) | Nucleo senza segno 24x24 bit |
| | [`m_Div_Core_32x24`](#utilita-m_div_core_32x24) | Nucleo senza segno 32x24 bit |
| | [`m_Div_Core_32x32`](#utilita-m_div_core_32x32) | Nucleo senza segno 32x32 bit |
| | [`DIV_8X8`](#utilita-div_8x8) | Divisione 8x8 bit senza segno |
| | [`SDIV_8X8`](#utilita-sdiv_8x8) | Divisione 8x8 bit con segno |
| | [`DIV_16X8`](#utilita-div_16x8) | Divisione 16x8 bit senza segno |
| | [`SDIV_16X8`](#utilita-sdiv_16x8) | Divisione 16x8 bit con segno |
| | [`DIV_24X8`](#utilita-div_24x8) | Divisione 24x8 bit senza segno |
| | [`SDIV_24X8`](#utilita-sdiv_24x8) | Divisione 24x8 bit con segno |
| | [`DIV_32X8`](#utilita-div_32x8) | Divisione 32x8 bit senza segno |
| | [`SDIV_32X8`](#utilita-sdiv_32x8) | Divisione 32x8 bit con segno |
| | [`DIV_16X16`](#utilita-div_16x16) | Divisione 16x16 bit senza segno |
| | [`SDIV_16X16`](#utilita-sdiv_16x16) | Divisione 16x16 bit con segno |
| | [`DIV_24X16`](#utilita-div_24x16) | Divisione 24x16 bit senza segno |
| | [`SDIV_24X16`](#utilita-sdiv_24x16) | Divisione 24x16 bit con segno |
| | [`DIV_32X16`](#utilita-div_32x16) | Divisione 32x16 bit senza segno |
| | [`SDIV_32X16`](#utilita-sdiv_32x16) | Divisione 32x16 bit con segno |
| | [`DIV_24X24`](#utilita-div_24x24) | Divisione 24x24 bit senza segno |
| | [`SDIV_24X24`](#utilita-sdiv_24x24) | Divisione 24x24 bit con segno |
| | [`DIV_32X24`](#utilita-div_32x24) | Divisione 32x24 bit senza segno |
| | [`SDIV_32X24`](#utilita-sdiv_32x24) | Divisione 32x24 bit con segno |
| | [`DIV_32X32`](#utilita-div_32x32) | Divisione 32x32 bit senza segno |
| | [`SDIV_32X32`](#utilita-sdiv_32x32) | Divisione 32x32 bit con segno |

## Uso

### Inclusione

La cartella `math` sta nella cartella delle librerie di C64Studio, accanto alle altre librerie di sistema. Il sorgente principale del programma include i moduli che usa nella parte dedicata al codice:

```
!source <math/fp.asm>, once
!source <math/math16.asm>, once
!source <math/math_mult.asm>, once
```

`fp.asm` contiene solo l'intestazione, le note d'uso e le righe `!source` degli altri moduli e dei file di simboli `<c64/symbols.asm>` e `<system/errors.asm>`: il programma non deve includere altro. Le macro dei moduli si assemblano solo quando vengono invocate, con `+nome`, seguito dai parametri se ne hanno.

Ogni modulo include da sé i file di cui ha bisogno (`<mem/mem16.asm>`, `<c64/symbols.asm>` e così via, vedi la tabella): il programma non deve includerli. Le macro si invocano con `+nome`, seguito dai parametri; il primo parametro delle macro che hanno più indirizzamenti è la stringa del modo (`"IMM"`, `"ABS"` o `"ZP"`). Gli operandi devono essere definiti prima dell'invocazione.

| Modulo | Include da sé | File da includere prima |
|---|---|---|
| `fp.asm` | `<c64/symbols.asm>`, `<system/errors.asm>`, `<math/fp_common.asm>`, `<math/fp_arith.asm>`, `<math/fp_boolean.asm>`, `<math/fp_compare.asm>`, `<math/fp_constants.asm>`, `<math/fp_error.asm>`, `<math/fp_integers.asm>`, `<math/fp_io.asm>`, `<math/fp_memory.asm>`, `<math/fp_poly.asm>`, `<math/fp_power.asm>`, `<math/fp_random.asm>`, `<math/fp_transcend.asm>`, `<math/fp_trig.asm>`, `<math/fp_unary.asm>` | Nessuno |
| `math8.asm` | `<c64/symbols.asm>` | Nessuno |
| `math16.asm` | `<mem/mem16.asm>` | Nessuno |
| `math24.asm` | `<mem/mem24.asm>` | Nessuno |
| `math32.asm` | `<mem/mem32.asm>` | Nessuno |
| `math_mult.asm` | `<c64/symbols.asm>` | Nessuno |
| `math_div.asm` | `<c64/symbols.asm>`, `<system/errors.asm>` | Nessuno |

I nomi delle macro dicono dove si trova l'altro operando: `_ARG` e `_FAC` indicano i registri in pagina zero, `_Mem` un indirizzo assoluto (parametro `.addr_`), `_Ptr` un indirizzo puntato da un puntatore in pagina zero (parametro `.ptr_`). Il risultato è in `FAC`, salvo dove il contratto indica altro.

### Configurazione

Ogni parametro e punto di personalizzazione si definisce nella copia di `config.asm` della Soluzione. Le macro dei moduli `math8`, `math16`, `math24`, `math32` e le macro di `fp.asm` si assemblano quando vengono invocate, con `+nome`, seguito dai parametri. Ogni subroutine viene assemblata solo se il suo parametro vale `1`. Nel template tutti i parametri valgono `0`.

| Parametro | Subroutine | Richiede anche |
|---|---|---|
| `__USE_FP_ERROR_HANDLER` | `FP_ERROR_HANDLER` | |
| `__USE_MUL_8X8` | `MUL_8X8` |  |
| `__USE_SMUL_8X8` | `SMUL_8X8` |  |
| `__USE_MUL_16X8` | `MUL_16X8` |  |
| `__USE_SMUL_16X8` | `SMUL_16X8` |  |
| `__USE_MUL_24X8` | `MUL_24X8` |  |
| `__USE_SMUL_24X8` | `SMUL_24X8` |  |
| `__USE_MUL_32X8` | `MUL_32X8` |  |
| `__USE_SMUL_32X8` | `SMUL_32X8` |  |
| `__USE_MUL_16X16` | `MUL_16X16` |  |
| `__USE_SMUL_16X16` | `SMUL_16X16` |  |
| `__USE_MUL_24X16` | `MUL_24X16` |  |
| `__USE_SMUL_24X16` | `SMUL_24X16` |  |
| `__USE_MUL_32X16` | `MUL_32X16` |  |
| `__USE_SMUL_32X16` | `SMUL_32X16` |  |
| `__USE_MUL_24X24` | `MUL_24X24` |  |
| `__USE_SMUL_24X24` | `SMUL_24X24` |  |
| `__USE_MUL_32X24` | `MUL_32X24` |  |
| `__USE_SMUL_32X24` | `SMUL_32X24` |  |
| `__USE_MUL_32X32` | `MUL_32X32` |  |
| `__USE_SMUL_32X32` | `SMUL_32X32` |  |
| `__USE_DIV_8X8` | `DIV_8X8` |  |
| `__USE_SDIV_8X8` | `SDIV_8X8` |  |
| `__USE_DIV_16X8` | `DIV_16X8` |  |
| `__USE_SDIV_16X8` | `SDIV_16X8` |  |
| `__USE_DIV_24X8` | `DIV_24X8` |  |
| `__USE_SDIV_24X8` | `SDIV_24X8` |  |
| `__USE_DIV_32X8` | `DIV_32X8` |  |
| `__USE_SDIV_32X8` | `SDIV_32X8` |  |
| `__USE_DIV_16X16` | `DIV_16X16` |  |
| `__USE_SDIV_16X16` | `SDIV_16X16` |  |
| `__USE_DIV_24X16` | `DIV_24X16` |  |
| `__USE_SDIV_24X16` | `SDIV_24X16` |  |
| `__USE_DIV_32X16` | `DIV_32X16` |  |
| `__USE_SDIV_32X16` | `SDIV_32X16` |  |
| `__USE_DIV_24X24` | `DIV_24X24` |  |
| `__USE_SDIV_24X24` | `SDIV_24X24` |  |
| `__USE_DIV_32X24` | `DIV_32X24` |  |
| `__USE_SDIV_32X24` | `SDIV_32X24` |  |
| `__USE_DIV_32X32` | `DIV_32X32` |  |
| `__USE_SDIV_32X32` | `SDIV_32X32` |  |

Punti di personalizzazione usati dalla libreria, definiti anch'essi in `config.asm`:

| Punto di personalizzazione | Usato da | Valore nel template | Significato |
|---|---|---|---|
| `__PRESERVE_ARG` | Le macro che alterano `ARG` | `1` | Interruttore: 1 = la macro preserva `ARG`; 0 = `ARG` può essere alterato |
| `__FP_SAVED_SP` | Le macro che possono provocare un errore, e `FP_ERROR_HANDLER` | `$06` | Cella in ZP: `.S` salvato prima delle chiamate alla ROM |
| `__PUT_STRING` | `m_Print_FAC`, `m_Print_ARG` | `$AB1E` (STROUT) | Subroutine di stampa di una stringa terminata da zero |

Il modulo usa inoltre due aree di appoggio in pagina zero, definite in `fp_common.asm`: `_SCRATCH_1` (`$3D`, 7 byte, copia di `FAC`) e `_SCRATCH_2` (coincide con `NUMWRK`, 6 byte, copia di `ARG`). Sono ad uso interno del modulo; per le conseguenze vedi la [Nota #04](#nota-fp-04) e la [Nota #06](#nota-fp-06).

### Pagina zero

`math_mult.asm` e `math_div.asm` lavorano in pagina zero su 12 byte da `NUMWRK` a `NUMWRK+11` ([Nota #02 di `math_mult.asm`](#nota-math_mult-02), [Nota #02 di `math_div.asm`](#nota-math_div-02)). Simboli definiti dai due moduli:

| Simbolo | Definizione | Significato |
|---|---|---|
| `MUL_1` | `NUMWRK` | Primo operando (moltiplicando), da 1 a 4 byte |
| `MUL_2` | `NUMWRK+4` | Secondo operando (moltiplicatore), da 1 a 4 byte |
| `MUL_RES` | `NUMWRK+4` | Prodotto, da 2 a 8 byte (sovrapposto a `MUL_2`) |
| `DIV_1` | `NUMWRK` | Primo operando (dividendo), da 1 a 4 byte |
| `DIV_QUOT` | `DIV_1` | Quoziente, da 1 a 4 byte (sovrapposto a `DIV_1`) |
| `DIV_2` | `NUMWRK+4` | Secondo operando (divisore), da 1 a 4 byte |
| `DIV_REM` | `NUMWRK+8` | Resto, da 1 a 4 byte |

La stessa area è condivisa con `ZPL_1` e `ZPL_2` (puntatori utente a 24/32 bit) e tra moltiplicazione e divisione: non si possono usare contemporaneamente.

### Note generali

Le note d'uso sono in [`fp.asm`](#modulo-fp). Quelle che valgono per tutto il modulo:

- [Nota #01](#nota-fp-01): i formati MBF e FAC dei numeri;
- [Nota #02](#nota-fp-02): il registro `ARISGN`;
- [Nota #03](#nota-fp-03): l'arrotondamento in base a `FACOV`;
- [Nota #04](#nota-fp-04): le celle di pagina zero condivise con i moduli `math`;
- [Nota #05](#nota-fp-05): le ROM del BASIC e del KERNAL devono essere visibili;
- [Nota #06](#nota-fp-06): variabili vitali del BASIC alterate dalla ROM;
- [Nota #07](#nota-fp-07): errori della ROM e `FP_ERROR_HANDLER`;
- [Nota #08](#nota-fp-08): il bug della moltiplicazione della ROM.

Le altre note riguardano singole funzioni e sono richiamate dalle schede.

<a id="modulo-fp"></a>
## fp.asm

Modulo principale della libreria. Include gli altri moduli e raccoglie le note d'uso. Le utilità sono definite nei sotto-moduli `fp_common.asm`, `fp_arith.asm`, `fp_boolean.asm`, `fp_compare.asm`, `fp_constants.asm`, `fp_error.asm`, `fp_integers.asm`, `fp_io.asm`, `fp_memory.asm`, `fp_poly.asm`, `fp_power.asm`, `fp_random.asm`, `fp_transcend.asm`, `fp_trig.asm`, `fp_unary.asm`: il programma non li include direttamente.

Requisiti di pagina zero: `__FP_SAVED_SP`, `_SCRATCH_1`, `_SCRATCH_2`.

### fp_common.asm

Aree di appoggio e macro per salvare e ripristinare una copia di `FAC` e di `ARG`, ad uso interno della libreria fp.

#### Salvataggio nell'area di appoggio

Macro: `m_Store_FAC_in_Scratch`, `m_Store_ARG_in_Scratch`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Registri Modificati | `.A`, `.P` (Negative, Zero) |

<a id="utilita-m_store_fac_in_scratch"></a>
##### m_Store_FAC_in_Scratch

Copia in `_SCRATCH_1` il contenuto di `FAC`, un registro alla volta. Uso interno della libreria.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `_SCRATCH_1` (7 byte, ZP): Copia di `FAC` |
| Registri Modificati | `_SCRATCH_1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_store_arg_in_scratch"></a>
##### m_Store_ARG_in_Scratch

Copia in `_SCRATCH_2` il contenuto di `ARG`, un registro alla volta. Uso interno della libreria.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `_SCRATCH_2` (6 byte, ZP): Copia di `ARG` |
| Registri Modificati | `_SCRATCH_2` |

[↑ Torna al contenuto](#contenuto)

#### Ripristino dall'area di appoggio

Macro: `m_Load_FAC_from_Scratch`, `m_Load_ARG_from_Scratch`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Registri Modificati | `.A`, `.P` (Negative, Zero) |

<a id="utilita-m_load_fac_from_scratch"></a>
##### m_Load_FAC_from_Scratch

Copia il contenuto di `_SCRATCH_1` in `FAC`, un registro alla volta. Uso interno della libreria.

| Voce | Specifico di questa macro |
|---|---|
| Input | `_SCRATCH_1` (7 byte, ZP): Copia di `FAC` |
| Output | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Registri Modificati | `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_from_scratch"></a>
##### m_Load_ARG_from_Scratch

Copia il contenuto di `_SCRATCH_2` in `ARG`, un registro alla volta. Uso interno della libreria.

| Voce | Specifico di questa macro |
|---|---|
| Input | `_SCRATCH_2` (6 byte, ZP): Copia di `ARG` |
| Output | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Registri Modificati | `ARG` |

[↑ Torna al contenuto](#contenuto)

### fp_arith.asm

Macro per le quattro operazioni aritmetiche sui numeri in virgola mobile (formato MBF): somma, sottrazione, moltiplicazione e divisione, con l'altro operando in `ARG`, a un indirizzo assoluto o puntato da un puntatore. Il risultato è sempre in `FAC`. L'interruttore `__PRESERVE_ARG` di config.asm decide se `ARG` viene preservato.

#### Somma

Macro: `m_Add_FAC_to_ARG`, `m_Add_FAC_to_Mem`, `m_Add_FAC_to_Ptr`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in `_SCRATCH_2` prima della chiamata e lo ripristina dopo; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata.

Se il risultato è troppo grande per il formato MBF la ROM segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo piccolo il risultato è zero. Per la gestione degli errori vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV`<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Risultato, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito<br>`ARISGN` (1 byte, ZP): Segno aritmetico, bit #7<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `_SCRATCH_2` (se `__PRESERVE_ARG` = 1), `__FP_SAVED_SP` |

<a id="utilita-m_add_fac_to_arg"></a>
##### m_Add_FAC_to_ARG

Somma `FAC` e un numero in formato MBF che si trova in `ARG` e lascia il risultato in `FAC`: `FAC` = `FAC` + `ARG`.

Calcola il segno del risultato in `ARISGN` (bit #7 = 0 se i segni di `FAC` e `ARG` sono uguali, 1 se sono diversi) e chiama la routine `FADDT` della ROM del BASIC, che richiede in `.A` l'esponente di `FAC`: se è zero, `FAC` è considerato zero.

La routine `FADDT` della ROM del BASIC può alterare `ARG`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_add_fac_to_mem"></a>
##### m_Add_FAC_to_Mem

Chiamata: `+m_Add_FAC_to_Mem .addr_`

Somma `FAC` e un numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`: `FAC` = `FAC` + `(.addr_)`.

Punta `.A` (LSB) e `.Y` (MSB) all'indirizzo del numero e chiama la routine `FADD` della ROM del BASIC, che lo carica in `ARG` con `CONUPK` e aggiorna `ARISGN`. La routine `FADD` altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `FADD` della ROM del BASIC altera sempre `ARG`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Registri Modificati | `INDEX` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_add_fac_to_ptr"></a>
##### m_Add_FAC_to_Ptr

Chiamata: `+m_Add_FAC_to_Ptr .ptr_`

Somma `FAC` e un numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`: `FAC` = `FAC` + `((.ptr_))`.

Punta `.A` (LSB) e `.Y` (MSB) all'indirizzo del numero e chiama la routine `FADD` della ROM del BASIC, che lo carica in `ARG` con `CONUPK` e aggiorna `ARISGN`. La routine `FADD` altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `FADD` della ROM del BASIC altera sempre `ARG`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Registri Modificati | `INDEX` |

[↑ Torna al contenuto](#contenuto)

#### Sottrazione

Macro: `m_Subtract_FAC_from_ARG`, `m_Subtract_FAC_from_Mem`, `m_Subtract_FAC_from_Ptr`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in `_SCRATCH_2` prima della chiamata e lo ripristina dopo; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata.

Se il risultato è troppo grande per il formato MBF la ROM segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo piccolo il risultato è zero. Per la gestione degli errori vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV`<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Risultato, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito<br>`ARISGN` (1 byte, ZP): Segno aritmetico, bit #7<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `_SCRATCH_2` (se `__PRESERVE_ARG` = 1), `__FP_SAVED_SP` |

<a id="utilita-m_subtract_fac_from_arg"></a>
##### m_Subtract_FAC_from_ARG

Sottrae `FAC` da un numero in formato MBF che si trova in `ARG` e lascia il risultato in `FAC`: `FAC` = `ARG` - `FAC`.

Chiama la routine `FSUBT` della ROM del BASIC, che inverte il segno di `FAC`, calcola `ARISGN` e tratta da sé il caso di `FAC` uguale a zero.

La routine `FSUBT` della ROM del BASIC può alterare `ARG`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_subtract_fac_from_mem"></a>
##### m_Subtract_FAC_from_Mem

Chiamata: `+m_Subtract_FAC_from_Mem .addr_`

Sottrae `FAC` da un numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`: `FAC` = `(.addr_)` - `FAC`.

Punta `.A` (LSB) e `.Y` (MSB) all'indirizzo del numero e chiama la routine `FSUB` della ROM del BASIC, che lo carica in `ARG` con `CONUPK` e aggiorna `ARISGN`. La routine `FSUB` altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `FSUB` della ROM del BASIC altera sempre `ARG`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Registri Modificati | `INDEX` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_subtract_fac_from_ptr"></a>
##### m_Subtract_FAC_from_Ptr

Chiamata: `+m_Subtract_FAC_from_Ptr .ptr_`

Sottrae `FAC` da un numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`: `FAC` = `((.ptr_))` - `FAC`.

Punta `.A` (LSB) e `.Y` (MSB) all'indirizzo del numero e chiama la routine `FSUB` della ROM del BASIC, che lo carica in `ARG` con `CONUPK` e aggiorna `ARISGN`. La routine `FSUB` altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `FSUB` della ROM del BASIC altera sempre `ARG`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Registri Modificati | `INDEX` |

[↑ Torna al contenuto](#contenuto)

#### Moltiplicazione

Macro: `m_Multiply_FAC_by_ARG`, `m_Multiply_FAC_by_Mem`, `m_Multiply_FAC_by_Ptr`.

Se il risultato è troppo grande per il formato MBF la ROM segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo piccolo il risultato è zero. Per la gestione degli errori vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

Per l'accuratezza del risultato vedi [Nota #08 di `math/fp.asm`](#nota-fp-08).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `FAC` (7 byte, ZP): Risultato, registri da `FACEXP` a `FACOV`<br>`ARISGN` (1 byte, ZP): Segno aritmetico, bit #7<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `__FP_SAVED_SP` |

<a id="utilita-m_multiply_fac_by_arg"></a>
##### m_Multiply_FAC_by_ARG

Moltiplica `FAC` per un numero in formato MBF che si trova in `ARG` e lascia il risultato in `FAC`: `FAC` = `FAC` x `ARG`.

Calcola il segno del risultato in `ARISGN` (bit #7 = 0 se i segni di `FAC` e `ARG` sono uguali, 1 se sono diversi) e chiama la routine `FMULTT` della ROM del BASIC, che richiede in `.A` l'esponente di `FAC`: se è zero, `FAC` è considerato zero.

La routine `FMULTT` della ROM del BASIC non altera `ARG`, quindi la macro non ha bisogno di preservarlo e l'interruttore `__PRESERVE_ARG` non ha effetto.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `ARG` (6 byte, ZP): Invariato |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_multiply_fac_by_mem"></a>
##### m_Multiply_FAC_by_Mem

Chiamata: `+m_Multiply_FAC_by_Mem .addr_`

Moltiplica `FAC` per un numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`: `FAC` = `FAC` x `(.addr_)`.

Punta `.A` (LSB) e `.Y` (MSB) all'indirizzo del numero e chiama la routine `FMULT` della ROM del BASIC, che lo carica in `ARG` con `CONUPK` e aggiorna `ARISGN`. La routine `FMULT` altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `FMULT` della ROM del BASIC altera sempre `ARG`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in `_SCRATCH_2` prima della chiamata e lo ripristina dopo; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito |
| Registri Modificati | `INDEX`, `_SCRATCH_2` (se `__PRESERVE_ARG` = 1) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_multiply_fac_by_ptr"></a>
##### m_Multiply_FAC_by_Ptr

Chiamata: `+m_Multiply_FAC_by_Ptr .ptr_`

Moltiplica `FAC` per un numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`: `FAC` = `FAC` x `((.ptr_))`.

Punta `.A` (LSB) e `.Y` (MSB) all'indirizzo del numero e chiama la routine `FMULT` della ROM del BASIC, che lo carica in `ARG` con `CONUPK` e aggiorna `ARISGN`. La routine `FMULT` altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `FMULT` della ROM del BASIC altera sempre `ARG`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in `_SCRATCH_2` prima della chiamata e lo ripristina dopo; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito |
| Registri Modificati | `INDEX`, `_SCRATCH_2` (se `__PRESERVE_ARG` = 1) |

[↑ Torna al contenuto](#contenuto)

#### Divisione

Macro: `m_Divide_ARG_by_FAC`, `m_Divide_Mem_by_FAC`, `m_Divide_Ptr_by_FAC`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in `_SCRATCH_2` prima della chiamata e lo ripristina dopo; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata.

Se `FAC` è zero la ROM segnala DIVISION BY ZERO ERROR e non ritorna al chiamante.

Se il risultato è troppo grande per il formato MBF la ROM segnala OVERFLOW ERROR e non ritorna al chiamante; se è troppo piccolo il risultato è zero. Per la gestione degli errori vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV`<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Risultato, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito<br>`ARISGN` (1 byte, ZP): Segno aritmetico, bit #7<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `_SCRATCH_2` (se `__PRESERVE_ARG` = 1), `__FP_SAVED_SP` |

<a id="utilita-m_divide_arg_by_fac"></a>
##### m_Divide_ARG_by_FAC

Divide un numero in formato MBF che si trova in `ARG` per `FAC` e lascia il risultato in `FAC`: `FAC` = `ARG` / `FAC`.

Calcola il segno del risultato in `ARISGN` (bit #7 = 0 se i segni di `FAC` e `ARG` sono uguali, 1 se sono diversi) e chiama la routine `FDIVT` della ROM del BASIC, che richiede in `.A` l'esponente di `FAC`: se è zero, `FAC` è considerato zero.

La routine `FDIVT` della ROM del BASIC altera sempre `ARG`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_divide_mem_by_fac"></a>
##### m_Divide_Mem_by_FAC

Chiamata: `+m_Divide_Mem_by_FAC .addr_`

Divide un numero in formato MBF che si trova a un indirizzo assoluto per `FAC` e lascia il risultato in `FAC`: `FAC` = `(.addr_)` / `FAC`.

Punta `.A` (LSB) e `.Y` (MSB) all'indirizzo del numero e chiama la routine `FDIV` della ROM del BASIC, che lo carica in `ARG` con `CONUPK` e aggiorna `ARISGN`. La routine `FDIV` altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `FDIV` della ROM del BASIC altera sempre `ARG`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Registri Modificati | `INDEX` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_divide_ptr_by_fac"></a>
##### m_Divide_Ptr_by_FAC

Chiamata: `+m_Divide_Ptr_by_FAC .ptr_`

Divide un numero in formato MBF che si trova all'indirizzo a cui punta un puntatore per `FAC` e lascia il risultato in `FAC`: `FAC` = `((.ptr_))` / `FAC`.

Punta `.A` (LSB) e `.Y` (MSB) all'indirizzo del numero e chiama la routine `FDIV` della ROM del BASIC, che lo carica in `ARG` con `CONUPK` e aggiorna `ARISGN`. La routine `FDIV` altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `FDIV` della ROM del BASIC altera sempre `ARG`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Registri Modificati | `INDEX` |

[↑ Torna al contenuto](#contenuto)

### fp_boolean.asm

Macro per gli operatori booleani bit a bit AND, OR e NOT sui numeri in virgola mobile (formato MBF), convertiti in interi a 16 bit con segno. Il secondo operando di AND e OR può essere in `ARG`, a un indirizzo assoluto o puntato da un puntatore; il risultato è in `FAC`. L'interruttore `__PRESERVE_ARG` di config.asm decide se `ARG` viene preservato.

#### AND

Macro: `m_AND_FAC_with_ARG`, `m_AND_FAC_with_Mem`, `m_AND_FAC_with_Ptr`.

Entrambi i numeri sono convertiti in interi a 16 bit con segno, arrotondati per difetto (-1.5 diventa -2); il risultato è riconvertito in virgola mobile.

Chiama la routine `ANDOP` della ROM del BASIC. Se `FAC` o l'altro numero è fuori dall'intervallo da -32768 a 32 767, la ROM segnala ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

La ROM altera queste celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `$07`-`$08`, `$0B` e `$0D` (`VALTYP`, posto a zero).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `FAC` (7 byte, ZP): Risultato, registri da `FACEXP` a `FACOV`<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `__FP_SAVED_SP` |

<a id="utilita-m_and_fac_with_arg"></a>
##### m_AND_FAC_with_ARG

Esegue un AND bit a bit tra `FAC` e il numero in formato MBF che è in `ARG` e lascia il risultato in `FAC`: `FAC` = `FAC` AND `ARG`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `ARG` (6 byte, ZP): Invariato |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_and_fac_with_mem"></a>
##### m_AND_FAC_with_Mem

Chiamata: `+m_AND_FAC_with_Mem .addr_`

Esegue un AND bit a bit tra `FAC` e il numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`: `FAC` = `FAC` AND `(.addr_)`.

Carica prima il numero in `ARG` con `m_Load_ARG_from_Mem`, che aggiorna `ARISGN` e altera `INDEX`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in `_SCRATCH_2` prima di caricare il numero e lo ripristina dopo; se vale 0 `ARG` contiene il numero caricato. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti contiene il numero |
| Registri Modificati | `ARISGN`, `INDEX`, `_SCRATCH_2` (se `__PRESERVE_ARG` = 1) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_and_fac_with_ptr"></a>
##### m_AND_FAC_with_Ptr

Chiamata: `+m_AND_FAC_with_Ptr .ptr_`

Esegue un AND bit a bit tra `FAC` e il numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`: `FAC` = `FAC` AND `((.ptr_))`.

Carica prima il numero in `ARG` con `m_Load_ARG_from_Ptr`, che aggiorna `ARISGN` e altera `INDEX`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in `_SCRATCH_2` prima di caricare il numero e lo ripristina dopo; se vale 0 `ARG` contiene il numero caricato. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti contiene il numero |
| Registri Modificati | `ARISGN`, `INDEX`, `_SCRATCH_2` (se `__PRESERVE_ARG` = 1) |

[↑ Torna al contenuto](#contenuto)

#### OR

Macro: `m_OR_FAC_with_ARG`, `m_OR_FAC_with_Mem`, `m_OR_FAC_with_Ptr`.

Entrambi i numeri sono convertiti in interi a 16 bit con segno, arrotondati per difetto (-1.5 diventa -2); il risultato è riconvertito in virgola mobile.

Chiama la routine `OROP` della ROM del BASIC. Se `FAC` o l'altro numero è fuori dall'intervallo da -32768 a 32 767, la ROM segnala ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

La ROM altera queste celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `$07`-`$08`, `$0B` e `$0D` (`VALTYP`, posto a zero).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `FAC` (7 byte, ZP): Risultato, registri da `FACEXP` a `FACOV`<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `__FP_SAVED_SP` |

<a id="utilita-m_or_fac_with_arg"></a>
##### m_OR_FAC_with_ARG

Esegue un OR bit a bit tra `FAC` e il numero in formato MBF che è in `ARG` e lascia il risultato in `FAC`: `FAC` = `FAC` OR `ARG`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `ARG` (6 byte, ZP): Invariato |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_or_fac_with_mem"></a>
##### m_OR_FAC_with_Mem

Chiamata: `+m_OR_FAC_with_Mem .addr_`

Esegue un OR bit a bit tra `FAC` e il numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`: `FAC` = `FAC` OR `(.addr_)`.

Carica prima il numero in `ARG` con `m_Load_ARG_from_Mem`, che aggiorna `ARISGN` e altera `INDEX`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in `_SCRATCH_2` prima di caricare il numero e lo ripristina dopo; se vale 0 `ARG` contiene il numero caricato. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti contiene il numero |
| Registri Modificati | `ARISGN`, `INDEX`, `_SCRATCH_2` (se `__PRESERVE_ARG` = 1) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_or_fac_with_ptr"></a>
##### m_OR_FAC_with_Ptr

Chiamata: `+m_OR_FAC_with_Ptr .ptr_`

Esegue un OR bit a bit tra `FAC` e il numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`: `FAC` = `FAC` OR `((.ptr_))`.

Carica prima il numero in `ARG` con `m_Load_ARG_from_Ptr`, che aggiorna `ARISGN` e altera `INDEX`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in `_SCRATCH_2` prima di caricare il numero e lo ripristina dopo; se vale 0 `ARG` contiene il numero caricato. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti contiene il numero |
| Registri Modificati | `ARISGN`, `INDEX`, `_SCRATCH_2` (se `__PRESERVE_ARG` = 1) |

[↑ Torna al contenuto](#contenuto)

#### NOT

Macro: `m_NOT_FAC`, `m_NOT_ARG`, `m_NOT_Mem`, `m_NOT_Ptr`.

Il numero è convertito in un intero a 16 bit con segno, arrotondato per difetto (-1.5 diventa -2); il risultato, che vale -n-1, è riconvertito in virgola mobile.

La ROM altera la cella di lavoro `$0D` (`VALTYP`), che viene posta a zero.

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Output | `__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `__FP_SAVED_SP` |

<a id="utilita-m_not_fac"></a>
##### m_NOT_FAC

Esegue un NOT bit a bit su `FAC` e lascia il risultato in `FAC`: `FAC` = NOT `FAC`.

Chiama la routine `NOTOP` della ROM del BASIC. Se il numero è fuori dall'intervallo da -32768 a 32 767, la ROM segnala ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `FAC` (7 byte, ZP): Risultato, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_not_arg"></a>
##### m_NOT_ARG

Esegue un NOT bit a bit su `ARG` e lascia il risultato in `ARG`, senza alterare `FAC`: `ARG` = NOT `ARG`. È l'unica macro di questo gruppo che lavora sul posto, e non lascia il risultato in `FAC`.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, esegue il NOT su `FAC` e li scambia di nuovo.

Chiama la routine `NOTOP` della ROM del BASIC. Se il numero è fuori dall'intervallo da -32768 a 32 767, la ROM segnala ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07). In questo caso `FAC` e `ARG` restano scambiati.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `ARG` (6 byte, ZP): Risultato, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Invariato |
| Registri Modificati | `_SCRATCH_2` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_not_mem"></a>
##### m_NOT_Mem

Chiamata: `+m_NOT_Mem .addr_`

Esegue un NOT bit a bit sul numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`, che perde il suo vecchio contenuto.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Mem`, che altera `INDEX`.

Chiama la routine `NOTOP` della ROM del BASIC. Se il numero è fuori dall'intervallo da -32768 a 32 767, la ROM segnala ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Risultato, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato |
| Registri Modificati | `INDEX` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_not_ptr"></a>
##### m_NOT_Ptr

Chiamata: `+m_NOT_Ptr .ptr_`

Esegue un NOT bit a bit sul numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`, che perde il suo vecchio contenuto.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Ptr`, che altera `INDEX`.

Chiama la routine `NOTOP` della ROM del BASIC. Se il numero è fuori dall'intervallo da -32768 a 32 767, la ROM segnala ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Risultato, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato |
| Registri Modificati | `INDEX` |

[↑ Torna al contenuto](#contenuto)

### fp_compare.asm

Macro per confrontare `FAC` con un altro numero in virgola mobile (formato MBF), che può essere in `ARG`, a un indirizzo assoluto o puntato da un puntatore. Il risultato è in `.A`.

#### Confronto

Macro: `m_Compare_FAC_to_ARG`, `m_Compare_FAC_to_Mem`, `m_Compare_FAC_to_Ptr`.

Chiama la routine `FCOMP` della ROM del BASIC, che altera `INDEX2`: il suo contenuto non è garantito dopo la chiamata.

Il risultato è in `.A`: `$00` se `FAC` = numero, `$01` se `FAC` > numero, `$FF` se `FAC` < numero. Anche i flag Negative e Zero riflettono `.A`; il Carry vale 1 se `FAC` < numero e 0 se `FAC` > numero, mentre non è garantito se sono uguali.

Il confronto è esatto su tutti i bit della mantissa, `FACOV` compreso. `FAC` e `ARG` non cambiano; due zeri sono uguali, qualunque sia il loro segno.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `.A` (1 byte, CPU): `$00` = uguali; `$01` = `FAC` maggiore; `$FF` = `FAC` minore<br>Carry (1 bit, .P): 0 = `FAC` maggiore; 1 = `FAC` minore (non garantito se uguali) |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `INDEX2` |

<a id="utilita-m_compare_fac_to_arg"></a>
##### m_Compare_FAC_to_ARG

Confronta `FAC` con il numero in virgola mobile di `ARG`.

`FCOMP` non lavora con `ARG`, che è in formato non impacchettato: la macro lo scrive in formato MBF in 5 byte a partire da `STACK` (`$0100`), con `m_Store_ARG_to_Mem`, e punta `FCOMP` a quell'indirizzo. Il contenuto di `STACK` non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Registri Modificati | `STACK` (5 byte) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_compare_fac_to_mem"></a>
##### m_Compare_FAC_to_Mem

Chiamata: `+m_Compare_FAC_to_Mem .addr_`

Confronta `FAC` con il numero in formato MBF che si trova a un indirizzo assoluto.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_compare_fac_to_ptr"></a>
##### m_Compare_FAC_to_Ptr

Chiamata: `+m_Compare_FAC_to_Ptr .ptr_`

Confronta `FAC` con il numero in formato MBF che si trova all'indirizzo a cui punta un puntatore.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

### fp_constants.asm

Macro per caricare `FAC` e `ARG` con un numero in virgola mobile in formato MBF, byte per byte o tra quelle predefinite.

#### Caricamento di un numero byte per byte

Macro: `m_Load_FAC_with`, `m_Load_ARG_with`.

Quando un byte è uguale al precedente la macro omette il caricamento in `.A`. Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `.exp_` (1 byte, Macro): Esponente<br>`.ho_` (1 byte, Macro): MSB della mantissa, con il segno nel bit #7<br>`.moh_` (1 byte, Macro): Secondo byte della mantissa<br>`.mo_` (1 byte, Macro): Terzo byte della mantissa<br>`.lo_` (1 byte, Macro): LSB della mantissa |
| Registri Modificati | `.A`, `.P` (Negative, Zero) |

<a id="utilita-m_load_fac_with"></a>
##### m_Load_FAC_with

Chiamata: `+m_Load_FAC_with .exp_, .ho_, .moh_, .mo_, .lo_`

Carica `FAC` con un numero in virgola mobile in formato MBF a precisione estesa (5 byte), scrivendo ogni byte con istruzioni lda e sta, senza chiamare la ROM del BASIC. Il valore caricato in `FAC` è sempre considerato arrotondato: `FACOV` viene azzerato.

| Voce | Specifico di questa macro |
|---|---|
| Output | `FAC` (7 byte, ZP): Numero caricato, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with"></a>
##### m_Load_ARG_with

Chiamata: `+m_Load_ARG_with .exp_, .ho_, .moh_, .mo_, .lo_`

Carica `ARG` con un numero in virgola mobile in formato MBF a precisione estesa (5 byte), scrivendo ogni byte con istruzioni lda e sta, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Output | `ARG` (6 byte, ZP): Numero caricato, registri da `ARGEXP` a `ARGSGN` |
| Registri Modificati | `ARG` |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di costanti in FAC

Macro: `m_Load_FAC_with_0`, `m_Load_FAC_with_0_25`, `m_Load_FAC_with_0_5`, `m_Load_FAC_with_1`, `m_Load_FAC_with_MINUS_1`, `m_Load_FAC_with_2`, `m_Load_FAC_with_10`, `m_Load_FAC_with_0_1`, `m_Load_FAC_with_PI4`, `m_Load_FAC_with_PI2`, `m_Load_FAC_with_PI`, `m_Load_FAC_with_2PI`, `m_Load_FAC_with_PI180`, `m_Load_FAC_with_PI200`, `m_Load_FAC_with_180PI`, `m_Load_FAC_with_200PI`, `m_Load_FAC_with_SQR2`, `m_Load_FAC_with_SQR3`, `m_Load_FAC_with_e`, `m_Load_FAC_with_LOG2`, `m_Load_FAC_with_LOG10`, `m_Load_FAC_with_eps`, `m_Load_FAC_with_MINR`, `m_Load_FAC_with_MAXR`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | Nessuno |
| Output | `FAC` (7 byte, ZP): Costante caricata, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.A` |

<a id="utilita-m_load_fac_with_0"></a>
##### m_Load_FAC_with_0

Carica `FAC` con la costante 0. `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$00`, `$00`, `$00`, `$00`, `$00`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

`FACEXP` vale zero, quindi il valore è zero per la ROM del BASIC; il MSB della mantissa vale `$80` (il bit implicito).

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_0_25"></a>
##### m_Load_FAC_with_0_25

Carica `FAC` con la costante 0.25. `FACOV` viene azzerato.

Legge la costante da `FR4` (`$E2EA`) nella ROM del BASIC con `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_0_5"></a>
##### m_Load_FAC_with_0_5

Carica `FAC` con la costante 0.5. `FACOV` viene azzerato.

Legge la costante da `FHALF` (`$BF11`) nella ROM del BASIC con `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_1"></a>
##### m_Load_FAC_with_1

Carica `FAC` con la costante 1. `FACOV` viene azzerato.

Legge la costante da `FONE` (`$B9BC`) nella ROM del BASIC con `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_minus_1"></a>
##### m_Load_FAC_with_MINUS_1

Carica `FAC` con la costante -1. `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$81`, `$80`, `$00`, `$00`, `$00`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_2"></a>
##### m_Load_FAC_with_2

Carica `FAC` con la costante 2. `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$82`, `$00`, `$00`, `$00`, `$00`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_10"></a>
##### m_Load_FAC_with_10

Carica `FAC` con la costante 10. `FACOV` viene azzerato.

Legge la costante da `TENC` (`$BAF9`) nella ROM del BASIC con `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_0_1"></a>
##### m_Load_FAC_with_0_1

Carica `FAC` con la costante 0.1. `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$7D`, `$4C`, `$CC`, `$CC`, `$CD`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_pi4"></a>
##### m_Load_FAC_with_PI4

Carica `FAC` con la costante π/4. `FACOV` viene azzerato.

Carica π/2 dalla ROM del BASIC con `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Poi decrementa l'esponente di `FAC`, che dimezza il valore.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FACEXP` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_pi2"></a>
##### m_Load_FAC_with_PI2

Carica `FAC` con la costante π/2. `FACOV` viene azzerato.

Legge la costante da `PI2` (`$E2E0`) nella ROM del BASIC con `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_pi"></a>
##### m_Load_FAC_with_PI

Carica `FAC` con la costante π. `FACOV` viene azzerato.

Legge la costante da `PIVAL` (`$AEA8`) nella ROM del BASIC con `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

Il valore della ROM non è il più vicino a π: vedi [Nota #17 di `math/fp.asm`](#nota-fp-17).

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_2pi"></a>
##### m_Load_FAC_with_2PI

Carica `FAC` con la costante 2π. `FACOV` viene azzerato.

Legge la costante da `TWOPI` (`$E2E5`) nella ROM del BASIC con `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_pi180"></a>
##### m_Load_FAC_with_PI180

Carica `FAC` con la costante π/180. `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$7B`, `$0E`, `$FA`, `$35`, `$13`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_pi200"></a>
##### m_Load_FAC_with_PI200

Carica `FAC` con la costante π/200. `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$7B`, `$00`, `$AD`, `$FC`, `$91`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_180pi"></a>
##### m_Load_FAC_with_180PI

Carica `FAC` con la costante 180/π. `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$86`, `$65`, `$2E`, `$E0`, `$D3`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_200pi"></a>
##### m_Load_FAC_with_200PI

Carica `FAC` con la costante 200/π. `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$86`, `$7E`, `$A5`, `$DD`, `$5C`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_sqr2"></a>
##### m_Load_FAC_with_SQR2

Carica `FAC` con la costante √2. `FACOV` viene azzerato.

Legge la costante da `FSQR2` (`$B9DB`) nella ROM del BASIC con `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_sqr3"></a>
##### m_Load_FAC_with_SQR3

Carica `FAC` con la costante √3. `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$81`, `$5D`, `$B3`, `$D7`, `$43`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_e"></a>
##### m_Load_FAC_with_e

Carica `FAC` con la costante e. `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$82`, `$2D`, `$F8`, `$54`, `$59`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_log2"></a>
##### m_Load_FAC_with_LOG2

Carica `FAC` con la costante ln 2. `FACOV` viene azzerato.

Legge la costante da `FLOG2` (`$B9E5`) nella ROM del BASIC con `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_log10"></a>
##### m_Load_FAC_with_LOG10

Carica `FAC` con la costante ln 10. `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$82`, `$13`, `$5D`, `$8D`, `$DE`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_eps"></a>
##### m_Load_FAC_with_eps

Carica `FAC` con l'epsilon di macchina. `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$62`, `$00`, `$00`, `$00`, `$00`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

Vale 4.65661287\*10^-10 ed è la differenza tra 1 e il numero in virgola mobile successivo.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_minr"></a>
##### m_Load_FAC_with_MINR

Carica `FAC` con il più piccolo numero rappresentabile (`MINR`). `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$01`, `$00`, `$00`, `$00`, `$00`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

Vale 2.93873588\*10^-39 ed è il più piccolo numero diverso da zero rappresentabile in formato MBF.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_maxr"></a>
##### m_Load_FAC_with_MAXR

Carica `FAC` con il più grande numero rappresentabile (`MAXR`). `FACOV` viene azzerato.

Scrive i 5 byte della costante (`$FF`, `$7F`, `$FF`, `$FF`, `$FF`) con `m_Load_FAC_with`, senza chiamare la ROM del BASIC.

Vale 1.70141183\*10^38 ed è il più grande numero rappresentabile in formato MBF.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `FAC` |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di costanti in ARG

Macro: `m_Load_ARG_with_0`, `m_Load_ARG_with_0_25`, `m_Load_ARG_with_0_5`, `m_Load_ARG_with_1`, `m_Load_ARG_with_MINUS_1`, `m_Load_ARG_with_2`, `m_Load_ARG_with_10`, `m_Load_ARG_with_0_1`, `m_Load_ARG_with_PI4`, `m_Load_ARG_with_PI2`, `m_Load_ARG_with_PI`, `m_Load_ARG_with_2PI`, `m_Load_ARG_with_PI180`, `m_Load_ARG_with_PI200`, `m_Load_ARG_with_180PI`, `m_Load_ARG_with_200PI`, `m_Load_ARG_with_SQR2`, `m_Load_ARG_with_SQR3`, `m_Load_ARG_with_e`, `m_Load_ARG_with_LOG2`, `m_Load_ARG_with_LOG10`, `m_Load_ARG_with_eps`, `m_Load_ARG_with_MINR`, `m_Load_ARG_with_MAXR`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | Nessuno |
| Output | `ARG` (6 byte, ZP): Costante caricata, registri da `ARGEXP` a `ARGSGN` |
| Registri Modificati | `.A` |

<a id="utilita-m_load_arg_with_0"></a>
##### m_Load_ARG_with_0

Carica `ARG` con la costante 0. `FAC` non cambia.

Scrive i 5 byte della costante (`$00`, `$00`, `$00`, `$00`, `$00`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

`FACEXP` vale zero, quindi il valore è zero per la ROM del BASIC; il MSB della mantissa vale `$80` (il bit implicito).

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_0_25"></a>
##### m_Load_ARG_with_0_25

Carica `ARG` con la costante 0.25. `FAC` non cambia.

Legge la costante da `FR4` (`$E2EA`) nella ROM del BASIC con `m_Load_ARG_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `CONUPK` della ROM aggiorna anche `ARISGN`: il bit #7 vale 1 se i segni di `FAC` e di `ARG` sono diversi.

| Voce | Specifico di questa macro |
|---|---|
| Output | `ARISGN` (1 byte, ZP): Bit #7: 0 = segni uguali; 1 = segni diversi |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_0_5"></a>
##### m_Load_ARG_with_0_5

Carica `ARG` con la costante 0.5. `FAC` non cambia.

Legge la costante da `FHALF` (`$BF11`) nella ROM del BASIC con `m_Load_ARG_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `CONUPK` della ROM aggiorna anche `ARISGN`: il bit #7 vale 1 se i segni di `FAC` e di `ARG` sono diversi.

| Voce | Specifico di questa macro |
|---|---|
| Output | `ARISGN` (1 byte, ZP): Bit #7: 0 = segni uguali; 1 = segni diversi |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_1"></a>
##### m_Load_ARG_with_1

Carica `ARG` con la costante 1. `FAC` non cambia.

Legge la costante da `FONE` (`$B9BC`) nella ROM del BASIC con `m_Load_ARG_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `CONUPK` della ROM aggiorna anche `ARISGN`: il bit #7 vale 1 se i segni di `FAC` e di `ARG` sono diversi.

| Voce | Specifico di questa macro |
|---|---|
| Output | `ARISGN` (1 byte, ZP): Bit #7: 0 = segni uguali; 1 = segni diversi |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_minus_1"></a>
##### m_Load_ARG_with_MINUS_1

Carica `ARG` con la costante -1. `FAC` non cambia.

Scrive i 5 byte della costante (`$81`, `$80`, `$00`, `$00`, `$00`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_2"></a>
##### m_Load_ARG_with_2

Carica `ARG` con la costante 2. `FAC` non cambia.

Scrive i 5 byte della costante (`$82`, `$00`, `$00`, `$00`, `$00`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_10"></a>
##### m_Load_ARG_with_10

Carica `ARG` con la costante 10. `FAC` non cambia.

Legge la costante da `TENC` (`$BAF9`) nella ROM del BASIC con `m_Load_ARG_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `CONUPK` della ROM aggiorna anche `ARISGN`: il bit #7 vale 1 se i segni di `FAC` e di `ARG` sono diversi.

| Voce | Specifico di questa macro |
|---|---|
| Output | `ARISGN` (1 byte, ZP): Bit #7: 0 = segni uguali; 1 = segni diversi |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_0_1"></a>
##### m_Load_ARG_with_0_1

Carica `ARG` con la costante 0.1. `FAC` non cambia.

Scrive i 5 byte della costante (`$7D`, `$4C`, `$CC`, `$CC`, `$CD`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_pi4"></a>
##### m_Load_ARG_with_PI4

Carica `ARG` con la costante π/4. `FAC` non cambia.

Carica π/2 dalla ROM del BASIC con `m_Load_ARG_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Poi decrementa l'esponente di `ARG`, che dimezza il valore.

La routine `CONUPK` della ROM aggiorna anche `ARISGN`: il bit #7 vale 1 se i segni di `FAC` e di `ARG` sono diversi.

| Voce | Specifico di questa macro |
|---|---|
| Output | `ARISGN` (1 byte, ZP): Bit #7: 0 = segni uguali; 1 = segni diversi |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARGEXP` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_pi2"></a>
##### m_Load_ARG_with_PI2

Carica `ARG` con la costante π/2. `FAC` non cambia.

Legge la costante da `PI2` (`$E2E0`) nella ROM del BASIC con `m_Load_ARG_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `CONUPK` della ROM aggiorna anche `ARISGN`: il bit #7 vale 1 se i segni di `FAC` e di `ARG` sono diversi.

| Voce | Specifico di questa macro |
|---|---|
| Output | `ARISGN` (1 byte, ZP): Bit #7: 0 = segni uguali; 1 = segni diversi |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_pi"></a>
##### m_Load_ARG_with_PI

Carica `ARG` con la costante π. `FAC` non cambia.

Legge la costante da `PIVAL` (`$AEA8`) nella ROM del BASIC con `m_Load_ARG_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

Il valore della ROM non è il più vicino a π: vedi [Nota #17 di `math/fp.asm`](#nota-fp-17).

La routine `CONUPK` della ROM aggiorna anche `ARISGN`: il bit #7 vale 1 se i segni di `FAC` e di `ARG` sono diversi.

| Voce | Specifico di questa macro |
|---|---|
| Output | `ARISGN` (1 byte, ZP): Bit #7: 0 = segni uguali; 1 = segni diversi |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_2pi"></a>
##### m_Load_ARG_with_2PI

Carica `ARG` con la costante 2π. `FAC` non cambia.

Legge la costante da `TWOPI` (`$E2E5`) nella ROM del BASIC con `m_Load_ARG_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `CONUPK` della ROM aggiorna anche `ARISGN`: il bit #7 vale 1 se i segni di `FAC` e di `ARG` sono diversi.

| Voce | Specifico di questa macro |
|---|---|
| Output | `ARISGN` (1 byte, ZP): Bit #7: 0 = segni uguali; 1 = segni diversi |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_pi180"></a>
##### m_Load_ARG_with_PI180

Carica `ARG` con la costante π/180. `FAC` non cambia.

Scrive i 5 byte della costante (`$7B`, `$0E`, `$FA`, `$35`, `$13`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_pi200"></a>
##### m_Load_ARG_with_PI200

Carica `ARG` con la costante π/200. `FAC` non cambia.

Scrive i 5 byte della costante (`$7B`, `$00`, `$AD`, `$FC`, `$91`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_180pi"></a>
##### m_Load_ARG_with_180PI

Carica `ARG` con la costante 180/π. `FAC` non cambia.

Scrive i 5 byte della costante (`$86`, `$65`, `$2E`, `$E0`, `$D3`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_200pi"></a>
##### m_Load_ARG_with_200PI

Carica `ARG` con la costante 200/π. `FAC` non cambia.

Scrive i 5 byte della costante (`$86`, `$7E`, `$A5`, `$DD`, `$5C`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_sqr2"></a>
##### m_Load_ARG_with_SQR2

Carica `ARG` con la costante √2. `FAC` non cambia.

Legge la costante da `FSQR2` (`$B9DB`) nella ROM del BASIC con `m_Load_ARG_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `CONUPK` della ROM aggiorna anche `ARISGN`: il bit #7 vale 1 se i segni di `FAC` e di `ARG` sono diversi.

| Voce | Specifico di questa macro |
|---|---|
| Output | `ARISGN` (1 byte, ZP): Bit #7: 0 = segni uguali; 1 = segni diversi |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_sqr3"></a>
##### m_Load_ARG_with_SQR3

Carica `ARG` con la costante √3. `FAC` non cambia.

Scrive i 5 byte della costante (`$81`, `$5D`, `$B3`, `$D7`, `$43`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_e"></a>
##### m_Load_ARG_with_e

Carica `ARG` con la costante e. `FAC` non cambia.

Scrive i 5 byte della costante (`$82`, `$2D`, `$F8`, `$54`, `$59`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_log2"></a>
##### m_Load_ARG_with_LOG2

Carica `ARG` con la costante ln 2. `FAC` non cambia.

Legge la costante da `FLOG2` (`$B9E5`) nella ROM del BASIC con `m_Load_ARG_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

La routine `CONUPK` della ROM aggiorna anche `ARISGN`: il bit #7 vale 1 se i segni di `FAC` e di `ARG` sono diversi.

| Voce | Specifico di questa macro |
|---|---|
| Output | `ARISGN` (1 byte, ZP): Bit #7: 0 = segni uguali; 1 = segni diversi |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_log10"></a>
##### m_Load_ARG_with_LOG10

Carica `ARG` con la costante ln 10. `FAC` non cambia.

Scrive i 5 byte della costante (`$82`, `$13`, `$5D`, `$8D`, `$DE`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_eps"></a>
##### m_Load_ARG_with_eps

Carica `ARG` con l'epsilon di macchina. `FAC` non cambia.

Scrive i 5 byte della costante (`$62`, `$00`, `$00`, `$00`, `$00`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

Vale 4.65661287\*10^-10 ed è la differenza tra 1 e il numero in virgola mobile successivo.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_minr"></a>
##### m_Load_ARG_with_MINR

Carica `ARG` con il più piccolo numero rappresentabile (`MINR`). `FAC` non cambia.

Scrive i 5 byte della costante (`$01`, `$00`, `$00`, `$00`, `$00`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

Vale 2.93873588\*10^-39 ed è il più piccolo numero diverso da zero rappresentabile in formato MBF.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_maxr"></a>
##### m_Load_ARG_with_MAXR

Carica `ARG` con il più grande numero rappresentabile (`MAXR`). `FAC` non cambia.

Scrive i 5 byte della costante (`$FF`, `$7F`, `$FF`, `$FF`, `$FF`) con `m_Load_ARG_with`, senza chiamare la ROM del BASIC.

Vale 1.70141183\*10^38 ed è il più grande numero rappresentabile in formato MBF.

| Voce | Specifico di questa macro |
|---|---|
| Registri Modificati | `.P` (Negative, Zero), `ARG` |

[↑ Torna al contenuto](#contenuto)

### fp_error.asm

Gestione delle condizioni d'errore segnalate dalle routine in virgola mobile della ROM del BASIC.

<a id="utilita-fp_error_handler"></a>
#### FP_ERROR_HANDLER

Gestore delle condizioni d'errore che le routine in virgola mobile della ROM possono segnalare. È pensato per essere installato nel vettore `IERROR`, al posto del gestore del BASIC: la ROM carica in `.X` il codice d'errore e salta all'indirizzo contenuto in `IERROR`.

Le macro che possono provocare un errore salvano `.S` in `__FP_SAVED_SP` prima di chiamare la ROM. Il gestore lo ripristina, meno i 2 byte dell'indirizzo di ritorno della chiamata, così l'rts finale ritorna alla macro subito dopo la chiamata, qualunque sia la profondità dello stack nella ROM. Per la macro lo stack resta quindi com'era prima della chiamata. Il gestore è valido solo per gli errori segnalati durante l'esecuzione di queste macro.

Le condizioni sono tre: ILLEGAL QUANTITY, OVERFLOW e DIVISION BY ZERO. Per ciascuna c'è un punto di gestione distinto; per il momento tutti e tre pongono a 1 il Carry e terminano con rts. Con qualunque altro codice, che non dovrebbe presentarsi, la subroutine pone a 0 il Carry e ritorna.

| Voce | Contenuto |
|---|---|
| Input | `.X` (1 byte, CPU): Codice d'errore (`ERR_ILLEGAL_QUANTITY`, `ERR_OVERFLOW` o `ERR_DIVISION_BY_ZERO`)<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata alla ROM |
| Output | Carry (1 bit, .P): 0 = altro codice; 1 = condizione prevista<br>`.PC` (2 byte, CPU): Ritorno alla macro che ha chiamato la ROM, subito dopo la chiamata |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, Zero, Carry), `.S` |

[↑ Torna al contenuto](#contenuto)

### fp_integers.asm

Macro per caricare `FAC` e `ARG` con un intero binario a 8, 16, 24 o 32 bit, con o senza segno, e per convertire `FAC` o `ARG` in un intero a 32 bit con segno.

#### Caricamento di UINT8 in FAC

Macro: `m_Load_FAC_with_UINT8`, `m_Load_FAC_with_UINT8_Mem`, `m_Load_FAC_with_UINT8_Ptr`.

Converte il numero con la routine `FLOATB` della ROM del BASIC, che normalizza `FAC` e prende il segno dal Carry: la macro lo imposta a 1 (numero positivo). `ARG` non cambia.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Output | `FAC` (7 byte, ZP): Intero convertito, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC` |

<a id="utilita-m_load_fac_with_uint8"></a>
##### m_Load_FAC_with_UINT8

Chiamata: `+m_Load_FAC_with_UINT8 .value_`

Carica `FAC` con un intero senza segno a 8 bit, passato come costante, e azzera `FACOV`.

I bit del valore oltre il bit #7 sono ignorati.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (1 byte, Macro): Valore da caricare, senza segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_uint8_mem"></a>
##### m_Load_FAC_with_UINT8_Mem

Chiamata: `+m_Load_FAC_with_UINT8_Mem .addr_`

Carica `FAC` con un intero senza segno a 8 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian), e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (1 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_uint8_ptr"></a>
##### m_Load_FAC_with_UINT8_Ptr

Chiamata: `+m_Load_FAC_with_UINT8_Ptr .ptr_`

Carica `FAC` con un intero senza segno a 8 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (1 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di UINT8 in ARG

Macro: `m_Load_ARG_with_UINT8`, `m_Load_ARG_with_UINT8_Mem`, `m_Load_ARG_with_UINT8_Ptr`.

Il contenuto di `_SCRATCH_2` non è garantito dopo la chiamata.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Valore da conservare, registri da `FACEXP` a `FACOV` |
| Output | `ARG` (6 byte, ZP): Intero convertito, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Valore di prima, arrotondato, `FACOV` azzerato |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC`, `_SCRATCH_2` |

<a id="utilita-m_load_arg_with_uint8"></a>
##### m_Load_ARG_with_UINT8

Chiamata: `+m_Load_ARG_with_UINT8 .value_`

Carica `ARG` con un intero senza segno a 8 bit, passato come costante.

I bit del valore oltre il bit #7 sono ignorati.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_UINT8` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (1 byte, Macro): Valore da caricare, senza segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_uint8_mem"></a>
##### m_Load_ARG_with_UINT8_Mem

Chiamata: `+m_Load_ARG_with_UINT8_Mem .addr_`

Carica `ARG` con un intero senza segno a 8 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian).

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_UINT8_Mem` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (1 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_uint8_ptr"></a>
##### m_Load_ARG_with_UINT8_Ptr

Chiamata: `+m_Load_ARG_with_UINT8_Ptr .ptr_`

Carica `ARG` con un intero senza segno a 8 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_UINT8_Ptr` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (1 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di INT8 in FAC

Macro: `m_Load_FAC_with_INT8`, `m_Load_FAC_with_INT8_Mem`, `m_Load_FAC_with_INT8_Ptr`.

Converte il numero con la routine `FLOATB` della ROM del BASIC, che normalizza `FAC` e prende il segno dal Carry: la macro lo imposta a 1 per i numeri senza segno e, per quelli con segno, lo ricava dal bit #7 del MSB (complemento a due). `ARG` non cambia.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Output | `FAC` (7 byte, ZP): Intero convertito, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC` |

<a id="utilita-m_load_fac_with_int8"></a>
##### m_Load_FAC_with_INT8

Chiamata: `+m_Load_FAC_with_INT8 .value_`

Carica `FAC` con un intero con segno a 8 bit, passato come costante, e azzera `FACOV`.

I bit del valore oltre il bit #7 sono ignorati.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (1 byte, Macro): Valore da caricare, con segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_int8_mem"></a>
##### m_Load_FAC_with_INT8_Mem

Chiamata: `+m_Load_FAC_with_INT8_Mem .addr_`

Carica `FAC` con un intero con segno a 8 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian), e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (1 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_int8_ptr"></a>
##### m_Load_FAC_with_INT8_Ptr

Chiamata: `+m_Load_FAC_with_INT8_Ptr .ptr_`

Carica `FAC` con un intero con segno a 8 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (1 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di INT8 in ARG

Macro: `m_Load_ARG_with_INT8`, `m_Load_ARG_with_INT8_Mem`, `m_Load_ARG_with_INT8_Ptr`.

Il contenuto di `_SCRATCH_2` non è garantito dopo la chiamata.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Valore da conservare, registri da `FACEXP` a `FACOV` |
| Output | `ARG` (6 byte, ZP): Intero convertito, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Valore di prima, arrotondato, `FACOV` azzerato |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC`, `_SCRATCH_2` |

<a id="utilita-m_load_arg_with_int8"></a>
##### m_Load_ARG_with_INT8

Chiamata: `+m_Load_ARG_with_INT8 .value_`

Carica `ARG` con un intero con segno a 8 bit, passato come costante.

I bit del valore oltre il bit #7 sono ignorati.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_INT8` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (1 byte, Macro): Valore da caricare, con segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_int8_mem"></a>
##### m_Load_ARG_with_INT8_Mem

Chiamata: `+m_Load_ARG_with_INT8_Mem .addr_`

Carica `ARG` con un intero con segno a 8 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian).

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_INT8_Mem` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (1 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_int8_ptr"></a>
##### m_Load_ARG_with_INT8_Ptr

Chiamata: `+m_Load_ARG_with_INT8_Ptr .ptr_`

Carica `ARG` con un intero con segno a 8 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_INT8_Ptr` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (1 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di UINT16 in FAC

Macro: `m_Load_FAC_with_UINT16`, `m_Load_FAC_with_UINT16_Mem`, `m_Load_FAC_with_UINT16_Ptr`.

Converte il numero con la routine `FLOATB` della ROM del BASIC, che normalizza `FAC` e prende il segno dal Carry: la macro lo imposta a 1 (numero positivo). `ARG` non cambia.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Output | `FAC` (7 byte, ZP): Intero convertito, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC` |

<a id="utilita-m_load_fac_with_uint16"></a>
##### m_Load_FAC_with_UINT16

Chiamata: `+m_Load_FAC_with_UINT16 .value_`

Carica `FAC` con un intero senza segno a 16 bit, passato come costante, e azzera `FACOV`.

I bit del valore oltre il bit #15 sono ignorati.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (2 byte, Macro): Valore da caricare, senza segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_uint16_mem"></a>
##### m_Load_FAC_with_UINT16_Mem

Chiamata: `+m_Load_FAC_with_UINT16_Mem .addr_`

Carica `FAC` con un intero senza segno a 16 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian), e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (2 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_uint16_ptr"></a>
##### m_Load_FAC_with_UINT16_Ptr

Chiamata: `+m_Load_FAC_with_UINT16_Ptr .ptr_`

Carica `FAC` con un intero senza segno a 16 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (2 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di UINT16 in ARG

Macro: `m_Load_ARG_with_UINT16`, `m_Load_ARG_with_UINT16_Mem`, `m_Load_ARG_with_UINT16_Ptr`.

Il contenuto di `_SCRATCH_2` non è garantito dopo la chiamata.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Valore da conservare, registri da `FACEXP` a `FACOV` |
| Output | `ARG` (6 byte, ZP): Intero convertito, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Valore di prima, arrotondato, `FACOV` azzerato |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC`, `_SCRATCH_2` |

<a id="utilita-m_load_arg_with_uint16"></a>
##### m_Load_ARG_with_UINT16

Chiamata: `+m_Load_ARG_with_UINT16 .value_`

Carica `ARG` con un intero senza segno a 16 bit, passato come costante.

I bit del valore oltre il bit #15 sono ignorati.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_UINT16` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (2 byte, Macro): Valore da caricare, senza segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_uint16_mem"></a>
##### m_Load_ARG_with_UINT16_Mem

Chiamata: `+m_Load_ARG_with_UINT16_Mem .addr_`

Carica `ARG` con un intero senza segno a 16 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian).

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_UINT16_Mem` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (2 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_uint16_ptr"></a>
##### m_Load_ARG_with_UINT16_Ptr

Chiamata: `+m_Load_ARG_with_UINT16_Ptr .ptr_`

Carica `ARG` con un intero senza segno a 16 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_UINT16_Ptr` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (2 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di INT16 in FAC

Macro: `m_Load_FAC_with_INT16`, `m_Load_FAC_with_INT16_Mem`, `m_Load_FAC_with_INT16_Ptr`.

Converte il numero con la routine `FLOATB` della ROM del BASIC, che normalizza `FAC` e prende il segno dal Carry: la macro lo imposta a 1 per i numeri senza segno e, per quelli con segno, lo ricava dal bit #15 del MSB (complemento a due). `ARG` non cambia.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Output | `FAC` (7 byte, ZP): Intero convertito, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC` |

<a id="utilita-m_load_fac_with_int16"></a>
##### m_Load_FAC_with_INT16

Chiamata: `+m_Load_FAC_with_INT16 .value_`

Carica `FAC` con un intero con segno a 16 bit, passato come costante, e azzera `FACOV`.

I bit del valore oltre il bit #15 sono ignorati.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (2 byte, Macro): Valore da caricare, con segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_int16_mem"></a>
##### m_Load_FAC_with_INT16_Mem

Chiamata: `+m_Load_FAC_with_INT16_Mem .addr_`

Carica `FAC` con un intero con segno a 16 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian), e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (2 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_int16_ptr"></a>
##### m_Load_FAC_with_INT16_Ptr

Chiamata: `+m_Load_FAC_with_INT16_Ptr .ptr_`

Carica `FAC` con un intero con segno a 16 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (2 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di INT16 in ARG

Macro: `m_Load_ARG_with_INT16`, `m_Load_ARG_with_INT16_Mem`, `m_Load_ARG_with_INT16_Ptr`.

Il contenuto di `_SCRATCH_2` non è garantito dopo la chiamata.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Valore da conservare, registri da `FACEXP` a `FACOV` |
| Output | `ARG` (6 byte, ZP): Intero convertito, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Valore di prima, arrotondato, `FACOV` azzerato |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC`, `_SCRATCH_2` |

<a id="utilita-m_load_arg_with_int16"></a>
##### m_Load_ARG_with_INT16

Chiamata: `+m_Load_ARG_with_INT16 .value_`

Carica `ARG` con un intero con segno a 16 bit, passato come costante.

I bit del valore oltre il bit #15 sono ignorati.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_INT16` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (2 byte, Macro): Valore da caricare, con segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_int16_mem"></a>
##### m_Load_ARG_with_INT16_Mem

Chiamata: `+m_Load_ARG_with_INT16_Mem .addr_`

Carica `ARG` con un intero con segno a 16 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian).

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_INT16_Mem` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (2 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_int16_ptr"></a>
##### m_Load_ARG_with_INT16_Ptr

Chiamata: `+m_Load_ARG_with_INT16_Ptr .ptr_`

Carica `ARG` con un intero con segno a 16 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_INT16_Ptr` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (2 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di UINT24 in FAC

Macro: `m_Load_FAC_with_UINT24`, `m_Load_FAC_with_UINT24_Mem`, `m_Load_FAC_with_UINT24_Ptr`.

Converte il numero con la routine `FLOATB` della ROM del BASIC, che normalizza `FAC` e prende il segno dal Carry: la macro lo imposta a 1 (numero positivo). `ARG` non cambia.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Output | `FAC` (7 byte, ZP): Intero convertito, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC` |

<a id="utilita-m_load_fac_with_uint24"></a>
##### m_Load_FAC_with_UINT24

Chiamata: `+m_Load_FAC_with_UINT24 .value_`

Carica `FAC` con un intero senza segno a 24 bit, passato come costante, e azzera `FACOV`.

I bit del valore oltre il bit #23 sono ignorati.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (3 byte, Macro): Valore da caricare, senza segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_uint24_mem"></a>
##### m_Load_FAC_with_UINT24_Mem

Chiamata: `+m_Load_FAC_with_UINT24_Mem .addr_`

Carica `FAC` con un intero senza segno a 24 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian), e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (3 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_uint24_ptr"></a>
##### m_Load_FAC_with_UINT24_Ptr

Chiamata: `+m_Load_FAC_with_UINT24_Ptr .ptr_`

Carica `FAC` con un intero senza segno a 24 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (3 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di UINT24 in ARG

Macro: `m_Load_ARG_with_UINT24`, `m_Load_ARG_with_UINT24_Mem`, `m_Load_ARG_with_UINT24_Ptr`.

Il contenuto di `_SCRATCH_2` non è garantito dopo la chiamata.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Valore da conservare, registri da `FACEXP` a `FACOV` |
| Output | `ARG` (6 byte, ZP): Intero convertito, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Valore di prima, arrotondato, `FACOV` azzerato |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC`, `_SCRATCH_2` |

<a id="utilita-m_load_arg_with_uint24"></a>
##### m_Load_ARG_with_UINT24

Chiamata: `+m_Load_ARG_with_UINT24 .value_`

Carica `ARG` con un intero senza segno a 24 bit, passato come costante.

I bit del valore oltre il bit #23 sono ignorati.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_UINT24` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (3 byte, Macro): Valore da caricare, senza segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_uint24_mem"></a>
##### m_Load_ARG_with_UINT24_Mem

Chiamata: `+m_Load_ARG_with_UINT24_Mem .addr_`

Carica `ARG` con un intero senza segno a 24 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian).

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_UINT24_Mem` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (3 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_uint24_ptr"></a>
##### m_Load_ARG_with_UINT24_Ptr

Chiamata: `+m_Load_ARG_with_UINT24_Ptr .ptr_`

Carica `ARG` con un intero senza segno a 24 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_UINT24_Ptr` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (3 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di INT24 in FAC

Macro: `m_Load_FAC_with_INT24`, `m_Load_FAC_with_INT24_Mem`, `m_Load_FAC_with_INT24_Ptr`.

Converte il numero con la routine `FLOATB` della ROM del BASIC, che normalizza `FAC` e prende il segno dal Carry: la macro lo imposta a 1 per i numeri senza segno e, per quelli con segno, lo ricava dal bit #23 del MSB (complemento a due). `ARG` non cambia.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Output | `FAC` (7 byte, ZP): Intero convertito, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC` |

<a id="utilita-m_load_fac_with_int24"></a>
##### m_Load_FAC_with_INT24

Chiamata: `+m_Load_FAC_with_INT24 .value_`

Carica `FAC` con un intero con segno a 24 bit, passato come costante, e azzera `FACOV`.

I bit del valore oltre il bit #23 sono ignorati.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (3 byte, Macro): Valore da caricare, con segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_int24_mem"></a>
##### m_Load_FAC_with_INT24_Mem

Chiamata: `+m_Load_FAC_with_INT24_Mem .addr_`

Carica `FAC` con un intero con segno a 24 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian), e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (3 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_int24_ptr"></a>
##### m_Load_FAC_with_INT24_Ptr

Chiamata: `+m_Load_FAC_with_INT24_Ptr .ptr_`

Carica `FAC` con un intero con segno a 24 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (3 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di INT24 in ARG

Macro: `m_Load_ARG_with_INT24`, `m_Load_ARG_with_INT24_Mem`, `m_Load_ARG_with_INT24_Ptr`.

Il contenuto di `_SCRATCH_2` non è garantito dopo la chiamata.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Valore da conservare, registri da `FACEXP` a `FACOV` |
| Output | `ARG` (6 byte, ZP): Intero convertito, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Valore di prima, arrotondato, `FACOV` azzerato |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC`, `_SCRATCH_2` |

<a id="utilita-m_load_arg_with_int24"></a>
##### m_Load_ARG_with_INT24

Chiamata: `+m_Load_ARG_with_INT24 .value_`

Carica `ARG` con un intero con segno a 24 bit, passato come costante.

I bit del valore oltre il bit #23 sono ignorati.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_INT24` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (3 byte, Macro): Valore da caricare, con segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_int24_mem"></a>
##### m_Load_ARG_with_INT24_Mem

Chiamata: `+m_Load_ARG_with_INT24_Mem .addr_`

Carica `ARG` con un intero con segno a 24 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian).

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_INT24_Mem` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (3 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_int24_ptr"></a>
##### m_Load_ARG_with_INT24_Ptr

Chiamata: `+m_Load_ARG_with_INT24_Ptr .ptr_`

Carica `ARG` con un intero con segno a 24 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_INT24_Ptr` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (3 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di UINT32 in FAC

Macro: `m_Load_FAC_with_UINT32`, `m_Load_FAC_with_UINT32_Mem`, `m_Load_FAC_with_UINT32_Ptr`.

Converte il numero con la routine `FLOATB` della ROM del BASIC, che normalizza `FAC` e prende il segno dal Carry: la macro lo imposta a 1 (numero positivo). `ARG` non cambia.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Output | `FAC` (7 byte, ZP): Intero convertito, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC` |

<a id="utilita-m_load_fac_with_uint32"></a>
##### m_Load_FAC_with_UINT32

Chiamata: `+m_Load_FAC_with_UINT32 .value_`

Carica `FAC` con un intero senza segno a 32 bit, passato come costante, e azzera `FACOV`.

I bit del valore oltre il bit #31 sono ignorati.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (4 byte, Macro): Valore da caricare, senza segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_uint32_mem"></a>
##### m_Load_FAC_with_UINT32_Mem

Chiamata: `+m_Load_FAC_with_UINT32_Mem .addr_`

Carica `FAC` con un intero senza segno a 32 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian), e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (4 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_uint32_ptr"></a>
##### m_Load_FAC_with_UINT32_Ptr

Chiamata: `+m_Load_FAC_with_UINT32_Ptr .ptr_`

Carica `FAC` con un intero senza segno a 32 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (4 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di UINT32 in ARG

Macro: `m_Load_ARG_with_UINT32`, `m_Load_ARG_with_UINT32_Mem`, `m_Load_ARG_with_UINT32_Ptr`.

Il contenuto di `_SCRATCH_2` non è garantito dopo la chiamata.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Valore da conservare, registri da `FACEXP` a `FACOV` |
| Output | `ARG` (6 byte, ZP): Intero convertito, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Valore di prima, arrotondato, `FACOV` azzerato |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC`, `_SCRATCH_2` |

<a id="utilita-m_load_arg_with_uint32"></a>
##### m_Load_ARG_with_UINT32

Chiamata: `+m_Load_ARG_with_UINT32 .value_`

Carica `ARG` con un intero senza segno a 32 bit, passato come costante.

I bit del valore oltre il bit #31 sono ignorati.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_UINT32` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (4 byte, Macro): Valore da caricare, senza segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_uint32_mem"></a>
##### m_Load_ARG_with_UINT32_Mem

Chiamata: `+m_Load_ARG_with_UINT32_Mem .addr_`

Carica `ARG` con un intero senza segno a 32 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian).

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_UINT32_Mem` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (4 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_uint32_ptr"></a>
##### m_Load_ARG_with_UINT32_Ptr

Chiamata: `+m_Load_ARG_with_UINT32_Ptr .ptr_`

Carica `ARG` con un intero senza segno a 32 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_UINT32_Ptr` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (4 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di INT32 in FAC

Macro: `m_Load_FAC_with_INT32`, `m_Load_FAC_with_INT32_Mem`, `m_Load_FAC_with_INT32_Ptr`.

Converte il numero con la routine `FLOATB` della ROM del BASIC, che normalizza `FAC` e prende il segno dal Carry: la macro lo imposta a 1 per i numeri senza segno e, per quelli con segno, lo ricava dal bit #31 del MSB (complemento a due). `ARG` non cambia.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Output | `FAC` (7 byte, ZP): Intero convertito, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC` |

<a id="utilita-m_load_fac_with_int32"></a>
##### m_Load_FAC_with_INT32

Chiamata: `+m_Load_FAC_with_INT32 .value_`

Carica `FAC` con un intero con segno a 32 bit, passato come costante, e azzera `FACOV`.

I bit del valore oltre il bit #31 sono ignorati.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (4 byte, Macro): Valore da caricare, con segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_int32_mem"></a>
##### m_Load_FAC_with_INT32_Mem

Chiamata: `+m_Load_FAC_with_INT32_Mem .addr_`

Carica `FAC` con un intero con segno a 32 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian), e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (4 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_with_int32_ptr"></a>
##### m_Load_FAC_with_INT32_Ptr

Chiamata: `+m_Load_FAC_with_INT32_Ptr .ptr_`

Carica `FAC` con un intero con segno a 32 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo, e azzera `FACOV`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (4 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Caricamento di INT32 in ARG

Macro: `m_Load_ARG_with_INT32`, `m_Load_ARG_with_INT32_Mem`, `m_Load_ARG_with_INT32_Ptr`.

Il contenuto di `_SCRATCH_2` non è garantito dopo la chiamata.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Valore da conservare, registri da `FACEXP` a `FACOV` |
| Output | `ARG` (6 byte, ZP): Intero convertito, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Valore di prima, arrotondato, `FACOV` azzerato |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FAC`, `_SCRATCH_2` |

<a id="utilita-m_load_arg_with_int32"></a>
##### m_Load_ARG_with_INT32

Chiamata: `+m_Load_ARG_with_INT32 .value_`

Carica `ARG` con un intero con segno a 32 bit, passato come costante.

I bit del valore oltre il bit #31 sono ignorati.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_INT32` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.value_` (4 byte, Macro): Valore da caricare, con segno |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_int32_mem"></a>
##### m_Load_ARG_with_INT32_Mem

Chiamata: `+m_Load_ARG_with_INT32_Mem .addr_`

Carica `ARG` con un intero con segno a 32 bit, letto da un indirizzo assoluto, a partire dal LSB (little-endian).

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_INT32_Mem` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo dell'intero<br>`(.addr_)` (4 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_with_int32_ptr"></a>
##### m_Load_ARG_with_INT32_Ptr

Chiamata: `+m_Load_ARG_with_INT32_Ptr .ptr_`

Carica `ARG` con un intero con segno a 32 bit, letto dall'indirizzo indicato da un puntatore in ZP, LSB per primo.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, carica `FAC` con la macro `m_Load_FAC_with_INT32_Ptr` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; il vecchio `ARG` si perde e `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 byte, Macro): Indirizzo in ZP del puntatore<br>`(.ptr_)` (2 byte, ZP): Indirizzo dell'intero (LSB, MSB)<br>`((.ptr_))` (4 byte, RAM): Intero, LSB per primo |

[↑ Torna al contenuto](#contenuto)

#### Conversione in INT32

Macro: `m_Convert_FAC_into_INT32`, `m_Convert_ARG_into_INT32`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

<a id="utilita-m_convert_fac_into_int32"></a>
##### m_Convert_FAC_into_INT32

Converte il numero in virgola mobile di `FAC` in un intero a 32 bit con segno, arrotondato per difetto (verso -infinito, tenendo conto anche di `FACOV`). Il numero deve stare nell'intervallo da -2147483647 a 2 147 483 647; fuori da questo intervallo il risultato è indefinito.

L'intero, in complemento a due, va nei 4 byte della mantissa, con il MSB in `FACHO`. Per ottenere un intero a 24, 16 o 8 bit, se il valore ci sta, si leggono gli ultimi 3, 2 o 1 byte, cioè da `FACMOH`, da `FACMO` o `FACLO`. `FACEXP` e `FACSGN` non cambiano, ma `FAC` non è più un numero valido; `FACOV` contiene i bit scartati.

Chiama la routine `QINT` della ROM del BASIC, che usa la cella `$68` (byte di overflow di `FAC`): deve valere zero in ingresso, e la routine la azzera in uscita.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `FACHO` (4 byte, ZP): Intero con segno, da `FACHO` a `FACLO`, MSB per primo |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_convert_arg_into_int32"></a>
##### m_Convert_ARG_into_INT32

Converte il numero in virgola mobile di `ARG` in un intero a 32 bit con segno, arrotondato per difetto (verso -infinito). Il numero deve stare nell'intervallo da -2147483647 a 2 147 483 647; fuori da questo intervallo il risultato è indefinito.

L'intero, in complemento a due, va nei 4 byte della mantissa di `ARG`, con il MSB in `ARGHO`. Per ottenere un intero a 24, 16 o 8 bit, se il valore ci sta, si leggono gli ultimi 3, 2 o 1 byte, cioè da `ARGMOH`, da `ARGMO` o `ARGLO`. `ARGEXP` e `ARGSGN` non cambiano, ma `ARG` non è più un numero valido. `ARISGN` non viene aggiornato.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, converte con la routine `QINT` della ROM del BASIC, azzera `FACOV` e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero. La macro azzera `FACOV` perché `QINT` vi lascia i bit scartati, che lo Swap userebbe per arrotondare l'intero.

`QINT` usa la cella `$68` (byte di overflow di `FAC`): deve valere zero in ingresso, e la routine la azzera in uscita. Il contenuto di `_SCRATCH_2` non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Valore da conservare, registri da `FACEXP` a `FACOV` |
| Output | `ARGHO` (4 byte, ZP): Intero con segno, da `ARGHO` a `ARGLO`, MSB per primo<br>`FAC` (7 byte, ZP): Valore di prima, arrotondato, `FACOV` azzerato |
| Registri Modificati | `FAC`, `_SCRATCH_2` |

[↑ Torna al contenuto](#contenuto)

### fp_io.asm

Macro per convertire i numeri in virgola mobile (formato MBF) in stringhe e viceversa, e per stamparli. Le macro di conversione in stringa e di stampa preservano sempre `FAC` e `ARG`; `m_String_to_FAC` preserva `ARG` se l'interruttore `__PRESERVE_ARG` di config.asm vale 1; `m_String_to_ARG` preserva sempre `FAC`.

#### Conversione in stringa

Macro: `m_FAC_to_String`, `m_ARG_to_String`.

La stringa, terminata da zero, è lunga al massimo 15 caratteri più il terminatore: ha uno spazio o il segno meno davanti, e usa la forma esponenziale (1E+10) quando serve. Si trova in `STACK`, da `$0100` in poi.

La ROM altera queste celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `INDEX`, `INDEX2`, `RESHO`, `$47`, `$56`, `$5D`-`$5E` e `$71`.

Per l'accuratezza della conversione vedi [Nota #08 di `math/fp.asm`](#nota-fp-08).

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Output | `STACK` (16 byte, RAM): Stringa terminata da zero, da `$0100`<br>`FAC` (7 byte, ZP): Invariato<br>`ARG` (6 byte, ZP): Invariato |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `_SCRATCH_1`, `_SCRATCH_2`, `STACK` (16 byte) |

<a id="utilita-m_fac_to_string"></a>
##### m_FAC_to_String

Converte il numero in virgola mobile di `FAC` in una stringa e la scrive in `STACK`.

Chiama la routine `FOUT` della ROM del BASIC, che altera `FAC` e `ARG`. Con `m_Store_FAC_in_Scratch` e `m_Store_ARG_in_Scratch` la macro salva `FAC` in `_SCRATCH_1` e `ARG` in `_SCRATCH_2` prima della chiamata e li ripristina dopo. Per le variabili del BASIC alterate vedi [Nota #06 di `math/fp.asm`](#nota-fp-06).

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_arg_to_string"></a>
##### m_ARG_to_String

Converte il numero in virgola mobile di `ARG` in una stringa e la scrive in `STACK`.

Copia prima `ARG` in `FAC` con `m_Transfer_ARG_to_FAC`, poi chiama la routine `FOUT` della ROM del BASIC, che altera `FAC` e `ARG`. Con `m_Store_FAC_in_Scratch` e `m_Store_ARG_in_Scratch` la macro salva `FAC` in `_SCRATCH_1` e `ARG` in `_SCRATCH_2` prima della copia e li ripristina dopo. Per le variabili del BASIC alterate vedi [Nota #06 di `math/fp.asm`](#nota-fp-06).

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

#### Conversione da stringa

Macro: `m_String_to_FAC`, `m_String_to_ARG`.

La stringa, terminata da zero, rappresenta un numero: spazi iniziali, segno opzionale, cifre, punto decimale ed esponente, introdotto dal carattere E (codice `$45`) con segno opzionale. La conversione si ferma al primo carattere non valido, senza errori; senza un numero il risultato è zero. Un esponente troppo piccolo dà zero.

La macro scrive l'indirizzo della stringa in `TXTPTR`, il puntatore al testo del BASIC, e la ROM lo fa avanzare fino al primo carattere dopo il numero. Per le variabili del BASIC alterate vedi [Nota #06 di `math/fp.asm`](#nota-fp-06).

Se il numero è troppo grande la ROM segnala OVERFLOW ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

La ROM altera queste celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `INDEX`, `RESHO`, `$56`, `$5D`-`$60` e `$67`.

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo della stringa<br>`(.addr_)` (n byte, RAM): Stringa terminata da zero |
| Output | `TXTPTR` (2 byte, ZP): Indirizzo del primo carattere dopo il numero<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `TXTPTR`, `__FP_SAVED_SP` |

<a id="utilita-m_string_to_fac"></a>
##### m_String_to_FAC

Chiamata: `+m_String_to_FAC .addr_`

Converte una stringa in un numero in virgola mobile e lo scrive in `FAC`, che perde il suo vecchio contenuto.

Dopo avere scritto `TXTPTR`, la macro chiama `CHRGOT`, che legge il primo carattere, e `FIN` della ROM del BASIC. `FIN` altera sempre `ARG`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in `_SCRATCH_2` prima della conversione e lo ripristina dopo; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero.

| Voce | Specifico di questa macro |
|---|---|
| Input | `__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Numero convertito, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito |
| Registri Modificati | `_SCRATCH_2` (se `__PRESERVE_ARG` = 1) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_string_to_arg"></a>
##### m_String_to_ARG

Chiamata: `+m_String_to_ARG .addr_`

Converte una stringa in un numero in virgola mobile e lo scrive in `ARG`, che perde il suo vecchio contenuto. `FAC` non cambia.

Dopo avere scritto `TXTPTR`, la macro chiama `CHRGOT`, che legge il primo carattere, e `FIN` della ROM del BASIC, che converte la stringa in `FAC` e altera `ARG`; poi chiama `MOVAF` per copiare `FAC` in `ARG`. Con `m_Store_FAC_in_Scratch` la macro salva `FAC` in `_SCRATCH_1` prima della conversione e con `m_Load_FAC_from_Scratch` lo ripristina dopo.

| Voce | Specifico di questa macro |
|---|---|
| Output | `ARG` (6 byte, ZP): Numero convertito, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Invariato |
| Registri Modificati | `_SCRATCH_1` |

[↑ Torna al contenuto](#contenuto)

#### Stampa

Macro: `m_Print_FAC`, `m_Print_ARG`.

La stringa, terminata da zero, è lunga al massimo 15 caratteri più il terminatore: ha uno spazio o il segno meno davanti, e usa la forma esponenziale (1E+10) quando serve. Si trova in `STACK`, da `$0100` in poi.

La stringa è stampata con la subroutine `__PUT_STRING`, un punto di personalizzazione di config.asm: per default è `STROUT` della ROM del BASIC. Una subroutine alternativa deve stampare la stringa in `STACK`, terminata da `$00`; ne riceve l'indirizzo in `.A` (LSB) e `.Y` (MSB).

La ROM altera queste celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `INDEX`, `INDEX2`, `RESHO`, `$47`, `$56`, `$5D`-`$5E` e `$71`.

La subroutine `__PUT_STRING` può alterare a sua volta registri e celle, che non sono elencati qui.

Per l'accuratezza della conversione vedi [Nota #08 di `math/fp.asm`](#nota-fp-08).

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `__PUT_STRING` (2 byte, Macro): Indirizzo della subroutine di stampa |
| Output | `STACK` (16 byte, RAM): Stringa terminata da zero, da `$0100`<br>`FAC` (7 byte, ZP): Invariato<br>`ARG` (6 byte, ZP): Invariato |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `_SCRATCH_1`, `_SCRATCH_2`, `STACK` (16 byte) |

<a id="utilita-m_print_fac"></a>
##### m_Print_FAC

Converte il numero in virgola mobile di `FAC` in una stringa e la stampa.

Chiama la routine `FOUT` della ROM del BASIC, che altera `FAC` e `ARG`, e poi `__PUT_STRING` con l'indirizzo di `STACK`. Con `m_Store_FAC_in_Scratch` e `m_Store_ARG_in_Scratch` la macro salva `FAC` in `_SCRATCH_1` e `ARG` in `_SCRATCH_2` prima della chiamata e li ripristina dopo. Per le variabili del BASIC alterate vedi [Nota #06 di `math/fp.asm`](#nota-fp-06).

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_print_arg"></a>
##### m_Print_ARG

Converte il numero in virgola mobile di `ARG` in una stringa e la stampa.

Copia prima `ARG` in `FAC` con `m_Transfer_ARG_to_FAC`, poi chiama la routine `FOUT` della ROM del BASIC, che altera `FAC` e `ARG`, e poi `__PUT_STRING` con l'indirizzo di `STACK`. Con `m_Store_FAC_in_Scratch` e `m_Store_ARG_in_Scratch` la macro salva `FAC` in `_SCRATCH_1` e `ARG` in `_SCRATCH_2` prima della copia e li ripristina dopo. Per le variabili del BASIC alterate vedi [Nota #06 di `math/fp.asm`](#nota-fp-06).

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

### fp_memory.asm

Macro per copiare numeri in virgola mobile (formato MBF) tra la memoria, `FAC` e `ARG`, e per scambiare `FAC` e `ARG`.

#### Caricamento da memoria

Macro: `m_Load_FAC_from_Mem`, `m_Load_FAC_from_Ptr`, `m_Load_ARG_from_Mem`, `m_Load_ARG_from_Ptr`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Registri Modificati | `.A`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

<a id="utilita-m_load_fac_from_mem"></a>
##### m_Load_FAC_from_Mem

Chiamata: `+m_Load_FAC_from_Mem .addr_`

Carica `FAC` con il numero in virgola mobile, in formato MBF (5 byte), che si trova a un indirizzo assoluto, e azzera `FACOV`.

Chiama la routine `MOVFM` della ROM del BASIC, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (2 byte, Macro): Indirizzo del numero da caricare<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Numero caricato, registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_fac_from_ptr"></a>
##### m_Load_FAC_from_Ptr

Chiamata: `+m_Load_FAC_from_Ptr .ptr_`

Carica `FAC` con il numero in virgola mobile, in formato MBF (5 byte), a cui punta un puntatore, e azzera `FACOV`.

Chiama la routine `MOVFM` della ROM del BASIC, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Numero caricato, registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_from_mem"></a>
##### m_Load_ARG_from_Mem

Chiamata: `+m_Load_ARG_from_Mem .addr_`

Carica `ARG` con il numero in virgola mobile, in formato MBF (5 byte), che si trova a un indirizzo assoluto. `FAC` non cambia.

Chiama la routine `CONUPK` della ROM del BASIC, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. `CONUPK` aggiorna `ARISGN`: il bit #7 vale 1 se i segni di `FAC` e di `ARG` sono diversi.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (2 byte, Macro): Indirizzo del numero da caricare<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Output | `ARG` (6 byte, ZP): Numero caricato, registri da `ARGEXP` a `ARGSGN`<br>`ARISGN` (1 byte, ZP): Bit #7: 0 = segni uguali; 1 = segni diversi |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_load_arg_from_ptr"></a>
##### m_Load_ARG_from_Ptr

Chiamata: `+m_Load_ARG_from_Ptr .ptr_`

Carica `ARG` con il numero in virgola mobile, in formato MBF (5 byte), a cui punta un puntatore. `FAC` non cambia.

Chiama la routine `CONUPK` della ROM del BASIC, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. `CONUPK` aggiorna `ARISGN`: il bit #7 vale 1 se i segni di `FAC` e di `ARG` sono diversi.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Output | `ARG` (6 byte, ZP): Numero caricato, registri da `ARGEXP` a `ARGSGN`<br>`ARISGN` (1 byte, ZP): Bit #7: 0 = segni uguali; 1 = segni diversi |

[↑ Torna al contenuto](#contenuto)

#### Scrittura in memoria

Macro: `m_Store_FAC_to_Mem`, `m_Store_FAC_to_Ptr`, `m_Store_ARG_to_Mem`, `m_Store_ARG_to_Ptr`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Registri Modificati | `.A` |

<a id="utilita-m_store_fac_to_mem"></a>
##### m_Store_FAC_to_Mem

Chiamata: `+m_Store_FAC_to_Mem .addr_`

Scrive `FAC` in formato MBF (5 byte) a un indirizzo assoluto. `FAC` viene prima arrotondato, perché il formato in memoria non ha il byte di arrotondamento: dopo la chiamata `FAC` contiene il valore arrotondato e `FACOV` vale zero.

Chiama la routine `MOVMF` della ROM del BASIC, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (2 byte, Macro): Indirizzo di destinazione |
| Output | `.addr_` (5 byte, Macro): Riceve `FAC` in formato MBF<br>`FAC` (7 byte, ZP): Arrotondato, `FACOV` azzerato |
| Registri Modificati | `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_store_fac_to_ptr"></a>
##### m_Store_FAC_to_Ptr

Chiamata: `+m_Store_FAC_to_Ptr .ptr_`

Scrive `FAC` in formato MBF (5 byte) a un indirizzo a cui punta un puntatore. `FAC` viene prima arrotondato, perché il formato in memoria non ha il byte di arrotondamento: dopo la chiamata `FAC` contiene il valore arrotondato e `FACOV` vale zero.

Chiama la routine `MOVMF` della ROM del BASIC, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo di destinazione (LSB, MSB) |
| Output | `((.ptr_))` (5 byte, RAM): Riceve `FAC` in formato MBF<br>`FAC` (7 byte, ZP): Arrotondato, `FACOV` azzerato |
| Registri Modificati | `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_store_arg_to_mem"></a>
##### m_Store_ARG_to_Mem

Chiamata: `+m_Store_ARG_to_Mem .addr_`

Scrive `ARG` in formato MBF (5 byte) a un indirizzo assoluto, senza chiamare la ROM del BASIC. Nel MSB della mantissa il bit #7, che in `ARG` è sempre 1, è sostituito dal segno. `ARG` non cambia e non va arrotondato, perché lo è già.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (2 byte, Macro): Indirizzo di destinazione<br>`ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `.addr_` (5 byte, Macro): Riceve `ARG` in formato MBF |
| Registri Modificati | `.P` (Negative, Zero) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_store_arg_to_ptr"></a>
##### m_Store_ARG_to_Ptr

Chiamata: `+m_Store_ARG_to_Ptr .ptr_`

Scrive `ARG` in formato MBF (5 byte) a un indirizzo a cui punta un puntatore, senza chiamare la ROM del BASIC. Nel MSB della mantissa il bit #7, che in `ARG` è sempre 1, è sostituito dal segno. `ARG` non cambia e non va arrotondato, perché lo è già.

L'indirizzo di destinazione passa per `INDEX`, il puntatore temporaneo che la ROM usa per queste operazioni.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo di destinazione (LSB, MSB)<br>`ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `((.ptr_))` (5 byte, RAM): Riceve `ARG` in formato MBF |
| Registri Modificati | `.X`, `.Y`, `.P` (Negative, Zero), `INDEX`, `INDEX`+1 |

[↑ Torna al contenuto](#contenuto)

#### Trasferimento tra FAC e ARG

Macro: `m_Transfer_FAC_to_ARG`, `m_Transfer_ARG_to_FAC`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry) |

<a id="utilita-m_transfer_fac_to_arg"></a>
##### m_Transfer_FAC_to_ARG

Copia `FAC` in `ARG`. `FAC` viene prima arrotondato, perché `ARG` non può contenere un valore non arrotondato: dopo la chiamata `FAC` contiene il valore arrotondato e `FACOV` vale zero. `ARISGN` non viene aggiornato.

Chiama la routine `MOVAF` della ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `ARG` (6 byte, ZP): Copia di `FAC`, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Arrotondato, `FACOV` azzerato |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_transfer_arg_to_fac"></a>
##### m_Transfer_ARG_to_FAC

Copia `ARG` in `FAC` e azzera `FACOV`. `ARG` e `ARISGN` non cambiano.

Chiama la routine `MOVFA` della ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `FAC` (7 byte, ZP): Copia di `ARG`, `FACOV` azzerato |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_swap_fac_and_arg"></a>
#### m_Swap_FAC_and_ARG

Scambia `FAC` e `ARG`. `FAC` viene prima arrotondato, perché `ARG` non può contenere un valore non arrotondato: dopo lo scambio `FACOV` vale zero. `ARISGN` non viene aggiornato.

Salva `ARG` in `_SCRATCH_2` e chiama la routine `MOVAF` della ROM del BASIC. Il contenuto di `_SCRATCH_2` non è garantito dopo la chiamata.

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `FAC` (7 byte, ZP): Valore di `ARG`, `FACOV` azzerato<br>`ARG` (6 byte, ZP): Valore di `FAC`, arrotondato |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `FAC`, `_SCRATCH_2` |

[↑ Torna al contenuto](#contenuto)

### fp_poly.asm

Macro per calcolare polinomi e polinomi dispari a coefficienti in virgola mobile (formato MBF). Il punto in cui calcolarli è in `FAC`, la tabella dei coefficienti è a un indirizzo assoluto o puntata da un puntatore; il risultato è in `FAC`. L'interruttore `__PRESERVE_ARG` di config.asm decide se `ARG` viene preservato.

#### Polinomio

Macro: `m_Poly_Mem`, `m_Poly_Ptr`.

Il primo byte della tabella è n; seguono n+1 numeri in formato MBF, i coefficienti da `a_n` ad `a_0`. Il valore di n deve essere almeno 1: con n = 0 la ROM esegue 256 iterazioni sui byte che seguono la tabella e di solito segnala OVERFLOW ERROR.

Chiama la routine `POLY2` della ROM del BASIC, che usa il metodo di Horner. Se un risultato intermedio è troppo grande la ROM segnala OVERFLOW ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

La ROM altera molte celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `INDEX`, `RESHO`, `$56`, `$5C`-`$60`, `$67` e `$71`-`$72`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in formato MBF in `STACK` (`$0100`-`$0104`) prima della chiamata e lo ripristina dopo, perché la ROM usa `NUMWRK`, dove si trova `_SCRATCH_2`; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero. Il contenuto di `STACK` non è garantito dopo la chiamata.

Per l'accuratezza del risultato vedi [Nota #08 di `math/fp.asm`](#nota-fp-08).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Punto x, registri da `FACEXP` a `FACOV`<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Valore del polinomio, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `STACK` (5 byte, se `__PRESERVE_ARG` = 1), `__FP_SAVED_SP` |

<a id="utilita-m_poly_mem"></a>
##### m_Poly_Mem

Chiamata: `+m_Poly_Mem .addr_`

Calcola in `FAC` il valore di un polinomio di grado n nel punto x che è in `FAC`: `FAC` = `a_n*`x^n + `a_`(n-1)\*x^(n-1) + ... + `a_1*`x + `a_0`. I coefficienti sono in una tabella a un indirizzo assoluto.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo della tabella<br>`(.addr_)` (1 byte, RAM): Valore di n, almeno 1<br>`(.addr_`+1) (5\*n+5 byte, RAM): Coefficienti in formato MBF |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_poly_ptr"></a>
##### m_Poly_Ptr

Chiamata: `+m_Poly_Ptr .ptr_`

Calcola in `FAC` il valore di un polinomio di grado n nel punto x che è in `FAC`: `FAC` = `a_n*`x^n + `a_`(n-1)\*x^(n-1) + ... + `a_1*`x + `a_0`. I coefficienti sono in una tabella all'indirizzo a cui punta un puntatore.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo della tabella (LSB, MSB)<br>`((.ptr_))` (1 byte, RAM): Valore di n, almeno 1<br>`((.ptr_)`+1) (5\*n+5 byte, RAM): Coefficienti in formato MBF |

[↑ Torna al contenuto](#contenuto)

#### Polinomio dispari

Macro: `m_Odd_Poly_Mem`, `m_Odd_Poly_Ptr`.

Il primo byte della tabella è d = (n-1)/2; seguono d+1 numeri in formato MBF, i coefficienti da `a_n` ad `a_1`. Il valore di d deve essere almeno 1: con d = 0 la ROM esegue 256 iterazioni sui byte che seguono la tabella e di solito segnala OVERFLOW ERROR.

Chiama la routine `POLY1` della ROM del BASIC, che usa il metodo di Horner. Se un risultato intermedio è troppo grande la ROM segnala OVERFLOW ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

La ROM altera molte celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `INDEX`, `RESHO`, `$56`, `NUMWRK`, `$67` e `$71`-`$72`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in formato MBF in `STACK` (`$0100`-`$0104`) prima della chiamata e lo ripristina dopo, perché la ROM usa `NUMWRK`, dove si trova `_SCRATCH_2`; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero. Il contenuto di `STACK` non è garantito dopo la chiamata.

Per l'accuratezza del risultato vedi [Nota #08 di `math/fp.asm`](#nota-fp-08).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Punto x, registri da `FACEXP` a `FACOV`<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Valore del polinomio, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `STACK` (5 byte, se `__PRESERVE_ARG` = 1), `__FP_SAVED_SP` |

<a id="utilita-m_odd_poly_mem"></a>
##### m_Odd_Poly_Mem

Chiamata: `+m_Odd_Poly_Mem .addr_`

Calcola in `FAC` il valore di un polinomio dispari di grado n, con n dispari, nel punto x che è in `FAC`: `FAC` = `a_n*`x^n + `a_`(n-2)\*x^(n-2) + ... + `a_3*`x^3 + `a_1*`x. I coefficienti sono in una tabella a un indirizzo assoluto.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo della tabella<br>`(.addr_)` (1 byte, RAM): Valore di d, almeno 1<br>`(.addr_`+1) (5\*d+5 byte, RAM): Coefficienti in formato MBF |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_odd_poly_ptr"></a>
##### m_Odd_Poly_Ptr

Chiamata: `+m_Odd_Poly_Ptr .ptr_`

Calcola in `FAC` il valore di un polinomio dispari di grado n, con n dispari, nel punto x che è in `FAC`: `FAC` = `a_n*`x^n + `a_`(n-2)\*x^(n-2) + ... + `a_3*`x^3 + `a_1*`x. I coefficienti sono in una tabella all'indirizzo a cui punta un puntatore.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo della tabella (LSB, MSB)<br>`((.ptr_))` (1 byte, RAM): Valore di d, almeno 1<br>`((.ptr_)`+1) (5\*d+5 byte, RAM): Coefficienti in formato MBF |

[↑ Torna al contenuto](#contenuto)

### fp_power.asm

Macro per l'elevamento a potenza e la radice quadrata di numeri in virgola mobile (formato MBF). La base può essere in `ARG`, a un indirizzo assoluto o puntata da un puntatore; il risultato è sempre in `FAC`. L'interruttore `__PRESERVE_ARG` di config.asm decide se `ARG` viene preservato.

#### Elevamento a potenza

Macro: `m_Power_ARG_to_FAC`, `m_Power_Mem_to_FAC`, `m_Power_Ptr_to_FAC`.

Chiama la routine `FPWRT` della ROM del BASIC, che calcola EXP(LOG(`ARG`) x `FAC`). I casi particolari sono: se `FAC` è zero il risultato è 1, anche con base zero; se la base è zero, e `FAC` non lo è, il risultato è zero, anche con esponente negativo; con base negativa l'esponente deve essere intero, altrimenti la ROM segnala ILLEGAL QUANTITY ERROR; se il risultato è troppo grande la ROM segnala OVERFLOW ERROR, se è troppo piccolo il risultato è zero. Se la ROM segnala un errore non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

La ROM altera molte celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `$07`, `INDEX`, `INDEX2`, `RESHO`, `$4E`-`$52`, `$56`, `NUMWRK`, `$67` e `$71`-`$72`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in formato MBF in `STACK` (`$0100`-`$0104`) prima della chiamata e lo ripristina dopo, perché la ROM usa `NUMWRK`, dove si trova `_SCRATCH_2`; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero. Il contenuto di `STACK` non è garantito dopo la chiamata.

Per l'accuratezza del risultato vedi [Nota #11 di `math/fp.asm`](#nota-fp-11), [Nota #12 di `math/fp.asm`](#nota-fp-12) e [Nota #08 di `math/fp.asm`](#nota-fp-08).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV`<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Risultato, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `INDEX2`, `STACK` (5 byte, se `__PRESERVE_ARG` = 1), `__FP_SAVED_SP` |

<a id="utilita-m_power_arg_to_fac"></a>
##### m_Power_ARG_to_FAC

Eleva il numero in virgola mobile di `ARG` alla potenza di `FAC` e lascia il risultato in `FAC`: `FAC` = `ARG` ^ `FAC`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_power_mem_to_fac"></a>
##### m_Power_Mem_to_FAC

Chiamata: `+m_Power_Mem_to_FAC .addr_`

Eleva il numero in formato MBF che si trova a un indirizzo assoluto alla potenza di `FAC` e lascia il risultato in `FAC`: `FAC` = `(.addr_)` ^ `FAC`.

Carica prima il numero in `ARG` con `m_Load_ARG_from_Mem`, che aggiorna `ARISGN` e altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_power_ptr_to_fac"></a>
##### m_Power_Ptr_to_FAC

Chiamata: `+m_Power_Ptr_to_FAC .ptr_`

Eleva il numero in formato MBF che si trova all'indirizzo a cui punta un puntatore alla potenza di `FAC` e lascia il risultato in `FAC`: `FAC` = `((.ptr_))` ^ `FAC`.

Carica prima il numero in `ARG` con `m_Load_ARG_from_Ptr`, che aggiorna `ARISGN` e altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

#### Radice quadrata

Macro: `m_SQR_FAC`, `m_SQR_ARG`, `m_SQR_Mem`, `m_SQR_Ptr`.

Chiama la routine SQR della ROM del BASIC, che copia `FAC` in `ARG`, carica 0.5 in `FAC` e chiama `FPWRT`: calcola quindi `ARG` ^ 0.5. La radice di zero è zero; se il numero è negativo la ROM segnala ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

La ROM altera molte celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `$07`, `INDEX`, `INDEX2`, `RESHO`, `$4E`-`$52`, `$56`, `NUMWRK`, `$67` e `$71`-`$72`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in formato MBF in `STACK` (`$0100`-`$0104`) prima della chiamata e lo ripristina dopo, perché la ROM usa `NUMWRK`, dove si trova `_SCRATCH_2`; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero. Il contenuto di `STACK` non è garantito dopo la chiamata.

Per l'accuratezza del risultato vedi [Nota #09 di `math/fp.asm`](#nota-fp-09) e [Nota #08 di `math/fp.asm`](#nota-fp-08).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Radice quadrata, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `INDEX2`, `STACK` (5 byte, se `__PRESERVE_ARG` = 1), `__FP_SAVED_SP` |

<a id="utilita-m_sqr_fac"></a>
##### m_SQR_FAC

Calcola la radice quadrata del numero in virgola mobile di `FAC` e lascia il risultato in `FAC`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sqr_arg"></a>
##### m_SQR_ARG

Calcola la radice quadrata del numero in virgola mobile di `ARG` e lascia il risultato in `FAC`, che perde il suo vecchio contenuto.

Copia prima `ARG` in `FAC` con `m_Transfer_ARG_to_FAC`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sqr_mem"></a>
##### m_SQR_Mem

Chiamata: `+m_SQR_Mem .addr_`

Calcola la radice quadrata del numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`, che perde il suo vecchio contenuto.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Mem`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sqr_ptr"></a>
##### m_SQR_Ptr

Chiamata: `+m_SQR_Ptr .ptr_`

Calcola la radice quadrata del numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`, che perde il suo vecchio contenuto.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Ptr`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

### fp_random.asm

Macro per generare numeri pseudocasuali in virgola mobile (formato MBF) con la routine RND della ROM del BASIC, e per inizializzare il generatore. L'interruttore `__PRESERVE_ARG` di config.asm decide se `ARG` viene preservato.

<a id="utilita-m_load_fac_with_rnd"></a>
#### m_Load_FAC_with_RND

Genera in `FAC` un numero pseudocasuale in virgola mobile tra 0 e 1, 1 escluso, con la routine RND della ROM del BASIC. Il generatore deve essere inizializzato prima: vedi `m_Randomize`.

Il segno di `FAC` prima della chiamata decide il comportamento. Con `FAC` > 0 `FAC` è sostituito dal numero successivo della sequenza e il suo valore non conta. Con `FAC` = 0 il numero deriva dai registri dei timer del CIA #1. Con `FAC` < 0 il generatore è reinizializzato con il numero che è in `FAC`, e `FAC` contiene il nuovo seme: con un seme piccolo è un numero molto piccolo.

Un seme negativo genera sempre la stessa sequenza: è utile per collaudo e debug. Per i limiti del caso `FAC` = 0 e per le altre particolarità di RND vedi [Nota #10 di `math/fp.asm`](#nota-fp-10).

La ROM altera queste celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `INDEX`, `RESHO` e `$56`. Aggiorna inoltre il seme, in `RNDX`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in `_SCRATCH_2` prima della chiamata e lo ripristina dopo, perché con `FAC` > 0 la ROM altera `ARG`; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero.

Con `FAC` > 0 la ROM usa una moltiplicazione: per l'accuratezza vedi [Nota #08 di `math/fp.asm`](#nota-fp-08).

| Voce | Contenuto |
|---|---|
| Input | `FAC` (7 byte, ZP): Segno: > 0 numero successivo; = 0 seme dal CIA #1; < 0 nuovo seme<br>`__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Numero tra 0 e 1, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito<br>`RNDX` (5 byte, ZP): Seme aggiornato, da `RNDX`+0 a `RNDX`+4 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `RNDX` (5 byte), `_SCRATCH_2` (se `__PRESERVE_ARG` = 1) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_randomize"></a>
#### m_Randomize

Inizializza il generatore di numeri pseudocasuali con -TI, cioè con il valore dell'orologio jiffy TIME, cambiato di segno. Poiché TI ha 24 bit, 8 bit del seme sarebbero sempre 0, e questo limita i semi possibili.

Per aggiungere casualità, il numero positivo tra 0 e 1 che la ROM genera con il primo seme è negato e usato come secondo seme: così tutti i 32 bit della mantissa sono valorizzati. Alla fine `FAC` contiene il seme in uso, un numero positivo tra 0 e 1.

La macro usa solo i rami di RND con `FAC` negativo, che non alterano `ARG`: per questo non ha bisogno di preservarlo e l'interruttore `__PRESERVE_ARG` non ha effetto. Per le particolarità di RND vedi [Nota #10 di `math/fp.asm`](#nota-fp-10).

La ROM altera la cella di lavoro `INDEX`, il cui contenuto non è garantito dopo la chiamata. Aggiorna inoltre il seme, in `RNDX`.

| Voce | Contenuto |
|---|---|
| Input | `TIME` (3 byte, ZP): Orologio jiffy |
| Output | `FAC` (7 byte, ZP): Seme in uso, numero tra 0 e 1<br>`ARG` (6 byte, ZP): Invariato<br>`RNDX` (5 byte, ZP): Nuovo seme, da `RNDX`+0 a `RNDX`+4 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `INDEX`, `RNDX` (5 byte) |

[↑ Torna al contenuto](#contenuto)

### fp_transcend.asm

Macro per le funzioni trascendenti sui numeri in virgola mobile (formato MBF): logaritmo naturale ed esponenziale (e elevato a un numero). L'argomento può essere in `FAC`, in `ARG`, a un indirizzo assoluto o puntato da un puntatore; il risultato è sempre in `FAC`. L'interruttore `__PRESERVE_ARG` di config.asm decide se `ARG` viene preservato.

#### Logaritmo naturale

Macro: `m_LOG_FAC`, `m_LOG_ARG`, `m_LOG_Mem`, `m_LOG_Ptr`.

Chiama la routine LOG della ROM del BASIC. Se il numero è zero o negativo la ROM segnala ILLEGAL QUANTITY ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07). LOG(1) vale zero.

La ROM altera molte celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `$07`, `INDEX`, `RESHO`, `$56`, `NUMWRK`, `$67` e `$71`-`$72`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in formato MBF in `STACK` (`$0100`-`$0104`) prima della chiamata e lo ripristina dopo, perché la ROM usa `NUMWRK`, dove si trova `_SCRATCH_2`; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero. Il contenuto di `STACK` non è garantito dopo la chiamata.

Per l'accuratezza del risultato vedi [Nota #11 di `math/fp.asm`](#nota-fp-11) e [Nota #08 di `math/fp.asm`](#nota-fp-08).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Logaritmo, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `STACK` (5 byte, se `__PRESERVE_ARG` = 1), `__FP_SAVED_SP` |

<a id="utilita-m_log_fac"></a>
##### m_LOG_FAC

Calcola il logaritmo naturale del numero in virgola mobile di `FAC` e lascia il risultato in `FAC`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_log_arg"></a>
##### m_LOG_ARG

Calcola il logaritmo naturale di `ARG` e lascia il risultato in `FAC`, che perde il suo vecchio contenuto.

Copia prima `ARG` in `FAC` con `m_Transfer_ARG_to_FAC`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_log_mem"></a>
##### m_LOG_Mem

Chiamata: `+m_LOG_Mem .addr_`

Calcola il logaritmo naturale del numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`, che perde il suo vecchio contenuto.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Mem`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_log_ptr"></a>
##### m_LOG_Ptr

Chiamata: `+m_LOG_Ptr .ptr_`

Calcola il logaritmo naturale del numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`, che perde il suo vecchio contenuto.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Ptr`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

#### Esponenziale

Macro: `m_EXP_FAC`, `m_EXP_ARG`, `m_EXP_Mem`, `m_EXP_Ptr`.

Chiama la routine EXP della ROM del BASIC. Se il risultato è troppo grande, cioè per un numero da circa 88.03 in su, la ROM segnala OVERFLOW ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07); se è troppo piccolo il risultato è zero. EXP(0) vale 1.

La ROM altera molte celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `$07`, `INDEX`, `RESHO`, `$56`, `NUMWRK`, `$67` e `$71`-`$72`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in formato MBF in `STACK` (`$0100`-`$0104`) prima della chiamata e lo ripristina dopo, perché la ROM usa `NUMWRK`, dove si trova `_SCRATCH_2`; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero. Il contenuto di `STACK` non è garantito dopo la chiamata.

Per l'accuratezza del risultato vedi [Nota #12 di `math/fp.asm`](#nota-fp-12) e [Nota #08 di `math/fp.asm`](#nota-fp-08).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Risultato, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `STACK` (5 byte, se `__PRESERVE_ARG` = 1), `__FP_SAVED_SP` |

<a id="utilita-m_exp_fac"></a>
##### m_EXP_FAC

Calcola e elevato al numero in virgola mobile di `FAC` e lascia il risultato in `FAC`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_exp_arg"></a>
##### m_EXP_ARG

Calcola e elevato a `ARG` e lascia il risultato in `FAC`, che perde il suo vecchio contenuto.

Copia prima `ARG` in `FAC` con `m_Transfer_ARG_to_FAC`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_exp_mem"></a>
##### m_EXP_Mem

Chiamata: `+m_EXP_Mem .addr_`

Calcola e elevato al numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`, che perde il suo vecchio contenuto.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Mem`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_exp_ptr"></a>
##### m_EXP_Ptr

Chiamata: `+m_EXP_Ptr .ptr_`

Calcola e elevato al numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`, che perde il suo vecchio contenuto.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Ptr`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

### fp_trig.asm

Macro per le funzioni trigonometriche sui numeri in virgola mobile (formato MBF): seno, coseno, tangente e arcotangente. L'argomento può essere in `FAC`, in `ARG`, a un indirizzo assoluto o puntato da un puntatore; il risultato è sempre in `FAC`. L'interruttore `__PRESERVE_ARG` di config.asm decide se `ARG` viene preservato.

#### Seno

Macro: `m_SIN_FAC`, `m_SIN_ARG`, `m_SIN_Mem`, `m_SIN_Ptr`.

Chiama la routine SIN della ROM del BASIC.

La ROM altera molte celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `$07`, `$12`, `INDEX`, `RESHO`, `$56`, `NUMWRK`, `$67` e `$71`-`$72`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in formato MBF in `STACK` (`$0100`-`$0104`) prima della chiamata e lo ripristina dopo, perché la ROM usa `NUMWRK`, dove si trova `_SCRATCH_2`; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero. Il contenuto di `STACK` non è garantito dopo la chiamata.

Per l'accuratezza del risultato vedi [Nota #13 di `math/fp.asm`](#nota-fp-13) e [Nota #08 di `math/fp.asm`](#nota-fp-08).

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Seno, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `STACK` (5 byte, se `__PRESERVE_ARG` = 1) |

<a id="utilita-m_sin_fac"></a>
##### m_SIN_FAC

Calcola il seno del numero in virgola mobile di `FAC` e lascia il risultato in `FAC`. L'angolo è in radianti.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sin_arg"></a>
##### m_SIN_ARG

Calcola il seno del numero in virgola mobile di `ARG` e lascia il risultato in `FAC`, che perde il suo vecchio contenuto. L'angolo è in radianti.

Copia prima `ARG` in `FAC` con `m_Transfer_ARG_to_FAC`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sin_mem"></a>
##### m_SIN_Mem

Chiamata: `+m_SIN_Mem .addr_`

Calcola il seno del numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`, che perde il suo vecchio contenuto. L'angolo è in radianti.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Mem`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sin_ptr"></a>
##### m_SIN_Ptr

Chiamata: `+m_SIN_Ptr .ptr_`

Calcola il seno del numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`, che perde il suo vecchio contenuto. L'angolo è in radianti.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Ptr`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

#### Coseno

Macro: `m_COS_FAC`, `m_COS_ARG`, `m_COS_Mem`, `m_COS_Ptr`.

Chiama la routine COS della ROM del BASIC.

La ROM altera molte celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `$07`, `$12`, `INDEX`, `RESHO`, `$56`, `NUMWRK`, `$67` e `$71`-`$72`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in formato MBF in `STACK` (`$0100`-`$0104`) prima della chiamata e lo ripristina dopo, perché la ROM usa `NUMWRK`, dove si trova `_SCRATCH_2`; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero. Il contenuto di `STACK` non è garantito dopo la chiamata.

Per l'accuratezza del risultato vedi [Nota #14 di `math/fp.asm`](#nota-fp-14) e [Nota #08 di `math/fp.asm`](#nota-fp-08).

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Coseno, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `STACK` (5 byte, se `__PRESERVE_ARG` = 1) |

<a id="utilita-m_cos_fac"></a>
##### m_COS_FAC

Calcola il coseno del numero in virgola mobile di `FAC` e lascia il risultato in `FAC`. L'angolo è in radianti.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_cos_arg"></a>
##### m_COS_ARG

Calcola il coseno del numero in virgola mobile di `ARG` e lascia il risultato in `FAC`, che perde il suo vecchio contenuto. L'angolo è in radianti.

Copia prima `ARG` in `FAC` con `m_Transfer_ARG_to_FAC`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_cos_mem"></a>
##### m_COS_Mem

Chiamata: `+m_COS_Mem .addr_`

Calcola il coseno del numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`, che perde il suo vecchio contenuto. L'angolo è in radianti.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Mem`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_cos_ptr"></a>
##### m_COS_Ptr

Chiamata: `+m_COS_Ptr .ptr_`

Calcola il coseno del numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`, che perde il suo vecchio contenuto. L'angolo è in radianti.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Ptr`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

#### Tangente

Macro: `m_TAN_FAC`, `m_TAN_ARG`, `m_TAN_Mem`, `m_TAN_Ptr`.

Chiama la routine TAN della ROM del BASIC. Se il coseno è zero la ROM segnala DIVISION BY ZERO ERROR e non ritorna al chiamante: vedi [Nota #07 di `math/fp.asm`](#nota-fp-07).

La ROM altera molte celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `$07`, `$12`, `INDEX`, `RESHO`, `$4E`-`$52`, `$56`, `NUMWRK`, `$67` e `$71`-`$72`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in formato MBF in `STACK` (`$0100`-`$0104`) prima della chiamata e lo ripristina dopo, perché la ROM usa `NUMWRK`, dove si trova `_SCRATCH_2`; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero. Il contenuto di `STACK` non è garantito dopo la chiamata.

Per l'accuratezza del risultato vedi [Nota #15 di `math/fp.asm`](#nota-fp-15) e [Nota #08 di `math/fp.asm`](#nota-fp-08).

Prima della chiamata alla ROM la macro salva `.S` in `__FP_SAVED_SP`, a uso di `FP_ERROR_HANDLER`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Tangente, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito<br>`__FP_SAVED_SP` (1 byte, ZP): Valore di `.S` prima della chiamata<br>`.PC` (2 byte, CPU): Ritorno al chiamante o, se la ROM segnala un errore, salto al vettore `IERROR` |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `STACK` (5 byte, se `__PRESERVE_ARG` = 1), `__FP_SAVED_SP` |

<a id="utilita-m_tan_fac"></a>
##### m_TAN_FAC

Calcola il tangente del numero in virgola mobile di `FAC` e lascia il risultato in `FAC`. L'angolo è in radianti.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_tan_arg"></a>
##### m_TAN_ARG

Calcola il tangente del numero in virgola mobile di `ARG` e lascia il risultato in `FAC`, che perde il suo vecchio contenuto. L'angolo è in radianti.

Copia prima `ARG` in `FAC` con `m_Transfer_ARG_to_FAC`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_tan_mem"></a>
##### m_TAN_Mem

Chiamata: `+m_TAN_Mem .addr_`

Calcola il tangente del numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`, che perde il suo vecchio contenuto. L'angolo è in radianti.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Mem`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_tan_ptr"></a>
##### m_TAN_Ptr

Chiamata: `+m_TAN_Ptr .ptr_`

Calcola il tangente del numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`, che perde il suo vecchio contenuto. L'angolo è in radianti.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Ptr`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

#### Arcotangente

Macro: `m_ATN_FAC`, `m_ATN_ARG`, `m_ATN_Mem`, `m_ATN_Ptr`.

Chiama la routine ATN della ROM del BASIC.

La ROM altera molte celle di lavoro, il cui contenuto non è garantito dopo la chiamata: `INDEX`, `RESHO`, `$56`, `NUMWRK`, `$67` e `$71`-`$72`.

Se `__PRESERVE_ARG` = 1 la macro salva `ARG` in formato MBF in `STACK` (`$0100`-`$0104`) prima della chiamata e lo ripristina dopo, perché la ROM usa `NUMWRK`, dove si trova `_SCRATCH_2`; se vale 0 il contenuto di `ARG` non è garantito dopo la chiamata. Un `ARG` uguale a zero (`ARGEXP` = 0) torna con `ARGHO` = `$80`, ed è ancora zero. Il contenuto di `STACK` non è garantito dopo la chiamata.

Per l'accuratezza del risultato vedi [Nota #16 di `math/fp.asm`](#nota-fp-16) e [Nota #08 di `math/fp.asm`](#nota-fp-08).

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Input | `__PRESERVE_ARG` (1 byte, Macro): 1 = `ARG` viene preservato; 0 = `ARG` può essere alterato |
| Output | `FAC` (7 byte, ZP): Arcotangente, registri da `FACEXP` a `FACOV`<br>`ARG` (6 byte, ZP): Invariato se `__PRESERVE_ARG` = 1; altrimenti non garantito |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `ARISGN`, `INDEX`, `STACK` (5 byte, se `__PRESERVE_ARG` = 1) |

<a id="utilita-m_atn_fac"></a>
##### m_ATN_FAC

Calcola il arcotangente del numero in virgola mobile di `FAC` e lascia il risultato in `FAC`. Il risultato è un angolo in radianti, tra -PI/2 e PI/2.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_atn_arg"></a>
##### m_ATN_ARG

Calcola il arcotangente del numero in virgola mobile di `ARG` e lascia il risultato in `FAC`, che perde il suo vecchio contenuto. Il risultato è un angolo in radianti, tra -PI/2 e PI/2.

Copia prima `ARG` in `FAC` con `m_Transfer_ARG_to_FAC`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_atn_mem"></a>
##### m_ATN_Mem

Chiamata: `+m_ATN_Mem .addr_`

Calcola il arcotangente del numero in formato MBF che si trova a un indirizzo assoluto e lascia il risultato in `FAC`, che perde il suo vecchio contenuto. Il risultato è un angolo in radianti, tra -PI/2 e PI/2.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Mem`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_atn_ptr"></a>
##### m_ATN_Ptr

Chiamata: `+m_ATN_Ptr .ptr_`

Calcola il arcotangente del numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lascia il risultato in `FAC`, che perde il suo vecchio contenuto. Il risultato è un angolo in radianti, tra -PI/2 e PI/2.

Carica prima il numero in `FAC` con `m_Load_FAC_from_Ptr`, che altera `INDEX`.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |

[↑ Torna al contenuto](#contenuto)

### fp_unary.asm

Macro per le funzioni unarie sui numeri in virgola mobile (formato MBF): cambio di segno, valore assoluto, segno, parte intera, moltiplicazione e divisione per 2.

#### Cambio di segno

Macro: `m_Negate_FAC`, `m_Negate_ARG`, `m_Negate_Mem`, `m_Negate_Ptr`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Registri Modificati | `.A` |

<a id="utilita-m_negate_fac"></a>
##### m_Negate_FAC

Cambia il segno del numero in virgola mobile di `FAC`.

Se `FAC` è zero (`FACEXP` = 0) il segno non cambia, come fa la routine della ROM del BASIC, per non produrre uno zero con segno.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `FACSGN` (1 byte, ZP): Segno invertito, solo il bit #7 è significativo |
| Registri Modificati | `.P` (Negative, Zero), `FACSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_negate_arg"></a>
##### m_Negate_ARG

Cambia il segno del numero in virgola mobile di `ARG`.

Se `ARG` è zero (`ARGEXP` = 0) il segno non cambia, come fa la routine della ROM del BASIC, per non produrre uno zero con segno. `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `ARGSGN` (1 byte, ZP): Segno invertito, solo il bit #7 è significativo |
| Registri Modificati | `.P` (Negative, Zero), `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_negate_mem"></a>
##### m_Negate_Mem

Chiamata: `+m_Negate_Mem .addr_`

Carica `FAC` con il numero in formato MBF che si trova a un indirizzo assoluto, ne cambia il segno e lascia il risultato in `FAC`.

La lettura usa `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Se `FAC` è zero (`FACEXP` = 0) il segno non cambia, come fa la routine della ROM del BASIC, per non produrre uno zero con segno.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Numero letto, con segno invertito, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FACSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_negate_ptr"></a>
##### m_Negate_Ptr

Chiamata: `+m_Negate_Ptr .ptr_`

Carica `FAC` con il numero in formato MBF che si trova all'indirizzo a cui punta un puntatore, ne cambia il segno e lascia il risultato in `FAC`.

La lettura usa `m_Load_FAC_from_Ptr`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Se `FAC` è zero (`FACEXP` = 0) il segno non cambia, come fa la routine della ROM del BASIC, per non produrre uno zero con segno.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Numero letto, con segno invertito, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FACSGN` |

[↑ Torna al contenuto](#contenuto)

#### Valore assoluto

Macro: `m_ABS_FAC`, `m_ABS_ARG`, `m_ABS_Mem`, `m_ABS_Ptr`.

<a id="utilita-m_abs_fac"></a>
##### m_ABS_FAC

Azzera il segno del numero in virgola mobile di `FAC`, cioè ne calcola il valore assoluto.

Basta azzerare il bit #7 del segno.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `FACSGN` (1 byte, ZP): Bit #7 azzerato |
| Registri Modificati | `.P` (Negative, Zero, Carry), `FACSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_abs_arg"></a>
##### m_ABS_ARG

Azzera il segno del numero in virgola mobile di `ARG`, cioè ne calcola il valore assoluto.

Basta azzerare il bit #7 del segno. `ARISGN` non viene aggiornato.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `ARGSGN` (1 byte, ZP): Bit #7 azzerato |
| Registri Modificati | `.P` (Negative, Zero, Carry), `ARGSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_abs_mem"></a>
##### m_ABS_Mem

Chiamata: `+m_ABS_Mem .addr_`

Carica `FAC` con il numero in formato MBF che si trova a un indirizzo assoluto e ne calcola il valore assoluto, lasciando il risultato in `FAC`.

La lettura usa `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Basta azzerare il bit #7 del segno.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Valore assoluto, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.A`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FACSGN` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_abs_ptr"></a>
##### m_ABS_Ptr

Chiamata: `+m_ABS_Ptr .ptr_`

Carica `FAC` con il numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e ne calcola il valore assoluto, lasciando il risultato in `FAC`.

La lettura usa `m_Load_FAC_from_Ptr`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Basta azzerare il bit #7 del segno.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Valore assoluto, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.A`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FACSGN` |

[↑ Torna al contenuto](#contenuto)

#### Segno in .A

Macro: `m_Sign_FAC`, `m_Sign_ARG`, `m_Sign_Mem`, `m_Sign_Ptr`.

Se il numero è zero il Carry non è garantito.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Output | `.A` (1 byte, CPU): `$FF` = negativo; `$00` = zero; `$01` = positivo<br>Carry (1 bit, .P): 0 = positivo; 1 = negativo |
| Registri Modificati | `.A` |

<a id="utilita-m_sign_fac"></a>
##### m_Sign_FAC

Restituisce in `.A` il segno del numero in virgola mobile di `FAC`.

Chiama la routine SIGN della ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sign_arg"></a>
##### m_Sign_ARG

Restituisce in `.A` il segno del numero in virgola mobile di `ARG`.

Il codice è interno alla macro.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Registri Modificati | `.P` (Negative, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sign_mem"></a>
##### m_Sign_Mem

Chiamata: `+m_Sign_Mem .addr_`

Carica `FAC` con il numero in formato MBF che si trova a un indirizzo assoluto e restituisce in `.A` il suo segno.

La lettura usa `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Chiama la routine SIGN della ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Numero letto, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sign_ptr"></a>
##### m_Sign_Ptr

Chiamata: `+m_Sign_Ptr .ptr_`

Carica `FAC` con il numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e restituisce in `.A` il suo segno.

La lettura usa `m_Load_FAC_from_Ptr`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Chiama la routine SIGN della ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Numero letto, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

[↑ Torna al contenuto](#contenuto)

#### Segno in FAC (SGN)

Macro: `m_SGN_FAC`, `m_SGN_ARG`, `m_SGN_Mem`, `m_SGN_Ptr`.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

<a id="utilita-m_sgn_fac"></a>
##### m_SGN_FAC

Sostituisce il numero in virgola mobile di `FAC` con il suo segno: -1, 0 o 1.

Chiama la routine SGN della ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `FAC` (7 byte, ZP): -1, 0 o 1, registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sgn_arg"></a>
##### m_SGN_ARG

Sostituisce il numero in virgola mobile di `ARG` con il suo segno: -1, 0 o 1.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, chiama la routine SGN della ROM del BASIC e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; `ARISGN` non viene aggiornato. Il contenuto di `_SCRATCH_2` non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `ARG` (6 byte, ZP): -1, 0 o 1, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Valore di prima, arrotondato, `FACOV` azzerato |
| Registri Modificati | `FAC`, `_SCRATCH_2` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sgn_mem"></a>
##### m_SGN_Mem

Chiamata: `+m_SGN_Mem .addr_`

Carica `FAC` con il numero in formato MBF che si trova a un indirizzo assoluto e lo sostituisce con il suo segno: -1, 0 o 1.

La lettura usa `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Chiama la routine SGN della ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): -1, 0 o 1, registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sgn_ptr"></a>
##### m_SGN_Ptr

Chiamata: `+m_SGN_Ptr .ptr_`

Carica `FAC` con il numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lo sostituisce con il suo segno: -1, 0 o 1.

La lettura usa `m_Load_FAC_from_Ptr`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Chiama la routine SGN della ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): -1, 0 o 1, registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

#### Parte intera (INT)

Macro: `m_INT_FAC`, `m_INT_ARG`, `m_INT_Mem`, `m_INT_Ptr`.

I numeri con esponente maggiore o uguale a `$A0`, cioè di valore assoluto non inferiore a 2^31, sono già interi e non cambiano.

La routine INT altera le celle `$07` e `$68`; usa `QINT`, che richiede `$68` = 0 in ingresso e lo azzera in uscita. Il contenuto di `$07` non è garantito dopo la chiamata.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry) |

<a id="utilita-m_int_fac"></a>
##### m_INT_FAC

Arrotonda per difetto, verso -infinito, il numero in virgola mobile di `FAC`: 1.2 diventa 1 e -1.2 diventa -2.

Chiama la routine INT della ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `FAC` (7 byte, ZP): Numero arrotondato, registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_int_arg"></a>
##### m_INT_ARG

Arrotonda per difetto, verso -infinito, il numero in virgola mobile di `ARG`: 1.2 diventa 1 e -1.2 diventa -2.

Scambia `FAC` e `ARG` con `m_Swap_FAC_and_ARG`, chiama la routine INT della ROM del BASIC e li scambia di nuovo. Dopo la chiamata `FAC` contiene il valore di prima, arrotondato, e `FACOV` vale zero; `ARISGN` non viene aggiornato. Il contenuto di `_SCRATCH_2` non è garantito dopo la chiamata.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `ARG` (6 byte, ZP): Numero arrotondato, registri da `ARGEXP` a `ARGSGN`<br>`FAC` (7 byte, ZP): Valore di prima, arrotondato, `FACOV` azzerato |
| Registri Modificati | `FAC`, `_SCRATCH_2` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_int_mem"></a>
##### m_INT_Mem

Chiamata: `+m_INT_Mem .addr_`

Carica `FAC` con il numero in formato MBF che si trova a un indirizzo assoluto e lo arrotonda per difetto, verso -infinito: 1.2 diventa 1 e -1.2 diventa -2. Il risultato resta in `FAC`.

La lettura usa `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Chiama la routine INT della ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Numero arrotondato, registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_int_ptr"></a>
##### m_INT_Ptr

Chiamata: `+m_INT_Ptr .ptr_`

Carica `FAC` con il numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lo arrotonda per difetto, verso -infinito: 1.2 diventa 1 e -1.2 diventa -2. Il risultato resta in `FAC`.

La lettura usa `m_Load_FAC_from_Ptr`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Chiama la routine INT della ROM del BASIC.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Numero arrotondato, registri da `FACEXP` a `FACOV` |

[↑ Torna al contenuto](#contenuto)

#### Moltiplicazione per 2

Macro: `m_Multiply_FAC_by_2`, `m_Multiply_ARG_by_2`, `m_Multiply_Mem_by_2`, `m_Multiply_Ptr_by_2`.

È molto più veloce di una moltiplicazione o di una divisione vera e propria.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Registri Modificati | `.A` |

<a id="utilita-m_multiply_fac_by_2"></a>
##### m_Multiply_FAC_by_2

Moltiplica per 2 il numero in virgola mobile di `FAC`, incrementando l'esponente.

Se `FAC` è zero (`FACEXP` = 0) resta zero. Se l'esponente vale `$FF` il risultato è zero, senza l'errore di overflow della ROM del BASIC: il valore è troppo grande per il formato MBF.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `FACEXP` (1 byte, ZP): Esponente incrementato, salvo se il numero è zero |
| Registri Modificati | `.P` (Negative, Zero), `FACEXP` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_multiply_arg_by_2"></a>
##### m_Multiply_ARG_by_2

Moltiplica per 2 il numero in virgola mobile di `ARG`, incrementando l'esponente.

Se `ARG` è zero (`ARGEXP` = 0) resta zero. Se l'esponente vale `$FF` il risultato è zero, senza l'errore di overflow della ROM del BASIC: il valore è troppo grande per il formato MBF.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `ARGEXP` (1 byte, ZP): Esponente incrementato, salvo se il numero è zero |
| Registri Modificati | `.P` (Negative, Zero), `ARGEXP` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_multiply_mem_by_2"></a>
##### m_Multiply_Mem_by_2

Chiamata: `+m_Multiply_Mem_by_2 .addr_`

Carica `FAC` con il numero in formato MBF che si trova a un indirizzo assoluto e lo moltiplica per 2, incrementando l'esponente. Il risultato resta in `FAC`.

La lettura usa `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Se `FAC` è zero (`FACEXP` = 0) resta zero. Se l'esponente vale `$FF` il risultato è zero, senza l'errore di overflow della ROM del BASIC: il valore è troppo grande per il formato MBF.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Numero letto moltiplicato per 2, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FACEXP` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_multiply_ptr_by_2"></a>
##### m_Multiply_Ptr_by_2

Chiamata: `+m_Multiply_Ptr_by_2 .ptr_`

Carica `FAC` con il numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lo moltiplica per 2, incrementando l'esponente. Il risultato resta in `FAC`.

La lettura usa `m_Load_FAC_from_Ptr`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Se `FAC` è zero (`FACEXP` = 0) resta zero. Se l'esponente vale `$FF` il risultato è zero, senza l'errore di overflow della ROM del BASIC: il valore è troppo grande per il formato MBF.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Numero letto moltiplicato per 2, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FACEXP` |

[↑ Torna al contenuto](#contenuto)

#### Divisione per 2

Macro: `m_Divide_FAC_by_2`, `m_Divide_ARG_by_2`, `m_Divide_Mem_by_2`, `m_Divide_Ptr_by_2`.

È molto più veloce di una moltiplicazione o di una divisione vera e propria.

Contratto comune a tutte le macro:

| Voce | Contenuto |
|---|---|
| Registri Modificati | `.A` |

<a id="utilita-m_divide_fac_by_2"></a>
##### m_Divide_FAC_by_2

Divide per 2 il numero in virgola mobile di `FAC`, decrementando l'esponente.

Se `FAC` è zero (`FACEXP` = 0) resta zero. Se l'esponente vale 1 il risultato è zero (underflow): il valore è troppo piccolo per il formato MBF.

| Voce | Specifico di questa macro |
|---|---|
| Input | `FAC` (7 byte, ZP): Registri da `FACEXP` a `FACOV` |
| Output | `FACEXP` (1 byte, ZP): Esponente decrementato, salvo se il numero è zero |
| Registri Modificati | `.P` (Negative, Zero), `FACEXP` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_divide_arg_by_2"></a>
##### m_Divide_ARG_by_2

Divide per 2 il numero in virgola mobile di `ARG`, decrementando l'esponente.

Se `ARG` è zero (`ARGEXP` = 0) resta zero. Se l'esponente vale 1 il risultato è zero (underflow): il valore è troppo piccolo per il formato MBF.

| Voce | Specifico di questa macro |
|---|---|
| Input | `ARG` (6 byte, ZP): Registri da `ARGEXP` a `ARGSGN` |
| Output | `ARGEXP` (1 byte, ZP): Esponente decrementato, salvo se il numero è zero |
| Registri Modificati | `.P` (Negative, Zero), `ARGEXP` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_divide_mem_by_2"></a>
##### m_Divide_Mem_by_2

Chiamata: `+m_Divide_Mem_by_2 .addr_`

Carica `FAC` con il numero in formato MBF che si trova a un indirizzo assoluto e lo divide per 2, decrementando l'esponente. Il risultato resta in `FAC`.

La lettura usa `m_Load_FAC_from_Mem`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Se `FAC` è zero (`FACEXP` = 0) resta zero. Se l'esponente vale 1 il risultato è zero (underflow): il valore è troppo piccolo per il formato MBF.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.addr_` (1 o 2 byte, Macro): Indirizzo del numero<br>`(.addr_)` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Numero letto diviso per 2, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FACEXP` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_divide_ptr_by_2"></a>
##### m_Divide_Ptr_by_2

Chiamata: `+m_Divide_Ptr_by_2 .ptr_`

Carica `FAC` con il numero in formato MBF che si trova all'indirizzo a cui punta un puntatore e lo divide per 2, decrementando l'esponente. Il risultato resta in `FAC`.

La lettura usa `m_Load_FAC_from_Ptr`, che altera anche `INDEX`: il suo contenuto non è garantito dopo la chiamata. Il vecchio contenuto di `FAC` si perde.

Se `FAC` è zero (`FACEXP` = 0) resta zero. Se l'esponente vale 1 il risultato è zero (underflow): il valore è troppo piccolo per il formato MBF.

| Voce | Specifico di questa macro |
|---|---|
| Input | `.ptr_` (1 o 2 byte, Macro): Indirizzo del puntatore<br>`(.ptr_)` (2 byte, RAM): Indirizzo del numero (LSB, MSB)<br>`((.ptr_))` (5 byte, RAM): Numero in formato MBF |
| Output | `FAC` (7 byte, ZP): Numero letto diviso per 2, registri da `FACEXP` a `FACOV` |
| Registri Modificati | `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `FACEXP` |

[↑ Torna al contenuto](#contenuto)

### Note d'uso di `fp.asm`

<a id="nota-fp-01"></a>
#### Nota #01

I numeri in memoria sono codificati in due formati diversi:

**MICROSOFT BINARY FORMAT (MBF)**

```
    Byte 0   Byte 1   Byte 2   Byte 3   Byte 4
  |76543210|76543210|76543210|76543210|76543210|
  |Esp.+$80|S<------------Mantissa------------>|
```

Poiché la mantissa è memorizzata in forma normalizzata, il bit #7 del byte 1 è per definizione sempre "1". Sfruttando questo fatto, il bit #7 del byte 1 codifica in realtà il segno del numero: "+" = 0 e "-" = 1, con il vantaggio di una rappresentazione che occupa meno memoria.

**FORMATO FLOATING POINT ACCUMULATOR (FAC)**

Quando il numero viene memorizzato in un `FAC`, o trasferito in esso, la rappresentazione viene espansa in una forma più adatta alla manipolazione numerica:

```
    Byte 0   Byte 1   Byte 2   Byte 3   Byte 4   Byte 5
  |76543210|76543210|76543210|76543210|76543210|76543210|
  |Esp.+$80|<------------Mantissa------------->|S<inut.>|
```

In questa rappresentazione il bit #7 del byte 1 è ripristinato a "1", mentre il bit #7 del byte aggiuntivo codifica il segno: "+" = 0, "-" = 1.

<a id="nota-fp-02"></a>
#### Nota #02

Il registro `ARISGN` contiene `$00` se i segni di `FAC` e `ARG` sono uguali e un valore diverso da `$00` se sono diversi, ma questo è garantito solo se `ARG` viene aggiornato DOPO `FAC`. Per semplificare il compito del programmatore, le macro della libreria aggiornano automaticamente il registro `ARISGN` ogni volta che `FAC` viene modificato.

<a id="nota-fp-03"></a>
#### Nota #03

Tutto ciò che esce da `FAC` viene arrotondato in base al valore del registro `FACOV`.

<a id="nota-fp-04"></a>
#### Nota #04

Le librerie math e fp usano le stesse celle di pagina zero. `NUMWRK` (`$57`-`$60`) è l'area di lavoro di `math_mult`, di math8 (`NUMWRK`+0) e della ROM; anche `_SCRATCH_2`, che contiene la copia di `ARG`, coincide con `NUMWRK`. In moltiplicazione le celle arrivano fino ai primi due byte di `FAC` (`$61`-`$62`). Un dato lasciato in quelle celle da una libreria viene distrutto dall'altra: ogni chiamata va considerata autonoma e il suo risultato va copiato altrove prima di chiamare l'altra libreria.

<a id="nota-fp-05"></a>
#### Nota #05

Le macro chiamano routine della ROM BASIC (`$A000`-`$BFFF`) e della sua parte residente nella ROM KERNAL (`$E000`-`$E4AC`). Entrambe le ROM devono essere visibili: `LORAM` e `HIRAM` (bit #0 e #1 di `$01`) devono valere 1, come nella configurazione standard (`$01` = `$37`).

<a id="nota-fp-06"></a>
#### Nota #06

Le routine della ROM alterano variabili vitali del BASIC. `_SCRATCH_1` (`$3D`-`$43`) copre `OLDTXT`, `DATLIN`, `DATPTR` e il byte basso di `INPPTR`: dopo l'uso di fp il comando CONT non è più affidabile e READ e INPUT ripartono da puntatori alterati. Vengono inoltre modificati `NUMWRK`, `FAC`, `ARG`, le celle di lavoro della ROM e, nelle conversioni da stringa, `TXTPTR` (`$7A`/`$7B`). Un programma in LM che non torna al BASIC non è interessato; uno che ci torna deve considerare persi questi valori.

<a id="nota-fp-07"></a>
#### Nota #07

Le routine della ROM possono segnalare tre errori: ?ILLEGAL QUANTITY (`$0E`), ?OVERFLOW (`$0F`) e ?DIVISION BY ZERO (`$14`). La ROM non ritorna al chiamante: salta a `IERROR` tramite il vettore (`$0300`) con il codice in `.X`, e il BASIC stampa il messaggio e torna a READY.

Con `__USE_FP_ERROR_HANDLER` = 1 ogni macro a rischio salva `.S` in `__FP_SAVED_SP` (ZP, `$06`) prima della chiamata. Se il chiamante fa puntare il vettore `IERROR` a `FP_ERROR_HANDLER`, il gestore ripristina `.S` e ritorna subito dopo il jsr della macro, con Carry = 1 e il codice d'errore in `.X`. Carry = 0 indica che non c'è stato errore. L'installazione del vettore è compito del chiamante.

<a id="nota-fp-08"></a>
#### Nota #08

La moltiplicazione in virgola mobile della ROM contiene un bug noto, che interessa quasi tutti i BASIC Commodore a 8 bit (non il BASIC 7.0 del C128). Per certe coppie di operandi il risultato è sbagliato di pochi bit, e può dipendere dall'ordine: con V = 1 + 255/2^31, V\*1-V dà 0 mentre 1\*V-V non dà 0. La causa è in `MLTPLY` (`$BA59`): quando un byte della mantissa di `ARG` è zero, la routine salta a `MULSHF` (`$B983`), che somma senza controllare il Carry e può scorrere di 9 bit invece di 8.

Il bug riguarda ogni macro che moltiplica, direttamente o attraverso la ROM: `m_Multiply_FAC_by_ARG/_Mem/_Ptr`, le conversioni in stringa e le stampe, i polinomi, la potenza e SQR, LOG ed EXP, le funzioni trigonometriche e `m_Load_FAC_with_RND` (con `FAC` positivo).

Fonte: https://www.c64-wiki.com/wiki/Multiply_bug

Nella sola moltiplicazione si può ridurre il problema scambiando i due operandi: su 20 000 coppie casuali lo scambio corregge circa il 94% dei casi in cui un ordine è sbagliato, ma non tutti, perché in 300 casi sono sbagliati entrambi. Dopo lo scambio `ARISGN` va ricalcolato (`FACSGN` xor `ARGSGN`). Per le altre funzioni il rimedio non si applica: l'ordine delle moltiplicazioni interne non dipende dal chiamante.

<a id="nota-fp-09"></a>
#### Nota #09

SQR calcola la radice tramite LOG ed EXP, quindi ne eredita i polinomi e il bug della moltiplicazione ([Nota #08](#nota-fp-08)). Il wiki dichiara un accordo col valore vero fino a 30 bit (25 bit per pochi ingressi). Nelle nostre misure, su 1500 ingressi casuali, la mediana è 33.0 bit e il minimo 31.0 (la mantissa ha 32 bit). SQR(0) = 0; un argomento negativo dà ?ILLEGAL QUANTITY.

Fonte: https://www.c64-wiki.com/wiki/SQR

<a id="nota-fp-10"></a>
#### Nota #10

RND dipende dal segno di `FAC`. Con `FAC` > 0 restituisce il numero successivo della sequenza (seme x 11 879 546 + 3.927677739E-8, poi i byte della mantissa vengono scambiati). Con `FAC` < 0 `FAC` diventa il nuovo seme, e lo stesso seme dà sempre la stessa sequenza: utile per collaudi e debug. Il risultato di quella chiamata è il seme stesso, quindi con un seme piccolo è un numero molto piccolo (RND(-1) = 2.99E-8). Con `FAC` = 0 il seme viene ricavato dai timer A e dall'orologio TOD del CIA #1 (`$DC04`, `$DC05`, `$DC08`, `$DC09`): questi registri non sono inizializzati all'avvio e alcuni lavorano in BCD, quindi non assumono tutti i valori possibili e lo spazio dei semi si riduce.

`m_Randomize` usa come seme -TI: TI ha 24 bit, quindi 8 bit della mantissa a 32 bit sono sempre zero. Per aggiungere casualità, il numero ottenuto (tra 0 e 1) viene poi negato e usato per reinizializzare il generatore.

Secondo il wiki l'implementazione può degenerare in sequenze molto corte (nel caso peggiore 723 valori distinti); questo non è stato verificato qui.

Fonte: https://www.c64-wiki.com/wiki/RND

<a id="nota-fp-11"></a>
#### Nota #11

LOG(V) dà ?ILLEGAL QUANTITY per V <= 0; LOG(1) = 0. Il wiki dichiara un accordo col valore vero fino a 29 bit (24 per pochi ingressi), con peggioramento vicino a V = 1. Nelle nostre misure su 1500 ingressi casuali la mediana è 31.9 bit e il minimo 22.8 (26 ingressi sotto 27 bit). I casi peggiori sono vicini a 1: LOG(0.99) dà 24.4 bit, LOG(1.01) 26.9, LOG(1.1) 27.7. L'errore assoluto resta piccolo, ma il risultato è piccolo, perciò cresce l'errore relativo. Il bug della moltiplicazione ([Nota #08](#nota-fp-08)) non è la causa: con la ROM corretta i valori sono identici. La potenza (`m_Power_*`) passa da LOG ed EXP e ne eredita i limiti.

Fonte: https://www.c64-wiki.com/wiki/LOG

<a id="nota-fp-12"></a>
#### Nota #12

EXP(V) dà ?OVERFLOW per V oltre circa 88.03 (il wiki indica 89.03, ma EXP(89.02) dà già errore; EXP(88) = 1.65E38). Per argomenti molto negativi il risultato è 0 senza errore (provati -89 e -100). Il wiki dichiara un accordo col valore vero fino a 30 bit (26 per pochi ingressi); nelle nostre misure su 1500 ingressi casuali la mediana è 33.0 bit e il minimo 30.9. EXP(0) = 1. La potenza (`m_Power_*`) passa da LOG ed EXP: stessi limiti.

Fonte: https://www.c64-wiki.com/wiki/EXP

<a id="nota-fp-13"></a>
#### Nota #13

SIN riduce l'argomento a un quarto di periodo e valuta un polinomio. Il wiki dichiara un accordo col valore vero fino a 30 bit tra circa -2.6 e +2.6, con peggioramento oltre per l'imprecisione di PI ([Nota #17](#nota-fp-17)) e per pochi ingressi fino a 24 bit. Nelle nostre misure su 1500 ingressi casuali la mediana è 32.1 bit e il minimo 27.5. Per argomenti piccoli l'errore relativo sale: da 4E-11 per 0.04 a 3.4E-9 per 1E-4 (da 34 a 28 bit), perché i coefficienti del polinomio non sono esatti. Un argomento fuori dai limiti della virgola mobile dà ?OVERFLOW; SIN stessa non ne ha altri.

Fonte: https://www.c64-wiki.com/wiki/SIN

<a id="nota-fp-14"></a>
#### Nota #14

COS(V) è calcolata come SIN(V + PI/2): valgono quindi i limiti della [Nota #13](#nota-fp-13) e il bug della moltiplicazione ([Nota #08](#nota-fp-08)). Il wiki dichiara un accordo col valore vero fino a 29 bit, con pochi ingressi a 24 e peggioramento vicino ai multipli dispari di PI/2. Nelle nostre misure su 1500 ingressi casuali la mediana è 31.8 bit e il minimo 27.7. La simmetria non è esatta: COS(0.9) - COS(-0.9) = -2 x 2^-32 (il wiki riporta 3 x 2^-32).

Fonte: https://www.c64-wiki.com/wiki/COS

<a id="nota-fp-15"></a>
#### Nota #15

TAN(V) è calcolata come SIN(V)/COS(V): eredita i limiti di entrambe e perde precisione dove le perdono loro. Il wiki dichiara un accordo di circa 29 bit (25 per pochi ingressi). Nelle nostre misure su 1500 ingressi casuali la mediana è 32.2 bit e il minimo 27.3. Se COS vale 0 la divisione dà ?DIVISION BY ZERO (il wiki cita TAN(PI/2)); questo è l'unico errore di TAN oltre a ?OVERFLOW. TAN(PI) non è esattamente 0: con PI arrotondato a 3.14159265359 abbiamo misurato 0, il wiki riporta -7.3E-10.

Fonte: https://www.c64-wiki.com/wiki/TAN

<a id="nota-fp-16"></a>
#### Nota #16

ATN usa la simmetria dispari e, per \|V\| > 1, l'identità PI/2 - ATN(1/V); per 0 <= V <= 1 valuta un polinomio. Il wiki dichiara un accordo col valore vero fino a 30 bit (25 per pochi ingressi). Nelle nostre misure su 1500 ingressi casuali la mediana è 32.1 bit e il minimo 30.6. ATN non dà errori a parte ?OVERFLOW per argomenti fuori dai limiti della virgola mobile.

Fonte: https://www.c64-wiki.com/wiki/ATN

<a id="nota-fp-17"></a>
#### Nota #17

La costante PI della ROM (5 byte `$82` `$49` `$0F` `$DA` `$A1` a `$AEA8`) vale 3.1415926525 invece di 3.1415926536: l'ultimo byte `$A1` è meno preciso del valore più vicino, che si ottiene con `$A2` (errore -1.2E-10 invece di -1.05E-9). 2\*PI e PI/2, usate da SIN, COS e TAN, hanno invece l'ultimo byte `$A2`. Di conseguenza ATN(1)\*4 dà 3.1415926525 (non 3.1415266 come riporta il wiki, che è sbagliato). Per usare il valore più vicino a pi greco si può caricare una propria costante (`$82` `$49` `$0F` `$DA` `$A2`).

Fonte: https://www.c64-wiki.com/wiki/Pi

[↑ Torna al contenuto](#contenuto)

<a id="modulo-math8"></a>
## math8.asm

Macro per operazioni matematiche su valori a 8 bit.

<a id="utilita-m_neg"></a>
### m_Neg

Chiamata: `+m_Neg .mode_, .op_, .res_`

Sottrae un valore a 8 bit da zero, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  .op_ è un valore a 8 bit.
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Valore (`IMM`) o indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (1 byte, Macro): Riceve il risultato |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_not"></a>
### m_Not

Chiamata: `+m_Not .mode_, .op_, .res_`

Inverte tutti i bit di un valore a 8 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  .op_ è un valore a 8 bit.
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Valore (`IMM`) o indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (1 byte, Macro): Riceve il risultato |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_asls"></a>
### m_AslS

Chiamata: `+m_AslS .mode_, .op_, .res_`

Fa scorrere a sinistra di un bit un valore a 8 bit con segno, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. A differenza di un semplice `ASL`, il cambiamento di segno dovuto all'uscita del bit più alto è segnalato dal flag di oVerflow.

```
"ACC"  L'operando e il risultato sono in .A.
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Con `"ACC"` la macro usa `NUMWRK+0` come cella di appoggio.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ACC"`, `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando (ignorato con `"ACC"`)<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato (ignorato con `"ACC"`)<br>`.A` (1 byte, CPU): Operando (solo con `"ACC"`) |
| Output | `.A` (1 byte, CPU): Risultato (solo con `"ACC"`)<br>`.res_` (1 byte, Macro): Riceve il risultato (con `"ABS"` e `"ZP"`)<br>oVerflow (1 bit, .P): 0 = segno invariato; 1 = segno cambiato |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `NUMWRK+0` (se `.mode_` = `"ACC"`), `.res_` (se `.mode_` = `"ABS"` o `"ZP"`) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_asrs"></a>
### m_AsrS

Chiamata: `+m_AsrS .mode_, .op_, .res_`

Fa scorrere a destra di un bit un valore a 8 bit con segno, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit di segno si conserva e il bit uscito finisce nel Carry.

```
"ACC"  L'operando e il risultato sono in .A.
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ACC"`, `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando (ignorato con `"ACC"`)<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato (ignorato con `"ACC"`)<br>`.A` (1 byte, CPU): Operando (solo con `"ACC"`) |
| Output | `.A` (1 byte, CPU): Risultato (solo con `"ACC"`)<br>`.res_` (1 byte, Macro): Riceve il risultato (con `"ABS"` e `"ZP"`)<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry), `.res_` (se `.mode_` = `"ABS"` o `"ZP"`) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_rl8"></a>
### m_Rl8

Chiamata: `+m_Rl8 .mode_, .op_, .res_`

Ruota a sinistra di un bit un valore a 8 bit senza passare per il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più alto finisce nella posizione più bassa.

```
"ACC"  L'operando e il risultato sono in .A.
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ACC"`, `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando (ignorato con `"ACC"`)<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato (ignorato con `"ACC"`)<br>`.A` (1 byte, CPU): Operando (solo con `"ACC"`) |
| Output | `.A` (1 byte, CPU): Risultato (solo con `"ACC"`)<br>`.res_` (1 byte, Macro): Riceve il risultato (con `"ABS"` e `"ZP"`) |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry), `.res_` (se `.mode_` = `"ABS"` o `"ZP"`) |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_rr8"></a>
### m_Rr8

Chiamata: `+m_Rr8 .mode_, .op_, .res_`

Ruota a destra di un bit un valore a 8 bit senza passare per il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più basso finisce nella posizione più alta.

```
"ACC"  L'operando e il risultato sono in .A.
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ACC"`, `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando (ignorato con `"ACC"`)<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato (ignorato con `"ACC"`)<br>`.A` (1 byte, CPU): Operando (solo con `"ACC"`) |
| Output | `.A` (1 byte, CPU): Risultato (solo con `"ACC"`)<br>`.res_` (1 byte, Macro): Riceve il risultato (con `"ABS"` e `"ZP"`) |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry), `.res_` (se `.mode_` = `"ABS"` o `"ZP"`) |

[↑ Torna al contenuto](#contenuto)

<a id="modulo-math16"></a>
## math16.asm

Macro per operazioni matematiche su valori a 16 bit.

<a id="utilita-m_asl16"></a>
### m_Asl16

Chiamata: `+m_Asl16 .mode_, .op_, .res_`

Fa scorrere a sinistra di un bit un valore a 16 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. È uno scorrimento logico: non si tiene traccia di un eventuale overflow.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A` (se `.op_` != `.res_`), `.P` (Negative, Zero, Carry), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_add16"></a>
### m_Add16

Chiamata: `+m_Add16 .mode_, .add1_, .add2_, .res_`

Somma due valori a 16 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .add1_ è un indirizzo e .add2_ è un
       valore a 16 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Se i due addendi coincidono (`"ABS"` e `"ZP"`) il raddoppio è eseguito da `m_Asl16`, che non imposta V.

Se `.res_` coincide con il primo operando le copie sono omesse, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.add1_` (1 o 2 byte, Macro): Indirizzo del primo addendo<br>`.add2_` (2 byte, Macro): Secondo addendo: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit<br>Carry (1 bit, .P): 0 = riporto assente; 1 = riporto |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sub16"></a>
### m_Sub16

Chiamata: `+m_Sub16 .mode_, .min_, .sub_, .res_`

Sottrae il sottraendo dal minuendo, due valori a 16 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .min_ è un indirizzo e .sub_ è un
       valore a 16 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Se `.res_` coincide con il minuendo e il sottraendo vale zero, la copia è omessa, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.min_` (1 o 2 byte, Macro): Indirizzo del minuendo<br>`.sub_` (2 byte, Macro): Sottraendo: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit<br>Carry (1 bit, .P): 0 = prestito; 1 = nessun prestito |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_neg16"></a>
### m_Neg16

Chiamata: `+m_Neg16 .mode_, .op_, .res_`

Sottrae un valore a 16 bit da zero, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  .op_ è un valore a 16 bit.
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Con `"IMM"` il risultato è calcolato dall'assemblatore e caricato da `m_Mov16`.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op_` (2 byte, Macro): Valore (`IMM`) o indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_not16"></a>
### m_Not16

Chiamata: `+m_Not16 .mode_, .op_, .res_`

Inverte tutti i bit di un valore a 16 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  .op_ è un valore a 16 bit.
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Con `"IMM"` il risultato è calcolato dall'assemblatore e caricato da `m_Mov16`.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op_` (2 byte, Macro): Valore (`IMM`) o indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_and16"></a>
### m_And16

Chiamata: `+m_And16 .mode_, .op1_, .op2_, .res_`

Esegue un `AND` booleano tra due valori a 16 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .op1_ è un indirizzo e .op2_ è un
       valore a 16 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Con `"IMM"` i byte della costante pari a `$00` o `$FF` sono trattati a parte: azzerano il byte o lo lasciano com'è.

Se `.res_` coincide con il primo operando le copie inutili sono omesse, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (1 o 2 byte, Macro): Indirizzo del primo operando<br>`.op2_` (2 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_ora16"></a>
### m_Ora16

Chiamata: `+m_Ora16 .mode_, .op1_, .op2_, .res_`

Esegue un OR booleano tra due valori a 16 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .op1_ è un indirizzo e .op2_ è un
       valore a 16 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Con `"IMM"` i byte della costante pari a `$00` o `$FF` sono trattati a parte: lasciano il byte com'è o lo portano a `$FF`.

Se `.res_` coincide con il primo operando le copie inutili sono omesse, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (1 o 2 byte, Macro): Indirizzo del primo operando<br>`.op2_` (2 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_eor16"></a>
### m_Eor16

Chiamata: `+m_Eor16 .mode_, .op1_, .op2_, .res_`

Esegue un `EOR` booleano tra due valori a 16 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .op1_ è un indirizzo e .op2_ è un
       valore a 16 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Con `"IMM"` i byte della costante pari a `$00` sono trattati a parte: lasciano il byte com'è.

Se `.res_` coincide con il primo operando le copie inutili sono omesse, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (1 o 2 byte, Macro): Indirizzo del primo operando<br>`.op2_` (2 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_asls16"></a>
### m_AslS16

Chiamata: `+m_AslS16 .mode_, .op_, .res_`

Fa scorrere a sinistra di un bit un valore a 16 bit con segno, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. A differenza di `m_Asl16` il cambiamento di segno dovuto all'uscita del bit più alto è segnalato da V.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit<br>oVerflow (1 bit, .P): 0 = segno invariato; 1 = segno cambiato |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_lsr16"></a>
### m_Lsr16

Chiamata: `+m_Lsr16 .mode_, .op_, .res_`

Fa scorrere a destra di un bit un valore a 16 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più alto del risultato vale zero.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A` (se `.op_` != `.res_`), `.P` (Negative, Zero, Carry), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_asrs16"></a>
### m_AsrS16

Chiamata: `+m_AsrS16 .mode_, .op_, .res_`

Fa scorrere a destra di un bit un valore a 16 bit con segno, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit di segno si conserva.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_rol16"></a>
### m_Rol16

Chiamata: `+m_Rol16 .mode_, .op_, .res_`

Ruota a sinistra di un bit un valore a 16 bit attraverso il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più alto esce nel Carry.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A` (se `.op_` != `.res_`), `.P` (Negative, Zero, Carry), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_rl16"></a>
### m_Rl16

Chiamata: `+m_Rl16 .mode_, .op_, .res_`

Ruota a sinistra di un bit un valore a 16 bit senza passare per il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più alto finisce nella posizione più bassa.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_ror16"></a>
### m_Ror16

Chiamata: `+m_Ror16 .mode_, .op_, .res_`

Ruota a destra di un bit un valore a 16 bit attraverso il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più basso esce nel Carry.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A` (se `.op_` != `.res_`), `.P` (Negative, Zero, Carry), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_rr16"></a>
### m_Rr16

Chiamata: `+m_Rr16 .mode_, .op_, .res_`

Ruota a destra di un bit un valore a 16 bit senza passare per il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più basso finisce nella posizione più alta.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (2 byte, Macro): Riceve il risultato a 16 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry), `.res_`+0 .. +1 |

[↑ Torna al contenuto](#contenuto)

<a id="modulo-math24"></a>
## math24.asm

Macro per operazioni matematiche su valori a 24 bit.

<a id="utilita-m_asl24"></a>
### m_Asl24

Chiamata: `+m_Asl24 .mode_, .op_, .res_`

Fa scorrere a sinistra di un bit un valore a 24 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. È uno scorrimento logico: non si tiene traccia di un eventuale overflow.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A` (se `.op_` != `.res_`), `.P` (Negative, Zero, Carry), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_add24"></a>
### m_Add24

Chiamata: `+m_Add24 .mode_, .add1_, .add2_, .res_`

Somma due valori a 24 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .add1_ è un indirizzo e .add2_ è un
       valore a 24 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Se i due addendi coincidono (`"ABS"` e `"ZP"`) il raddoppio è eseguito da `m_Asl24`, che non imposta V.

Se `.res_` coincide con il primo operando le copie sono omesse, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.add1_` (1 o 2 byte, Macro): Indirizzo del primo addendo<br>`.add2_` (3 byte, Macro): Secondo addendo: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit<br>Carry (1 bit, .P): 0 = riporto assente; 1 = riporto |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sub24"></a>
### m_Sub24

Chiamata: `+m_Sub24 .mode_, .min_, .sub_, .res_`

Sottrae il sottraendo dal minuendo, due valori a 24 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .min_ è un indirizzo e .sub_ è un
       valore a 24 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Se `.res_` coincide con il minuendo e il sottraendo vale zero, la copia è omessa, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.min_` (1 o 2 byte, Macro): Indirizzo del minuendo<br>`.sub_` (3 byte, Macro): Sottraendo: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit<br>Carry (1 bit, .P): 0 = prestito; 1 = nessun prestito |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_neg24"></a>
### m_Neg24

Chiamata: `+m_Neg24 .mode_, .op_, .res_`

Sottrae un valore a 24 bit da zero, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  .op_ è un valore a 24 bit.
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Con `"IMM"` il risultato è calcolato dall'assemblatore e caricato da `m_Mov24`.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op_` (3 byte, Macro): Valore (`IMM`) o indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_not24"></a>
### m_Not24

Chiamata: `+m_Not24 .mode_, .op_, .res_`

Inverte tutti i bit di un valore a 24 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  .op_ è un valore a 24 bit.
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Con `"IMM"` il risultato è calcolato dall'assemblatore e caricato da `m_Mov24`.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op_` (3 byte, Macro): Valore (`IMM`) o indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_and24"></a>
### m_And24

Chiamata: `+m_And24 .mode_, .op1_, .op2_, .res_`

Esegue un `AND` booleano tra due valori a 24 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .op1_ è un indirizzo e .op2_ è un
       valore a 24 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Con `"IMM"` i byte della costante pari a `$00` o `$FF` sono trattati a parte: azzerano il byte o lo lasciano com'è.

Se `.res_` coincide con il primo operando le copie inutili sono omesse, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (1 o 2 byte, Macro): Indirizzo del primo operando<br>`.op2_` (3 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_ora24"></a>
### m_Ora24

Chiamata: `+m_Ora24 .mode_, .op1_, .op2_, .res_`

Esegue un OR booleano tra due valori a 24 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .op1_ è un indirizzo e .op2_ è un
       valore a 24 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Con `"IMM"` i byte della costante pari a `$00` o `$FF` sono trattati a parte: lasciano il byte com'è o lo portano a `$FF`.

Se `.res_` coincide con il primo operando le copie inutili sono omesse, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (1 o 2 byte, Macro): Indirizzo del primo operando<br>`.op2_` (3 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_eor24"></a>
### m_Eor24

Chiamata: `+m_Eor24 .mode_, .op1_, .op2_, .res_`

Esegue un `EOR` booleano tra due valori a 24 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .op1_ è un indirizzo e .op2_ è un
       valore a 24 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Con `"IMM"` i byte della costante pari a `$00` sono trattati a parte: lasciano il byte com'è.

Se `.res_` coincide con il primo operando le copie inutili sono omesse, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (1 o 2 byte, Macro): Indirizzo del primo operando<br>`.op2_` (3 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_asls24"></a>
### m_AslS24

Chiamata: `+m_AslS24 .mode_, .op_, .res_`

Fa scorrere a sinistra di un bit un valore a 24 bit con segno, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. A differenza di `m_Asl24` il cambiamento di segno dovuto all'uscita del bit più alto è segnalato da V.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit<br>oVerflow (1 bit, .P): 0 = segno invariato; 1 = segno cambiato |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_lsr24"></a>
### m_Lsr24

Chiamata: `+m_Lsr24 .mode_, .op_, .res_`

Fa scorrere a destra di un bit un valore a 24 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più alto del risultato vale zero.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A` (se `.op_` != `.res_`), `.P` (Negative, Zero, Carry), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_asrs24"></a>
### m_AsrS24

Chiamata: `+m_AsrS24 .mode_, .op_, .res_`

Fa scorrere a destra di un bit un valore a 24 bit con segno, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit di segno si conserva.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_rol24"></a>
### m_Rol24

Chiamata: `+m_Rol24 .mode_, .op_, .res_`

Ruota a sinistra di un bit un valore a 24 bit attraverso il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più alto esce nel Carry.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A` (se `.op_` != `.res_`), `.P` (Negative, Zero, Carry), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_rl24"></a>
### m_Rl24

Chiamata: `+m_Rl24 .mode_, .op_, .res_`

Ruota a sinistra di un bit un valore a 24 bit senza passare per il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più alto finisce nella posizione più bassa.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_ror24"></a>
### m_Ror24

Chiamata: `+m_Ror24 .mode_, .op_, .res_`

Ruota a destra di un bit un valore a 24 bit attraverso il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più basso esce nel Carry.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A` (se `.op_` != `.res_`), `.P` (Negative, Zero, Carry), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_rr24"></a>
### m_Rr24

Chiamata: `+m_Rr24 .mode_, .op_, .res_`

Ruota a destra di un bit un valore a 24 bit senza passare per il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più basso finisce nella posizione più alta.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (3 byte, Macro): Riceve il risultato a 24 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry), `.res_`+0 .. +2 |

[↑ Torna al contenuto](#contenuto)

<a id="modulo-math32"></a>
## math32.asm

Macro per operazioni matematiche su valori a 32 bit.

<a id="utilita-m_asl32"></a>
### m_Asl32

Chiamata: `+m_Asl32 .mode_, .op_, .res_`

Fa scorrere a sinistra di un bit un valore a 32 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. È uno scorrimento logico: non si tiene traccia di un eventuale overflow.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A` (se `.op_` != `.res_`), `.P` (Negative, Zero, Carry), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_add32"></a>
### m_Add32

Chiamata: `+m_Add32 .mode_, .add1_, .add2_, .res_`

Somma due valori a 32 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .add1_ è un indirizzo e .add2_ è un
       valore a 32 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Se i due addendi coincidono (`"ABS"` e `"ZP"`) il raddoppio è eseguito da `m_Asl32`, che non imposta V.

Se `.res_` coincide con il primo operando le copie sono omesse, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.add1_` (1 o 2 byte, Macro): Indirizzo del primo addendo<br>`.add2_` (4 byte, Macro): Secondo addendo: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit<br>Carry (1 bit, .P): 0 = riporto assente; 1 = riporto |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_sub32"></a>
### m_Sub32

Chiamata: `+m_Sub32 .mode_, .min_, .sub_, .res_`

Sottrae il sottraendo dal minuendo, due valori a 32 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .min_ è un indirizzo e .sub_ è un
       valore a 32 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Se `.res_` coincide con il minuendo e il sottraendo vale zero, la copia è omessa, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.min_` (1 o 2 byte, Macro): Indirizzo del minuendo<br>`.sub_` (4 byte, Macro): Sottraendo: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit<br>Carry (1 bit, .P): 0 = prestito; 1 = nessun prestito |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_neg32"></a>
### m_Neg32

Chiamata: `+m_Neg32 .mode_, .op_, .res_`

Sottrae un valore a 32 bit da zero, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  .op_ è un valore a 32 bit.
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Con `"IMM"` il risultato è calcolato dall'assemblatore e caricato da `m_Mov32`.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op_` (4 byte, Macro): Valore (`IMM`) o indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_not32"></a>
### m_Not32

Chiamata: `+m_Not32 .mode_, .op_, .res_`

Inverte tutti i bit di un valore a 32 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  .op_ è un valore a 32 bit.
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Con `"IMM"` il risultato è calcolato dall'assemblatore e caricato da `m_Mov32`.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op_` (4 byte, Macro): Valore (`IMM`) o indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_and32"></a>
### m_And32

Chiamata: `+m_And32 .mode_, .op1_, .op2_, .res_`

Esegue un `AND` booleano tra due valori a 32 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .op1_ è un indirizzo e .op2_ è un
       valore a 32 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Con `"IMM"` i byte della costante pari a `$00` o `$FF` sono trattati a parte: azzerano il byte o lo lasciano com'è.

Se `.res_` coincide con il primo operando le copie inutili sono omesse, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (1 o 2 byte, Macro): Indirizzo del primo operando<br>`.op2_` (4 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_ora32"></a>
### m_Ora32

Chiamata: `+m_Ora32 .mode_, .op1_, .op2_, .res_`

Esegue un OR booleano tra due valori a 32 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .op1_ è un indirizzo e .op2_ è un
       valore a 32 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Con `"IMM"` i byte della costante pari a `$00` o `$FF` sono trattati a parte: lasciano il byte com'è o lo portano a `$FF`.

Se `.res_` coincide con il primo operando le copie inutili sono omesse, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (1 o 2 byte, Macro): Indirizzo del primo operando<br>`.op2_` (4 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_eor32"></a>
### m_Eor32

Chiamata: `+m_Eor32 .mode_, .op1_, .op2_, .res_`

Esegue un `EOR` booleano tra due valori a 32 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata.

```
"IMM"  Immediato: .op1_ è un indirizzo e .op2_ è un
       valore a 32 bit.
"ABS"  Assoluto: gli operandi sono indirizzi
       assoluti.
"ZP"   Pagina Zero: gli operandi sono indirizzi in
       pagina zero.
```

Con `"IMM"` i byte della costante pari a `$00` sono trattati a parte: lasciano il byte com'è.

Se `.res_` coincide con il primo operando le copie inutili sono omesse, e N e Z non riflettono il risultato.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"IMM"`, `"ABS"` oppure `"ZP"`<br>`.op1_` (1 o 2 byte, Macro): Indirizzo del primo operando<br>`.op2_` (4 byte, Macro): Secondo operando: valore (`IMM`) o indirizzo<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_asls32"></a>
### m_AslS32

Chiamata: `+m_AslS32 .mode_, .op_, .res_`

Fa scorrere a sinistra di un bit un valore a 32 bit con segno, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. A differenza di `m_Asl32` il cambiamento di segno dovuto all'uscita del bit più alto è segnalato da V.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit<br>oVerflow (1 bit, .P): 0 = segno invariato; 1 = segno cambiato |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_lsr32"></a>
### m_Lsr32

Chiamata: `+m_Lsr32 .mode_, .op_, .res_`

Fa scorrere a destra di un bit un valore a 32 bit, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più alto del risultato vale zero.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A` (se `.op_` != `.res_`), `.P` (Negative, Zero, Carry), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_asrs32"></a>
### m_AsrS32

Chiamata: `+m_AsrS32 .mode_, .op_, .res_`

Fa scorrere a destra di un bit un valore a 32 bit con segno, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit di segno si conserva.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_rol32"></a>
### m_Rol32

Chiamata: `+m_Rol32 .mode_, .op_, .res_`

Ruota a sinistra di un bit un valore a 32 bit attraverso il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più alto esce nel Carry.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A` (se `.op_` != `.res_`), `.P` (Negative, Zero, Carry), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_rl32"></a>
### m_Rl32

Chiamata: `+m_Rl32 .mode_, .op_, .res_`

Ruota a sinistra di un bit un valore a 32 bit senza passare per il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più alto finisce nella posizione più bassa.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_ror32"></a>
### m_Ror32

Chiamata: `+m_Ror32 .mode_, .op_, .res_`

Ruota a destra di un bit un valore a 32 bit attraverso il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più basso esce nel Carry.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit<br>Carry (1 bit, .P): 0 = bit uscito 0; 1 = bit uscito 1 |
| Registri Modificati | `.A` (se `.op_` != `.res_`), `.P` (Negative, Zero, Carry), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_rr32"></a>
### m_Rr32

Chiamata: `+m_Rr32 .mode_, .op_, .res_`

Ruota a destra di un bit un valore a 32 bit senza passare per il Carry, secondo l'indirizzamento scelto, e memorizza il risultato nella locazione desiderata. Il bit più basso finisce nella posizione più alta.

```
"ABS"  .op_ è un indirizzo assoluto.
"ZP"   .op_ è un indirizzo in pagina zero.
```

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mode_` (stringa, Macro): Indirizzamento: `"ABS"` oppure `"ZP"`<br>`.op_` (1 o 2 byte, Macro): Indirizzo dell'operando<br>`.res_` (1 o 2 byte, Macro): Indirizzo del risultato, assoluto o in pagina zero |
| Output | `.res_` (4 byte, Macro): Riceve il risultato a 32 bit |
| Registri Modificati | `.A`, `.P` (Negative, Zero, Carry), `.res_`+0 .. +3 |

[↑ Torna al contenuto](#contenuto)

<a id="modulo-math_mult"></a>
## math_mult.asm

Moltiplicazione intera senza segno e con segno per tutte le combinazioni di operandi da 8 a 32 bit. Il prodotto ha sempre la lunghezza esatta m+n bit, senza perdita di precisione.

Requisiti di pagina zero: `MUL_1`, `MUL_2`, `MUL_RES`.

Note d'uso del modulo: [Nota #01](#nota-math_mult-01), [Nota #02](#nota-math_mult-02), [Nota #03](#nota-math_mult-03).

<a id="utilita-m_mul_negate"></a>
### m_Mul_Negate

Chiamata: `+m_Mul_Negate .address_, .bytes_`

Nega sul posto un valore a più byte in pagina zero, cioè lo sostituisce con il suo complemento a 2. Serve per rendere positivi gli operandi e per correggere il segno del prodotto.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.address_` (1 byte, Macro): Indirizzo in pagina zero del byte meno significativo<br>`.bytes_` (1 byte, Macro): Numero di byte del valore (da 1 a 8) |
| Output | `.address_` (1 .. 8 byte, ZP): Il valore negato, nelle stesse locazioni |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.address_`+0 .. `.address_`+`.bytes_`-1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_mul_stage"></a>
### m_Mul_Stage

Chiamata: `+m_Mul_Stage .stage_, .mcand_bytes_, .mplier_bytes_`

Elabora un byte del moltiplicatore con 8 iterazioni di shift-and-add. Ogni iterazione somma il moltiplicando all'accumulatore alto se il bit in esame vale 1, poi fa scorrere a destra l'accumulatore e il byte in esame. I bit esaminati escono dal byte del moltiplicatore e al loro posto entrano i bit bassi dell'accumulatore, che formano un byte definitivo del prodotto finale.

Se il moltiplicando ha un solo byte l'accumulatore alto sta tutto in `.A`. Altrimenti il byte più alto dell'accumulatore sta in `.A` e gli altri nei byte di `MUL_RES` che seguono quelli del moltiplicatore; il byte più alto si scrive in memoria solo alla fine di `m_Mul_Core`.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.stage_` (1 byte, Macro): Indice del byte del moltiplicatore (0 = il meno significativo)<br>`.mcand_bytes_` (1 byte, Macro): Byte del moltiplicando (da 1 a 4)<br>`.mplier_bytes_` (1 byte, Macro): Byte del moltiplicatore (da 1 a 4)<br>`MUL_1` (1 .. 4 byte, ZP): Moltiplicando<br>`MUL_RES` (2 .. 8 byte, ZP): Moltiplicatore e accumulatore alto<br>`.A` (1 byte, CPU): Byte più alto dell'accumulatore |
| Output | `MUL_RES` (2 .. 8 byte, ZP): Il byte `.stage_` diventa un byte definitivo del prodotto<br>`.A` (1 byte, CPU): Byte più alto dell'accumulatore |
| Registri Modificati | `.A`, `.X`, `.Y` (se `.mcand_bytes_` > 1), `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+6` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_mul_core"></a>
### m_Mul_Core

Chiamata: `+m_Mul_Core .mcand_bytes_, .mplier_bytes_`

Moltiplica due valori senza segno con l'algoritmo shift-and-add elaborando un byte del moltiplicatore alla volta (`m_Mul_Stage`). Il moltiplicatore sta nei byte bassi di `MUL_RES`, che a fine operazione contengono il prodotto di `.mcand_bytes_` + `.mplier_bytes_` byte.

Conviene usare come moltiplicando l'operando più lungo, perché il costo cresce con il numero di byte del moltiplicatore.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.mcand_bytes_` (1 byte, Macro): Byte del moltiplicando (da 1 a 4)<br>`.mplier_bytes_` (1 byte, Macro): Byte del moltiplicatore (da 1 a 4)<br>`MUL_1` (1 .. 4 byte, ZP): Moltiplicando (senza segno)<br>`MUL_2` (1 .. 4 byte, ZP): Moltiplicatore (senza segno) |
| Output | `MUL_RES` (2 .. 8 byte, ZP): Prodotto della moltiplicazione |
| Registri Modificati | `.A`, `.X`, `.Y` (se `.mcand_bytes_` > 1), `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+7` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_mul_core_8x8"></a>
### m_Mul_Core_8x8

Moltiplicazione senza segno tra due valori a 8 bit con il nucleo generico `m_Mul_Core`.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` (1 byte, ZP): Moltiplicando<br>`MUL_2+0` (1 byte, ZP): Moltiplicatore |
| Output | `MUL_RES+0` .. `MUL_RES+1` (2 byte, ZP): Prodotto a 16 bit |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_mul_core_16x8"></a>
### m_Mul_Core_16x8

Moltiplicazione senza segno tra un valore a 16 bit (moltiplicando) e uno a 8 bit (moltiplicatore) con il nucleo generico `m_Mul_Core`.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+1` (2 byte, ZP): Moltiplicando<br>`MUL_2+0` (1 byte, ZP): Moltiplicatore |
| Output | `MUL_RES+0` .. `MUL_RES+2` (3 byte, ZP): Prodotto a 24 bit |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+2` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_mul_core_24x8"></a>
### m_Mul_Core_24x8

Moltiplicazione senza segno tra un valore a 24 bit (moltiplicando) e uno a 8 bit (moltiplicatore) con il nucleo generico `m_Mul_Core`.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+2` (3 byte, ZP): Moltiplicando<br>`MUL_2+0` (1 byte, ZP): Moltiplicatore |
| Output | `MUL_RES+0` .. `MUL_RES+3` (4 byte, ZP): Prodotto a 32 bit |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+3` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_mul_core_32x8"></a>
### m_Mul_Core_32x8

Moltiplicazione senza segno tra un valore a 32 bit (moltiplicando) e uno a 8 bit (moltiplicatore) con il nucleo generico `m_Mul_Core`.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+3` (4 byte, ZP): Moltiplicando<br>`MUL_2+0` (1 byte, ZP): Moltiplicatore |
| Output | `MUL_RES+0` .. `MUL_RES+4` (5 byte, ZP): Prodotto a 40 bit |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+4` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_mul_core_16x16"></a>
### m_Mul_Core_16x16

Moltiplicazione senza segno tra due valori a 16 bit con il nucleo generico `m_Mul_Core`.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+1` (2 byte, ZP): Moltiplicando<br>`MUL_2+0` .. `MUL_2+1` (2 byte, ZP): Moltiplicatore |
| Output | `MUL_RES+0` .. `MUL_RES+3` (4 byte, ZP): Prodotto a 32 bit |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+3` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_mul_core_24x16"></a>
### m_Mul_Core_24x16

Moltiplicazione senza segno tra un valore a 24 bit (moltiplicando) e uno a 16 bit (moltiplicatore) con il nucleo generico `m_Mul_Core`.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+2` (3 byte, ZP): Moltiplicando<br>`MUL_2+0` .. `MUL_2+1` (2 byte, ZP): Moltiplicatore |
| Output | `MUL_RES+0` .. `MUL_RES+4` (5 byte, ZP): Prodotto a 40 bit |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+4` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_mul_core_32x16"></a>
### m_Mul_Core_32x16

Moltiplicazione senza segno tra un valore a 32 bit (moltiplicando) e uno a 16 bit (moltiplicatore) con il nucleo generico `m_Mul_Core`.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+3` (4 byte, ZP): Moltiplicando<br>`MUL_2+0` .. `MUL_2+1` (2 byte, ZP): Moltiplicatore |
| Output | `MUL_RES+0` .. `MUL_RES+5` (6 byte, ZP): Prodotto a 48 bit |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+5` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_mul_core_24x24"></a>
### m_Mul_Core_24x24

Moltiplicazione senza segno tra due valori a 24 bit con il nucleo generico `m_Mul_Core`.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+2` (3 byte, ZP): Moltiplicando<br>`MUL_2+0` .. `MUL_2+2` (3 byte, ZP): Moltiplicatore |
| Output | `MUL_RES+0` .. `MUL_RES+5` (6 byte, ZP): Prodotto a 48 bit |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+5` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_mul_core_32x24"></a>
### m_Mul_Core_32x24

Moltiplicazione senza segno tra un valore a 32 bit (moltiplicando) e uno a 24 bit (moltiplicatore) con il nucleo generico `m_Mul_Core`.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+3` (4 byte, ZP): Moltiplicando<br>`MUL_2+0` .. `MUL_2+2` (3 byte, ZP): Moltiplicatore |
| Output | `MUL_RES+0` .. `MUL_RES+6` (7 byte, ZP): Prodotto a 56 bit |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+6` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_mul_core_32x32"></a>
### m_Mul_Core_32x32

Moltiplicazione senza segno tra due valori a 32 bit con il nucleo generico `m_Mul_Core`.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+3` (4 byte, ZP): Moltiplicando<br>`MUL_2+0` .. `MUL_2+3` (4 byte, ZP): Moltiplicatore |
| Output | `MUL_RES+0` .. `MUL_RES+7` (8 byte, ZP): Prodotto a 64 bit |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+7` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-mul_8x8"></a>
### MUL_8X8

Moltiplica due interi a 8 bit, senza segno.

| Voce | Contenuto |
|---|---|
| Input | `.A` (1 byte, CPU): Primo operando (moltiplicando)<br>`.X` (1 byte, CPU): Secondo operando (moltiplicatore) |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`MUL_RES+0` .. `MUL_RES+1` (2 byte, ZP): Prodotto a 16 bit<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_1+0`, `MUL_RES+0` .. `MUL_RES+1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-smul_8x8"></a>
### SMUL_8X8

Moltiplica due interi a 8 bit, con segno.

Rende positivi gli operandi, esegue il nucleo senza segno e, se i segni erano diversi, nega il prodotto.

| Voce | Contenuto |
|---|---|
| Input | `.A` (1 byte, CPU): Primo operando con segno (moltiplicando)<br>`.X` (1 byte, CPU): Secondo operando con segno (moltiplicatore) |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`MUL_RES+0` .. `MUL_RES+1` (2 byte, ZP): Prodotto a 16 bit con segno<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_1+0`, `MUL_RES+0` .. `MUL_RES+1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-mul_16x8"></a>
### MUL_16X8

Moltiplica un intero a 16 bit per uno a 8 bit, senza segno.

| Voce | Contenuto |
|---|---|
| Input | `.A` (1 byte, CPU): Primo operando, byte basso<br>`.X` (1 byte, CPU): Primo operando, byte alto<br>`.Y` (1 byte, CPU): Secondo operando (moltiplicatore) |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+2` (3 byte, ZP): Prodotto a 24 bit<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_1+0` .. `MUL_1+1`, `MUL_RES+0` .. `MUL_RES+2` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-smul_16x8"></a>
### SMUL_16X8

Moltiplica un intero a 16 bit per uno a 8 bit, con segno.

Rende positivi gli operandi, esegue il nucleo senza segno e, se i segni erano diversi, nega il prodotto.

| Voce | Contenuto |
|---|---|
| Input | `.A` (1 byte, CPU): Primo operando con segno, byte basso<br>`.X` (1 byte, CPU): Primo operando con segno, byte alto<br>`.Y` (1 byte, CPU): Secondo operando con segno (moltiplicatore) |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+2` (3 byte, ZP): Prodotto a 24 bit con segno<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_1+0` .. `MUL_1+1`, `MUL_RES+0` .. `MUL_RES+2` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-mul_24x8"></a>
### MUL_24X8

Moltiplica un intero a 24 bit per uno a 8 bit, senza segno.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+2` (3 byte, ZP): Primo operando (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando (moltiplicatore) |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+3` (4 byte, ZP): Prodotto a 32 bit<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+3` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-smul_24x8"></a>
### SMUL_24X8

Moltiplica un intero a 24 bit per uno a 8 bit, con segno.

Rende positivi gli operandi, esegue il nucleo senza segno e, se i segni erano diversi, nega il prodotto.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+2` (3 byte, ZP): Primo operando con segno (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando con segno (moltiplicatore) |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+3` (4 byte, ZP): Prodotto a 32 bit con segno<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_1+0` .. `MUL_1+2`, `MUL_RES+0` .. `MUL_RES+3` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-mul_32x8"></a>
### MUL_32X8

Moltiplica un intero a 32 bit per uno a 8 bit, senza segno.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+3` (4 byte, ZP): Primo operando (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando (moltiplicatore) |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+4` (5 byte, ZP): Prodotto a 40 bit<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+4` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-smul_32x8"></a>
### SMUL_32X8

Moltiplica un intero a 32 bit per uno a 8 bit, con segno.

Rende positivi gli operandi, esegue il nucleo senza segno e, se i segni erano diversi, nega il prodotto.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+3` (4 byte, ZP): Primo operando con segno (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando con segno (moltiplicatore) |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+4` (5 byte, ZP): Prodotto a 40 bit con segno<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_1+0` .. `MUL_1+3`, `MUL_RES+0` .. `MUL_RES+4` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-mul_16x16"></a>
### MUL_16X16

Moltiplica due interi a 16 bit, senza segno.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+1` (2 byte, ZP): Primo operando (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando, byte 0<br>`.X` (1 byte, CPU): Secondo operando, byte 1 |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+3` (4 byte, ZP): Prodotto a 32 bit<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+3` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-smul_16x16"></a>
### SMUL_16X16

Moltiplica due interi a 16 bit, con segno.

Rende positivi gli operandi, esegue il nucleo senza segno e, se i segni erano diversi, nega il prodotto.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+1` (2 byte, ZP): Primo operando con segno (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando con segno, byte 0<br>`.X` (1 byte, CPU): Secondo operando con segno, byte 1 |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+3` (4 byte, ZP): Prodotto a 32 bit con segno<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_1+0` .. `MUL_1+1`, `MUL_RES+0` .. `MUL_RES+3` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-mul_24x16"></a>
### MUL_24X16

Moltiplica un intero a 24 bit per uno a 16 bit, senza segno.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+2` (3 byte, ZP): Primo operando (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando, byte 0<br>`.X` (1 byte, CPU): Secondo operando, byte 1 |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+4` (5 byte, ZP): Prodotto a 40 bit<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+4` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-smul_24x16"></a>
### SMUL_24X16

Moltiplica un intero a 24 bit per uno a 16 bit, con segno.

Rende positivi gli operandi, esegue il nucleo senza segno e, se i segni erano diversi, nega il prodotto.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+2` (3 byte, ZP): Primo operando con segno (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando con segno, byte 0<br>`.X` (1 byte, CPU): Secondo operando con segno, byte 1 |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+4` (5 byte, ZP): Prodotto a 40 bit con segno<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_1+0` .. `MUL_1+2`, `MUL_RES+0` .. `MUL_RES+4` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-mul_32x16"></a>
### MUL_32X16

Moltiplica un intero a 32 bit per uno a 16 bit, senza segno.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+3` (4 byte, ZP): Primo operando (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando, byte 0<br>`.X` (1 byte, CPU): Secondo operando, byte 1 |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+5` (6 byte, ZP): Prodotto a 48 bit<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+5` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-smul_32x16"></a>
### SMUL_32X16

Moltiplica un intero a 32 bit per uno a 16 bit, con segno.

Rende positivi gli operandi, esegue il nucleo senza segno e, se i segni erano diversi, nega il prodotto.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+3` (4 byte, ZP): Primo operando con segno (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando con segno, byte 0<br>`.X` (1 byte, CPU): Secondo operando con segno, byte 1 |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+5` (6 byte, ZP): Prodotto a 48 bit con segno<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_1+0` .. `MUL_1+3`, `MUL_RES+0` .. `MUL_RES+5` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-mul_24x24"></a>
### MUL_24X24

Moltiplica due interi a 24 bit, senza segno.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+2` (3 byte, ZP): Primo operando (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando, byte 0<br>`.X` (1 byte, CPU): Secondo operando, byte 1<br>`.Y` (1 byte, CPU): Secondo operando, byte 2 |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+5` (6 byte, ZP): Prodotto a 48 bit<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+5` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-smul_24x24"></a>
### SMUL_24X24

Moltiplica due interi a 24 bit, con segno.

Rende positivi gli operandi, esegue il nucleo senza segno e, se i segni erano diversi, nega il prodotto.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+2` (3 byte, ZP): Primo operando con segno (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando con segno, byte 0<br>`.X` (1 byte, CPU): Secondo operando con segno, byte 1<br>`.Y` (1 byte, CPU): Secondo operando con segno, byte 2 |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+5` (6 byte, ZP): Prodotto a 48 bit con segno<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_1+0` .. `MUL_1+2`, `MUL_RES+0` .. `MUL_RES+5` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-mul_32x24"></a>
### MUL_32X24

Moltiplica un intero a 32 bit per uno a 24 bit, senza segno.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+3` (4 byte, ZP): Primo operando (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando, byte 0<br>`.X` (1 byte, CPU): Secondo operando, byte 1<br>`.Y` (1 byte, CPU): Secondo operando, byte 2 |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+6` (7 byte, ZP): Prodotto a 56 bit<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+6` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-smul_32x24"></a>
### SMUL_32X24

Moltiplica un intero a 32 bit per uno a 24 bit, con segno.

Rende positivi gli operandi, esegue il nucleo senza segno e, se i segni erano diversi, nega il prodotto.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+3` (4 byte, ZP): Primo operando con segno (moltiplicando)<br>`.A` (1 byte, CPU): Secondo operando con segno, byte 0<br>`.X` (1 byte, CPU): Secondo operando con segno, byte 1<br>`.Y` (1 byte, CPU): Secondo operando con segno, byte 2 |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+6` (7 byte, ZP): Prodotto a 56 bit con segno<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_1+0` .. `MUL_1+3`, `MUL_RES+0` .. `MUL_RES+6` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-mul_32x32"></a>
### MUL_32X32

Moltiplica due interi a 32 bit, senza segno.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+3` (4 byte, ZP): Primo operando (moltiplicando)<br>`MUL_2+0` .. `MUL_2+3` (4 byte, ZP): Secondo operando (moltiplicatore) |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+7` (8 byte, ZP): Prodotto a 64 bit<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_RES+0` .. `MUL_RES+7` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-smul_32x32"></a>
### SMUL_32X32

Moltiplica due interi a 32 bit, con segno.

Rende positivi gli operandi, esegue il nucleo senza segno e, se i segni erano diversi, nega il prodotto.

| Voce | Contenuto |
|---|---|
| Input | `MUL_1+0` .. `MUL_1+3` (4 byte, ZP): Primo operando con segno (moltiplicando)<br>`MUL_2+0` .. `MUL_2+3` (4 byte, ZP): Secondo operando con segno (moltiplicatore) |
| Output | `.A` (1 byte, CPU): Byte 0 del prodotto<br>`.X` (1 byte, CPU): Byte 1 del prodotto<br>`.Y` (1 byte, CPU): Byte 2 del prodotto<br>`MUL_RES+0` .. `MUL_RES+7` (8 byte, ZP): Prodotto a 64 bit con segno<br>Carry (1 bit, .P): sempre 0 |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `MUL_1+0` .. `MUL_1+3`, `MUL_RES+0` .. `MUL_RES+7` |

[↑ Torna al contenuto](#contenuto)

### Note d'uso di `math_mult.asm`

<a id="nota-math_mult-01"></a>
#### Nota #01

Il primo operando è il più lungo e fa da moltiplicando; il secondo è il moltiplicatore. Le routine con operandi in registri usano, dal byte più basso al più alto, `.A`, `.X` e `.Y` (cioè la terna `.YXA`, come nell'ordine di memoria). I byte del prodotto oltre il terzo non entrano nei registri: si leggono da `MUL_RES+3` in poi.

```
  Routine  1º operando    2º operando    Registri in uscita
  -------  -------------  -------------  ------------------
  8x8      .A             .X             .A, .X
  16x8     .A basso,      .Y             .A, .X, .Y
           .X alto
  24x8     MUL_1 (ZP)     .A             .A, .X, .Y
  32x8     MUL_1 (ZP)     .A             .A, .X, .Y
  16x16    MUL_1 (ZP)     .A basso,      .A, .X, .Y
                          .X alto
  24x16    MUL_1 (ZP)     .A basso,      .A, .X, .Y
                          .X alto
  32x16    MUL_1 (ZP)     .A basso,      .A, .X, .Y
                          .X alto
  24x24    MUL_1 (ZP)     .A, .X, .Y     .A, .X, .Y
  32x24    MUL_1 (ZP)     .A, .X, .Y     .A, .X, .Y
  32x32    MUL_1 (ZP)     MUL_2 (ZP)     .A, .X, .Y
```

Per le versioni con segno gli operandi sono in complemento a 2 e il prodotto ha il segno corretto. L'input non si conserva: il moltiplicatore viene consumato e, nelle versioni con segno, gli operandi diventano positivi.

<a id="nota-math_mult-02"></a>
#### Nota #02

Le routine lavorano in pagina zero sui 12 byte da `NUMWRK` a `NUMWRK+11`, cioè `NUMWRK` più i primi due byte di `FAC`, che sono liberi finché non si usa la matematica in virgola mobile del BASIC.

```
  MUL_1    NUMWRK+0 .. NUMWRK+3     Moltiplicando (primo operando)
  MUL_2    NUMWRK+4 .. NUMWRK+7     Moltiplicatore (secondo operando)
  MUL_RES  NUMWRK+4 .. NUMWRK+11    Prodotto, da 2 a 8 byte
```

`MUL_2` e `MUL_RES` coincidono: il moltiplicatore occupa i byte bassi del prodotto e viene consumato mentre i byte definitivi prendono il suo posto, bit dopo bit. I byte alti di `MUL_RES` ospitano l'accumulatore. Per questo il moltiplicatore non si conserva e `MUL_2` e `MUL_RES` non si usano insieme.

La stessa area è condivisa con `ZPL_1` e `ZPL_2` (puntatori utente a 24/32 bit) e con le routine di divisione: non si possono usare contemporaneamente.

<a id="nota-math_mult-03"></a>
#### Nota #03

Si elabora un byte del moltiplicatore alla volta, con 8 iterazioni di shift-and-add: se il bit meno significativo vale 1 si somma il moltiplicando all'accumulatore alto, poi tutto scorre di un bit a destra. Il moltiplicando non si sposta mai e ogni iterazione fa scorrere solo l'accumulatore e il byte in esame del moltiplicatore, non l'intero prodotto. Il byte più alto dell'accumulatore resta in `.A` per tutta l'elaborazione e si scrive in memoria una sola volta, alla fine.

I cicli medi con operandi casuali comprendono il caricamento dei registri e l'rts, ma non la jsr.

```
  Routine  Senza segno  Con segno
  8x8            167       214
  16x8           270       315
  24x8           336       390
  32x8           415       466
  16x16          496       555
  24x16          663       700
  32x16          818       864
  24x24          982      1007
  32x24         1222      1234
  32x32         1582      1624
```

[↑ Torna al contenuto](#contenuto)

<a id="modulo-math_div"></a>
## math_div.asm

Divisione intera senza segno e con segno per tutte le combinazioni di operandi da 8 a 32 bit. Il quoziente ha la lunghezza del dividendo e il resto quella del divisore, senza perdita di precisione.

Requisiti di pagina zero: `DIV_1`, `DIV_2`, `DIV_QUOT`, `DIV_REM`.

Note d'uso del modulo: [Nota #01](#nota-math_div-01), [Nota #02](#nota-math_div-02), [Nota #03](#nota-math_div-03), [Nota #04](#nota-math_div-04).

<a id="utilita-m_div_negate"></a>
### m_Div_Negate

Chiamata: `+m_Div_Negate .address_, .bytes_`

Nega sul posto un valore a più byte in pagina zero, cioè lo sostituisce con il suo complemento a 2. Serve per rendere positivi dividendo e divisore e per correggere il segno di quoziente e resto.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.address_` (1 byte, Macro): Indirizzo in pagina zero del byte meno significativo<br>`.bytes_` (1 byte, Macro): Numero di byte del valore (da 1 a 4) |
| Output | `.address_` (1 .. 4 byte, ZP): Il valore negato, nelle stesse locazioni |
| Registri Modificati | `.A`, `.P` (Negative, oVerflow, Zero, Carry), `.address_`+0 .. `.address_`+`.bytes_`-1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_roll"></a>
### m_Div_Roll

Chiamata: `+m_Div_Roll .address_, .bytes_`

Fa scorrere a sinistra di un bit un valore a più byte in pagina zero. Il Carry entra nel bit meno significativo e il bit più alto del valore esce nel Carry.

Gli operandi devono essere definiti prima dell'invocazione, perché la macro li confronta per scegliere il ramo.

| Voce | Contenuto |
|---|---|
| Input | `.address_` (1 byte, Macro): Indirizzo in pagina zero del byte meno significativo<br>`.bytes_` (1 byte, Macro): Numero di byte del valore (da 1 a 4)<br>Carry (1 bit, .P): 0 = entra uno 0; 1 = entra un 1 |
| Output | `.address_` (1 .. 4 byte, ZP): Il valore scorso di un bit<br>Carry (1 bit, .P): 0 = esce uno 0; 1 = esce un 1 |
| Registri Modificati | `.P` (Negative, oVerflow, Zero, Carry), `.address_`+0 .. `.address_`+`.bytes_`-1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_core_byte"></a>
### m_Div_Core_Byte

Chiamata: `+m_Div_Core_Byte .dvd_bytes_`

Divisione senza segno con un divisore a 8 bit e un dividendo da 1 a 4 byte. Per ogni bit del dividendo, dal più alto, il resto parziale scorre a sinistra e riceve il bit; se è maggiore o uguale al divisore si sottrae e il bit di quoziente vale 1. Quel bit entra nel dividendo alla rotazione seguente, quindi il quoziente prende il posto del dividendo.

Il resto parziale sta in `.A` per tutta l'elaborazione e si scrive in memoria una sola volta, alla fine. Il divisore deve essere diverso da zero: la macro non lo controlla.

| Voce | Contenuto |
|---|---|
| Input | `.dvd_bytes_` (1 byte, Macro): Byte del dividendo (da 1 a 4)<br>`DIV_1` (1 .. 4 byte, ZP): Dividendo (senza segno)<br>`DIV_2+0` (1 byte, ZP): Divisore (senza segno, diverso da zero) |
| Output | `DIV_QUOT` (1 .. 4 byte, ZP): Quoziente<br>`DIV_REM+0` (1 byte, ZP): Resto<br>`.A` (1 byte, CPU): Resto (uguale a `DIV_REM+0`) |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT`+`.dvd_bytes_`-1, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_core_multi"></a>
### m_Div_Core_Multi

Chiamata: `+m_Div_Core_Multi .dvd_bytes_, .dvs_bytes_`

Divisione senza segno con un divisore da 2 a 4 byte e un dividendo da 1 a 4 byte. Per ogni bit del dividendo, dal più alto, il resto parziale scorre a sinistra e riceve il bit; se è maggiore o uguale al divisore si sottrae e il bit di quoziente vale 1. Quel bit entra nel dividendo alla rotazione seguente, quindi il quoziente prende il posto del dividendo.

Il confronto parte dal byte più alto e si ferma appena l'esito è noto. Se il resto parziale esce dai suoi byte si sottrae senza confrontare. Il divisore deve essere diverso da zero: la macro non lo controlla.

| Voce | Contenuto |
|---|---|
| Input | `.dvd_bytes_` (1 byte, Macro): Byte del dividendo (da 1 a 4)<br>`.dvs_bytes_` (1 byte, Macro): Byte del divisore (da 2 a 4)<br>`DIV_1` (1 .. 4 byte, ZP): Dividendo (senza segno)<br>`DIV_2` (2 .. 4 byte, ZP): Divisore (senza segno, diverso da zero) |
| Output | `DIV_QUOT` (1 .. 4 byte, ZP): Quoziente<br>`DIV_REM` (2 .. 4 byte, ZP): Resto |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT`+`.dvd_bytes_`-1, `DIV_REM+0` .. `DIV_REM`+`.dvs_bytes_`-1 |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_core_8x8"></a>
### m_Div_Core_8x8

Divisione senza segno tra due valori a 8 bit con il nucleo generico `m_Div_Core_Multi`.

Il divisore deve essere diverso da zero: la macro non lo controlla.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` (1 byte, ZP): Dividendo (senza segno)<br>`DIV_2+0` (1 byte, ZP): Divisore (senza segno, diverso da zero) |
| Output | `.A` (1 byte, CPU): Resto (uguale a `DIV_REM+0`)<br>`DIV_QUOT+0` (1 byte, ZP): Quoziente a 8 bit<br>`DIV_REM+0` (1 byte, ZP): Resto a 8 bit |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0`, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_core_16x8"></a>
### m_Div_Core_16x8

Divisione senza segno tra un valore a 16 bit (dividendo) e uno a 8 bit (divisore) con il nucleo generico `m_Div_Core_Byte`.

Il divisore deve essere diverso da zero: la macro non lo controlla.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+1` (2 byte, ZP): Dividendo (senza segno)<br>`DIV_2+0` (1 byte, ZP): Divisore (senza segno, diverso da zero) |
| Output | `.A` (1 byte, CPU): Resto (uguale a `DIV_REM+0`)<br>`DIV_QUOT+0` .. `DIV_QUOT+1` (2 byte, ZP): Quoziente a 16 bit<br>`DIV_REM+0` (1 byte, ZP): Resto a 8 bit |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+1`, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_core_24x8"></a>
### m_Div_Core_24x8

Divisione senza segno tra un valore a 24 bit (dividendo) e uno a 8 bit (divisore) con il nucleo generico `m_Div_Core_Byte`.

Il divisore deve essere diverso da zero: la macro non lo controlla.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+2` (3 byte, ZP): Dividendo (senza segno)<br>`DIV_2+0` (1 byte, ZP): Divisore (senza segno, diverso da zero) |
| Output | `.A` (1 byte, CPU): Resto (uguale a `DIV_REM+0`)<br>`DIV_QUOT+0` .. `DIV_QUOT+2` (3 byte, ZP): Quoziente a 24 bit<br>`DIV_REM+0` (1 byte, ZP): Resto a 8 bit |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+2`, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_core_32x8"></a>
### m_Div_Core_32x8

Divisione senza segno tra un valore a 32 bit (dividendo) e uno a 8 bit (divisore) con il nucleo generico `m_Div_Core_Byte`.

Il divisore deve essere diverso da zero: la macro non lo controlla.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+3` (4 byte, ZP): Dividendo (senza segno)<br>`DIV_2+0` (1 byte, ZP): Divisore (senza segno, diverso da zero) |
| Output | `.A` (1 byte, CPU): Resto (uguale a `DIV_REM+0`)<br>`DIV_QUOT+0` .. `DIV_QUOT+3` (4 byte, ZP): Quoziente a 32 bit<br>`DIV_REM+0` (1 byte, ZP): Resto a 8 bit |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+3`, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_core_16x16"></a>
### m_Div_Core_16x16

Divisione senza segno tra due valori a 16 bit con il nucleo generico `m_Div_Core_Multi`.

Il divisore deve essere diverso da zero: la macro non lo controlla.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+1` (2 byte, ZP): Dividendo (senza segno)<br>`DIV_2+0` .. `DIV_2+1` (2 byte, ZP): Divisore (senza segno, diverso da zero) |
| Output | `DIV_QUOT+0` .. `DIV_QUOT+1` (2 byte, ZP): Quoziente a 16 bit<br>`DIV_REM+0` .. `DIV_REM+1` (2 byte, ZP): Resto a 16 bit |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+1`, `DIV_REM+0` .. `DIV_REM+1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_core_24x16"></a>
### m_Div_Core_24x16

Divisione senza segno tra un valore a 24 bit (dividendo) e uno a 16 bit (divisore) con il nucleo generico `m_Div_Core_Multi`.

Il divisore deve essere diverso da zero: la macro non lo controlla.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+2` (3 byte, ZP): Dividendo (senza segno)<br>`DIV_2+0` .. `DIV_2+1` (2 byte, ZP): Divisore (senza segno, diverso da zero) |
| Output | `DIV_QUOT+0` .. `DIV_QUOT+2` (3 byte, ZP): Quoziente a 24 bit<br>`DIV_REM+0` .. `DIV_REM+1` (2 byte, ZP): Resto a 16 bit |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+2`, `DIV_REM+0` .. `DIV_REM+1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_core_32x16"></a>
### m_Div_Core_32x16

Divisione senza segno tra un valore a 32 bit (dividendo) e uno a 16 bit (divisore) con il nucleo generico `m_Div_Core_Multi`.

Il divisore deve essere diverso da zero: la macro non lo controlla.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+3` (4 byte, ZP): Dividendo (senza segno)<br>`DIV_2+0` .. `DIV_2+1` (2 byte, ZP): Divisore (senza segno, diverso da zero) |
| Output | `DIV_QUOT+0` .. `DIV_QUOT+3` (4 byte, ZP): Quoziente a 32 bit<br>`DIV_REM+0` .. `DIV_REM+1` (2 byte, ZP): Resto a 16 bit |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+3`, `DIV_REM+0` .. `DIV_REM+1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_core_24x24"></a>
### m_Div_Core_24x24

Divisione senza segno tra due valori a 24 bit con il nucleo generico `m_Div_Core_Multi`.

Il divisore deve essere diverso da zero: la macro non lo controlla.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+2` (3 byte, ZP): Dividendo (senza segno)<br>`DIV_2+0` .. `DIV_2+2` (3 byte, ZP): Divisore (senza segno, diverso da zero) |
| Output | `DIV_QUOT+0` .. `DIV_QUOT+2` (3 byte, ZP): Quoziente a 24 bit<br>`DIV_REM+0` .. `DIV_REM+2` (3 byte, ZP): Resto a 24 bit |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+2`, `DIV_REM+0` .. `DIV_REM+2` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_core_32x24"></a>
### m_Div_Core_32x24

Divisione senza segno tra un valore a 32 bit (dividendo) e uno a 24 bit (divisore) con il nucleo generico `m_Div_Core_Multi`.

Il divisore deve essere diverso da zero: la macro non lo controlla.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+3` (4 byte, ZP): Dividendo (senza segno)<br>`DIV_2+0` .. `DIV_2+2` (3 byte, ZP): Divisore (senza segno, diverso da zero) |
| Output | `DIV_QUOT+0` .. `DIV_QUOT+3` (4 byte, ZP): Quoziente a 32 bit<br>`DIV_REM+0` .. `DIV_REM+2` (3 byte, ZP): Resto a 24 bit |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+3`, `DIV_REM+0` .. `DIV_REM+2` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-m_div_core_32x32"></a>
### m_Div_Core_32x32

Divisione senza segno tra due valori a 32 bit con il nucleo generico `m_Div_Core_Multi`.

Il divisore deve essere diverso da zero: la macro non lo controlla.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+3` (4 byte, ZP): Dividendo (senza segno)<br>`DIV_2+0` .. `DIV_2+3` (4 byte, ZP): Divisore (senza segno, diverso da zero) |
| Output | `DIV_QUOT+0` .. `DIV_QUOT+3` (4 byte, ZP): Quoziente a 32 bit<br>`DIV_REM+0` .. `DIV_REM+3` (4 byte, ZP): Resto a 32 bit |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+3`, `DIV_REM+0` .. `DIV_REM+3` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-div_8x8"></a>
### DIV_8X8

Divide due interi a 8 bit, senza segno. Il quoziente ha 8 bit e il resto 8 bit.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `.A` (1 byte, CPU): Dividendo<br>`.X` (1 byte, CPU): Divisore |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Resto (uguale a `DIV_REM+0`)<br>`DIV_QUOT+0` (1 byte, ZP): Quoziente a 8 bit<br>`DIV_REM+0` (1 byte, ZP): Resto a 8 bit<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0`, `DIV_2+0`, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-sdiv_8x8"></a>
### SDIV_8X8

Divide due interi a 8 bit, con segno. Il quoziente ha 8 bit e il resto 8 bit.

Rende positivi dividendo e divisore, esegue il nucleo senza segno e corregge i segni: il quoziente è negativo se i segni degli operandi sono diversi e il resto ha il segno del dividendo.

L'unico overflow possibile è -2^7 diviso -1: il quoziente esce troncato ai 8 bit bassi e il flag di oVerflow vale 1.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `.A` (1 byte, CPU): Dividendo con segno<br>`.X` (1 byte, CPU): Divisore con segno |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Resto (uguale a `DIV_REM+0`)<br>`DIV_QUOT+0` (1 byte, ZP): Quoziente a 8 bit con segno<br>`DIV_REM+0` (1 byte, ZP): Resto a 8 bit con segno<br>oVerflow (1 bit, .P): 0 = nessuno; 1 = overflow<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0`, `DIV_2+0`, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-div_16x8"></a>
### DIV_16X8

Divide un intero a 16 bit per uno a 8 bit, senza segno. Il quoziente ha 16 bit e il resto 8 bit.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+1` (2 byte, ZP): Dividendo<br>`.A` (1 byte, CPU): Divisore |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Resto (uguale a `DIV_REM+0`)<br>`DIV_QUOT+0` .. `DIV_QUOT+1` (2 byte, ZP): Quoziente a 16 bit<br>`DIV_REM+0` (1 byte, ZP): Resto a 8 bit<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+1`, `DIV_2+0`, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-sdiv_16x8"></a>
### SDIV_16X8

Divide un intero a 16 bit per uno a 8 bit, con segno. Il quoziente ha 16 bit e il resto 8 bit.

Rende positivi dividendo e divisore, esegue il nucleo senza segno e corregge i segni: il quoziente è negativo se i segni degli operandi sono diversi e il resto ha il segno del dividendo.

L'unico overflow possibile è -2^15 diviso -1: il quoziente esce troncato ai 16 bit bassi e il flag di oVerflow vale 1.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+1` (2 byte, ZP): Dividendo con segno<br>`.A` (1 byte, CPU): Divisore con segno |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Resto (uguale a `DIV_REM+0`)<br>`DIV_QUOT+0` .. `DIV_QUOT+1` (2 byte, ZP): Quoziente a 16 bit con segno<br>`DIV_REM+0` (1 byte, ZP): Resto a 8 bit con segno<br>oVerflow (1 bit, .P): 0 = nessuno; 1 = overflow<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+1`, `DIV_2+0`, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-div_24x8"></a>
### DIV_24X8

Divide un intero a 24 bit per uno a 8 bit, senza segno. Il quoziente ha 24 bit e il resto 8 bit.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+2` (3 byte, ZP): Dividendo<br>`.A` (1 byte, CPU): Divisore |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+2` (3 byte, ZP): Quoziente a 24 bit<br>`DIV_REM+0` (1 byte, ZP): Resto a 8 bit<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+2`, `DIV_2+0`, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-sdiv_24x8"></a>
### SDIV_24X8

Divide un intero a 24 bit per uno a 8 bit, con segno. Il quoziente ha 24 bit e il resto 8 bit.

Rende positivi dividendo e divisore, esegue il nucleo senza segno e corregge i segni: il quoziente è negativo se i segni degli operandi sono diversi e il resto ha il segno del dividendo.

L'unico overflow possibile è -2^23 diviso -1: il quoziente esce troncato ai 24 bit bassi e il flag di oVerflow vale 1.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+2` (3 byte, ZP): Dividendo con segno<br>`.A` (1 byte, CPU): Divisore con segno |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+2` (3 byte, ZP): Quoziente a 24 bit con segno<br>`DIV_REM+0` (1 byte, ZP): Resto a 8 bit con segno<br>oVerflow (1 bit, .P): 0 = nessuno; 1 = overflow<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+2`, `DIV_2+0`, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-div_32x8"></a>
### DIV_32X8

Divide un intero a 32 bit per uno a 8 bit, senza segno. Il quoziente ha 32 bit e il resto 8 bit.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+3` (4 byte, ZP): Dividendo<br>`.A` (1 byte, CPU): Divisore |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+3` (4 byte, ZP): Quoziente a 32 bit<br>`DIV_REM+0` (1 byte, ZP): Resto a 8 bit<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+3`, `DIV_2+0`, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-sdiv_32x8"></a>
### SDIV_32X8

Divide un intero a 32 bit per uno a 8 bit, con segno. Il quoziente ha 32 bit e il resto 8 bit.

Rende positivi dividendo e divisore, esegue il nucleo senza segno e corregge i segni: il quoziente è negativo se i segni degli operandi sono diversi e il resto ha il segno del dividendo.

L'unico overflow possibile è -2^31 diviso -1: il quoziente esce troncato ai 32 bit bassi e il flag di oVerflow vale 1.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+3` (4 byte, ZP): Dividendo con segno<br>`.A` (1 byte, CPU): Divisore con segno |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+3` (4 byte, ZP): Quoziente a 32 bit con segno<br>`DIV_REM+0` (1 byte, ZP): Resto a 8 bit con segno<br>oVerflow (1 bit, .P): 0 = nessuno; 1 = overflow<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+3`, `DIV_2+0`, `DIV_REM+0` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-div_16x16"></a>
### DIV_16X16

Divide due interi a 16 bit, senza segno. Il quoziente ha 16 bit e il resto 16 bit.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+1` (2 byte, ZP): Dividendo<br>`.A` (1 byte, CPU): Divisore, byte 0<br>`.X` (1 byte, CPU): Divisore, byte 1 |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+1` (2 byte, ZP): Quoziente a 16 bit<br>`DIV_REM+0` .. `DIV_REM+1` (2 byte, ZP): Resto a 16 bit<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+1`, `DIV_2+0` .. `DIV_2+1`, `DIV_REM+0` .. `DIV_REM+1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-sdiv_16x16"></a>
### SDIV_16X16

Divide due interi a 16 bit, con segno. Il quoziente ha 16 bit e il resto 16 bit.

Rende positivi dividendo e divisore, esegue il nucleo senza segno e corregge i segni: il quoziente è negativo se i segni degli operandi sono diversi e il resto ha il segno del dividendo.

L'unico overflow possibile è -2^15 diviso -1: il quoziente esce troncato ai 16 bit bassi e il flag di oVerflow vale 1.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+1` (2 byte, ZP): Dividendo con segno<br>`.A` (1 byte, CPU): Divisore con segno, byte 0<br>`.X` (1 byte, CPU): Divisore con segno, byte 1 |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+1` (2 byte, ZP): Quoziente a 16 bit con segno<br>`DIV_REM+0` .. `DIV_REM+1` (2 byte, ZP): Resto a 16 bit con segno<br>oVerflow (1 bit, .P): 0 = nessuno; 1 = overflow<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+1`, `DIV_2+0` .. `DIV_2+1`, `DIV_REM+0` .. `DIV_REM+1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-div_24x16"></a>
### DIV_24X16

Divide un intero a 24 bit per uno a 16 bit, senza segno. Il quoziente ha 24 bit e il resto 16 bit.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+2` (3 byte, ZP): Dividendo<br>`.A` (1 byte, CPU): Divisore, byte 0<br>`.X` (1 byte, CPU): Divisore, byte 1 |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+2` (3 byte, ZP): Quoziente a 24 bit<br>`DIV_REM+0` .. `DIV_REM+1` (2 byte, ZP): Resto a 16 bit<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+2`, `DIV_2+0` .. `DIV_2+1`, `DIV_REM+0` .. `DIV_REM+1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-sdiv_24x16"></a>
### SDIV_24X16

Divide un intero a 24 bit per uno a 16 bit, con segno. Il quoziente ha 24 bit e il resto 16 bit.

Rende positivi dividendo e divisore, esegue il nucleo senza segno e corregge i segni: il quoziente è negativo se i segni degli operandi sono diversi e il resto ha il segno del dividendo.

L'unico overflow possibile è -2^23 diviso -1: il quoziente esce troncato ai 24 bit bassi e il flag di oVerflow vale 1.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+2` (3 byte, ZP): Dividendo con segno<br>`.A` (1 byte, CPU): Divisore con segno, byte 0<br>`.X` (1 byte, CPU): Divisore con segno, byte 1 |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+2` (3 byte, ZP): Quoziente a 24 bit con segno<br>`DIV_REM+0` .. `DIV_REM+1` (2 byte, ZP): Resto a 16 bit con segno<br>oVerflow (1 bit, .P): 0 = nessuno; 1 = overflow<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+2`, `DIV_2+0` .. `DIV_2+1`, `DIV_REM+0` .. `DIV_REM+1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-div_32x16"></a>
### DIV_32X16

Divide un intero a 32 bit per uno a 16 bit, senza segno. Il quoziente ha 32 bit e il resto 16 bit.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+3` (4 byte, ZP): Dividendo<br>`.A` (1 byte, CPU): Divisore, byte 0<br>`.X` (1 byte, CPU): Divisore, byte 1 |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+3` (4 byte, ZP): Quoziente a 32 bit<br>`DIV_REM+0` .. `DIV_REM+1` (2 byte, ZP): Resto a 16 bit<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+3`, `DIV_2+0` .. `DIV_2+1`, `DIV_REM+0` .. `DIV_REM+1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-sdiv_32x16"></a>
### SDIV_32X16

Divide un intero a 32 bit per uno a 16 bit, con segno. Il quoziente ha 32 bit e il resto 16 bit.

Rende positivi dividendo e divisore, esegue il nucleo senza segno e corregge i segni: il quoziente è negativo se i segni degli operandi sono diversi e il resto ha il segno del dividendo.

L'unico overflow possibile è -2^31 diviso -1: il quoziente esce troncato ai 32 bit bassi e il flag di oVerflow vale 1.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+3` (4 byte, ZP): Dividendo con segno<br>`.A` (1 byte, CPU): Divisore con segno, byte 0<br>`.X` (1 byte, CPU): Divisore con segno, byte 1 |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+3` (4 byte, ZP): Quoziente a 32 bit con segno<br>`DIV_REM+0` .. `DIV_REM+1` (2 byte, ZP): Resto a 16 bit con segno<br>oVerflow (1 bit, .P): 0 = nessuno; 1 = overflow<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+3`, `DIV_2+0` .. `DIV_2+1`, `DIV_REM+0` .. `DIV_REM+1` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-div_24x24"></a>
### DIV_24X24

Divide due interi a 24 bit, senza segno. Il quoziente ha 24 bit e il resto 24 bit.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+2` (3 byte, ZP): Dividendo<br>`.A` (1 byte, CPU): Divisore, byte 0<br>`.X` (1 byte, CPU): Divisore, byte 1<br>`.Y` (1 byte, CPU): Divisore, byte 2 |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+2` (3 byte, ZP): Quoziente a 24 bit<br>`DIV_REM+0` .. `DIV_REM+2` (3 byte, ZP): Resto a 24 bit<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+2`, `DIV_2+0` .. `DIV_2+2`, `DIV_REM+0` .. `DIV_REM+2` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-sdiv_24x24"></a>
### SDIV_24X24

Divide due interi a 24 bit, con segno. Il quoziente ha 24 bit e il resto 24 bit.

Rende positivi dividendo e divisore, esegue il nucleo senza segno e corregge i segni: il quoziente è negativo se i segni degli operandi sono diversi e il resto ha il segno del dividendo.

L'unico overflow possibile è -2^23 diviso -1: il quoziente esce troncato ai 24 bit bassi e il flag di oVerflow vale 1.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+2` (3 byte, ZP): Dividendo con segno<br>`.A` (1 byte, CPU): Divisore con segno, byte 0<br>`.X` (1 byte, CPU): Divisore con segno, byte 1<br>`.Y` (1 byte, CPU): Divisore con segno, byte 2 |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+2` (3 byte, ZP): Quoziente a 24 bit con segno<br>`DIV_REM+0` .. `DIV_REM+2` (3 byte, ZP): Resto a 24 bit con segno<br>oVerflow (1 bit, .P): 0 = nessuno; 1 = overflow<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+2`, `DIV_2+0` .. `DIV_2+2`, `DIV_REM+0` .. `DIV_REM+2` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-div_32x24"></a>
### DIV_32X24

Divide un intero a 32 bit per uno a 24 bit, senza segno. Il quoziente ha 32 bit e il resto 24 bit.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+3` (4 byte, ZP): Dividendo<br>`.A` (1 byte, CPU): Divisore, byte 0<br>`.X` (1 byte, CPU): Divisore, byte 1<br>`.Y` (1 byte, CPU): Divisore, byte 2 |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+3` (4 byte, ZP): Quoziente a 32 bit<br>`DIV_REM+0` .. `DIV_REM+2` (3 byte, ZP): Resto a 24 bit<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+3`, `DIV_2+0` .. `DIV_2+2`, `DIV_REM+0` .. `DIV_REM+2` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-sdiv_32x24"></a>
### SDIV_32X24

Divide un intero a 32 bit per uno a 24 bit, con segno. Il quoziente ha 32 bit e il resto 24 bit.

Rende positivi dividendo e divisore, esegue il nucleo senza segno e corregge i segni: il quoziente è negativo se i segni degli operandi sono diversi e il resto ha il segno del dividendo.

L'unico overflow possibile è -2^31 diviso -1: il quoziente esce troncato ai 32 bit bassi e il flag di oVerflow vale 1.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+3` (4 byte, ZP): Dividendo con segno<br>`.A` (1 byte, CPU): Divisore con segno, byte 0<br>`.X` (1 byte, CPU): Divisore con segno, byte 1<br>`.Y` (1 byte, CPU): Divisore con segno, byte 2 |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+3` (4 byte, ZP): Quoziente a 32 bit con segno<br>`DIV_REM+0` .. `DIV_REM+2` (3 byte, ZP): Resto a 24 bit con segno<br>oVerflow (1 bit, .P): 0 = nessuno; 1 = overflow<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+3`, `DIV_2+0` .. `DIV_2+2`, `DIV_REM+0` .. `DIV_REM+2` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-div_32x32"></a>
### DIV_32X32

Divide due interi a 32 bit, senza segno. Il quoziente ha 32 bit e il resto 32 bit.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+3` (4 byte, ZP): Dividendo<br>`DIV_2+0` .. `DIV_2+3` (4 byte, ZP): Divisore |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+3` (4 byte, ZP): Quoziente a 32 bit<br>`DIV_REM+0` .. `DIV_REM+3` (4 byte, ZP): Resto a 32 bit<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+3`, `DIV_REM+0` .. `DIV_REM+3` |

[↑ Torna al contenuto](#contenuto)

<a id="utilita-sdiv_32x32"></a>
### SDIV_32X32

Divide due interi a 32 bit, con segno. Il quoziente ha 32 bit e il resto 32 bit.

Rende positivi dividendo e divisore, esegue il nucleo senza segno e corregge i segni: il quoziente è negativo se i segni degli operandi sono diversi e il resto ha il segno del dividendo.

L'unico overflow possibile è -2^31 diviso -1: il quoziente esce troncato ai 32 bit bassi e il flag di oVerflow vale 1.

Se il divisore è zero esce con il Carry a 1 e `ERR_DIVISION_BY_ZERO` in `.A`, senza toccare quoziente e resto.

| Voce | Contenuto |
|---|---|
| Input | `DIV_1+0` .. `DIV_1+3` (4 byte, ZP): Dividendo con segno<br>`DIV_2+0` .. `DIV_2+3` (4 byte, ZP): Divisore con segno |
| Output | `.A` (1 byte, CPU): Byte 0 del quoziente, o `ERR_DIVISION_BY_ZERO` se C = 1<br>`.X` (1 byte, CPU): Byte 1 del quoziente<br>`.Y` (1 byte, CPU): Byte 2 del quoziente<br>`DIV_QUOT+0` .. `DIV_QUOT+3` (4 byte, ZP): Quoziente a 32 bit con segno<br>`DIV_REM+0` .. `DIV_REM+3` (4 byte, ZP): Resto a 32 bit con segno<br>oVerflow (1 bit, .P): 0 = nessuno; 1 = overflow<br>Carry (1 bit, .P): 0 = eseguita; 1 = divisore nullo |
| Registri Modificati | `.A`, `.X`, `.Y`, `.P` (Negative, oVerflow, Zero, Carry), `DIV_QUOT+0` .. `DIV_QUOT+3`, `DIV_2+0` .. `DIV_2+3`, `DIV_REM+0` .. `DIV_REM+3` |

[↑ Torna al contenuto](#contenuto)

### Note d'uso di `math_div.asm`

<a id="nota-math_div-01"></a>
#### Nota #01

Il dividendo ha m byte e il divisore n byte, con m maggiore o uguale a n. Il quoziente ha la lunghezza del dividendo e il resto quella del divisore, quindi nessuna informazione va persa. I valori a più byte si scambiano con i registri dal byte più basso al più alto: byte 0 in `.A`, byte 1 in `.X` e byte 2 in `.Y` (cioè la terna `.YXA`, come nell'ordine di memoria). I byte del quoziente oltre il terzo si leggono da `DIV_QUOT+3`.

Il resto si legge sempre da `DIV_REM`. Quando il resto ha un solo byte ed è rimasto un registro libero, la routine lo restituisce anche in quel registro.

```
  Routine  Dividendo   Divisore    Quoziente        Resto
  -------  ----------  ----------  ---------------  ------------
  8x8      .A          .X          .A               .X e DIV_REM
  16x8     DIV_1 (ZP)  .A          .A, .X           .Y e DIV_REM
  24x8     DIV_1 (ZP)  .A          .A, .X, .Y       DIV_REM
  32x8     DIV_1 (ZP)  .A          .A, .X, .Y (*)   DIV_REM
  16x16    DIV_1 (ZP)  .A, .X      .A, .X           DIV_REM
  24x16    DIV_1 (ZP)  .A, .X      .A, .X, .Y       DIV_REM
  32x16    DIV_1 (ZP)  .A, .X      .A, .X, .Y (*)   DIV_REM
  24x24    DIV_1 (ZP)  .A, .X, .Y  .A, .X, .Y       DIV_REM
  32x24    DIV_1 (ZP)  .A, .X, .Y  .A, .X, .Y (*)   DIV_REM
  32x32    DIV_1 (ZP)  DIV_2 (ZP)  .A, .X, .Y (*)   DIV_REM

  (*) Il byte 3 del quoziente si legge da DIV_QUOT+3.
```

Per le versioni con segno gli operandi sono in complemento a 2. Il resto ha il segno del dividendo e il quoziente si tronca verso zero, come nella divisione intera dei linguaggi di alto livello.

<a id="nota-math_div-02"></a>
#### Nota #02

Le routine lavorano in pagina zero sui 12 byte da `NUMWRK` a `NUMWRK+11`, cioè `NUMWRK` più i primi due byte di `FAC`, che sono liberi finché non si usa la matematica in virgola mobile del BASIC.

```
  DIV_1     NUMWRK+0 .. NUMWRK+3     Dividendo (primo operando)
  DIV_QUOT  NUMWRK+0 .. NUMWRK+3     Quoziente, coincide con DIV_1
  DIV_2     NUMWRK+4 .. NUMWRK+7     Divisore (secondo operando)
  DIV_REM   NUMWRK+8 .. NUMWRK+11    Resto
```

`DIV_QUOT` coincide con `DIV_1`: il dividendo viene consumato bit dopo bit e al suo posto entrano i bit del quoziente. Per questo il dividendo non si conserva. Nelle versioni con segno anche il divisore diventa positivo.

La stessa area è condivisa con `ZPL_1` e `ZPL_2` (puntatori utente a 24/32 bit) e con le routine di moltiplicazione: non si possono usare contemporaneamente.

<a id="nota-math_div-03"></a>
#### Nota #03

Si elabora un bit del dividendo alla volta, dal più alto. Il resto parziale scorre a sinistra e riceve il bit; se è maggiore o uguale al divisore si sottrae e il bit di quoziente vale 1, altrimenti vale 0 e il resto non si tocca: non esiste nessun ripristino. Il bit di quoziente è il Carry lasciato dal confronto ed entra dal basso nel dividendo alla rotazione successiva. Dividendo e quoziente condividono gli stessi byte e il quoziente non richiede nessun passo a parte.

Con un divisore di un byte il resto sta in `.A` per tutto il tempo. Con più byte sta in `DIV_REM` e il confronto parte dal byte più alto: si ferma appena l'esito è noto, cioè di solito dopo un solo byte.

I cicli medi con operandi casuali comprendono il caricamento dei registri e l'rts, ma non la jsr. Il divisore è casuale e non nullo, in parte più corto dell'operando.

```
  Routine  Senza segno  Con segno
  8x8            200       267
  16x8           451       528
  24x8           783       869
  32x8          1195      1289
  16x16          686       768
  24x16         1188      1279
  32x16         1775      1876
  24x24         1335      1431
  32x24         1991      2095
  32x32         2152      2244
```

<a id="nota-math_div-04"></a>
#### Nota #04

Divisione per zero: la routine esce con il Carry a 1 e `.A` uguale a `ERR_DIVISION_BY_ZERO`, senza toccare il quoziente e il resto.

Un dividendo nullo non ha un percorso a parte: il ciclo lo elabora come ogni altro valore e dà quoziente e resto uguali a zero.

Overflow nelle versioni con segno: l'unico caso è il dividendo più negativo diviso per -1, per esempio -128 / -1 a 8 bit. Il quoziente corretto (+128) non entra in 8 bit con il segno: la routine restituisce il quoziente troncato ai bit bassi (`$80`, che letto con il segno vale -128), pone il flag di oVerflow a 1 e lascia il Carry a 0. Il bit perso è il bit di segno del quoziente vero, che qui vale sempre 0: chi vuole il risultato esatto lo ricostruisce con un byte in più a zero. In tutti gli altri casi il flag di oVerflow vale 0.

[↑ Torna al contenuto](#contenuto)

<a id="limiti-noti"></a>
## Limiti noti

I sorgenti non hanno riquadri TO-DO. Le note d'uso dichiarano questi limiti:

- Le routine della ROM alterano variabili vitali del BASIC: dopo l'uso di `fp` il comando CONT non è più affidabile, e READ e INPUT ripartono da puntatori alterati ([Nota #06](#nota-fp-06)).
- I moduli `math` e `fp` usano le stesse celle di pagina zero: ogni chiamata va considerata autonoma ([Nota #04](#nota-fp-04)).
- Le routine della ROM non ritornano al chiamante quando segnalano un errore (ILLEGAL QUANTITY, OVERFLOW, DIVISION BY ZERO). `FP_ERROR_HANDLER` li gestisce solo in parte: in tutti e tre i casi pone a 1 il Carry e ritorna, e le gestioni più sofisticate non sono ancora scritte. L'installazione del vettore `IERROR` è compito del chiamante ([Nota #07](#nota-fp-07)).
- La moltiplicazione della ROM ha un bug noto che rende il risultato sbagliato di pochi bit per certe coppie di operandi; riguarda ogni macro che moltiplica, direttamente o attraverso la ROM ([Nota #08](#nota-fp-08)).
- L'accuratezza di `SQR`, `LOG`, `EXP`, `SIN`, `COS`, `TAN` e `ATN` è quella della ROM, descritta nelle note da [Nota #09](#nota-fp-09) a [Nota #16](#nota-fp-16).
- La costante `PI` della ROM non è il valore più vicino a pi greco ([Nota #17](#nota-fp-17)).
- l'area di pagina zero da `NUMWRK` a `NUMWRK+11` è condivisa da moltiplicazione, divisione, `ZPL_1` e `ZPL_2`: non si usano contemporaneamente ([Nota #02 di `math_mult.asm`](#nota-math_mult-02), [Nota #02 di `math_div.asm`](#nota-math_div-02));
- i primi due byte di `FAC` fanno parte di quell'area: sono liberi solo finché non si usa la matematica in virgola mobile del BASIC;
- nelle moltiplicazioni l'input non si conserva: il moltiplicatore viene consumato e, nelle versioni con segno, gli operandi diventano positivi ([Nota #01 di `math_mult.asm`](#nota-math_mult-01)); nelle divisioni il dividendo non si conserva e, con segno, anche il divisore diventa positivo ([Nota #02 di `math_div.asm`](#nota-math_div-02));
- divisione per zero: la routine esce con il Carry a 1 e `.A` uguale a `ERR_DIVISION_BY_ZERO`, senza toccare quoziente e resto; nelle versioni con segno il dividendo più negativo diviso per -1 dà il quoziente troncato e il flag oVerflow a 1 ([Nota #04 di `math_div.asm`](#nota-math_div-04)).

[↑ Torna al contenuto](#contenuto)

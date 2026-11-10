# math

Macro e subroutine di matematica intera su valori da 8 a 32 bit: negazione, operazioni booleane, somma, sottrazione, scorrimenti e rotazioni (`math8`, `math16`, `math24`, `math32`), moltiplicazione e divisione intere con e senza segno (`math_mult`, `math_div`). La libreria `math` fa parte della Libreria di Sistema (progetto `math.c64`) ed è scritta in assembly 6510 per C64Studio (sintassi ACME).

Questo documento deriva dai sorgenti. Per ogni dettaglio fanno fede i contratti d'interfaccia nelle intestazioni delle macro e delle subroutine.

<a id="contenuto"></a>
## Contenuto

| Modulo | Utilità | Descrizione |
|---|---|---|
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
!source <math/math16.asm>, once
!source <math/math_mult.asm>, once
```

Ogni modulo include da sé i file di cui ha bisogno (`<mem/mem16.asm>`, `<c64/symbols.asm>` e così via, vedi la tabella): il programma non deve includerli. Le macro si invocano con `+nome`, seguito dai parametri; il primo parametro delle macro che hanno più indirizzamenti è la stringa del modo (`"IMM"`, `"ABS"` o `"ZP"`). Gli operandi devono essere definiti prima dell'invocazione.

| Modulo | Include da sé | File da includere prima |
|---|---|---|
| `math8.asm` | `<c64/symbols.asm>` | Nessuno |
| `math16.asm` | `<mem/mem16.asm>` | Nessuno |
| `math24.asm` | `<mem/mem24.asm>` | Nessuno |
| `math32.asm` | `<mem/mem32.asm>` | Nessuno |
| `math_mult.asm` | `<c64/symbols.asm>` | Nessuno |
| `math_div.asm` | `<c64/errors.asm>`, `<c64/symbols.asm>` | Nessuno |

### Configurazione

Le macro si assemblano quando vengono invocate. Ogni subroutine viene assemblata solo se il suo parametro vale `1` nella copia di `config.asm` della Soluzione. Nel template tutti i parametri valgono `0`.

| Parametro | Subroutine | Richiede anche |
|---|---|---|
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

- l'area di pagina zero da `NUMWRK` a `NUMWRK+11` è condivisa da moltiplicazione, divisione, `ZPL_1` e `ZPL_2`: non si usano contemporaneamente ([Nota #02 di `math_mult.asm`](#nota-math_mult-02), [Nota #02 di `math_div.asm`](#nota-math_div-02));
- i primi due byte di `FAC` fanno parte di quell'area: sono liberi solo finché non si usa la matematica in virgola mobile del BASIC;
- nelle moltiplicazioni l'input non si conserva: il moltiplicatore viene consumato e, nelle versioni con segno, gli operandi diventano positivi ([Nota #01 di `math_mult.asm`](#nota-math_mult-01)); nelle divisioni il dividendo non si conserva e, con segno, anche il divisore diventa positivo ([Nota #02 di `math_div.asm`](#nota-math_div-02));
- divisione per zero: la routine esce con il Carry a 1 e `.A` uguale a `ERR_DIVISION_BY_ZERO`, senza toccare quoziente e resto; nelle versioni con segno il dividendo più negativo diviso per -1 dà il quoziente troncato e il flag oVerflow a 1 ([Nota #04 di `math_div.asm`](#nota-math_div-04)).

[↑ Torna al contenuto](#contenuto)

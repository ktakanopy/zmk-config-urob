# Mapa das 42 posições

Os números abaixo são os índices físicos usados pelo ZMK/keymap-drawer. A
numeração segue a ordem das linhas: três linhas de 12 teclas e, por fim, seis
thumbs.

## Posições físicas

```text
        ESQUERDA                                      DIREITA

00 TAB   01 Q   02 W   03 E   04 R   05 T    06 Y   07 U   08 I   09 O   10 P   11 BSPC
12 LALT  13 A   14 S   15 D   16 F   17 G    18 H   19 J   20 K   21 L   22 ;   23 '
24 LSHFT 25 Z   26 X   27 C   28 V   29 B    30 N   31 M   32 ,   33 .   34 /   35 LSHFT

                              36 ESC/LGUI   37 SPACE/NAV   38 TAB/ONE_HAND   39 RET/NAV   40 BSPC/NUM   41 LCTRL
```

## Camada `num`

```text
00 GRAVE   01 !      02 @      03 #      04 $      05 %       06 ^      07 &      08 *      09 (      10 )      11 __
12 __      13 1      14 2      15 3      16 4      17 5       18 6      19 7      20 8      21 9      22 0      23 __
24 __      25 LCTRL   26 LALT   27 LGUI   28 LSHFT  29 g_       30 RSHFT   31 RGUI   32 RALT   33 RCTRL  34 __     35 __

                              36 LGUI   37 SPACE   38 DOT       39 RET   40 BSPC   41 DEL
```

Assim, `g_` está na posição `29`, diretamente abaixo do `5` na posição `17`.

## Camada `nav`

```text
00 GRAVE   01 HOME    02 PG_UP   03 PG_DN   04 END    05 __        06 __      07 WH_U    08 WH_D    09 __      10 __      11 __
12 __      13 __      14 __      15 __      16 __     17 __        18 LEFT    19 DOWN    20 UP      21 RIGHT   22 __      23 __
24 __      25 LCTRL   26 LALT   27 LGUI   28 LSHFT  29 __        30 HOME    31 PG_UP   32 PG_DN   33 END    34 __     35 __

                              36 __      37 __      38 __          39 __    40 __      41 __
```

Segure `Enter` para ativar `nav`; ao tocar, ele continua enviando `Enter`.

## Camada `one_hand`

```text
00 CTRL+SPACE 01 HOME    02 PG_UP   03 PG_DN   04 END    05 DEL       06 __      07 __      08 __      09 __      10 __      11 __
12 LCTRL      13 RET     14 BSPC    15 DEL     16 TAB    17 ESC       18 __      19 __      20 __      21 __      22 __      23 __
24 LSHFT      25 LEFT    26 DOWN    27 UP      28 RIGHT  29 INS       30 __      31 __      32 __      33 __      34 __      35 __

                              36 LGUI   37 SPACE   38 LALT         39 RET   40 BSPC   41 DEL
```

O double-tap do thumb esquerdo ativa `one_hand`; a camada foi renomeada da antiga `nav2`.

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

                              36 ESC/LGUI   37 SPACE/NAV   38 DEL/NAV2       39 RET/FUN   40 BSPC/NUM   41 LSHFT
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
00 GUI+`   01 PREV WIN 02 NEXT WIN 03 LAST WIN 04 __ 05 NEW WIN   06 JOIN WIN 07 PASTE 08 CHOOSE WIN 09 __ 10 __ 11 __
12 LALT    13 LCTRL   14 LALT   15 LGUI   16 LSHFT 17 COPY MODE  18 LEFT    19 DOWN  20 UP         21 RIGHT 22 __ 23 __
24 LCTRL   25 ZOOM    26 SPLIT H 27 SPLIT V 28 BREAK 29 PREV PANE 30 HOME    31 PG_UP 32 PG_DN      33 END   34 __ 35 __

                              36 __      37 __      38 __          39 __    40 __      41 __
```

Segure `Space` para ativar `nav`; ao tocar, ela continua enviando `Space`.

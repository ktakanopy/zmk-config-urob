/*                              36 KEY MATRIX / LAYOUT MAPPING

  ╭────────────────────┬────────────────────╮ ╭─────────────────────┬─────────────────────╮
  │  0   1   2   3   4 │  5   6   7   8   9 │ │ LT4 LT3 LT2 LT1 LT0 │ RT0 RT1 RT2 RT3 RT4 │
  │ 10  11  12  13  14 │ 15  16  17  18  19 │ │ LM4 LM3 LM2 LM1 LM0 │ RM0 RM1 RM2 RM3 RM4 │
  │ 20  21  22  23  24 │ 25  26  27  28  29 │ │ LB4 LB3 LB2 LB1 LB0 │ RB0 RB1 RB2 RB3 RB4 │
  ╰───────╮ 30  31  32 │ 33  34  35 ╭───────╯ ╰───────╮ LH2 LH1 LH0 │ RH0 RH1 RH2 ╭───────╯
          ╰────────────┴────────────╯                 ╰─────────────┴─────────────╯             */

#pragma once

#define LT0  0  // left-top row (Q W E R T)
#define LT1  1
#define LT2  2
#define LT3  3
#define LT4  4

#define RT0  5  // right-top row (Y U I O P)
#define RT1  6
#define RT2  7
#define RT3  8
#define RT4  9

#define LM0 10  // left-middle row (A S D F G)
#define LM1 11
#define LM2 12
#define LM3 13
#define LM4 14

#define RM0 15  // right-middle row (H J K L ;)
#define RM1 16
#define RM2 17
#define RM3 18
#define RM4 19

#define LB0 20  // left-bottom row (Z X C V B)
#define LB1 21
#define LB2 22
#define LB3 23
#define LB4 24

#define RB0 25  // right-bottom row (N M , . /)
#define RB1 26
#define RB2 27
#define RB3 28
#define RB4 29

#define LH0 30  // left thumb keys
#define LH1 31
#define LH2 32

#define RH0 33  // right thumb keys
#define RH1 34
#define RH2 35
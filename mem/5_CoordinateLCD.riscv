AddressInit:
# base-address s0 = 0x7000
# 0x0000 is the starting point of Stack
li s0, 0x7000
addi s1, s0, 0x0000     # LEDR[16:0] address: s1 = 0x7000    
addi s2, s0, 0x0010     # LEDG[7:0] address: s2 = 0x7010
addi s3, s0, 0x0020     # _HEX3_HEX2_HEX1_HEX0 address: s3 = 0x7020
addi s4, s0, 0x0024     # _HEX7_HEX6_HEX5_HEX4 address: s4 = 0x7024
addi s5, s0, 0x0030     # LCD address: s5 = 0x7030
                        # LCD 
addi s6, s0, 0x0400     
addi s6, s6, 0x0400     # SW[16:0] address: s6 = 0x7800 (0 - 131071 decimal)
addi s7, s6, 0x0010     # KEY[3:0] address: s7 = 0x7810, RESET - START - STOP

addi s8, x0, 0x30          # A(x)
addi s9, x0, 0x30          # A(y)
addi s10, x0, 0x30         # B(x)
addi s11, x0, 0x30         # B(y)
addi a0, x0, 0x30          # C(x)
addi a1, x0, 0x30          # C(y)
addi a2, x0, 0x00          # 'A' or 'B'
addi a3, x0, 0x00          # State of BUTTON (KEY)
addi a4, x0, 0x02          # KEY[1] PUSHED

# a5 - a7

# t2 = 0x100 is the start-address of LUT(0-9)
Bin2SegLUT:
   addi t2, x0, 0x100
   addi t1, x0, 0x40
   sw t1, 0(t2)
   addi t2, x0, 0x104
   addi t1, x0, 0x79
   sw t1, 0(t2)
   addi t2, x0, 0x108
   addi t1, x0, 0x24
   sw t1, 0(t2)
   addi t2, x0, 0x10c
   addi t1, x0, 0x30
   sw t1, 0(t2)
   addi t2, x0, 0x110
   addi t1, x0, 0x19
   sw t1, 0(t2)
   addi t2, x0, 0x114
   addi t1, x0, 0x12
   sw t1, 0(t2)
   addi t2, x0, 0x118
   addi t1, x0, 0x02
   sw t1, 0(t2)
   addi t2, x0, 0x11c
   addi t1, x0, 0x78
   sw t1, 0(t2)
   addi t2, x0, 0x120
   addi t1, x0, 0x00
   sw t1, 0(t2)
   addi t2, x0, 0x124
   addi t1, x0, 0x10
   sw t1, 0(t2)

RESET_LCD:
   jal ra, DELAY10MS
   jal ra, DELAY10MS
   li t0, 0x30
   jal ra, CMDWRITE
   jal ra, DELAY10MS
   jal ra, DELAY10MS
   jal ra, DELAY10MS
   li t0, 0x30
   jal ra, CMDWRITE
   jal ra, DELAY10MS
   li t0, 0x30
   jal ra, CMDWRITE
   jal ra, DELAY10MS

INIT_LCD:
   li t0, 0x38
   jal ra, CMDWRITE
   li t0, 0x01
   jal ra, CMDWRITE
   li t0, 0x0C
   jal ra, CMDWRITE
   li t0, 0x06
   jal ra, CMDWRITE

MAIN:
   jal ra, GET_COOR_ABC       # A(s8,s9) B(s10,s11) C(a0,a1)
   jal ra, DO_MATH            # Nam Doan's MATHEMATIC >> a2 will be 'A' or 'B'
   jal ra, MAKE_DATA_LCD      # INIT 16x2 DATA
   jal ra, DISPLAY_LCD        # DISPLAY
   jal ra, MAIN               

#########################
#     NAM DOAN DINH     #
#########################

# Destructed reg: no register were harmed
# DELAY 1 centisecond = 10 milisecond
# 20ns + 40ns + x*60ns + 20ns + 20ns = 10ms => x = 166665
DELAY10MS:
   sw t0, 0x1C(x0)         # 20ns
   li t0, 2000000           # 40ns
DELAY10MS_LOOP:            # 60ns
   addi t0, t0, -1               # 20ns
   bne  t0, x0, DELAY10MS_LOOP   # 20ns

   lw t0, 0x1C(x0)               # 20ns
   jalr x0, ra, 0                # 20ns

DELAY500MS:
   sw t0, 0x1C(x0)         # 20ns
   li t0, 10000000           # 40ns
DELAY500MS_LOOP:            # 60ns
   addi t0, t0, -1               # 20ns
   bne  t0, x0, DELAY500MS_LOOP   # 20ns

   lw t0, 0x1C(x0)               # 20ns
   jalr x0, ra, 0                # 20ns

# Destructed reg: t0
# Input: t0 (8-bit CMD) 0x00000_0_data
# Output: t0 was write as CMD
CMDWRITE:
   sw t1, 0x00(x0)
   sw t2, 0x04(x0)
   sw t3, 0x08(x0)
   sw t4, 0x0C(x0)
   sw t5, 0x10(x0)
   sw t6, 0x14(x0)
   sw ra, 0x18(x0)

   li t1, 0x00000400     # EN
   li t2, 0x00000200     # RS
   li t3, 0x00000100     # RW
   li t4, 0xFFFFFBFF     # NOT_EN
   li t5, 0xFFFFFDFF     # NOT_RS
   li t6, 0xFFFFFEFF     # NOT_EN

   or t0, t0, t1           # EN = 1
   sw t0, 0(s5)
   jal ra, DELAY10MS
   and t0, t0, t4         # EN = 0
   sw t0, 0(s5)
   jal ra, DELAY10MS        

   lw ra, 0x18(x0)
   lw t6, 0x14(x0)
   lw t5, 0x10(x0)
   lw t4, 0x0C(x0)
   lw t3, 0x08(x0)
   lw t2, 0x04(x0)
   lw t1, 0x00(x0)
   
   jalr x0, ra, 0

DATAWRITE:
   sw t1, 0x00(x0)
   sw t2, 0x04(x0)
   sw t3, 0x08(x0)
   sw t4, 0x0C(x0)
   sw t5, 0x10(x0)
   sw t6, 0x14(x0)
   sw ra, 0x18(x0)
   
   li t1, 0x00000400     # EN
   li t2, 0x00000200     # RS
   li t3, 0x00000100     # RW
   li t4, 0xFFFFFBFF     # NOT_EN
   li t5, 0xFFFFFDFF     # NOT_RS
   li t6, 0xFFFFFEFF     # NOT_EN

   or t0, t0, t1
   or t0, t0, t2
   sw t0, 0(s5)
   jal ra, DELAY10MS
   and t0, t0, t4
   sw t0, 0(s5)
   jal ra, DELAY10MS   

   lw ra, 0x18(x0)
   lw t6, 0x14(x0)
   lw t5, 0x10(x0)
   lw t4, 0x0C(x0)
   lw t3, 0x08(x0)
   lw t2, 0x04(x0)
   lw t1, 0x00(x0)
   
   jalr x0, ra, 0


# Destructed registers: t0, s8, s9, s10, s11, a0, a1
# Input: t0
# Output: D5D4D3D2D1D0 = s8s9s10s11a0a1
GET_DIGIT_s8s9s10s11a0a1:
   sw ra, 0x4C(x0)

   lw t0, 0(s6)         # GET_SW
   sw t0, 0(s1)         # DISP_TO_LEDR

   jal ra, DIV100000    # NAM DOAN's MATHEMATIC
   addi s8, t1, 0x30    # t1 is quotient, add 0x30 to get ASCII
   slli t1, t1, 2       # *4 for LU
   lw t1, 0x100(t1)     # call LUT
   jal ra, STORE_HEX5   # store to seg

   jal ra, DIV10000
   addi s9, t1, 0x30
   slli t1, t1, 2
   lw t1, 0x100(t1)
   jal ra, STORE_HEX4

   jal ra, DIV1000
   addi s10, t1, 0x30
   slli t1, t1, 2
   lw t1, 0x100(t1)
   jal ra, STORE_HEX3

   jal ra, DIV100
   addi s11, t1, 0x30
   slli t1, t1, 2
   lw t1, 0x100(t1)
   jal ra, STORE_HEX2

   jal ra, DIV10
   addi a0, t1, 0x30
   slli t1, t1, 2
   lw t1, 0x100(t1)
   jal ra, STORE_HEX1

   jal ra, DIV1
   addi a1, t1, 0x30
   slli t1, t1, 2
   lw t1, 0x100(t1)
   jal ra, STORE_HEX0

   addi t1, x0, 0
   jal ra, STORE_HEX7
   addi t1, x0, 0
   jal ra, STORE_HEX6

   lw ra, 0x4C(ra)
   jalr x0, ra, 0

# Destructed register: t0
# Input: s8s9s10s11a0a1
# t2 = 0x200 is the start-address 16x2 datas for LCD
MAKE_DATA_LCD:
   li t0, 'A'  
   sw t0, 0x200(x0)
   li t0, 40 
   sw t0, 0x204(x0)
   addi t0, s8, 0x30 
   sw t0, 0x208(x0)
   li t0, ',' 
   sw t0, 0x20C(x0)
   addi t0, s9, 0x30 
   sw t0, 0x210(x0)
   li t0, ')' 
   sw t0, 0x214(x0)
   li t0, 'B' 
   sw t0, 0x218(x0)
   li t0, 40 
   sw t0, 0x21C(x0)
   addi t0, s10, 0x30 
   sw t0, 0x220(x0)
   li t0, ','
   sw t0, 0x224(x0)
   addi t0, s11, 0x30
   sw t0, 0x228(x0)
   li t0, ')'
   sw t0, 0x22C(x0)
   li t0, 'C'
   sw t0, 0x230(x0)
   li t0, 40
   sw t0, 0x234(x0)
   addi t0, a0, 0x30
   sw t0, 0x238(x0)
   li t0, ','
   sw t0, 0x23C(x0)
   
   addi t0, a1, 0x30 
   sw t0, 0x240(x0)
   li t0, ')' 
   sw t0, 0x244(x0)
   li t0, ' ' 
   sw t0, 0x248(x0)
   li t0, '>' 
   sw t0, 0x24C(x0)
   li t0, ' ' 
   sw t0, 0x250(x0)
   addi t0, a2, 0x30 
   sw t0, 0x254(x0)
   li t0, ' ' 
   sw t0, 0x258(x0)
   li t0, 'i' 
   sw t0, 0x25C(x0)
   li t0, 's' 
   sw t0, 0x260(x0)
   li t0, ' ' 
   sw t0, 0x264(x0)
   li t0, 'c' 
   sw t0, 0x268(x0)
   li t0, 'l' 
   sw t0, 0x26C(x0)
   li t0, 'o' 
   sw t0, 0x270(x0)
   li t0, 's' 
   sw t0, 0x274(x0)
   li t0, 'e' 
   sw t0, 0x278(x0)
   li t0, 'r' 
   sw t0, 0x27C(x0)  
   
   jalr x0, ra, 0 


DISPLAY_LCD:
   sw t0, 0x38(x0)
   sw ra, 0x3C(x0)

   li t0, 0x80          # Resset DDRAM pointer to Line 1
   jal ra, CMDWRITE

   lw t0, 0x200(x0)
   jal ra, DATAWRITE
   lw t0, 0x204(x0)
   jal ra, DATAWRITE
   lw t0, 0x208(x0)
   jal ra, DATAWRITE
   lw t0, 0x20C(x0)
   jal ra, DATAWRITE
   lw t0, 0x210(x0)
   jal ra, DATAWRITE
   lw t0, 0x214(x0)
   jal ra, DATAWRITE
   lw t0, 0x218(x0)
   jal ra, DATAWRITE
   lw t0, 0x21C(x0)
   jal ra, DATAWRITE
   lw t0, 0x220(x0)
   jal ra, DATAWRITE
   lw t0, 0x224(x0)
   jal ra, DATAWRITE
   lw t0, 0x228(x0)
   jal ra, DATAWRITE
   lw t0, 0x22C(x0)
   jal ra, DATAWRITE
   lw t0, 0x230(x0)
   jal ra, DATAWRITE
   lw t0, 0x234(x0)
   jal ra, DATAWRITE
   lw t0, 0x238(x0)
   jal ra, DATAWRITE
   lw t0, 0x23C(x0)
   jal ra, DATAWRITE

   li t0, 0xC0          # Resset DDRAM pointer to Line 2
   jal ra, CMDWRITE

   lw t0, 0x240(x0)
   jal ra, DATAWRITE
   lw t0, 0x244(x0)
   jal ra, DATAWRITE
   lw t0, 0x248(x0)
   jal ra, DATAWRITE
   lw t0, 0x24C(x0)
   jal ra, DATAWRITE
   lw t0, 0x250(x0)
   jal ra, DATAWRITE
   lw t0, 0x254(x0)
   jal ra, DATAWRITE
   lw t0, 0x258(x0)
   jal ra, DATAWRITE
   lw t0, 0x25C(x0)
   jal ra, DATAWRITE
   lw t0, 0x260(x0)
   jal ra, DATAWRITE
   lw t0, 0x264(x0)
   jal ra, DATAWRITE
   lw t0, 0x268(x0)
   jal ra, DATAWRITE
   lw t0, 0x26C(x0)
   jal ra, DATAWRITE
   lw t0, 0x270(x0)
   jal ra, DATAWRITE
   lw t0, 0x274(x0)
   jal ra, DATAWRITE
   lw t0, 0x278(x0)
   jal ra, DATAWRITE
   lw t0, 0x27C(x0)
   jal ra, DATAWRITE
   
   lw ra, 0x3C(x0)
   lw t0, 0x38(x0)

   jalr x0, ra, 0

# Destructed reg: t0, t1, t2
# Input: t0
# Output: t0 (remainder), t1 (quotient)
DIV100000:
   li t1, 0
   li t2, -100000
DIV100000_LOOP:
   addi t1, t1, 1
   add  t0, t0, t2
   bge  t0, x0, DIV100000_LOOP
   
   addi t1, t1, -1
   li t2, 100000
   add  t0, t0, t2
   jalr x0, ra, 0

DIV10000:
   li t1, 0
   li t2, -10000
DIV10000_LOOP:
   addi t1, t1, 1
   add  t0, t0, t2
   bge  t0, x0, DIV10000_LOOP
   
   addi t1, t1, -1
   li t2, 10000
   add  t0, t0, t2
   jalr x0, ra, 0

DIV1000:
   li t1, 0
   li t2, -1000
DIV1000_LOOP:
   addi t1, t1, 1
   add  t0, t0, t2
   bge  t0, x0, DIV1000_LOOP
   
   addi t1, t1, -1
   li t2, 1000
   add  t0, t0, t2
   jalr x0, ra, 0

DIV100:
   li t1, 0
   li t2, -100
DIV100_LOOP:
   addi t1, t1, 1
   add  t0, t0, t2
   bge  t0, x0, DIV100_LOOP
   
   addi t1, t1, -1
   li t2, 100
   add  t0, t0, t2
   jalr x0, ra, 0

DIV10:
   li t1, 0
   li t2, -10
DIV10_LOOP:
   addi t1, t1, 1
   add  t0, t0, t2
   bge  t0, x0, DIV10_LOOP
   
   addi t1, t1, -1
   li t2, 10
   add  t0, t0, t2
   jalr x0, ra, 0

DIV1:
   li t1, 0
   li t2, -1
DIV1_LOOP:
   addi t1, t1, 1
   add  t0, t0, t2
   bge  t0, x0, DIV1_LOOP
   
   addi t1, t1, -1
   li t2, 1
   add  t0, t0, t2
   jalr x0, ra, 0

# Destructed reg: t1, t2, t3
# Input: t1
# Output: HEX_ hold t1 seg
STORE_HEX0:
   lw t2, 0(s3)
   li t3, 0xFFFFFF00
   and t2, t2, t3
   or t1, t1, t2
   sw t1, 0(s3)
   jalr x0, ra, 0

STORE_HEX1:
   lw t2, 0(s3)
   li t3, 0xFFFF00FF
   and t2, t2, t3
   slli t1, t1, 8
   or t1, t1, t2
   sw t1, 0(s3)
   jalr x0, ra, 0

STORE_HEX2:
   lw t2, 0(s3)
   li t3, 0xFF00FFFF
   and t2, t2, t3
   slli t1, t1, 16
   or t1, t1, t2
   sw t1, 0(s3)
   jalr x0, ra, 0

STORE_HEX3:
   lw t2, 0(s3)
   li t3, 0x00FFFFFF
   and t2, t2, t3
   slli t1, t1, 24
   or t1, t1, t2
   sw t1, 0(s3)
   jalr x0, ra, 0

STORE_HEX4:
   lw t2, 0(s4)
   li t3, 0xFFFFFF00
   and t2, t2, t3
   or t1, t1, t2
   sw t1, 0(s4)
   jalr x0, ra, 0

STORE_HEX5:
   lw t2, 0(s4)
   li t3, 0xFFFF00FF
   and t2, t2, t3
   slli t1, t1, 8
   or t1, t1, t2
   sw t1, 0(s4)
   jalr x0, ra, 0

STORE_HEX6:
   lw t2, 0(s4)
   li t3, 0xFF00FFFF
   and t2, t2, t3
   slli t1, t1, 16
   or t1, t1, t2
   sw t1, 0(s4)
   jalr x0, ra, 0
   
STORE_HEX7:
   lw t2, 0(s4)
   li t3, 0x00FFFFFF
   and t2, t2, t3
   slli t1, t1, 24
   or t1, t1, t2
   sw t1, 0(s4)
   jalr x0, ra, 0

# Destructed registers: only t0
# NOTCE: s8s9s10s11a0a1 need to be preserved for MAKE_DATA_LCD
# Input: no need
# Output: A(s8,s9) B(s10,s11) C(a0,a1)
GET_COOR_ABC:
                  sw ra, 0x34(x0)

                  lw t0, 0(s6)            # GET_SW
                  sw t0, 0(s1)            # DISP_TO_LEDR
                  lw a3, 0(s7)            # GET_KEY
CHECK_PUSHED_s8:  bne a3, a4, NOT_PUSHED_s8
                  sw t0, 0(s8)
                  jal ra, NEXT_s8
NOT_PUSHED_s8:    jal ra, CHECK_PUSHED_s8
NEXT_s8:          jal ra, DELAY500MS

                  lw t0, 0(s6)            # GET_SW
                  sw t0, 0(s1)            # DISP_TO_LEDR
                  lw a3, 0(s7)            # GET_KEY
CHECK_PUSHED_s9:  bne a3, a4, NOT_PUSHED_s9
                  sw t0, 0(s9)
                  jal ra, NEXT_s9
NOT_PUSHED_s9:    jal ra, CHECK_PUSHED_s9
NEXT_s9:          jal ra, DELAY500MS               
               
                  lw t0, 0(s6)            # GET_SW
                  sw t0, 0(s1)            # DISP_TO_LEDR
                  lw a3, 0(s7)            # GET_KEY
CHECK_PUSHED_s10: bne a3, a4, NOT_PUSHED_s10
                  sw t0, 0(s10)
                  jal ra, NEXT_s10
NOT_PUSHED_s10:    jal ra, CHECK_PUSHED_s10
NEXT_s10:          jal ra, DELAY500MS                    
               
                  lw t0, 0(s6)            # GET_SW
                  sw t0, 0(s1)            # DISP_TO_LEDR
                  lw a3, 0(s7)            # GET_KEY
CHECK_PUSHED_s11: bne a3, a4, NOT_PUSHED_s11
                  sw t0, 0(s11)
                  jal ra, NEXT_s11
NOT_PUSHED_s11:    jal ra, CHECK_PUSHED_s11
NEXT_s11:          jal ra, DELAY500MS                 

                  lw t0, 0(s6)            # GET_SW
                  sw t0, 0(s1)            # DISP_TO_LEDR
                  lw a3, 0(s7)            # GET_KEY
CHECK_PUSHED_a0:  bne a3, a4, NOT_PUSHED_a0
                  sw t0, 0(a0)
                  jal ra, NEXT_a0
NOT_PUSHED_a0:    jal ra, CHECK_PUSHED_a0
NEXT_a0:          jal ra, DELAY500MS 

                  lw t0, 0(s6)            # GET_SW
                  sw t0, 0(s1)            # DISP_TO_LEDR
                  lw a3, 0(s7)            # GET_KEY
CHECK_PUSHED_a1: bne a3, a4, NOT_PUSHED_a1
                  sw t0, 0(a1)
                  jal ra, NEXT_a1
NOT_PUSHED_a1:    jal ra, CHECK_PUSHED_a1
NEXT_a1:          jal ra, DELAY500MS 

                  lw ra, 0x34(x0)
                  jalr x0, ra, 0

# Destructed registers: t0, a5 (gapCA^2), a6(gapCB^2)
# NOTCE: s8s9s10s11a0a1 need to be preserved for MAKE_DATA_LCD
# Input: A(s8,s9) B(s10,s11) C(a0,a1)
# Output: a2 = 'A' or 'B'
# CA^2 = (a0-s8)^2 + (a1-s9)^2 = a5
# 
# CB^2 = (a0-s10)^2 + (a1-s11)^2 = a6
DO_MATH:
            sw ra, 0x58(x0)
            
            sub t0, a0, s8

            jal ra, MUL
            addi a5, t0, 0
            sub t0, a1, s9
            jal ra, MUL
            add a5, a5, t0       # a5 now hold CA^2

            sub t0, a0, s10
            jal ra, MUL
            addi a6, t0, 0
            sub t0, a1, s11
            jal ra, MUL
            add a6, a6, t0       # a6 now hold CB^2

            bltu a5, a6, a5_closer
            li a2, 'B'
            jal ra, a6_next   
a5_closer:  li a2, 'A'
a6_next:    
            lw ra, 0x58(x0)
            jalr x0, ra, 0 

# Destructed registers: t0
# Input: t0
# Output: t0^2
MUL:
      sw t1, 0x60(x0)
      sw t2, 0x64(x0)
      
      addi t1, t0, 0    # counter
      addi t2, t0, 0    # step
      addi t0, x0, 0    # reset result
LOOP: add t0, t0, t2    
      addi t1, t1, -1   
      bne t1, x0, LOOP

      lw t2, 0x64(x0)
      lw t1, 0x60(x0)
      jalr x0, ra, 0

# Destructed registers: t0
# Input: t0
# Output: absolute value of t0
ABS_t0:
         bge t0, x0, NO_ABS
         xori t0, t0 , -1
         addi t0, t0, 1
NO_ABS:  
         jalr x0, ra, 0
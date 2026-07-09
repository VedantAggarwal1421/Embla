lui x31, 0x11223
addi x31, x31, 0x344
addi t0, x0, 0x100
sw x31, 0(t0)

lw  s0, 0(t0)      # 0x11223344

lb  s1, 0(t0)      # 0x44
lb  s2, 1(t0)      # 0x33
lb  s3, 2(t0)      # 0x22
lb  s4, 3(t0)      # 0x11

lbu s5, 0(t0)      # 0x44
lbu s6, 1(t0)      # 0x33
lbu s7, 2(t0)      # 0x22
lbu s8, 3(t0)      # 0x11

lh  s9, 0(t0)      # 0x3344
lh  s10,2(t0)      # 0x1122

lhu s11,0(t0)      # 0x3344
lhu t1, 2(t0)      # 0x1122

############################################################
# Store Byte
############################################################

li t2, 0xAA
sb t2, 1(t0)

# Expected word:
# bytes = 44 AA 22 11
# word  = 0x1122AA44

lw t3, 0(t0)       # 0x1122AA44
lbu t4, 1(t0)      # 0xAA
lb  t5, 1(t0)      # 0xFFFFFFAA

############################################################
# Store Halfword
############################################################

li t2, 0xCCDD
sh t2, 2(t0)

# bytes = 44 AA DD CC
# word  = 0xCCDDAA44

lw  t6, 0(t0)      # 0xCCDDAA44
lhu a0, 2(t0)      # 0xCCDD
lh  a1, 2(t0)      # 0xFFFFCCDD

############################################################
# Store Word
############################################################

li t2, 0x89ABCDEF
sw t2, 0(t0)

lw  a2, 0(t0)      # 0x89ABCDEF

lb  a3, 0(t0)      # 0xFFFFFFEF
lb  a4, 1(t0)      # 0xFFFFFFCD
lb  a5, 2(t0)      # 0xFFFFFFAB
lb  a6, 3(t0)      # 0xFFFFFF89

lbu a7, 0(t0)      # 0xEF

lh  t3, 0(t0)      # 0xFFFFCDEF
lh  t4, 2(t0)      # 0xFFFF89AB

lhu t5, 0(t0)      # 0x0000CDEF
lhu t6, 2(t0)      # 0x000089AB

done:
    j done
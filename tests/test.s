# Memory:
# 0x00 : DEAD0000
# 0x04 : F0F0F0F0

addi x20, x0, 13
add  x21, x0, x20
addi x22, x20, 16

# -----------------------------
# Load-use hazard
# -----------------------------
lw      x1, 0(x0)          # x1 = DEAD0000
addi    x2, x1, 15          # hazard -> DEAD000F

lw      x3, 4(x0)          # x3 = F0F0F0F0
addi    x4, x3, 15         # hazard -> F0F0F0FF

# -----------------------------
# EX forwarding chain
# -----------------------------
add     x5, x2, x4         # CF9DF10E
addi    x6, x2, -15        # DEAD0000
xor     x7, x6, x4         # 2E5DF0FF
and     x8, x7, x1         # 0E0D0000
or      x9, x8, x3         # FEFDF0F0

# -----------------------------
# Shift forwarding
# -----------------------------
addi    x10, x0, 4
sll     x11, x9, x10       # EFDF0F00
srl     x12, x11, x10      # 0EFDF0F0


# -----------------------------
# Store / Load test
# -----------------------------
sw      x12, 8(x0)         # Nothing is written
lw      x13, 8(x0)         # Load x12 = 0EFDF0F0  
addi    x14, x13, 1        # Load Use hazard
addi     x15, x8, 1

.text
.globl _start

_start:

# -----------------------------------------
# Setup
# -----------------------------------------

addi x1, x0, 5          # x1 = 5
addi x2, x0, 5          # x2 = 5
addi x3, x0, 10         # x3 = 10
addi x4, x0, -1         # x4 = 0xffffffff
addi x5, x0, 0          # pass counter

# -----------------------------------------
# BEQ (taken)
# -----------------------------------------

beq x1, x2, beq_pass
addi x5, x5, 100        # should NOT execute

beq_pass:
addi x5, x5, 1

# -----------------------------------------
# BEQ (not taken)
# -----------------------------------------

beq x1, x3, beq_fail
addi x5, x5, 1

beq_fail:

# -----------------------------------------
# BNE (taken)
# -----------------------------------------

bne x1, x3, bne_pass
addi x5, x5, 100

bne_pass:
addi x5, x5, 1

# -----------------------------------------
# BNE (not taken)
# -----------------------------------------

bne x1, x2, bne_fail
addi x5, x5, 1

bne_fail:

# -----------------------------------------
# BLT signed
# -----------------------------------------

blt x1, x3, blt_pass
addi x5, x5, 100

blt_pass:
addi x5, x5, 1

# -----------------------------------------
# BGE signed
# -----------------------------------------

bge x3, x1, bge_pass
addi x5, x5, 100

bge_pass:
addi x5, x5, 1

# -----------------------------------------
# Signed comparison with negative number
# (-1 < 5)
# -----------------------------------------

blt x4, x1, neg_pass
addi x5, x5, 100

neg_pass:
addi x5, x5, 1

# -----------------------------------------
# Unsigned comparison
# 0xffffffff > 5
# so BLTU should NOT take
# -----------------------------------------

bltu x4, x1, bltu_fail
addi x5, x5, 1

bltu_fail:

# -----------------------------------------
# BGEU should take
# -----------------------------------------

bgeu x4, x1, bgeu_pass
addi x5, x5, 100

bgeu_pass:
addi x5, x5, 1

# -----------------------------------------
# Branch after R-type result
# -----------------------------------------

sub x6, x3, x1          # 10-5 = 5

beq x6, x2, alu_pass
addi x5, x5, 100

alu_pass:
addi x5, x5, 1

# -----------------------------------------
# Branch after I-type result
# -----------------------------------------

addi x7, x6, -5         # =0

beq x7, x0, zero_pass
addi x5, x5, 100

zero_pass:
addi x5, x5, 1

# -----------------------------------------
# Backward branch loop
# -----------------------------------------

addi x8, x0, 4

loop:
addi x8, x8, -1
bne x8, x0, loop

addi x5, x5, 1

# -----------------------------------------
# Final result
# x5 should equal 12
# -----------------------------------------

done:
beq x0, x0, done

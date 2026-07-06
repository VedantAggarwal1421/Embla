lw x15, 4(x0) # This exists so my memory isnt optimized away.

############################################################
# Test 1 : Forward A from EX/MEM
############################################################

addi x1, x0, 5
add  x2, x1, x1      # x2 = 10
add  x3, x2, x1      # x3 = 15
# ForwardA = EX/MEM


############################################################
# Test 2 : Forward A from MEM/WB
############################################################

addi x1, x0, 5
add  x2, x1, x1
addi x5, x0, 0       # independent instruction
add  x3, x2, x1
# ForwardA = MEM/WB


############################################################
# Test 3 : Forward B from EX/MEM
############################################################

addi x1, x0, 5
add  x2, x1, x1
add  x3, x1, x2
# ForwardB = EX/MEM


############################################################
# Test 4 : Forward B from MEM/WB
############################################################

addi x1, x0, 5
add  x2, x1, x1
addi x5, x0, 0
add  x3, x1, x2
# ForwardB = MEM/WB


############################################################
# Test 5 : Both operands forwarded from EX/MEM
############################################################

addi x1, x0, 3

add  x2, x1, x1      # 6
add  x3, x1, x1      # 6
add  x4, x2, x3      # both forwarded

# x4 = 12


############################################################
# Test 6 : A = EX/MEM, B = MEM/WB
############################################################

addi x1, x0, 2

add  x2, x1, x1      # x2 = 4
addi x5, x0, 0
add  x3, x1, x1      # x3 = 4
add  x4, x3, x2

# ForwardA = EX/MEM
# ForwardB = MEM/WB


############################################################
# Test 7 : A = MEM/WB, B = EX/MEM
############################################################

addi x1, x0, 2

add  x2, x1, x1
addi x5, x0, 0
add  x3, x1, x1
add  x4, x2, x3

# ForwardA = MEM/WB
# ForwardB = EX/MEM


############################################################
# Test 8 : Destination register reused immediately
############################################################

addi x1, x0, 5
add  x1, x1, x1      # x1 = 10
add  x2, x1, x1      # x2 = 20

# Catches rd==rs==rt forwarding bugs


############################################################
# Test 9 : Consecutive writes to same register
############################################################

addi x1, x0, 1
addi x1, x1, 1
addi x1, x1, 1
add  x2, x1, x0

# x2 MUST be 3
# EX/MEM forwarding must have priority over MEM/WB


############################################################
# Test 10 : x0 should never forward
############################################################

add  x0, x1, x2
add  x3, x0, x1

# x3 should equal x1
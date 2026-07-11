#DIV2

#100/5 = 20
addi x1, x0, 100
addi x2, x0, 5
div x3, x1, x2
addi x4, x0, 20
bne x3, x4, fail

# rem = 0
rem x3, x1, x2
addi x4, x0, 0
bne x3, x4, fail

#5/100 = 0
addi x1, x0, 5
addi x2, x0, 100
div x3, x1, x2
addi x4, x0, 0
bne x3, x4, fail

# rem = 5
rem x3, x1, x2
addi x4, x0, 5
bne x3, x4, fail

#0/100 = 0
addi x1, x0, 0
addi x2, x0, 100
div x3, x1, x2
addi x4, x0, 0
bne x3, x4, fail

# rem = 0
rem x3, x1, x2
addi x4, x0, 0
bne x3, x4, fail

#100/0 = -1 (Signed DIV/0 Convention)
addi x1, x0, 100
addi x2, x0, 0
div x3, x1, x2
addi x4, x0, -1
bne x3, x4, fail

# rem = 100
rem x3, x1, x2
addi x4, x0, 100
bne x3, x4, fail

addi x16, x0, 100
addi x17, x0, 200
fail:
addi x31, x0, -1
addi x30, x0, -1
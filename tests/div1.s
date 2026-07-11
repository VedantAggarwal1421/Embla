#DIV
#10/3 = 3
addi x1, x0, 10
addi x2, x0, 3
div x3, x1, x2
addi x4, x0, 3
bne x3, x4, fail

# rem = 1
rem x3, x1, x2
addi x4, x0, 1
bne x3, x4, fail

# -10/3 = -3
addi x1, x0, -10
addi x2, x0, 3
div x3, x1, x2
addi x4, x0, -3
bne x4, x3, fail

#rem = -1
rem x3, x1, x2
addi x4, x0, -1
bne x4, x3, fail

# 10/-3 = -3
addi x1, x0, 10
addi x2, x0, -3
div x3, x1, x2
addi x4, x0, -3
bne x4, x3, fail

#rem = 1
rem x3, x1, x2
addi x4, x0, 1
bne x4, x3, fail

# -10/-3 = 3
addi x1, x0, -10
addi x2, x0, -3
div x3, x1, x2
addi x4, x0, 3
bne x4, x3, fail

#rem = -1
rem x3, x1, x2
addi x4, x0, -1
bne x4, x3, fail

addi x16, x0, 100
addi x17, x0, 200
fail:
addi x31, x0, -1
addi x30, x0, -1
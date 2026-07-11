#DIV3

#Signed Overflow
li x1, 0x80000000
addi x2, x0, -1
div x3, x1, x2
li x4, 0x80000000
bne x3, x4, fail

# rem = 0
rem x3, x1, x2
addi x4, x0, 0
bne x3, x4, fail

#DIVU
addi x1, x0, -1
addi x2, x0, 2
divu x3, x1, x2
li x4, 0x7FFFFFFF
bne x3, x4, fail

remu x3, x1, x2
addi x4, x0, 1
bne x3, x4, fail

#DIVU/0
li x1, 0xdeadbeef
addi x2, x0, 0
divu x3, x1, x2
addi x4, x0, -1
bne x3, x4, fail

remu x3, x1, x2
li x4, 0xdeadbeef
bne x3, x4, fail

#Large Unsigned
li x1, 0x80000000
addi x2, x0, 2
divu x3, x1, x2
li x4, 0x40000000
bne x3, x4, fail

remu x3, x1, x2
addi x4, x0, 0
bne x4, x2, fail



addi x16, x0, 100
addi x17, x0, 200
fail:
addi x31, x0, -1
addi x30, x0, -1
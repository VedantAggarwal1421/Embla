addi x1, x0, 5
addi x2, x0, 5
beq x1, x2, target
addi x3, x0, 0xFF

target:
    lui x4, 0xf2f4f
    addi x4, x4, 0x6f8
    sw x4, 0(x0)
    lw x5, 0(x0)
    lb x6, 0(x0)
    lb x7, 1(x0)
    lb x8, 2(x0)
    lb x9, 3(x0)
    lbu x10, 0(x0)
    lbu x11, 1(x0)
    lbu x12, 2(x0)
    lbu x13, 3(x0)
    lh x14, 0(x0)
    lh x15, 3(x0)
    lhu x16, 0(x0)
    lhu x17, 3(x0)
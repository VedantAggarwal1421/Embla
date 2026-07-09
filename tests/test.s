    .text
    .globl _start

_start:

############################################################
# LUI TEST
############################################################

    lui     x1, 0x12345
    lui     x2, 0x12345
    bne     x1, x2, fail

    lui     x3, 0x54321
    lui     x4, 0x54321
    bne     x3, x4, fail

############################################################
# AUIPC TEST
############################################################
# Two AUIPC instructions separated by one instruction.
# Difference should be 8 bytes.

    auipc   x5, 0
    addi    x6, x0, 0          # register write

    auipc   x7, 0
    addi    x8, x5, 8
    bne     x7, x8, fail

############################################################
# JAL TEST
############################################################
# x9 should receive the address of jal_return.

    jal     x9, jal_target

jal_return:
    addi    x10, x0, 1

############################################################
# Prepare for JALR
############################################################
# Obtain PC without using label arithmetic.

    jal     x11, get_pc

############################################################
# JAL TARGET
############################################################

jal_target:

    addi    x12, x0, 7

    auipc   x13, 0
    addi    x13, x13, 8        # Address of the instruction after jal

    bne     x9, x13, fail

    addi    x14, x0, 9         # register write before jump

    jalr    x0, 0(x9)

############################################################
# GET PC FOR JALR
############################################################

get_pc:

    # x11 contains address of the next instruction.
    # jalr_target is 20 bytes ahead:
    #
    # addi
    # addi
    # jalr
    # fail addi
    # fail beq
    #
    # = 5 instructions = 20 bytes

    addi    x15, x11, 20

    addi    x16, x0, 5         # register write

    jalr    x17, 0(x15)

    addi    x31, x0, 0xFF      # should never execute
    beq     x0, x0, fail

############################################################
# JALR TARGET
############################################################

jalr_target:

    addi    x18, x0, 11

    # x17 should contain the address after the jalr.
    # That address is exactly 4 bytes before the fail ADDI.

    auipc   x19, 0
    addi    x19, x19, -8

    bne     x17, x19, fail

    addi    x20, x0, 22

############################################################
# PASS
############################################################

pass:
    addi    x30, x0, 1

pass_loop:
    beq     x0, x0, pass_loop

############################################################
# FAIL
############################################################

fail:
    addi    x31, x0, 0xFF

fail_loop:
    beq     x0, x0, fail_loop
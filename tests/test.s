    .section .text
    .globl _start

    .org 0x000

_start:
    li      x1, 1
    li      x31, 0x00000000

illegal_here:
    addi    x2, x2, 0xFF          # <-- Manually corrupting this instruction.

after_trap:
    csrr    t1, mepc
    sw      t0, 0(x31)
    csrr    t0, mcause
    sw      t0, 0(x31)
    csrr    t0, mtval
    sw      t0, 0(x31)
    csrr    t0, mstatus
    sw      t0, 0(x31)

done:
    j done


    # ================================================================
    # Trap handler (mtvec = 0x100)
    # ================================================================

    .org 0x100

trap_handler:
    csrr    t0, mepc
    sw      t0, 0(x31)
    csrr    t0, mcause
    sw      t0, 0(x31)
    csrr    t0, mtval
    sw      t0, 0(x31)
    csrr    t0, mstatus
    sw      t0, 0(x31)

    # Skip the offending instruction

    csrr    t0, mepc
    addi    t0, t0, 4
    csrw    mepc, t0

    mret
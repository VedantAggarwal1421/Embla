    .section .text
    .globl _start

    .org 0x000

_start:
    li      x1, 1

illegal_here:
    addi    x2, x2, 0xFF          # <-- Manually corrupting this instruction.

after_trap:
    csrr    t1, mepc
    csrr    t0, mcause
    csrr    t0, mtval
    csrr    t0, mstatus

done:
    j done


    # ================================================================
    # Trap handler (mtvec = 0x100)
    # ================================================================

    .org 0x100

trap_handler:
    csrr    t0, mepc
    csrr    t0, mcause
    csrr    t0, mtval
    csrr    t0, mstatus

    # Skip the offending instruction

    csrr    t0, mepc
    addi    t0, t0, 4
    csrw    mepc, t0

    mret
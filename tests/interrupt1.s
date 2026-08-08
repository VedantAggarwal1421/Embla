    .section .text
    .globl _start

    .org 0x000

_start:

    # ---------------------------------------------------------------
    # Enable machine timer interrupt
    # ---------------------------------------------------------------

    li      t0, 0x80          # MTIE = bit 7 in mie
    csrs    mie, t0

    # Enable global machine interrupts
    li      t0, 0x8           # MIE = bit 3 in mstatus
    csrs    mstatus, t0


    # ---------------------------------------------------------------
    # Normal program
    #
    # Assert MTIP from the testbench somewhere while these execute.
    # ---------------------------------------------------------------

before_interrupt:

    addi    x1, x1, 1
    addi    x1, x1, 1
    addi    x1, x1, 1
    addi    x1, x1, 1

interrupt_point:

    addi    x2, x2, 10        # <-- interrupt should happen around here

    addi    x2, x2, 20
    addi    x2, x2, 30
    addi    x2, x2, 40

after_interrupt:

    # ---------------------------------------------------------------
    # If interrupt handling is correct, execution eventually reaches
    # here after mret.
    # ---------------------------------------------------------------

    li      x3, 0x12345678

done:
    j       done


    # ===============================================================
    # Machine interrupt handler
    #
    # mtvec = 0x100
    # ===============================================================

    .org 0x100

trap_handler:

    # Just do some harmless work.
    # We deliberately DON'T modify mepc.

    addi    t0, t0, 1
    addi    t1, t1, 2
    addi    t2, t2, 3
    addi    t3, t3, 4

    # Return to interrupted program

    mret
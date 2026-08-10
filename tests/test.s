    .section .text
    .globl _start

    .org 0x000

_start:

    # ===============================================================
    # Enable Machine Timer Interrupt
    # ===============================================================

    li      t0, 0x80              # MTIE
    csrs    mie, t0

    li      t0, 0x8               # MIE
    csrs    mstatus, t0


    # ===============================================================
    # Basic arithmetic
    # ===============================================================

    li      x1, 10
    li      x2, 20

    add     x3, x1, x2            # x3 = 30
    sub     x4, x2, x1            # x4 = 10

    addi    x5, x3, 5             # x5 = 35
    addi    x6, x4, -3            # x6 = 7


    # ===============================================================
    # Forwarding / dependency chain
    # ===============================================================

    add     x7, x5, x6            # x7 = 42
    addi    x7, x7, 1             # x7 = 43
    addi    x7, x7, 1             # x7 = 44


    # ===============================================================
    # Branch taken
    # ===============================================================

    li      x8, 1
    li      x9, 1

    beq     x8, x9, branch_taken

    # Should NOT execute
    li      x10, 0xdead


branch_taken:

    li      x10, 100
    addi    x10, x10, 23          # x10 = 123


    # ===============================================================
    # Branch NOT taken
    # ===============================================================

    li      x11, 5
    li      x12, 10

    beq     x11, x12, branch_not_taken

    # This SHOULD execute
    addi    x13, x0, 55


branch_not_taken:

    # ===============================================================
    # Another branch with arithmetic around it
    # ===============================================================

    li      x14, 3
    li      x15, 3

    bne     x14, x15, should_not_branch

    addi    x16, x0, 77           # Should execute

should_not_branch:


    # ===============================================================
    # Known interrupt boundary
    #
    # ASSERT MTIP HERE FROM THE TESTBENCH.
    #
    # At this point all instructions above should have committed.
    # ===============================================================

interrupt_boundary:

    addi    x17, x0, 111
    addi    x18, x0, 222
    addi    x19, x0, 333

    add     x20, x17, x18         # 333
    add     x20, x20, x19         # 666


    # ===============================================================
    # More control flow after the interrupt
    #
    # This proves that execution didn't merely return to the
    # right general area, but continued normally.
    # ===============================================================

    li      x21, 0

    beq     x20, x20, post_int_branch

    # Should NOT execute
    li      x21, 0xdead


post_int_branch:

    addi    x21, x21, 10
    addi    x21, x21, 20
    addi    x21, x21, 30           # x21 = 60


    # ===============================================================
    # Final marker
    # ===============================================================

    li      x22, 0x12345678

done:
    j       done



    # ===============================================================
    # MACHINE INTERRUPT HANDLER
    #
    # mtvec = 0x100
    # ===============================================================

    .org 0x100

trap_handler:

    # ---------------------------------------------------------------
    # Deliberately use registers that already contain values.
    # This is okay for this test because we don't care about
    # preserving them yet.
    # ---------------------------------------------------------------

    addi    t0, t0, 1
    addi    t1, t1, 2
    addi    t2, t2, 3
    addi    t3, t3, 4

    # Some arithmetic
    add     t4, t0, t1
    sub     t5, t4, t2

    # DO NOT modify mepc.
    # We want to test that mret returns to the address saved
    # automatically during interrupt entry.

    mret
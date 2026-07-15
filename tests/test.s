.section .text
.globl _start

#===========================================================
# Illegal Instruction Trap Test
#===========================================================

_start:

    # Normal instructions
    li      t0, 0x12345678
    li      t1, 0xCAFEBABE
    add     t2, t0, t1

    #--------------------------------------------------------
    # Illegal instruction
    #--------------------------------------------------------
    .word   0x00000000

    # Should never execute
    li      t3, 0xDEADBEEF

end:
    j end


#===========================================================
# Trap Handler (mtvec = 0x100)
#===========================================================

.org 0x100

trap_handler:

    # Save relevant CSRs into registers for inspection
    csrr    s0, mepc
    csrr    s1, mcause
    csrr    s2, mtval
    csrr    s3, mstatus
    csrr    s4, mtvec

trap_loop:
    j trap_loop
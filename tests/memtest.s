    .section .text
    .globl _start

.equ UART,       0x10000000
.equ RAM_END,    0x00800000       # 8 MiB, exclusive

_start:
    li      s0, 0                  # Current RAM address
    li      s1, RAM_END
    li      s2, UART

test_loop:
    sw      s0, 0(s2)
    # --------------------------------------------------------
    # Write address as test pattern
    # --------------------------------------------------------
    sw      s0, 0(s0)

    # --------------------------------------------------------
    # Read it back
    # --------------------------------------------------------
    lw      t0, 0(s0)

    # --------------------------------------------------------
    # Compare
    # --------------------------------------------------------
    bne     t0, s0, test_failed

    # --------------------------------------------------------
    # Print successfully tested address
    # UART accepts a full 32-bit word
    # --------------------------------------------------------
    sw      s0, 0(s2)

    # Next word
    addi    s0, s0, 4

    # Continue until 0x00800000
    bltu    s0, s1, test_loop


    # --------------------------------------------------------
    # Entire RAM passed
    # Print 0xFFFFFFFF as completion marker
    # --------------------------------------------------------
    li      t0, -1
    sw      t0, 0(s2)


done:
    j       done


# ------------------------------------------------------------
# Failure
#
# s0 = address that failed
#
# Print the failing address, then stop.
# ------------------------------------------------------------
test_failed:
    sw      s0, 0(s2)

failure_loop:
    j       failure_loop
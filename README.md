# Embla

*A handwritten RISC-V SoC, built from scratch, in pursuit of booting Linux on FPGA.*

---

> 🚧 **Status: Early development.** This README describes the planned architecture and will evolve as the project progresses.

## About

Embla is a from-scratch RISC-V System-on-Chip targeting FPGA, built as a deep dive into CPU microarchitecture, memory systems, and SoC design. The end goal is a self-contained core and ecosystem capable of booting Linux.

## Planned Features

- **RV32IMA Core** — Classic 5-stage pipelined RISC-V core implementing the RV32I base ISA with (M,A) extensions and privileged architecture supporting U/S/M modes.
- **MMU** — Sv32 virtual memory with a 2-tier page table, TLBs, and a hardware page table walker.
- **AXI4 Interconnect** — Memory bus connecting the core to RAM, UART, and other memory-mapped peripherals.
- **Cache Subsystem** — Separate data and instruction caches.
- **SDRAM Controller** — Custom controller for the FPGA's dedicated SDRAM block.
- **UART** — Console and debugging interface.
- *More peripherals to be added as time allows.*

## Roadmap

- [ ] Core (fetch → decode → execute → memory → writeback)
- - [x] RV32I Pipelined Cpu
- - [ ] M/A Extensions
- [ ] UART
- - [x] Debug transmitter
- - [ ] UART 16550
- [ ] Privileged architecture (U/S/M modes, trap handling)
- [ ] MMU (Sv32, TLB, page table walker)
- [ ] Caches (I-cache, D-cache)
- [ ] AXI4 interconnect
- [ ] SDRAM controller
- [ ] Boot Linux
---

*Progress, notes, and write-ups will be added here as development continues.*
- Working on setting up formal verification for the cpu.
- Developing the MMU.

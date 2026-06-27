//Top level module for the RV32IMA Core. Interfaces with memory systems.

module core (
    input         clk,
    input         rst,
    //Instruction Memory
    output [31:0] im_addr,   //Instruction memory address
    input  [31:0] im_data,   // Instruction memory data
    //Data Memory
    output [31:0] dm_addr,   // Data memory address
    output [31:0] dm_wdata,  // Data memory write data
    output        dm_we,     // Data memory write enable
    output [ 1:0] dm_size,   // Data memory size (00=byte, 01=halfword, 10=word)
    input  [31:0] dm_rdata   // Data memory read data
);


endmodule

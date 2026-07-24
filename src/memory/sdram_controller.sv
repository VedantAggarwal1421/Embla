module sdram_controller(
    input        clk,
    input        clk_sdram,
    input        rst,

    //SDRAM INTERFACE
    output logic O_sdram_clk,             // Sdram Clock
    output logic O_sdram_cke,             // Clock Enable
    output logic O_sdram_cs_n,            // Chip select
    output logic O_sdram_cas_n,           // Column address select
    output logic O_sdram_ras_n,           // Row address select
    output logic O_sdram_wen_n,           // Write enable
    inout  logic [31:0] IO_sdram_dq,      // Input output data from sdram
    output logic [10:0] O_sdram_addr,     // 11 Bit address (2K Rows)
    output logic [1:0] O_sdram_ba,        // Bank
    output logic [3:0] O_sdram_dqm,       // Write Mask

    //DATA MEMORY INTERFACE
    input  logic [31:0] addr,         // Data memory address
    input  logic        req_valid,    // Requesting Data
    input  logic [31:0] wdata,        // Data memory write data
    input  logic        we,           // Data memory write enable
    input  logic [ 3:0] byte_mask,    // Data Memory byte mask
    output logic        wdata_ready,  // Data Stored Succesfully
    output logic [31:0] rdata,        // Data memory read data
    output logic        rdata_ready   // Data is ready to be read   
    
);

    //Signals that actually go the sdram
    logic read_sdram;
    logic write_sdram;
    logic [22:0] address_sdram; //23 Bits for 8MB or 64 Mbits byte addresses memory , 8*2^20 = 2^23 Bytes.
    logic [31:0] write_data_sdram;
    logic [31:0] read_data_sdram;



endmodule
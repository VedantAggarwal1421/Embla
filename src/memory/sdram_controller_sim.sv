//Simulation only file. Simulates sdram as bram.

module sdram_controller #(
    parameter FREQ = 27_000_000
) (
    input clk,
    input clk_sdram,
    input rst,

    //SDRAM INTERFACE
    output logic        O_sdram_clk,    // Sdram Clock
    output logic        O_sdram_cke,    // Clock Enable
    output logic        O_sdram_cs_n,   // Chip select
    output logic        O_sdram_cas_n,  // Column address select
    output logic        O_sdram_ras_n,  // Row address select
    output logic        O_sdram_wen_n,  // Write enable
    inout  logic [31:0] IO_sdram_dq,    // Input output data from sdram
    output logic [10:0] O_sdram_addr,   // 11 Bit address (2K Rows)
    output logic [ 1:0] O_sdram_ba,     // Bank
    output logic [ 3:0] O_sdram_dqm,    // Write Mask

    //DATA MEMORY INTERFACE
    input  logic [31:0] addr,         // Data memory address
    input  logic        req_valid,    // Requesting Data
    input  logic [31:0] wdata,        // Data memory write data
    input  logic        we,           // Data memory write enable
    input  logic [ 3:0] byte_mask,    // Data Memory byte mask
    output logic        wdata_ready,  // Data Stored Succesfully
    output logic [31:0] rdata,        // Data memory read data
    output logic        rdata_ready,  // Data is ready to be read   
    output logic [ 3:0] debug_led

);
    (* ram_style = "block" *)
    logic [31:0] data_mem[0:1023];


    always_ff @(posedge clk) begin
        if (rst) begin
            wdata_ready <= 0;
            rdata_ready <= 0;
            rdata <= 0;
        end else begin
            wdata_ready <= 0;
            rdata_ready <= 0;

            if (we) begin
                if (byte_mask[0]) data_mem[addr[11:2]][7:0] <= wdata[7:0];
                if (byte_mask[1]) data_mem[addr[11:2]][15:8] <= wdata[15:8];
                if (byte_mask[2]) data_mem[addr[11:2]][23:16] <= wdata[23:16];
                if (byte_mask[3]) data_mem[addr[11:2]][31:24] <= wdata[31:24];
                wdata_ready <= 1;
            end

            if (req_valid) begin
                rdata <= data_mem[addr[11:2]];
                rdata_ready <= 1;
            end
        end
    end
endmodule

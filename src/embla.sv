// Top module for the Embla SoC. This module instantiates the core and other subsystems.
`timescale 1ns / 1ns
module embla (
    input  wire clk,      // System clock
    input  wire rst,      // Active high reset
    output wire uart_tx,  // UART transmit
    input  wire uart_rx   // UART receive
);

    logic [31:0] if_addr;
    logic        if_req_valid;
    logic [31:0] if_data;
    logic        if_data_valid;

    logic [31:0] dm_addr;
    logic [31:0] dm_wdata;
    logic        dm_we;
    logic [ 1:0] dm_size;
    logic [31:0] dm_rdata;

    core core_inst (
        .clk(clk),
        .rst(rst),

        //Instruction Memory Interface
        .if_addr(if_addr),
        .if_req_valid(if_req_valid),
        .if_data(if_data),
        .if_data_valid(if_data_valid),

        //Data Memory Interface
        .dm_addr(dm_addr),
        .dm_wdata(dm_wdata),
        .dm_we(dm_we),
        .dm_size(dm_size),
        .dm_rdata(dm_rdata)
    );

    imem imem_inst (
        .clk(clk),
        .rst(rst),
        .addr(if_addr),
        .req_valid(if_req_valid),
        .data(if_data),
        .data_valid(if_data_valid)
    );
endmodule

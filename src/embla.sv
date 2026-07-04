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
    logic        if_stall;

    logic [31:0] mem_addr;
    logic        mem_req_valid;
    logic [31:0] mem_wdata;
    logic        mem_we;
    logic [ 1:0] mem_size;
    logic        mem_wdata_ready;
    logic [31:0] mem_rdata;
    logic        mem_rdata_ready;

    logic        routed_mem_enable;
    logic        routed_uart_enable;

    core core_inst (
        .clk(clk),
        .rst(rst),

        //Instruction Memory Interface
        .if_addr(if_addr),
        .if_req_valid(if_req_valid),
        .if_data(if_data),
        .if_data_valid(if_data_valid),
        .if_stall(if_stall),

        //Data Memory Interface
        .mem_addr(mem_addr),
        .mem_req_valid(mem_req_valid),
        .mem_wdata(mem_wdata),
        .mem_we(mem_we),
        .mem_size(mem_size),
        .mem_wdata_ready(mem_wdata_ready),
        .mem_rdata(mem_rdata),
        .mem_rdata_ready(mem_rdata_ready)
    );

    //Routing the data.
    //0x10000000 -> UART
    //Everything else -> Data mem
    always_comb begin
        if (mem_addr[31] == 1'b1) begin
            routed_uart_enable = 1'b0;
            routed_mem_enable  = mem_we;
        end else begin
            routed_uart_enable = mem_we;
            routed_mem_enable  = 1'b0;
        end
    end

    //Memories
    imem imem_inst (
        .clk(clk),
        .rst(rst),
        .addr(if_addr),
        .req_valid(if_req_valid),
        .data(if_data),
        .data_valid(if_data_valid),
        .stall(if_stall)
    );

    dmem dmem_inst (
        .clk(clk),
        .rst(rst),
        .addr(mem_addr),
        .req_valid(mem_req_valid),
        .wdata(mem_wdata),
        .we(routed_mem_enable),
        .size(mem_size),
        .wdata_ready(mem_wdata_ready),
        .rdata(mem_rdata),
        .rdata_ready(mem_rdata_ready)
    );

    //UART MODULE
    uart_driver uart_inst (
        .clk(clk),
        .rst(rst),
        .tx_word(mem_wdata),
        .tx_data_valid(routed_uart_enable),
        .tx_pin(uart_tx)
    );
endmodule

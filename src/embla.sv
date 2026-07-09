// Top module for the Embla SoC. This module instantiates the core and other subsystems.
`timescale 1ns / 1ns
module embla (
    input  wire clk,      // System clock
    input  wire rst,      // Active high reset
    input  wire s2,       // Button 2 of fpga. Debugging purposes.  
    output wire uart_tx,  // UART transmit
    output wire led,      // Represents the slowed down clock. Debugging purposes
    output wire led2,     // Preserves Debug output
    input  wire uart_rx   // UART receive
);

    // ****************** Debugging Infrastructure - Start **********************
    localparam test = 32'hdeadbeef;
    localparam second = $clog2(27_000_000) - 1;
    reg [second:0] debug_count;
    reg clk_second;
    logic sync0, sync1;
    logic rise;
    assign rise = sync0 & ~sync1;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_second  <= 'd0;
            debug_count <= 'd0;
        end else begin
            debug_count <= debug_count + 1;
            if (~|debug_count) clk_second <= ~clk_second;
        end
    end

    always_ff @(posedge clk) begin
        sync0 <= clk_second;
        sync1 <= sync0;
    end

    logic [31:0] debug_out;
    assign led  = clk_second;
    assign led2 = |debug_out;

    // ************** Debugging Infrastrucure - End *********************

    logic [31:0] if_addr;
    logic        if_req_valid;
    logic [31:0] if_data;
    logic        if_data_valid;
    logic        if_stall;

    logic [31:0] debug_uart;
    logic        uart_en;

    logic [31:0] mem_addr;
    logic        mem_req_valid;
    logic [31:0] mem_wdata;
    logic        mem_we;
    logic [ 1:0] mem_size;
    logic        mem_wdata_ready;
    logic [31:0] mem_rdata;
    logic        mem_rdata_ready;

    core core_inst (
        .clk(clk_second),
        .rst(rst),

        //Instruction Memory Interface
        .if_addr(if_addr),
        .if_req_valid(if_req_valid),
        .if_data(if_data),
        .if_data_valid(if_data_valid),
        .if_stall(if_stall),
        .debug_s2(s2),
        .debug_out(debug_out),
        .debug_uart(debug_uart),

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

    //Memories
    imem imem_inst (
        .clk(clk_second),
        .rst(rst),
        .addr(if_addr),
        .req_valid(if_req_valid),
        .data(if_data),
        .data_valid(if_data_valid),
        .write_enable(s2),
        .write_data(32'b0),
        .stall(if_stall)
    );

    dmem dmem_inst (
        .clk(clk_second),
        .rst(rst),
        .addr(mem_addr),
        .req_valid(mem_req_valid),
        .wdata(mem_wdata),
        .we(mem_we),
        .size(mem_size),
        .wdata_ready(mem_wdata_ready),
        .rdata(mem_rdata),
        .rdata_ready(mem_rdata_ready)
    );

    //UART MODULE

    uart_driver uart_inst (
        .clk(clk),
        .rst(rst),
        .tx_word(debug_uart),
        .tx_data_valid(rise),
        .tx_pin(uart_tx)
    );
endmodule

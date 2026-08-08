// Top module for the Embla SoC. This module instantiates the core and other subsystems.
`timescale 1ns / 1ns
module embla (
    input  logic       sys_clk,         // System clock
    input  logic       sys_rst,         // Active high reset - Hard reset for the entire soc
    input  logic       s2,              // Button 2 of fpga. Debugging purposes.  
    output logic       uart_tx,         // UART transmit
    output logic       led,             // Represents the slowed down clock. Debugging purposes
    output logic       led2,            // Preserves Debug output
    output logic [3:0] debug_led,
    input  logic       interrupt_test,
    input  logic       uart_rx,         // UART receive

    //Interface to sdram
    output logic        O_sdram_clk,    // Sdram Clock
    output logic        O_sdram_cke,    // Clock Enable
    output logic        O_sdram_cs_n,   // Chip select
    output logic        O_sdram_cas_n,  // Column address select
    output logic        O_sdram_ras_n,  // Row address select
    output logic        O_sdram_wen_n,  // Write enable
    inout  logic [31:0] IO_sdram_dq,    // Input output data from sdram
    output logic [10:0] O_sdram_addr,   // 11 Bit address (2K Rows)
    output logic [ 1:0] O_sdram_ba,     // Bank
    output logic [ 3:0] O_sdram_dqm     // Write Mask
);

    logic clk;
    logic clk_sdram;
    logic pll_locked;
    logic rst;

    pll pll_inst (
        .clkin    (sys_clk),    //Input System Clock 27 Mhz
        .reset    (sys_rst),    //Reset Pll
        .clk      (clk),        //Output Clock , set to 27 Mhz for now.
        .clk_sdram(clk_sdram),  //180 deg Phase shifted clock for sdram.
        .locked   (pll_locked)  //Pll stable
    );

    assign rst = sys_rst || (~pll_locked);  //Assert Reset until pll is stable

    // assign clk = sys_clk;
    // assign rst = sys_rst;

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

    logic [31:0] lsu_addr;
    logic        lsu_req_valid;
    logic [31:0] lsu_wdata;
    logic        lsu_we;
    logic [ 1:0] lsu_size;
    logic        lsu_wdata_ready;
    logic [31:0] lsu_rdata;
    logic        lsu_rdata_ready;

    logic [31:0] dmem_addr;
    logic        dmem_req_valid;
    logic [31:0] dmem_wdata;
    logic        dmem_we;
    logic [ 3:0] dmem_byte_mask;
    logic        dmem_wdata_ready;
    logic [31:0] dmem_rdata;
    logic        dmem_rdata_ready;

    logic [31:0] uart_out_data;
    logic        uart_busy;
    logic        uart_en;

    logic        msip_irq;
    logic        mtip_irq;
    logic        meip_irq;
    assign mtip_irq = interrupt_test;

    core core_inst (
        .clk(clk),
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

        //Load Store Unit Interface
        .lsu_addr(lsu_addr),
        .lsu_req_valid(lsu_req_valid),
        .lsu_wdata(lsu_wdata),
        .lsu_we(lsu_we),
        .lsu_size(lsu_size),
        .lsu_wdata_ready(lsu_wdata_ready),
        .lsu_rdata(lsu_rdata),
        .lsu_rdata_ready(lsu_rdata_ready),

        .msip_irq(msip_irq),
        .mtip_irq(mtip_irq),
        .meip_irq(meip_irq)
    );

    //Memories
    imem imem_inst (
        .clk(clk),
        .rst(rst),
        .addr(if_addr),
        .req_valid(if_req_valid),
        .data(if_data),
        .data_valid(if_data_valid),
        .write_enable(s2),
        .write_data(32'b0),
        .stall(if_stall)
    );

    load_store_unit lsu (
        .clk(clk),
        .rst(rst),

        .lsu_addr(lsu_addr),
        .lsu_req_valid(lsu_req_valid),
        .lsu_wdata(lsu_wdata),
        .lsu_we(lsu_we),
        .lsu_size(lsu_size),
        .lsu_wdata_ready(lsu_wdata_ready),
        .lsu_rdata(lsu_rdata),
        .lsu_rdata_ready(lsu_rdata_ready),

        .dmem_addr(dmem_addr),
        .dmem_req_valid(dmem_req_valid),
        .dmem_wdata(dmem_wdata),
        .dmem_we(dmem_we),
        .dmem_byte_mask(dmem_byte_mask),
        .dmem_wdata_ready(dmem_wdata_ready),
        .dmem_rdata(dmem_rdata),
        .dmem_rdata_ready(dmem_rdata_ready),

        .uart_busy(uart_busy),
        .uart_out_data(uart_out_data),
        .uart_en(uart_en)
    );

    // dmem dmem_inst (
    //     .clk(clk),
    //     .rst(rst),
    //     .addr(dmem_addr),
    //     .req_valid(dmem_req_valid),
    //     .wdata(dmem_wdata),
    //     .we(dmem_we),
    //     .byte_mask(dmem_byte_mask),
    //     .wdata_ready(dmem_wdata_ready),
    //     .rdata(dmem_rdata),
    //     .rdata_ready(dmem_rdata_ready)
    // );

    sdram_controller sdcnt_inst (
        .clk(clk),
        .clk_sdram(clk_sdram),
        .rst(rst),

        .O_sdram_clk(O_sdram_clk),    // Sdram Clock
        .O_sdram_cke(O_sdram_cke),    // Clock Enable
        .O_sdram_cs_n(O_sdram_cs_n),   // Chip select
        .O_sdram_cas_n(O_sdram_cas_n),  // Column address select
        .O_sdram_ras_n(O_sdram_ras_n),  // Row address select
        .O_sdram_wen_n(O_sdram_wen_n),  // Write enable
        .IO_sdram_dq(IO_sdram_dq),    // Input output data from sdram
        .O_sdram_addr(O_sdram_addr),   // 11 Bit address (2K Rows)
        .O_sdram_ba(O_sdram_ba),     // Bank
        .O_sdram_dqm(O_sdram_dqm),    // Write Mask

        .addr(dmem_addr),
        .req_valid(dmem_req_valid),
        .wdata(dmem_wdata),
        .we(dmem_we),
        .byte_mask(dmem_byte_mask),
        .wdata_ready(dmem_wdata_ready),
        .rdata(dmem_rdata),
        .rdata_ready(dmem_rdata_ready),
        .debug_led(debug_led)
    );



    //UART MODULE

    // uart_driver uart_inst (
    //     .clk(clk),
    //     .rst(rst),
    //     .tx_word(debug_uart),
    //     .tx_data_valid(rise),
    //     .tx_pin(uart_tx)
    // );

    uart_driver uart_inst (
        .clk(clk),
        .rst(rst),
        .tx_word(uart_out_data),
        .tx_data_valid(uart_en),
        .uart_busy(uart_busy),
        .tx_pin(uart_tx)
    );


endmodule

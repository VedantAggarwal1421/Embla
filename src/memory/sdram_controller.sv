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
    output logic        rdata_ready   // Data is ready to be read   

);

    //Signals that actually go the sdram
    logic read_sdram;
    logic write_sdram;
    logic [22:0] address_sdram; //23 Bits for 8MB or 64 Mbits byte addresses memory , 8*2^20 = 2^23 Bytes.
    logic [31:0] write_data_sdram;
    logic write_ready_sdram;
    logic [31:0] read_data_sdram;
    logic read_ready_sdram;

    assign address_sdram    = addr[22:0];
    assign write_data_sdram = wdata;
    assign wdata_ready      = write_ready_sdram;
    assign rdata            = read_data_sdram;
    assign rdata_ready      = read_ready_sdram;


    logic busy;

    //Refresh signals
    localparam REFRESH_CYCLES = FREQ / 1_000_000 * 15;
    logic refresh;
    logic refresh_needed;
    logic [15:0] refresh_cycle_cnt;

    always_ff @(posedge clk) begin
        if (!refresh) begin
            refresh_cycle_cnt <= refresh_cycle_cnt + 16'd1;
            if (refresh_cycle_cnt == REFRESH_CYCLES - 1) refresh_needed <= 1;
            else refresh_needed <= 0;
        end else begin
            refresh_cycle_cnt <= refresh_cycle_cnt - REFRESH_CYCLES;
            refresh_needed <= 0;
        end
    end

    typedef enum logic [1:0] {
        SDRAM_IDLE,
        SDRAM_WRITE,
        SDRAM_READ,
        SDRAM_REFRESH
    } state_t;

    state_t state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= SDRAM_IDLE;
        end else begin
            case (state)
                SDRAM_IDLE: begin
                    if (busy) begin  //SDRAM is configuring
                        state <= SDRAM_IDLE;
                    end else if (req_valid) begin
                        read_sdram <= 1;
                        state <= SDRAM_READ;
                    end else if (we) begin
                        write_sdram <= 1;
                        state <= SDRAM_WRITE;
                    end else if (refresh_needed) begin
                        refresh <= 1;
                        state   <= SDRAM_REFRESH;
                    end
                end

                SDRAM_READ: begin
                    read_sdram <= 0;
                    if (read_ready_sdram) begin  //Read Complete
                        state <= SDRAM_IDLE;
                    end
                end

                SDRAM_WRITE: begin
                    write_sdram <= 0;
                    if (write_ready_sdram) begin  //Write Complete
                        state <= SDRAM_IDLE;
                    end
                end

                SDRAM_REFRESH: begin
                    refresh <= 0;
                    if (!(busy)) begin  //Refresh Complete
                        state <= SDRAM_IDLE;
                    end
                end
            endcase
        end
    end

    sdram #(
        .FREQ(FREQ)
    ) sdram_inst (
        .clk(clk),
        .clk_sdram(clk_sdram),
        .rst(rst),

        .O_sdram_clk(O_sdram_clk),
        .O_sdram_cke(O_sdram_cke),
        .O_sdram_cs_n(O_sdram_cs_n),
        .O_sdram_cas_n(O_sdram_cas_n),
        .O_sdram_ras_n(O_sdram_ras_n),
        .O_sdram_wen_n(O_sdram_wen_n),
        .IO_sdram_dq(IO_sdram_dq),
        .O_sdram_addr(O_sdram_addr),
        .O_sdram_ba(O_sdram_ba),
        .O_sdram_dqm(O_sdram_dqm),

        .address_sdram(address_sdram),
        .read_sdram(read_sdram),
        .write_sdram(write_sdram),
        .refresh(refresh),
        .write_data_sdram(write_data_sdram),
        .byte_mask_sdram(byte_mask),
        .read_data_sdram(read_data_sdram),
        .write_ready_sdram(write_ready_sdram),
        .read_ready_sdram(read_ready_sdram),
        .busy(busy)
    );


endmodule

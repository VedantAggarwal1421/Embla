//verilog_format: off
module sdram #(
    parameter FREQ = 27_000_000
) (
    input logic clk,
    input logic clk_sdram,
    input logic rst,
    output logic [3:0] debug_led,

    //sdram interface
    output logic        O_sdram_clk,    // Sdram Clock
    output logic        O_sdram_cke,    // Clock Enable
    output logic        O_sdram_cs_n,   // Chip select
    output logic        O_sdram_cas_n,  // Column address select
    output logic        O_sdram_ras_n,  // Row address select
    output logic        O_sdram_wen_n,  // Write enable
    inout  logic [31:0] IO_sdram_dq,    // Input output data from sdram
    output logic [10:0] O_sdram_addr,   // 11 Bit address (2048 Rows)
    output logic [ 1:0] O_sdram_ba,     // Bank
    output logic [ 3:0] O_sdram_dqm,    // Write Mask

    //Controller Interface
    input  logic [22:0] address_sdram,
    input  logic        read_sdram,
    input  logic        write_sdram,
    input  logic        refresh,
    input  logic [31:0] write_data_sdram,
    input  logic [ 3:0] byte_mask_sdram, 
    output logic [31:0] read_data_sdram,
    output logic        write_ready_sdram,
    output logic        read_ready_sdram,
    output logic        busy
);
    localparam DATA_WIDTH = 32;
    localparam ROW_WIDTH = 11;
    localparam COL_WIDTH = 8;
    localparam BANK_WIDTH = 2;

    localparam CAS = 4'd2;  // 2 cycles, set in mode register
    localparam T_WR = 4'd2;  // 2 cycles, write recovery
    localparam T_MRD = 4'd2;  // 2 cycles, mode register set
    localparam T_RP = 4'd1;  // 15ns, precharge to active
    localparam T_RCD = 4'd1;  // 15ns, active to r/w
    localparam T_RC = 4'd2;  // 60ns, ref/active to ref/active

    logic dq_out_en;  //Output enable
    logic [DATA_WIDTH-1:0] dq_out;
    assign IO_sdram_dq     = dq_out_en ? 32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz_zzzz : dq_out;
    assign read_data_sdram = IO_sdram_dq;

    assign O_sdram_clk     = clk_sdram;  //Phase shifted sdram clock
    assign O_sdram_cke     = 1'b1;  //Clock always enabled
    assign O_sdram_cs_n    = 1'b0;  //Chip select

    //SDRAM COMMANDS
    localparam CMD_SetModeReg   = 3'b000;
    localparam CMD_AutoRefresh  = 3'b001;
    localparam CMD_PreCharge    = 3'b010;
    localparam CMD_BankActivate = 3'b011;
    localparam CMD_Write        = 3'b100;
    localparam CMD_Read         = 3'b101;
    localparam CMD_NOP          = 3'b111;

    localparam BURST_LEN        = 3'b0;
    localparam BURST_MODE       = 1'b0;
    localparam MODE_REG         = {4'b0, CAS[2:0], BURST_MODE, BURST_LEN};

    logic configure;
    logic [3:0] cycle_cnt;
    logic [31:0] wr_data_buff;
    logic [22:0] addr_buff;

    logic reached_idle;
    assign debug_led[2] = ~reached_idle;

    typedef enum logic [2:0] {
        SD_INIT,
        SD_CONFIGURE,
        SD_IDLE,
        SD_READ,
        SD_WRITE,
        SD_REFRESH
    } state_t;

    state_t state;
    //Main SDRAM state machine
    always @(posedge clk) begin
        cycle_cnt <= (cycle_cnt == 4'd15)? 4'd15 : cycle_cnt + 4'd1;

        {O_sdram_ras_n, O_sdram_cas_n, O_sdram_wen_n} <= CMD_NOP;

        casex ({state, cycle_cnt})

            {SD_INIT, 4'bxxxx}: begin
                if(configure) begin
                    state <= SD_CONFIGURE;
                    cycle_cnt <= 0;
                end
            end

            {SD_CONFIGURE, 4'd0}: begin
                {O_sdram_ras_n, O_sdram_cas_n, O_sdram_wen_n} <= CMD_PreCharge;
                O_sdram_addr[10] <= 1'b1;
            end

            {SD_CONFIGURE, T_RP}: begin
                {O_sdram_ras_n, O_sdram_cas_n, O_sdram_wen_n} <= CMD_AutoRefresh;
            end

            {SD_CONFIGURE, T_RP+T_RC}: begin
                {O_sdram_ras_n, O_sdram_cas_n, O_sdram_wen_n} <= CMD_AutoRefresh;
            end

            {SD_CONFIGURE, T_RP+T_RC+T_RC}: begin
                {O_sdram_ras_n, O_sdram_cas_n, O_sdram_wen_n} <= CMD_SetModeReg;
                O_sdram_addr[10:0] <= MODE_REG;
            end

            {SD_CONFIGURE, T_RP+T_RC+T_RC+T_MRD}: begin
                state <= SD_IDLE;
                busy <= 1'b0;
            end

            {SD_IDLE, 4'bxxxx}: begin
                read_ready_sdram <= 1'b0;
                write_ready_sdram <= 1'b0;
                reached_idle      <= 1'b1;

                if(read_sdram | write_sdram) begin
                    {O_sdram_ras_n, O_sdram_cas_n, O_sdram_wen_n} <= CMD_BankActivate;

                    O_sdram_ba <= address_sdram[ROW_WIDTH+COL_WIDTH+BANK_WIDTH-1+2 : ROW_WIDTH+COL_WIDTH+2];
                    O_sdram_addr <= address_sdram[ROW_WIDTH+COL_WIDTH-1+2:COL_WIDTH+2];

                    state <= read_sdram? SD_READ : SD_WRITE;
                    addr_buff <= address_sdram;
                    if(write_sdram) wr_data_buff <= write_data_sdram;
                    cycle_cnt <= 4'd1;
                    busy <= 1'b1;
                end
                else if (refresh) begin 
                    {O_sdram_ras_n, O_sdram_cas_n, O_sdram_wen_n} <= CMD_AutoRefresh;
                    state <= SD_REFRESH;
                    cycle_cnt <= 4'd1;
                    busy <= 1'b1;
                end
            end

            {SD_READ, T_RCD}: begin
                {O_sdram_ras_n, O_sdram_cas_n, O_sdram_wen_n} <= CMD_Read;
                O_sdram_addr[10] <= 1'b1;
                O_sdram_addr[9:0] <= {1'b0, addr_buff[COL_WIDTH-1+2:2]};
                O_sdram_dqm       <= 4'b0;
            end
            {SD_READ, T_RCD+CAS}: begin
                read_ready_sdram <= 1'b1;
                busy <= 1'b0;
                state <= SD_IDLE;
            end

            {SD_WRITE, T_RCD}: begin
                {O_sdram_ras_n, O_sdram_cas_n, O_sdram_wen_n} <= CMD_Write;
                O_sdram_addr[10]  <= 1'b1;
                O_sdram_addr[9:0] <= {1'b0, addr_buff[COL_WIDTH-1+2:2]};
                O_sdram_dqm       <= ~byte_mask_sdram;
                dq_out            <= wr_data_buff;
                dq_out_en         <= 1'b0;
            end

            {SD_WRITE, T_RCD+4'd1}: begin
                dq_out_en <= 1'b1;
            end

            {SD_WRITE, T_RCD+T_WR+T_RP}: begin
                write_ready_sdram <= 1'b1;
                busy <= 0;
                state <= SD_IDLE;
            end

            {SD_REFRESH, T_RC}: begin
                state <= SD_IDLE;
                busy  <= 0;
            end
        endcase

        if(rst) begin
            busy <= 1'b1;
            dq_out_en <= 1'b1;
            O_sdram_dqm <= 4'b0;
            state <= SD_INIT;
            reached_idle <= 1'b0;
        end
    end

    logic [15:0] rst_cnt;
    logic rst_done, rst_done_buf;

    logic config_debug;
    assign debug_led[3] = ~config_debug;

    always @(posedge clk) begin
        rst_done_buf <= rst_done;
        configure    <= rst_done & ~rst_done_buf;
        if(configure) config_debug <= 1'b1;
        if( rst_cnt != FREQ / 1_000_000 * 200) rst_cnt <= rst_cnt + 16'd1;
        else rst_done <= 1'b1;

        if(rst) begin
            rst_cnt <= 16'd0;
            rst_done <= 1'b0;
            config_debug <= 1'b0;
        end
    end
endmodule

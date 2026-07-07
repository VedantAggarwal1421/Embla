/* verilator lint_off WIDTHEXPAND */
module uart_tx #(
    parameter CLK_FREQ  = 27,
    parameter BAUD_RATE = 115200
) (
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] tx_data,
    input  logic       tx_valid,
    output logic       tx_ready,
    output logic       tx_pin
);
    localparam CYCLES = CLK_FREQ * 1_000_000 / BAUD_RATE;

    typedef enum logic [1:0] {
        S_IDLE,
        S_START,
        S_DATA,
        S_STOP
    } tx_state_t;

    tx_state_t state;
    logic [7:0] data;
    logic [2:0] bit_pos;
    logic [7:0] cycle_cnt;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_pin <= 1'b1;
            state <= S_IDLE;
            data <= 8'd0;
            bit_pos <= 3'd0;
            cycle_cnt <= 8'b0;
        end else begin
            case (state)
                S_IDLE: begin
                    tx_pin <= 1'b1;
                    if (tx_valid) begin
                        state <= S_START;
                        data <= tx_data;
                        bit_pos <= 3'd0;
                        cycle_cnt <= 8'd0;
                    end else state <= S_IDLE;
                end
                S_START: begin
                    cycle_cnt <= cycle_cnt + 1;
                    tx_pin <= 1'b0;
                    if (cycle_cnt == CYCLES - 1) begin
                        state <= S_DATA;
                        cycle_cnt <= 8'd0;
                    end else state <= S_START;
                end
                S_DATA: begin
                    tx_pin <= data[bit_pos];
                    cycle_cnt <= cycle_cnt + 1;
                    if (cycle_cnt == CYCLES - 1) begin
                        cycle_cnt <= 8'b0;
                        bit_pos   <= bit_pos + 3'd1;
                        if (bit_pos == 3'd7) state <= S_STOP;
                        else state <= S_DATA;
                    end else state <= S_DATA;
                end
                S_STOP: begin
                    tx_pin <= 1'b1;
                    cycle_cnt <= cycle_cnt + 1;
                    if (cycle_cnt == CYCLES - 1) begin
                        cycle_cnt <= 8'b0;
                        state <= S_IDLE;
                    end
                end
            endcase
        end
    end

    assign tx_ready = (state == S_IDLE);

endmodule

/* verilator lint_off WIDTHEXPAND */
module uart_driver (
    input logic clk,
    input logic rst,
    input logic [31:0] tx_word,
    input logic tx_data_valid,
    output logic tx_pin
);
    parameter CLK_FREQ = 27;  //MHz
    parameter BAUD_RATE = 115200;

    reg  [31:0] tx_data_word;
    reg  [ 7:0] tx_data;
    wire        tx_data_ready;
    reg         tx_active;
    reg  [ 1:0] tx_cnt;

    localparam S_IDLE = 0;
    localparam S_SEND = 1;

    reg [1:0] state;
    //verilog_format: off

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_data <= 8'd0;
            tx_cnt <= 2'd0;
            tx_active <= 1'b0;
            state <= S_IDLE;
        end else begin
            case(state)
                S_IDLE: begin
                    if(tx_data_valid) begin
                        tx_data_word <= tx_word;
                        tx_cnt <= 0;
                        tx_data <= tx_word[31:24];
                        state <= S_SEND;
                        tx_active <= 1'b1;
                    end
                    else begin
                        state <= S_IDLE;
                    end
                end
                S_SEND: begin
                    if(tx_data_ready && tx_cnt < 3) begin
                        tx_data <= tx_data_word[(2-tx_cnt)*8 +: 8];
                        tx_cnt <= tx_cnt+ 2'd1;
                    end else if(tx_data_ready) begin
                        state <= S_IDLE;
                        tx_active <= 1'b0;
                    end else begin
                        state <= S_SEND;
                    end
                end
            endcase
        end
    end
    
    //verilog_format: on
    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tranmitter (
        .clk     (clk),
        .rst     (rst),
        .tx_data (tx_data),
        .tx_valid(tx_active),
        .tx_ready(tx_data_ready),
        .tx_pin  (tx_pin)
    );
endmodule

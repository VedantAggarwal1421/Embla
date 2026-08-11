module uart_driver (
    input logic clk,
    input logic rst,
    input logic [31:0] tx_word,
    input logic tx_data_valid,
    output logic uart_busy,
    output logic tx_pin
);

    logic [4:0] counter;
    logic busy;
    assign uart_busy = busy;
    assign tx_pin = 1'b1;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 5'b0;
        end else begin
            counter <= (counter == 5'b0) ? 5'b0 : counter - 5'd1;
            if (tx_data_valid) begin
                if (!busy) begin
                    counter <= 5'b11111;
                    busy <= 1'b1;
                end else if (counter == 5'b0) begin
                    busy <= 1'b0;
                end
            end else if (counter == 5'b0) begin
                busy <= 1'b0;
            end
        end
    end

endmodule

//Program Counter (PC) module

module pc (
    input             clk,
    input             rst,
    input             pc_update,
    input      [31:0] pc_in,
    output reg [31:0] pc_out
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'b0;  // Reset PC to 0 on reset
        end else if (pc_update) begin
            pc_out <= pc_in;  // Update PC
        end
    end
endmodule

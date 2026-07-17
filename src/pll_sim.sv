//Only for simulation purposes.

module pll (
    input logic clkin,
    input logic reset,

    output logic clk,
    output logic clk_sdram,
    output logic locked
);
    assign clk = clkin;
    assign clk_sdram = ~clkin;
    assign locked    = 1'b1;
endmodule

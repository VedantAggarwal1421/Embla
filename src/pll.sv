module pll (
    input logic clkin,
    input logic reset,

    output logic clk,
    output logic clk_sdram,
    output logic locked
);

    logic clk_unused_d;
    logic clk_unused_d3;

    localparam VCC = 1'b1;
    localparam GND = 1'b0;

    rPLL rpll_inst (
        .CLKIN  (clkin),
        .RESET  (reset),
        .RESET_P(GND),

        .CLKOUT (clk),
        .CLKOUTP(clk_sdram),
        .LOCK   (locked),

        .CLKOUTD (clk_unused_d),
        .CLKOUTD3(clk_unused_d3),

        .CLKFB(GND),

        .FBDSEL({6{GND}}),
        .IDSEL ({6{GND}}),
        .ODSEL ({6{GND}}),

        .PSDA  ({4{GND}}),
        .DUTYDA({4{GND}}),
        .FDLY  ({4{VCC}})
    );

    // 27 MHz in -> 27 MHz out
    defparam rpll_inst.FCLKIN           = "27";
    defparam rpll_inst.IDIV_SEL         = 0;
    defparam rpll_inst.FBDIV_SEL        = 0;
    defparam rpll_inst.ODIV_SEL         = 32;

    // 180° phase-shifted CLKOUTP
    defparam rpll_inst.PSDA_SEL         = "1000";

    defparam rpll_inst.DYN_IDIV_SEL     = "false";
    defparam rpll_inst.DYN_FBDIV_SEL    = "false";
    defparam rpll_inst.DYN_ODIV_SEL     = "false";
    defparam rpll_inst.DYN_DA_EN        = "false";

    defparam rpll_inst.DUTYDA_SEL       = "1000";

    defparam rpll_inst.CLKFB_SEL        = "internal";

    defparam rpll_inst.CLKOUT_BYPASS    = "false";
    defparam rpll_inst.CLKOUTP_BYPASS   = "false";
    defparam rpll_inst.CLKOUTD_BYPASS   = "false";

    defparam rpll_inst.CLKOUT_FT_DIR    = 1'b1;
    defparam rpll_inst.CLKOUTP_FT_DIR   = 1'b1;

    defparam rpll_inst.CLKOUT_DLY_STEP  = 0;
    defparam rpll_inst.CLKOUTP_DLY_STEP = 0;

    defparam rpll_inst.DYN_SDIV_SEL     = 2;
    defparam rpll_inst.CLKOUTD_SRC      = "CLKOUT";
    defparam rpll_inst.CLKOUTD3_SRC     = "CLKOUT";

    defparam rpll_inst.DEVICE           = "GW2AR-18C";

endmodule

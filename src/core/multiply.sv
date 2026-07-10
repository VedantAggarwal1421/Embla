import core_pkg::muldiv_type_t;

module multiply (
    input  muldiv_type_t        muldiv_type,
    input  logic         [31:0] multiplicand,
    input  logic         [31:0] multiplier,
    output logic         [31:0] mul_result
);

    logic [63:0]    full_result;
    logic signed_multiplicand;
    logic signed_multiplier;

    always_comb begin
        signed_multiplicand = 0;
        signed_multiplier   = 0;

        if (muldiv_type == MUL || muldiv_type == MULH) begin
            signed_multiplicand = 1;
            signed_multiplier   = 1;
        end else if (muldiv_type == MULHSU) begin
            signed_multiplicand = 1;
        end
    end

    assign full_result = $signed(
        {multiplicand[31] && signed_multiplicand, multiplicand}
    ) * $signed(
        {multiplier[31] && signed_multiplier, multiplier}
    );

    assign mul_result = (muldiv_type == MUL)?   full_result[31:0] : full_result[63:32];
endmodule

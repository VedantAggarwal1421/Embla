//ALU Module
import core_pkg::*;

module alu (
    input logic [31:0] alu_a,
    input logic [31:0] alu_b,
    input alu_ctrl_t alu_ctrl,
    output logic [31:0] alu_res
);
    always_comb begin
        alu_res = '0;
        unique case (alu_ctrl)
            ALU_ADD:  alu_res = alu_a + alu_b;
            ALU_SUB:  alu_res = alu_a - alu_b;  
            ALU_SLL:  alu_res = alu_a << alu_b[4:0];
            ALU_SLT:  alu_res = {31'b0, $signed(alu_a) < $signed(alu_b)};
            ALU_SLTU: alu_res = {31'b0, alu_a < alu_b};
            ALU_XOR:  alu_res = alu_a ^ alu_b;
            ALU_SRL:  alu_res = alu_a >> alu_b[4:0];
            ALU_SRA:  alu_res = $signed(alu_a) >>> alu_b[4:0];
            ALU_OR:   alu_res = alu_a | alu_b;
            ALU_AND:  alu_res = alu_a & alu_b;
        endcase
    end
endmodule

import core_pkg::*;

module controller (
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input opcode_t opcode,

    output control_t ctrl
);

    //Main Decoder
    always_comb begin
        ctrl = '0;

        case (opcode)
            OPCODE_R: begin
                ctrl.reg_write = 1;
                ctrl.alu_srcb  = ALUB_REGISTER;
                ctrl.res_src   = RES_ALU;
                ctrl.alu_ctrl  = alu_ctrl_t'({funct7[5], funct3});
            end
            OPCODE_I: begin
                ctrl.reg_write = 1;
                ctrl.alu_srcb  = ALUB_IMMEDIATE;
                ctrl.res_src   = RES_ALU;
                ctrl.imm_type  = IMM_I;
                if (funct3 == 3'b101) begin
                    ctrl.alu_ctrl = alu_ctrl_t'({funct7[5], funct3});
                end else begin
                    ctrl.alu_ctrl = alu_ctrl_t'({1'b0, funct3});
                end
            end
            OPCODE_S: begin
                ctrl.mem_write = 1;
                ctrl.alu_srcb  = ALUB_IMMEDIATE;
                ctrl.mem_size  = funct3[1:0];
                ctrl.imm_type  = IMM_S;
            end
            OPCODE_L: begin
                ctrl.reg_write = 1;
                ctrl.mem_read  = 1;
                ctrl.alu_srcb  = ALUB_IMMEDIATE;
                ctrl.mem_size  = funct3[1:0];
                ctrl.res_src   = RES_MEM;
                ctrl.imm_type  = IMM_I;
            end
            OPCODE_B: begin
                ctrl.imm_type = IMM_B;
                ctrl.is_branch = 1'b1;
                ctrl.is_conditional = 1'b1;
                case (funct3)
                    3'b000:  ctrl.br_comp = EQ;
                    3'b001:  ctrl.br_comp = NE;
                    3'b100:  ctrl.br_comp = LT;
                    3'b101:  ctrl.br_comp = GE;
                    3'b110:  ctrl.br_comp = LTU;
                    3'b111:  ctrl.br_comp = GEU;
                    default: ctrl.br_comp = EQ;
                endcase
            end
            default: begin
                ctrl = '0;
            end
        endcase
    end

endmodule

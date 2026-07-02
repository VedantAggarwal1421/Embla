import core_pkg::*;

module controller (
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input opcode_t opcode,

    output control_t ctrl
);

    //Main Decoder
    always_comb begin
        ctrl.reg_write = 0;
        ctrl.mem_read  = 0;
        ctrl.mem_size  = '0;
        ctrl.mem_write = 0;
        case (opcode)
            OPCODE_R: begin
                ctrl.reg_write = 1;
                ctrl.alu_srcb  = ALUB_REGISTER;
                ctrl.res_src   = RES_ALU;
            end
            OPCODE_I: begin
                ctrl.reg_write = 1;
                ctrl.alu_srcb  = ALUB_IMMEDIATE;
                ctrl.res_src   = RES_ALU;
            end
            OPCODE_S: begin
                ctrl.mem_write = 1;
                ctrl.alu_srcb  = ALUB_IMMEDIATE;
                ctrl.mem_size  = funct3[1:0];
            end
            OPCODE_L: begin
                ctrl.reg_write = 1;
                ctrl.mem_read  = 1;
                ctrl.alu_srcb  = ALUB_IMMEDIATE;
                ctrl.mem_size  = funct3[1:0];
                ctrl.res_src   = RES_MEM;
            end
            default: begin
                ctrl.reg_write = 0;
                ctrl.mem_read  = 0;
                ctrl.mem_write = 0;
            end
        endcase
    end

    //Immediate Control
    always_comb begin
        case (opcode)
            OPCODE_I:     ctrl.imm_type = IMM_I;
            OPCODE_L:     ctrl.imm_type = IMM_I;
            OPCODE_S:     ctrl.imm_type = IMM_S;
            OPCODE_B:     ctrl.imm_type = IMM_B;
            OPCODE_LUI:   ctrl.imm_type = IMM_U;
            OPCODE_AUIPC: ctrl.imm_type = IMM_U;
            OPCODE_JAL:   ctrl.imm_type = IMM_J;
            OPCODE_JALR:  ctrl.imm_type = IMM_J;
            default:      ctrl.imm_type = IMM_I;
        endcase
    end

    //ALU Decoder
    always_comb begin
        if (opcode == OPCODE_R) ctrl.alu_ctrl = alu_ctrl_t'({funct7[5], funct3});
        else if (opcode == OPCODE_I) begin
            if (funct3 == 3'b101) ctrl.alu_ctrl = alu_ctrl_t'({funct7[5], funct3});
            else ctrl.alu_ctrl = alu_ctrl_t'({1'b0, funct3});
        end else ctrl.alu_ctrl = ALU_ADD;
    end
endmodule

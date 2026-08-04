import core_pkg::*;

module controller (
    input logic [31:0] instruction,
    output control_t ctrl
);
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [11:0] funct12;
    opcode_t opcode;

    assign funct3  = instruction[14:12];
    assign funct7  = instruction[31:25];
    assign funct12 = instruction[31:20];
    assign opcode  = opcode_t'(instruction[6:0]);

    //Main Decoder
    always_comb begin
        ctrl = '0;

        case (opcode)
            OPCODE_R: begin
                if (funct7[0] == 0) begin
                    ctrl.reg_write = 1;
                    ctrl.alu_srca  = ALUA_REGISTER;
                    ctrl.alu_srcb  = ALUB_REGISTER;
                    ctrl.res_src   = RES_ALU;
                    ctrl.alu_ctrl  = alu_ctrl_t'({funct7[5], funct3});
                end else begin  //MULDIV
                    ctrl.reg_write   = 1'b1;
                    ctrl.res_src     = RES_ALU;
                    ctrl.muldiv_type = muldiv_type_t'(funct3);
                    ctrl.ex_res_sel  = (funct3[2]) ? EX_RES_DIV : EX_RES_MUL;
                end
            end
            OPCODE_I: begin
                ctrl.reg_write = 1;
                ctrl.alu_srca  = ALUA_REGISTER;
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
                ctrl.alu_srca  = ALUA_REGISTER;
                ctrl.alu_srcb  = ALUB_IMMEDIATE;
                ctrl.mem_size  = funct3[1:0];
                ctrl.imm_type  = IMM_S;
            end
            OPCODE_L: begin
                ctrl.reg_write = 1;
                ctrl.mem_read  = 1;
                ctrl.alu_srca  = ALUA_REGISTER;
                ctrl.alu_srcb  = ALUB_IMMEDIATE;
                ctrl.load_type = load_type_t'(funct3);
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
            OPCODE_JAL: begin
                ctrl.reg_write  = 1'b1;
                ctrl.is_branch  = 1'b1;
                ctrl.imm_type   = IMM_J;
                ctrl.res_src    = RES_ALU;
                ctrl.ex_res_sel = EX_RES_PC4;
            end
            OPCODE_JALR: begin
                ctrl.reg_write  = 1'b1;
                ctrl.res_src    = RES_ALU;
                ctrl.is_branch  = 1'b1;
                ctrl.imm_type   = IMM_I;
                ctrl.ex_res_sel = EX_RES_PC4;
                ctrl.is_jalr    = 1'b1;
            end
            OPCODE_LUI: begin
                ctrl.reg_write  = 1'b1;
                ctrl.res_src    = RES_ALU;
                ctrl.imm_type   = IMM_U;
                ctrl.ex_res_sel = EX_RES_IMM;
            end
            OPCODE_AUIPC: begin
                ctrl.reg_write = 1'b1;
                ctrl.res_src   = RES_ALU;
                ctrl.imm_type  = IMM_U;
                ctrl.alu_srca  = ALUA_PC;
                ctrl.alu_srcb  = ALUB_IMMEDIATE;
            end
            OPCODE_SYSTEM: begin
                ctrl.is_mret = (funct3 == 3'b000) && (funct12 == 12'b001100000010);
                if (!ctrl.is_mret) begin
                    ctrl.reg_write  = 1'b1;
                    ctrl.res_src    = RES_ALU;
                    ctrl.ex_res_sel = EX_RES_CSR;
                    ctrl.imm_type   = IMM_CSR;
                    ctrl.is_csr     = 1'b1;
                end
            end
            default: begin
                //Illegal Instruction
                ctrl.trap_req.valid  = 1'b1;
                ctrl.trap_req.tcause = EXP_ILLEGAL_INSTR;
            end
        endcase
    end

endmodule

package core_pkg;

    //OPCODES
    typedef enum logic [6:0] {
        OPCODE_R     = 7'b0110011,
        OPCODE_I     = 7'b0010011,
        OPCODE_L     = 7'b0000011,
        OPCODE_S     = 7'b0100011,
        OPCODE_B     = 7'b1100011,
        OPCODE_JAL   = 7'b1101111,
        OPCODE_JALR  = 7'b1100111,
        OPCODE_LUI   = 7'b0110111,
        OPCODE_AUIPC = 7'b0010111
    } opcode_t;

    //ALU Control
    typedef enum logic [3:0] {  //{funct7[5], funct3}
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b1000,
        ALU_SLL  = 4'b0001,
        ALU_SLT  = 4'b0010,
        ALU_SLTU = 4'b0011,
        ALU_XOR  = 4'b0100,
        ALU_SRL  = 4'b0101,
        ALU_SRA  = 4'b1101,
        ALU_OR   = 4'b0110,
        ALU_AND  = 4'b0111
    } alu_ctrl_t;

    typedef enum logic {
        ALUB_REGISTER,
        ALUB_IMMEDIATE
    } alu_srcb_t;

    typedef enum logic {
        RES_ALU,
        RES_MEM
    } res_src_t;

    //Immediates
    typedef enum logic [2:0] {
        IMM_I,
        IMM_S,
        IMM_B,
        IMM_U,
        IMM_J
    } imm_type_t;

    //verilog_format: off
    function automatic logic [31:0] imm_decode(
        input imm_type_t    imm_type,
        input logic [31:0]  instruction
    );
        imm_decode = '0;
        unique case (imm_type)
            IMM_I: imm_decode = {{20{instruction[31]}}, instruction[31:20]};
            IMM_S: imm_decode = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            IMM_B: imm_decode = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            IMM_U: imm_decode = {instruction[31:12], 12'b0};
            IMM_J: imm_decode = {{11{instruction[31]}}, instruction[31], instruction[20], instruction[19:12], instruction[30:21], 1'b0};
        endcase
    endfunction
    //verilog_format: on

    typedef struct packed {
        logic       reg_write;
        logic       mem_read;
        logic       mem_write;
        logic [1:0] mem_size;
        alu_ctrl_t  alu_ctrl;
        alu_srcb_t  alu_srcb;
        res_src_t   res_src;
        imm_type_t  imm_type;
    } control_t;

    typedef struct packed {
        logic [31:0] mem_addr;       // Data memory address
        logic        mem_req_valid;  // Requesting Data
        logic [31:0] mem_wdata;      // Data memory write data
        logic        mem_we;         // Data memory write enable
        logic [1:0]  mem_size;       // Data size
    } mem_in_data_t;

    //Pipeline Registers
    typedef struct packed {
        logic        valid;
        logic [31:0] pc;
        logic [31:0] instruction;
    } if_id_t;

    typedef struct packed {
        //Data
        logic [31:0] rs1_data;
        logic [31:0] rs2_data;
        logic [31:0] immediate;
        //Control
        logic        reg_write;
        logic        mem_read;
        logic        mem_write;
        logic [1:0]  mem_size;
        alu_ctrl_t   alu_ctrl;
        alu_srcb_t   alu_srcb;
        res_src_t    res_src;
        //Forwarding
        logic [4:0]  rs1_addr;
        logic [4:0]  rs2_addr;
        logic [4:0]  rd_addr;
    } id_ex_t;

    typedef struct packed {
        //Data
        logic [31:0] alu_res;
        //Control
        logic        mem_read;
        logic        mem_write;
        logic        reg_write;
        res_src_t    res_src;
        //Forward
        logic [4:0]  rd_addr;
    } ex_mem_t;

    typedef struct packed {
        logic [31:0] alu_res;
        logic [31:0] mem_rdata;
        logic        reg_write;
        logic [4:0]  rd_addr;
        res_src_t    res_src;
    } mem_wb_t;

endpackage

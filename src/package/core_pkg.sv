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

    typedef enum logic [2:0] {
        EQ,
        NE,
        LT,
        GE,
        LTU,
        GEU
    } branch_comp_t;

    typedef enum logic [2:0] {
        LB  = 3'b000,
        LH  = 3'b001,
        LW  = 3'b010,
        LBU = 3'b100,
        LHU = 3'b101
    } load_type_t;

    typedef enum logic {
        ALUA_REGISTER,
        ALUA_PC
    } alu_srca_t;

    typedef enum logic {
        ALUB_REGISTER,
        ALUB_IMMEDIATE
    } alu_srcb_t;

    typedef enum logic [1:0] {
        FWD_REG,
        FWD_MEM,
        FWD_WB
    } forward_sel_t;

    typedef enum logic [2:0] {
        EX_RES_ALU,
        EX_RES_PC4,
        EX_RES_IMM,
        EX_RES_MUL,
        EX_RES_DIV
    } ex_res_sel_t
        ;  //Execute stage result.Treated as alu_res in stages after execute.

    typedef enum logic {
        RES_ALU,
        RES_MEM
    } res_src_t;

    typedef enum logic [2:0] {
        MUL    = 3'b000,
        MULH   = 3'b001,
        MULHSU = 3'b010,
        MULHU  = 3'b011,
        DIV    = 3'b100,
        DIVU   = 3'b101,
        REM    = 3'b110,
        REMU   = 3'b111
    } muldiv_type_t;

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

    function automatic logic [31:0] format_load(
        input logic [31:0] load,
        input load_type_t load_type,
        input logic [1:0]  res2Lsb
    );
        logic [7:0]  byte_word;
        logic [15:0] half_word;
        byte_word = load[8*res2Lsb +: 8];
        half_word = load[16*res2Lsb[1] +: 16];
        case (load_type)
            LB:  format_load = {{24{byte_word[7]}}, byte_word};   // LB
            LH:  format_load = {{16{half_word[15]}}, half_word};  // LH
            LW:  format_load = load;                              // LW
            LBU: format_load = {24'b0, byte_word};                // LBU
            LHU: format_load = {16'b0, half_word};                // LHU
            default: format_load = 32'b0;
        endcase
    endfunction

    //verilog_format: on

    typedef struct packed {
        //Ctrl Signals for RV32I
        logic         reg_write;
        logic         mem_read;
        logic         mem_write;
        logic [1:0]   mem_size;
        load_type_t   load_type;
        ex_res_sel_t  ex_res_sel;
        alu_ctrl_t    alu_ctrl;
        alu_srca_t    alu_srca;
        alu_srcb_t    alu_srcb;
        res_src_t     res_src;
        imm_type_t    imm_type;
        logic         is_branch;
        logic         is_conditional;
        logic         is_jalr;
        branch_comp_t br_comp;
        //M Extension
        muldiv_type_t muldiv_type;
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
        logic [31:0] pc;
        logic [31:0] instruction;
        logic [31:0] pc_4;
    } if_id_t;

    typedef struct packed {
        //Data
        logic [31:0]  rs1_data;
        logic [31:0]  rs2_data;
        logic [31:0]  immediate;
        logic [31:0]  pc;
        logic [31:0]  pc_4;
        //Control - RV32I
        logic         reg_write;
        logic         mem_read;
        logic         mem_write;
        logic [1:0]   mem_size;
        load_type_t   load_type;
        ex_res_sel_t  ex_res_sel;
        alu_ctrl_t    alu_ctrl;
        alu_srca_t    alu_srca;
        alu_srcb_t    alu_srcb;
        res_src_t     res_src;
        //Control - M
        muldiv_type_t muldiv_type;
        //Forwarding
        logic [4:0]   rs1_addr;
        logic [4:0]   rs2_addr;
        logic [4:0]   rd_addr;
    } id_ex_t;

    typedef struct packed {
        //Data
        logic [31:0] alu_res;
        //Control
        logic        mem_read;
        logic        mem_write;
        logic        reg_write;
        res_src_t    res_src;
        load_type_t  load_type;
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

    // Stall And Flush Signals

    typedef struct packed {
        logic if_id;
        logic id_ex;
        logic ex_mem;
        logic mem_wb;
    } stall_t;

    typedef struct packed {
        logic if_id;
        logic id_ex;
        logic ex_mem;
        logic mem_wb;
    } flush_t;

endpackage

package riscv;

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
    typedef enum logic [3:0] {
        ALU_ADD,
        ALU_SUB,
        ALU_SLL,
        ALU_SLT,
        ALU_SLTU,
        ALU_XOR,
        ALU_SRL,
        ALU_SRA,
        ALU_OR,
        ALU_AND
    } alu_ctrl_t;

    //Pipeline Registers
    typedef struct packed {
        logic valid;
        logic [31:0] pc;
        logic [31:0] instruction;
    } if_id_t;

endpackage

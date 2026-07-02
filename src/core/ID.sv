import core_pkg::*;

module instruction_decode (
    input logic clk,
    input logic rst,

    //Data from IF/ID Pipeline Register
    input if_id_t if_id,

    //Register File
    input logic [31:0] rd_data,  // Data to be written to destination register
    input logic [4:0] rd_addr,  //Address of destination register
    input logic rd_we,  // Write enable for the destination register

    //Data to ID/EX Pipeline Register
    output id_ex_t id_ex_d

);

    logic [ 4:0] rs1_addr;
    logic [ 4:0] rs2_addr;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    assign rs1_addr = if_id.instruction[19:15];
    assign rs2_addr = if_id.instruction[24:20];

    assign id_ex_d.rs1_addr = rs1_addr;
    assign id_ex_d.rs2_addr = rs2_addr;
    assign id_ex_d.rd_addr = if_id.instruction[11:7];

    assign id_ex_d.rs1_data = rs1_data;
    assign id_ex_d.rs2_data = rs2_data;

    register_file rf_inst (
        .clk(clk),
        .rst(rst),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rd_we(rd_we),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    logic [2:0] funct3;
    logic [6:0] funct7;
    opcode_t opcode;
    control_t ctrl;

    assign funct3 = if_id.instruction[14:12];
    assign funct7 = if_id.instruction[31:25];
    assign opcode = opcode_t'(if_id.instruction[6:0]);

    controller ctrl_inst (
        .funct3(funct3),
        .funct7(funct7),
        .opcode(opcode),
        .ctrl  (ctrl)
    );

    assign id_ex_d.immediate = imm_decode(ctrl.imm_type, if_id.instruction);

    assign id_ex_d.reg_write = ctrl.reg_write;
    assign id_ex_d.mem_read  = ctrl.mem_read;
    assign id_ex_d.mem_write = ctrl.mem_write;
    assign id_ex_d.mem_size  = ctrl.mem_size;
    assign id_ex_d.alu_ctrl  = ctrl.alu_ctrl;
    assign id_ex_d.alu_srcb  = ctrl.alu_srcb;
    assign id_ex_d.res_src   = ctrl.res_src;

endmodule

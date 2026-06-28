module instruction_decode (
    input logic clk,
    input logic rst,

    //Data from IF/ID Pipeline Register
    input logic [31:0] id_instruction,
    input logic [31:0] id_instruction_pc,
    input logic        id_instruction_valid,

    //Register File
    input logic [31:0] rd_data,  // Data to be written to destination register
    input logic rd_we,  // Write enable for the destination register

    //Data to ID/EX Pipeline Register
    //Control Signals

    //Operands
    output logic [31:0] id_rs1_data,  // Data from the first source register
    output logic [31:0] id_rs2_data   // Data from the second

);

    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;

    assign rs1_addr = id_instruction[19:15];
    assign rs2_addr = id_instruction[24:20];
    assign rd_addr  = id_instruction[11:7];

    register_file rf_inst (
        .clk(clk),
        .rst(rst),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rd_we(rd_we),
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data)
    );

endmodule

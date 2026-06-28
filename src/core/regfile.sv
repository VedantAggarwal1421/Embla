// This file defines the register file module.

module regfile (
    input  logic        clk,
    input  logic        rst,
    input  logic [ 4:0] rs1_addr,  // Address of the first source register
    input  logic [ 4:0] rs2_addr,  // Address of the second source register
    input  logic [ 4:0] rd_addr,   // Address of the destination register
    input  logic [31:0] rd_data,   // Destination address data
    input  logic        rd_we,     // Write enable for the destination register
    output logic [31:0] rs1_data,  // Data from the first source register
    output logic [31:0] rs2_data   // Data from the second source register
);

    logic [31:0] regFile[31:0];
    assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : regFile[rs1_addr];  //Ensure that x0 is always 0
    assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : regFile[rs2_addr]; //Combinattionaly read register file

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 32; i++) begin
                regFile[i] <= 32'b0;  //Set all registers to 0 on reset
            end
        end else if (rd_we && rd_addr != 5'b0) begin  //Ensure that x0 is never written to
            regFile[rd_addr] <= rd_data;  //Write data to the destination register
        end
    end
endmodule

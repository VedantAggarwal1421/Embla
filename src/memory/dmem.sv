module dmem (
    input logic clk,
    input logic rst,

    input  logic [31:0] addr,         // Data memory address
    input  logic        req_valid,    // Requesting Data
    input  logic [31:0] wdata,        // Data memory write data
    input  logic        we,           // Data memory write enable
    input  logic [ 1:0] size,         // Data memory size (00=byte, 01=halfword, 10=word)
    output logic        wdata_ready,  // Data Stored Succesfully
    output logic [31:0] rdata,        // Data memory read data
    output logic        rdata_ready   // Data is ready to be read        
);

    logic [31:0] data_mem[0:1023]; //Implementing memory as bram right now , will switch to sdram later.


    always_ff @(posedge clk or posedge rst) begin
        wdata_ready <= 1'b0;
        rdata       <= 32'b0;
        rdata_ready <= 1'b0;

        if (rst) begin
            wdata_ready <= 1'b0;
            rdata <= 32'b0;
            rdata_ready <= 1'b0;
        end else if (we) begin
            data_mem[addr[11:2]] <= wdata;
            wdata_ready <= 1'b1;
        end else if (req_valid) begin
            rdata <= data_mem[addr[11:2]];
            rdata_ready <= 1'b1;
        end
    end

    initial begin
        data_mem[0] = 32'hDEADBEEF;
    end
endmodule

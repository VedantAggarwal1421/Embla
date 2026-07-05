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

    (* ram_style = "block" *)
    logic [31:0] data_mem[0:1023]; //Implementing memory as bram right now , will switch to sdram later.


    always_ff @(posedge clk) begin
        if (rst) begin
            wdata_ready <= 0;
            rdata_ready <= 0;
            rdata <= 0;
        end else begin
            wdata_ready <= 0;
            rdata_ready <= 0;

            if (we) begin
                data_mem[addr[11:2]] <= wdata;
                wdata_ready <= 1;
            end

            if (req_valid) begin
                rdata <= data_mem[addr[11:2]];
                rdata_ready <= 1;
            end
        end
    end

    initial begin
        data_mem[0] = 32'hDEADBEEF;
        data_mem[1] = 32'hcafebabe;
    end
endmodule

module dmem (
    input logic clk,
    input logic rst,

    input  logic [31:0] addr,         // Data memory address
    input  logic        req_valid,    // Requesting Data
    input  logic [31:0] wdata,        // Data memory write data
    input  logic        we,           // Data memory write enable
    input  logic [ 3:0] byte_mask,    // Data Memory byte mask
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
                if(byte_mask[0])
                    data_mem[addr[11:2]][7:0] <= wdata[7:0];
                if(byte_mask[1])
                    data_mem[addr[11:2]][15:8] <= wdata[15:8];
                if(byte_mask[2])
                    data_mem[addr[11:2]][23:16] <= wdata[23:16];
                if(byte_mask[3])
                    data_mem[addr[11:2]][31:24] <= wdata[31:24];
                wdata_ready <= 1;
            end

            if (req_valid) begin
                rdata <= data_mem[addr[11:2]];
                rdata_ready <= 1;
            end
        end
    end

    initial begin
        data_mem[0] = 32'hDEAD0000;
        data_mem[1] = 32'hf0f0f0f0;
    end
endmodule

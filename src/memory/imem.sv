//Instruction memory module.

module imem (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] addr,        // Address input
    input  logic        req_valid,   //Instruction Fetch active 
    output logic [31:0] data,        // Data output
    output logic        data_valid,
    output logic        stall
);

    //Later will be implemented in SDRAM, for now we will use BRAM to store instructions for simulation purposes.
    (* ram_style = "block" *)
    logic [31:0] memory[0:255];
    // 256 x 32-bit instruction memory

    always_ff @(posedge clk or posedge rst) begin
        data_valid <= 1'b0;  // Default to not valid
        stall      <= 1'b0;  // Default to not stalled

        if (rst) begin
            data <= 32'b0;
            data_valid <= 1'b0;
            stall <= 1'b0;
        end else if (req_valid) begin
            data <= memory[addr[9:2]];
            data_valid <= 1'b1;
        end else begin
            data_valid <= 1'b0;
        end
    end

    initial begin
        // Load instructions from a file into the instruction memory
        $readmemh("tests/program.hex", memory);
    end

    // always @(*) begin
    //     if (req_valid) $display("%0t MEM accepted %h", $time, addr);

    //     if (data_valid) $display("%0t RESP %h", $time, data);
    // end
endmodule

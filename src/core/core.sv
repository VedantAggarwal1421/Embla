//Top level module for the RV32IMA Core. Interfaces with memory systems.

module core (
    input         clk,
    input         rst,
    //Instruction Fetch
    output [31:0] if_addr,        //Instruction fetch address
    output        if_req_valid,   //Fetch request valid
    input  [31:0] if_data,        // Instruction fetch data
    input         if_data_valid,  // Instruction fetch data valid
    //Data Memory
    output [31:0] dm_addr,        // Data memory address
    output [31:0] dm_wdata,       // Data memory write data
    output        dm_we,          // Data memory write enable
    output [ 1:0] dm_size,        // Data memory size (00=byte, 01=halfword, 10=word)
    input  [31:0] dm_rdata        // Data memory read data
);
    // Instruction Fetch(F) -> Instruction Decode(D) -> Execute(E) -> Memory Access(M) -> Write Back(W)

    logic [31:0] instruction;
    logic        instruction_valid;

    instructionFetch if_inst (
        .clk(clk),
        .rst(rst),
        .if_addr(if_addr),
        .if_req_valid(if_req_valid),
        .if_data(if_data),
        .if_data_valid(if_data_valid),
        .instruction(instruction),
        .instruction_valid(instruction_valid)
    );

    logic [31:0] if_id_instruction;
    logic        if_id_instruction_valid;

    always_ff @(posedge clk or posedge rst) begin
        if_id_instruction_valid <= 1'b0;  // Default to not valid
        if (rst) begin
            if_id_instruction       <= 32'b0;
            if_id_instruction_valid <= 1'b0;
        end else if (instruction_valid == 1'b1) begin
            if_id_instruction       <= instruction;
            if_id_instruction_valid <= 1'b1;
            $display("Instruction : %h, Time: %0t", instruction, $time);
        end
    end

endmodule

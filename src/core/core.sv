//Top level module for the RV32IMA Core. Interfaces with memory systems.

module core (
    input         clk,
    input         rst,
    //Instruction Fetch
    output [31:0] if_addr,        //Instruction fetch address
    output        if_req_valid,   //Fetch request valid
    input  [31:0] if_data,        // Instruction fetch data
    input         if_data_valid,  // Instruction fetch data valid
    input         if_stall,
    //Data Memory
    output [31:0] dm_addr,        // Data memory address
    output [31:0] dm_wdata,       // Data memory write data
    output        dm_we,          // Data memory write enable
    output [ 1:0] dm_size,        // Data memory size (00=byte, 01=halfword, 10=word)
    input  [31:0] dm_rdata        // Data memory read data
);
    // Instruction Fetch(F) -> Instruction Decode(D) -> Execute(E) -> Memory Access(M) -> Write Back(W)

    logic [31:0] if_instruction;
    logic [31:0] if_instruction_pc;
    logic        if_instruction_valid;

    instruction_fetch if_inst (
        .clk(clk),
        .rst(rst),
        .if_addr(if_addr),
        .if_req_valid(if_req_valid),
        .if_data(if_data),
        .if_data_valid(if_data_valid),
        .if_stall(if_stall),
        .instruction(if_instruction),
        .instruction_pc(if_instruction_pc),
        .instruction_valid(if_instruction_valid)
    );

    logic [31:0] if_id_instruction;
    logic [31:0] if_id_instruction_pc;
    logic        if_id_instruction_valid;

    //IF/ID Pipeline Register
    always_ff @(posedge clk or posedge rst) begin
        if_id_instruction_valid <= 1'b0;  // Default to not valid
        if (rst) begin
            if_id_instruction       <= 32'b0;
            if_id_instruction_pc    <= 32'b0;
            if_id_instruction_valid <= 1'b0;
        end else if (if_instruction_valid == 1'b1) begin
            if_id_instruction       <= if_instruction;
            if_id_instruction_pc    <= if_instruction_pc;
            if_id_instruction_valid <= if_instruction_valid;
            $display("Instruction : %h, PC: %h, Time: %0t", if_instruction, if_instruction_pc,
                     $time);
        end
    end

    //Instruction Decode

    logic [31:0] id_instruction;
    logic [31:0] id_instruction_pc;
    logic        id_instruction_valid;

    assign id_instruction = if_id_instruction;
    assign id_instruction_pc = if_id_instruction_pc;
    assign id_instruction_valid = if_id_instruction_valid;

endmodule

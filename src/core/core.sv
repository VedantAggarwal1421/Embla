//Top level module for the RV32IMA Core. Interfaces with memory systems.
import riscv::*;

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

    if_id_t if_id_d;
    if_id_t if_id_q;

    instruction_fetch if_inst (
        .clk(clk),
        .rst(rst),
        .if_addr(if_addr),
        .if_req_valid(if_req_valid),
        .if_data(if_data),
        .if_data_valid(if_data_valid),
        .if_stall(if_stall),
        .instruction(if_id_d.instruction),
        .instruction_pc(if_id_d.pc),
        .instruction_valid(if_id_d.valid)
    );

    //IF/ID Pipeline Register
    always_ff @(posedge clk or posedge rst) begin
        if_id_q.valid <= 1'b0;  // Default to not valid
        if (rst) begin
            if_id_q <= '0;
        end else if (if_id_d.valid == 1'b1) begin
            if_id_q <= if_id_d;
            $display("Instruction : %h, PC: %h, Time: %0t", if_id_d.instruction, if_id_d.pc, $time);
        end
    end

    //Instruction Decode

    logic [31:0] id_instruction;
    logic [31:0] id_instruction_pc;
    logic        id_instruction_valid;

endmodule

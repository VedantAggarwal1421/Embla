module instruction_fetch (
    input  logic        clk,
    input  logic        rst,
    //Instruction Fetch Signals
    output logic [31:0] if_addr,        // Instruction fetch address
    output logic        if_req_valid,   // Fetch request valid
    input  logic [31:0] if_data,        // Instruction fetch data
    input  logic        if_data_valid,  // Instruction fetch data valid
    input  logic        if_stall,

    output logic [31:0] instruction,
    output logic [31:0] instruction_pc,
    output logic        instruction_valid  // Signal indicating instruction is valid
);

    logic [31:0] pc;
    logic [31:0] old_pc;

    assign if_addr = pc;
    assign if_req_valid = ~if_stall;  // Always request instructions. Will add stall logic later.

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'b0;
            old_pc <= 32'b0;
        end else if (if_req_valid) begin
            pc <= pc + 4;  // Increment PC by 4 for next instruction
            old_pc <= pc;  // Store the current PC
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        instruction_valid <= 1'b0;  // Default to not valid
        if (rst) begin
            instruction <= 32'b0;
            instruction_pc <= 32'b0;
            instruction_valid <= 1'b0;
        end else begin
            instruction <= if_data;
            instruction_pc <= old_pc;  // Use the stored PC for the current instruction
            instruction_valid <= if_data_valid;
        end
    end

endmodule

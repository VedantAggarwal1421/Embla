module instructionFetch (
    input  logic        clk,
    input  logic        rst,
    //Instruction Fetch Signals
    output logic [31:0] if_addr,       // Instruction fetch address
    output logic        if_req_valid,  // Fetch request valid
    input  logic [31:0] if_data,       // Instruction fetch data
    input  logic        if_data_valid, // Instruction fetch data valid

    output logic [31:0] instruction,
    output logic [31:0] instruction_pc,
    output logic        instruction_valid  // Signal indicating instruction is valid
);

    logic [31:0] pc;

    assign if_addr = pc;  // Assign the current PC to the instruction fetch address

    typedef enum logic [0:0] {
        IF_REQ,
        IF_WAIT
    } if_state_t;

    if_state_t if_state;

    always_ff @(posedge clk or posedge rst) begin
        //$display("Instruction Fetch State: %0d, Time: %0t", if_state, $time);
        if (rst) begin
            if_state          <= IF_REQ;
            if_req_valid      <= 1'b1;
            pc                <= 32'b0;  // Reset PC to 0 on reset
            instruction       <= 32'b0;
            instruction_pc    <= 32'b0;
            instruction_valid <= 1'b0;
        end else begin
            instruction_valid <= 1'b0;  // Default to instruction not valid
            case (if_state)
                IF_REQ: begin
                    if_req_valid <= 1'b1;  // Request instruction fetch
                    if_state <= IF_WAIT;
                end
                IF_WAIT: begin
                    if_req_valid <= 1'b0;
                    if (if_data_valid) begin
                        instruction       <= if_data;  //Latch instruction data
                        instruction_valid <= 1'b1;  //Assert valid
                        instruction_pc    <= pc;  //Latch PC
                        pc                <= pc + 32'd4;  //Update PC
                        if_req_valid      <= 1'b1;
                        if_state          <= IF_REQ;
                    end else begin
                        if_state <= IF_WAIT;  // Stay in wait state until data is valid
                    end
                end
            endcase
        end
    end



endmodule

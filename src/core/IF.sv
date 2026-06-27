module instructionFetch (
    input  logic        clk,
    input  logic        rst,
    //Instruction Fetch Signals
    output logic [31:0] if_addr,       // Instruction fetch address
    output logic        if_req_valid,  // Fetch request valid
    input  logic [31:0] if_data,       // Instruction fetch data
    input  logic        if_data_valid, // Instruction fetch data valid

    output logic [31:0] instruction,
    output logic        instruction_valid  // Signal indicating instruction is valid
);

    logic pc_update;
    logic [31:0] pc_in;
    logic [31:0] pc_out;

    assign pc_in   = pc_out + 32'd4;
    assign if_addr = pc_out;

    typedef enum logic [0:0] {
        IF_REQ,
        IF_WAIT
    } if_state_t;

    if_state_t if_state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            if_state          <= IF_REQ;
            pc_update         <= 1'b0;
            if_req_valid      <= 1'b0;
            instruction       <= 32'b0;
            instruction_valid <= 1'b0;
        end else begin
            pc_update <= 1'b0;  // Default to no PC update
            instruction_valid <= 1'b0;  // Default to instruction not valid
            case (if_state)
                IF_REQ: begin
                    //if_req_valid <= 1'b1;  // Request instruction fetch
                    if_state <= IF_WAIT;
                end
                IF_WAIT: begin
                    if_req_valid <= 1'b0;
                    if (if_data_valid) begin
                        instruction       <= if_data;  //Latch instruction data
                        instruction_valid <= 1'b1;  //Assert valid
                        pc_update         <= 1'b1;  //Update PC
                        if_req_valid      <= 1'b1;  // Request next instruction fetch
                        if_state          <= IF_REQ;
                    end else begin
                        if_state <= IF_WAIT;  // Stay in wait state until data is valid
                    end
                end
            endcase
        end
    end

    pc pc_inst (
        .clk(clk),
        .rst(rst),
        .pc_update(pc_update),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

endmodule

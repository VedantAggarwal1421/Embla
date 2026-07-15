module instruction_fetch (
    input  logic        clk,
    input  logic        rst,
    //Instruction Fetch Signals
    output logic [31:0] if_addr,        // Instruction fetch address
    output logic        if_req_valid,   // Fetch request valid
    input  logic [31:0] if_data,        // Instruction fetch data
    input  logic        if_data_valid,  // Instruction fetch data valid
    input  logic        if_stall,

    output logic        instruction_valid,
    output logic [31:0] instruction,
    output logic [31:0] instruction_pc,
    output logic [31:0] instruction_pc_4,

    //Branching
    input logic        redirect_valid,
    input logic [31:0] redirect_pc
);

    logic [31:0] pc;
    logic [31:0] old_pc;

    logic [31:0] fetch_buff_instr;
    logic [31:0] fetch_buff_pc;
    logic [31:0] fetch_buff_pc_4;
    logic        fetch_buff_valid;


    assign if_req_valid = ~if_stall;  //If not stalled request instructions
    assign if_addr = pc;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'd0;
            old_pc <= 32'd0;
        end else if (if_req_valid) begin
            if (redirect_valid) begin
                pc <= redirect_pc;
                old_pc <= pc;
            end else begin
                pc <= pc + 32'd4;
                old_pc <= pc;
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            fetch_buff_instr <= 32'b0;
            fetch_buff_pc <= 32'b0;
            fetch_buff_pc_4 <= 32'b0;
            fetch_buff_valid <= 1'b0;
        end else if (!if_req_valid && if_data_valid) begin
            fetch_buff_instr <= if_data;
            fetch_buff_pc <= old_pc;
            fetch_buff_pc_4 <= pc;
            fetch_buff_valid <= 1'b1;
        end else if (if_req_valid) begin
            fetch_buff_valid <= 1'b0;
        end
    end

    assign instruction_valid = (fetch_buff_valid) ? 1'b1 : if_data_valid;
    assign instruction = (fetch_buff_valid) ? fetch_buff_instr : (if_data_valid) ? if_data : 32'b0;
    assign instruction_pc = (fetch_buff_valid) ? fetch_buff_pc : old_pc;
    assign instruction_pc_4 = (fetch_buff_valid) ? fetch_buff_pc_4 : pc;

endmodule

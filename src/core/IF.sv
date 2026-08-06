module instruction_fetch (
    input  logic        clk,
    input  logic        rst,
    //Instruction Fetch Signals
    output logic [31:0] if_addr,        // Instruction fetch address
    output logic        if_req_valid,   // Fetch request valid
    input  logic [31:0] if_data,        // Instruction fetch data
    input  logic        if_data_valid,  // Instruction fetch data valid
    input  logic        if_stall,

    input logic if_id_en,  //if/id register accepting instructions

    output logic        instruction_valid,
    output logic [31:0] instruction,
    output logic [31:0] instruction_pc,
    output logic [31:0] instruction_pc_4,

    //Branching
    input logic        redirect_valid,
    input logic [31:0] redirect_pc
);

    logic [31:0] outstanding_pc;
    logic [31:0] request_pc;
    logic [31:0] outstanding_pc_4;
    assign outstanding_pc_4 = outstanding_pc + 32'd4;

    logic        redirect_req_pending;
    logic [31:0] redirect_req_pc;
    logic        redirect_serviced;

    always @(posedge clk) begin
        if (redirect_valid) begin
            redirect_req_pending <= 1'b1;
            redirect_req_pc <= redirect_pc;
        end else if (redirect_serviced) begin
            redirect_req_pending <= 1'b0;
        end
    end

    typedef enum logic [1:0] {
        IF_IDLE,
        IF_REQ,
        IF_RESP
    } if_state_t;

    if_state_t if_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            if_state       <= IF_REQ;
            outstanding_pc <= 32'd0;
            request_pc     <= 32'd0;
        end else begin
            case (if_state)
                IF_IDLE: begin
                    if (!if_stall) begin
                        request_pc <= outstanding_pc_4;
                        if_state   <= IF_REQ;
                    end
                end
                IF_REQ: begin
                    redirect_serviced <= 1'b0;
                    if (!if_stall) begin
                        instruction_valid <= 1'b0;
                        if_req_valid      <= 1'b1;
                        if_addr           <= request_pc;
                        outstanding_pc    <= request_pc;
                        if_state          <= IF_RESP;
                    end else if (if_id_en) begin
                        instruction_valid <= 1'b0;
                    end
                end
                IF_RESP: begin
                    if_req_valid <= 1'b0;
                    if (if_data_valid && !(redirect_req_pending || redirect_valid)) begin  //Response for outstanding pc. Dicard if we need to branch
                        if (if_stall) begin  //Dont request any more instructions
                            instruction_valid <= 1'b1;
                            instruction       <= if_data;
                            instruction_pc    <= outstanding_pc;
                            instruction_pc_4  <= outstanding_pc_4;
                            if_state          <= IF_IDLE;
                        end else begin  //Everything executing normally
                            instruction_valid <= 1'b1;
                            instruction       <= if_data;
                            instruction_pc    <= outstanding_pc;
                            instruction_pc_4  <= outstanding_pc_4;
                            if_state          <= IF_REQ;
                            request_pc        <= outstanding_pc_4;
                        end
                    end else if (if_data_valid) begin  //Redirect active
                        if_state          <= IF_REQ;
                        request_pc        <= (redirect_valid) ? redirect_pc : redirect_req_pc;
                        redirect_serviced <= 1'b1;
                    end else begin
                        if_state <= IF_RESP;
                    end
                end
                default: if_state <= IF_IDLE;
            endcase
        end
    end
endmodule

/*
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
        end else if (fetch_buff_valid && if_id_en) begin
            fetch_buff_valid <= 1'b0;
        end
    end

    assign instruction_valid = (fetch_buff_valid) ? 1'b1 : if_data_valid;
    assign instruction = (fetch_buff_valid) ? fetch_buff_instr : (if_data_valid) ? if_data : 32'b0;
    assign instruction_pc = (fetch_buff_valid) ? fetch_buff_pc : old_pc;
    assign instruction_pc_4 = (fetch_buff_valid) ? fetch_buff_pc_4 : pc;
    */

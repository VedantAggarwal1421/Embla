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
    input logic [31:0] redirect_pc,

    //State info
    output logic        settled,
    output logic [31:0] next_fetch
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

    assign settled = if_stall && (if_state != IF_RESP);
    always_comb begin
        case (if_state)
            IF_IDLE: begin
                if (redirect_valid || redirect_req_pending)
                    next_fetch = redirect_valid ? redirect_pc : redirect_req_pc;
                else next_fetch = outstanding_pc_4;
            end
            IF_REQ: begin
                if (redirect_valid || redirect_req_pending)
                    next_fetch = redirect_valid ? redirect_pc : redirect_req_pc;
                else next_fetch = request_pc;
            end
            default: next_fetch = outstanding_pc_4;
        endcase
    end


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            if_state       <= IF_REQ;
            outstanding_pc <= 32'd0;
            request_pc     <= 32'd0;
        end else begin
            case (if_state)
                IF_IDLE: begin
                    if (!if_stall) begin
                        instruction_valid <= 1'b0;
                        if (redirect_valid || redirect_req_pending) begin
                            request_pc <= redirect_valid ? redirect_pc : redirect_req_pc;
                        end else request_pc <= outstanding_pc_4;
                        if_state <= IF_REQ;
                    end else if (if_id_en) begin
                        instruction_valid <= 1'b0;
                    end
                end
                IF_REQ: begin
                    redirect_serviced <= 1'b0;
                    if (!if_stall) begin
                        instruction_valid <= 1'b0;
                        if_req_valid      <= 1'b1;
                        if (redirect_valid || redirect_req_pending) begin
                            if_addr           <= redirect_valid ? redirect_pc : redirect_req_pc;
                            outstanding_pc    <= redirect_valid ? redirect_pc : redirect_req_pc;
                            redirect_serviced <= 1'b1;
                        end else begin
                            if_addr        <= request_pc;
                            outstanding_pc <= request_pc;
                        end
                        if_state <= IF_RESP;
                    end else if (if_id_en) begin
                        instruction_valid <= 1'b0;
                    end
                end
                IF_RESP: begin
                    if_req_valid <= 1'b0;
                    redirect_serviced <= 1'b0;
                    if (if_data_valid && !((redirect_req_pending&&(~redirect_serviced)) || redirect_valid)) begin  //Response for outstanding pc. Dicard if we need to branch

                        instruction_valid <= 1'b1;
                        instruction       <= if_data;
                        instruction_pc    <= outstanding_pc;
                        instruction_pc_4  <= outstanding_pc_4;
                        request_pc        <= outstanding_pc_4;
                        if_state          <= (if_stall) ? IF_IDLE : IF_REQ;

                    end else if (if_data_valid) begin  //Redirect active
                        if_state <= IF_REQ;
                    end else begin
                        if_state <= IF_RESP;
                    end
                end
                default: if_state <= IF_IDLE;
            endcase
        end
    end
endmodule

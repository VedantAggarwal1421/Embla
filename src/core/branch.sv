import core_pkg::*;

module branch_unit (
    input  logic                is_branch,
    input  logic                is_conditional,
    input  logic         [31:0] branch_pc,
    input  logic         [31:0] branch_offset,
    input  logic         [31:0] rs1,             //Forwarding handled by hazard unit
    input  logic         [31:0] rs2,
    input  branch_comp_t        br_comp,
    output logic                redirect_valid,
    output logic         [31:0] redirect_pc,
    output logic                branch_flush
);

    assign redirect_pc = branch_pc + branch_offset;
    logic equal, less_u, less;
    assign equal  = rs1 == rs2;
    assign less_u = rs1 < rs2;
    assign less   = $signed(rs1) < $signed(rs2);

    always_comb begin
        redirect_valid = 1'b0;
        if (is_conditional && is_branch) begin
            case (br_comp)
                EQ: redirect_valid = equal;
                NE: redirect_valid = !equal;
                LT: redirect_valid = less;
                GE: redirect_valid = !less;
                LTU: redirect_valid = less_u;
                GEU: redirect_valid = !less_u;
                default: redirect_valid = 1'b0;
            endcase
        end else if (is_branch) begin
            redirect_valid = 1'b1;
        end
    end

    always_comb begin
        branch_flush = 1'b0;
        if (redirect_valid) begin
            branch_flush = 1'b1;
        end
    end



endmodule

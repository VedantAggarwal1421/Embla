import core_pkg::*;

module hazard_unit (
    input  logic         [4:0] mem_rd_addr,
    input  logic               mem_reg_write,
    input  logic         [4:0] wb_rd_addr,
    input  logic               wb_reg_write,
    input  logic         [4:0] ex_rs1_addr,
    input  logic         [4:0] ex_rs2_addr,
    output forward_sel_t       fwd_a_sel,
    output forward_sel_t       fwd_b_sel
);

    //Forward A
    always_comb begin
        if (mem_reg_write && (mem_rd_addr != 5'd0) && (mem_rd_addr == ex_rs1_addr))
            fwd_a_sel = FWD_MEM;
        else if (wb_reg_write && (wb_rd_addr != 5'd0) && (wb_rd_addr == ex_rs1_addr))
            fwd_a_sel = FWD_WB;
        else begin
            fwd_a_sel = FWD_REG;
        end
    end

    //Forward B
    always_comb begin
        if (mem_reg_write && (mem_rd_addr != 5'd0) && (mem_rd_addr == ex_rs2_addr))
            fwd_b_sel = FWD_MEM;
        else if (wb_reg_write && (wb_rd_addr != 5'd0) && (wb_rd_addr == ex_rs2_addr))
            fwd_b_sel = FWD_WB;
        else begin
            fwd_b_sel = FWD_REG;
        end
    end

endmodule

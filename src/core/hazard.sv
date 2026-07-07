import core_pkg::*;

module hazard_unit (
    input  logic         [4:0] mem_rd_addr,
    input  logic               mem_reg_write,
    input  logic         [4:0] wb_rd_addr,
    input  logic               wb_reg_write,
    input  logic         [4:0] ex_rs1_addr,
    input  logic         [4:0] ex_rs2_addr,
    input  res_src_t           ex_res_src,
    input  logic         [4:0] ex_rd_addr,
    input  logic         [4:0] id_rs1_addr,
    input  logic         [4:0] id_rs2_addr,
    output forward_sel_t       fwd_a_sel,
    output forward_sel_t       fwd_b_sel,
    output stall_t             stall,
    output flush_t             flush
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

    always_comb begin
        if(ex_res_src == RES_MEM && ((id_rs1_addr == ex_rd_addr) || (id_rs2_addr == ex_rd_addr))) begin
            stall.if_id = 1;
            flush.id_ex = 1;
        end else begin
            stall = '0;
            flush = '0;
        end
    end



endmodule

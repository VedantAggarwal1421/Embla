import core_pkg::*;

module hazard_unit (
    input  logic         [4:0] mem_rd_addr,
    input  logic               mem_reg_write,
    input  res_src_t           mem_res_src,
    input  logic         [4:0] wb_rd_addr,
    input  logic               wb_reg_write,
    input  logic         [4:0] ex_rs1_addr,
    input  logic         [4:0] ex_rs2_addr,
    input  res_src_t           ex_res_src,
    input  logic         [4:0] ex_rd_addr,
    input  logic         [4:0] id_rs1_addr,
    input  logic         [4:0] id_rs2_addr,
    input  logic               is_conditional,  //Branch
    input  logic               is_jalr,
    output forward_sel_t       fwd_a_sel,
    output forward_sel_t       fwd_b_sel,
    output forward_sel_t       branch_a_sel,
    output forward_sel_t       branch_b_sel,
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

    //Forward Branches
    always_comb begin
        if (is_conditional || is_jalr) begin
            if (mem_reg_write && (mem_rd_addr != 5'd0) && (mem_rd_addr == id_rs1_addr))
                branch_a_sel = FWD_MEM;
            else if (wb_reg_write && (wb_rd_addr != 5'd0) && (wb_rd_addr == id_rs1_addr))
                branch_a_sel = FWD_WB;
            else begin
                branch_a_sel = FWD_REG;
            end
        end else branch_a_sel = FWD_REG;
    end
    always_comb begin
        if (is_conditional) begin
            if (mem_reg_write && (mem_rd_addr != 5'd0) && (mem_rd_addr == id_rs2_addr))
                branch_b_sel = FWD_MEM;
            else if (wb_reg_write && (wb_rd_addr != 5'd0) && (wb_rd_addr == id_rs2_addr))
                branch_b_sel = FWD_WB;
            else begin
                branch_b_sel = FWD_REG;
            end
        end else branch_b_sel = FWD_REG;
    end

    //Stall the pipeline
    always_comb begin
        stall.if_id = 0;
        flush.id_ex = 0;
        if (is_conditional || is_jalr) begin  //Hazards in case of branching
            if((id_rs1_addr == ex_rd_addr) || (id_rs2_addr == ex_rd_addr)) begin //Needed operand in EX stage
                stall.if_id = 1;
                flush.id_ex = 1;
            end
            else if(mem_res_src == RES_MEM && ((id_rs1_addr == mem_rd_addr) || (id_rs2_addr == mem_rd_addr))) begin //Needed operand has to be loaded from memory
                stall.if_id = 1;
                flush.id_ex = 1;
            end
        end else begin
            if(ex_res_src == RES_MEM && ((id_rs1_addr == ex_rd_addr) || (id_rs2_addr == ex_rd_addr))) begin //Load use hazard
                stall.if_id = 1;
                flush.id_ex = 1;
            end else begin
                stall = '0;
                flush = '0;
            end
        end
    end

endmodule

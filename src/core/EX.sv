/* verilator lint_off CASEINCOMPLETE */
import core_pkg::*;

module execute (
    input logic clk,
    input logic rst,

    input id_ex_t id_ex,

    input forward_sel_t fwd_a_sel,
    input forward_sel_t fwd_b_sel,
    input logic [31:0] fwd_mem_data,
    input logic [31:0] fwd_wb_data,

    output ex_mem_t ex_mem_d,
    output mem_in_data_t mem_in_data
);

    logic [31:0] alu_a;
    logic [31:0] alu_b;
    logic [31:0] alu_res;

    logic [31:0] fwd_a;
    logic [31:0] fwd_b;

    assign alu_a = fwd_a;

    // alu_srcb_t alu_src_b_debug;
    // logic [31:0] immediate_debug;

    // assign alu_src_b_debug = id_ex.alu_srcb;
    // assign immediate_debug = id_ex.immediate;
    //ALU Source B MUX
    always_comb begin
        unique case (id_ex.alu_srcb)
            ALUB_REGISTER:  alu_b = fwd_b;
            ALUB_IMMEDIATE: alu_b = id_ex.immediate;
        endcase
    end

    //Forward A Mux
    always_comb begin
        fwd_a = id_ex.rs1_data;
        case (fwd_a_sel)
            FWD_REG: fwd_a = id_ex.rs1_data;
            FWD_MEM: fwd_a = fwd_mem_data;
            FWD_WB:  fwd_a = fwd_wb_data;
        endcase
    end
    //Forward B Mux
    always_comb begin
        fwd_b = id_ex.rs2_data;
        case (fwd_b_sel)
            FWD_REG: fwd_b = id_ex.rs2_data;
            FWD_MEM: fwd_b = fwd_mem_data;
            FWD_WB:  fwd_b = fwd_wb_data;
        endcase
    end

    //ALU
    alu alu_inst (
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_ctrl(id_ex.alu_ctrl),
        .alu_res(alu_res)
    );

    assign ex_mem_d.rd_addr          = id_ex.rd_addr;
    assign ex_mem_d.alu_res          = (id_ex.sel_pc_4)? id_ex.pc_4 : alu_res;
    assign ex_mem_d.reg_write        = id_ex.reg_write;
    assign ex_mem_d.mem_read         = id_ex.mem_read;
    assign ex_mem_d.mem_write        = id_ex.mem_write;
    assign ex_mem_d.res_src          = id_ex.res_src;

    assign mem_in_data.mem_addr      = alu_res;
    assign mem_in_data.mem_req_valid = id_ex.mem_read;
    assign mem_in_data.mem_wdata     = fwd_b;
    assign mem_in_data.mem_we        = id_ex.mem_write;
    assign mem_in_data.mem_size      = id_ex.mem_size;
endmodule

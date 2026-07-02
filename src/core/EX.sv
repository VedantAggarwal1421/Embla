import core_pkg::*;

module execute (
    input logic clk,
    input logic rst,

    input id_ex_t id_ex,

    output ex_mem_t ex_mem_d,
    output mem_in_data_t mem_in_data
);

    logic [31:0] alu_a;
    logic [31:0] alu_b;
    logic [31:0] alu_res;

    assign alu_a = id_ex.rs1_data;
    //ALU Source B MUX
    always_comb begin
        unique case (id_ex.alu_srcb)
            ALUB_REGISTER:  alu_b = id_ex.rs2_data;
            ALUB_IMMEDIATE: alu_b = id_ex.immediate;
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
    assign ex_mem_d.alu_res          = alu_res;
    assign ex_mem_d.reg_write        = id_ex.reg_write;
    assign ex_mem_d.mem_read         = id_ex.mem_read;
    assign ex_mem_d.mem_write        = id_ex.mem_write;
    assign ex_mem_d.res_src          = id_ex.res_src;

    assign mem_in_data.mem_addr      = alu_res;
    assign mem_in_data.mem_req_valid = id_ex.mem_read;
    assign mem_in_data.mem_wdata     = id_ex.rs2_data;
    assign mem_in_data.mem_we        = id_ex.mem_write;
    assign mem_in_data.mem_size      = id_ex.mem_size;
endmodule

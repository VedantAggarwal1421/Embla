import core_pkg::*;

module memory_access (
    input logic clk,
    input logic rst,

    input logic        mem_wdata_ready,  // Write completed
    input logic [31:0] mem_rdata,        // Data memory read data
    input logic        mem_rdata_ready,  // Data is ready to be read

    output logic   mem_stall,        // Either write is not complete or read isnt complete. Stall the entire pipeline.
    input ex_mem_t ex_mem,
    output mem_wb_t mem_wb_d
);
    assign mem_stall = (ex_mem.mem_read && ~mem_rdata_ready) || (ex_mem.mem_write && ~mem_wdata_ready);
    assign mem_wb_d.alu_res = ex_mem.alu_res;
    assign mem_wb_d.mem_rdata = format_load(mem_rdata, ex_mem.load_type, ex_mem.alu_res[1:0]);
    assign mem_wb_d.reg_write = ex_mem.reg_write;
    assign mem_wb_d.rd_addr = ex_mem.rd_addr;
    assign mem_wb_d.res_src = ex_mem.res_src;
endmodule

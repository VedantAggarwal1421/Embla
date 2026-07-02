module write_back (
    input logic clk,
    input logic rst,

    input  mem_wb_t        mem_wb,
    output logic    [31:0] rd_data,
    output logic    [ 4:0] rd_addr,
    output logic           rd_we
);
    assign rd_addr = mem_wb.rd_addr;
    assign rd_we   = mem_wb.reg_write;

    always_comb begin
        unique case (mem_wb.res_src)
            RES_ALU: rd_data = mem_wb.alu_res;
            RES_MEM: rd_data = mem_wb.mem_rdata;
        endcase
    end

endmodule

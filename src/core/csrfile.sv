import csr_pkg::*;

module csr_file (
    input logic clk,
    input logic rst,

    input logic        csr_read,
    input logic [11:0] csr_src_addr,
    input logic [11:0] csr_rd_addr,
    input logic [31:0] csr_rd_data,
    input logic        csr_rd_we,

    output logic [31:0] csr_src_data
);

    logic write_allowed;
    priv_lvl_t priv_lvl;
    assign write_allowed = ~(&csr_src_addr[11:10]);
    assign priv_lvl = priv_lvl_t'(csr_src_addr[9:8]);


    logic [31:0] mvendorid;
    logic [31:0] marchid;
    logic [31:0] mimpid;
    logic [31:0] mhartid;
    logic [31:0] mstatus;
    logic [31:0] misa;
    logic [31:0] mie;
    logic [31:0] mtvec;
    logic [31:0] mscratch;
    logic [31:0] mepc;
    logic [31:0] mcause;
    logic [31:0] mtval;
    logic [31:0] mip;
    logic [63:0] mcycle;
    logic [63:0] minstret;


    always_comb begin
        if (csr_read) begin

        end
    end
endmodule

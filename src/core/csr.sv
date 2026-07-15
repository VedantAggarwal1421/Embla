import core_pkg::*;
import csr_pkg::*;

module csr_unit (  //Manages the csr subsystem
    input logic        clk,
    input logic        rst,
    input logic        csr_instr_valid,
    input logic [ 2:0] csr_instr,
    input logic [11:0] csr_src_addr,
    input logic [31:0] immediate_data_in,
    input logic [ 4:0] int_rs1_addr,
    input logic [ 4:0] int_rd_addr,
    input logic [31:0] int_data_in,

    input  trap_req_t        id_trap_req,
    output logic             trap_redirect_valid,
    output logic      [31:0] trap_redirect_pc,

    output logic [31:0] int_data_out
);

    logic        csr_instr_valid_q;
    logic [ 2:0] csr_instr_q;
    logic [11:0] csr_src_addr_q;
    logic [31:0] immediate_q;
    logic [ 4:0] rs1_addr_q;
    logic [ 4:0] rd_addr_q;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            csr_instr_valid_q <= '0;
            csr_instr_q       <= '0;
            csr_src_addr_q    <= '0;
            immediate_q       <= '0;
            rs1_addr_q        <= '0;
            rd_addr_q         <= '0;
        end else begin
            csr_instr_valid_q <= csr_instr_valid;
            csr_instr_q       <= csr_instr;
            csr_src_addr_q    <= csr_src_addr;
            immediate_q       <= immediate_data_in;
            rs1_addr_q        <= int_rs1_addr;
            rd_addr_q         <= int_rd_addr;
        end
    end

    logic        csr_read;
    logic [31:0] csr_src_data;
    logic [31:0] csr_rd_data;
    logic        csr_rd_we;

    csr_file cf_inst (
        .clk(clk),
        .rst(rst),
        .csr_read(csr_instr_valid_q && csr_read),
        .csr_src_addr(csr_src_addr_q),
        .csr_rd_addr(csr_src_addr_q),
        .csr_rd_data(csr_rd_data),
        .csr_rd_we(csr_instr_valid && csr_rd_we),
        .csr_src_data(csr_src_data),
        .id_trap_req(id_trap_req),
        .trap_redirect_valid(trap_redirect_valid),
        .trap_redirect_pc(trap_redirect_pc)
    );

    //Operation
    always_comb begin
        case (csr_instr_t'(csr_instr_q))
            CSRRW: begin
                if (rd_addr_q == 0) csr_read = 1'b0;
                else csr_read = 1'b1;

                int_data_out = csr_src_data;
                csr_rd_data  = int_data_in;
                csr_rd_we    = 1'b1;
            end
            CSRRS: begin
                csr_read = 1'b1;
                int_data_out = csr_src_data;
                csr_rd_data = int_data_in | csr_src_data;

                if (rs1_addr_q == 0) csr_rd_we = 1'b0;
                else csr_rd_we = 1'b1;
            end
            CSRRC: begin
                csr_read = 1'b1;
                int_data_out = csr_src_data;
                csr_rd_data = (~int_data_in) & csr_src_data;

                if (rs1_addr_q == 0) csr_rd_we = 1'b0;
                else csr_rd_we = 1'b1;
            end
            CSRRWI: begin
                if (rd_addr_q == 0) csr_read = 1'b0;
                else csr_read = 1'b1;

                int_data_out = csr_src_data;
                csr_rd_data  = immediate_q;
                csr_rd_we    = 1'b1;
            end
            CSRRSI: begin
                csr_read = 1'b1;
                int_data_out = csr_src_data;
                csr_rd_data = immediate_q | csr_src_data;

                if (rs1_addr_q == 0) csr_rd_we = 1'b0;
                else csr_rd_we = 1'b1;
            end
            CSRRCI: begin
                csr_read = 1'b1;
                int_data_out = csr_src_data;
                csr_rd_data = (~immediate_q) & csr_src_data;

                if (rs1_addr_q == 0) csr_rd_we = 1'b0;
                else csr_rd_we = 1'b1;
            end
            default: begin
                csr_read = 1'b0;
                csr_rd_data = '0;
                csr_rd_we = 1'b0;
                int_data_out = '0;
            end
        endcase
    end


endmodule

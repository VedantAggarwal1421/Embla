/* verilator lint_off CMPCONST */
import core_pkg::*;
import csr_pkg::*;

module csr_file (
    input logic clk,
    input logic rst,

    input logic        csr_read,
    input logic [11:0] csr_src_addr,
    input logic [11:0] csr_rd_addr,
    input logic [31:0] csr_rd_data,
    input logic        csr_rd_we,

    output logic [31:0] csr_src_data,

    input  trap_req_t        id_trap_req,
    output logic             trap_redirect_valid,
    output logic      [31:0] trap_redirect_pc
);

    logic write_allowed;
    priv_lvl_t cur_priv_lvl, req_priv_lvl;
    assign write_allowed = ~(&csr_src_addr[11:10]);
    assign req_priv_lvl  = priv_lvl_t'(csr_src_addr[9:8]);
    //assign cur_priv_lvl  = PRIV_M;

    logic trap_req;
    logic trapped;
    logic illegal;
    assign trap_req = id_trap_req.valid;

    localparam ms_mie = 3;  //M Status Interupt Enable bit
    localparam ms_mpie = 7;  //M Status previous Interrupt Enable bit
    localparam ms_mpp_h = 12;  //M Status previous priv lvl msb
    localparam ms_mpp_l = 11;  //M Status previous priv lvl lsb


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
        if (csr_read && cur_priv_lvl >= req_priv_lvl && !trap_req) begin
            case (csr_t'(csr_src_addr))
                MVENDORID: csr_src_data = mvendorid;
                MARCHID:   csr_src_data = marchid;
                MIMPID:    csr_src_data = mimpid;
                MHARTID:   csr_src_data = mhartid;

                MSTATUS: csr_src_data = mstatus;
                MISA:    csr_src_data = misa;
                MIE:     csr_src_data = mie;
                MTVEC:   csr_src_data = mtvec;

                MSCRATCH: csr_src_data = mscratch;
                MEPC:     csr_src_data = mepc;
                MCAUSE:   csr_src_data = mcause;
                MTVAL:    csr_src_data = mtval;
                MIP:      csr_src_data = mip;

                MCYCLE:   csr_src_data = mcycle[31:0];
                MINSTRET: csr_src_data = minstret[31:0];

                MCYCLEH:   csr_src_data = mcycle[63:32];
                MINSTRETH: csr_src_data = minstret[63:32];
                default:   csr_src_data = 32'b0;
            endcase
        end else csr_src_data = 32'b0;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cur_priv_lvl               <= PRIV_M;
            mstatus[ms_mie]            <= 1'b1;
            mstatus[ms_mpie]           <= 1'b1;
            mstatus[ms_mpp_h:ms_mpp_l] <= PRIV_M;
            trapped                    <= 1'b0;
            mtvec                      <= 32'h100;  //Temporary
        end
        else if (csr_rd_we && cur_priv_lvl >= req_priv_lvl && write_allowed && !trap_req) begin
            case (csr_t'(csr_rd_addr))
                MVENDORID: mvendorid <= csr_rd_data;
                MARCHID:   marchid <= csr_rd_data;
                MIMPID:    mimpid <= csr_rd_data;
                MHARTID:   mhartid <= csr_rd_data;

                MSTATUS: mstatus <= csr_rd_data;
                MISA:    misa <= csr_rd_data;
                MIE:     mie <= csr_rd_data;
                MTVEC:   mtvec <= csr_rd_data;

                MSCRATCH: mscratch <= csr_rd_data;
                MEPC:     mepc <= csr_rd_data;
                MCAUSE:   mcause <= csr_rd_data;
                MTVAL:    mtval <= csr_rd_data;
                MIP:      mip <= csr_rd_data;

                MCYCLE:   mcycle <= {mcycle[63:32], csr_rd_data};
                MINSTRET: minstret <= {minstret[63:32], csr_rd_data};

                MCYCLEH:   mcycle <= {csr_rd_data, mcycle[31:0]};
                MINSTRETH: minstret <= {csr_rd_data, minstret[31:0]};
                default:   mvendorid <= mvendorid;
            endcase
        end else if (trap_req) begin
            trapped <= 1'b1;
            mepc <= id_trap_req.pc;
            mcause <= {id_trap_req.is_interrupt, id_trap_req.tcause};
            mtval <= id_trap_req.tval;
            cur_priv_lvl <= PRIV_M;
            mstatus[ms_mie] <= 1'b0;
            mstatus[ms_mpie] <= mstatus[ms_mie];
            mstatus[ms_mpp_h:ms_mpp_l] <= cur_priv_lvl;
        end
    end

    assign trap_redirect_valid = trap_req;
    assign trap_redirect_pc = mtvec;

endmodule

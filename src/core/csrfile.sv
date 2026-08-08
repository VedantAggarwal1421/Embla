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

    input  trap_req_t         id_trap_req,
    input  sys_instr_t        sys_instr,
    input  logic              pipeline_stall,
    output logic              trap_redirect_valid,
    output logic       [31:0] trap_redirect_pc,
    output logic              csr_stall_if_id,

    //Interrupts
    input logic msip_irq,
    input logic mtip_irq,
    input logic meip_irq,

    output logic drain_pipeline,
    input logic [31:0] drain_next_pc,
    input logic pipeline_clear
);

    priv_lvl_t cur_priv_lvl, req_priv_lvl;
    assign req_priv_lvl = priv_lvl_t'(csr_src_addr[9:8]);
    //assign cur_priv_lvl  = PRIV_M;

    logic trap_req;
    logic trapped;
    logic illegal;
    assign trap_req = id_trap_req.valid;

    logic ex_sys_instr;
    assign ex_sys_instr = sys_instr.is_mret;

    localparam ms_mie = 3;  //M Status Interupt Enable bit
    localparam ms_mpie = 7;  //M Status previous Interrupt Enable bit
    localparam ms_mpp_h = 12;  //M Status previous priv lvl msb
    localparam ms_mpp_l = 11;  //M Status previous priv lvl lsb

    localparam msip = 3;
    localparam mtip = 7;
    localparam meip = 11;
    localparam msie = 3;
    localparam mtie = 7;
    localparam meie = 11;


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

    logic priv_check;
    logic read_allowed;
    logic write_allowed;
    assign priv_check = cur_priv_lvl >= req_priv_lvl;
    assign read_allowed = priv_check && !trap_req && !ex_sys_instr;
    assign write_allowed = ~(&csr_src_addr[11:10]) && priv_check && !trap_req;

    always_comb begin
        mip[msip] = msip_irq;
        mip[mtip] = mtip_irq;
        mip[meip] = meip_irq;
    end

    logic interrupt_pending;// = (mip[msip] && mie[msie]) || (mip[mtip] && mie[mtie]) || (mip[meip] && mie[meie]);
    logic [30:0] interrupt_cause;
    always_comb begin
        if (mip[meip] && mie[meie]) begin
            interrupt_pending = 1'b1;
            interrupt_cause   = INT_MACHINE_EXT;
        end else if (mip[msip] && mie[msie]) begin
            interrupt_pending = 1'b1;
            interrupt_cause   = INT_MACHINE_SOFTWARE;
        end else if (mip[mtip] && mie[mtie]) begin
            interrupt_pending = 1'b1;
            interrupt_cause   = INT_MACHINE_TIMER;
        end else begin
            interrupt_pending = 1'b0;
            interrupt_cause   = 31'd0;
        end
    end

    reg debug_irq_taken;

    always_comb begin
        if (csr_read && read_allowed) begin
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

    assign csr_stall_if_id = csr_rd_we && (ex_sys_instr || trap_req || interrupt_pending);

    logic take_exception;
    logic take_interrupt;
    logic take_system_inst;
    assign take_exception = trap_req && !csr_stall_if_id && !pipeline_stall;
    assign take_interrupt = interrupt_pending && mstatus[ms_mie] && !csr_stall_if_id && !pipeline_stall && !trapped;
    assign take_system_inst = ex_sys_instr && !csr_stall_if_id && !pipeline_stall;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cur_priv_lvl               <= PRIV_M;
            mstatus[ms_mie]            <= 1'b1;
            mstatus[ms_mpie]           <= 1'b1;
            mstatus[ms_mpp_h:ms_mpp_l] <= PRIV_M;
            trapped                    <= 1'b0;
            mtvec                      <= 32'h100;  //Temporary
            mie[msie]                  <= 1'b0;
            mie[mtie]                  <= 1'b0;
            mie[meie]                  <= 1'b0;
            debug_irq_taken            <= 1'b0;
        end else if (csr_rd_we && write_allowed) begin
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
                //MIP:      mip <= csr_rd_data;

                MCYCLE:   mcycle <= {mcycle[63:32], csr_rd_data};
                MINSTRET: minstret <= {minstret[63:32], csr_rd_data};

                MCYCLEH:   mcycle <= {csr_rd_data, mcycle[31:0]};
                MINSTRETH: minstret <= {csr_rd_data, minstret[31:0]};
                default:   mvendorid <= mvendorid;
            endcase
        end else if (take_exception) begin
            drain_pipeline <= 1'b0;
            trapped <= 1'b1;
            mepc <= id_trap_req.pc;
            mcause <= {id_trap_req.is_interrupt, id_trap_req.tcause};
            mtval <= id_trap_req.tval;
            cur_priv_lvl <= PRIV_M;
            mstatus[ms_mie] <= 1'b0;
            mstatus[ms_mpie] <= mstatus[ms_mie];
            mstatus[ms_mpp_h:ms_mpp_l] <= cur_priv_lvl;

        end else if (take_interrupt && !debug_irq_taken) begin
            if (pipeline_clear) begin
                //Take the interrupt
                debug_irq_taken <= 1'b1;
                drain_pipeline <= 1'b0;
                trapped <= 1'b1;
                mepc    <= drain_next_pc;
                mcause <= {1'b1, interrupt_cause};
                mstatus[ms_mie] <= 1'b0;
                mstatus[ms_mpie] <= mstatus[ms_mie];
                mstatus[ms_mpp_h:ms_mpp_l] <= cur_priv_lvl;
                cur_priv_lvl <= PRIV_M;
                mtval <= 32'b0;
            end else begin
                drain_pipeline <= 1'b1;
            end
        end else if (take_system_inst) begin
            if (sys_instr.is_mret) begin  //Return from trap
                trapped <= 1'b0;
                cur_priv_lvl <= priv_lvl_t'(mstatus[ms_mpp_h:ms_mpp_l]);
                mstatus[ms_mie] <= mstatus[ms_mpie];
                mstatus[ms_mpie] <= 1'b1;
                mstatus[ms_mpp_h:ms_mpp_l] <= PRIV_M;   //Needs to be updated to least supported priviliged level
            end
        end
    end

    assign trap_redirect_valid = take_exception || (take_system_inst && sys_instr.is_mret) || (take_interrupt && pipeline_clear);//(trap_req || sys_instr.is_mret) && !csr_stall_if_id && !pipeline_stall;
    // always_comb begin
    //     if (sys_instr.is_mret) begin
    //         if (csr_rd_we == 1'b1 && csr_rd_addr == MEPC) begin  //Writing to mepc
    //             trap_redirect_pc = csr_rd_data;
    //         end else begin
    //             trap_redirect_pc = mepc;
    //         end
    //     end else begin
    //         trap_redirect_pc = mtvec;
    //     end
    // end
    assign trap_redirect_pc = (sys_instr.is_mret) ? mepc : mtvec;
    // always_comb begin
    //     if (take_interrupt && pipeline_clear) trap_redirect_pc = mtvec;
    //     else if (sys_instr.is_mret) trap_redirect_pc = mepc;
    //     else trap_redirect_pc = mtvec;
    // end

endmodule

//Top level module for the RV32IMA Core. Interfaces with memory systems.
import core_pkg::*;

module core (
    input  logic        clk,
    input  logic        rst,
    //Instruction Fetch
    output logic [31:0] if_addr,        // Instruction fetch address
    output logic        if_req_valid,   // Fetch request valid
    input  logic [31:0] if_data,        // Instruction fetch data
    input  logic        if_data_valid,  // Instruction fetch data valid
    input  logic        if_stall,

    input logic debug_s2,
    output logic [31:0] debug_uart,
    output logic [31:0] debug_out,
    //Data Memory
    output logic [31:0] lsu_addr,  // Data memory address
    output logic lsu_req_valid,  // Requesting Data
    output logic [31:0] lsu_wdata,  // Data memory write data
    output logic lsu_we,  // Data memory write enable
    output logic [ 1:0] lsu_size,         // Data memory size (00=byte, 01=halfword, 10=word)
    input logic lsu_wdata_ready,  // Write completed
    input logic [31:0] lsu_rdata,  // Data memory read data
    input logic lsu_rdata_ready  // Data is ready to be read
);
    // Instruction Fetch -> Instruction Decode -> Execute -> Memory Access -> Write Back

    logic pipeline_stall;
    logic ex_pipe_stall;
    assign pipeline_stall = ex_pipe_stall;

    stall_t              stall;
    flush_t              flush;

    logic         [31:0] rd_data;
    logic         [ 4:0] rd_addr;
    logic                rd_we;

    logic                redirect_valid;
    logic         [31:0] redirect_pc;

    logic                is_branch;
    logic                is_conditional;
    logic                is_jalr;
    branch_comp_t        br_comp;
    logic                branch_redirect_valid;
    logic         [31:0] branch_redirect_pc;
    forward_sel_t        branch_a_sel;
    forward_sel_t        branch_b_sel;
    logic                branch_flush;
    //Buffering Branch Flush to account for synchronous mem.
    logic                br_flush_buff;
    always_ff @(posedge clk) br_flush_buff <= branch_flush;

    csr_in_data_t        csr_in_data;
    logic         [31:0] csr_out_data;
    trap_req_t           id_trap_req;
    logic                trap_redirect_valid;
    logic         [31:0] trap_redirect_pc;
    logic                trap_flush;
    logic                trap_flush_buff;  //Buffer for same reason as branch.
    always_ff @(posedge clk) trap_flush_buff <= trap_flush;
    assign trap_flush = trap_redirect_valid;


    if_id_t if_id_d;
    if_id_t if_id_q;

    always_comb begin
        if (trap_redirect_valid) begin
            redirect_valid = 1'b1;
            redirect_pc    = trap_redirect_pc;
        end else if (branch_redirect_valid) begin
            redirect_valid = 1'b1;
            redirect_pc    = branch_redirect_pc;
        end else begin
            redirect_valid = 1'b0;
            redirect_pc    = 32'b0;
        end
    end

    instruction_fetch if_inst (
        .clk              (clk),
        .rst              (rst),
        .if_addr          (if_addr),
        .if_req_valid     (if_req_valid),
        .if_data          (if_data),
        .if_data_valid    (if_data_valid),
        .if_stall         (pipeline_stall || stall.if_id),
        .instruction_valid(if_id_d.instruction_valid),
        .instruction      (if_id_d.instruction),
        .instruction_pc   (if_id_d.pc),
        .instruction_pc_4 (if_id_d.pc_4),
        .redirect_valid   (redirect_valid),
        .redirect_pc      (redirect_pc)
    );

    logic if_id_flush;
    assign if_id_flush = (|{branch_flush, br_flush_buff, trap_flush, trap_flush_buff}) && !pipeline_stall;
    localparam nop_instr = 32'h00000013;

    //IF/ID Pipeline Register
    always_ff @(posedge clk or posedge rst) begin
        //debug_uart <= if_id_q.instruction;
        if (rst) begin
            if_id_q <= '0;
            //debug_uart <= '0;
        end else if (if_id_flush) begin
            if_id_q.instruction_valid <= if_id_d.instruction_valid;
            if_id_q.pc                <= if_id_d.pc;
            if_id_q.instruction       <= nop_instr;
            if_id_q.pc_4              <= if_id_d.pc_4;
        end else if (!pipeline_stall && !stall.if_id) begin
            if_id_q <= if_id_d;
            //$display("Instruction : %h, PC: %h, Time: %0t", if_id_d.instruction, if_id_d.pc, $time);
        end
    end

    //Instruction Decode
    id_ex_t id_ex_d;
    id_ex_t id_ex_q;

    instruction_decode id_inst (
        .clk(clk),
        .rst(rst),
        .if_id(if_id_q),
        .rd_data(rd_data),  //These signals come from write back stage.
        .rd_addr(rd_addr),
        .rd_we(rd_we),
        .pipeline_stalled(pipeline_stall),
        .id_ex_d(id_ex_d),
        .is_branch(is_branch),
        .is_conditional(is_conditional),
        .is_jalr(is_jalr),
        .br_comp(br_comp),
        .csr_in_data(csr_in_data),
        .id_trap_req(id_trap_req)
    );

    //Branch Unit
    logic [31:0] branch_op_a;
    logic [31:0] branch_op_b;
    always_comb begin
        case (branch_a_sel)
            FWD_REG: branch_op_a = id_ex_d.rs1_data;
            FWD_MEM: branch_op_a = ex_mem_q.alu_res;
            FWD_WB:  branch_op_a = rd_data;
            default: branch_op_a = id_ex_d.rs1_data;
        endcase
    end
    always_comb begin
        case (branch_b_sel)
            FWD_REG: branch_op_b = id_ex_d.rs2_data;
            FWD_MEM: branch_op_b = ex_mem_q.alu_res;
            FWD_WB:  branch_op_b = rd_data;
            default: branch_op_b = id_ex_d.rs2_data;
        endcase
    end
    branch_unit branch_inst (
        .is_branch(is_branch),
        .is_conditional(is_conditional),
        .is_jalr(is_jalr),
        .is_stalled(stall.if_id),
        .branch_pc(if_id_q.pc),
        .branch_offset(id_ex_d.immediate),
        .rs1(branch_op_a),
        .rs2(branch_op_b),
        .br_comp(br_comp),
        .redirect_valid(branch_redirect_valid),
        .redirect_pc(branch_redirect_pc),
        .branch_flush(branch_flush)
    );

    //ID/EX Pipeline register
    always_ff @(posedge clk or posedge rst) begin
        //debug_uart <= id_ex_q.immediate;
        if (rst) begin
            id_ex_q <= '0;
            //debug_uart <= '0;
        end else if ((flush.id_ex || trap_flush) && !pipeline_stall) begin
            id_ex_q <= '0;
        end else if (!pipeline_stall) begin
            id_ex_q <= id_ex_d;
            //$display("DATA1: %h, DATA2: %h, Time: %0t", id_ex_d.rs1_data, id_ex_d.rs2_data, $time);
        end
    end

    //Execute Stage

    ex_mem_t ex_mem_d;
    ex_mem_t ex_mem_q;
    mem_in_data_t mem_in_data;

    forward_sel_t fwd_a_sel;
    forward_sel_t fwd_b_sel;

    execute execute_inst (
        .clk          (clk),
        .rst          (rst),
        .id_ex        (id_ex_q),
        .fwd_a_sel    (fwd_a_sel),
        .fwd_b_sel    (fwd_b_sel),
        .fwd_mem_data (ex_mem_q.alu_res),
        .fwd_wb_data  (rd_data),
        .csr_out_data (csr_out_data),
        .ex_pipe_stall(ex_pipe_stall),
        .ex_mem_d     (ex_mem_d),
        .mem_in_data  (mem_in_data)
    );

    assign lsu_addr      = mem_in_data.mem_addr;
    assign lsu_req_valid = mem_in_data.mem_req_valid;
    assign lsu_wdata     = mem_in_data.mem_wdata;
    assign lsu_we        = mem_in_data.mem_we;
    assign lsu_size      = mem_in_data.mem_size;

    //EX/MEM Pipeline Register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ex_mem_q <= '0;
            //debug_out <= '0;
        end else if (!pipeline_stall) begin
            ex_mem_q <= ex_mem_d;
            //debug_out <= ex_mem_d.alu_res;
            //$display("ALU RESULT: %h, TIME: %0t", ex_mem_q.alu_res, $time);
        end
    end

    //Memory Access Stage
    mem_wb_t mem_wb_d;
    mem_wb_t mem_wb_q;
    logic mem_stall;

    memory_access mem_inst (
        .clk(clk),
        .rst(rst),
        .mem_wdata_ready(lsu_wdata_ready),
        .mem_rdata(lsu_rdata),
        .mem_rdata_ready(lsu_rdata_ready),
        .mem_stall(mem_stall),
        .ex_mem(ex_mem_q),
        .mem_wb_d(mem_wb_d)
    );

    //MEM/WB Pipeline Register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_wb_q   <= '0;
            debug_out  <= '0;
            debug_uart <= '0;
        end else begin
            debug_uart <= rd_data;
            if (!pipeline_stall) begin
                mem_wb_q <= mem_wb_d;
                //debug_out <= mem_rdata;
                //$display("MEM READ: %h, TIME: %0t, Stall: %b", mem_wb_q.mem_rdata, $time, mem_stall);
            end
        end
    end

    //Write Back Stage

    write_back wb_inst (
        .clk(clk),
        .rst(rst),
        .mem_wb(mem_wb_q),
        .rd_data(rd_data),
        .rd_addr(rd_addr),
        .rd_we(rd_we)
    );

    //Hazard Unit
    hazard_unit hazard_inst (
        .mem_rd_addr(ex_mem_q.rd_addr),
        .mem_reg_write(ex_mem_q.reg_write),
        .mem_res_src(ex_mem_q.res_src),
        .wb_rd_addr(mem_wb_q.rd_addr),
        .wb_reg_write(mem_wb_q.reg_write),
        .ex_rs1_addr(id_ex_q.rs1_addr),
        .ex_rs2_addr(id_ex_q.rs2_addr),
        .ex_res_src(id_ex_q.res_src),
        .ex_rd_addr(id_ex_q.rd_addr),
        .id_rs1_addr(id_ex_d.rs1_addr),
        .id_rs2_addr(id_ex_d.rs2_addr),
        .is_conditional(is_conditional),
        .is_jalr(is_jalr),
        .fwd_a_sel(fwd_a_sel),
        .fwd_b_sel(fwd_b_sel),
        .branch_a_sel(branch_a_sel),
        .branch_b_sel(branch_b_sel),
        .stall(stall),
        .flush(flush)
    );


    //CSR Unit
    logic [31:0] fwd_integer_reg;
    always_comb begin
        fwd_integer_reg = id_ex_q.rs1_data;
        case (fwd_a_sel)
            FWD_REG: fwd_integer_reg = id_ex_q.rs1_data;
            FWD_MEM: fwd_integer_reg = ex_mem_q.alu_res;
            FWD_WB:  fwd_integer_reg = rd_data;
            default: fwd_integer_reg = id_ex_q.rs1_data;
        endcase
    end

    csr_unit csr_unit_inst (
        .clk(clk),
        .rst(rst),
        .csr_instr_valid(csr_in_data.valid),
        .csr_instr(csr_in_data.instr),
        .csr_src_addr(csr_in_data.src_addr),
        .immediate_data_in(csr_in_data.immediate),
        .int_rs1_addr(csr_in_data.rs1_addr),
        .int_rd_addr(csr_in_data.rd_addr),
        .int_data_in(fwd_integer_reg),
        .id_trap_req(id_trap_req),
        .trap_redirect_valid(trap_redirect_valid),
        .trap_redirect_pc(trap_redirect_pc),
        .int_data_out(csr_out_data)
    );

endmodule

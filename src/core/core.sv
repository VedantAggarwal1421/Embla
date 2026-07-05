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

    output logic [31:0] debug_uart,
    output logic [31:0] debug_out,
    //Data Memory
    output logic [31:0] mem_addr,         // Data memory address
    output logic        mem_req_valid,    // Requesting Data
    output logic [31:0] mem_wdata,        // Data memory write data
    output logic        mem_we,           // Data memory write enable
    output logic [ 1:0] mem_size,         // Data memory size (00=byte, 01=halfword, 10=word)
    input  logic        mem_wdata_ready,  // Write completed
    input  logic [31:0] mem_rdata,        // Data memory read data
    input  logic        mem_rdata_ready   // Data is ready to be read
);
    // Instruction Fetch -> Instruction Decode -> Execute -> Memory Access -> Write Back

    logic   [31:0] rd_data;
    logic   [ 4:0] rd_addr;
    logic          rd_we;


    if_id_t        if_id_d;
    if_id_t        if_id_q;

    instruction_fetch if_inst (
        .clk              (clk),
        .rst              (rst),
        .if_addr          (if_addr),
        .if_req_valid     (if_req_valid),
        .if_data          (if_data),
        .if_data_valid    (if_data_valid),
        .if_stall         (if_stall),
        .instruction      (if_id_d.instruction),
        .instruction_pc   (if_id_d.pc),
        .instruction_valid(if_id_d.valid)
    );

    //IF/ID Pipeline Register
    always_ff @(posedge clk or posedge rst) begin
        if_id_q.valid <= 1'b0;  // Default to not valid
        if (rst) begin
            if_id_q <= '0;
            //debug_out <= '0;
        end else if (if_id_d.valid == 1'b1) begin
            if_id_q <= if_id_d;
            //debug_out <= if_id_d;
            //$display("Instruction : %h, PC: %h, Time: %0t", if_id_d.instruction, if_id_d.pc, $time);
        end
    end

    //Instruction Decode
    id_ex_t id_ex_d;
    id_ex_t id_ex_q;

    instruction_decode id_inst (
        .clk    (clk),
        .rst    (rst),
        .if_id  (if_id_q),
        .rd_data(rd_data),  //These signals come from write back stage.
        .rd_addr(rd_addr),
        .rd_we  (rd_we),
        .id_ex_d(id_ex_d)
    );

    //ID/EX Pipeline register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            id_ex_q <= '0;
            //debug_out <= '0;
        end else begin
            id_ex_q <= id_ex_d;
            //debug_out <= id_ex_d.immediate;
            //$display("DATA1: %h, DATA2: %h, Time: %0t", id_ex_d.rs1_data, id_ex_d.rs2_data, $time);
        end
    end


    //Execute Stage

    ex_mem_t ex_mem_d;
    ex_mem_t ex_mem_q;
    mem_in_data_t mem_in_data;

    execute execute_inst (
        .clk        (clk),
        .rst        (rst),
        .id_ex      (id_ex_q),
        .ex_mem_d   (ex_mem_d),
        .mem_in_data(mem_in_data)
    );

    assign mem_addr      = mem_in_data.mem_addr;
    assign mem_req_valid = mem_in_data.mem_req_valid;
    assign mem_wdata     = mem_in_data.mem_wdata;
    assign mem_we        = mem_in_data.mem_we;
    assign mem_size      = mem_in_data.mem_size;

    //EX/MEM Pipeline Register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ex_mem_q <= '0;
            //debug_out <= '0;
        end else begin
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
        .mem_wdata_ready(mem_wdata_ready),
        .mem_rdata(mem_rdata),
        .mem_rdata_ready(mem_rdata_ready),
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
            mem_wb_q   <= mem_wb_d;
            debug_out  <= mem_wb_d.mem_rdata;
            debug_uart <= mem_wb_d.mem_rdata;
            //$display("MEM READ: %h, TIME: %0t, Stall: %b", mem_wb_q.mem_rdata, $time, mem_stall);
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
endmodule

module csr_unit (  //Manages the csr subsystem
    input  logic        clk,
    input  logic        rst,
    input  logic        csr_instr_valid,
    input  logic [ 2:0] csr_instr,
    input  logic [11:0] csr_src_addr,
    input  logic [31:0] int_data_in,
    output logic [31:0] int_data_out
);

    logic [2:0] csr_instr_q;
    logic [11:0] csr_src_addr_q;
    logic [31:0] integer_reg_q;
    logic csr_instr_valid_q;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            csr_instr_q <= '0;
            csr_src_addr_q <= '0;
            integer_reg_q <= '0;
        end else begin
            csr_instr_valid_q <= csr_instr_valid;
            csr_instr_q <= csr_instr;
            csr_src_addr_q <= csr_src_addr;
            integer_reg_q <= integer_reg;
        end
    end

    logic [31:0] csr_src_data;
    logic [31:0] csr_rd_data;
    logic        csr_rd_we;

    csr_file cf_inst (
        .clk(clk),
        .rst(rst),
        .csr_read(csr_instr_valid_q),
        .csr_src_addr(csr_src_addr_q),
        .csr_rd_addr(csr_src_addr_q),
        .csr_rd_data(),
        .csr_rd_we(),
        .csr_src_data(csr_src_data)
    );

    //Operation



endmodule

module csr_file (
    input logic clk,
    input logic rst,

    input  logic [11:0] csr_src_addr,
    input  logic [11:0] csr_rd_addr,
    input  logic [31:0] csr_rd_data,
    input  logic        csr_rd_we,
    output logic [31:0] csr_src_data
);

    logic [31:0] csr_file[4095:0];
    assign csr_src_data = (csr_rd_we && (csr_rd_addr == csr_src_addr))? csr_rd_data : csr_file[csr_src_addr];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < 4096; i++) begin
                csr_file[i] <= 32'b0;
            end
        end else if (csr_rd_we) begin
            csr_file[csr_rd_addr] <= csr_rd_data;
            $display("WRITE CSR: %h, REG CSR: %h, TIME: %0t", csr_rd_data,
                     csr_rd_addr, $time);
        end
    end

endmodule

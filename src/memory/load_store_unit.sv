module load_store_unit(
    input   logic        clk,
    input   logic        rst,

    //Interface with the core
    input   logic [31:0] lsu_addr,         // Data memory address
    input   logic        lsu_req_valid,    // Requesting Data
    input   logic [31:0] lsu_wdata,        // Data memory write data
    input   logic        lsu_we,           // Data memory write enable
    input   logic [ 1:0] lsu_size,         // Data memory size (00=byte, 01=halfword, 10=word)
    output  logic        lsu_wdata_ready,  // Write completed
    output  logic [31:0] lsu_rdata,        // Data memory read data
    output  logic        lsu_rdata_ready,   // Data is ready to be read

    //Interface with data memory
    output   logic [31:0] dmem_addr,         
    output   logic        dmem_req_valid,    
    output   logic [31:0] dmem_wdata,        
    output   logic        dmem_we,           
    output   logic [3:0]  dmem_byte_mask,    
    input    logic        dmem_wdata_ready,  
    input    logic [31:0] dmem_rdata,        
    input    logic        dmem_rdata_ready   
);

    logic [31:0] formatted_store;
    logic [ 3:0] byte_mask;

    assign dmem_addr = lsu_addr;
    assign dmem_req_valid = lsu_req_valid;
    assign dmem_wdata = formatted_store;
    assign dmem_we = lsu_we;
    assign dmem_byte_mask = byte_mask;
    assign lsu_wdata_ready = dmem_wdata_ready;
    assign lsu_rdata = dmem_rdata;
    assign lsu_rdata_ready = dmem_rdata_ready;

    logic [1:0] addr2lsb;
    assign addr2lsb = lsu_addr[1:0];

    always_comb begin
        case(lsu_size)
            2'b00: begin
                formatted_store = lsu_wdata << 8*addr2lsb;
                byte_mask = 4'b0001 << addr2lsb;
            end
            2'b01: begin
                formatted_store = lsu_wdata << 16*addr2lsb[1];
                byte_mask = 4'b0011 << 2*addr2lsb[1];
            end
            2'b10: begin
                formatted_store = lsu_wdata;
                byte_mask = 4'b1111;
            end
            default: begin
                formatted_store = lsu_wdata;
                byte_mask = 4'b1111;
            end
        endcase
    end


endmodule
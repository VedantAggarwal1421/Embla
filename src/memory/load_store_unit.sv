module load_store_unit (
    input logic clk,
    input logic rst,

    //Interface with the core
    input  logic [31:0] lsu_addr,         // Data memory address
    input  logic        lsu_req_valid,    // Requesting Data
    input  logic [31:0] lsu_wdata,        // Data memory write data
    input  logic        lsu_we,           // Data memory write enable
    input  logic [ 1:0] lsu_size,         // Data memory size (00=byte, 01=halfword, 10=word)
    output logic        lsu_wdata_ready,  // Write completed
    output logic [31:0] lsu_rdata,        // Data memory read data
    output logic        lsu_rdata_ready,  // Data is ready to be read

    //Interface with data memory
    output logic [31:0] dmem_addr,
    output logic        dmem_req_valid,
    output logic [31:0] dmem_wdata,
    output logic        dmem_we,
    output logic [ 3:0] dmem_byte_mask,
    input  logic        dmem_wdata_ready,
    input  logic [31:0] dmem_rdata,
    input  logic        dmem_rdata_ready,

    //Uart Interface
    input  logic        uart_busy,
    output logic [31:0] uart_out_data,
    output logic        uart_en
);

    //Memory Map
    /*
        0x00000000  Boot ROM
        0x02000000  CLINT
        0x0C000000  PLIC
        0x10000000  UART
        0x20000000  QSPI Flash
        0x80000000  DRAM
    */

    always_comb begin
        lsu_wdata_ready = 0;
        lsu_rdata_ready = 0;
        dmem_req_valid  = 0;
        dmem_we         = 0;
        uart_en         = 0;

        if (lsu_addr == 32'h10000000) begin  //Uart
            uart_en         = lsu_we;  //Enable Uart
            lsu_wdata_ready = ~uart_busy;  //Stall if uart is busy , otherwise continue
        end else begin
            dmem_req_valid  = lsu_req_valid;
            dmem_we         = lsu_we;
            lsu_rdata_ready = dmem_rdata_ready;
            lsu_wdata_ready = dmem_wdata_ready;
        end
    end



    logic [31:0] formatted_store;
    logic [ 3:0] byte_mask;

    assign dmem_addr = lsu_addr;
    assign dmem_wdata = formatted_store;
    assign dmem_byte_mask = byte_mask;
    assign lsu_rdata = dmem_rdata;

    assign uart_out_data = formatted_store;

    logic [1:0] addr2lsb;
    assign addr2lsb = lsu_addr[1:0];

    always_comb begin
        case (lsu_size)
            2'b00: begin
                formatted_store = lsu_wdata << 8 * addr2lsb;
                byte_mask = 4'b0001 << addr2lsb;
            end
            2'b01: begin
                formatted_store = lsu_wdata << 16 * addr2lsb[1];
                byte_mask = 4'b0011 << 2 * addr2lsb[1];
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

`timescale 1ns / 1ns

module embla_tb;
    logic clk;
    logic rst;
    logic uart_tx;
    logic uart_rx;
    logic led;
    logic led2;
    logic s2;

    initial begin
        clk = 0;
        rst = 0;
        uart_tx = 1;
        uart_rx = 1;
        forever #5 clk = ~clk;
    end

    embla DUT (
        .clk(clk),
        .rst(rst),
        .uart_tx(uart_tx),
        .uart_rx(uart_rx),
        .led(led),
        .led2(led2),
        .s2(s2)
    );

    initial begin
        // Reset the system
        $dumpfile("obj_dir/wave.vcd");
        $dumpvars(0, embla_tb);

        rst = 1;
        #20;
        rst = 0;

        // Wait for some time to observe the behavior
        #2000;

        // Finish the simulation
        $finish;
    end
endmodule

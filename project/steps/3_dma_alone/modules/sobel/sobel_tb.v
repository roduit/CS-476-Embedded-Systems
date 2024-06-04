`timescale 1ns/1ns

`define WAITHALFCYCLE #5;
`define WAITCYCLE #10;
`define WAIT2CYCLES repeat(2) @(posedge clk);

module sobel_tb;

    // Inputs
    reg clk = 0;
    reg reset = 0;
    reg start = 0;
    
    // Create a test image
    reg [7:0] pixel0 = 200;
    reg [7:0] pixel1 = 102;
    reg [7:8] pixel2 = 103;
    reg [7:0] pixel3 = 244;
    reg [7:0] pixel4 = 155;
    reg [7:0] pixel5 = 166;
    reg [7:0] pixel6 = 70;
    reg [7:0] pixel7 = 80;
    reg [7:0] pixel8 = 90;

    // Outputs
    wire [31:0] edge_data;

    reg [7:0] threshold = 128;
    reg [31:0] valueA;
    reg [31:0] valueB;

    // Instantiate the Sobel module
    edge_detection #(.customInstructionId(8'h00)) DUT (
        .start(start),
        .clock(clk),
        .reset(reset),
        .valueA(valueA),
        .valueB(valueB),
        .ciN(8'h00),
        .done(),
        .result(edge_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Reset generation
    initial begin
        $dumpfile("sobel.vcd");
        $dumpvars(0, sobel_tb); // Dump all variables in sobel_tb
        start = 1'b0;
        reset = 1'b1;
        `WAIT2CYCLES;
        reset = 1'b0;
        `WAITCYCLE;

    // Stimulus generation
        // Set the image
        start = 1'b1;
        valueB = 1;
        valueA = {pixel3, pixel2, pixel1, pixel0};
        `WAITCYCLE;
        start = 1'b0;
        #10;
        start = 1'b1;
        valueB = 2 + (threshold << 16) + (pixel8 << 8);
        valueA = {pixel7, pixel6, pixel5, pixel4};
        `WAITCYCLE;
        start = 1'b0;
        #10;

        $display("Edge data: %0d", edge_data);

        // Finish simulation
        $finish;
    end

endmodule

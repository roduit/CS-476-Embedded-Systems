`timescale 1ns/1ns

`define WAITHALFCYCLE #5;
`define WAITCYCLE #10;
`define WAIT2CYCLES repeat(2) @(posedge clk);

module grayscale_conv_tb;

    // Inputs
    reg clk = 0;
    reg reset = 0;
    reg start = 0;

    // Outputs
    wire [31:0] conversion;
    wire done;

    reg [7:0] pixel1_gray = 8'h23;
    reg [7:0] pixel2_gray = 8'h43;

    reg [31:0] valueA;
    reg [31:0] valueB;

    // Instantiate the grayscale_conv module
    grayscale_conv #(.customInstructionId(8'h00)) DUT (
        .start(start),
        .clock(clk),
        .reset(reset),
        .valueA(valueA),
        .valueB(valueB),
        .ciN(8'h00),
        .done(done),
        .result(conversion)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Reset generation
    initial begin
        $dumpfile("grayscale_conv.vcd");
        $dumpvars(0, DUT);
        start = 1'b0;
        reset = 1'b1;
        `WAIT2CYCLES;
        reset = 1'b0;
        start = 1'b1;
        valueA = {16'h00,pixel2_gray, pixel1_gray};
        valueB = 32'h00000000;
        `WAITCYCLE;
        #10;
        $display("Conversion : %0h", conversion);

        // Finish simulation
        $finish;
    end

endmodule

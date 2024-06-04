`timescale 1ns/1ns

module sobel_tb;

    // Inputs
    reg clk;
    reg reset;
    
    // Create a test image
    reg [7:0] pixel0 = 200;
    reg [7:0] pixel1 = 102;
    reg [7:0] pixel2 = 103;
    reg [7:0] pixel3 = 244;
    reg [7:0] pixel4 = 155;
    reg [7:0] pixel5 = 166;
    reg [7:0] pixel6 = 70;
    reg [7:0] pixel7 = 80;
    reg [7:0] pixel8 = 90;

    // Outputs
    wire [7:0] edge_data;

    reg [7:0] threshold = 128;

    // Instantiate the Sobel module
    sobel sobel_inst (
        .pixel0(pixel0),
        .pixel1(pixel1),
        .pixel2(pixel2),
        .pixel3(pixel3),
        .pixel4(pixel4),
        .pixel5(pixel5),
        .pixel6(pixel6),
        .pixel7(pixel7),
        .pixel8(pixel8),
        .threshold(threshold),
        .edge_val(edge_data)

    );

    // Clock generation
    always #5 clk = ~clk;

    // Reset generation
    initial begin
        reset = 1;
        #10 reset = 0;
    end

    // Stimulus generation
    initial begin
        // Provide test image data
        


        // Wait for a few clock cycles
        #20;

        // Test 1

        // Display the edge data
        $display("Edge data: %0d", edge_data);

        // Test 2
        pixel1 = 1;
        pixel0 = 2;
        pixel2 = 3;
        pixel3 = 4;
        pixel4 = 5;
        pixel5 = 6;
        pixel6 = 7;
        pixel7 = 8;
        pixel8 = 9;

        // Wait for a few clock cycles
        #10;
        $display("Edge data: %0d", edge_data);

        // Finish simulation
        $finish;
    end

endmodule
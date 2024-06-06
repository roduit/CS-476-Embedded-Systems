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
    reg [7:0] pixel [23:0];
    reg [31:0] line [5:0];

    // Outputs
    wire [31:0] edge_data;
    reg [31:0] result;
    reg signed [31:0] valueX;
    reg signed [31:0] valueY;

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

    task compute_sobel;
        input [31:0] px_line0, px_line1, px_line2, px_line3, px_line4, px_line5;
        // input [31:0] result;
        // input signed [31:0] valueX, valueY;
        input [7:0] threshold;
        input reverse;
        begin

        start = 1'b1;
        valueB = 7;
        `WAITCYCLE;
        start = 1'b0;
        `WAITCYCLE;
        
        start = 1'b1;
        valueB = 0;
        valueA = px_line0;
        `WAITCYCLE;
        start = 1'b0;
        `WAITCYCLE;
        
        start = 1'b1;
        valueB = 1;
        valueA = px_line1;
        `WAITCYCLE;
        start = 1'b0;
        `WAITCYCLE;
        

        start = 1'b1;
        valueB = 2;
        valueA = px_line2;
        `WAITCYCLE;
        start = 1'b0;
        `WAITCYCLE;
        

        start = 1'b1;
        valueB = 3;
        valueA = px_line3;
        `WAITCYCLE;
        start = 1'b0;
        `WAITCYCLE;

        start = 1'b1;
        valueB = 4;
        valueA = px_line4;
        `WAITCYCLE;
        start = 1'b0;
        `WAITCYCLE;
        

        start = 1'b1;
        valueB = {14'd0, 1'b1, reverse, threshold, 8'd5};
        valueA = px_line5;
        `WAITCYCLE;
        `WAITCYCLE;
        start = 1'b0;
        while (!DUT.done) begin
            `WAITCYCLE;
        end
        
        $display("");
        $display("Line 0: \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m", px_line0[7:0], px_line0[15:8], px_line0[23:16], px_line0[31:24]);
        $display("Line 1: \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m", px_line1[7:0], px_line1[15:8], px_line1[23:16], px_line1[31:24]);
        $display("Line 2: \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m", px_line2[7:0], px_line2[15:8], px_line2[23:16], px_line2[31:24]);
        $display("Line 3: \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m", px_line3[7:0], px_line3[15:8], px_line3[23:16], px_line3[31:24]);
        $display("Line 4: \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m", px_line4[7:0], px_line4[15:8], px_line4[23:16], px_line4[31:24]);
        $display("Line 5: \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m", px_line5[7:0], px_line5[15:8], px_line5[23:16], px_line5[31:24]);
        $display("");
        $display("Threshold: \033[34m%0d\033[0m", DUT.threshold);
        $display("");
        $display("Shift Register : \033[34m%1b\033[0m", edge_data);
        // $display("Result 2 : \033[34m%0d\033[0m", edge_data[15:8]);
        // $display("Result 3 : \033[34m%0d\033[0m", edge_data[23:16]);
        // $display("Result 4 : \033[34m%0d\033[0m", edge_data[31:24]);
        // $display("Gx   : \033[34m%0d\033[0m, \tValueX: \033[34m%0d\033[0m", DUT.sobel_module.Gx, valueX);
        // $display("Gy   : \033[34m%0d\033[0m, \tValueY: \033[34m%0d\033[0m", DUT.sobel_module.Gy, valueY);

        // // display the pixel values inside and outside the module
        // $display("Pixel0: \033[34m%0d\033[0m, \tPixel0_sob: \033[34m%0d\033[0m", pixel0, DUT.sobel_module.pixel0);
        // $display("Pixel1: \033[34m%0d\033[0m, \tPixel1_sob: \033[34m%0d\033[0m", pixel1, DUT.sobel_module.pixel1);
        // $display("Pixel2: \033[34m%0d\033[0m, \tPixel2_sob: \033[34m%0d\033[0m", pixel2, DUT.sobel_module.pixel2);
        // $display("Pixel3: \033[34m%0d\033[0m, \tPixel3_sob: \033[34m%0d\033[0m", pixel3, DUT.sobel_module.pixel3);
        // $display("Pixel4: \033[34m%0d\033[0m, \tPixel4_sob: \033[34m%0d\033[0m", pixel4, DUT.sobel_module.pixel4);
        // $display("Pixel5: \033[34m%0d\033[0m, \tPixel5_sob: \033[34m%0d\033[0m", pixel5, DUT.sobel_module.pixel5);
        // $display("Pixel6: \033[34m%0d\033[0m, \tPixel6_sob: \033[34m%0d\033[0m", pixel6, DUT.sobel_module.pixel6);
        // $display("Pixel7: \033[34m%0d\033[0m, \tPixel7_sob: \033[34m%0d\033[0m", pixel7, DUT.sobel_module.pixel7);
        // $display("Pixel8: \033[34m%0d\033[0m, \tPixel8_sob: \033[34m%0d\033[0m", pixel8, DUT.sobel_module.pixel8);

        // // display the threshold value inside and outside the module
        // $display("Thresh: \033[34m%0d\033[0m, \tThresh_sob: \033[34m%0d\033[0m", threshold, DUT.sobel_module.threshold);
    

        $display("");

        end
    endtask

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

        // Set the threshold
        threshold = 128;
        valueB = 6;
        valueA = threshold;
        start = 1'b1;
        `WAITCYCLE;
        start = 1'b0;

        line[0] = 32'h20202020;
        line[1] = 32'h20212220;
        line[2] = 32'h25202020;
        line[3] = 32'h21217121;
        line[4] = 32'h20212121;
        line[5] = 32'h20202120;

        compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold, 0);
        compute_sobel(32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, threshold, 0);
        compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold, 0);
        compute_sobel(32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, threshold, 0);
        compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold, 0);
        compute_sobel(32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, threshold, 0);
        compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold, 0);
        compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold, 0);
        // compute_sobel(32'd0, 32'd0, 32'd0, 32'd0, 32'd0, 32'd0, threshold, 0);
        //compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold, 0);

        // line[0] = 32'h000000ff;
        // line[1] = 32'h00000000;
        // line[2] = 32'h00000000;
        // line[3] = 32'h00000000;
        // line[4] = 32'h00000000;
        // line[5] = 32'h00000000;

        // compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold, 0);

        // line[0] = 32'h00000000;
        // line[1] = 32'h000000ff;
        // line[2] = 32'h00000000;
        // line[3] = 32'h00000000;
        // line[4] = 32'h00000000;
        // line[5] = 32'h00000000;
        // compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold, 0);

        // Finish simulation
        $finish;
    end

endmodule

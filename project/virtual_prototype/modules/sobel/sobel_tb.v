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
        valueB = {15'd0, reverse, threshold, 8'd5};
        valueA = px_line5;
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
        $display("Result 1 : \033[34m%0d\033[0m", edge_data[7:0]);
        $display("Result 2 : \033[34m%0d\033[0m", edge_data[15:8]);
        $display("Result 3 : \033[34m%0d\033[0m", edge_data[23:16]);
        $display("Result 4 : \033[34m%0d\033[0m", edge_data[31:24]);
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

        // Test 1
        // pixel[0] = 8'h0A;
        // pixel[1] = 8'hFF;
        // pixel[2] = 8'hEF;
        // pixel[3] = 8'hEE;
        // pixel[4] = 8'h00;
        // pixel[5] = 8'h00;
        // pixel[6] = 8'h02;
        // pixel[7] = 8'h05;
        // pixel[8] = 8'h00;
        // pixel[9] = 8'hFF;
        // pixel[10] = 8'hFF;
        // pixel[11] = 8'hFF;
        // pixel[12] = 8'h00;
        // pixel[13] = 8'h00;
        // pixel[14] = 8'h00;
        // pixel[15] = 8'h00;
        // pixel[16] = 8'h28;
        // pixel[17] = 8'h00;
        // pixel[18] =8'h00;
        // pixel[19] =8'h00;
        // pixel[20] = 8'h00;
        // pixel[21] = 8'h00;
        // pixel[22] = 8'h00;
        // pixel[23] = 8'h00;

        // line[0] = 32'h8c652f85;
        // line[1] = 32'h9c6440bb;
        // line[2] = 32'hfa4391b4;
        // line[3] = 32'hd916909e;
        // line[4] = 32'h4285b377;
        // line[5] = 32'h6e848536;

        // compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold, 0);
        //compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold, 1);

        line[0] = 32'haa652f85;
        line[1] = 32'h4285b377;
        line[2] = 32'he13dd277;
        line[3] = 32'hdddaaaff;
        line[4] = 32'h1313223a;
        line[5] = 32'h983489ab;

        compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold, 1);

        // line[0] = 32'h5d579691;
        // line[1] = 32'h807b9fa1;
        // line[2] = 32'h25ba9db8;
        // line[3] = 32'hdc15d5d7;
        // line[4] = 32'h4a1c8cc2;
        // line[5] = 32'ha956812c;

        // compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold);

        // line[0] = 32'hfe90faac;
        // line[1] = 32'hdc5ffcda;
        // line[2] = 32'h9bc38e5d;
        // line[3] = 32'hc6a315f2;
        // line[4] = 32'h87472cb4;
        // line[5] = 32'hd1422528;

        // compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold);

        

        // Finish simulation
        $finish;
    end

endmodule

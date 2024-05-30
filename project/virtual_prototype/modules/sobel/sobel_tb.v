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
        begin
        
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
        valueB = {16'd0, threshold, 8'd5};
        valueA = px_line5;
        `WAITCYCLE;
        start = 1'b0;
        while (!DUT.done) begin
            `WAITCYCLE;
        end
        

        $display("Line 0: \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m", px_line0[7:0], px_line0[15:8], px_line0[23:16], px_line0[31:24]);
        $display("Line 1: \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m", px_line1[7:0], px_line1[15:8], px_line1[23:16], px_line1[31:24]);
        $display("Line 2: \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m", px_line2[7:0], px_line2[15:8], px_line2[23:16], px_line2[31:24]);
        $display("Line 3: \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m", px_line3[7:0], px_line3[15:8], px_line3[23:16], px_line3[31:24]);
        $display("Line 4: \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m", px_line4[7:0], px_line4[15:8], px_line4[23:16], px_line4[31:24]);
        $display("Line 5: \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m, \033[34m%0d\033[0m", px_line5[7:0], px_line5[15:8], px_line5[23:16], px_line5[31:24]);
        $display("Threshold: \033[34m%0d\033[0m", DUT.threshold);
        $display("Result 1 : \033[34m%0d\033[0m", edge_data[7:0]);
        $display("Result 2 : \033[34m%0d\033[0m", edge_data[15:8]);
        $display("Result 3 : \033[34m%0d\033[0m", edge_data[23:16]);
        $display("Result 4 : \033[34m%0d\033[0m", edge_data[31:24]);
    

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
        pixel[0] = 200;
        pixel[1] = 102;
        pixel[2] = 103;
        pixel[3] = 100;
        pixel[4] = 123;
        pixel[5] = 210;
        pixel[6] = 15;
        pixel[7] = 67;
        pixel[8] = 244;
        pixel[9] = 155;
        pixel[10] = 166;
        pixel[11] = 200;
        pixel[12] = 123;
        pixel[13] = 120;
        pixel[14] = 54;
        pixel[15] = 32;
        pixel[16] = 70;
        pixel[17] = 80;
        pixel[18] = 90;
        pixel[19] = 100;
        pixel[20] = 123;
        pixel[21] = 60;
        pixel[22] = 12;
        pixel[23] = 230;

        line[0] = {pixel[3], pixel[2], pixel[1], pixel[0]};
        line[1] = {pixel[7], pixel[6], pixel[5], pixel[4]};
        line[2] = {pixel[11], pixel[10], pixel[9], pixel[8]};
        line[3] = {pixel[15], pixel[14], pixel[13], pixel[12]};
        line[4] = {pixel[19], pixel[18], pixel[17], pixel[16]};
        line[5] = {pixel[23], pixel[22], pixel[21], pixel[20]};

        compute_sobel(line[0], line[1], line[2], line[3], line[4], line[5], threshold);

        

        // Finish simulation
        $finish;
    end

endmodule

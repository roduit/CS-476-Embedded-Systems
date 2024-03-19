`timescale 1ps/1ps // set the time-units for simulation

module rgb565GrayscaleIse_tb;

    reg start, clock;
    reg [7:0] ciN;
    reg [31:0] valueA = 32'h00000000;
    wire [31:0] result;

    initial begin
        clock = 1'b0; // set the initial values
        repeat (4) #5 clock = ~clock; // generate 2 clock periods
        forever #5 clock = ~clock; // generate a clock with a period of 10 time-units
    end

    // instantiate the unit under test (UUT)
    rgb565GrayscaleIse #(.customInstructionId(8'h0B)) DUT (
        .start(start), 
        .valueA(valueA), 
        .iseId(ciN),
        .done(), 
        .result(result)
    );

    initial begin

        // Start the conversion
        start = 1'b1;
        valueA = 32'd33296;
        ciN = 8'h0B;
        @(negedge clock); /* wait for the reset period to end */
        repeat(2) @(negedge clock); /* wait for 2 clock cycles */
        $display("r = 16, g = 16, b = 16 ==> q = %d, theretical = 16",result);
        start = 1'b0;
        valueA = 32'h00000000;
        repeat(2) @(negedge clock); /* wait for 2 clock cycles */


        // Start the conversion
        start = 1'b1;
        valueA = 32'd20980;
        ciN = 8'h0B;
        @(negedge clock); /* wait for the reset period to end */
        repeat(2) @(negedge clock); /* wait for 2 clock cycles */
        $display("r = 10, g = 15, b = 20 ==> q =%d, theretical = 14",result);
        start = 1'b0;
        valueA = 32'h00000000;
        repeat(2) @(negedge clock); /* wait for 2 clock cycles */


        // Start the conversion
        start = 1'b1;
        valueA = 32'd64511;
        ciN = 8'h0B;
        @(negedge clock); /* wait for the reset period to end */
        repeat(2) @(negedge clock); /* wait for 2 clock cycles */
        $display("r = 31, g = 31, b = 31 ==> q = %d, theretical = 31",result);
        start = 1'b0;
        valueA = 32'h00000000;
        repeat(2) @(negedge clock); /* wait for 2 clock cycles */

        
        // Start the conversion
        start = 1'b1;
        valueA = 32'd12642;
        ciN = 8'h0B;
        @(negedge clock); /* wait for the reset period to end */
        repeat(2) @(negedge clock); /* wait for 2 clock cycles */
        $display("r = 6, g = 11, b = 2 ==> q = %d, theretical = 9",result);
        start = 1'b0;
        valueA = 32'h00000000;
        repeat(2) @(negedge clock); /* wait for 2 clock cycles */
        
        $finish;
    end

    initial begin
        // define the name of the .vcd file that can be viewed by GTKWAVE
        $dumpfile("grayscale.vcd"); 
        
        // dump all signals inside the DUT-component in the .vcd file
        $dumpvars(1, DUT); 
    end


endmodule
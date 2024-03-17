`timescale 1ps/1ps // set the time-units for simulation

module profileCi_tb;

    reg start, clock, reset, stall, busIdle;
    reg [7:0] ciN;
    reg [31:0] valueA = 32'h00000000;
    reg [31:0] valueB = 32'h00000000;
    wire [31:0] result;

    initial begin
        reset = 1'b1;
        clock = 1'b0; // set the initial values
        repeat (4) #5 clock = ~clock; // generate 2 clock periods
        reset = 1'b0; // de-activate the reset
        forever #5 clock = ~clock; // generate a clock with a period of 10 time-units
    end

    profileCi #(.customId(8'h0B)) DUT (
        .start(start), 
        .clock(clock), 
        .reset(reset), 
        .stall(stall), 
        .busIdle(busIdle),
        .valueA(valueA), 
        .valueB(valueB),
        .ciN(ciN),
        .done(), 
        .result(result)
    );

    initial begin

        // Initialize the inputs
        start = 1'b0;
        ciN = 8'h0B;
        busIdle = 1'b1;
        stall = 1'b1;
        @(negedge reset); /* wait for the reset period to end */
        repeat(2) @(negedge clock); /* wait for 2 clock cycles */
        #5

        // Activate counter 0
        valueB = 32'h00000001;
        start = 1'b1;
        @(posedge clock); /* wait for the next clock cycle */
        start = 1'b0;
        //valueB = 32'h00000000;
        @(posedge clock); /* wait for 2 clock cycles */


        // Read the result
        start = 1'b1;
        @(posedge clock); /* wait for the next clock cycle */
        start = 1'b0;

        repeat(2) @(posedge clock); /* wait for 5 clock cycles */

        // Disable counter 0
        valueB = 32'h00000011;
        start = 1'b1;
        @(posedge clock); /* wait for the next clock cycle */
        start = 1'b0;
        valueB = 32'h00000000;

        repeat(2) @(posedge clock); /* wait for 5 clock cycles */

        // Reset counter 0
        // valueB = 32'h00000100;
        // start = 1'b1;
        // @(posedge clock); /* wait for the next clock cycle */
        // start = 1'b0;
        // valueB = 32'h00000000;
        
        repeat(2) @(posedge clock); /* wait for 5 clock cycles */

        // Activate counter 1
        valueB = 32'h00000002;
        start = 1'b1;
        @(posedge clock); /* wait for the next clock cycle */
        start = 1'b0;
        valueB = 32'h00000000;
        @(posedge clock); /* wait for 2 clock cycles */

        repeat(2) @(posedge clock); /* wait for 5 clock cycles */

        // Reset stall
        stall = 1'b0;

        repeat(2) @(posedge clock); /* wait for 5 clock cycles */

        // Activate counter 0, 2 and 3
        valueB = 32'h000000D;
        start = 1'b1;
        @(posedge clock); /* wait for the next clock cycle */
        start = 1'b0;
        valueB = 32'h00000000;

        repeat(2) @(posedge clock); /* wait for 5 clock cycles */

        $finish; /* finish the simulation */
    end
    
    initial begin
        // define the name of the .vcd file that can be viewed by GTKWAVE
        $dumpfile("profiler.vcd"); 
        
        // dump all signals inside the DUT-component in the .vcd file
        $dumpvars(1, DUT); 
    end

endmodule
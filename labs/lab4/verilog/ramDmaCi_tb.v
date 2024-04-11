`timescale 1ps/1ps // set the time-units for simulation

module ramDmaCiTestbench;
    reg start;
    reg clock;
    reg reset;
    reg [31:0] valueA;
    reg [31:0] valueB;
    reg [7:0] ciN;
    wire done;
    wire [31:0] result;

    initial begin
        reset = 1'b1;
        clock = 1'b0; // set the initial values
        repeat (4) #5 clock = ~clock; // generate 2 clock periods
        reset = 1'b0; // de-activate the reset
        forever #5 clock = ~clock; // generate a clock with a period of 10 time-units
    end

    ramDmaCi #(.customId(8'h0B)) DUT (
        .start(start), 
        .clock(clock), 
        .reset(reset), 
        .valueA(valueA), 
        .valueB(valueB),
        .ciN(ciN),
        .done(), 
        .result(result)
    );

    initial begin
        valueA = 32'h00000000;
        start = 1'b1;
        @(negedge reset); /* wait for the reset period to end */
        repeat(2) @(posedge clock); /* wait for 2 clock cycles */
        #5
        $finish;
    end

    initial begin
        // define the name of the .vcd file that can be viewed by GTKWAVE
        $dumpfile("ramDmaCi.vcd"); 
        
        // dump all signals inside the DUT-component in the .vcd file
        $dumpvars(1, DUT); 
    end
endmodule
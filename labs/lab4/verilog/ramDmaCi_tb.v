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

    // Declare DUT as an instance of your ramDmaCi module
    ramDmaCi DUT (
        .start(start),
        .clock(clock),
        .reset(reset),
        .valueA(valueA),
        .valueB(valueB),
        .ciN(ciN),
        .done(done),
        .result(result)
    );

    initial begin
        reset = 1'b1;
        clock = 1'b0; // set the initial values
        repeat (4) #5 clock = ~clock; // generate 2 clock periods
        reset = 1'b0; // de-activate the reset
        forever #5 clock = ~clock; // generate a clock with a period of 10 time-units
    end

    initial begin
        // define the name of the .vcd file that can be viewed by GTKWAVE
        $dumpfile("ramDmaCi.vcd"); 
        
        // dump all signals inside the DUT-component in the .vcd file
        $dumpvars(1, DUT); 
    end
endmodule
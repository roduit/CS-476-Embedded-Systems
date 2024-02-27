`timescale 1ps/1ps // set the time-units for simulation

module fifoTestbench;
    reg reset, clock;

    // Reset and clock generation
    initial begin
        reset = 1'b1;
        clock = 1'b0; // set the initial values
        repeat (4) #5 clock = ~clock; // generate 2 clock periods
        reset = 1'b0; // de-activate the reset
        forever #5 clock = ~clock; // generate a clock with a period of 10 time-units
    end

    reg s_push, s_pop; // define the signals for the DUT
    wire s_full, s_empty; // changed from reg to wire
    reg [7:0] s_pushData;
    wire [7:0] s_popData;

    fifo #(.nrOfEntries(8), .bitWidth(8)) DUT (
        .clock(clock),
        .reset(reset),
        .push(s_push),
        .pop(s_pop),
        .pushData(s_pushData),
        .full(s_full),
        .empty(s_empty),
        .popData(s_popData)
    );

    initial
        begin
            s_push = 1'b0;
            s_pop = 1'b0;
            s_pushData = 8'd5;
            @(negedge reset); /* wait for the reset period to end */
            repeat(2) @(negedge clock); /* wait for 2 clock cycles */
            s_push = 1'b1;
            repeat(4) @(negedge clock) s_pushData = s_pushData + 8'd1;
            s_pop = 1'b1;
            repeat(10) @(negedge clock) s_pushData = s_pushData + 8'd1;; /* wait for 32 clock cycles */
            // s_pop = 1'b0;
            $finish; /* finish the simulation */
        end
    
    integer idx;
    initial begin
        // define the name of the .vcd file that can be viewed by GTKWAVE
        $dumpfile("fifoSignals.vcd"); 
        
        // dump all signals inside the DUT-component in the .vcd file
        $dumpvars(1, DUT); 
        
        // dump all signals inside the fifoMemory-component in the .vcd file
        $dumpvars(1, DUT.fifoMemory); 
        
        for(idx = 0; idx < 8; idx = idx + 1)
            // dump all signals inside the memoryContent-array in the .vcd file
            $dumpvars(1, DUT.fifoMemory.memoryContent[idx]); 
    end
endmodule
`timescale 1ns/1ps

module ramDmaCi_test;

    reg start;
    reg clock;
    reg reset;
    reg [31:0] valueA;
    reg [31:0] valueB;
    reg [7:0] ciN;
    wire done;
    wire [31:0] result;

    // Instantiate the module
    ramDmaCi #(8'h01) uut (
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
        // Initialize signals
        start = 0;
        clock = 0;
        reset = 1;
        valueA = 0;
        valueB = 0;
        ciN = 0;

        // Apply reset
        #10 reset = 0;
        #10 reset = 1;
        #10 reset = 0;

        // Perform write operation
        start = 1;
        valueA = 32'h00000200; // Address 0x200
        valueB = 32'h12345678; // Some data
        ciN = 8'h01; // Custom ID
        #10;

        // Perform read operation
        start = 0;
        valueA = 32'h00000200; // Address 0x200
        ciN = 8'h01; // Custom ID
        #10;

        // End simulation
        $finish;
    end

    // Clock generator
    always #5 clock = ~clock;

endmodule
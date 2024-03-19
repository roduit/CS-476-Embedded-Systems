/*
Verilog description for the profilerCi module
*/

module profileCi   #(parameter [7:0] customId = 8'h0B)
                    (input wire         start, 
                                        clock, 
                                        reset, 
                                        stall, 
                                        busIdle,
                     input wire [31:0]  valueA, 
                                        valueB,
                     input wire [7:0]   ciN,
                     output wire        done,
                     output wire [31:0] result);

    // Counter values
    wire [31:0] s_valCounter0, s_valCounter1, s_valCounter2, s_valCounter3;
    wire [31:0] outputCounters;

    // Counter enable signals
    wire s_enCounter0, s_enCounter1, s_enCounter2, s_enCounter3;
    reg r_enCounter0, r_enCounter1, r_enCounter2, r_enCounter3;

    // Counter reset signals
    wire s_resetCounter0, s_resetCounter1, s_resetCounter2, s_resetCounter3;

    // Define the control signals
    assign s_resetCounter0 = reset | (valueB[8] & done);
    assign s_resetCounter1 = reset | (valueB[9] & done);
    assign s_resetCounter2 = reset | (valueB[10] & done);
    assign s_resetCounter3 = reset | (valueB[11] & done);

    assign s_enCounter0 = r_enCounter0;
    assign s_enCounter1 = r_enCounter1 & stall;
    assign s_enCounter2 = r_enCounter2 & busIdle;
    assign s_enCounter3 = r_enCounter3;

    // Send the counter values to the output and generate the done signal
    assign outputCounters = valueA[1] ? (valueA[0] ? s_valCounter3 : s_valCounter2) : (valueA[0] ? s_valCounter1 : s_valCounter0);

    assign done = (ciN == customId) && start;
    assign result = done ? outputCounters : 32'h00000000;

    // Define the 4 counters
    counter #(.WIDTH(32)) counter0 ( .reset(s_resetCounter0), .clock(clock), .enable(s_enCounter0), .direction(1'b1), .counterValue(s_valCounter0) );
    counter #(.WIDTH(32)) counter1 ( .reset(s_resetCounter1), .clock(clock), .enable(s_enCounter1), .direction(1'b1), .counterValue(s_valCounter1) );
    counter #(.WIDTH(32)) counter2 ( .reset(s_resetCounter2), .clock(clock), .enable(s_enCounter2), .direction(1'b1), .counterValue(s_valCounter2) );
    counter #(.WIDTH(32)) counter3 ( .reset(s_resetCounter3), .clock(clock), .enable(s_enCounter3), .direction(1'b1), .counterValue(s_valCounter3) );

    // Update the enable signals
    always @(posedge clock) begin
        if (valueB[4] && done) 
            r_enCounter0 <= 1'b0;
        else if (valueB[0] && done) 
            r_enCounter0 <= 1'b1;

        if (valueB[5] && done) 
            r_enCounter1 <= 1'b0;
        else if (valueB[1] && done) 
            r_enCounter1 <= 1'b1;

        if (valueB[6] && done) 
            r_enCounter2 <= 1'b0;
        else if (valueB[2] && done) 
            r_enCounter2 <= 1'b1;

        if (valueB[7] && done) 
            r_enCounter3 <= 1'b0;
        else if (valueB[3] && done) 
            r_enCounter3 <= 1'b1;
    end


endmodule


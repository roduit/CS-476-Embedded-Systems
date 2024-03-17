/*
Verilog module for the profiler
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

// Counter output signals
wire [31:0] s_counter0Value, s_counter1Value, s_counter2Value, s_counter3Value;

// Counter control signals
wire s_enCounter0, s_enCounter1, s_enCounter2, s_enCounter3;

// Define the 4 SR latches (reset dominant) for the counter control signals
// In this way, we can memorize the state of the control signals
sr_latch latch0 ( .S(valueB[0]), .R(valueB[4] | reset), .Q(s_enCounter0) );
sr_latch latch1 ( .S(valueB[1]), .R(valueB[5] | reset), .Q(s_enCounter1) );
sr_latch latch2 ( .S(valueB[2]), .R(valueB[6] | reset), .Q(s_enCounter2) );
sr_latch latch3 ( .S(valueB[3]), .R(valueB[7] | reset), .Q(s_enCounter3) );

// Define the output enable signal
wire s_outEnable = ((ciN == customId) ? 1'b1 : 1'b0) & start;

// Define the 4 counters
counter #(.WIDTH(32)) counter0 ( .reset(valueB[8] | reset),  .clock(clock), .enable(s_enCounter0),           .direction(1'b1), .counterValue(s_counter0Value) );
counter #(.WIDTH(32)) counter1 ( .reset(valueB[9] | reset),  .clock(clock), .enable(s_enCounter1 & stall),   .direction(1'b1), .counterValue(s_counter1Value) );
counter #(.WIDTH(32)) counter2 ( .reset(valueB[10] | reset), .clock(clock), .enable(s_enCounter2 & busIdle), .direction(1'b1), .counterValue(s_counter2Value) );
counter #(.WIDTH(32)) counter3 ( .reset(valueB[11] | reset), .clock(clock), .enable(s_enCounter3),           .direction(1'b1), .counterValue(s_counter3Value) );

// Send the counter values to the output and generate the done signal
assign done = s_outEnable;
assign result = s_outEnable ? (valueA[1] ? (valueA[0] ? s_counter3Value : s_counter2Value) : (valueA[0] ? s_counter1Value : s_counter0Value)) : 32'h00000000;

endmodule

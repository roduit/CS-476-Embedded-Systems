/*
Verilog module for the SR latch
*/
module sr_latch(
    input wire S, R,
    output wire Q, Qn);

    wire Sp = (~R) & S;

    assign Q     = ~(R | Qn);
    assign Qn = ~(Sp | Q);

endmodule
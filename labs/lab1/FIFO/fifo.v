module fifo #(
    parameter nrOfEntries = 16,
    parameter bitWidth = 32
)
(
    input wire clock,
    reset,
    push,
    pop,
    input wire [bitWidth-1:0] pushData,
    output wire full,
    empty,
    output wire [bitWidth-1:0] popData
);
endmodule
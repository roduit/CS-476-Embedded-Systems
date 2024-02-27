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

reg [$clog2(nrOfEntries)-1:0] push_pointer, pop_pointer = 0;

semiDualPortSSRAM #(.bitwidth(bitWidth), .nrOfEntries(nrOfEntries)) fifoMemory  
    (.clockA(clock),
     .clockB(clock),
     .writeEnable(push),
     .addressA(push_pointer),
     .addressB(pop_pointer),
     .dataIn(pushData),
     .dataOutA(popData),
     .dataOutB());

counter #(.WIDTH($clog2(nrOfEntries))) counterPush 
     (.reset(reset),
      .clock(clock),
      .enable(push && !full),
      .direction(1'b1),
      .counterValue(push_pointer));

counter #(.WIDTH($clog2(nrOfEntries))) counterPop 
     (.reset(reset),
      .clock(clock),
      .enable(pop && !empty),
      .direction(1'b1),
      .counterValue(pop_pointer));

always @(posedge clock) begin
    if (reset)
        // reset the FIFO
        pop_pointer <= push_pointer;
end

assign full = push_pointer == pop_pointer -1
assign empty = push_pointer == pop_pointer;

endmodule
module fifo #(
    parameter nrOfEntries = 16,
    parameter bitWidth = 32
)
(
    input wire clock,
    input wire reset,
    input wire push,
    input wire pop,
    input wire [bitWidth-1:0] pushData,
    output wire full,
    output wire empty,
    output wire [bitWidth-1:0] popData
);

wire [$clog2(nrOfEntries)-1:0] push_pointer_wire, pop_pointer_wire;
reg [$clog2(nrOfEntries)-1:0] push_pointer, pop_pointer = 0;

semiDualPortSSRAM #(.bitwidth(bitWidth), .nrOfEntries(nrOfEntries)) fifoMemory  
    (.clockA(clock),
     .clockB(clock),
     .writeEnable(push),
     .addressA(push_pointer_wire),
     .addressB(pop_pointer_wire),
     .dataIn(pushData),
     .dataOutA(popData),
     .dataOutB());

counter #(.WIDTH($clog2(nrOfEntries))) counterPush 
     (.reset(reset),
      .clock(clock),
      .enable(push && !full),
      .direction(1'b1),
      .counterValue(push_pointer_wire));

counter #(.WIDTH($clog2(nrOfEntries))) counterPop 
     (.reset(reset),
      .clock(clock),
      .enable(pop && !empty),
      .direction(1'b1),
      .counterValue(pop_pointer_wire));

always @(posedge clock) begin
    if (reset) begin
        push_pointer <= 0;
        pop_pointer <= 0;
    end else begin
        push_pointer <= push_pointer_wire;
        pop_pointer <= pop_pointer_wire;
    end
end
endmodule
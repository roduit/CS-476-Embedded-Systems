module fifo #(
    parameter nrOfEntries   = 16,
    parameter bitWidth      = 32
)
(
    input   wire                clock,
    input   wire                reset,
    input   wire                push,
    input   wire                pop,
    input   wire [bitWidth-1:0] pushData,
    output  wire                full,
    output  wire                empty,
    output  wire [bitWidth-1:0] popData
);

// FIFO control signals
wire [$clog2(nrOfEntries)-1:0] writeAddress, readAddress;
wire isFullCounter = ((writeAddress + 1) % nrOfEntries == readAddress) ? 1'b1 : 1'b0;
wire isEmptyCounter = (writeAddress == readAddress) ? 1'b1 : 1'b0;
wire do_push = push && ~isFullCounter;
wire do_pop = pop && ~isEmptyCounter;

assign full = isFullCounter;
assign empty = isEmptyCounter;

// FIFO memory
semiDualPortSSRAM #(
    .bitwidth(bitWidth),
    .nrOfEntries(nrOfEntries),
    .readAfterWrite(1)
)
fifoMemory (
    .clockA(clock),
    .clockB(clock),
    .writeEnable(do_push),
    .addressA(writeAddress),
    .addressB(readAddress),
    .dataIn(pushData),
    .dataOutA(),
    .dataOutB(popData)
);

// Counters
counter #(
    .WIDTH($clog2(nrOfEntries))
)
counterPush (
    .reset(reset),
    .clock(clock),
    .enable(do_push),
    .direction(1'b1),
    .counterValue(writeAddress)
);

counter #(
    .WIDTH($clog2(nrOfEntries))
)
counterPop (
    .reset(reset),
    .clock(clock),
    .enable(do_pop),
    .direction(1'b1),
    .counterValue(readAddress)
);


endmodule
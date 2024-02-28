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

// FIFO control
reg [$clog2(nrOfEntries)-1:0] writeAddress, readAddress;
wire [$clog2(nrOfEntries)-1:0] nextWriteAddress, nextReadAddress;
wire isFullCounter, isEmptyCounter;

// FIFO memory
semiDualPortSSRAM #(
    .bitwidth(bitWidth),
    .nrOfEntries(nrOfEntries),
    .readAfterWrite(1)
)
fifoMemory (
    .clockA(clock),
    .clockB(clock),
    .writeEnable(push && ~full),
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
    .enable(push && ~isFullCounter),
    .direction(1'b1),
    .counterValue(nextWriteAddress)
);

counter #(
    .WIDTH($clog2(nrOfEntries))
)
counterPop (
    .reset(reset),
    .clock(clock),
    .enable(pop && ~isEmptyCounter),
    .direction(1'b1),
    .counterValue(nextReadAddress)
);


always @(posedge clock or posedge reset) begin
    if (reset)
        begin
            writeAddress <= 0;
            readAddress <= 0;
        end
    else
        begin
            writeAddress <= nextWriteAddress;
            readAddress <= nextReadAddress;
        end
end

assign isFullCounter = ((nextWriteAddress + 1) % nrOfEntries == nextReadAddress);
assign isEmptyCounter = (nextWriteAddress == nextReadAddress);

assign full = ((writeAddress + 1) % nrOfEntries == readAddress);
assign empty = (writeAddress == readAddress);


endmodule
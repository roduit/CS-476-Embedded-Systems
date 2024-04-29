module ramDmaCi #(parameter [7:0] customId = 8'h00)
                    (input wire         start,
                                        clock,
                                        reset,
                    input wire [31:0]   valueA,
                                        valueB,
                    input wire [7:0]    ciN,
                    output wire         done,
                    output wire [31:0]  result);

 wire s_isMyCi = (ciN == customId) ? start : 1'b0;
    wire enWR = (valueA[31:10] == 0 && s_isMyCi);
    wire writeEnableA = valueA[9] && enWR;
    wire [31:0] resultSRAM; 
    
    reg read_done = 0;

    dualPortSSRAM #(
        .bitwidth(32), 
        .nrOfEntries(512), 
        .readAfterWrite(0))

    SSRAM(.clockA(clock),
         .clockB(clock),
         .writeEnableA(writeEnableA),
         .writeEnableB(1'b0),
         .addressA(valueA[8:0]),
         .addressB(9'b0),
         .dataInA(valueB),
         .dataInB(0),
         .dataOutA(resultSRAM));

always @(posedge clock) begin
        read_done <= enWR;
    end
assign done = ((writeEnableA | ~enWR) ? 1'b1 : read_done) && s_isMyCi;
assign result = done ? resultSRAM : 32'b0;

endmodule
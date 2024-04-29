module ramDmaCi #(parameter [7:0] customId = 8'h00)
                    (input wire         start,
                                        clock,
                                        reset,
                    input wire [31:0]   valueA,
                                        valueB,
                    input wire [7:0]    ciN,
                    output wire         done,
                    output wire [31:0]  result);

    wire            s_isMyCi = (ciN == customId);
    wire            write = s_isMyCi ? valueA[9] : 1'b0;
    wire            enWR_CPU = valueA[31:10] == 0 && s_isMyCi;
    wire            writeEnableA = valueA[9] && enWR_CPU && start;
    wire [31:0]     resultSRAM; 
    
    reg read_done = 0;

    dualPortSSRAM #(
        .bitwidth(32), 
        .nrOfEntries(512))

    SSRAM(.clockA(clock),
         .clockB(~clock),
         .writeEnableA(writeEnableA),
         .writeEnableB(1'b0),
         .addressA(valueA[8:0]),
         .addressB(9'b0),
         .dataInA(valueB),
         .dataInB(0),
         .dataOutA(resultSRAM));

always @(posedge clock) begin
        read_done <= reset ? 0: enWR_CPU;
    end
assign done     = (write ? 1'b1 : read_done) && s_isMyCi;
assign result = done ? resultSRAM : 32'b0;

endmodule
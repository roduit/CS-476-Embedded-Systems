module rgb565GrayscaleIse # (parameter [7:0] customInstructionId = 8'd0)
                            (input wire         start,
                             input wire [31:0]  valueA,
                             input wire [7:0]   iseId,
                             output wire        done,
                             output wire [31:0] result);

    wire [15:0] R, G, B;
    wire [15:0] partialR1, partialR2, partialR3, partialR4;
    wire [15:0] partialG1, partialG2, partialG3, partialG4, partialG5;
    wire [15:0] partialB1, partialB2;
    wire [31:0] grayscale;

    // R values - 5 bit
    assign R = valueA[15:11] << 3;

    // G values - 6 bit
    assign G = valueA[10:5] << 2;

    // B values - 5 bit
    assign B = valueA[4:0] << 3;


    // Red multiplication
    assign partialR1 = R << 5;
    assign partialR2 = R << 4;
    assign partialR3 = R << 2;
    assign partialR4 = R << 1;

    // Green multiplication
    assign partialG1 = G << 7;
    assign partialG2 = G << 5;
    assign partialG3 = G << 4;
    assign partialG4 = G << 2;
    assign partialG5 = G << 1;

    // Blue multiplication
    assign partialB1 = B << 4;
    assign partialB2 = B << 1;

    // Grayscale conversion
    assign grayscale = (partialR1 + partialR2 + partialR3 + partialR4 + 
                        partialG1 + partialG2 + partialG3 + partialG4 + partialG5 + G + 
                        partialB1 + partialB2 + B) >> 8;
    
    // Output
    assign done = (iseId == customInstructionId) ? start : 1'b0;
    assign result = done ? (grayscale & 32'h000000FF) : 32'b0;

endmodule
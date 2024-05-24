module edge_detection #(parameter [7:0] customInstructionId = 8'd0)
(
    input wire         start,
    input wire         reset,
    input wire         clock,
    input wire [31:0]  valueA,
                       valueB,
    input wire [7:0]   ciN,
    output wire        done,
    output wire [31:0] result
);

    // HOW TO USE THIS MODULE
    // 1. valueB[7:0] = 0b01 => set image0 pixel 0-3
    // 2. valueB[7:0] = 0b10 => set image0 pixel 4-7 and valueB[15:8] = pixel 8 image0 and valueB[23:16] = threshold and compute the result

    reg [7:0] image [0:8];
    reg [7:0] threshold;

    wire [7:0] edge_result;

    wire s_isMyEd = (ciN == customInstructionId) ? start : 1'b0;

    wire s_doCompute = s_isMyEd && (valueB[1:0] == 2'b10);
    reg s_doComputeReg;

    // wire s_isEdgRead = s_isMyEd & valueB[7:0];
    // reg s_isEdgReadReg;
  
    assign done   = (s_isMyEd && (valueB[1:0] == 2'b01)) ? 1'b1 : (s_doComputeReg) ? 1'b1 : 1'b0;
    assign result = (s_doComputeReg == 1'b1) ? edge_result : 32'd0;

    // Define Sobel edge detection module
    sobel sobel_module (
        .pixel0(image[0]),
        .pixel1(image[1]),
        .pixel2(image[2]),
        .pixel3(image[3]),
        .pixel4(image[4]),
        .pixel5(image[5]),
        .pixel6(image[6]),
        .pixel7(image[7]),
        .pixel8(image[8]),
        .threshold(threshold),
        .edge_val(edge_result)
    );

    always @(posedge clock) 
    begin
        // Reset the image and threshold
        if (reset) begin
            image[0] <= 0;
            image[1] <= 0;
            image[2] <= 0;
            image[3] <= 0;
            image[4] <= 0;
            image[5] <= 0;
            image[6] <= 0;
            image[7] <= 0;
            image[8] <= 0;
            threshold <= 0;
            s_doComputeReg <= 0;
        end
        else
        // Compute the edge detection
        begin
            s_doComputeReg <= s_doCompute;
            case(valueB[7:0])
                8'd0: begin
                    image[0] <= valueA[7:0];
                    image[1] <= valueA[15:8];
                    image[2] <= valueA[23:16];
                    image[3] <= valueA[31:24];
                end
                8'd1: begin
                    image[4] <= valueA[7:0];
                    image[5] <= valueA[15:8];
                    image[6] <= valueA[23:16];
                    image[7] <= valueA[31:24];
                    image[8] <= valueB[15:8];
                    threshold <= valueB[23:16];
                end
            endcase
        end
    end

endmodule

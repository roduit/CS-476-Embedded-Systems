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

    // ============================================================================
    //                             HOW TO USE THIS MODULE
    // ============================================================================
    //  1. valueB[7:0] = 0b000  =>  Set pixel 0-3
    //  2. valueB[7:0] = 0b001  =>  Set pixel 4-7
    //  3. valueB[7:0] = 0b010  =>  Set pixel 8-11
    //  4. valueB[7:0] = 0b011  =>  Set pixel 12-15
    //  5. valueB[7:0] = 0b100  =>  Set pixel 16-19
    //  6. valueB[7:0] = 0b101  =>  Set pixel 20-23 + threshold (valueB[15:8])
    // ============================================================================
    //
    //  Example of how to use this module (case 1):
    //  -------------------------------------------
    //  valueA = {px3, px2, px1, px0}
    //  valueB = 0
    //
    // ============================================================================

    // Define the signals
    reg [7:0] pixels [23:0];
    reg [7:0] threshold;

    // Define the output signals
    wire [7:0] s_sobel_0;
    wire [7:0] s_sobel_1;
    wire [7:0] s_sobel_2;
    wire [7:0] s_sobel_3;


    wire s_isMyEd = (ciN == customInstructionId) ? start : 1'b0;

    // wire s_doCompute = s_isMyEd && (valueB[7:0] == 8'd5);
    wire s_doCompute = s_isMyEd;
    reg s_doComputeReg = 0;
  
    assign done   = (s_isMyEd && (valueB[7:0] != 8'd5)) ? 1'b1 : (s_doComputeReg) ? 1'b1 : 1'b0;
    assign result = (s_doComputeReg == 1'b1) ?  {s_sobel_3, s_sobel_2, s_sobel_1, s_sobel_0} : 32'd0;

    // assign done   = (s_doComputeReg) ? 1'b1 : 1'b0;
    // assign result = (s_doComputeReg == 1'b1) ?  (valueB[7:0] == 8'd0) ? {pixels[3], pixels[2], pixels[1], pixels[0]} : 
    //                                             (valueB[7:0] == 8'd1) ? {pixels[3], pixels[2], pixels[1], pixels[0]} : 
    //                                             (valueB[7:0] == 8'd2) ? {pixels[3], pixels[2], pixels[1], pixels[0]}: 
    //                                             (valueB[7:0] == 8'd3) ? {pixels[3], pixels[2], pixels[1], pixels[0]} : 
    //                                             (valueB[7:0] == 8'd4) ? {pixels[3], pixels[2], pixels[1], pixels[0]} :
    //                                             {pixels[3], pixels[2], pixels[1], pixels[0]} : 32'd0;

    // ============================================================================
    //                         SOBEL EDGE DETECTION MODULE
    // ============================================================================

    sobel sobel_module_0 (
        .pixel0(pixels[0]),
        .pixel1(pixels[1]),
        .pixel2(pixels[2]),
        .pixel3(pixels[8]),
        .pixel4(pixels[9]),
        .pixel5(pixels[10]),
        .pixel6(pixels[16]),
        .pixel7(pixels[17]),
        .pixel8(pixels[18]),
        .threshold(threshold),
        .edge_val(s_sobel_0)
    );

    sobel sobel_module_1 (
        .pixel0(pixels[1]),
        .pixel1(pixels[2]),
        .pixel2(pixels[3]),
        .pixel3(pixels[9]),
        .pixel4(pixels[10]),
        .pixel5(pixels[11]),
        .pixel6(pixels[17]),
        .pixel7(pixels[18]),
        .pixel8(pixels[19]),
        .threshold(threshold),
        .edge_val(s_sobel_1)
    );

    sobel sobel_module_2 (
        .pixel0(pixels[2]),
        .pixel1(pixels[3]),
        .pixel2(pixels[4]),
        .pixel3(pixels[10]),
        .pixel4(pixels[11]),
        .pixel5(pixels[12]),
        .pixel6(pixels[18]),
        .pixel7(pixels[19]),
        .pixel8(pixels[20]),
        .threshold(threshold),
        .edge_val(s_sobel_2)
    );

    sobel sobel_module_3 (
        .pixel0(pixels[3]),
        .pixel1(pixels[4]),
        .pixel2(pixels[5]),
        .pixel3(pixels[11]),
        .pixel4(pixels[12]),
        .pixel5(pixels[13]),
        .pixel6(pixels[19]),
        .pixel7(pixels[20]),
        .pixel8(pixels[21]),
        .threshold(threshold),
        .edge_val(s_sobel_3)
    );

    // ============================================================================
    //                             SOBEL STATE MACHINE                        
    // ============================================================================
    localparam LOAD_PX_0_3 = 8'd0;
    localparam LOAD_PX_4_7 = 8'd1;
    localparam LOAD_PX_8_11 = 8'd2;
    localparam LOAD_PX_12_15 = 8'd3;
    localparam LOAD_PX_16_19 = 8'd4;
    localparam LOAD_LAST_PX_AND_THRESHOLD = 8'd5;

    always @(posedge clock) 
    begin
        // Reset the image and threshold
        if (reset) begin
            pixels[0] <= 8'b0;
            pixels[1] <= 8'b0;
            pixels[2] <= 8'b0;
            pixels[3] <= 8'b0;
            pixels[4] <= 8'b0;
            pixels[5] <= 8'b0;
            pixels[6] <= 8'b0;
            pixels[7] <= 8'b0;
            pixels[8] <= 8'b0;
            pixels[9] <= 8'b0;
            pixels[10] <= 8'b0;
            pixels[11] <= 8'b0;
            pixels[12] <= 8'b0;
            pixels[13] <= 8'b0;
            pixels[14] <= 8'b0;
            pixels[15] <= 8'b0;
            pixels[16] <= 8'b0;
            pixels[17] <= 8'b0;
            pixels[18] <= 8'b0;
            pixels[19] <= 8'b0;
            pixels[20] <= 8'b0;
            pixels[21] <= 8'b0;
            pixels[22] <= 8'b0;
            pixels[23] <= 8'b0;
            threshold <= 8'b0;
        end else begin
            // Compute the edge detection
            s_doComputeReg <= s_doCompute;
            if (s_isMyEd) begin
                case(valueB[7:0])
                    LOAD_PX_0_3: begin
                        $display("Loading pixels 0-3");
                        pixels[0] <= valueA[7:0];
                        pixels[1] <= valueA[15:8];
                        pixels[2] <= valueA[23:16];
                        pixels[3] <= valueA[31:24];
                    end
                    LOAD_PX_4_7: begin
                        $display("Loading pixels 4-7");
                        pixels[4] <= valueA[7:0];
                        pixels[5] <= valueA[15:8];
                        pixels[6] <= valueA[23:16];
                        pixels[7] <= valueA[31:24];
                    end
                    LOAD_PX_8_11: begin
                        $display("Loading pixels 8-11");
                        pixels[8] <= valueA[7:0];
                        pixels[9] <= valueA[15:8];
                        pixels[10] <= valueA[23:16];
                        pixels[11] <= valueA[31:24];
                    end
                    LOAD_PX_12_15: begin
                        $display("Loading pixels 12-15");
                        pixels[12] <= valueA[7:0];
                        pixels[13] <= valueA[15:8];
                        pixels[14] <= valueA[23:16];
                        pixels[15] <= valueA[31:24];
                    end
                    LOAD_PX_16_19: begin
                        $display("Loading pixels 16-19");
                        pixels[16] <= valueA[7:0];
                        pixels[17] <= valueA[15:8];
                        pixels[18] <= valueA[23:16];
                        pixels[19] <= valueA[31:24];
                    end
                    LOAD_LAST_PX_AND_THRESHOLD: begin
                        $display("Loading pixels 20-23 and threshold");
                        pixels[20] <= valueA[7:0];
                        pixels[21] <= valueA[15:8];
                        pixels[22] <= valueA[23:16];
                        pixels[23] <= valueA[31:24];
                        threshold <= valueB[15:8];
                    end

                endcase
            end
        end
    end

endmodule
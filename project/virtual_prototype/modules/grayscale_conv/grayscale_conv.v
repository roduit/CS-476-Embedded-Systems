module grayscale_conv #(parameter [7:0] customInstructionId = 8'd0)
(
    input wire start,
    input wire reset,
    input wire clock,
    input wire [31:0] valueA,
    input wire [31:0] valueB,
    input wire [7:0] ciN,
    output wire done,
    output wire [31:0] result
);

wire [15:0] pixelRGB;
wire [7:0] pixelGray;

reg done_reg;

wire s_isMyGrayscale = (ciN == customInstructionId) ? start : 1'b0;

assign pixelGray = valueA[7:0];

assign done = (s_isMyGrayscale && (valueB == 0)) ? 1'b1 : 1'b0;
assign result = done ? pixelRGB : 32'd0;

wire [4:0] red;    // 5 bits for red
wire [5:0] green;  // 6 bits for green
wire [4:0] blue;   // 5 bits for blue

assign red = (pixelGray[7:3] & 5'b11111);  // Mask with 0x1F for 5 bits
assign green = (pixelGray[7:2] & 6'b111111); // Mask with 0x3F for 6 bits
assign blue = (pixelGray[7:3] & 5'b11111);  // Mask with 0x1F for 5 bits

assign pixelRGB = {red, green, blue};

endmodule

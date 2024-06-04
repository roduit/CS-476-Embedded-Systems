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

wire [15:0] pixel1RGB;
wire [15:0] pixel2RGB;
wire [31:0] pixelsRGB;

wire [7:0] pixel1Gray;
wire [7:0] pixel2Gray;

wire [4:0] red_px1;
wire [5:0] green_px1; 
wire [4:0] blue_px1; 

wire [4:0] red_px2;
wire [5:0] green_px2;
wire [4:0] blue_px2;

wire s_isMyGrayscale = (ciN == customInstructionId) ? start : 1'b0;

assign pixel1Gray = valueA[7:0];
assign pixel2Gray = valueA[15:8];

assign done = (s_isMyGrayscale && (valueB == 0)) ? 1'b1 : 1'b0;
assign result = done ? pixelsRGB : 32'd0;



assign red_px1 = (pixel1Gray[7:3] & 5'b11111);  // Mask with 0x1F for 5 bits
assign green_px1 = (pixel1Gray[7:2] & 6'b111111); // Mask with 0x3F for 6 bits
assign blue_px1 = (pixel1Gray[7:3] & 5'b11111);  // Mask with 0x1F for 5 bits

assign red_px2 = (pixel2Gray[7:3] & 5'b11111);  // Mask with 0x1F for 5 bits
assign green_px2 = (pixel2Gray[7:2] & 6'b111111); // Mask with 0x3F for 6 bits
assign blue_px2 = (pixel2Gray[7:3] & 5'b11111);  // Mask with 0x1F for 5 bits

assign pixel1RGB = {red_px1, green_px1, blue_px1};
assign pixel2RGB = {red_px2, green_px2, blue_px2};

assign pixelsRGB = {pixel2RGB, pixel1RGB};

endmodule

module sobel
(
    input wire  [7:0]   pixel0, pixel1, pixel2,
                        pixel3, pixel4, pixel5,
                        pixel6, pixel7, pixel8,
    input wire  [7:0]   threshold,
    output wire [7:0]   edge_val
);

    // Sobel kernels
    wire signed [31:0] Gx, Gy;
    wire [10:0] Gx_abs, Gy_abs;

    // Compute the Sobel gradient in x direction
    assign Gx = (pixel2 + (pixel5 << 1) + pixel8) - (pixel0 + (pixel3 << 1) + pixel6);
    
    // Compute the Sobel gradient in y direction
    assign Gy = (pixel0 + (pixel1 << 1) + pixel2) - (pixel6 + (pixel7 << 1) + pixel8);

    // Compute the absolute values of Gx and Gy
    assign Gx_abs = Gx < 0 ? -Gx : Gx;
    assign Gy_abs = Gy < 0 ? -Gy : Gy;

    // Calculate the edge value
    //assign edge_val = (Gx_abs + Gy_abs) > threshold ? 255 : 0;
    assign edge_val = (Gx_abs + Gy_abs);

endmodule

module sobel
(
    input wire  [7:0]   pixel0, pixel1, pixel2,
                        pixel3, pixel4, pixel5,
                        pixel6, pixel7, pixel8,
    input wire  [7:0]   threshold,
    output wire         edge_val
);

    // Sobel kernels
    wire signed [10:0] Gx, Gy;
    wire [10:0] Gx_abs, Gy_abs;

    // Compute the Sobel gradient in x direction
    // The shift is done by keeping the MSB to avoid losing data in the sum
    assign Gx = (pixel2 + {pixel5, 1'b0} + pixel8) - (pixel0 + {pixel3, 1'b0} + pixel6);
    
    // Compute the Sobel gradient in y direction
    assign Gy = (pixel0 + {pixel1, 1'b0} + pixel2) - (pixel6 + {pixel7, 1'b0} + pixel8);
    
    // Compute the absolute values of Gx and Gy
    assign Gx_abs = Gx < 0 ? -Gx : Gx;
    assign Gy_abs = Gy < 0 ? -Gy : Gy;

    // Calculate the edge value
    assign edge_val = (Gx_abs + Gy_abs) > threshold ? 1'b1 : 1'b0;
    //assign edge_val = (Gx_abs + Gy_abs);

endmodule

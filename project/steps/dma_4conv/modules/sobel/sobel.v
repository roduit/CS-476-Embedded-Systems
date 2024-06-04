module sobel
(
    input wire  [7:0]   pixel0, pixel1, pixel2,
                        pixel3, pixel4, pixel5,
                        pixel6, pixel7, pixel8,
    input wire  [7:0]   threshold,
    output wire [7:0]   edge_val
);
    // Sobel kernels
    wire signed [9:0] Gx, Gy;
    wire        [9:0] Gx_abs, Gy_abs;

    // compute the absolute value of pixel 0


    assign Gx = (pixel2 + 2*pixel5 + pixel8) - (pixel0 + 2*pixel3 + pixel6);
    assign Gy = (pixel0 + 2*pixel1 + pixel2) - (pixel6 + 2*pixel7 + pixel8);

    assign Gx_abs = Gx[9] ? -Gx : Gx;
    assign Gy_abs = Gy[9] ? -Gy : Gy;

    // Calculate the edge value
    // assign edge_val = (Gx_abs + Gy_abs) > threshold ? 255 : 0;
    assign edge_val = Gx_abs + Gy_abs;

endmodule 

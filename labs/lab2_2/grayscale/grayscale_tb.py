def calculate_grayscale(r, g, b):
    return (54 * r + 183 * g + 19 * b) // 256

def print_grayscale(r, g, b):
    grayscale = calculate_grayscale(r, g, b)
    # concatenate the rgb values in hexadecimal r is 5 bits, g is 6 bits, b is 5 bits, put the result in a 32 bit hex value
    rgb = int((r << 11) | (g << 5) | b)
    print("// Start the conversion")
    print("start = 1'b1;")
    print(f"valueA = 32'd{rgb};")
    print("ciN = 8'h0B;")
    print("@(negedge clock); /* wait for the reset period to end */")
    print("repeat(2) @(negedge clock); /* wait for 2 clock cycles */")
    print(f'$display("r = {r}, g = {g}, b = {b} ==> q = %d, theretical = {grayscale}",result);')
    print("start = 1'b0;")
    print("valueA = 32'h00000000;")
    print("repeat(2) @(negedge clock); /* wait for 2 clock cycles */")

print_grayscale(16, 16, 16)
print_grayscale(10, 15, 20)
print_grayscale(31, 31, 31)
print_grayscale(6, 11, 2)
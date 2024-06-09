import numpy as np

def sobel_calc(image, threshold):
    # Sobel operator
    Kx = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]])
    Ky = np.array([[1, 2, 1], [0, 0, 0], [-1, -2, -1]])
    
    gx = np.sum(image * Kx)
    gy = np.sum(image * Ky)

    print(f'gx: {gx}, gy: {gy}')

    edge_val = 255 if np.abs(gx) + np.abs(gy) > threshold else 0
    return edge_val

# Test
image = np.array([[200, 102, 103], [244, 155, 166], [70, 80, 90]])
threshold = 128

print(sobel_calc(image, threshold))
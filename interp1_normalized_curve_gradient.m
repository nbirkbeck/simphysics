function g=interp1_normalized_curve_gradient(x_points, y_points, x, method)
    dx = 1e-4;
    g = (interp1_normalized_curve(x_points, y_points, x + dx, method) -
         interp1_normalized_curve(x_points, y_points, x - dx, method)) / (2 * dx);
    return

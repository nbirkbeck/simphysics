function [curve, curve_gradient] = make_curve(width, height, interior_points, method)
  x_points = linspace(0, width, length(interior_points) + 2);
  y_points = cat(2, [height], (interior_points), [0]);

  curve=@(x)(interp1_normalized_curve(x_points, y_points, x, method));
  curve_gradient=@(x)(interp1_normalized_curve_gradient(x_points, y_points, x, method));
  return

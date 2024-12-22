function r=interp1_normalized_curve(x_points, y_points, x, method)
  if nargin < 4,
    method = 'spline';
  end
  r = interp1(x_points, y_points, x, method);
  I = find(x <= x_points(1));
  r(I) = y_points(1);
  I = find(x >= x_points(end));
  r(I) = y_points(end);
  return;

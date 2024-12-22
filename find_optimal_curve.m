function find_optimal_curve(width, height)

  if nargin < 1,
    height = 1;
  end
  if nargin < 2,
    width = 2 * height;
  end

  num_points1 = 4;
  method1 = 'spline';
  num_points2 = 4;
  method2 = 'pchip';

  interior_points = height - linspace(0, height, num_points1);
  [interior_points, t_opt, info, output] = fminunc(@(x)(optimize_interior_point(width, height, x, method1)), interior_points(2:(end-1)));
  t_opt
  info
  output
  
  % Resolve using second method
  interior_points = interp1_normalized_curve(linspace(0, width, num_points1),
					     [height, interior_points, 0],
					     linspace(0, width, num_points2), method1);
  [interior_points, t_opt2, info2, output2] = fminunc(@(x)(optimize_interior_point(width, height, x, method2)), interior_points(2:(end-1)));
  t_opt, t_opt2
  info, info2
  output, output2

  [curve, curve_gradient] = make_curve(width, height, interior_points, method2);
  x = linspace(0, width, 100);
  y = curve(x);

  clf;
  figure(2);
  t = simulate_generic(width, height, curve, curve_gradient, 1);
  figure(1);
  plot(y);
  return
  
function t = optimize_interior_point(width, height, interior_points, method)
  [curve, curve_gradient] = make_curve(width, height, interior_points, method);
  t = simulate_generic(width, height, curve, curve_gradient);
  display(sprintf("t = %f", t));
  return;
  


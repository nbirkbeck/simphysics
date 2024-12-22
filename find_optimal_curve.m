function find_optimal_curve()

  height = 1;
  width = 2 * height;

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
  %x_points = linspace(0, width, length(interior_points) + 2)
  %y_points = cat(2, [height], (interior_points), [0]);
  %curve=@(x)(interp1_normalized_curve(x_points, y_points, x, method2));
  %curve_gradient=@(x)(interp1_normalized_curve_gradient(x_points, y_points, x, method2));

  x = linspace(0, width, 100);
  y = curve(x);

  clf;
  figure(2);
  t = simulate(width, height, curve, curve_gradient, 1);
  figure(1);
  plot(y);
  return

function [curve, curve_gradient] = make_curve(width, height, interior_points, method)
  x_points = linspace(0, width, length(interior_points) + 2);
  y_points = cat(2, [height], (interior_points), [0]);

  curve=@(x)(interp1_normalized_curve(x_points, y_points, x, method));
  curve_gradient=@(x)(interp1_normalized_curve_gradient(x_points, y_points, x, method));
  return
  
function t = optimize_interior_point(width, height, interior_points, method)
  [curve, curve_gradient] = make_curve(width, height, interior_points, method);
  t = simulate(width, height, curve, curve_gradient);
  display(sprintf("t = %f", t));
  return;
  
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

function g=interp1_normalized_curve_gradient(x_points, y_points, x, method)
    dx = 1e-4;
    g = (interp1_normalized_curve(x_points, y_points, x + dx, method) -
	 interp1_normalized_curve(x_points, y_points, x - dx, method)) / (2 * dx);
    return

function t = simulate(width, height, curve, curve_gradient, plotting)
  % Set up the initial position so that (0, 0) is where ramp meets ground.
  pos = [0, height];
  opos = pos;
  v = [0, 0];
  friction = 1.75;
  dt = 0.0125;
  t = 0;
  debug = 0;
  if nargin < 5,
    plotting = 0;
  end
  if plotting,
    ground = [];
    for x=linspace(0, width, 100),
      ground = [ground; x curve(x)];
    end
    prev_pos = [];
  end
  while pos(1) < width,
    if plotting,
      clf;
      plot([0, width], [height, -height / 2], 'w*'); hold on;
      plot([pos(1)], [pos(2)], 'b*');
      plot(ground(:, 1), ground(:, 2), 'r');
      if length(prev_pos) > 0
	plot(prev_pos(:, 1), prev_pos(:, 2), 'b');
      end
      axis equal;
      drawnow;
      pause(0.025);
      prev_pos = cat(1, prev_pos, pos);
    end

   
    slope_dy = curve_gradient(pos(1));
    slope_dx = 1;
    l = norm([slope_dx, slope_dy]);
    
    slope_dx /= l;
    slope_dy /= l;

    g = -9.81;
    dy = pos(2) - curve(pos(1));

    if plotting,
      display(sprintf('Energy top: %f', 9.81 * pos(2) + 0.5 * norm(v)^2 ))
      display(sprintf('dy: %f, slope_dy: %f', dy, slope_dy));
    end

    % if above the ground, apply enough acceleration to drop to the ground.
    if (dy > 0) && dt
      ratio_applied = min(1, dy / dt);
      if plotting,
	sprintf('ratio_applied:%f\n', ratio_applied)
      end
      a = [0, ratio_applied] * g;
      v += (a * dt);
      g *= (1 - ratio_applied);
    elseif dot(v, [-slope_dy, slope_dx]) < 0.5 * norm(v)
      % If dot product of velocity and surface normal is negative and in
      % contact with the ground rotate the velocity so we don't lose energy.
      v = [slope_dx, slope_dy] * norm(v);
    end

    a = [slope_dx, slope_dy] * slope_dy * g;
    v += (a * dt);

    v = v * (max(0.001, norm(v) - friction * dt)) / (norm(v)); % some friction
    last_pos = pos;

    pos += v * dt;

    dy = pos(2) - curve(pos(1));
    if dy < 0, # && slope_dy > 0,
      if plotting && debug,
	display(sprintf('Energy before: %f', 9.81 * pos(2) + 0.5 * norm(v)^2 ))
      end
      % This can't be free energy take away from velocity
      pos(2) -= dy;

      % 0.5 * (norm(v1)^2 - norm(v0)^2) = dy * 9.81
      %  (2*v0*dx + dx^2) = dy * 9.81 / 0.5
      % dx^2 + 2 * v0 * dx - dy * 9.81 / 0.5
      ps = [1, 2 * norm(v), -dy * 9.81 / 0.5];
      s1 = (-ps(2) + sqrt(max(0, ps(2)*ps(2) - 4 * ps(3)))) /2;
      s2 = (-ps(2) - sqrt(max(0, ps(2)*ps(2) - 4 * ps(3)))) /2;
      s = s2;
      if abs(s2) > norm(v)
	s=s1;
	% ps(1) * s * s + ps(2) *s + ps(3)
      end
      norm_before = norm(v);
      v = v * max(0.0, norm(v) + s) / (norm(v));
      norm_after = norm(v);

      if plotting && debug,
	dy
	display(sprintf('%f %f norm(v)=%f, %f\n', s1, s2, norm(v), s))
	sprintf("%f %f\n", 0.5 * (norm_after^2 - norm_before^2), dy * 9.81)
	display(sprintf('Energy after: %f', 9.81 * pos(2) + 0.5 * norm(v)^2 ))
      end

    elseif dy < 0,
      pos(2) -= dy;
    end

    t += dt;

    if plotting && debug,
      display(sprintf('Energy: %f', 9.81 * pos(2) + 0.5 * norm(v)^2 ))
    end
  end

  t -= dt * (pos(1) - width) / (pos(1) - last_pos(1));
  return;

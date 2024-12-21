function find_optimal_curve()

  height = 1;
  width = 3 * height;


  interior_points = height - linspace(0, height, 6);
  interior_points = fminunc(@(x)(optimize_interior_point(width, height, x)), interior_points(2:(end-1)));
  %interior_points
  x_points = linspace(0, width, length(interior_points) + 2)
  y_points = cat(2, [height], (interior_points), [0]);
  interior_points
  curve=@(x)(interp1_normalized_curve(x_points, y_points, x));
  curve_gradient=@(x)(interp1_normalized_curve_gradient(x_points, y_points, x));

  y = [];
  for x=linspace(0, width, 100),
    y = [y; curve(x)];
  end
  clf;
  figure(2);
  t = simulate(width, height, curve, curve_gradient, 1);
  figure(1);
  plot(y);
  return

function t = optimize_interior_point(width, height, interior_points)
  x_points = linspace(0, width, length(interior_points) + 2);
  y_points = cat(2, [height], (interior_points), [0]);

  curve=@(x)(interp1_normalized_curve(x_points, y_points, x));
  curve_gradient=@(x)(interp1_normalized_curve_gradient(x_points, y_points, x));
  t = simulate(width, height, curve, curve_gradient)
  sprintf("%f\n", t)
  return;
  
function r=interp1_normalized_curve(x_points, y_points, x)
  if x <= x_points(1),
    r = y_points(1);
  elseif x >= x_points(end),
    r = y_points(end);
  else
    r = interp1(x_points, y_points, x, 'pchip');
  end
  return;

function g=interp1_normalized_curve_gradient(x_points, y_points, x)
    dx = 1e-4;
    g = (interp1_normalized_curve(x_points, y_points, x + dx) - interp1_normalized_curve(x_points, y_points, x - dx)) / (2 * dx);
    return

function t = simulate(width, height, curve, curve_gradient, plotting)
  % Set up the initial position so that (0, 0) is where ramp meets ground.
  pos = [0, height];
  opos = pos;
  v = [0, 0];
  dt = 0.025;
  t = 0;

  if nargin < 5,
    plotting = 0;
  end

  while pos(1) < width,
    if plotting,
      clf;
      plot([0, width], [height, -height / 2], 'w*'); hold on;
      plot([pos(1)], [pos(2)], 'b*');
      axis equal;
      drawnow;
      pause(0.025);
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

    
    if (dy > 0)
      ratio_applied = min(1, dy / dt);
      if plotting,
	sprintf('ratio_applied:%f\n', ratio_applied)
      end
      a = [0, ratio_applied] * g;
      v += (a * dt);
      g *= (1 - ratio_applied);
    end
    a = [slope_dx, slope_dy] * slope_dy * g;
    v += (a * dt);

    %v = v * (max(0.001, norm(v) - 0.0 * dt)) / (norm(v)); % some friction
    last_pos = pos;

    pos += v * dt;

    dy = pos(2) - curve(pos(1));
    if dy < 0 && slope_dy > 0,
      if plotting,
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

      if plotting,
	dy
	display(sprintf('%f %f norm(v)=%f, %f\n', s1, s2, norm(v), s))
	sprintf("%f %f\n", 0.5 * (norm_after^2 - norm_before^2), dy * 9.81)
	display(sprintf('Energy after: %f', 9.81 * pos(2) + 0.5 * norm(v)^2 ))
      end


    elseif dy < 0,
      pos(2) -= dy;
    end

    t += dt;

    if plotting,
      display(sprintf('Energy: %f', 9.81 * pos(2) + 0.5 * norm(v)^2 ))
    end
  end

  t -= dt * (pos(1) - width) / (pos(1) - last_pos(1));
  return;

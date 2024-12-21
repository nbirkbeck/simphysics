function simulate(height, drop_height, jump_length, hill_angle)
  slope_dx =  cos(hill_angle);
  slope_dy = -sin(hill_angle);

% Set up the initial position so that (0, 0) is where ramp meets ground.
  pos = [height / slope_dy * slope_dx - jump_length, height + drop_height];
  opos = pos;
  v = [0, 0];
  dt = 0.025;
  t = 0;

  while pos(2) > 0,
    clf;
    plot([opos(1), -jump_length, 0], [opos(2), drop_height, drop_height], 'r'); hold on;
    plot([0], [0], 'r*');
    plot([pos(1)], [pos(2)], 'b*');
    axis equal;
    drawnow;
    pause(0.025);
    if pos(1) < -jump_length,
      a = [slope_dx, slope_dy] * slope_dy * -9.81;
    elseif pos(1) < 0,
      % Assume jump is flat
      velocity = norm(v);
      w = dt * 10;
      v = v * (1 - w) + [velocity, 0] * w;
      v = velocity * v / norm(v);
    else
      a = [0, -9.81];
    end
    v += (a * dt);
    x_gt_0 = pos(1) >= 0;
    pos += v * dt;
    if pos(1) > -jump_length && pos(1) < 0,
      pos(2) = max(pos(2), drop_height);
    end
    if !x_gt_0 && pos(1) >= 0,
      sprintf('Transition:')
      v, norm(v), t
    end
    t += dt;
  end

  pos, norm(v)

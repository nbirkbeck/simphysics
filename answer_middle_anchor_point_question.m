function [results, optimal_curve] = answer_middle_anchor_point_question(width_ratio)
  height = 1;
  if nargin < 1
    width_ratio = 2;
  end
width = width_ratio * height;

num_points = 3;
method = 'spline';

results = [];
x = linspace(0, width, 100);

figure(1); clf;

for interior_point1=linspace(-0.9, 0.5, 40),
  interior_point1
  [curve, curve_gradient] = make_curve(width, height, [interior_point1], method);

  figure(1);
  plot(x, curve(x), 'r');
  hold on;
  drawnow;

  t = simulate_generic(width, height, curve, curve_gradient, 0);
  results = [results; interior_point1, t];
end
figure(2); clf;
plot(results(:, 1), results(:, 2)); hold on;
I = find(results(:, 2) == min(results(:, 2)));
plot(results(I(1), 1), results(I(1), 2), 'r*');
hold off;
results(I(1), :)

[curve, curve_gradient] = make_curve(width, height, [results(I(1), 1)], method);
figure(1);
plot(x, curve(x), 'b');
optimal_curve = curve(x); 
%t = simulate_generic(width, height, curve, curve_gradient_2, 1);
%plot(x, curve(x));
return

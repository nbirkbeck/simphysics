function answer_drop_height_question()
  run_single_example(4, 3, 15);
  run_single_example(8, 3, 15);
  run_single_example(12, 3, 15);

  run_single_example(12, 6, 30);

  [a, b, all_pos_double] = simulate(4, 3 * 2, 1.5, 15 * pi / 180, false);
  [a, b, all_pos_full] = simulate(4, 3, 1.5, 15 * pi / 180, false);
  clf;
  plot(all_pos_full(:, 1), all_pos_full(:, 2), 'r'); hold on;
  plot(all_pos_double(:, 1), all_pos_double(:, 2), 'g');
  hold off;
  return

function run_single_example(height, drop_height, angle)

pos_double_height = simulate(height, drop_height * 2, 1.5, angle * pi / 180, false);
[pos_full_height, v_full_height] = simulate(height, drop_height, 1.5, angle * pi / 180, false);
pos_half_height = simulate(height, drop_height/2, 1.5,angle * pi / 180, false);
display(sprintf("\n\nheight: %f drop_height: %f", height, drop_height));
display(sprintf("distance: %f %f %f (v=%f)", pos_half_height(1), pos_full_height(1), pos_double_height(1), norm(v_full_height)));
display(sprintf("ratios: %f %f", pos_full_height(1) / pos_half_height(1),    pos_double_height(1) / pos_full_height(1)));

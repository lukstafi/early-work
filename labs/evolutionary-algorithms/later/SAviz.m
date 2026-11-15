% Simulated Annealing with linear temperature decrease, with
% visualization of search.


function [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OFUN, HISTORY_P] = SAviz(OFUN, d, N, MAX_ITERATIONS, temperature, sigma)

Individual = rand (1,d);

assert(d == 2);

[PlotX, PlotY] = meshgrid([0:0.05:1], [0:0.05:1]);
PlotZ = mesh_function(OFUN, PlotX, PlotY);
disp ('PlotZ computed');

figure;

hold off;
mesh(PlotX, PlotY, PlotZ);
hold on;
IndObjective = feval (OFUN, Individual);
plot3 (Individual(1), Individual(2), IndObjective, '.or');
plot3 (Individual(1), Individual(2), IndObjective, '.xg');

disp ('Initial position.');
input ('Press <enter> to continue: ', 's');



BEST_OBJECTIVE = -inf;

HISTORY_OFUN = [];
HISTORY_P = [];

for gen_num = 1:MAX_ITERATIONS
  hold off;
  mesh(PlotX, PlotY, PlotZ);
  hold on;

  temp = temperature * (MAX_ITERATIONS - gen_num + 1) / MAX_ITERATIONS;

  Objective = [];
  Population = [];
  for ind = 1:N
    Child = normrnd (Individual, sigma);
    ChildObjective = feval (OFUN, Child);
    if IndObjective < ChildObjective | exp((ChildObjective - IndObjective) / temp) > rand()
      IndObjective = ChildObjective;
      Individual = Child;
    end;
    Objective = [Objective; IndObjective];
    Population = [Population; Individual];
  end;

  plot3 (Individual(1), Individual(2),  IndObjective, '.or');
  plot3 (Individual(1), Individual(2),  IndObjective, '.xg');
  plot3 (Population(:,1), Population(:,2),  Objective, '--r');
  disp ('Generation: '), disp(gen_num);
  disp ('temperature: '), disp(temp);
  disp ('Objective: '), disp(IndObjective);
  input ('Press <enter> to continue: ', 's');

  [ACT_BEST_OBJECTIVE, bestI] = max (Objective);
  if(BEST_OBJECTIVE < ACT_BEST_OBJECTIVE)
    BEST_INDIVIDUAL = Population(bestI, :);
    BEST_OBJECTIVE = ACT_BEST_OBJECTIVE;
  end;

  HISTORY_OFUN = [HISTORY_OFUN; min(Objective) max(Objective) mean(Objective) std(Objective)];
  HISTORY_P = [HISTORY_P; Individual];

end;

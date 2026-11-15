% Simulated Annealing with linear temperature decrease.
%
% function [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OFUN, HISTORY_P, Indiv] = SA(OFUN, d, N, MAX_ITERATIONS, Individual, temperature, sigma)


function [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OFUN, HISTORY_P, Indiv] = SA(OFUN, d, N, MAX_ITERATIONS, temperature, sigma)

Individual = rand (1,d);
IndObjective = feval (OFUN, Individual);

BEST_OBJECTIVE = -inf;

HISTORY_OFUN = [];
HISTORY_P = [];

for gen_num = 1:MAX_ITERATIONS

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

  [ACT_BEST_OBJECTIVE, bestI] = max (Objective);
  if(BEST_OBJECTIVE < ACT_BEST_OBJECTIVE)
    BEST_INDIVIDUAL = Population(bestI, :);
    BEST_OBJECTIVE = ACT_BEST_OBJECTIVE;
  end;

  HISTORY_OFUN = [HISTORY_OFUN; min(Objective) max(Objective) mean(Objective) std(Objective)];
  HISTORY_P = [HISTORY_P; Individual];

end;

Indiv = Individual;

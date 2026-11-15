% Simulated Annealing with MultiStart and linear temperature decrease.
%
% function [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OFUN, HISTORY_P, Indiv] = SAMS(OFUN, d, N, MAX_ITERATIONS, Individual, temperature, sigma)


function [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OFUN, HISTORY_P, POP] = SAMS(OFUN, d, N, MAX_ITERATIONS, temperature, sigma)

Population = rand (N,d);
Objective = feval (OFUN, Population);

BEST_OBJECTIVE = -inf;

HISTORY_OFUN = [];
HISTORY_P = [];

for gen_num = 1:MAX_ITERATIONS

  temp = temperature * (MAX_ITERATIONS - gen_num + 1) / MAX_ITERATIONS;

  NewPop = normrnd (Population, sigma);
  NewObjective = feval (OFUN, NewPop);
  for ind = 1:N
    if Objective(ind) < NewObjective(ind) | exp((NewObjective(ind) - Objective(ind)) / temp) > rand()
      Objective(ind) = NewObjective(ind);
      Population(ind) = NewPop(ind);
    end;
  end;

  [ACT_BEST_OBJECTIVE, bestI] = max (Objective);
  if(BEST_OBJECTIVE < ACT_BEST_OBJECTIVE)
    BEST_INDIVIDUAL = Population(bestI, :);
    BEST_OBJECTIVE = ACT_BEST_OBJECTIVE;
  end;

  p = mean(Population);
    
  HISTORY_OFUN = [HISTORY_OFUN; min(Objective) max(Objective) mean(Objective) std(Objective)];
  HISTORY_P = [HISTORY_P; p];

end;

POP = Population;

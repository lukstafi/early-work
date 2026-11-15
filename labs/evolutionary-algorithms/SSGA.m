% Simplified Simple Genetic Algorithm, SSGA

function [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OBJECTIVE_FUNCTION, HISTORY_P] = SSGA(OBJECTIVE_FUNCTION, d, N, MAX_ITERATIONS)

Omega      = 0.25;
Lambda     = round(Omega * N);



Population = rand(N, d) < 0.5;
Objective = feval(OBJECTIVE_FUNCTION, Population);

[Objective I] = sort(-Objective);
Objective = -Objective;
Population = Population(I, :);



BEST_OBJECTIVE = -inf;

HISTORY_OBJECTIVE_FUNCTION = [];
HISTORY_P = [];

for k = 1 : MAX_ITERATIONS;
    Population(N - Lambda + 1 : N, :) = Population(1 : Lambda, :);
    Population = Population(randperm(N), :);

    A = find(rand(1, d) < 0.5);

    NewPopulation = Population;
    NewPopulation([1:2:N], A) = Population([2:2:N], A);
    NewPopulation([2:2:N], A) = Population([1:2:N], A);
    
    Population = NewPopulation;

    Objective = feval(OBJECTIVE_FUNCTION, Population);

    [Objective I] = sort(-Objective);
    Objective = -Objective;
    Population = Population(I, :);

    p = mean(Population);
    
    if(BEST_OBJECTIVE < Objective(1))
        BEST_INDIVIDUAL = Population(1, :);
        BEST_OBJECTIVE = Objective(1);
    end;

    HISTORY_OBJECTIVE_FUNCTION = [HISTORY_OBJECTIVE_FUNCTION; min(Objective) max(Objective) mean(Objective) std(Objective)];
    HISTORY_P = [HISTORY_P; p];
end;

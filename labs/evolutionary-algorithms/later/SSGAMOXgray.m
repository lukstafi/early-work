% Simplified Simple Genetic Algorithm, SSGA, with Mutation and one-point crossover

function [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OBJECTIVE_FUNCTION, HISTORY_P] = SSGAMOXgray(OBJECTIVE_FUNCTION, d, N, MAX_ITERATIONS, MutProb, Omega)

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

    A = find(1:d < rand(1, 1) * d);

    Population = bit2gray(Population);

    NewPopulation = Population;
    NewPopulation([1:2:N], A) = Population([2:2:N], A);
    NewPopulation([2:2:N], A) = Population([1:2:N], A);
    
    Population = NewPopulation;
    
    B = find(rand(N, d) < MutProb);
    B0 = B(find(Population(B) == 0));
    B1 = B(find(Population(B) == 1));
    Population(B0) = 1;
    Population(B1) = 0;

    Population = gray2bit(Population);

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

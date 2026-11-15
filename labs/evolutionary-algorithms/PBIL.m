% Population-Based Incremental Learning, PBIL

function [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OBJECTIVE_FUNCTION, HISTORY_P] = PBIL(OBJECTIVE_FUNCTION, d, N, MAX_ITERATIONS)

Th1        = 0.1;
Th2        = 0.02;
Th3        = 0.02;



p = 0.5 * ones(1, d);

BEST_OBJECTIVE = -inf;

HISTORY_OBJECTIVE_FUNCTION = [];
HISTORY_P = p;

for k = 1 : MAX_ITERATIONS;
    Population = rand(N, d) < ones(N, 1) * p;
    Objective = feval(OBJECTIVE_FUNCTION, Population);

    [Objective I] = sort(-Objective);
    Objective = -Objective;
    Population = Population(I, :);
    
    if(BEST_OBJECTIVE < Objective(1))
        BEST_INDIVIDUAL = Population(1, :);
        BEST_OBJECTIVE = Objective(1);
    end;

    p = p * (1.0 - Th1) + Population(1, :) * Th1;

    for i = 1 : d;
        if rand(1, 1) < Th2;
            p(i) = p(i) * (1.0 - Th3) + round(rand(1, 1)) * Th3;
        end;
    end;

    HISTORY_OBJECTIVE_FUNCTION = [HISTORY_OBJECTIVE_FUNCTION; min(Objective) max(Objective) mean(Objective) std(Objective)];
    HISTORY_P = [HISTORY_P; p];
end;

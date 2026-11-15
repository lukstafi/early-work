% Compact Genetic Algorithm, CGA

function [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OBJECTIVE_FUNCTION, HISTORY_P] = CGA(OBJECTIVE_FUNCTION, d, N, MAX_ITERATIONS)

p = 0.5 * ones(1, d);

BEST_OBJECTIVE = -inf;

HISTORY_OBJECTIVE_FUNCTION = [];
HISTORY_P = p;

for k = 1 : MAX_ITERATIONS;
    Population = rand(2, d) < ones(2, 1) * p;
    Objective = feval(OBJECTIVE_FUNCTION, Population);

    if(Objective(1) < Objective(2));
        Population = Population([2 1], :);
        Objective = Objective([2 1]);
    end;
    
    if(BEST_OBJECTIVE < Objective(1))
        BEST_INDIVIDUAL = Population(1, :);
        BEST_OBJECTIVE = Objective(1);
    end;

    for i = 1 : d;
        if(Population(1, i) ~= Population(2, i))
            if(Population(1, i) == 0)
                p(i) = p(i) - 1/N;
            else
                p(i) = p(i) + 1/N;
            end;
        end;
    end;

    HISTORY_OBJECTIVE_FUNCTION = [HISTORY_OBJECTIVE_FUNCTION; min(Objective) max(Objective) mean(Objective) std(Objective)];
    HISTORY_P = [HISTORY_P; p];
end;

% Simplified Simple Genetic Algorithm, SSGA, with Mutation, as
% population transformation, with visualization of population

function [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OBJECTIVE_FUNCTION, \
	  HISTORY_P] = SSGAMviz(OBJECTIVE_FUNCTION, d, N, MAX_ITERATIONS, \
			     Omega, MutProb)

Population = rand(N, d) < 0.5;

Lambda     = round(Omega * N);

PlotRange = real2bit (d, [0:0.001:1]');

figure;

Objective = feval(OBJECTIVE_FUNCTION, Population);

hold off;
plot (bit2real (PlotRange), feval(OBJECTIVE_FUNCTION, \
					     PlotRange), "--b");
hold on;
plot (bit2real(Population), Objective, ".or");
plot (bit2real(Population), Objective, ".xg");
disp ("Initial population.");
input ("Press <enter> to continue: ", "s");

[Objective I] = sort(-Objective);
Objective = -Objective;
Population = Population(I, :);


BEST_OBJECTIVE = -inf;

HISTORY_OBJECTIVE_FUNCTION = [];
HISTORY_P = [];

for k = 1 : MAX_ITERATIONS
    hold off;
    plot (bit2real (PlotRange), feval(OBJECTIVE_FUNCTION, \
	 			      PlotRange), "--b");
    hold on;

    Population(N - Lambda + 1 : N, :) = Population(1 : Lambda, :);
    Population = Population(randperm(N), :);

    A = find(rand(1, d) < 0.5);

    NewPopulation = Population;
    NewPopulation([1:2:N], A) = Population([2:2:N], A);
    NewPopulation([2:2:N], A) = Population([1:2:N], A);
    
    for i = 1:(N-1)
      old1 = Population(i, :);
      old2 = Population(i+1, :);
      new1 = NewPopulation(i, :);
      new2 = NewPopulation(i+1, :);
      plot ([bit2real(old1), bit2real(new1)], \
	    [feval(OBJECTIVE_FUNCTION, old1), \
	     feval(OBJECTIVE_FUNCTION, new1)], "--r");
      plot ([bit2real(old1), bit2real(new2)], \
	    [feval(OBJECTIVE_FUNCTION, old1), \
	     feval(OBJECTIVE_FUNCTION, new2)], "--r");
      plot ([bit2real(old2), bit2real(new1)], \
	    [feval(OBJECTIVE_FUNCTION, old2), \
	     feval(OBJECTIVE_FUNCTION, new1)], "--r");
      plot ([bit2real(old2), bit2real(new2)], \
	    [feval(OBJECTIVE_FUNCTION, old2), \
	     feval(OBJECTIVE_FUNCTION, new2)], "--r");
    end;
    Population = NewPopulation;
    
    B = find(rand(N, d) < MutProb);
    B0 = B(find(Population(B) == 0));
    B1 = B(find(Population(B) == 1));
    NewPopulation = Population;
    NewPopulation(B0) = 1;
    NewPopulation(B1) = 0;
    
    for i = 1:N
      old1 = Population(i, :);
      new1 = NewPopulation(i, :);
      plot ([bit2real(old1), bit2real(new1)], \
	    [feval(OBJECTIVE_FUNCTION, old1), \
	     feval(OBJECTIVE_FUNCTION, new1)], "--r");
    end;
    Population = NewPopulation;

    Objective = feval(OBJECTIVE_FUNCTION, Population);

    plot (bit2real(Population), Objective, ".or");
    plot (bit2real(Population), Objective, ".xg");
    disp (["Generation: ", num2str(k)]);
    input ("Press <enter> to continue: ", "s");

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

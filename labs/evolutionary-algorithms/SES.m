% Simplified Evolutionary Strategy, with Rechenberg "1/5" rule applied to
% whole population (to speed-up presentation), with three operators to
% choose from (linear combination, heuristic recombination, mutation)
% with arbitrary number of parents, roulette wheel selection
%
% [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OFUN, \
%	  HISTORY_P] = SESviz(OFUN, d, N, MAX_ITERATIONS, \
%			     operators, lin_parents, heur_parents)
%
% operators(i) gives percentage of children created by operator i

function [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OFUN, \
	  HISTORY_P] = SESviz(OFUN, d, N, MAX_ITERATIONS, \
			     one_fifth, operators, \
			      lin_parents, heur_parents)

Population = rand(N, d);

theta      = 0.82;
sigma      = 0.1;
LIN_num    = floor(operators(1)*N);
HEUR_num   = floor(operators(2)*N);
MUT_num    = floor(operators(3)*N);
COPY_num   = N - LIN_num - HEUR_num - MUT_num;

Objective = feval(OFUN, Population);

BEST_OBJECTIVE = -inf;

HISTORY_OFUN = [];
HISTORY_P = [];

better_lin_tot = 0;
better_heur_tot = 0;
better_mut_tot = 0;

for gen_num = 1:MAX_ITERATIONS

  better_lin = 0;
  U = rand(LIN_num, lin_parents);
  LinChildren = zeros(LIN_num, columns(Population));
  for i = 1:LIN_num
    LinParents = Population(roulette(Objective,lin_parents),:);
    U(i,:) = U(i,:) ./ sum(U(i,:));
    LinChildren(i,:) = U(i,:) * LinParents;
    LinObjective = feval (OFUN, LinParents);
    [BestVal, LinBestI] = max (LinObjective);
    ChildObj = feval(OFUN, LinChildren(i,:));
    if ChildObj > BestVal
      better_lin = better_lin + 1;
    end;
  end;

  better_heur = 0;
  HeurChildren = zeros(LIN_num, columns(Population));
  for i = 1:HEUR_num
    HeurParents = Population(roulette(Objective,heur_parents),:);
    HeurMean = mean (HeurParents);
    HeurObjective = feval (OFUN, HeurParents);
    [BestVal, HeurBestI] = max (HeurObjective);
    HeurBest = HeurParents(HeurBestI,:);
    HeurChildren(i,:) = HeurMean + (HeurBest - HeurMean)*(1+sigma);
    ChildObj = feval(OFUN, HeurChildren(i,:));
    if ChildObj > BestVal
      better_heur = better_heur + 1;
    end;
  end;

  better_mut = 0;
  MutParents = Population(roulette(Objective,MUT_num),:);
  MutChildren = normal_rnd (MutParents, \
			    ones(size(MutParents)) .* (sigma^2), \
			    size(MutParents));
  for i = 1:MUT_num
    ParentObj = feval(OFUN, MutParents(i,:));
    ChildObj = feval(OFUN,MutChildren(i,:));
    if ChildObj > ParentObj
      better_mut = better_mut + 1;
    end;
  end;

  CopyChildren = Population(roulette(Objective,COPY_num),:);
  Population = [LinChildren; HeurChildren; MutChildren; CopyChildren];

  Objective = feval(OFUN, Population);

  if (better_heur + better_mut) > one_fifth*(HEUR_num + MUT_num)
    sigma = sigma * (1/theta)
  else
    sigma = sigma * theta
  end;

  p = mean(Population);
    
  [ACT_BEST_OBJECTIVE, bestI] = max (Objective);
  if(BEST_OBJECTIVE < ACT_BEST_OBJECTIVE)
    BEST_INDIVIDUAL = Population(bestI, :);
    BEST_OBJECTIVE = ACT_BEST_OBJECTIVE;
  end;

  HISTORY_OFUN = [HISTORY_OFUN; min(Objective) max(Objective) \
		  mean(Objective) std(Objective)];
  HISTORY_P = [HISTORY_P; p];

end;

POP = Population;

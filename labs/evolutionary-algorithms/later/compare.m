% Compare two evolutionary algorithms. The algorithms need to return the values:
%
% [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OFUN]
%
% where each row of HISTORY_OFUN is
% min(Objective), max(Objective), mean(Objective), std(Objective)
%
% function [mean_alg1, mean_alg2] = compare(alg1, alg_name1, alg2, alg_name2, repetitions)
%
% alg1 and alg2 are strings that call the algorithms with required parameters.
% alg_name1 and alg_name2 are strings for display
% repetitions is the number of trials for each algorithm.


function [mean_obj1, mean_obj2] = compare(alg1, alg_name1, alg2, alg_name2, repetitions)

    best_obj1 = [];
    max_obj1 = [];
    mean_obj1 = [];
    std_obj1 = [];
    best_obj2 = [];
    max_obj2 = [];
    mean_obj2 = [];
    std_obj2 = [];
    disp (['computing for algorithm 1: ', alg_name1]);
    for samp = 1:repetitions
      eval (['[BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OFUN] = ', alg1]);
      best_obj1 = [best_obj1; BEST_OBJECTIVE];
      max_obj1 = [max_obj1, HISTORY_OFUN(:,2)];
      mean_obj1 = [mean_obj1, HISTORY_OFUN(:,3)];
      std_obj1 = [std_obj1, HISTORY_OFUN(:,4)];
    end;

    disp (['computing for algorithm 2: ', alg_name2]);
    for samp = 1:repetitions
      eval (['[BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OFUN] = ', alg2]);
      best_obj2 = [best_obj2; BEST_OBJECTIVE];
      max_obj2 = [max_obj2, HISTORY_OFUN(:,2)];
      mean_obj2 = [mean_obj2, HISTORY_OFUN(:,3)];
      std_obj2 = [std_obj2, HISTORY_OFUN(:,4)];
    end;

    mean_alg1 = mean(max_obj1, 2);
    mean_alg2 = mean(max_obj2, 2);
    std_alg1 = std(max_obj1, 0, 2);
    std_alg2 = std(max_obj2, 0, 2);
    mean_m_alg1 = mean(mean_obj1, 2);
    mean_m_alg2 = mean(mean_obj2, 2);
    std_m_alg1 = std(mean_obj1, 0, 2);
    std_m_alg2 = std(mean_obj2, 0, 2);

  figure;
  hold on;
  title ('Mean maximal value in the population during run');
  xlabel ('Number of generation');
  ylabel ('values +- std dev');
  iterations = length(mean_alg1);
  plot (1:iterations,mean_alg1 - std_alg1,'-b');
  plot (1:iterations,mean_alg1 + std_alg1,'-b');
  plot (1:iterations,mean_alg2 - std_alg2,'-r');
  plot (1:iterations,mean_alg2 + std_alg2,'-r');
  plot (1:iterations,mean_m_alg1 - std_m_alg1,'-ob');
  plot (1:iterations,mean_m_alg1 + std_m_alg1,'-ob');
  plot (1:iterations,mean_m_alg2 - std_m_alg2,'-or');
  plot (1:iterations,mean_m_alg2 + std_m_alg2,'-or');
  legend([alg_name1, ' max - stdev'], [alg_name1, ' max + stdev'], [alg_name2, ' max - stdev'], [alg_name2, ' max + stdev'], [alg_name1, ' mean - stdev'], [alg_name1, ' mean + stdev'], [alg_name2, ' mean - stdev'], [alg_name2, ' mean + stdev']);

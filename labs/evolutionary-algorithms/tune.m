% Run a series of experiments for an evolutionary algorithm over a range
% of parameter values. The algorithms need to return the values:
%
% [BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OFUN]
%
% where each row of HISTORY_OFUN is
% min(Objective), max(Objective), mean(Objective), std(Objective)
%
% function [mean_best_obj, mean_max_obj] = \ 
%       tune(preparam, postparam, param_vals, repetitions, param_name)
%
% The tested argument is inserted on the param_num position into the
% PARAMi arguments. preparam is the algorithm call up to tested
% function, postparam is the rest of arguments or ")", e.g.
% preparam = "EA (OFUN, d, N, MAX_ITERATIONS, PARAM1,"
% postparam = "PARAM3)"
% repetitions is the number of trials for each value of tested
% parameter. param_name is a string naming the parameter.



function [mean_best_obj, mean_max_obj] = \
      tune(preparam, postparam, param_vals, repetitions, param_name)

  mean_best_obj = [];
  mean_max_obj = [];
  mean_mean_obj = [];
  mean_std_obj = [];
  std_best_obj = [];
  std_max_obj = [];
  std_mean_obj = [];
  std_std_obj = [];
  for param = param_vals
    best_obj = [];
    max_obj = [];
    mean_obj = [];
    std_obj = [];
    disp (["computing for ", param_name, " = ", num2str(param)]);
    for samp = 1:repetitions
      eval (["[BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OFUN] = ", \
	    preparam, num2str(param), postparam]);
      best_obj = [best_obj; BEST_OBJECTIVE];
      max_obj = [max_obj, HISTORY_OFUN(:,2)];
      mean_obj = [mean_obj, HISTORY_OFUN(:,3)];
      std_obj = [std_obj, HISTORY_OFUN(:,4)];
    end;
    mean_best_obj = [mean_best_obj, mean(best_obj)];
    mean_max_obj = [mean_max_obj, mean(max_obj,2)];
    mean_mean_obj = [mean_mean_obj, mean(mean_obj,2)];
    mean_std_obj = [mean_std_obj, mean(std_obj,2)];
    std_best_obj = [std_best_obj, std(best_obj)];
    std_max_obj = [std_max_obj, std(max_obj,0,2)];
    std_mean_obj = [std_mean_obj, std(mean_obj,0,2)];
    std_std_obj = [std_std_obj, std(std_obj,0,2)];
  end;

  figure;
  hold on;
  title ("Best overall result");
  xlabel ([param_name, " value"]);
  ylabel ("Best result value, +- std dev")
  plot (param_vals,mean_best_obj,"--r");
  plot (param_vals,mean_best_obj - std_best_obj,"--b");
  plot (param_vals,mean_best_obj + std_best_obj,"--b");

  iterations = rows (mean_max_obj);
  figure;
  hold on;
  title ("Maximal value in the population during run");
  xlabel ([param_name, " value"]);
  ylabel ("Number of generation");
  zlabel ("Maximal value in population, +- std dev")
  [figX, figY] = meshgrid (param_vals, 1:iterations);
  mesh (figX, figY, mean_max_obj - std_max_obj);
  mesh (figX, figY, mean_max_obj + std_max_obj);

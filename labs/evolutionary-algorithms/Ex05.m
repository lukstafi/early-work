% Meta-optimization: tuning the optimizer's parameters for a given task.

disp ("Simulated Annealing, the trimodal mixture example.");
p_0 = 0.01;
p_1 = 2.01;
p_step = 0.2;
mean_best_obj = \
    tune ("SA(@ObjFunc_mixture,2,10,10,", ", 0.1);", \
	  [p_0:p_step:p_1], 10, "temperature");
[best_val, best] = max (mean_best_obj);
best_temp = p_0 + (best - 1) * p_step;
disp (["Tuning step for temperature ", num2str(best_temp)]);
p_0 = 0.01;
p_1 = 0.51;
p_step = 0.05;
mean_best_obj = \
    tune (["SA(@ObjFunc_mixture,2,10,10,",num2str(best_temp),","], ");", \
	  [p_0:p_step:p_1], 10, "step");
[best_val, best] = max (mean_best_obj);
best_step = p_0 + (best - 1) * p_step;
disp (["Best step for temperature ", num2str(best_temp), " is ", \
       num2str(best_step)]);

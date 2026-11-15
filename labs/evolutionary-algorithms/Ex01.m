[BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OBJECTIVE_FUNCTION, HISTORY_P] = SSGAM(@ObjFunc_KDOneMax, 40, 50, 50);



figure;

subplot(2, 1, 1);
hold on;
plot(HISTORY_OBJECTIVE_FUNCTION(:, 1), 'b--', 'linewidth', 2);
plot(HISTORY_OBJECTIVE_FUNCTION(:, 2), 'b--', 'linewidth', 2);
plot(HISTORY_OBJECTIVE_FUNCTION(:, 3), 'b-',  'linewidth', 2);
title('Objective function values in successive iterations');
xlabel('iteration');
ylabel('objective function value');
%axis([1, 50, 0, 40]);
%set(gca, 'xtick', [0:10:50]);
%set(gca, 'ytick', [0:10:40]);

subplot(2, 1, 2);
hold on;
plot(HISTORY_OBJECTIVE_FUNCTION(:, 4), 'b-', 'linewidth', 2);
title('Standard deviation of objective function values in successive iterations');
xlabel('iteration');
ylabel('std of objective function values');
%axis([1, 50, 0, 5]);
%set(gca, 'xtick', [0:10:50]);
%set(gca, 'ytick', [0:1:5]);



figure;
hold on;
plot(HISTORY_P, 'b-');
title('Gene values in successive iterations');
xlabel('iteration');
ylabel('average gene value');
%axis([1, 50, 0, 1]);
%set(gca, 'xtick', [0:10:50]);
%set(gca, 'ytick', [0.0:0.1:1.0]);

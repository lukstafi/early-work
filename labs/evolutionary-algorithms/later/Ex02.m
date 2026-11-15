global GaussMixtureMeans
global GaussMixtureStdDev
GaussMixtureMeans = [0.1,0.3;0.7,0.5;0.3,0.8]
GaussMixtureStdDev = [0.1, 0.03, 0.01]

N = 10
d = 2				% do not change d
iter = 10
Temperature = 5
Sigma = 0.1

[BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OBJECTIVE_FUNCTION, HISTORY_P] = SAviz(@ObjFunc_mixture, d, N, iter, Temperature, Sigma);

figure;

subplot(2, 1, 1);
hold on;
plot(HISTORY_OBJECTIVE_FUNCTION(:, 1), 'b--', 'linewidth', 2);
plot(HISTORY_OBJECTIVE_FUNCTION(:, 2), 'g--', 'linewidth', 2);
plot(HISTORY_OBJECTIVE_FUNCTION(:, 3), 'r-',  'linewidth', 2);
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

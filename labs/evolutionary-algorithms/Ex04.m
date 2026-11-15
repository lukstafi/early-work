global GaussMixtureMeans
global GaussMixtureVariances
GaussMixtureMeans = [0.1,0.3;0.7,0.5;0.3,0.8]
GaussMixtureVariances = [0.01, 0.003, 0.0005]

N = 10
d = 2
iter = 10
one_fifth = 1/3

[BEST_INDIVIDUAL, BEST_OBJECTIVE, HISTORY_OBJECTIVE_FUNCTION, \
 HISTORY_P] = SESviz(@ObjFunc_mixture, d, N, iter, \
				    one_fifth, [0.3,0.3,0.3], 3, 3);

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

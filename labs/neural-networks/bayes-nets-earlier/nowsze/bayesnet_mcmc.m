% Tutorial on Bayesian nets for BNT (Bayesian Net Toolbox by Kevin Murphy)
% Discretization into three-valued variables: values 'low', 'medium', 'high'

% By Lukasz Stafiniak 2006 lukstafi@gmail.com

load('spam.data');

n = 1;
sel(n)=1;  names{n} = 'make';       n = n + 1;
sel(n)=2;  names{n} = 'address';    n = n + 1;
sel(n)=3;  names{n} = 'all';        n = n + 1;
sel(n)=5;  names{n} = 'our';        n = n + 1;
sel(n)=6;  names{n} = 'over';       n = n + 1;
sel(n)=7;  names{n} = 'remove';     n = n + 1;
sel(n)=8;  names{n} = 'internet';   n = n + 1;
sel(n)=9;  names{n} = 'order';      n = n + 1;
sel(n)=10; names{n} = 'mail';       n = n + 1;
sel(n)=11; names{n} = 'receive';    n = n + 1;
sel(n)=12; names{n} = 'will';       n = n + 1;
sel(n)=13; names{n} = 'people';     n = n + 1;
sel(n)=14; names{n} = 'report';     n = n + 1;
sel(n)=15; names{n} = 'addresses';  n = n + 1;
sel(n)=16; names{n} = 'free';       n = n + 1;
sel(n)=17; names{n} = 'business';   n = n + 1;
sel(n)=18; names{n} = 'email';      n = n + 1;
sel(n)=19; names{n} = 'you';        n = n + 1;
sel(n)=20; names{n} = 'credit';     n = n + 1;
sel(n)=24; names{n} = 'money';      n = n + 1;
sel(n)=31; names{n} = 'telnet';     n = n + 1;
sel(n)=33; names{n} = 'data';       n = n + 1;
sel(n)=36; names{n} = 'technology'; n = n + 1;
sel(n)=38; names{n} = 'parts';      n = n + 1;
sel(n)=40; names{n} = 'direct';     n = n + 1;
sel(n)=42; names{n} = 'meeting';    n = n + 1;
sel(n)=43; names{n} = 'original';   n = n + 1;
sel(n)=44; names{n} = 'project';    n = n + 1;
sel(n)=47; names{n} = 'table';      n = n + 1;
sel(n)=48; names{n} = 'conference'; n = n + 1;
sel(n)=58; names{n} = 'spam';

spam = spam(:,sel);
data = spam;
[nobs, nvar] = size(spam);
T = spam(:,end);
stddev = std(spam(:,1:(nvar-1)));
smean = mean(spam(:,1:(nvar-1)));

% low: below half of standard deviation from mean
% medium: at mean
% high: above half of standard deviation from mean
ns = [2*ones(1,nvar-1),2];
spam(:,1:(nvar-1)) = ...
    (spam(:,1:(nvar-1)) > ones(nobs,1) * smean); % + ...
    %(spam(:,1:(nvar-1)) > ones(nobs,1) * (smean - stddev/2)) + ...
    %(spam(:,1:(nvar-1)) > ones(nobs,1) * (smean + stddev/2));

% Heuristic: No occurences is never a medium number of occurences
spam = spam .* (~(data == 0)) + ones(nobs, nvar);

samples = cell(nvar, nobs);
for i=1:nobs
  samples(:,i) = num2cell(spam(i,:)');
end

[sampled_graphs, accept_ratio, num_edges, best_bf, best_R, bfs, Rs, last] = ...
    learn_struct_mcmc2(samples, ns); %, 'scoring_fn', 'bic', 'nsamples', 10000)

if last == 0
    error('Canceled learn_struct_mcmc2 while still in burnin phase.');
end
figure;
subplot(4,1,1);
plot (accept_ratio);
title('Search acceptation ratio by number of iterations');
subplot(4,1,2);
plot (num_edges);
title('Number of edges');
subplot(4,1,3);
plot (bfs);
title('Bayes factor value of a try');
subplot(4,1,4);
plot (min(1,Rs));
title('Probability of acceptance of a try');

dag1 = sampled_graphs{last};
dag2 = sampled_graphs{best_bf};
dag3 = sampled_graphs{best_R};

figure;
draw_graph(dag1, names);
title('Bayes net for last step of MCMC');
if ~(best_bf == last)
    figure;
    draw_graph(dag2, names);
    title('Bayes net for best Bayes factor step of MCMC');
end
if ~(best_R == last | best_R == best_bf)
    figure;
    draw_graph(dag3, names);
    title('Bayes net for best probability of acceptance step of MCMC');
end

bnet1 = mk_bnet(dag1, ns, 'names', names);
seed = 0;
rand('state', seed);
for i=1:nvar
    bnet1.CPD{i} = tabular_CPD(bnet1, i, 'prior_type', 'dirichlet', 'dirichlet_weight', 0);
end
if ~(best_bf == last)
    bnet2 = mk_bnet(dag2, ns, 'names', names);
    seed = 0;
    rand('state', seed);
    for i=1:nvar
        bnet2.CPD{i} = tabular_CPD(bnet2, i, 'prior_type', 'dirichlet', 'dirichlet_weight', 0);
    end
end
if ~(best_R == last | best_R == best_bf)
    bnet3 = mk_bnet(dag3, ns, 'names', names);
    seed = 0;
    rand('state', seed);
    for i=1:nvar
        bnet3.CPD{i} = tabular_CPD(bnet3, i, 'prior_type', 'dirichlet', 'dirichlet_weight', 0);
    end
end

% Find MLEs from fully observed data
bnet1 = learn_params2(bnet1, samples);
if ~(best_bf == last)
    bnet2 = learn_params2(bnet2, samples);
end
if ~(best_R == last | best_R == best_bf)
    bnet3 = learn_params2(bnet3, samples);
end

% Inference engine
engine1 = jtree_inf_engine(bnet1);
if ~(best_bf == last)
    engine2 = jtree_inf_engine(bnet2);
end
if ~(best_R == last | best_R == best_bf)
    engine3 = jtree_inf_engine(bnet3);
end

% check efficiency
check_bnt_eff (engine1, bnet1.names{'spam'}, samples, T, 'last of CMCM run');
if ~(best_bf == last)
    check_bnt_eff (engine2, bnet2.names{'spam'}, samples, T, 'best Bayes factor');
end
if ~(best_R == last | best_R == best_bf)
    check_bnt_eff (engine3, bnet3.names{'spam'}, samples, T, 'best acceptance prob.');
end

% Examples of conditional probabilities

% probability being a spam given that frequency of 'money' is high
[p, desc] = bayesask(bnet1, engine1, 'spam', 2, 'money', 2);
disp(desc);

% probability being a spam given that frequency of 'conference' is high
[p, desc] = bayesask(bnet1, engine1, 'spam', 2, 'conference', 2);
disp(desc);

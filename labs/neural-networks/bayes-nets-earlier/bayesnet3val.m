% Tutorial on Bayesian nets for BNT (Bayesian Net Toolbox by Kevin Murphy)
% Discretization into three-valued variables: values 'low', 'medium', 'high'

% By Lukasz Stafiniak 2006 lukstafi@gmail.com

load('spam.data');

n = 1;
%sel(n)=1;  names{n} = 'make';       n = n + 1;
%sel(n)=2;  names{n} = 'address';    n = n + 1;
sel(n)=3;  names{n} = 'all';        n = n + 1;
%sel(n)=5;  names{n} = 'our';        n = n + 1;
sel(n)=6;  names{n} = 'over';       n = n + 1;
sel(n)=7;  names{n} = 'remove';     n = n + 1;
%sel(n)=8;  names{n} = 'internet';   n = n + 1;
%sel(n)=9;  names{n} = 'order';      n = n + 1;
%sel(n)=10; names{n} = 'mail';       n = n + 1;
sel(n)=11; names{n} = 'receive';    n = n + 1;
sel(n)=12; names{n} = 'will';       n = n + 1;
%sel(n)=13; names{n} = 'people';     n = n + 1;
sel(n)=14; names{n} = 'report';     n = n + 1;
%sel(n)=15; names{n} = 'addresses';  n = n + 1;
%sel(n)=16; names{n} = 'free';       n = n + 1;
%sel(n)=17; names{n} = 'business';   n = n + 1;
sel(n)=18; names{n} = 'email';      n = n + 1;
%sel(n)=19; names{n} = 'you';        n = n + 1;
sel(n)=20; names{n} = 'credit';     n = n + 1;
%sel(n)=24; names{n} = 'money';      n = n + 1;
%sel(n)=31; names{n} = 'telnet';     n = n + 1;
sel(n)=33; names{n} = 'data';       n = n + 1;
%sel(n)=36; names{n} = 'technology'; n = n + 1;
sel(n)=38; names{n} = 'parts';      n = n + 1;
sel(n)=40; names{n} = 'direct';     n = n + 1;
sel(n)=42; names{n} = 'meeting';    n = n + 1;
%sel(n)=43; names{n} = 'original';   n = n + 1;
sel(n)=44; names{n} = 'project';    n = n + 1;
%sel(n)=47; names{n} = 'table';      n = n + 1;
%sel(n)=48; names{n} = 'conference'; n = n + 1;
sel(n)=58; names{n} = 'spam';

spam = spam(:,sel);
data = spam;
[nobs, nvar] = size(spam);
T = spam(:,end);
stddev = std(spam(:,1:(nvar-1)));
smean = mean(spam(:,1:(nvar-1)));

% low: below half of standard deviation from mean
% high: above half of standard deviation from mean
spam(:,1:(nvar-1)) = ...
    (spam(:,1:(nvar-1)) > ones(nobs,1) * (smean - stddev/2)) + ...
    (spam(:,1:(nvar-1)) > ones(nobs,1) * (smean + stddev/2));
% Heuristic: No occurences is never a medium number of occurences
spam = spam .* (~(data == 0)) + ones(nobs, nvar);

samples = cell(nvar, nobs);
for i=1:nobs
  samples(:,i) = num2cell(spam(i,:)');
end

% preparation of training and testing sets
ispam = samples(:,T==1);
notspam = samples(:,T==0);
n_ispam = length(ispam)
n_notspam = length(notspam)
trn = [ispam(:,1:floor(n_ispam/2)), notspam(:,1:floor(n_notspam/2))];
test = [ispam(:,floor(n_ispam/2+1):n_ispam), ...
        notspam(:,floor(n_notspam/2+1):n_notspam)];
trn_tgt = [ones(floor(n_ispam/2),1); zeros(floor(n_notspam/2),1)];
test_tgt = [ones(ceil(n_ispam/2),1); zeros(ceil(n_notspam/2),1)];

%error('stop here');

ns = [3*ones(1,nvar-1),2];

dag = learn_struct_K2_2 (trn, ns, 1:nvar, 'verbose', 'yes', 'names', names);

draw_graph(dag, names);

bnet = mk_bnet(dag, ns, 'names', names);
seed = 0;
rand('state', seed);
for i=1:nvar
    bnet.CPD{i} = tabular_CPD(bnet, i, 'prior_type', 'dirichlet', 'dirichlet_weight', 0);
end

% Find MLEs from fully observed data
bnet = learn_params2(bnet, samples);

% Inference engine
engine = jtree_inf_engine(bnet);

% check efficiency
ev  = cell(1,nvar);
wbar = waitbar(0, 'Checking efficiency of the model - learning data', 'CreateCancelBtn', 'break');
for i=1:length(trn)
    waitbar(i/nobs,wbar);
    ev = trn(:,i);
    ev{nvar} = [];
    engine = enter_evidence(engine, ev);
    mS = marginal_nodes(engine, nvar);
    y(i) = mS.T(2);
end
delete(wbar);
conffig2(y', trn_tgt, 'BNET eff. learning data');

wbar = waitbar(0, 'Checking efficiency of the model - test data', 'CreateCancelBtn', 'break');
for i=1:length(test)
    waitbar(i/nobs,wbar);
    ev = test(:,i);
    ev{nvar} = [];
    engine = enter_evidence(engine, ev);
    mS = marginal_nodes(engine, nvar);
    y(i) = mS.T(2);
end
delete(wbar);
conffig2(y', test_tgt, 'BNET eff. test data');

% Examples of conditional probabilities

% probability being a spam given that frequency of 'money' is high
[p, desc] = bayesask(bnet, engine, 'spam', 2, 'money', 3);
disp(desc);

% probability being a spam given that frequency of 'conference' is high
[p, desc] = bayesask(bnet, engine, 'spam', 2, 'conference', 3);
disp(desc);

function [net, y] = turbo2lp_conf (train_set, train_tgt, nch, epsgood, glmsteps, glmapprox, test_set, test_tgt, nhidden, fcenter, simple, func, fvecs)
% Initialise first layer weights to vectors calculated by FVECS (CASCDISCR by default),
% set biases to separate class centers, train second layer with confnet (and optionally glmtrain).
%
% NET = TURBO2LP_CONF (TRAIN_SET, TRAIN_TGT)
% TRAIN_TGT must have rows with 1 in position indicating sample class, 0 in other positions.
%
% NET = TURBO2LP_CONF (TRAIN_SET, TRAIN_TGT, NCH, EPSGOOD, GLMSTEPS, GLMAPPROX, ...
%           TEST_SET, TEST_TGT, NHIDDEN, FCENTER, SIMPLE, FUNC, FVECS)
% NCH is the (max) number of candidate neurons checked for the efficiency requirement
% in one turn.
% EPSGOOD is the efficiency gain required to include the input considered.
% GLMSTEPS it the number of iterations of glmtrain, defaults to 1.
% GLMAPPROX, if 1, approximates the hessian by computing only the diagonal
% (much faster), defaults to 0.
% TEST_SET, TEST_TGT -- if not empty, perform evaluation of efficiency on the test data,
% default to [].
% NHIDDEN is the number of hidden neuron candidates, 0 means the maximal number, defaults to 0.
% FCENTER is used to find class centers, defaults to 'median', try 'mean' as an alternative.
% SIMPLE==1 -- split in the middle between centers,
% SIMPLE==0 -- bias based on sample distribution between centers, SIMPLE defaults to 1.
% FUNC -- activation function, one of: 'linear', 'logistic', 'softmax',
% FUNC defaults to 'softmax'.
% FVECS defaults to 'cascdiscr'.
% In FVECS(TRAIN_SET, TRAIN_TGT, K), K is the requested number of vectors,
% if K is not given, FVECS should return the maximal number of vectors.
% [NET, Y] = TRUBO2LP_CONF (...) returns in Y outputs for training sample

% By Lukasz Stafiniak 2005-2006 lukstafi@gmail.com

if nargin < 13, fvecs = 'cascdiscr'; end
if nargin < 12, func = 'softmax'; end
if nargin < 11, simple = 1; end
if nargin < 10, fcenter = 'median'; end
if nargin < 9, nhidden = 0; end
if nargin < 8, test_tgt = []; end
if nargin < 7, test_set = []; end
if nargin < 6, glmapprox = 0; end
if nargin < 5, glmsteps = 1; end
if nargin < 4, epsgood = 0; end
if nargin < 3, nch = 5; end
[nobs, nclasses] = size(train_tgt);
nout = nclasses;
nin = size(train_set,2);

% Preparing first-layer neuron candidates.
if nhidden==0
    vecs = feval (fvecs, train_set, train_tgt);
else
    vecs = feval (fvecs, train_set, train_tgt, ceil(nhidden/(nclasses-1)));
end
if ~(ceil(nhidden/(nclasses-1)) == size(vecs,2))
    nhidden = size(vecs,2) * (nclasses-1);
end
[w1, b1] = netlayer (train_set, train_tgt, vecs, nhidden, fcenter, simple);
H = tanh(train_set*w1 + ones(nobs, 1)*b1);
if ~isempty(test_set)
    tstH = tanh(test_set*w1 + ones(size(test_set, 1), 1)*b1);
end
% Selecting first-layer neurons and initializing second layer weights.
if isempty(test_set)
    [w2, sel, y, H, eff] = confnet (H, train_tgt, nch, epsgood, func);
else
    [w2, sel, y, H, eff, tstH, efftst] = confnet (H, train_tgt, nch, epsgood, func, tstH, test_tgt);
end
%display the efficiencies
figure;
hold on;
siz = length(eff);
plot(1:siz, eff, 'b-');
if ~isempty(test_set)
    plot(1:siz, efftst, 'r-');
    legend('train data', 'test data');
end
title('Efficiency by number of hidden neurons, before burnout with GLMTRAIN');
hold off;

nhidden = length(sel);
net = mlp (nin, nhidden, nout, func);
net.w1 = w1(:,sel);
net.b1 = b1(sel);


if glmsteps < 1
    net.w2 = w2;
    net.b2 = zeros(net.nhidden);
    return
end

% Burning out second layer by GLM
glmnet = glm (net.nhidden, nout, func);
glmnet.w1 = w2;
glmnet.b1 = zeros(1,nout);

options = foptions;
options(1) = 1;
options(5) = glmapprox;
options(14) = glmsteps;
if isempty(test_set)
    [glmnet, foo, eff2] = glmtrain2(glmnet, options, H, train_tgt);
else
    [glmnet, foo, eff2, efftst2] = glmtrain2(glmnet, options, H, train_tgt, tstH, test_tgt);
end

figure;
hold on;
siz = length(eff2);
plot(1:siz, eff2, 'b-');
if ~isempty(test_set)
    plot(1:siz, efftst2, 'r-');
    legend('train data', 'test data');
end
title('Efficiency by number of iterations of GLMTRAIN');
hold off;


net.w2 = glmnet.w1;
net.b2 = glmnet.b1;

if nargout > 1
    y = mlpfwd(net, train_set);
    conffig2(y, train_tgt, 'after GLMTRAIN');
end
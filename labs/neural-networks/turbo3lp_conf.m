function [net, y] = turbo3lp_conf (train_set, train_tgt, epsgood, glmsteps, glmapprox, nhidden2, test_set, test_tgt, nhidden1, fcenter, simple, func, fvecs)
% Initialise first and second layer weights to vectors calculated by FVECS (CASCDISCR by default),
% set biases to separate class centers, train second layer with CONFNET.
%
% NET = TURBO3LP_CONF (TRAIN_SET, TRAIN_TGT)
% TRAIN_TGT must have rows with 1 in position indicating sample class, 0 in other positions.
%
% NET = TURBO3LP_CONF (TRAIN_SET, TRAIN_TGT, CONFTOL, GLMSTEPS, GLMAPPROX, NHIDDEN2, TEST_SET, TEST_TGT, NHIDDEN1, FCENTER, SIMPLE, FUNC, FVECS)
% EPSGOOD is the efficiency gain required to include the input considered.
% GLMSTEPS it the number of iterations of glmtrain, defaults to 1.
% GLMAPPROX, if 1, approximates the hessian by computing only the diagonal
% (much faster), defaults to 0.
% NHIDDEN2 is the number of hidden neuron candidates, 0 means the maximal number, defaults to 0.
% TEST_SET, TEST_TGT -- if not empty, perform evaluation of efficiency on the test data,
% default to [].
% NHIDDEN1 is the number of first layer neurons, 0 means the maximal number, defaults to 0.
% FCENTER is used to find class centers, defaults to 'median', try 'mean' as an alternative.
% SIMPLE==1 -- split in the middle between centers,
% SIMPLE==0 -- bias based on sample distribution between centers, SIMPLE defaults to 1.
% FUNC -- activation function, one of: 'linear', 'logistic', 'softmax',
% FUNC defaults to 'softmax'.
% FVECS defaults to 'cascdiscr'.
% In FVECS(TRAIN_SET, TRAIN_TGT, K), K is the requested number of vectors,
% if K is not given, FVECS should return the maximal number of vectors.
% [NET, Y] = TRUBOMLP (...) returns in Y outputs for training sample

% By Lukasz Stafiniak 2005 lukstafi@gmail.com

if nargin < 13, fvecs = 'cascdiscr'; end
if nargin < 12, func = 'softmax'; end
if nargin < 11, simple = 1; end
if nargin < 10, fcenter = 'median'; end
if nargin < 9, nhidden1 = 0; end
if nargin < 8, test_tgt = []; end
if nargin < 7, test_set = []; end
if nargin < 6, nhidden2 = 0; end
if nargin < 5, glmapprox = 0; end
if nargin < 4, glmsteps = 1; end
if nargin < 3, epsgood = 0; end    % 90%
[nobs, nclasses] = size(train_tgt);
nout = nclasses;
nin = size(train_set,2);

% Preparing first-layer neurons.
if nhidden1==0
    vecs = feval (fvecs, train_set, train_tgt);
else
    vecs = feval (fvecs, train_set, train_tgt, ceil(nhidden1/(nclasses-1)));
end
if ~(ceil(nhidden1/(nclasses-1)) == size(vecs,2))
    nhidden1 = size(vecs,2) * (nclasses-1);
end
[w1, b1] = netlayer (train_set, train_tgt, vecs, nhidden1, fcenter, simple);
H1 = tanh(train_set*w1 + ones(nobs, 1)*b1);
if ~isempty(test_set)
    tstH1 = tanh(test_set*w1 + ones(size(test_set, 1), 1)*b1);
end

% Preparing second-layer neuron candidates.
if nhidden2==0
    vecs = feval (fvecs, H1, train_tgt);
else
    vecs = feval (fvecs, H1, train_tgt, ceil(nhidden2/(nclasses-1)));
end
if ~(ceil(nhidden2/(nclasses-1)) == size(vecs,2))
    nhidden2 = size(vecs,2) * (nclasses-1);
end
[w2, b2] = netlayer (H1, train_tgt, vecs, nhidden2, fcenter, simple);
H2 = tanh(H1*w2 + ones(nobs, 1)*b2);
if ~isempty(test_set)
    tstH2 = tanh(tstH1*w2 + ones(size(test_set, 1), 1)*b2);
end
% Selecting second-layer neurons and initializing third layer weights.
if isempty(test_set)
    [w3, sel, y, H2, eff] = confnet (H2, train_tgt, epsgood, func);
else
    [w3, sel, y, H2, eff, tstH2, efftst] = confnet (H2, train_tgt, epsgood, func, tstH2, test_tgt);
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
title('Efficiency by number of snd-layer hidden neurons, before burnout with GLMTRAIN');
hold off;

nhidden2 = length(sel);
net.type = 'mlp3l';
net.nin = nin;
net.nhidden1 = nhidden1;
net.nhidden2 = nhidden2;
net.nout = nout;
net.nwts = (nin + 1)*nhidden1 + (nhidden1 + 1)*nhidden2 + (nhidden2 + 1)*nout;
net.w1 = w1;
net.b1 = b1;
net.w2 = w2(:,sel);
net.b2 = b2(sel);


if glmsteps < 1
    net.w3 = w3;
    net.b3 = zeros(net.nhidden);
    return
end

% Burning out second layer by GLM
glmnet = glm (net.nhidden2, nout, func);
glmnet.w1 = w3;
glmnet.b1 = zeros(1,nout);

options = foptions;
options(1) = 1;
options(5) = glmapprox;
options(14) = glmsteps;
if isempty(test_set)
    [glmnet, foo, eff2] = glmtrain2(glmnet, options, H2, train_tgt);
else
    [glmnet, foo, eff2, efftst2] = glmtrain2(glmnet, options, H2, train_tgt, tstH2, test_tgt);
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


net.w3 = glmnet.w1;
net.b3 = glmnet.b1;

if nargout > 1
    y = mlp3lfwd(net, train_set);
    conffig2(y, train_tgt, 'after GLMTRAIN');
end
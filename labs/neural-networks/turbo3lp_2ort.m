function [net, output] = turbo3lp_2ort (train_set, train_tgt, orttol2, orttol1, nhidden2, nhidden1, fcenter, simple, func, fvecs)
% Initialise hidden layers weights to vectors calculated by FVECS (CASCDISCR by default),
% set biases to separate class centers, train third layer with glmtrain.
%
% NET = TURBOMLP (TRAIN_SET, TRAIN_TGT)
% TRAIN_TGT must have rows with 1 in position indicating sample class, 0 in other positions.
%
% NET = TURBOMLP (TRAIN_SET, TRAIN_TGT, GLMSTEPS, NHIDDEN2, NHIDDEN1, FCENTER, SIMPLE, FUNC, FVECS)
% NHIDDENx is the number of hidden neurons, 0 means the maximal number, defaults to 0.
% ORTTOL it the tolerance coefficient passed to ORTNET.
% FCENTER is used to find class centers, defaults to 'median', try 'mean' as an alternative.
% SIMPLE==1 -- split in the middle between centers,
% SIMPLE==0 -- bias based on sample distribution between centers, SIMPLE defaults to 1.
% FUNC -- activation function, one of: 'linear', 'logistic', 'softmax',
% FUNC defaults to 'softmax'.
% FVECS defaults to 'cascdiscr'.
% In FVECS(TRAIN_SET, TRAIN_TGT, K), K is the requested number of vectors,
% if K is not given, FVECS should return the maximal number of vectors.

% By Lukasz Stafiniak 2005 lukstafi@gmail.com

if nargin < 10, fvecs = 'cascdiscr'; end
if nargin < 9, func = 'logistic'; end
if nargin < 8, simple = 1; end
if nargin < 7, fcenter = 'median'; end
if nargin < 6, nhidden1 = 0; end
if nargin < 5, nhidden2 = 0; end
if nargin < 4, orttol1 = 0.9; end
if nargin < 3, orttol2 = 0.9; end
[nobs, nclasses] = size(train_tgt);
nout = nclasses;
nin = size(train_set,2);

% Initial first-layer weights.
disp ('Initializing first layer...');
if nhidden1==0
    vecs = feval (fvecs, train_set, train_tgt);
else
    vecs = feval (fvecs, train_set, train_tgt, ceil(nhidden1/(nclasses-1)));
end
if nhidden1==0, nhidden1 = size(vecs,2) * (nclasses-1); end
[layer1, bias1] = netlayer (train_set, train_tgt, vecs, nhidden1, fcenter, simple);

% Choosing neurons for first layer by ORTNET
disp ('Choosing neurons for first layer by ORTNET...');
snd_train_set = tanh(train_set*layer1 + ones(nobs, 1)*bias1);

[sel, layer2, bias2] = ortnet (snd_train_set, train_tgt, orttol1, func);
if isempty(bias2)
    bias2 = zeros (1, nhidden2);
end
nhidden1 = length(sel);
layer1 = layer1(:,sel);
bias1 = bias1(sel);
snd_train_set = snd_train_set(:,sel);

% Initial second-layer weights.
disp ('Initializing second layer...');
if nhidden2==0
    vecs = feval (fvecs, snd_train_set, train_tgt);
else
    vecs = feval (fvecs, snd_train_set, train_tgt, ceil(nhidden2/(nclasses-1)));
end
if nhidden2==0, nhidden2 = size(vecs,2) * (nclasses-1); end
[layer2, bias2] = netlayer (snd_train_set, train_tgt, vecs, nhidden2, fcenter, simple);

% Choosing neurons for second layer and initializing third layer by ORTNET
disp ('Initializing third (output) layer by ORTNET...');
trd_train_set = tanh(snd_train_set*layer2 + ones(nobs, 1)*bias2);

[sel, layer3, bias3] = ortnet (trd_train_set, train_tgt, orttol2, func);
if isempty(bias3)
    bias3 = zeros (1,nout);
end
nhidden2 = length(sel);
layer2 = layer2(:,sel);
bias2 = bias2(sel);

net.type = 'mlp3l';
net.nin = nin;
net.nhidden1 = nhidden1;
net.nhidden2 = nhidden2;
net.nout = nout;
net.nwts = (nin + 1)*nhidden1 + (nhidden1 + 1)*nhidden2 + (nhidden2 + 1)*nout;
net.w1 = layer1;
net.b1 = bias1;
net.w2 = layer2;
net.b2 = bias2;
net.w3 = layer3;
net.b3 = bias3;

if nargout > 1

    disp('Calculating output values...');
    trn = trd_train_set(:,sel);
    a = trn*net.w3 + ones(nobs, 1)*net.b3;
    output = outf (a, func);

end
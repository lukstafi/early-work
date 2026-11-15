function [vecs, canvals] = cascdiscr (X, T, K)
% CASCDISCR Compute canonical discrimination variates, in data space and then in
% orthogonal complement subspaces of the variates computed so far.
%
% [VECS, CANVALS] = canpc (X, T, K)
% X is the data, T is the target matrix, K is the number of vectors.
% VECS are the cascade canonical discrimination vectors in data space.
% CANVALS are the eigen values of VECS.

% By Lukasz Stafiniak 2005 lukstafi@gmail.com

global cascdiscr_break_ctrl;

nclasses = size(T, 2);
nobs = size(T, 1);
[ndata, nin] = size(X);
if nargin < 3
    K = nin;
end

wbar = waitbar(0, 'CASCDISCR: Computing vectors', 'CreateCancelBtn', ...
    'global cascdiscr_break_ctrl; cascdiscr_break_ctrl = 1');
if K < nclasses
    [CAN, PCA, cvals, pcavals] = canpc(X, T, K);
else
    [CAN, PCA, cvals, pcavals] = canpc(X, T);
end
vecs = CAN;
canvals = cvals;

HOME = PCA;
Y = X;
K0 = K;
K = K - length(canvals);
waitbar((K0-K)/K0, wbar, ['CASCDISCR: Computing vectors, biggest eig.val. ', num2str(cvals(1))]);
while K > 0
    % the projected data
    Y = Y*PCA;
    if K < nclasses
        [YCAN, PCA, cvals, pcavals] = canpc(Y, T, K);
    else
        [YCAN, PCA, cvals, pcavals] = canpc(Y, T);
    end
    % return to the data space
    CAN = HOME * YCAN;
    vecs = [vecs, CAN];
    canvals = [canvals; cvals];
    
    % next iteration   
    K = K - length(cvals);
    waitbar((K0-K)/K0, wbar, ['CASCDISCR: Computing vectors, biggest eig.val. ', num2str(cvals(1))]);
    if cascdiscr_break_ctrl
        break;
    end
    if K > 0, HOME = HOME * PCA; end
end
delete(wbar);

function [canvecs, pcavecs, canvals, pcavals] = canpc (X, T, K)
% CANPC Compute N canonical discrimination variates, and supply with K-N principal components.
%
% [CANVECS, PCAVECS, CANVALS, PCAVALS] = canpc (X, T, K)
% X is the data, T is the target matrix, K is the number of vectors.
% PCAVECS are principal vectors for orthogonal complement of CANVECS.
% CANVALS are the eigen values of CANVECS, PCAVALS are the eigen values of PCAVECS.

% By Lukasz Stafiniak 2005 lukstafi@gmail.com

nclasses = size(T, 2);
nobs = size(T, 1);
[ndata, nin] = size(X);
if nargin < 3
    K = nin;
end

N = min(nclasses - 1, nin);
if (K <= N)
    [canvals, canvecs] = canvar(X, T, K);
    pcavecs = [];
    pcavals = [];
else
    [canvals, canvecs] = canvar(X, T);
    CV=canvecs;
    Y = X;
    siz=size(canvecs,2);
    for i=1:siz
        %v is a column vector, X is a "list" of row vectors
        v=CV(:,1);
        Y=Y-(((Y*v)./(v'*v))*ones(1,nin)).*(ones(nobs,1)*v');
        if i<siz
            CV=CV(:,2:end);
            for j=1:(siz-i)
                w=CV(:,j);
                CV(:,j)=w-((w'*v)/(v'*v))*v;
            end
        end
    end
    [pcavals, pcavecs] = pca(Y, K-N);
    % vecs = [canvecs, pcavecs];
end
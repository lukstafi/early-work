function [flayer, fbias] = netlayer (train_set, train_tgt, vecs, nhidden, fcenter, simple)

% By Lukasz Stafiniak 2005 lukstafi@gmail.com

[nobs, nclasses] = size(train_tgt);
if nargin < 6, simple = 1; end
if nargin < 5, fcenter = 'median'; end
if nargin < 4 | nhidden == 0, nhidden = size(vecs,2)*(nclasses-1); end

nfull = floor(nhidden/(nclasses-1));
flayer = [];
for i=1:nfull
    v=vecs(:,i);
    flayer = [flayer, v*ones(1,nclasses-1)];
end
flayer = [flayer, vecs(:,end)*ones(1,nhidden-nfull*(nclasses-1))];

% Computing biases to smartly (?) separate classes.
fbias = [];
for v=vecs
    proj=train_set*v;
    for c = 1:nclasses
        c_center(c) = feval(fcenter, proj(train_tgt(:,c)==1));
    end
    [thres, I] = sort(c_center);
    if simple
        biases = (thres(1:(nclasses-1))+(thres(2:end)-thres(1:(nclasses-1)))/2);
    else
        pts = proj(train_tgt(:,I(1))==1);
        lmed(1) = median(pts(pts >= thres(1) & pts <= thres(2)));
        for i=2:nclasses-1
            pts = proj(train_tgt(:,I(i))==1);
            lmed(i) = median(pts(pts >= thres(i) & pts <= thres(i+1)));
            rmed(i-1) = median(pts(pts >= thres(i-1) & pts <= thres(i)));
        end
        pts = proj(train_tgt(:,I(nclasses))==1);
        rmed(i) = median(pts(pts >= thres(i) & pts <= thres(nclasses)));
        biases = (lmed >= rmed).*(thres(1:(nclasses-1))+(thres(2:end)- ...
            thres(1:(nclasses-1)))/2) + (lmed < rmed).*(lmed + (rmed - lmed)/2);
    end
    fbias = [fbias, biases];
end
fbias = -fbias(1:nhidden);

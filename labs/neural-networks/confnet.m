function [wghts, sel, y, X, eff, tstX, efftst] = confnet (X, T, nch, epsgood, func, tstX, tstT)
% A simple single-layer net training reminiscent of Bayes nets
% with heuristic search for relevant inputs (net structure).
%
% [WGHTS, SEL, Y, X, EFF] = CONFNET (X, T, NCH, EPSGOOD, FUNC)
% Compute WGHTS (biases equal zero) of a net that best maps SELected columns of X to T.
% T encodes target classes as vectors with 1 in position of target class, 0 otherwise.
% NCH is the (max) number of candidate neurons checked for the efficiency requirement
% in one turn.
% EPSGOOD is the efficiency gain required to include the input considered.
% FUNC is the output function, one of: 'linear', 'softmax', 'max'; defaults to 'softmax'.
% WGHTS are the learned weights (biases are zero in this model).
% SEL are the indices of selected inputs.
% Y is the output of the net.
% X are the selected inputs (in order corresponding to SEL).
% EFF are the efficiencies for consecutive numbers of inputs.
% [WGHTS, SEL, Y, X, EFF, TSTX, EFFTST] = CONFNET (X, T, NCH, EPSGOOD, FUNC, TSTX, TSTT)
% -- calculate efficiencies also for the test data

% By Lukasz Stafiniak 2005-2006 lukstafi@gmail.com

global confnet_break_ctrl;

[nobs, nin] = size(X);
nout = size(T,2);

%Recode target from 0-1 to bipolar encoding
Tb = 2*T - 1;

wghts = (X'*Tb) ./ nobs;
y = outf(X*wghts, func);
conffig2(y, T, ['all ' num2str(nin) ' inputs']);

confnet_break_ctrl = 0;
wbar = waitbar(1/nin, 'CONFNET: Selecting inputs', 'CreateCancelBtn', ...
    'global confnet_break_ctrl; confnet_break_ctrl = 1');

% separation properties: how well does k separate i and j
% the lower the better
for k=1:nin
    for i=1:nout
        for j=1:nout
            sep(i,j,k) = wghts(k,i) * wghts(k,j);
            %worse heuristic: 1-abs(wghts(k,i) - wghts(k,j));
        end
    end
end

k = 1;
y = outf(X(:,1)*wghts(1,:), func);
[cmat, effi] = confmat(y, T);
eff(1) = effi(1);
if nargin > 4
    ytst = outf(tstX(:,1)*wghts(1,:), func);
    [foo, effitst] = confmat(ytst, tstT);
    efftst(1) = effi(1);
end
cmat = cmat + cmat';    % symetrisation of confusion
cmat = cmat .* (ones(nout,nout) - eye(nout));   % remove the diagonal
sel = 1:nin;
% nin will decrease, when we will discard inputs
% k will increase, when we will select inputs
k = 2;
looserun = 0;
while k <= nin
    waitbar(max(k/nin, looserun/(nout*(nout-1)/2)), wbar, ['CONFNET: Selecting inputs, k=' num2str(k) ...
            ', end=' num2str(looserun) ' / ' num2str(nout*(nout-1)/2) ', eff=' num2str(eff(k-1))]);
    if confnet_break_ctrl
        break;
    end
    looserun = looserun + 1;
    % find the worst separated classes
    [foo, i] = max(cmat);
    [bar, j] = max(foo);
    i = i(j);
    if cmat(i,j)==0
        break;
    end
    % find the input that will best separate i and j
    [foo, Icand] = sort(sep(i,j,k:nin));
    % and will increase the efficiency
    for c=1:min(nch, ceil((nin-k+1)/2))
        Ik = Icand(c) + k - 1;
        y = outf([X(:,1:(k-1)),X(:,Ik)]*[wghts(1:(k-1),:);wghts(Ik,:)], func);
        acteff = efficiency(y, T);
        if confnet2_break_ctrl
            break;
        end
        if acteff - eff(k-1) > epsgood
            break;
        end
    end
    if acteff - eff(k-1) > epsgood
        if ~(Ik==k)
            waux = wghts(k,:); wghts(k,:) = wghts(Ik,:); wghts(Ik,:) = waux;
            Xaux = X(:,k); X(:,k) = X(:,Ik); X(:,Ik) = Xaux;
            if nargin > 4
                Xaux = tstX(:,k); tstX(:,k) = tstX(:,Ik); tstX(:,Ik) = Xaux;
            end
            saux = sep(:,:,k); sep(:,:,k) = sep(:,:,Ik); sep(:,:,Ik) = saux;
            selx = sel(k); sel(k) = sel(Ik); sel(Ik) = selx;
        end
        [cmat, effi] = confmat(y, T);
        eff(k) = effi(1);
        if nargin > 4
            ytst = outf(tstX(:,1:k)*wghts(1:k,:), func);
            efftst(k) = efficiency(ytst,tstT);
        end
        cmat = cmat + cmat';    % symetrisation of confusion
        cmat = cmat .* (ones(nout,nout) - eye(nout));   % remove the diagonal
        k = k + 1;
        looserun = 0;
    else 
        % consider some other classes next time
        cmat(i,j) = 0; cmat(j,i) = 0;
    end
end
delete(wbar);
k = k - 1;
y = outf(X(:,1:k))*wghts(1:k,:), func);
conffig2(y, T, ['selected ' num2str(k) ' inputs (tst)']);
sel = sel(1:k);
wghts = wghts(1:k,:);
X = X(:,1:k);
if nargin > 4
    tstX = tstX(:,1:k);
end
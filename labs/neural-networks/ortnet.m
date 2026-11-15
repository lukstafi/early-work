function [sel, wghts, bss] = ortnet (F, D, tol, func)
% Select inputs and generate output layer using orthogonalisation.
%
% [SEL, WGHTS, BSS] = ORTNET (F, TGT, TOL)
% F -- input matrix, each row corresponds to a training sample input
% D -- target matrix, each row corresponds to a target
% ORTNET approximates the function: F(i,:) |--> TGT(i,:)
% TOL -- the tolerance coefficient (the higher the more inputs are chosen)
% FUNC -- activation function, one of: 'linear', 'tanh', 'logistic'
% SEL -- selected inputs' indices
% WGHTS -- weights of the computed output layer
% BSS -- biases of the computed output layer

% By Lukasz Stafiniak 2005 lukstafi@gmail.com

[nobs, nin] = size(F);
nout = size(D,2);

%Extending F to include biases into weights
F = [F, ones(nobs,1)];
K = nin+1;

%for func='linear'
% D = F*W + err = Q*G + err,
%where F = Q*A, G = A*W, Q'*Q is diagonal, A is upper triangular
% D'*D = (Q*G)'*(Q*G) + err'*(..) + (..)*err =
% = G'*(Q'*Q)*G + err'*(..) + (..)*err =
%% by diagonality of Q'*Q
% = sum(g_i.^2*q_i'*q_i) + err'*(..) + (..)*err
%coefficient of importance of input-output pairing:
% E(i,j) = g_i.^2*q_i'*q_i ./ (d_j'*d_j)
%generally:
% D = func(F*W) + err = func(Q*G) + err
% D - err = func(Q*G)
% func^{-1}(D - err) = Q*G
% func^{-1}(D - err)'*func^{-1}(D - err) = (Q*G)'*(Q*G)
%% by diagonality of Q'*Q
% = sum(g_i.^2*q_i'*q_i)
%coefficient of importance of input-output pairing:
% E(i,j) = g_i.^2*q_i'*q_i ./ (func^{-1}(D_j)'*func^{-1}(D_j))


wbar = waitbar(0, 'ORTNET: Selecting inputs', 'CreateCancelBtn', 'break');
%initial values:
Q = F;
G = [];
D = invf(D, func);
% Columns of G correspond to output neurons
for q=Q, G = [G; (q'*D) / (q'*q)]; end
% "Output by input"
% coeff. of importance
for i=1:K
    for j=1:nout
        E(i,j) = G(i,j)*G(i,j)*Q(:,i)'*Q(:,i)/(D(:,j)'*D(:,j));
    end
end

% sum over outputs
E = mean(E,2);
[eee, I1] = max(E);
sel = I1;
if ~(I1==1)
    perm = [I1,2:(I1-1),1,(I1+1):K];
    Q = Q(:,perm);
    G = G(perm,:);
    F = F(:,perm);
    E = E(perm);
end
%loop -- choosing best inputs
A = []; k = 1; sel = 1:K;
B(1,1) = 1;
err = E(1);
tdif = max(0.001, 1 - tol);
while (1 - err < tol) & k < nin
    if err - 1 + tol > tdif
        errbar = (log(err-1+tol)/log(tdif))/2;
    else
        errbar = 1 - (err-1+tol)*(1/tdif)/2;
    end
    waitbar(errbar, wbar, ['ORTNET: Selecting inputs ' num2str(k)]);
    k = k + 1;
    for i=k:K
        for j=1:(k-1)
            A(i,j,k) = (Q(:,j)'*F(:,i)) ./ (Q(:,j)'*Q(:,j));
        end
        Q(:,i) = F(:,i) - Q(:,[1:(k-1)])*reshape(A(i,[1:(k-1)],k),k-1,1);
        G(i,:) = (Q(:,i)'*D) / (Q(:,i)'*Q(:,i));
        for j=1:nout
            E(i,j) = G(i,j)*G(i,j)*Q(:,i)'*Q(:,i)/(D(:,j)'*D(:,j));
        end
    end
    E = mean(E,2);
    [eee, Ik] = max(E(k:end));
    Ik = Ik+k-1;
    if ~(Ik==k)
        perm=[1:(k-1),Ik,(k+1):(Ik-1),k,(Ik+1):K];
        Q = Q(:,perm);
        G = G(perm,:);
        F = F(:,perm);
        E = E(perm);
        sel = sel(perm);
    end
    for j=1:(k-1)
        B(j,k) = A(Ik,j,k);
    end
    B(k,k) = 1;
    err = sum(E(1:k));
end
delete(wbar);
% B is A now
W = B\G(1:k,:);
sel = sel(1:k);
wghts = W(~(sel == K),:);
Bi = find(sel == K);
if isempty(Bi)
    bss = [];
else
    bss = W(Bi(1),:);
end
sel = sel(~(sel == K));
function [errs, effs1, effs2, effs3, best, best_val] = errorviz_err(n_iter, n_runs, nin, nhidden, nout, func, optmet, train_set, train_tgt, test_set, test_tgt)
% Wyznacz bledy w kolejnych iteracjach dla wielu przebiegow uczenia sieci MLP w zadaniu klasyfikacji
%
% [errs, effs1, effs2, best, best_val] = errorviz_err(n_iter, n_runs, ...
%  nin, nhidden, nout, func, optmet, train_set, train_tgt, test_set, test_tgt)
%
% N_ITER -- rozpatrywana ilosc iteracji; N_RUNS -- liczba przebiegow;
% NIN..FUNC -- parametry sieci; OPTMET -- algorytm optymalizacji;
% TRAIN_SET..TEST_TGT -- dane
% ERRS -- bledy klasyfikacji 'cross-entropy';
% EFFS1 -- skutecznosc klasyfikacji na zbiorze uczacym;
% EFFS2 -- skutecznosc klasyfikacji na zbiorze testowym
% EFFS3 -- laczna skutecznosc (zb. uczacy + testowy)
% BEST -- siec o najlepszej skutecznosci lacznej;
% BEST_VAL -- jej skutecznosc laczna

% By Lukasz Stafiniak 2005 lukstafi@gmail.com

%not proofchecked

options = foptions;
options(1) = 0;
options(14) = n_iter;
errs(n_iter+1,n_runs)=0;
effs1(n_iter+1,n_runs)=0;
effs2(n_iter+1,n_runs)=0;
effs3(n_iter+1,n_runs)=0;
best_val = 0;
s1 = size(train_set); s2 = size(test_set);
total_sampl = s1(1) + s2(1);
wbar = waitbar(0, 'Multiple runs of MLP training statistics', 'CreateCancelBtn', 'break');
for i=1:n_runs
    mlpnet = mlp(nin, nhidden, nout, func);
    [mlpnet, op, er, netw] = netopt(mlpnet, options, train_set, train_tgt, optmet);
    waitbar(i/n, wbar);
    siz=size(er); siz=prod(siz);
    for j=1:(n_iter+1)
        if j<=siz
            errs(j,i)=er(j);
            mlpnet=mlpunpak(mlpnet,netw(j,:));
            mlpY = mlpfwd(mlpnet, train_set);
            [matA, rate2] = confmat(mlpY, train_tgt);
            effs1(j,i)=rate2(1);
            mlpY = mlpfwd(mlpnet, test_set);
            [matA, rate3] = confmat(mlpY, test_tgt);
            effs2(j,i)=rate3(1);
            effs3(j,i)=(rate2(2)+rate3(2))/total_sampl;
            if best_val < effs3(j,i)
                best = mlpnet;
                best_val = effs3(j,i);
            end
        else
            errs(j,i)=er(siz);
            effs1(j,i)=effs1(siz,i);
            effs2(j,i)=effs2(siz,i);
            effs3(j,i)=effs3(siz,i);
        end
    end
end
delete(wbar);
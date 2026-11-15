function [errs, effs1, effs2, effs3, best, best_val] = errorviz_onerun(mlpnet, n_iter, optmet, comment, train_set, train_tgt, test_set, test_tgt)
% Visualisation of error / efficiency by iterations of MLP learning, for single run.
%
% [ERRS, EFFS1, EFFS2, EFFS3, BEST, BEST_VAL] = ERRORVIZ_ONERUN(MLPNET, N_ITER, OPTMET, ...
%    COMMENT, TRAIN_SET, TRAIN_TGT, TEST_SET, TEST_TGT)
% MLPNET -- the MLP net to train
% N_ITER -- number of iterations
% OPTMET -- matlab standard optimalisation function (e.g. 'conjgrad', 'scg', 'quasinew')
% COMMENT -- a comment string
% TRAIN_SET, TEST_SET -- input data, each row is an observation
% TRAIN_TGT, TEST_TGT -- expected output; classes encoded as 0-1 rows with position indicating class

% By Lukasz Stafiniak 2005 lukstafi@gmail.com

options = foptions;
options(14) = n_iter;
errs(n_iter+1)=0;
effs1(n_iter+1)=0;
effs2(n_iter+1)=0;
effs3(n_iter+1)=0;
best_val = 0;
s1 = size(train_set); s2 = size(test_set);
total_sampl = s1(1) + s2(1);

[mlpnet, op, er, netw] = netopt(mlpnet, options, train_set, train_tgt, optmet);
siz=length(er);
for j=1:(n_iter+1)
    if j<=siz
            errs(j)=er(j);
            mlpnet=mlpunpak(mlpnet,netw(j,:));
            mlpY = mlpfwd(mlpnet, train_set);
            [matA, rate2] = confmat(mlpY, train_tgt);
            effs1(j)=rate2(1);
            mlpY = mlpfwd(mlpnet, test_set);
            [matA, rate3] = confmat(mlpY, test_tgt);
            effs2(j)=rate3(1);
            effs3(j)=(rate2(2)+rate3(2))/total_sampl;
            if best_val < effs3(j)
                best = mlpnet;
                best_val = effs3(j);
            end
    else
            errs(j)=er(siz);
            effs1(j)=effs1(siz);
            effs2(j)=effs2(siz);
            effs3(j)=effs3(siz);
    end
end

wykres(errs)
ylabel ('blad cross-entropy')
if length(comment)==0
    titl='Blad uczenia w kolejnych iteracjach dla wielu powtorzen'
else
    titl=['Blad uczenia w kolejnych iteracjach dla wielu powtorzen -- ', comment]
end
title (titl)
hold off

wykres(effs1)
ylabel ('skutecznosc na zbiorze uczacym %')
if length(comment)==0
    titl='Skutecznosc uczenia w kolejnych iteracjach dla wielu powtorzen'
else
    titl=['Skutecznosc uczenia w kolejnych iteracjach dla wielu powtorzen -- ', comment]
end
title (titl)
hold off

wykres(effs2)
ylabel ('skutecznosc na zbiorze testowym %')
if length(comment)==0
    titl='Skutecznosc uczenia w kolejnych iteracjach dla wielu powtorzen'
else
    titl=['Skutecznosc uczenia w kolejnych iteracjach dla wielu powtorzen -- ', comment]
end
title (titl)
hold off

wykres(effs3)
ylabel ('skutecznosc laczna %')
if length(comment)==0
    titl='Skutecznosc uczenia w kolejnych iteracjach dla wielu powtorzen'
else
    titl=['Skutecznosc uczenia w kolejnych iteracjach dla wielu powtorzen -- ', comment]
end
title (titl)
hold off

siz = size(effs1); siz = siz(1);
korel(siz)=0; tot_korel(siz)=0;
for i=1:siz
    ccf = corrcoef(effs1(i,:),effs2(i,:));
    korel(i) = ccf(1,2);
    train=effs1(1:i); test=effs2(1:i);
    train=reshape(train,[prod(size(train)),1]);
    test=reshape(test,[prod(size(test)),1]);
    ccf2 = corrcoef(train,test);
    tot_korel(i) = ccf2(1,2);
end

figure
hold on
plot (1:siz, korel, 'k:')
plot (1:siz, tot_korel, 'r-')
xlabel ('il. iteracji')
ylabel ('korelacja')
if length(comment)==0
    titl='Korelacja skutecznosci na zbiorze uczacym i testowym'
else
    titl=['Korelacja skutecznosci na zbiorze uczacym i testowym -- ', comment]
end
title (titl)
legend ('chwilowa','laczna');
hold off

function wykres(errs)

siz = length(errs);

figure
hold on
plot (1:siz, errs, 'b-')
xlabel ('il. iteracji')

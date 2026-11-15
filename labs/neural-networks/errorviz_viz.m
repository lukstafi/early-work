function [corr, tot_corr] = errorviz_viz(errs, effs1, effs2, effs3, comment)
% Visualisation of error / efficiency by iterations of learning algorithms, for multiple runs.
% Pass results of errorviz_err as arguments.
%
% [CORR, TOT_CORR] = ERRORVIZ_VIZ(ERRS, EFFS1, EFFS2, EFFS3, COMMENT)
% Pass as ERRS..EFFS3 the results from ERRORVIZ_ERR. COMMENT is a comment string.

% By Lukasz Stafiniak 2005 lukstafi@gmail.com

%not proofchecked

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
    train=effs1(1:i,:); test=effs2(1:i,:);
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

siz = size(errs); siz = siz(1);

for i=1:siz
    srednia(i)=mean(errs(i,:));
    mediana(i)=median(errs(i,:));
    odchylenie(i)=std(errs(i,:));
    max_e(i)=max(errs(i,:));
    min_e(i)=min(errs(i,:));
end

figure
hold on
plot (1:siz, srednia-odchylenie, 'b-')
plot (1:siz, srednia+odchylenie, 'b-')
plot (1:siz, mediana, 'r-')
plot (1:siz, max_e, 'r-.')
plot (1:siz, min_e, 'r-.')
plot (1:siz, errs(:,1)', 'g:')
xlabel ('il. iteracji')
legend ('srednia - odchylenie std.','srednia + odchylenie std.', ...
    'mediana', 'blad maksymalny', 'blad minimalny', 'przykladowy przebieg')

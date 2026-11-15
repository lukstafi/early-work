clear;
n_iter = 20;

Data;
options = foptions;
options(1) = 0;
options(14) = n_iter;
for i=1:10
    logtext = ['Przebieg ', int2str(i), ' ***'];
    disp (logtext);
    mlpnet = mlp(36, 30, 7, 'softmax');
    [mlpnet, op, er, netw] = netopt(mlpnet, options, satTrn(:, 1:36), satTrnTarget, 'conjgrad');
    errs1(:,i)=er;
    for j=1:(n_iter+1)
        mlpnet=mlpunpak(mlpnet,netw(j,:));
        mlpY = mlpfwd(mlpnet, satTrn(:, 1:36));
        [matA, rate] = confmat(mlpY, satTrnTarget);
        errs2(j,i)=rate(1);
        mlpY = mlpfwd(mlpnet, satTst(:, 1:36));
        [matA, rate] = confmat(mlpY, satTstTarget);
        errs3(j,i)=rate(1);
    end
end


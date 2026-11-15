function [net, errs1, errs2, errs3, errs4, decs, dists, best, best_val] = simann3_cl(R0, Tmax, deg, n_steps, n_iter, burnout, nin, nhidden, nout, func, optmet, train_set, train_tgt, test_set, test_tgt)

% By Lukasz Stafiniak 2005 lukstafi@gmail.com

%not proofchecked

errs1(n_steps+burnout/n_iter) = 0;
errs2(n_steps+burnout/n_iter) = 0;
errs3(n_steps+burnout/n_iter) = 0;
errs4(n_steps+burnout/n_iter) = 0;

options = foptions;
options(1) = 0;
options(14) = n_iter;

best_val = 0;
s1 = size(train_set); s2 = size(test_set);
total_sampl = s1(1) + s2(1);

net = mlp(nin, nhidden, nout, func);

E = mlperr(net, train_set, train_tgt);
last_E = E;
last = net;

for i=1:n_steps
    net1 = net;
    radius = R0*((n_steps-i+1)/n_steps)^deg;
    T = Tmax*((n_steps-i+1)/n_steps)^deg;
    net1.w1 = net1.w1 + (randn(nin, nhidden)/sqrt(nin + 1))*radius;
    net1.b1 = net1.b1 + (randn(1, nhidden)/sqrt(nin + 1))*radius;
    net1.w2 = net1.w2 + (randn(nhidden, nout)/sqrt(nhidden + 1))*radius;
    net1.b2 = net1.b2 + (randn(1, nout)/sqrt(nhidden + 1))*radius;

    [net1, op] = netopt(net1, options, train_set, train_tgt, optmet);

    E1 = mlperr(net1, train_set, train_tgt);
    DE = E1 - E;
    if DE < 0 | exp(-DE/T) > rand(1)
        if DE < 0
            dec = -1;
        else
            dec = 1;
        end
        net = net1;
        E = E1;
    else
        dec = 0;
    end

    packed = netpak(net) - netpak(last);
    dist = sqrt(packed * packed');

    if E < last_E
        last_E = E;
        last = net;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %tylko wizualizacja
    decs(i)=dec;
    errs1(i)=E;
    if ~(dec==0) | i==1
        mlpY = mlpfwd(net, train_set);
        [matA, rate2] = confmat(mlpY, train_tgt);
        trneff=rate2(1);
        mlpY = mlpfwd(net, test_set);
        [matA, rate3] = confmat(mlpY, test_tgt);
        tsteff=rate3(1);
        toteff=(rate2(2)+rate3(2))/total_sampl;
        if best_val < toteff
            best = net;
            best_val = toteff;
        end
    end
        
    errs2(i)=trneff;
    errs3(i)=tsteff;
    errs4(i)=toteff;
    dists(i)=dist;
    %%%%%%%%%%%%%%%%%%%%

        %if round(i/5)*5 == i
        disp (['K ', int2str(i), ' *** E=', num2str(E), ...
                ' DE=', num2str(DE), ' T=', num2str(T), ' dec=', int2str(dec), ...
                ' trn=', num2str(trneff), ' tst=', num2str(tsteff), ' dist=', num2str(dist), ...
                ' to ', num2str(last_E)]);
        %end

end

%burnout phase
options(14) = burnout;

disp('burnout...');
[net, op, er, netw] = netopt(net, options, train_set, train_tgt, optmet);
disp('...done');

siz=size(er); siz=prod(siz);
for j=1:5:(burnout+1)
    i=i+1;
    if j<=siz
        lasti = i;
        errs1(i)=er(j);
        mlpnet=mlpunpak(net,netw(j,:));
        mlpY = mlpfwd(mlpnet, train_set);
        [matA, rate2] = confmat(mlpY, train_tgt);
        errs2(i)=rate2(1);
        mlpY = mlpfwd(mlpnet, test_set);
        [matA, rate3] = confmat(mlpY, test_tgt);
        errs3(i)=rate3(1);
        errs4(i)=(rate2(2)+rate3(2))/total_sampl;
        if best_val < errs4(i)
            best = mlpnet;
            best_val = errs4(i);
        end
    else
        errs1(i)=errs1(lasti);
        errs2(i)=errs2(lasti);
        errs3(i)=errs3(lasti);
        errs4(i)=errs4(lasti);
    end
end

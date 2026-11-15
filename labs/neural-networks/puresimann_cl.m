function [errs1, errs2, errs3, errs4, decs, best, best_val] = puresimann_cl(R0, Tmax, n_steps, nin, nhidden, nout, func, train_set, train_tgt, test_set, test_tgt)

% By Lukasz Stafiniak 2005 lukstafi@gmail.com

% not proofchecked

errs1(n_steps) = 0;
errs2(n_steps) = 0;
errs3(n_steps) = 0;
errs4(n_steps) = 0;

best_val = 0;
s1 = size(train_set); s2 = size(test_set);
total_sampl = s1(1) + s2(1);

net = mlp(nin, nhidden, nout, func);

E = mlperr(net, train_set, train_tgt);
n_iter = 0;
pos = 0;
radius = 1;

for i=1:n_steps
    net1 = net;
    radius = R0*((n_steps-i+1)/n_steps)^2;
    T = Tmax*((n_steps-i+1)/n_steps)^2;
    net1.w1 = net1.w1 + (randn(nin, nhidden)/sqrt(nin + 1))*radius;
    net1.b1 = net1.b1 + (randn(1, nhidden)/sqrt(nin + 1))*radius;
    net1.w2 = net1.w2 + (randn(nhidden, nout)/sqrt(nhidden + 1))*radius;
    net1.b2 = net1.b2 + (randn(1, nout)/sqrt(nhidden + 1))*radius;

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

    if round(i/5)*5 == i
        disp (['Krok ', int2str(i), ' *** E = ', num2str(E), ...
                ' DE = ', num2str(DE), ' T = ', num2str(T), ' dec = ', int2str(dec)]);
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
    %%%%%%%%%%%%%%%%%%%%
    
end
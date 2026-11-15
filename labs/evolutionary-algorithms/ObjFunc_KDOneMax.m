% K-Deceptive OneMax

function y = ObjFunc_KDOneMax(x);

y = [];
for i = 1 : size(x, 1);
    t = sum(x(i, : ));
    if(sum(x(i, 1 : 10)) == 0);
        t = t + 11;
    end;
    if(sum(x(i, 11 : 20)) == 0);
        t = t + 11;        
    end;
    if(sum(x(i, 21 : 30)) == 0);
        t = t + 11;        
    end;
    if(sum(x(i, 31 : 40)) == 0);
        t = t + 11;
    end;
    y = [y; t];
end;

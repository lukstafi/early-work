% K-Deceptive OneMax

function y = ObjFunc_KDOneMax(x);

y = [];
for i = 1 : size(x, 1);
    t = sum(x(i, : ));
    if(sum(x(i, 1 : 3)) == 0);
        t = t + 4;
    end;
    if(sum(x(i, 4 : 6)) == 0);
        t = t + 4;        
    end;
    if(sum(x(i, 7 : 9)) == 0);
        t = t + 4;        
    end;
    if(sum(x(i, 10 : 12)) == 0);
        t = t + 4;
    end;
    y = [y; t];
end;

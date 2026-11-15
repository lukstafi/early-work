% Comparizon of one-point and uniform crossover

disp ('Comparizon of multistart simulated annealing and evolutionary strategy.');
compare ('SAMS(@ObjFunc_mixture,2,10,10, 0.21, 0.26);', 'SAMS', 'SES(@ObjFunc_mixture, 2,10,10, 1/3, [0.3,0.3,0.3], 3, 3);', 'ES', 30);

disp ('Comparizon of one-point and uniform crossover on difficult 10-Deceptive OneMax.');
compare ('SSGAM(@ObjFunc_KDOneMax,40,50,50, 0.1, 0.25);', 'uniform', 'SSGAMOX(@ObjFunc_KDOneMax,40,50,50, 0.1, 0.25);', 'one-point', 10);

disp ('Comparizon of one-point and uniform crossover on simple 3-Deceptive OneMax.');
compare ('SSGAM(@ObjFunc_3DOneMax,12,50,100, 0.1, 0.25);', 'uniform', 'SSGAMOX(@ObjFunc_3DOneMax,12,50,100, 0.1, 0.25);', 'one-point', 10);

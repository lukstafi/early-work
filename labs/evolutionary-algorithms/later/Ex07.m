% Comparizon of binary and Gray coding

global GaussMixtureParams
GaussMixtureParams = [0.2, 0.1; 0.5, 0.03; 0.8, 0.01]

disp ('Comparizon of gray and exp-binary coding.');
compare ('SSGAMOXgray(@ObjFunc_bitmixture,40,50,50, 0.1, 0.25);', 'gray (one-point)', 'SSGAMOX(@ObjFunc_bitmixture,40,50,50, 0.1, 0.25);', 'one-point', 10);

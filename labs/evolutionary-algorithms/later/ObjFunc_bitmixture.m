% trimodal Gaussian mixture

function y = ObjFunc_bitmixture(x)
global GaussMixtureParams

% x = gray2bit(bit2real(x));
x = bit2real(x);
y = 0;
[rowsGM, columnsGM] = size(GaussMixtureParams);
for i = 1:rowsGM
  y = y + normpdf(x, GaussMixtureParams(i,1), GaussMixtureParams(i,2));
end;
y = y ./ rowsGM;

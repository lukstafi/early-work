% trimodal Gaussian mixture

function y = ObjFunc_bitmixture(x)
global GaussMixtureParams

% x = gray2bit(bit2real(x));
x = bit2real(x);
y = 0;
for i = 1:rows(GaussMixtureParams)
  y = y + normal_pdf(x, GaussMixtureParams(i,1), GaussMixtureParams(i,2));
end;
y = y ./ rows(GaussMixtureParams);

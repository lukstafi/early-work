% trimodal Gaussian mixture

function y = ObjFunc_mixture(x)
global GaussMixtureMeans
global GaussMixtureStdDev

GaussMixtureMeans
GaussMixtureStdDev

[rowsGM, columnsGM] = size(GaussMixtureMeans);
[rowsX, columnsX] = size(x);
y = zeros(rowsX,1);
for n = 1:rowsGM
  for k = 1:rowsX
    mx = x(k,:) - GaussMixtureMeans(n,:);
    y(k) = y(k) + normpdf(mx*mx', 0, GaussMixtureStdDev(n));
  end;
end;
y = y ./ rows(GaussMixtureMeans);

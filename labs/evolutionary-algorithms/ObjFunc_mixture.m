% trimodal Gaussian mixture

function y = ObjFunc_mixture(x)
global GaussMixtureMeans
global GaussMixtureVariances

y = zeros(rows(x),1);
for n = 1:rows(GaussMixtureMeans)
  for k = 1:rows(x)
    mx = x(k,:) - GaussMixtureMeans(n,:);
    y(k) = y(k) + normal_pdf(mx*mx', 0, GaussMixtureVariances(n));
  end;
end;
y = y ./ rows(GaussMixtureMeans);

function [rate, total] = efficiency (Y, T)

%	CONFMAT Copyright (c) Ian T Nabney (1996-2001) Modified by Lukasz Stafiniak

[n c]=size(Y);
[n2 c2]=size(T);

if n~=n2 | c~=c2
  error('Outputs and targets are different sizes')
end

if c > 1
  % Find the winning class assuming 1-of-N encoding
  [maximum Yclass] = max(Y', [], 1);

  TL=[1:c]*T';
else
  % Assume two classes with 0-1 encoding
  c = 2;
  class2 = find(T > 0.5);
  TL = ones(n, 1);
  TL(class2) = 2;
  class2 = find(Y > 0.5);
  Yclass = ones(n, 1);
  Yclass(class2) = 2;
end

% Compute 
correct = (Yclass==TL);
total=sum(sum(correct));
rate=total*100/n;

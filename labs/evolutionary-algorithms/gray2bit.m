% transform a Gray code into binary code

function B = gray2bit (G)
  
  B = [];
  n = columns (G);
  B(:,1) = G(:,1);
  for i = 2:n
    B(:,i) = xor (B(:,i-1), G(:,i));
  end;

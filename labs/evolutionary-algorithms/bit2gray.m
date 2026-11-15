% transform a binary code into Gray code

function G = bit2gray (B)
  
  G = [];
  n = columns (B);
  G(:,1) = B(:,1);
  for i = 2:n
    G(:,i) = xor (B(:,i-1), B(:,i));
  end;

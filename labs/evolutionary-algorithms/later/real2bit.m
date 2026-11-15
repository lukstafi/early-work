% real2bit(d,x) -- transform 0 <= x < 1 into a length d binary representation

function v = real2bit(d,x)

  v = [];
  for i=1:d
    v = [v, x >= 0.5];
    x = x.*2-(x >= 0.5);
  end;


    
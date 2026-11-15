% transofrm binary vector v into a number x, 0 <= x < 1

function x = bit2real(v)

  powers = 2.^(-(1:columns(v)));
  x = v * powers';

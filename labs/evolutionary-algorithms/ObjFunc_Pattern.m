% Pattern

function y = ObjFunc_Pattern(x);

PATTERN = [ 1 0 1 1 0 1 0 0 0 1    1 0 1 1 1 0 0 0 0 1    1 0 0 0 0 0 1 1 1 1    1 1 0 0 0 0 1 1 0 1 ];

y = sum( x == ones(size(x, 1), 1) * PATTERN, 2 );

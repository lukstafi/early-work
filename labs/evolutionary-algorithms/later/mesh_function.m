% compute Z matrix for a mesh

function Z = mesh_function(F, X, Y)

  [rowsX, columnsX] = size(X);
  for m = 1:rowsX
    for n = 1:columnsX
      Z(m,n) = feval(F, [X(m,n), Y(m,n)]);
    end;
  end;

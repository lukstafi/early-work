% compute Z matrix for a mesh

function Z = mesh_function(F, X, Y)

  for m = 1:rows(X)
    for n = 1:columns(X)
      Z(m,n) = feval(F, [X(m,n), Y(m,n)]);
    end;
  end;

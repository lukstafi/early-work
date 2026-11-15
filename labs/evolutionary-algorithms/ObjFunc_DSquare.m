% Bimodal square

function y = ObjFunc_DSquare(x)

aux = (bit2real(x)-0.5);
y =  aux .* aux;

function y = invf (a, func)
% Inverse of output neuron activation function (one of: 'linear', 'tanh', 'logistic')
[nobs, nout] = size(a);
switch func

  case 'linear'    % Linear outputs

    y = a;

  case 'logistic'  % Logistic outputs
    % Prevent overflow and underflow: use same bounds as mlperr
    if a==0
        y = -708.3964;
    elseif a==1
            y = 36.0437; 
        else
            a = max(a, realmin);
            a = min(a, 1 - eps);
    y = -log(1./a - 1);
end
  case 'tanh'      % Bipolar outputs
      
      y = atanh(a);

  otherwise
    error(['Unknown (or not invertible: softmax) activation function ', func]);  
end

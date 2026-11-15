function y = outf (a, func)
% Output neuron activation function, one of: 'linear', 'logistic', 'softmax', 'max', 'tanh'
[nobs, nout] = size(a);
switch func

  case 'linear'    % Linear outputs

    y = a;

  case 'logistic'  % Logistic outputs
    % Prevent overflow and underflow: use same bounds as mlperr
    % Ensure that log(1-y) is computable: need exp(a) > eps
    maxcut = -log(eps);
    % Ensure that log(y) is computable
    mincut = -log(1/realmin - 1);
    a = min(a, maxcut);
    a = max(a, mincut);
    y = 1./(1 + exp(-a));

  case 'softmax'   % Softmax outputs
  
    % Prevent overflow and underflow: use same bounds as glmerr
    % Ensure that sum(exp(a), 2) does not overflow
    maxcut = log(realmax) - log(nout);
    % Ensure that exp(a) > 0
    mincut = log(realmin);
    a = min(a, maxcut);
    a = max(a, mincut);
    temp = exp(a);
    y = temp./(sum(temp, 2)*ones(1, nout));

  case 'max'   % defuzzified classification outputs

      [foo, I] = max(a');
      y = zeroes(nobs, nout);
      for i=1:nobs
        y(i,I(i)) = 1;
    end

  case 'tanh'      % Bipolar outputs
      
      y = tanh(a);
    
  otherwise
    error(['Unknown activation function ', func]);  
end

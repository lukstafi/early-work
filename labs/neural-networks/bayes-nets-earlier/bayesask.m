function [p, desc] = bayesask (bnet, engine, qvar, qval, varargin)
% Check a probability in the Bayesian net.
%
% P = BAYESASK (BNET, QVAR, QVAL, A, AVAL, B, BVAL, ...)
% Returns the probability P = P (QVAR=QVAL | A=AVAL, B=BVAL, ...)
% QVAR, A, B, ... are strings (variable names), BNET must have NAMES field set.
% [P, DESC] = BAYESASK (BNET, QVAR, QVAL, A, AVAL, B, BVAL, ...)
% Returns also DESC = 'P (QVAR=QVAL | A=AVAL, B=BVAL, ...) = P'
% There may be no conditioning variables.

% By Lukasz Stafiniak 2006 lukstafi@gmail.com

nvar = length(bnet.dnodes);
ev = cell(nvar,1);
nin = length(varargin)/2;
if nargout > 1
    desc = ['P (' qvar '=' num2str(qval)];
end
for i=1:nin
    ev{bnet.names{varargin{2*i-1}}} = varargin{2*i};
    if nargout > 1
        if i == 1
            desc = [desc  ' | '];
        else
            desc = [desc ', '];
        end
        desc = [desc varargin{2*i-1} '=' num2str(varargin{2*i})];
    end
end
eng = enter_evidence(engine, ev);
mQ = marginal_nodes (eng, bnet.names{qvar});
p = mQ.T(qval);
if nargout > 1
    desc = [desc ') = ' num2str(p)];
end


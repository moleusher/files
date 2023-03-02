function Y = gammaln(X)
%GAMMALN Logarithm of gamma function of codistributed array
%   Y = GAMMALN(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = gammaln(D)
%   end
%   
%   See also GAMMA,  CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@gammaln, X);

function Y = gamma(X)
%GAMMA Gamma function of codistributed array
%   Y = GAMMA(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = gamma(D)
%   end
%   
%   See also GAMMALN,  CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@gamma, X);

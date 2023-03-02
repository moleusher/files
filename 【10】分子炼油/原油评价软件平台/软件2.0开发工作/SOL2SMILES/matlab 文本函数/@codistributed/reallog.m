function Y = reallog(X)
%REALLOG Real logarithm of codistributed array
%   Y = REALLOG(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = -exp(1)*codistributed.ones(N)
%       try reallog(D), catch, disp('negative input!'), end
%       E = reallog(-D)
%   end
%   
%   See also REALLOG, CODISTRIBUTED.


%   Copyright 2006-2013 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOpWithCatch(@reallog, X);

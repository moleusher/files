function y = log1p(z)
%LOG1P Compute log(1+z) accurately of codistributed array
%   Y = LOG1P(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = eps(1) .* codistributed.ones(N);
%       E = log1p(D)
%   end
%   
%   See also LOG1P, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

y = codistributed.pElementwiseUnaryOp(@log1p, z);

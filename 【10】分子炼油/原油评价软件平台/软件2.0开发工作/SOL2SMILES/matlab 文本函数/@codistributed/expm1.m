function y = expm1(z)
%EXPM1 Compute EXP(X)-1 accurately for codistributed array
%   Y = EXPM1(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = eps(1) .* codistributed.ones(N);
%       E = expm1(D)
%   end
%   
%   See also EXPM1, CODISTRIBUTED.


%   Copyright 2006-2013 The MathWorks, Inc.

y = codistributed.pElementwiseUnaryOp(@expm1, z);

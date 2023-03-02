function Y = acosh(X)
%ACOSH Inverse hyperbolic cosine of codistributed array
%   Y = ACOSH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = acosh(D)
%   end
%   
%   See also ACOSH, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2014 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@acosh, X);

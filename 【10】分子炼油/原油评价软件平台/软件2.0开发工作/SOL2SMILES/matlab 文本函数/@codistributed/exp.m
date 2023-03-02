function Y = exp(X)
%EXP Exponential of codistributed array
%   Y = EXP(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = exp(D)
%   end
%   
%   See also EXP, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@exp, X);

function Y = cot(X)
%COT Cotangent of codistributed array in radians
%   Y = COT(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = cot(D)
%   end
%   
%   See also COT, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@cot, X);

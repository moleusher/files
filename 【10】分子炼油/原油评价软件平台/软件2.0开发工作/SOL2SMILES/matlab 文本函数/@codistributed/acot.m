function Y = acot(X)
%ACOT Inverse cotangent of codistributed array, result in radians
%   Y = ACOT(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = acot(D)
%   end
%   
%   See also ACOT, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@acot, X);

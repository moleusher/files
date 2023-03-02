function Y = asin(X)
%ASIN Inverse sine of codistributed array, result in radians
%   Y = ASIN(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = asin(D)
%   end
%   
%   See also ASIN, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@asin, X);

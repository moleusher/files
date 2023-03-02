function Y = atan(X)
%ATAN Inverse tangent of codistributed array, result in radians
%   Y = ATAN(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = atan(D)
%   end
%   
%   See also ATAN, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@atan, X);

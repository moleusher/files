function Y = asec(X)
%ASEC Inverse secant of codistributed array, result in radians
%   Y = ASEC(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = asec(D)
%   end
%   
%   See also ASEC, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@asec, X);

function Y = asech(X)
%ASECH Inverse hyperbolic secant of codistributed array
%   Y = ASECH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = asech(D)
%   end
%   
%   See also ASECH, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2014 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@asech, X);

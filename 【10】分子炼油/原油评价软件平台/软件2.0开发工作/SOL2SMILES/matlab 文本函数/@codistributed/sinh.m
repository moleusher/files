function Y = sinh(X)
%SINH Hyperbolic sine of codistributed array
%   Y = SINH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       E = sinh(D)
%   end
%   
%   See also SINH, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@sinh, X);

function Y = coth(X)
%COTH Hyperbolic cotangent of codistributed array
%   Y = COTH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       E = coth(D)
%   end
%   
%   See also COTH, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@coth, X);

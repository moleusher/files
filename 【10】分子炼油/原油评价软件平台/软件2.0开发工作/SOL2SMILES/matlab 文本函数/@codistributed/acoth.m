function Y = acoth(X)
%ACOTH Inverse hyperbolic cotangent of codistributed array
%   Y = ACOTH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       E = acoth(D)
%   end
%   
%   See also ACOTH, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@acoth, X);

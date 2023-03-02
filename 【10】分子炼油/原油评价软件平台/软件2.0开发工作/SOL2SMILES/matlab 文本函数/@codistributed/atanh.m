function Y = atanh(X)
%ATANH Inverse hyperbolic tangent of codistributed array
%   Y = ATANH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = atanh(D)
%   end
%   
%   See also ATANH, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@atanh, X);

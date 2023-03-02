function Y = sqrt(X)
%SQRT Square root of codistributed array
%   Y = SQRT(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 2 * codistributed.ones(N)
%       E = sqrt(D)
%   end
%   
%   See also SQRT, CODISTRIBUTED.


%   Copyright 2006-2013 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@sqrt, X);

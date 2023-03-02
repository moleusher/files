function Y = log(X)
%LOG Natural logarithm of codistributed array
%   Y = LOG(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = log(D)
%   end
%   
%   See also LOG, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@log, X);

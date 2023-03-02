function Y = beta(Z,W)
%BETA  Beta function for codistributed arrays
%   Y = BETA(Z,W) computes the beta function for corresponding elements
%   of Z and W. The arrays Z and W must be real and nonnegative. Both arrays
%   must be the same size, or either can be scalar.
%   
%   Example:
%   spmd
%       N = 1000;
%       Z = rand(N, 'codistributed');
%       W = rand(N, 'codistributed');
%       beta(Z, W)
%   end
%   
%   See also BETA, CODISTRIBUTED/BETALN, CODISTRIBUTED.


%   Copyright 2006-2014 The MathWorks, Inc.

Y = codistributed.pElementwiseOp(@beta, Z, W);

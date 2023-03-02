function Y = betaln(Z,W)
%BETALN  Logarithm of beta function for codistributed arrays
%   Y = BETALN(Z,W) computes the natural logarithm of the beta function for
%   corresponding elements of Z and W. The arrays Z and W must be real and 
%   nonnegative. Both arrays must be the same size, or either can be scalar.
%   
%   Example:
%   spmd
%       N = 1000;
%       Z = rand(N, 'codistributed');
%       W = rand(N, 'codistributed');
%       betaln(Z, W)
%   end
%   
%   See also BETALN, CODISTRIBUTED/BETA, CODISTRIBUTED.


%   Copyright 2006-2014 The MathWorks, Inc.

Y = codistributed.pElementwiseOp(@betaln, Z, W);

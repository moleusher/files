function Y = asinh(X)
%ASINH Inverse hyperbolic sine of codistributed array
%   Y = ASINH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = asinh(D)
%   end
%   
%   See also ASINH, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@asinh, X);


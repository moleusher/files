function Y = uplus(X)
%+ Unary plus for codistributed array
%   B = +A
%   B = UPLUS(A)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.eye(N);
%       D2 = +D1
%   end
%   
%   See also UPLUS, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@uplus, X);

function Y = log10(X)
%LOG10 Common (base 10) logarithm of codistributed array
%   Y = LOG10(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 10.^codistributed.colon(1,N);
%       E = log10(D)
%   end
%   
%   See also LOG10, CODISTRIBUTED, CODISTRIBUTED/COLON.


%   Copyright 2006-2013 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@log10, X);

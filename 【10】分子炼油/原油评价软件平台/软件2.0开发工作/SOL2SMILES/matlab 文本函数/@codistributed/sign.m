function Y = sign(X)
%SIGN Signum function for codistributed array
%   Y = SIGN(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1, N) - ceil(N/2)
%       E = sign(D)
%   end
%   
%   See also SIGN, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@sign, X);

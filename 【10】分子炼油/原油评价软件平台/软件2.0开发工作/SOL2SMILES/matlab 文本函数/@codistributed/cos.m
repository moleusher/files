function Y = cos(X)
%COS Cosine of codistributed array in radians
%   Y = COS(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = cos(D)
%   end
%   
%   See also COS, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@cos, X);

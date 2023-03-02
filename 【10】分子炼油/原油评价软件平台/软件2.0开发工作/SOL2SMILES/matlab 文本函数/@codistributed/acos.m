function Y = acos(X)
%ACOS Inverse cosine of codistributed array, result in radians
%   Y = ACOS(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = acos(D)
%   end
%   
%   See also ACOS, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2013 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@acos, X);

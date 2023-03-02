function Y = asind(X)
%ASIND Inverse sine of codistributed array, result in degrees
%   Y = ASIND(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = asind(D)
%   end
%   
%   See also ASIND, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

if ~isreal(X)
    error(message('parallel:distributed:AsindComplexInput'));
end

Y = codistributed.pElementwiseUnaryOp(@asind, X);


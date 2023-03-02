function Y = acscd(X)
%ACSCD Inverse cosecant of codistributed array, result in degrees
%   Y = ACSCD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = acscd(D)
%   end
%   
%   See also ACSCD, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

if ~isreal(X)
    error(message('parallel:distributed:AcscdComplexInput'));
end

Y = codistributed.pElementwiseUnaryOp(@acscd, X);

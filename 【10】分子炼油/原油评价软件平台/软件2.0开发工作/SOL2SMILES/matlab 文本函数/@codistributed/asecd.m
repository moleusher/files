function Y = asecd(X)
%ASECD Inverse secant of codistributed array, result in degrees
%   Y = ASECD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = asecd(D)
%   end
%   
%   See also ASECD, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

if ~isreal(X)
    error(message('parallel:distributed:AsecdComplexInput'));
end

Y = codistributed.pElementwiseUnaryOp(@asecd, X);


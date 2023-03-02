function Y = cotd(X)
%COTD Cotangent of codistributed array in degrees
%   Y = COTD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = cotd(D)
%   end
%   
%   See also COTD, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

if ~isreal(X)
    error(message('parallel:distributed:CotdComplexInput'));
end

Y = codistributed.pElementwiseUnaryOp(@cotd, X);

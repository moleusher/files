function Y = acotd(X)
%ACOTD Inverse cotangent of codistributed array, result in degrees
%   Y = ACOTD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = acotd(D)
%   end
%   
%   See also ACOTD, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

if ~isreal(X)
    error(message('parallel:distributed:AcotdComplexInput'));
end

Y = codistributed.pElementwiseUnaryOp(@acotd, X);

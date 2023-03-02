function Y = atand(X)
%ATAND Inverse tangent of codistributed array, result in degrees
%   Y = ATAND(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = atand(D)
%   end
%   
%   See also ATAND, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

if ~isreal(X)
    error(message('parallel:distributed:AtandComplexInput'));
end

Y = codistributed.pElementwiseUnaryOp(@atand, X);

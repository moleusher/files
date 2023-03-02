function Y = tand(X)
%TAND Tangent of codistributed array in degrees
%   Y = TAND(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 45*codistributed.ones(N);
%       E = tand(D)
%   end
%   
%   See also TAND, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

if ~isreal(X)
    error(message('parallel:distributed:TandComplexInput'));
end

Y = codistributed.pElementwiseUnaryOp(@tand, X);

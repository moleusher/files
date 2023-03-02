function Y = sind(X)
%SIND Sine of codistributed array in degrees
%   Y = SIND(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = pi/2*codistributed.ones(N);
%       E = sind(D)
%   end
%   
%   See also SIND, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

if ~isreal(X)
    error(message('parallel:distributed:SindComplexInput'));
end

Y = codistributed.pElementwiseUnaryOp(@sind, X);

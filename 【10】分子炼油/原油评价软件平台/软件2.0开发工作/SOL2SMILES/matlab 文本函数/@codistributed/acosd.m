function Y = acosd(X)
%ACOSD Inverse cosine of codistributed array, result in degrees
%   Y = ACOSD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = acosd(D)
%   end
%   
%   See also ACOSD, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2013 The MathWorks, Inc.

if ~isreal(X)
    error(message('parallel:distributed:AcosdComplexInput'));
end

Y = codistributed.pElementwiseUnaryOp(@acosd, X);

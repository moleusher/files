function Y = secd(X)
%SECD Secant of codistributed array in degrees
%   Y = SECD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = secd(D)
%   end
%   
%   See also SECD, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2013 The MathWorks, Inc.

if ~isreal(X)
    error(message('parallel:distributed:SecdComplexInput'));
end

Y = codistributed.pElementwiseUnaryOp(@secd, X);

function Y = cosd(X)
%COSD Cosine of codistributed array in degrees
%   Y = COSD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = cosd(D)
%   end
%   
%   See also COSD, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2013 The MathWorks, Inc.

if ~isreal(X)
    error(message('parallel:distributed:CosdComplexInput'));
end

Y = codistributed.pElementwiseUnaryOp(@cosd, X);

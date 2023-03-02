function Y = cscd(X)
%CSCD Cosecant of codistributed array in degrees
%   Y = CSCD(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = cscd(D)
%   end
%   
%   See also CSCD, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

if ~isreal(X)
    error(message('parallel:distributed:CscdComplexInput'));
end

Y = codistributed.pElementwiseUnaryOp(@cscd, X);

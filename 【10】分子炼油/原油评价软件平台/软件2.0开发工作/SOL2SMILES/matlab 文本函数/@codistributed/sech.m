function Y = sech(X)
%SECH Hyperbolic secant of codistributed array
%   Y = SECH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(N);
%       E = sech(D)
%   end
%   
%   See also SECH, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@sech, X);

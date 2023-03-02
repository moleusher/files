function Y = acsch(X)
%ACSCH Inverse hyperbolic cosecant of codistributed array
%   Y = ACSCH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       E = acsch(D)
%   end
%   
%   See also ACSCH, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@acsch, X);
